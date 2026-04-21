#!/bin/bash
# Joplin MCP Doctor - Script de diagnóstico

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"
JOPLIN_CONFIG_DIR="$HOME/.config/joplin-desktop"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo "  Joplin MCP Doctor v1.2"
echo "========================================"
echo ""

# Check if installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗${NC} Joplin MCP no está instalado en $INSTALL_DIR"
    echo ""
    echo "Ejecuta el instalador primero:"
    echo "  ./install.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} Instalación encontrada: $INSTALL_DIR"
echo ""

# Get version if available
if [ -f "$INSTALL_DIR/VERSION" ]; then
    echo "Versión instalada: $(cat $INSTALL_DIR/VERSION)"
    echo ""
fi

# Check core files
echo -e "${BLUE}Verificando archivos:${NC}"
[ -f "$INSTALL_DIR/server.py" ] && echo -e "  ${GREEN}✓${NC} server.py" || echo -e "  ${RED}✗${NC} server.py no encontrado"
[ -f "$INSTALL_DIR/run_mcp.sh" ] && echo -e "  ${GREEN}✓${NC} run_mcp.sh" || echo -e "  ${RED}✗${NC} run_mcp.sh no encontrado"
[ -f "$INSTALL_DIR/requirements.txt" ] && echo -e "  ${GREEN}✓${NC} requirements.txt" || echo -e "  ${RED}✗${NC} requirements.txt no encontrado"
[ -f "$INSTALL_DIR/venv/bin/python" ] && echo -e "  ${GREEN}✓${NC} Entorno virtual" || echo -e "  ${RED}✗${NC} Entorno virtual no encontrado"

# Check token
echo ""
echo -e "${BLUE}Verificando token:${NC}"
if [ -f "$INSTALL_DIR/run_mcp.sh" ]; then
    # Source the script to get variables
    JOPLIN_TOKEN=$(grep "export JOPLIN_TOKEN" "$INSTALL_DIR/run_mcp.sh" | cut -d'"' -f2)
    JOPLIN_PORT=$(grep "export JOPLIN_PORT" "$INSTALL_DIR/run_mcp.sh" | cut -d'"' -f2)
    
    if [ -n "$JOPLIN_TOKEN" ] && [ "$JOPLIN_TOKEN" != "TOKEN_JOPLIN" ]; then
        echo -e "  ${GREEN}✓${NC} Token configurado (${#JOPLIN_TOKEN} caracteres)"
        echo -e "  ${GREEN}✓${NC} Puerto configurado: ${JOPLIN_PORT:-41184}"
    else
        echo -e "  ${RED}✗${NC} Token no configurado o es placeholder"
        echo "     Ejecuta ./install.sh para configurar"
    fi
fi

# Check Joplin
echo ""
echo -e "${BLUE}Verificando Joplin:${NC}"
port="${JOPLIN_PORT:-41184}"

# Check if Joplin process is running
if pgrep -f "joplin" > /dev/null 2>&1 || pgrep -f "Joplin" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Proceso de Joplin detectado"
else
    echo -e "  ${YELLOW}⚠${NC} No se detectó proceso de Joplin"
fi

# Check if port is listening
if command -v lsof &> /dev/null; then
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Puerto $port está escuchando"
    else
        echo -e "  ${YELLOW}⚠${NC} Puerto $port no está escuchando"
    fi
elif command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep -q ":$port"; then
        echo -e "  ${GREEN}✓${NC} Puerto $port está escuchando"
    else
        echo -e "  ${YELLOW}⚠${NC} Puerto $port no está escuchando"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} No se puede verificar puerto (instala lsof o netstat)"
fi

# Test connection to Joplin
echo ""
echo -e "${BLUE}Probando conexión a Joplin:${NC}"
if curl -s "http://localhost:$port/ping" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Joplin responde en puerto $port"
else
    echo -e "  ${YELLOW}⚠${NC} Joplin no responde en puerto $port"
    echo "     Asegúrate de que:"
    echo "     1. Joplin está ejecutándose"
    echo "     2. Web Clipper está habilitado (Options > Web Clipper)"
fi

# Test token validity
if [ -n "$JOPLIN_TOKEN" ] && [ "$JOPLIN_TOKEN" != "TOKEN_JOPLIN" ]; then
    echo ""
    echo -e "${BLUE}Validando token:${NC}"
    if curl -s "http://localhost:$port/notes?token=$JOPLIN_TOKEN&limit=1" 2>/dev/null | grep -q '"items"'; then
        echo -e "  ${GREEN}✓${NC} Token válido - Conexión exitosa"
    else
        echo -e "  ${RED}✗${NC} Token inválido o rechazado"
        echo "     Posibles causas:"
        echo "     - El token ha cambiado"
        echo "     - Web Clipper no está habilitado"
        echo "     - Ejecuta ./install.sh para reconfigurar"
    fi
fi

# Test MCP server
echo ""
echo -e "${BLUE}Probando servidor MCP:${NC}"
if [ -f "$INSTALL_DIR/run_mcp.sh" ]; then
    response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
    
    if [ -n "$response" ] && echo "$response" | grep -q '"jsonrpc"'; then
        echo -e "  ${GREEN}✓${NC} Servidor MCP responde"
        
        # Test tools/list
        tools_response=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
        if echo "$tools_response" | grep -q '"tools"'; then
            tool_count=$(echo "$tools_response" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('result',{}).get('tools',[])))" 2>/dev/null || echo "?")
            echo -e "  ${GREEN}✓${NC} Herramientas disponibles: $tool_count"
        fi
    else
        echo -e "  ${RED}✗${NC} Servidor MCP no responde correctamente"
        echo "     Revisa el log: $INSTALL_DIR/logs/install.log"
    fi
else
    echo -e "  ${RED}✗${NC} No se encontró run_mcp.sh"
fi

# Check OpenCode config
echo ""
echo -e "${BLUE}Verificando configuración de OpenCode:${NC}"
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    if grep -q '"joplin"' "$CONFIG_DIR/opencode.json"; then
        echo -e "  ${GREEN}✓${NC} Configuración de joplin encontrada en opencode.json"
    else
        echo -e "  ${YELLOW}⚠${NC} No se encontró configuración de joplin"
        echo "     Ejecuta ./install.sh para configurar"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} No se encontró opencode.json"
    echo "     Configuración típica en: $CONFIG_DIR/opencode.json"
fi

# Show backup info
echo ""
echo -e "${BLUE}Backups disponibles:${NC}"
latest_backup=$(cat "$INSTALL_DIR/LATEST_BACKUP" 2>/dev/null || echo "")
if [ -n "$latest_backup" ] && [ -d "$latest_backup" ]; then
    echo -e "  ${GREEN}✓${NC} Último backup: $latest_backup"
else
    echo "  ℹ No hay información de backups recientes"
fi

echo ""
echo "========================================"
echo -e "  ${GREEN}Diagnóstico completado${NC}"
echo "========================================"
echo ""
echo "Si encuentras problemas:"
echo "  1. Revisa el log: $INSTALL_DIR/logs/install.log"
echo "  2. Reinstala: ./install.sh"
echo "  3. Desinstala y vuelve a instalar: ./uninstall.sh && ./install.sh"
echo ""
echo "========================================"
