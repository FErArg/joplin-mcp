#!/bin/bash
# Joplin MCP Uninstaller

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  Desinstalador de Joplin MCP"
echo "========================================"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠${NC} Joplin MCP no parece estar instalado en $INSTALL_DIR"
    exit 0
fi

echo "Se eliminará:"
echo "  - Directorio: $INSTALL_DIR"
echo "  - Configuración en: $CONFIG_DIR/opencode.json"
echo ""

read -p "¿Continuar? (s/n): " confirm
if [ "$confirm" != "s" ]; then
    echo "Cancelado"
    exit 0
fi

# Backup before removal
backup_dir="$HOME/.joplin-mcp-backup-$(date +%Y%m%d_%H%M%S)"
if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "$backup_dir"
    echo -e "${GREEN}✓${NC} Backup creado: $backup_dir"
fi

# Remove from opencode.json
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    echo "Actualizando configuración de OpenCode..."
    
    python3 << EOF
import json
import sys

config_file = "$CONFIG_DIR/opencode.json"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    if 'mcp' in config and 'joplin' in config['mcp']:
        del config['mcp']['joplin']
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        print("✓ Configuración de joplin eliminada de opencode.json")
    else:
        print("ℹ No se encontró configuración de joplin")
        
except Exception as e:
    print(f"⚠ Error al actualizar opencode.json: {e}", file=sys.stderr)
    sys.exit(1)
EOF
fi

# Remove installation directory
echo "Eliminando $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"

echo ""
echo "========================================"
echo -e "  ${GREEN}Desinstalación completada${NC}"
echo "========================================"
echo ""
echo "Backup guardado en:"
echo "  $backup_dir"
echo ""
echo "Para reinstalar, ejecuta:"
echo "  ./install.sh"
echo "========================================"
