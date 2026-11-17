# Cambios respecto al ntfy original

**Base:** `binwiederhier/ntfy`, etiqueta `v2.37.2`, sin modificar.
**Resumen:** el código Go/JavaScript de ntfy se usa tal cual. El trabajo está en cómo se **compila**, cómo se **configura** y cómo se **despliega** para el uso interno de la Oficialía.

> Si en algún momento se edita un archivo del código fuente, `scripts/comparar-con-original.ps1` genera el diff exacto contra `v2.37.2` y se agrega aquí en la sección 5.

---

## 1. Compilación

| Qué | Original (ntfy) | Lo que se hizo aquí | Por qué |
|---|---|---|---|
| Origen del binario | Descargar el `.exe`/binario ya compilado de *Releases* | Compilar todo desde el código con `Dockerfile-build` | Indicación del doctor: debe salir del código fuente, no de un binario de terceros |
| Versión | La rama `main` cambia constantemente | Fijada en `v2.37.2` (`git checkout v2.37.2`) | Que el resultado sea reproducible |
| Clonado en Windows | `git clone` normal | `git clone --config core.autocrlf=false` | Git en Windows convierte saltos de línea a CRLF y eso rompe el `Makefile` dentro del contenedor Linux |
| Nombre de imagen | `binwiederhier/ntfy` | `ntfy-oficialia:2.37.2` | Distinguir la imagen propia de la oficial |

Resultado: build de 46 pasos en ~254 s, imagen de 36.5 MB.
Etapa 1 (golang + Node + Python) compila documentación, interfaz web y servidor con `make cli-linux-server`; etapa 2 copia solo el binario a una imagen Alpine.

## 2. Configuración — `etc/server.yml`

ntfy sin configuración es **público**: cualquiera en la red puede publicar y leer cualquier tema. Se cambió:

| Opción | Valor por defecto | Valor aquí | Efecto |
|---|---|---|---|
| `base-url` | vacío | `http://<IP-de-la-PC>:8080` | Enlaces y adjuntos apuntan a la dirección correcta en la red local |
| `listen-http` | `:80` | `:80` (dentro del contenedor) | Se publica hacia fuera en el 8080 desde el compose |
| `cache-file` | sin caché (mensajes solo en memoria) | `/var/cache/ntfy/cache.db` | Los mensajes sobreviven a reinicios y el teléfono recibe lo que se perdió mientras estaba desconectado |
| `auth-file` | sin autenticación | `/var/cache/ntfy/user.db` | Activa usuarios y contraseñas |
| `auth-default-access` | `read-write` | `deny-all` | Un usuario anónimo **no** puede leer ni publicar nada |

## 3. Despliegue — `docker-compose.yml`

| Elemento | Valor | Por qué |
|---|---|---|
| Puertos | `8080:80` | El 80 de Windows suele estar ocupado; se usa 8080 |
| Volumen `./etc` → `/etc/ntfy` | config editable desde Windows | Cambiar la configuración sin recompilar |
| Volumen `./cache` → `/var/cache/ntfy` | base de mensajes y usuarios | No se pierden datos al recrear el contenedor |
| `TZ=America/Mexico_City` | zona horaria | Las horas de los mensajes y logs coinciden con la hora local |
| `restart: unless-stopped` | reinicio automático | El servidor vuelve a levantarse solo al iniciar Docker |

Fuera del compose:
- Regla de firewall de Windows `ntfy` — entrada TCP 8080, para que el teléfono llegue a la PC.

## 4. Usuarios y permisos

| Usuario | Rol | Permisos |
|---|---|---|
| `alex` | admin | lectura y escritura en todos los temas |
| `lector` | user | solo lectura del tema `pruebas` |
| `*` (anónimo) | — | sin acceso |

Las contraseñas no están en el repositorio; se guardan cifradas (bcrypt) en `user.db`, que está excluido por `.gitignore`.

## 5. Cambios al código fuente

Ninguno hasta la fecha. La versión compilada es idéntica a `v2.37.2`.

Para ubicar el código por si se requiere modificarlo:
- `main.go` — solo arranca la línea de comandos (`cmd.New()`).
- `cmd/serve.go` — arma la configuración (`server.NewConfig()`) y llama a `server.New(conf)` y `s.Run()`.
- `server/server.go` — núcleo del servidor: listeners HTTP y rutas.

## 6. Herramientas agregadas

| Script | Para qué |
|---|---|
| `scripts/compilar.ps1` | Clonar en la versión fijada y construir la imagen en un solo paso |
| `scripts/actualizar-ip.ps1` | La IP de la PC cambia según la red (se usaron 172.17.61.73 y 192.168.7.187); detecta la nueva, la escribe en `server.yml` y reinicia el contenedor |
| `scripts/comparar-con-original.ps1` | Demostrar que el código no se alteró, o mostrar exactamente qué se alteró |
