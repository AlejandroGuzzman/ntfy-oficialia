# Bitácora

## Etapa 1 — Primer intento con el binario (4 nov 2026)

- Se instaló ntfy v2.37.2 en Windows con el `.exe` de *Releases* y `server.yml` en `C:\ProgramData\ntfy\`.
- **Cambio de enfoque:** el doctor pidió que el servidor saliera del código fuente. Se descartó el binario descargado.

## Etapa 2 — Preparar el entorno de compilación (4 nov 2026)

- Instalados Git para Windows, Docker Desktop y WSL 2:
  ```powershell
  winget install --id Git.Git -e
  winget install --id Docker.DockerDesktop -e
  wsl --install --no-distribution
  ```
- Se eligió compilar dentro de Docker con el `Dockerfile-build` oficial para no instalar Go, Node y Python directamente en Windows.

## Etapa 3 — Compilación desde el código

- Clonado en `v2.37.2`.
- **Problema:** con el clonado normal, Git en Windows convierte los saltos de línea a CRLF y el `Makefile` falla dentro del contenedor Linux.
  **Solución:** clonar con `--config core.autocrlf=false`.
- Build terminado: 46 pasos, ~254 s, imagen `ntfy-oficialia:2.37.2` de 36.5 MB.

## Etapa 4 — Despliegue y seguridad

- Carpeta de despliegue con `docker-compose.yml`, `etc/server.yml` y `cache/`.
- Acceso anónimo bloqueado (`auth-default-access: deny-all`); creados los usuarios `alex` (admin) y `lector` (solo lectura de `pruebas`).
- Regla de firewall TCP 8080.

## Etapa 5 — Pruebas (11 nov 2026)

- Publicación con `curl` al tema `pruebas` → **notificación recibida en el teléfono Android**.
- **Duda resuelta:** aparecían dos procesos en el puerto 8080. `com.docker.backend` en `0.0.0.0:8080` es el contenedor publicado a la red; `wslrelay` en `127.0.0.1:8080` es el puente interno de WSL, no otro servidor.
- **Problema:** la IP de la PC cambia al cambiar de red (172.17.61.73 → 192.168.7.187) y el teléfono deja de conectar. La 172.21.224.1 que aparece es el adaptador virtual de WSL/Docker, no la de la red.
  **Solución:** `scripts/actualizar-ip.ps1`.

## Pendiente

- Contraseñas definitivas.
- Migración a un servidor de la Oficialía con Docker Engine en Linux (la misma imagen y el mismo compose sirven).
