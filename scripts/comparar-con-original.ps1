# Compara el código local de ntfy contra la versión oficial v2.37.2
# y guarda el resultado en cambios-codigo.diff.
# Si no hay salida, el código es idéntico al original.

$Src    = "C:\ntfy-src"
$Salida = Join-Path (Split-Path $PSScriptRoot -Parent) "cambios-codigo.diff"

Push-Location $Src
"Archivos modificados respecto a v2.37.2:"
git diff --stat v2.37.2
git status --short
git diff v2.37.2 | Out-File -Encoding utf8 $Salida
Pop-Location

if ((Get-Item $Salida).Length -eq 0) {
    "Sin cambios en el código fuente."
    Remove-Item $Salida
} else {
    "Diff guardado en $Salida"
}
