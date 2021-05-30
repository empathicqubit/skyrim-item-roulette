<#
    .SYNOPSIS
    Builds the plugin and optionally reloads it in Vortex.

    .PARAMETER InstallDependencies
    Installs script dependencies with Chocolatey, except Papyrus, and quit

    .PARAMETER Scripts
    Build Papyrus scripts

    .PARAMETER Models
    Build Blender models

    .PARAMETER Textures
    Build GIMP textures

    .PARAMETER Zip
    Build the ZIP AND NOTHING ELSE. You probably don't want this option.

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

    choco install blender gimp 7zip autohotkey
}

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

    $Gimp = (Get-Item -Path @("$Env:ProgramFiles/GIMP*/bin/gimp-console*.exe", "${env:ProgramFiles(x86)}/GIMP*/bin/gimp-console*.exe")).FullName
    & $Gimp -n -i --batch-interpreter python-fu-eval -b "import export_gimp_textures"

    if($LastExitCode -ne 0) {
        return $LastExitCode
    }

    Pop-Location
}


if($Models) {
    $Blender = (Get-Item -Path @("${env:ProgramFiles(x86)}/blender*/blender*/blender.exe", "$env:ProgramFiles/blender*/blender*/blender.exe")).FullName
    & $Blender --background --python "$PSScriptRoot/export_blender_models.py"

    if($LastExitCode -ne 0) {
        return $LastExitCode
    }

    $ChunkmergeBase = "$PSScriptRoot/build/ChunkMerge"
    $MeshSourceDir = "$PSScriptRoot/Source/Meshes/_EQ_ItemRoulette"
    $MeshDestDir = "$PSScriptRoot/plugin/Data/Meshes/_EQ_ItemRoulette"
    $ChunkMergeZip = "$PSScriptRoot/build/chunkmerge.7z"
    if(-not (Test-Path $ChunkmergeBase)) {
        Invoke-WebRequest -Uri "https://github.com/downloads/skyfox69/NifUtils/ChunkMerge0155.7z" -OutFile $ChunkMergeZip
        7z x "-o$PSScriptRoot/build" $ChunkMergeZip
    }

    $ChunkMergeConfig = @"
<Config>
    <PathSkyrim>$SkyrimBase</PathSkyrim>
    <PathNifXML>$PSScriptRoot/nif.xml</PathNifXML>
    <PathTemplate>$MeshSourceDir</PathTemplate>
    <LastTexture></LastTexture>
    <LastTemplate></LastTemplate>
    <DirSource></DirSource>
    <DirDestination></DirDestination>
    <DirCollision></DirCollision>
    <MatHandling>0</MatHandling>
    <VertexColorHandling>0</VertexColorHandling>
    <UpdateTangentSpace>1</UpdateTangentSpace>
    <ReorderProperties>1</ReorderProperties>
    <CollTypeHandling>1</CollTypeHandling>
    <CollMaterial>-553455049</CollMaterial>
    <MaterialScan>
        <MatScanTag>SkyrimHavokMaterial</MatScanTag>
        <MatScanName>SKY_HAV_</MatScanName>
        <MatScanPrefixList>
            <MatScanPrefix>Material</MatScanPrefix>
        </MatScanPrefixList>
        <MatScanIgnoreList>
            <MatScanIgnore>Unknown</MatScanIgnore>
        </MatScanIgnoreList>
    </MaterialScan>
    <DirectXView>
        <ShowTexture>1</ShowTexture>
        <ShowWireframe>0</ShowWireframe>
        <ShowColorWire>0</ShowColorWire>
        <ForceDDS>0</ForceDDS>
        <ColorWireframe>ffffffff</ColorWireframe>
        <ColorWireCollision>ffffff00</ColorWireCollision>
        <ColorBackground>ff200020</ColorBackground>
        <ColorSelected>ffff00ff</ColorSelected>
        <TexturePathList>
        </TexturePathList>
    </DirectXView>
</Config>
"@

    Out-File -Encoding ascii -FilePath "$ChunkmergeBase/ChunkMerge.xml" -InputObject $ChunkMergeConfig

    $ChunkMerge = "$ChunkmergeBase/ChunkMerge.exe"
    & $ChunkMerge

    # FIXME This path is not recursive because ChunkMerge can't handle it
    foreach($ChunkTemplate in (Get-Item "$MeshSourceDir/*_template.nif")) {
        $env:ChunkMerge_NifFile = Join-Path $MeshDestDir ($ChunkTemplate.Name -replace "_template.", ".")
        $env:ChunkMerge_CollisionFile = Join-Path $MeshDestDir ($ChunkTemplate.Name -replace "_template.", "_collision.")
        $env:ChunkMerge_TemplateFile = $ChunkTemplate.Name
        Start-Process -Wait -FilePath AutoHotkey -ArgumentList @("$PSScriptRoot/ChunkMerge.ahk")

        if($LastExitCode -ne 0) {
            return $LastExitCode
        }
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
    $VortexRunningWithDebuggingPortActive = `
        (Get-NetTCPConnection -State Listen -LocalPort $KickPort -ErrorAction SilentlyContinue) `
        | Where-Object { 
            $tcpConn = $_ 
            Get-Process -Name Vortex | Where-Object { $tcpConn.OwningProcess -eq $_.Id }
        }

    $env:KICK_PORT=$KickPort

    if (-not $VortexRunningWithDebuggingPortActive) {
        Stop-Process -Name Vortex -ErrorAction SilentlyContinue
        $VortexPath = (Get-ItemProperty HKLM:\SOFTWARE\57979c68-f490-55b8-8fed-8b017a5af2fe).InstallLocation
        $GameId = (Get-Item "$env:APPDATA/Vortex/skyrim*").BaseName
        & "$VortexPath/Vortex.exe" --remote-debugging-port=$KickPort --game=$GameId
    }

    pnpm install -C "$PSScriptRoot"

    node "$PSScriptRoot/kick-vortex.js"
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