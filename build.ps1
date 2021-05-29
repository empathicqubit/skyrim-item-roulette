<#
    .SYNOPSIS
    Builds the plugin and optionally reloads it in Vortex.

    .PARAMETER Scripts
    Build Papyrus scripts

    .PARAMETER Models
    Build Blender models

    .PARAMETER Textures
    Build GIMP textures

    .PARAMETER Zip
    Build the ZIP AND NOTHING ELSE. You probably don't want this option

    .PARAMETER KickVortex
    Syncs the plugin with Vortex. If there are file conflicts, take changes
    from the game directory! This will have changes from the ESP that were
    made in Creation Kit! You need to symlink the /plugin directory into
    the staging area, preferably using setup-dev.ps1 script.

    .PARAMETER Reload
    Reloads Skyrim after building. It completely kills and restarts the game
    as I had trouble getting hlp and reloadscript commands to work.
#>
param (
    [Parameter(Mandatory = $False)]
    [Switch]
    $Scripts,
    [Parameter(Mandatory = $False)]
    [Switch]
    $Models,
    [Parameter(Mandatory = $False)]
    [Switch]
    $Textures,
    [Parameter(Mandatory = $False)]
    [Switch]
    $Zip,

    [Parameter(Mandatory = $False)]
    [Switch]
    $KickVortex,
    [Parameter(Mandatory = $False)]
    [Switch]
    $Reload
)

if(-not $Scripts -and -not $Models -and -not $Textures -and -not $Zip) {
    $Scripts = $true
    $Textures = $true
    $Models = $true
    $Zip = $true
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
    $steamLibraries += Get-Member -InputObject $libraryFolders.Value -MemberType Dynamic | where-object -Property Name -Match "[0-9]+" | foreach { $libraryFolders.Value[$_.Name].ToString() }

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

if($Scripts) {
    # Compile the scripts
    & "$SkyrimBase/Papyrus Compiler/PapyrusCompiler.exe" `
        "$PsScriptRoot/Source/Scripts" `
        "-f=$SkyrimBase/Data/Source/Scripts/TESV_Papyrus_Flags.flg" `
        "-i=$SkyrimBase/Data/Source/Scripts;$PsScriptRoot/Source/Scripts" `
        "-o=$PsScriptRoot/plugin/Data/Scripts" `
        "-all"

    if($LastExitCode -ne 0) {
        return $LastExitCode
    }
}

if($Textures) {
    Push-Location "$PSScriptRoot"

    gimp-console -n -i --batch-interpreter python-fu-eval -b "import export_gimp_textures"

    if($LastExitCode -ne 0) {
        return $LastExitCode
    }

    Pop-Location
}

if($Models) {
    blender --background --python "$PSScriptRoot/export_blender_models.py"

    if($LastExitCode -ne 0) {
        return $LastExitCode
    }
}

if($Zip) {
    # ZIP up the deployment package
    $ZipPath = "$PSScriptRoot/build/Item Roulette for VRIK.zip"

    Remove-Item $ZipPath -ErrorAction SilentlyContinue
    Compress-Archive -Path $PSScriptRoot/plugin/* -DestinationPath $ZipPath
}

if($KickVortex) {
    # Restart Vortex and kick off deploy-mods event via Chrome Debug Protocol.
    Stop-Process -Name Vortex
    $env:KICK_PORT=6969
    $VortexPath = (Get-ItemProperty HKLM:\SOFTWARE\57979c68-f490-55b8-8fed-8b017a5af2fe).InstallLocation
    $GameId = (Get-Item "$env:APPDATA/Vortex/skyrim*").BaseName
    & "$VortexPath/Vortex.exe" --remote-debugging-port=$env:KICK_PORT --game=$GameId

    pnpm install -C "$PSScriptRoot"

    node "$PSScriptRoot/kick-vortex.js"
    Stop-Process -Name Vortex -ErrorAction SilentlyContinue
}

if($Reload) {
    if($Proc) {
        Stop-Process $Proc
    }

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