<#
    .SYNOPSIS
    Builds the plugin and optionally reloads it in Vortex.

    .PARAMETER InstallDependencies
    Installs script dependencies with Chocolatey, except Papyrus, and quit

    .PARAMETER StartVortex
    Start Vortex on the appropriate port and do nothing else.

    .PARAMETER Target
    Build a specific Makefile target

    .PARAMETER KickVortex
    Syncs the plugin with Vortex. This option requires Node.js and pnpm to
    communicate with Vortex. Keep in mind that this only half works if Vortex
    wasn't already started, so if it fails just run the script again.
    If there are file conflicts, take changes from the game directory! This will
    have changes from the ESP that were made in Creation Kit! You need to
    symlink the /plugin directory into the mod staging area, preferably using
    setup-dev.ps1 script.

    .PARAMETER KickPort
    The port for Vortex to listen on.

    .PARAMETER Reload
    Kills Skyrim before and loads it after building. It completely kills the game
    because I had trouble getting hlp and reloadscript commands to work.
#>
param (
    [Parameter(Mandatory = $False)]
    [Switch]
    $InstallDependencies,
    [Parameter(Mandatory = $False)]
    [Switch]
    $StartVortex,

    [Parameter(Mandatory = $False)]
    [String]
    $Target,

    [Parameter(Mandatory = $False)]
    [Switch]
    $KickVortex,
    [Parameter(Mandatory = $False)]
    [int]
    $KickPort = 6969,

    [Parameter(Mandatory = $False)]
    [Switch]
    $Reload
)

if($InstallDependencies) {
    # Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    choco install blender gimp 7zip autohotkey make nodejs
    return 0
}

if($StartVortex) {
    Stop-Process -Name Vortex -ErrorAction SilentlyContinue
    $VortexPath = (Get-ItemProperty HKLM:\SOFTWARE\57979c68-f490-55b8-8fed-8b017a5af2fe).InstallLocation
    $GameId = (Get-Item "$env:APPDATA/Vortex/skyrim*").BaseName
    & "$VortexPath/Vortex.exe" --remote-debugging-port=$KickPort --game=$GameId
    return 0
}

New-Item -ItemType Directory "$PSScriptRoot/build" -ErrorAction SilentlyContinue

Add-Type -Path "$PSScriptRoot/Gameloop.Vdf.dll" -ErrorAction SilentlyContinue

$Proc = Get-Process Skyrim*

# Use the running instance
if($Proc) {
    $Wmi = Get-WmiObject -Class win32_process -filter "ProcessId=$($Proc.Id)"
    $SkyrimBase = Split-Path $Wmi.ExecutablePath
}

# Check for Steam version
if(-not $SkyrimBase) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $steamInstallPath = "${env:ProgramFiles(x86)}/Steam"
    }
    else {
        $steamInstallPath = "$env:ProgramFiles/Steam"
    }

    $libraryFolders = [Gameloop.Vdf.VdfConvert]::Deserialize((Get-Content "$steamInstallPath/steamapps/libraryfolders.vdf") -join "`n")

    $steamLibraries = @()

    $steamLibraries += @($steamInstallPath)
    $steamLibraries += Get-Member -InputObject $libraryFolders.Value -MemberType Dynamic | where-object -Property Name -Match "[0-9]+" | ForEach-Object { $libraryFolders.Value[$_.Name].ToString() }

    $manifestPath = $None
    foreach($steamLibrary in $steamLibraries) {
        $manifestPath = Get-Item -Path @(
            "$steamLibrary/steamapps/appmanifest_611670.acf",
            "$steamLibrary/steamapps/appmanifest_489930.acf",
            "$steamLibrary/steamapps/appmanifest_72850.acf"
        ) -ErrorAction SilentlyContinue | Select-Object -First 1

        if($manifestPath) {
            Write-Host "Manifest found at $($manifestPath.FullName)"
            break
        }
    }

    if($manifestPath) {
        $appManifest = [Gameloop.Vdf.VdfConvert]::Deserialize((Get-Content $manifestPath) -join "`n")
        $installDir = $appManifest.Value["installdir"].ToString()
        $SkyrimBase = "$(Split-Path $manifestPath)/common/$installDir"
    }
}

# Default to non-Steam version
if(-not $SkyrimBase) {
    $SkyrimBase = (Get-Item -Path @(
        "$env:ProgramFiles/Bethesda*/*Skyrim*"
        "${env:ProgramFiles(x86)}/Bethesda*/*Skyrim*"
    )).FullName
}

if($Reload) {
    if($Proc) {
        Stop-Process $Proc
    }
}

make -C "$PSScriptRoot" SKYRIM_BASE=$SkyrimBase $Target

if(-not $LastExitCode -eq 0) {
    return $LastExitCode
}

if($KickVortex) {
    $env:KICK_PORT=$KickPort

    pnpm install -C "$PSScriptRoot"

    if(-not $LastExitCode -eq 0) {
        return $LastExitCode
    }

    node "$PSScriptRoot/kick-vortex.js"

    if(-not $LastExitCode -eq 0) {
        return $LastExitCode
    }
}

if($Reload) {
    # Prefer SKSE loader if we have it installed
    $SkyrimExe = Get-Item -Path @(
        "$SkyrimBase/skse*_loader.exe",
        "$SkyrimBase/Skyrim*.exe"
    ) | Select-Object -First 1

    Start-Process -WorkingDirectory $SkyrimExe.DirectoryName -FilePath $SkyrimExe

    # Send JSON command to load first autosave. Doesn't currently work.
    do {
        $wrFail = $None
        Start-Sleep -Seconds 1
        Invoke-WebRequest -Uri "http://localhost:8558/api/command" `
            -Method Post `
            -ErrorVariable $wrFail `
            -ContentType 'application/json' `
            -Headers @{ Accept = 'application/json' } `
            -Body @"
{ "command": "load \"autosave1\" " }
"@
    } while ($wrFail)
}

return 0