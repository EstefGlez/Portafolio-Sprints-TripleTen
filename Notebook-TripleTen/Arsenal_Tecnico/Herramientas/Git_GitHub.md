---
tags: [herramienta, git, github, control-versiones, terminal]
tipo: indice-herramienta
---

# 🌿 Git & GitHub — Flujo de Trabajo Profesional

Referencia de comandos Git para control de versiones y publicación de proyectos en GitHub. Cubre desde los comandos básicos del día a día hasta los más usados en la industria.

---

## 📋 Índice

| Operación | Ir a |
|---|---|
| Configuración inicial (una sola vez) | [[#config]] |
| Flujo básico diario | [[#flujo-basico]] |
| Revisar estado y historial | [[#status-log]] |
| Ramas (branches) | [[#ramas]] |
| Deshacer cambios | [[#deshacer]] |
| Sincronización con GitHub | [[#remoto]] |
| .gitignore | [[#gitignore]] |
| Comandos más usados en la industria | [[#industria]] |

---

## ⚙️ Configuración Inicial {#config}

**Cuándo:** Solo una vez al configurar Git en una máquina nueva.

```bash
# Configurar identidad global (aparece en todos tus commits)
git config --global user.name "EstefGlez"
git config --global user.email "tu@email.com"

# Verificar configuración
git config --list

# Inicializar un repositorio local nuevo
git init

# Vincular con repositorio remoto en GitHub
git remote add origin https://github.com/EstefGlez/nombre-repo.git

# Verificar que el remoto quedó bien configurado
git remote -v
```

---

## 🔄 Flujo Básico Diario {#flujo-basico}

**Cuándo:** Cada vez que terminas un bloque de trabajo y quieres guardar el progreso.

```bash
# 1. Ver qué archivos cambiaron
git status

# 2. Agregar archivos al staging area
git add .                        # todos los archivos modificados
git add nombre_archivo.py        # un archivo específico
git add carpeta/                 # una carpeta completa

# 3. Crear el commit (la "foto" del estado actual)
git commit -m "feat: descripción clara de lo que hiciste"

# 4. Subir al repositorio remoto
git push
```

> [!TIP] Convención de mensajes de commit (estándar industria)
> ```
> feat:     nueva funcionalidad o archivo
> fix:      corrección de error
> docs:     cambios en documentación
> refactor: restructuración de código sin cambiar comportamiento
> chore:    tareas de mantenimiento (actualizar .gitignore, etc.)
> ```
> Ejemplo: `git commit -m "feat: add S9 landing page analysis notebook"`

---

## 🔍 Revisar Estado e Historial {#status-log}

**Cuándo:** Para saber en qué punto está tu repositorio o revisar el historial de cambios.

```bash
# Ver estado actual (archivos modificados, en staging, sin trackear)
git status

# Ver historial de commits
git log

# Historial compacto (una línea por commit) — más útil en el día a día
git log --oneline

# Historial con gráfico de ramas
git log --oneline --graph --all

# Ver qué cambió exactamente en un archivo
git diff nombre_archivo.py

# Ver qué hay en el staging area antes de commitear
git diff --staged
```

---

## 🌿 Ramas (Branches) {#ramas}

**Cuándo:** Para trabajar en una nueva funcionalidad sin afectar la rama principal (`main`). Estándar en trabajo colaborativo y profesional.

```bash
# Ver todas las ramas
git branch

# Crear una rama nueva
git branch nombre-rama

# Cambiar a una rama
git checkout nombre-rama

# Crear y cambiar en un solo comando (el más usado)
git checkout -b nombre-rama

# Fusionar una rama hacia main
git checkout main
git merge nombre-rama

# Eliminar una rama ya fusionada
git branch -d nombre-rama

# Renombrar la rama actual (ej. de master a main)
git branch -M main
```

> [!NOTE] Convención de nombres de ramas en la industria
> ```
> feature/nombre-funcionalidad   → nueva función
> fix/descripcion-del-bug        → corrección
> docs/actualizacion-readme      → documentación
> refactor/limpieza-codigo       → restructuración
> ```

---

## ↩️ Deshacer Cambios {#deshacer}

**Cuándo:** Cuando cometiste un error y necesitas revertir sin perder el historial.

```bash
# Sacar un archivo del staging (sin borrar los cambios)
git restore --staged nombre_archivo.py

# Descartar cambios en un archivo (vuelve al último commit)
git restore nombre_archivo.py

# Deshacer el último commit pero conservar los cambios en staging
git reset --soft HEAD~1

# Deshacer el último commit y sacar los cambios del staging
git reset HEAD~1

# ⚠️ PELIGROSO: deshacer commit y BORRAR los cambios permanentemente
git reset --hard HEAD~1

# Crear un commit nuevo que revierte uno anterior (seguro para repos compartidos)
git revert abc1234    # abc1234 = hash del commit a revertir
```

> [!WARNING] `reset --hard` es irreversible
> Borra los cambios permanentemente. En repos compartidos siempre preferir `git revert` para no reescribir el historial público.

---

## 🌐 Sincronización con GitHub {#remoto}

**Cuándo:** Para trabajar entre máquinas o colaborar con otros.

```bash
# Primera vez que subes una rama nueva al remoto
git push -u origin main
# El -u establece el tracking upstream. Después solo necesitas git push

# Subir cambios (después del primer push -u)
git push

# Bajar cambios del remoto (sin fusionar)
git fetch

# Bajar y fusionar cambios del remoto (fetch + merge)
git pull

# Clonar un repositorio existente de GitHub
git clone https://github.com/EstefGlez/Portafolio-Sprints-TripleTen.git

# Ver la URL del remoto configurado
git remote -v
```

**Contexto real:** Portafolio TripleTen — `git push -u origin main` para el primer push, luego `git push` para cada sprint nuevo.

---

## 🙈 .gitignore {#gitignore}

**Cuándo:** Para excluir archivos que no deben subirse a GitHub (entornos virtuales, checkpoints, archivos pesados, credenciales).

```bash
# Crear el archivo .gitignore en la raíz del proyecto
touch .gitignore
```

**Contenido estándar para proyectos de Data Science:**
```
# Entorno virtual
env/
venv/
.env

# Jupyter checkpoints
.ipynb_checkpoints/

# Archivos de sistema
.DS_Store
Thumbs.db

# Archivos de configuración local
*.env
secrets.py

# Datasets pesados (subir solo scripts, no datos crudos)
data/raw/
*.csv
*.xlsx
```

> [!IMPORTANT] El .gitignore debe existir antes del primer `git add .`
> Si ya subiste archivos que deberían estar ignorados, necesitas removerlos del tracking: `git rm -r --cached nombre_carpeta/`

---

## 🏭 Comandos Más Usados en la Industria {#industria}

```bash
# Ver quién modificó cada línea de un archivo (útil en equipos)
git blame nombre_archivo.py

# Guardar cambios temporalmente sin commitear (cambiar de rama rápido)
git stash
git stash pop              # recuperar los cambios guardados
git stash list             # ver todos los stashes guardados

# Buscar en qué commit se introdujo un bug (búsqueda binaria)
git bisect start
git bisect bad             # el commit actual tiene el bug
git bisect good abc1234    # este commit estaba bien

# Traer un commit específico de otra rama (sin fusionar toda la rama)
git cherry-pick abc1234

# Etiquetar una versión (releases)
git tag v1.0.0
git push origin v1.0.0

# Ver resumen compacto de cambios entre dos commits
git diff abc1234..def5678 --stat
```

---

## 📌 Contexto del Portafolio

| Repositorio | URL |
|---|---|
| Portafolio Sprints TripleTen | [github.com/EstefGlez/Portafolio-Sprints-TripleTen](https://github.com/EstefGlez/Portafolio-Sprints-TripleTen) |

**Flujo aplicado en el portafolio:**
```bash
git add .
git commit -m "feat: regularize sprint X pipeline and executive report"
git push
```

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Entorno de desarrollo:** [[Jupyter_VSCode]]
