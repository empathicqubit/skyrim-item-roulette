mkdir "$PSScriptRoot/build" -ErrorAction SilentlyContinue

pnpm install -C $PSScriptRoot

$ZipName = "EmpathicQubit-ItemRoulette-Dev.zip"
$ModPath = (Get-Item "$env:APPDATA/Vortex/skyrim*/mods").FullName+"/"+[IO.Path]::GetFileNameWithoutExtension($ZipName)

if((Get-Item $ModPath).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {
    Write-Host "Already setup."
    return
}

$ZipPath = "$PSScriptRoot/build/$ZipName"
Compress-Archive -Update -Path "$PSScriptRoot/plugin/Data/_EQ_ItemRoulette_Placeholder.md" -DestinationPath $ZipPath

$VortexPath = (Get-ItemProperty HKLM:\SOFTWARE\57979c68-f490-55b8-8fed-8b017a5af2fe).InstallLocation

Invoke-WebRequest -Uri http://nginx.org/download/nginx-1.21.0.zip -OutFile "$PSScriptRoot/build/nginx.zip"
Expand-Archive -Path "$PSScriptRoot/build/nginx.zip" -DestinationPath "$PSScriptRoot/build"
$NginxPath = "$PSScriptRoot/build/nginx-1.21.0"

Move-Item "$NginxPath/conf/nginx.conf" "$NginxPath/conf/nginx.conf.old"
(Get-Content "$NginxPath/conf/nginx.conf.old") `
    -replace '^([^#]*root).*$', "`$1 $PSScriptRoot/build;" `
    -replace '^([^#]*listen).*$', '$1 8998;' `
    | Out-File -Encoding ascii "$NginxPath/conf/nginx.conf"

$job = Start-Job { & "$NginxPath/nginx.exe" -g 'daemon off;' }

Start-Sleep -Seconds 1

& "$VortexPath/Vortex.exe" -i "http://localhost:8998/$ZipName"

Start-Sleep -Seconds 10

Stop-Job $job

Remove-Item -Recurse $ModPath
New-Item -Path $ModPath -ItemType SymbolicLink -Value "$PSScriptRoot/plugin/Data"