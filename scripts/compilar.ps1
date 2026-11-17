# Descarga el código de ntfy en la versión fijada y compila la imagen Docker.
# Uso: .\scripts\compilar.ps1   (requiere Git y Docker Desktop)

$Version = "2.37.2"
$Src     = "C:\ntfy-src"

if (-not (Test-Path $Src)) {
    # autocrlf=false: sin esto Git convierte a CRLF y el Makefile falla en Linux
    git clone --config core.autocrlf=false https://github.com/binwiederhier/ntfy.git $Src
}

Push-Location $Src
git fetch --tags
git checkout "v$Version"

docker build -f Dockerfile-build --build-arg VERSION=$Version -t "ntfy-oficialia:$Version" .
Pop-Location

docker images ntfy-oficialia
