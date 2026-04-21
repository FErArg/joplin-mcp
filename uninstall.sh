#!/bin/bash
# Joplin MCP Uninstaller

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  Joplin MCP Uninstaller"
echo "========================================"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠${NC} Joplin MCP does not appear to be installed in $INSTALL_DIR"
    exit 0
fi

echo "Will be removed:"
echo "  - Directory: $INSTALL_DIR"
echo "  - Configuration at: $CONFIG_DIR/opencode.json"
echo ""

read -p "Continue? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Cancelled"
    exit 0
fi

# Backup before removal
backup_dir="$HOME/.joplin-mcp-backup-$(date +%Y%m%d_%H%M%S)"
if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "$backup_dir"
    echo -e "${GREEN}✓${NC} Backup created: $backup_dir"
fi

# Remove from opencode.json
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    echo "Updating OpenCode configuration..."
    
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
        print("✓ Joplin configuration removed from opencode.json")
    else:
        print("ℹ Joplin configuration not found")
        
except Exception as e:
    print(f"⚠ Error updating opencode.json: {e}", file=sys.stderr)
    sys.exit(1)
EOF
fi

# Remove installation directory
echo "Removing $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"

echo ""
echo "========================================"
echo -e "  ${GREEN}Uninstallation complete${NC}"
echo "========================================"
echo ""
echo "Backup saved to:"
echo "  $backup_dir"
echo ""
echo "To reinstall, run:"
echo "  ./install.sh"
echo "========================================"
