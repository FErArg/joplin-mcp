# INSTALL.md - Guía de Instalación de Joplin MCP

Esta guía cubre todos los aspectos de instalación, configuración y desinstalación del Joplin MCP Server.

## Tabla de Contenidos

- [Requisitos Previos](#requisitos-previos)
- [Instalación Automática (Recomendada)](#instalación-automática-recomendada)
- [Instalación Manual](#instalación-manual)
- [Configuración](#configuración)
  - [OpenCode](#opencode)
  - [Claude Desktop](#claude-desktop)
- [Gestión de la Instalación](#gestión-de-la-instalación)
- [Desinstalación](#desinstalación)
- [Solución de Problemas](#solución-de-problemas)
- [Recuperación de Backup](#recuperación-de-backup)

---

## Requisitos Previos

Antes de instalar, asegúrate de tener:

- **Python 3.9 o superior**
  ```bash
  python3 --version  # Debe mostrar 3.9.x o superior
  ```

- **Joplin Desktop** ejecutándose con Web Clipper habilitado:
  1. Abre Joplin
  2. Ve a **Options > Web Clipper**
  3. Habilita **"Enable Web Clipper"**
  4. Opcionalmente, copia el token (el instalador puede detectarlo automáticamente)

- **Dependencias del sistema** (normalmente ya instaladas):
  - `curl` - para validar la conexión con Joplin
  - `git` - para clonar el repositorio

---

## Instalación Automática (Recomendada)

La forma más fácil y rápida de instalar es usando el instalador automático:

```bash
# 1. Clonar el repositorio
git clone https://github.com/ferarg/joplin-mcp.git
cd joplin-mcp

# 2. Ejecutar el instalador
./install.sh
```

### ¿Qué hace el instalador?

El instalador `install.sh` automatiza todo el proceso:

1. **Verificación del sistema**
   - Detecta tu sistema operativo (Linux, macOS, Windows WSL)
   - Verifica que tengas Python 3.9+ instalado
   - Comprueba dependencias (pip, curl)

2. **Detección del token de Joplin**
   - Busca automáticamente tu token en `~/.config/joplin-desktop/settings.json`
   - Si no lo encuentra, te lo pide interactivamente
   - Valida que el token funcione antes de continuar

3. **Instalación del entorno**
   - Crea el directorio `~/.joplin-mcp/`
   - Crea un entorno virtual Python
   - Instala todas las dependencias desde `requirements.txt`
   - Genera el script `run_mcp.sh` con tu token

4. **Configuración de OpenCode**
   - Realiza **backup automático** de `~/.config/opencode/opencode.json`
   - Añade la configuración del MCP de Joplin
   - Preserva tu configuración existente

5. **Validación**
   - Prueba que el servidor MCP responde
   - Verifica que las herramientas están disponibles
   - Muestra resumen de la instalación

---

## Instalación Manual

Si prefieres instalar manualmente o necesitas más control sobre el proceso:

### Paso 1: Preparar el entorno

```bash
# Crear directorio de instalación
mkdir -p ~/.joplin-mcp
cd ~/.joplin-mcp

# Copiar archivos necesarios desde el repositorio clonado
cp /ruta/al/repo/joplin-mcp/server.py .
cp /ruta/al/repo/joplin-mcp/requirements.txt .
```

### Paso 2: Crear entorno virtual Python

```bash
# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Verificar instalación
pip list | grep -E "mcp|httpx"
```

### Paso 3: Configurar el token de Joplin

Necesitas obtener tu token de Joplin Web Clipper:

1. Abre **Joplin Desktop**
2. Ve a **Options > Web Clipper**
3. Habilita **"Enable Web Clipper"**
4. Copia el valor de **"API Token"**

### Paso 4: Crear el script wrapper

Crea el archivo `run_mcp.sh` con tu token:

```bash
cat > ~/.joplin-mcp/run_mcp.sh << 'EOF'
#!/bin/bash
export JOPLIN_TOKEN="PEGA_TU_TOKEN_AQUI"
export JOPLIN_PORT="41184"
exec ~/.joplin-mcp/venv/bin/python ~/.joplin-mcp/server.py
EOF

# Hacer ejecutable
chmod +x ~/.joplin-mcp/run_mcp.sh
```

⚠️ **Importante**: Reemplaza `PEGA_TU_TOKEN_AQUI` con tu token real de Joplin.

### Paso 5: Configurar OpenCode manualmente

Edita el archivo `~/.config/opencode/opencode.json`:

```bash
# Crear el directorio si no existe
mkdir -p ~/.config/opencode

# Añadir configuración (si el archivo ya existe, añade solo la sección mcp.joplin)
cat >> ~/.config/opencode/opencode.json << 'EOF'
{
  "mcp": {
    "joplin": {
      "type": "local",
      "command": ["/home/TU_USUARIO/.joplin-mcp/run_mcp.sh"],
      "enabled": true
    }
  }
}
EOF
```

**Nota**: Reemplaza `/home/TU_USUARIO/` con tu ruta real (usa `echo $HOME` para verificar).

### Paso 6: Verificar la instalación

```bash
# Probar el servidor MCP
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ~/.joplin-mcp/run_mcp.sh

# Si ves una respuesta JSON, ¡todo está funcionando!
```

---

## Configuración

### OpenCode

El instalador configura automáticamente `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "joplin": {
      "type": "local",
      "command": ["/home/TU_USUARIO/.joplin-mcp/run_mcp.sh"],
      "enabled": true
    }
  }
}
```

Si necesitas configurarlo manualmente:

```bash
# Añadir a ~/.config/opencode/opencode.json
{
  "mcp": {
    "joplin": {
      "type": "local",
      "command": ["~/.joplin-mcp/run_mcp.sh"],
      "enabled": true
    }
  }
}
```

### Claude Desktop

Añade a tu configuración (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "joplin_mcp": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "mcp[cli]",
        "--with",
        "httpx",
        "/home/TU_USUARIO/.joplin-mcp/server.py"
      ],
      "env": {
        "JOPLIN_TOKEN": "TU_TOKEN_AQUI",
        "JOPLIN_PORT": "41184"
      }
    }
  }
}
```

---

## Gestión de la Instalación

### Comandos útiles

```bash
# Diagnóstico y verificación
~/.joplin-mcp/joplin-mcp-doctor.sh

# Desinstalar completamente
~/.joplin-mcp/uninstall.sh

# Reinstalar o actualizar
cd /ruta/al/repo/joplin-mcp
./install.sh
```

### Estructura de la instalación

```
~/.joplin-mcp/
├── server.py              # Servidor MCP
├── requirements.txt       # Dependencias
├── run_mcp.sh            # Script wrapper (con tu token)
├── venv/                 # Entorno virtual Python
├── logs/                 # Logs de instalación y operación
│   └── install.log
├── backup/               # Backups automáticos
│   └── 20250121_143022/
│       ├── opencode.json.backup
│       └── joplin-settings.json.backup
├── joplin-mcp-doctor.sh  # Script de diagnóstico
├── uninstall.sh          # Desinstalador
└── VERSION               # Versión instalada
```

---

## Desinstalación

Para desinstalar completamente el Joplin MCP:

### Método 1: Usar el desinstalador (Recomendado)

```bash
# Ejecutar el desinstalador
~/.joplin-mcp/uninstall.sh
```

Este script:
1. Crea un backup de tu instalación actual
2. Elimina la entrada del MCP de `~/.config/opencode/opencode.json`
3. Elimina el directorio `~/.joplin-mcp/`
4. Muestra la ubicación del backup

### Método 2: Desinstalación manual

```bash
# 1. Eliminar configuración de OpenCode
# Edita ~/.config/opencode/opencode.json y elimina la sección mcp.joplin

# 2. Eliminar directorio de instalación
rm -rf ~/.joplin-mcp

# 3. Verificar que no quedan procesos activos
pkill -f "joplin-mcp" 2>/dev/null || true
```

### Limpieza completa (incluyendo backups)

```bash
# Eliminar instalación y todos los backups
rm -rf ~/.joplin-mcp
rm -rf ~/.joplin-mcp-backup-*
```

---

## Solución de Problemas

### Error 403: Authentication failed

```bash
# Verificar que el token funciona
curl "http://localhost:41184/notes?token=TU_TOKEN&limit=1"

# Si falla, reinstalar con nuevo token
./install.sh
```

### Error: Joplin server not available

```bash
# Verificar que Joplin responde
~/.joplin-mcp/joplin-mcp-doctor.sh

# Asegurarse de que:
# 1. Joplin desktop está ejecutándose
# 2. Web Clipper está habilitado (Options > Web Clipper > Enable)
# 3. El puerto 41184 está disponible
```

### Error: MCP server not responding

```bash
# Verificar instalación
~/.joplin-mcp/joplin-mcp-doctor.sh

# Ver logs
cat ~/.joplin-mcp/logs/install.log

# Reinstalar si es necesario
./install.sh
```

### Error: Permiso denegado (permission denied)

```bash
# Asegurar que los scripts son ejecutables
chmod +x ~/.joplin-mcp/run_mcp.sh
chmod +x ~/.joplin-mcp/joplin-mcp-doctor.sh
chmod +x ~/.joplin-mcp/uninstall.sh
```

---

## Recuperación de Backup

Si algo sale mal, puedes restaurar el backup:

### Ver backups disponibles

```bash
# Listar todos los backups
ls -la ~/.joplin-mcp/backup/

# Ver el backup más reciente
cat ~/.joplin-mcp/LATEST_BACKUP
```

### Restaurar configuración de OpenCode

```bash
# Restaurar desde un backup específico
cp ~/.joplin-mcp/backup/20250121_143022/opencode.json.backup ~/.config/opencode/opencode.json

# O restaurar desde el backup automático del desinstalador
cp ~/.joplin-mcp-backup-*/opencode.json.backup ~/.config/opencode/opencode.json 2>/dev/null || echo "No hay backup automático"
```

### Restaurar instalación completa

```bash
# Si desinstalaste pero tienes backup
rm -rf ~/.joplin-mcp  # Si existe una instalación parcial
cp -r ~/.joplin-mcp-backup-20250121_143022 ~/.joplin-mcp

# Reconfigurar permisos
chmod +x ~/.joplin-mcp/run_mcp.sh
chmod +x ~/.joplin-mcp/*.sh
```

---

## Notas de Seguridad

- **Nunca compartas tu token de Joplin**: El token permite acceso completo a tus notas
- **Permisos de archivos**: El token se guarda en `~/.joplin-mcp/run_mcp.sh` con permisos de usuario (0o600)
- **Backups**: Los backups contienen tu token, protégelos adecuadamente
- **Repositorio**: Nunca hagas commit de archivos con tokens reales

---

## Soporte

Si encuentras problemas durante la instalación:

1. Ejecuta el diagnóstico: `~/.joplin-mcp/joplin-mcp-doctor.sh`
2. Revisa los logs: `~/.joplin-mcp/logs/install.log`
3. Abre un issue en GitHub con la salida del diagnóstico
