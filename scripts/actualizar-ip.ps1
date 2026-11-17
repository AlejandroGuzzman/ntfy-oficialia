# Detecta la IP actual de la PC, la escribe en etc/server.yml y reinicia ntfy.
# Usar cada vez que la PC cambie de red. Después, re-suscribirse en el teléfono con la IP nueva.

$Raiz   = Split-Path $PSScriptRoot -Parent
$Config = Join-Path $Raiz "etc\server.yml"

# Adaptador con puerta de enlace = red real (descarta el adaptador virtual de WSL/Docker)
$ip = @((Get-NetIPConfiguration |
        Where-Object IPv4DefaultGateway |
        Select-Object -First 1).IPv4Address.IPAddress)[0]

"IP detectada: $ip"

(Get-Content $Config -Raw) -replace 'http://[\d\.]+:8080', "http://${ip}:8080" |
    Set-Content $Config -NoNewline

Push-Location $Raiz
docker compose restart
docker logs --tail 3 ntfy
Pop-Location

"Servidor en http://${ip}:8080"
