<#
    .SYNOPSIS
    Builds the plugin and optionally reloads it in Vortex.

    .PARAMETER Reload
    Reloads Skyrim after building.  Reloading assumes you have symlinked the mod
    into Vortex's staging area using the method in setup-dev.ps1. It completely
    kills and restarts the game as I had trouble getting hlp and reloadscript
    commands to work.
#>
param (
    [Parameter(Mandatory = $False)]
    [Switch]
    $Reload
)

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

# Build the models
blender.exe --background --python "$PSScriptRoot/export-blender-models.py"

if($LastExitCode -ne 0) {
    return $LastExitCode
}

# ZIP up the deployment package
$ZipPath = "$PSScriptRoot/build/Item Roulette for VRIK.zip"

Remove-Item $ZipPath -ErrorAction SilentlyContinue
Compress-Archive -Path $PSScriptRoot/plugin/* -DestinationPath $ZipPath

if($Reload) {
    if($Proc) {
        Stop-Process $Proc
    }

    # Restart Vortex and kick off deploy-mods event via Chrome Debug Protocol.
    Stop-Process -Name Vortex
    $env:KICK_PORT=6969
    $VortexPath = (Get-ItemProperty HKLM:\SOFTWARE\57979c68-f490-55b8-8fed-8b017a5af2fe).InstallLocation
    $GameId = (Get-Item "$env:APPDATA/Vortex/skyrim*").BaseName
    & "$VortexPath/Vortex.exe" --remote-debugging-port=$env:KICK_PORT --game=$GameId

    pnpm install -C "$PSScriptRoot"

    node.exe "$PSScriptRoot/kick-vortex.js"
    Stop-Process -Name Vortex -ErrorAction SilentlyContinue

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