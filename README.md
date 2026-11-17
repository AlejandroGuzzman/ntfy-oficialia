# ntfy — Servidor de notificaciones de la Oficialía Mayor

Servidor de notificaciones push autoalojado, compilado desde el código fuente y desplegado en la red local para la **Oficina de IA, Dirección de Desarrollo Organizacional, Oficialía Mayor de Gobierno del Estado de Tlaxcala**.

| | |
|---|---|
| Alumno | Jesús Alejandro Guzmán Cordero — Ing. en Inteligencia Artificial, IPN UPIIT Tlaxcala |
| Responsable | Dr. Pedro Aarón Hernández Avalos, Jefe de la Oficina de IA |
| Proyecto | "Inteligencia artificial aplicada al sector público" (Estancia Profesional, nov 2026) |
| Base | [ntfy](https://github.com/binwiederhier/ntfy) de Philipp Heckel, licencia Apache 2.0 / GPLv2, versión **v2.37.2** |

## Qué contiene este repositorio

Este repositorio **no copia el código de ntfy**: el código original se descarga del repositorio oficial en la versión fijada. Aquí está **lo que yo hice y modifiqué** para que funcione en la Oficialía:

| Archivo | Qué es |
|---|---|
| [`CAMBIOS.md`](CAMBIOS.md) | **Lo principal**: qué se agregó o modificó respecto al ntfy original y por qué |
| [`BITACORA.md`](BITACORA.md) | Qué se hizo cada etapa, problemas encontrados y cómo se resolvieron |
| [`docker-compose.yml`](docker-compose.yml) | Despliegue del contenedor (puertos, volúmenes, zona horaria, reinicio) |
| [`etc/server.yml`](etc/server.yml) | Configuración del servidor (autenticación, caché, URL base) |
| [`scripts/compilar.ps1`](scripts/compilar.ps1) | Descarga el código v2.37.2 y compila la imagen Docker |
| [`scripts/actualizar-ip.ps1`](scripts/actualizar-ip.ps1) | Ajusta la configuración cuando cambia la red / IP de la PC |
| [`scripts/comparar-con-original.ps1`](scripts/comparar-con-original.ps1) | Genera el diff del código local contra la versión oficial |
| [`evidencias/`](evidencias/) | Capturas del build, pruebas y notificación en el teléfono |

## Arquitectura

```
 Teléfono Android (app ntfy)          Sistemas / scripts (curl, HTTP)
            │  suscripción                        │  publicación
            └──────────────┐          ┌──────────┘
                           ▼          ▼
                 PC  ─  puerto 8080 (firewall)
                 Docker Desktop (WSL 2)
                 └─ contenedor "ntfy"  (imagen ntfy-oficialia:2.37.2)
                      ├─ /etc/ntfy/server.yml      ← etc/
                      └─ /var/cache/ntfy/          ← cache/  (mensajes y usuarios)
```

Solo red local, sin túnel ni exposición a internet (indicación del Dr. Hernández).

## Uso rápido

```powershell
# 1. Compilar la imagen desde el código fuente (~4 min)
.\scripts\compilar.ps1

# 2. Poner la IP de la PC en etc/server.yml y levantar
.\scripts\actualizar-ip.ps1
docker compose up -d

# 3. Crear el usuario administrador
docker exec -it ntfy ntfy user add --role=admin alex

# 4. Probar
curl.exe -u alex:<contraseña> -H "Title: ntfy Oficialía" -d "Hola" http://localhost:8080/pruebas
```

En el teléfono: app ntfy → **+** → tema `pruebas` → *Use another server* → `http://<IP>:8080` → usuario y contraseña.

## Estado

- [x] Compilado desde el código fuente (documentación, interfaz web y servidor)
- [x] Servidor corriendo con Docker Compose en la red local
- [x] Control de acceso: anónimos sin acceso, usuarios con permisos por tema
- [x] Notificación recibida en el teléfono
- [ ] Cambiar contraseñas de prueba por definitivas
- [ ] Migrar a un servidor de la Oficialía (misma imagen y mismo compose sobre Docker Engine en Linux)
