# Joplin MCP Server

[![Version](https://img.shields.io/badge/version-1.1-blue.svg)](https://github.com/ferarg/joplin-mcp/releases)
[![Python](https://img.shields.io/badge/python-3.9+-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

A Model Context Protocol (MCP) server for interacting with Joplin notes.

## Features

- **search_notes**: Search notes by keyword across all notebooks
- **read_note**: Read full note content in Markdown format
- **list_notebooks**: List all notebooks (folders) in Joplin

## Quick Install (v1.1)

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

### Requisitos previos

Antes de ejecutar el instalador, asegúrate de tener:

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

## Configuración

### OpenCode (Automática con install.sh)

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

## Available Tools

### search_notes

Search for notes by keyword.

**Input**: `{"query": "search term"}`

**Example**:
```
⚙ joplin_search_notes [query="AI"]
Result:
- Machine Learning Notes (ID: abc123)
- AI Research Paper (ID: def456)
```

### read_note

Read the full content of a specific note.

**Input**: `{"note_id": "note-id-here"}`

**Example**:
```
⚙ joplin_read_note [note_id="abc123"]
Result:
# Machine Learning Notes

This is the markdown content of the note...
```

### list_notebooks

List all notebooks/folders in Joplin.

**Example**:
```
⚙ joplin_list_notebooks
Result:
- Work (ID: folder-abc)
- Personal (ID: folder-def)
- Research (ID: folder-ghi)
```

## Troubleshooting

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

### Recuperar backup

Si algo sale mal, puedes restaurar el backup:

```bash
# Ver backups disponibles
ls -la ~/.joplin-mcp/backup/

# Restaurar configuración de opencode
cp ~/.joplin-mcp/backup/20250121_143022/opencode.json.backup ~/.config/opencode/opencode.json

# O restaurar todo
rm -rf ~/.joplin-mcp
cp -r ~/.joplin-mcp-backup-20250121_143022 ~/.joplin-mcp
```

## Development

### Project Structure

```
joplin-mcp/
├── install.sh              # Instalador principal
├── uninstall.sh            # Desinstalador
├── joplin-mcp-doctor.sh    # Script de diagnóstico
├── run_mcp.sh              # Template del wrapper
├── server.py               # Servidor MCP
├── requirements.txt        # Dependencias Python
├── mcp_config.json         # Ejemplo para Claude Desktop
├── CHANGELOG.md            # Historial de cambios
└── README.md               # Este archivo
```

### Testing

```bash
# Test manual del servidor
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ~/.joplin-mcp/run_mcp.sh

# Diagnóstico completo
~/.joplin-mcp/joplin-mcp-doctor.sh
```

## Changelog

### v1.1 (2025-04-21)
- **Nuevo**: Instalador automático (`install.sh`)
- **Nuevo**: Desinstalador (`uninstall.sh`)
- **Nuevo**: Script de diagnóstico (`joplin-mcp-doctor.sh`)
- **Nuevo**: Detección automática de token desde Joplin settings
- **Nuevo**: Validación de token durante instalación
- **Nuevo**: Tests post-instalación
- **Nuevo**: Backup automático de configuraciones
- **Nuevo**: Sistema de logs
- **Mejora**: Idempotencia en reinstalaciones
- **Mejora**: Manejo de errores y recuperación

### v1.0 (2025-04-21)
- Initial stable release
- search_notes, read_note, list_notebooks tools
- Wrapper script support for OpenCode
- Environment variable configuration
- MCP protocol implementation

## Security Notes

- **Never commit your Joplin token to git**
- El instalador guarda el token en `~/.joplin-mcp/run_mcp.sh` (solo accesible por tu usuario)
- El repositorio solo contiene placeholders (`TOKEN_JOPLIN`)
- Backups se guardan en `~/.joplin-mcp/backup/` (revisar permisos)

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please ensure:
1. No tokens or sensitive data in commits
2. Follow existing code style
3. Update README.md if adding features
4. Test with `./joplin-mcp-doctor.sh`

## Support

For issues or questions:
1. Run `~/.joplin-mcp/joplin-mcp-doctor.sh` para diagnóstico
2. Check logs: `~/.joplin-mcp/logs/install.log`
3. Open an issue on GitHub
