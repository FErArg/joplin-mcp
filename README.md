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

La forma más fácil de instalar es usar el instalador automático:

```bash
# Clonar el repositorio
git clone https://github.com/ferarg/joplin-mcp.git
cd joplin-mcp

# Ejecutar el instalador
./install.sh
```

El instalador automáticamente:
- ✅ Detecta tu token de Joplin o te lo pide
- ✅ Configura el entorno Python (venv)
- ✅ Instala todas las dependencias
- ✅ Configura OpenCode automáticamente
- ✅ Realiza backup de tu configuración
- ✅ Valida que todo funcione correctamente

### Requisitos previos

- Python 3.9 o superior
- pip (instalador de paquetes Python)
- curl (para validación de token)
- Joplin desktop con Web Clipper habilitado

## Instalación Manual

Si prefieres instalar manualmente:

```bash
# 1. Crear directorio de instalación
mkdir -p ~/.joplin-mcp
cd ~/.joplin-mcp

# 2. Copiar archivos
cp /ruta/al/repo/server.py .
cp /ruta/al/repo/requirements.txt .

# 3. Crear entorno virtual
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 4. Crear script wrapper con tu token
cat > run_mcp.sh << 'EOF'
#!/bin/bash
export JOPLIN_TOKEN="TU_TOKEN_AQUI"
export JOPLIN_PORT="41184"
exec ~/.joplin-mcp/venv/bin/python ~/.joplin-mcp/server.py
EOF
chmod +x run_mcp.sh

# 5. Configurar OpenCode manualmente (ver sección de configuración)
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
