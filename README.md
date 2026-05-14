# Copy Fail Lab — CVE-2026-31431 (v2)

Devcontainer reproducible para experimentar con la vulnerabilidad **Copy Fail**
(CVE-2026-31431) en un kernel Linux 6.12 controlado dentro de QEMU.

Esta v2 incorpora todas las correcciones aprendidas en una sesión de debugging
exhaustiva: opciones de kernel necesarias para que arranque, configuración
correcta de BusyBox dinámico, rutas dinámicas independientes del nombre del repo,
y dependencias Ubuntu 24.04 corregidas.

---

## Inicio rápido para el estudiante

1. Abre un Codespace desde este repo.
2. Configura tu identidad git:
   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "tu@correo.com"
   ```
3. Ejecuta:
   ```bash
   make setup    # descarga kernel + arma rootfs (~5 min)
   make qemu     # arranca la VM vulnerable
   ```

Para salir de QEMU: `Ctrl+A` luego `X`.

---

## Configuración inicial del docente (una sola vez)

### 1. Subir este repo a GitHub

```bash
cd copyfail-v2
git init && git add -A && git commit -m "initial"
git branch -M main
gh repo create TU-ORG/copy-fail-lab --public --source=. --push
```

### 2. Marcarlo como Template

GitHub → tu repo → Settings → marcar `Template repository`.

### 3. Editar `.devcontainer/devcontainer.json`

Cambia el valor `KERNEL_REPO`:
```json
"KERNEL_REPO": "TU-ORG/copy-fail-lab"
```

Commit y push.

### 4. Disparar el workflow del kernel

GitHub → Actions → `Build Vulnerable Kernel` → Run workflow.
Tarda ~25 min en los servidores de GitHub (no en tu Codespace).
Al terminar crea un Release con el `bzImage_vuln` listo para descarga.

### 5. Verificar

Tu repo → Releases → debe aparecer `kernel-v6.12-vuln` con tres archivos
adjuntos. Los estudiantes ahora pueden hacer `make setup` y descarga en 2 min.

---

## Estructura del repo

```
.
├── .devcontainer/
│   ├── Dockerfile             ← Ubuntu 24.04 + deps verificadas
│   └── devcontainer.json      ← sin rutas hardcodeadas
├── .github/workflows/
│   └── build-kernel.yml       ← compila kernel y crea Release
├── scripts/
│   ├── 00_welcome.sh
│   ├── 01_fetch_kernel.sh     ← descarga del Release
│   ├── 02_build_kernel.sh     ← fallback: compila desde fuente
│   ├── 03_build_rootfs.sh     ← BusyBox dinámico + initramfs
│   └── 04_run_qemu.sh
├── Makefile
└── README.md
```

---

## Comandos disponibles

| Comando | Acción |
|---|---|
| `make setup` | Descarga kernel + arma rootfs (~5 min) |
| `make qemu` | Arranca la VM vulnerable |
| `make info` | Muestra el estado del ambiente |
| `make rootfs` | Reconstruye solo el initramfs |
| `make fetch-kernel` | Solo descarga el bzImage del Release |
| `make build-kernel` | Compila kernel desde fuente (~25 min) |
| `make clean` | Borra builds (mantiene fuentes) |
| `make clean-all` | Borra todo |

---

## Recursos del CVE

- Write-up técnico: https://xint.io/blog/copy-fail-linux-distributions
- Sitio del CVE: https://copy.fail
- PoC oficial: https://github.com/theori-io/copy-fail-CVE-2026-31431

---

## Lecciones aprendidas (referencia para futuras versiones)

Esta v2 incorpora los siguientes fixes respecto a la v1:

- `hexdump` → `bsdextrautils` en Ubuntu 24.04
- `bzip2` agregado al Dockerfile (lo necesita BusyBox)
- Eliminado el `mounts` con ruta hardcodeada en `devcontainer.json`
- Todos los scripts detectan workspace con `SCRIPT_DIR` dinámico
- Kernel: agregadas opciones críticas `BINFMT_ELF`, `BINFMT_SCRIPT`, `RD_GZIP`
- Kernel: agregada dep `CRYPTO_AEAD` antes de `CRYPTO_AUTHENCESN`
- BusyBox: reemplazado `scripts/config` (no existe) por `sed`
- BusyBox: eliminado `olddefconfig` (no existe en BusyBox)
- BusyBox: deshabilitado `CONFIG_TC` (rompe compilación con kernels nuevos)
- BusyBox: generado dinámicamente y empaquetadas las librerías compartidas necesarias
- Workflow Actions: greps de verificación con `|| echo`, tolerantes


DOCUMENTACION ARIEL
Bueno, como punto general tenemos el exploit de copy fail que que ataca una vulnerabilidad en la escalada de student hacia root, este exploit consta de un file en python que pesa 700bytes, ni siquiera un 1mb, sin embargo, este actaca específicamente, al fallo que reside en un componente del kernel de Linux llamado algif_aead, que forma parte de la API de cifrado (AF_ALG).
Primer paso.
En el primer paso que fue el mas sencillo, solo debiamos verificar nuestros permisos en el qemu que practicamente era no poder hacer nada en qemu, a veces ni un ls, a menos que se le aumenten flags.
Segundo paso.
En la opinion de la mayoria, la parte mas dificil del examen, en mi caso la pregunta fue, sera que puedo conectar mi qemu sin nada con python3 para poder correr el exploit? con las herramientas de IA que estuvieron en nuestras manos y en la oportunidad de usar, me dio la respuesta de descargar las dependencias despues del make setup y antes del make qemu, esto lo intente varias bases en mi maquina virtual que lo explique en clase, sin embargo mi ubuntu y mi version del kernel ya estaban parchadas para mi mala suerte, sin embargo lo que se realizo fue:
QEMU inicialmente no tenia todos los binarios necesarios. Se copiaron Python3 y sus dependencias para ejecutar el exploit, ademas de un su real con SUID y una shell real para evitar errores como applet not found o FileNotFoundError sobre /usr/bin/su.
•	Python3 permitio ejecutar copy_fail_exp.py dentro de QEMU.
•	/usr/bin/su real fue necesario porque el exploit intenta abrir o modificar ese binario.
•	El permiso correcto para /usr/bin/su fue -rwsr-xr-x, equivalente a chmod 4755.
•	/bin/sh real corrigio errores de BusyBox relacionados con applets inexistentes.
Hay bastantes comandos que aun logro entener al 100, sin embargo con este lab he aprendido bastantes cosas, en este segundo paso fue a poder modificar el rootfs que es uno de los scripts clave para descragar las dependencias de python3
 install -o root -g root -m 0755 "$(command -v python3)" "$ROOTFS/usr/bin/python3"
install -o root -g root -m 4755 /usr/bin/su "$ROOTFS/usr/bin/su"
rm -f "$ROOTFS/bin/su"
ln -s /usr/bin/su "$ROOTFS/bin/su"

SHREAL="$(command -v dash || readlink -f /bin/sh)"
install -o root -g root -m 0755 "$SHREAL" "$ROOTFS/bin/sh"
Debemos tener en cuenta que yo intente ponerle internet a qemu cambiando una parte del script 04 donde corre qemu, esto nos ayudaria a usar wget y poder hacerlo mucho mas facil
Tercer paso
Mitigacion temporal, es decir poder hacer que el exploit ya no se ejecute por un tiempo, para poder hacer esto se uso lo que el ing puso en el reto, que hay un comando que hay que crear o descargarse para poder hacer la mitigacion temporal
Cuarto paso
Finalmente un paso igual de dificil en mi caso, tuvimos que poner un kernel parchado, como me ocurrio en el primer paso, mi ubuntu tenia un kernel que se suponia que era un kernel donde se podiar ejecutar el exploit, pero ya se parcho, es mas fue mi culpa, ya que con sudo apt upgrade se actualiza todo lo del kernel.
Bueno para este paso se tuvo que ir a la carpeta del kernel donde tuvimos que poner patches para poder ejecutar el kernel con su debido parche.
UNA TAREA BASTANTE RETADORA SIN EMBARGO SE LOGRO, CON AYUDA DE LO APRENDIDO, INVESTIGACION Y UNA NOCHE SIN DORMIR JAJA, gracias ing tito por tanto y perdon por tan poco.