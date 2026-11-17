# Evidencias

Capturas que documentan cada etapa. Nombres sugeridos:

| Archivo | Qué muestra |
|---|---|
| `01-build-terminado.png` | Final del `docker build` (46 pasos) |
| `02-docker-images.png` | `docker images ntfy-oficialia` con la imagen de 36.5 MB |
| `03-contenedor-logs.png` | `docker logs ntfy` con el servidor escuchando |
| `04-usuarios.png` | `docker exec ntfy ntfy user list` |
| `05-firewall.png` | Regla `ntfy` TCP 8080 |
| `06-curl.png` | Publicación con `curl` y su respuesta |
| `07-notificacion-telefono.jpg` | Notificación recibida en el teléfono |
| `08-acceso-anonimo-denegado.png` | Intento sin usuario rechazado (403) |

Antes de subir, revisar que ninguna captura muestre contraseñas.
