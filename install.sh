#!/bin/bash
# Joplin MCP Installer v1.2
# Instalador completo con validación, backup y tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"
JOPLIN_CONFIG_DIR="$HOME/.config/joplin-desktop"
LOG_FILE="$INSTALL_DIR/logs/install.log"
BACKUP_DIR="$INSTALL_DIR/backup/$(date +%Y%m%d_%H%M%S)"
VERSION="1.2"

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"
}

# ============================================================
# PHASE 1: PRE-CHECKS
# ============================================================

detect_os() {
    log "Detectando sistema operativo..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    
    success "Sistema operativo detectado: $OS"
}

check_system_deps() {
    log "Verificando dependencias del sistema..."
    
    local deps_ok=true
    
    # Check Python 3
    if ! command -v python3 &> /dev/null; then
        error "Python 3 no está instalado"
        deps_ok=false
    else
        PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+')
        success "Python 3 encontrado: $PYTHON_VERSION"
        
        # Check version >= 3.9
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)"; then
            success "Versión de Python compatible (>= 3.9)"
        else
            warning "Python < 3.9 detectado. Puede haber problemas de compatibilidad."
        fi
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        error "pip no está instalado"
        deps_ok=false
    else
        success "pip encontrado"
    fi
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        warning "curl no está instalado (necesario para validación)"
        deps_ok=false
    else
        success "curl encontrado"
    fi
    
    if [ "$deps_ok" = false ]; then
        error "Faltan dependencias críticas. Por favor instálalas e intenta de nuevo."
        exit 1
    fi
}

check_joplin_installed() {
    log "Verificando instalación de Joplin..."
    
    local joplin_found=false
    local settings_path=""
    
    # Check common locations
    if [ -d "$JOPLIN_CONFIG_DIR" ]; then
        joplin_found=true
        settings_path="$JOPLIN_CONFIG_DIR/settings.json"
    elif [ -d "$HOME/.var/app/net.cozic.joplin_desktop" ]; then
        # Flatpak
        joplin_found=true
        settings_path="$HOME/.var/app/net.cozic.joplin_desktop/config/joplin-desktop/settings.json"
    elif [ -d "$HOME/Library/Application Support/Joplin" ]; then
        # macOS
        joplin_found=true
        settings_path="$HOME/Library/Application Support/Joplin/settings.json"
    fi
    
    if [ "$joplin_found" = true ]; then
        success "Joplin encontrado"
        
        # Check if Web Clipper might be enabled (check if port is in use)
        if command -v lsof &> /dev/null; then
            if lsof -Pi :41184 -sTCP:LISTEN -t >/dev/null 2>&1 || \
               netstat -tuln 2>/dev/null | grep -q ':41184'; then
                success "Web Clipper parece estar habilitado (puerto 41184)"
            else
                warning "Web Clipper no detectado en puerto 41184"
                warning "Asegúrate de habilitarlo en Joplin: Options > Web Clipper > Enable Web Clipper"
            fi
        fi
    else
        warning "No se encontró Joplin en las ubicaciones estándar"
        warning "Asegúrate de tener Joplin instalado y configurado"
    fi
}

check_existing_installation() {
    log "Verificando instalación previa..."
    
    echo ""
    echo "Selecciona una opción:"
    
    if [ -d "$INSTALL_DIR" ]; then
        warning "Instalación previa detectada en $INSTALL_DIR"
        echo "1) Reinstalar (eliminar todo y volver a instalar)"
        echo "2) Actualizar (preservar configuración)"
        echo "3) Cancelar"
        echo ""
        read -p "Opción [1-3]: " choice
        
        case $choice in
            1)
                log "Realizando reinstalación completa..."
                backup_existing
                rm -rf "$INSTALL_DIR"
                ;;
            2)
                log "Actualizando instalación existente..."
                UPDATE_MODE=true
                ;;
            3)
                log "Instalación cancelada por el usuario"
                exit 0
                ;;
            *)
                error "Opción inválida"
                exit 1
                ;;
        esac
    else
        echo "1) Instalar"
        echo "2) Cancelar"
        echo ""
        read -p "Opción [1-2]: " choice
        
        case $choice in
            1)
                log "Procediendo con la instalación..."
                ;;
            2)
                log "Instalación cancelada por el usuario"
                exit 0
                ;;
            *)
                error "Opción inválida"
                exit 1
                ;;
        esac
    fi
}

backup_existing() {
    log "Creando backup de instalación existente..."
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$INSTALL_DIR" ]; then
        # Excluir directorio backup para evitar copia recursiva infinita
        if command -v rsync &>/dev/null; then
            rsync -a --exclude="backup" "$INSTALL_DIR/" "$BACKUP_DIR/"
        else
            # Usar find y cp como alternativa sin rsync
            find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name "backup" -exec cp -r {} "$BACKUP_DIR/" \;
        fi
        success "Backup de instalación guardado en: $BACKUP_DIR"
    fi
}

# ============================================================
# PHASE 2: BACKUP CONFIGURATION
# ============================================================

backup_config() {
    log "Creando backup de configuraciones..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup opencode.json
    if [ -f "$CONFIG_DIR/opencode.json" ]; then
        cp "$CONFIG_DIR/opencode.json" "$BACKUP_DIR/opencode.json.backup"
        success "Backup de opencode.json creado"
    fi
    
    # Backup Joplin settings (for reference)
    if [ -f "$JOPLIN_CONFIG_DIR/settings.json" ]; then
        cp "$JOPLIN_CONFIG_DIR/settings.json" "$BACKUP_DIR/joplin-settings.json.backup"
        success "Backup de settings de Joplin creado"
    fi
    
    # Save backup reference
    echo "$BACKUP_DIR" > "$INSTALL_DIR/LATEST_BACKUP" 2>/dev/null || true
    
    success "Backup guardado en: $BACKUP_DIR"
}

# ============================================================
# PHASE 3: TOKEN DETECTION & VALIDATION
# ============================================================

search_joplin_token() {
    log "Buscando token de Joplin..."
    
    local settings_files=(
        "$JOPLIN_CONFIG_DIR/settings.json"
        "$HOME/.var/app/net.cozic.joplin_desktop/config/joplin-desktop/settings.json"
        "$HOME/Library/Application Support/Joplin/settings.json"
    )
    
    for settings_file in "${settings_files[@]}"; do
        if [ -f "$settings_file" ]; then
            log "Analizando: $settings_file"
            
            # Try to extract token using Python
            TOKEN=$(python3 -c "
import json
import sys
try:
    with open('$settings_file', 'r') as f:
        data = json.load(f)
        token = data.get('api.token', '')
        if token:
            print(token)
            sys.exit(0)
except Exception as e:
    sys.exit(1)
" 2>/dev/null)
            
            if [ -n "$TOKEN" ]; then
                success "Token encontrado en settings.json"
                return 0
            fi
        fi
    done
    
    return 1
}

validate_token() {
    local token=$1
    local port=${JOPLIN_PORT:-41184}
    
    log "Validando token con Joplin..."
    
    # Test connection to Joplin
    local response
    response=$(curl -s "http://localhost:$port/notes?token=$token&limit=1" 2>/dev/null || echo "")
    
    if echo "$response" | grep -q '"items"'; then
        success "Token válido - Conexión exitosa con Joplin"
        return 0
    else
        error "Token inválido o Joplin no responde"
        return 1
    fi
}

prompt_for_token() {
    log "Solicitando token al usuario..."
    
    echo ""
    echo "========================================"
    echo "  CONFIGURACIÓN DE TOKEN"
    echo "========================================"
    echo ""
    echo "No se encontró token automáticamente."
    echo ""
    echo "Para obtener tu token:"
    echo "  1. Abre Joplin"
    echo "  2. Ve a Options > Web Clipper"
    echo "  3. Habilita 'Enable Web Clipper' si no está habilitado"
    echo "  4. Copia el token de 'API Token'"
    echo ""
    
    while true; do
        read -s -p "Ingresa tu token de Joplin: " TOKEN
        echo ""
        
        if [ ${#TOKEN} -lt 10 ]; then
            error "Token muy corto. Debe tener al menos 10 caracteres."
            continue
        fi
        
        # Validate token
        if validate_token "$TOKEN"; then
            break
        else
            echo ""
            warning "No se pudo validar el token. Posibles causas:"
            warning "  - Joplin no está ejecutándose"
            warning "  - Web Clipper no está habilitado"
            warning "  - El puerto es diferente a 41184"
            echo ""
            read -p "¿Deseas continuar de todos modos? (s/n): " continue_anyway
            if [ "$continue_anyway" = "s" ]; then
                break
            fi
        fi
    done
}

get_token() {
    if ! search_joplin_token; then
        prompt_for_token
    fi
    
    # Confirm token with user
    echo ""
    echo "Token configurado: ${TOKEN:0:10}... (${#TOKEN} caracteres)"
    read -p "¿Es correcto? (s/n): " confirm
    if [ "$confirm" != "s" ]; then
        prompt_for_token
    fi
}

# ============================================================
# PHASE 4: INSTALLATION
# ============================================================

install_files() {
    log "Instalando archivos..."
    
    # Create directory structure
    mkdir -p "$INSTALL_DIR"/{bin,logs,backup}
    
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Copy main files
    if [ -f "$SCRIPT_DIR/server.py" ]; then
        cp "$SCRIPT_DIR/server.py" "$INSTALL_DIR/"
        success "server.py instalado"
    else
        error "server.py no encontrado en el directorio del script"
        exit 1
    fi
    
    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/"
        success "requirements.txt instalado"
    else
        error "requirements.txt no encontrado"
        exit 1
    fi
    
    # Create version file
    echo "$VERSION" > "$INSTALL_DIR/VERSION"
    
    success "Archivos instalados en: $INSTALL_DIR"
}

generate_wrapper_script() {
    log "Generando script wrapper..."
    
    cat > "$INSTALL_DIR/run_mcp.sh" << EOF
#!/bin/bash
# Auto-generated by Joplin MCP Installer v$VERSION
# DO NOT EDIT MANUALLY - Use install.sh to reconfigure
# Generated: $(date)

export JOPLIN_TOKEN="$TOKEN"
export JOPLIN_PORT="${JOPLIN_PORT:-41184}"

exec $INSTALL_DIR/venv/bin/python $INSTALL_DIR/server.py
EOF
    
    chmod +x "$INSTALL_DIR/run_mcp.sh"
    success "Script wrapper creado: $INSTALL_DIR/run_mcp.sh"
}

install_python_deps() {
    log "Instalando dependencias Python..."
    
    # Create virtual environment
    if [ ! -d "$INSTALL_DIR/venv" ]; then
        python3 -m venv "$INSTALL_DIR/venv"
        success "Entorno virtual creado"
    fi
    
    # Activate and install
    source "$INSTALL_DIR/venv/bin/activate"
    
    log "Actualizando pip..."
    pip install --upgrade pip >> "$LOG_FILE" 2>&1
    
    log "Instalando dependencias..."
    pip install -r "$INSTALL_DIR/requirements.txt" >> "$LOG_FILE" 2>&1
    
    success "Dependencias instaladas"
}

# ============================================================
# PHASE 5: CONFIGURE OPCODE
# ============================================================

configure_opencode() {
    log "Configurando OpenCode..."
    
    local config_file="$CONFIG_DIR/opencode.json"
    
    # Create config directory if needed
    mkdir -p "$CONFIG_DIR"
    
    # Create or update config using Python for safe JSON manipulation
    python3 << EOF
import json
import os

config_file = "$config_file"
install_dir = "$INSTALL_DIR"

# Load existing config or create new
if os.path.exists(config_file):
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
    except json.JSONDecodeError:
        print(f"Warning: {config_file} tiene formato inválido, creando nuevo")
        config = {}
else:
    config = {}

# Ensure mcp section exists
if 'mcp' not in config:
    config['mcp'] = {}

# Add/update joplin configuration
config['mcp']['joplin'] = {
    'type': 'local',
    'command': [f'{install_dir}/run_mcp.sh'],
    'enabled': True
}

# Write config back
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"Configuración actualizada: {config_file}")
EOF
    
    if [ $? -eq 0 ]; then
        success "OpenCode configurado correctamente"
    else
        error "Error al configurar OpenCode"
        return 1
    fi
}

# ============================================================
# PHASE 6: POST-INSTALLATION TESTS
# ============================================================

test_mcp_server() {
    log "Probando servidor MCP..."
    
    local response
    response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
    
    if echo "$response" | grep -q '"jsonrpc"'; then
        success "Servidor MCP responde correctamente"
        return 0
    else
        error "El servidor MCP no responde correctamente"
        return 1
    fi
}

test_mcp_tools() {
    log "Probando herramientas MCP..."
    
    local response
    response=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
    
    if echo "$response" | grep -q '"tools"'; then
        success "Herramientas MCP disponibles"
        
        # Count tools
        local tool_count
        tool_count=$(echo "$response" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('result',{}).get('tools',[])))" 2>/dev/null || echo "?")
        success "Número de herramientas: $tool_count"
        
        return 0
    else
        error "No se pudieron cargar las herramientas MCP"
        return 1
    fi
}

# ============================================================
# PHASE 7: CREATE HELPER SCRIPTS
# ============================================================

create_helper_scripts() {
    log "Creando scripts auxiliares..."
    
    # Create doctor script
    cat > "$INSTALL_DIR/joplin-mcp-doctor.sh" << 'EOF'
#!/bin/bash
# Joplin MCP Doctor - Script de diagnóstico

INSTALL_DIR="$HOME/.joplin-mcp"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  Joplin MCP Doctor"
echo "========================================"
echo ""

# Check installation
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗${NC} Joplin MCP no está instalado en $INSTALL_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} Instalación encontrada: $INSTALL_DIR"

# Check files
[ -f "$INSTALL_DIR/server.py" ] && echo -e "${GREEN}✓${NC} server.py existe" || echo -e "${RED}✗${NC} server.py no encontrado"
[ -f "$INSTALL_DIR/run_mcp.sh" ] && echo -e "${GREEN}✓${NC} run_mcp.sh existe" || echo -e "${RED}✗${NC} run_mcp.sh no encontrado"
[ -f "$INSTALL_DIR/venv/bin/python" ] && echo -e "${GREEN}✓${NC} Entorno virtual existe" || echo -e "${RED}✗${NC} Entorno virtual no encontrado"

# Check token
if [ -f "$INSTALL_DIR/run_mcp.sh" ]; then
    source "$INSTALL_DIR/run_mcp.sh" 2>/dev/null
    if [ -n "$JOPLIN_TOKEN" ]; then
        echo -e "${GREEN}✓${NC} Token configurado (${#JOPLIN_TOKEN} caracteres)"
    else
        echo -e "${RED}✗${NC} Token no configurado"
    fi
fi

# Check Joplin
port="${JOPLIN_PORT:-41184}"
if curl -s "http://localhost:$port/ping" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Joplin responde en puerto $port"
else
    echo -e "${YELLOW}⚠${NC} Joplin no responde en puerto $port (¿está ejecutándose?)"
fi

# Test token
echo ""
echo "Probando conexión con token..."
if curl -s "http://localhost:$port/notes?token=$JOPLIN_TOKEN&limit=1" 2>/dev/null | grep -q '"items"'; then
    echo -e "${GREEN}✓${NC} Token válido - Conexión exitosa"
else
    echo -e "${RED}✗${NC} Token inválido o Joplin no acepta conexiones"
fi

# Test MCP server
echo ""
echo "Probando servidor MCP..."
response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
if echo "$response" | grep -q '"jsonrpc"'; then
    echo -e "${GREEN}✓${NC} Servidor MCP responde"
else
    echo -e "${RED}✗${NC} Servidor MCP no responde"
fi

echo ""
echo "========================================"
echo "  Diagnóstico completado"
echo "========================================"
EOF
    chmod +x "$INSTALL_DIR/joplin-mcp-doctor.sh"
    success "Script doctor creado"
    
    # Create uninstall script
    cat > "$INSTALL_DIR/uninstall.sh" << 'EOF'
#!/bin/bash
# Joplin MCP Uninstaller

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"

echo "Desinstalador de Joplin MCP"
echo "=========================="
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Joplin MCP no parece estar instalado en $INSTALL_DIR"
    exit 0
fi

read -p "¿Eliminar ~/.joplin-mcp? (s/n): " confirm
if [ "$confirm" != "s" ]; then
    echo "Cancelado"
    exit 0
fi

# Backup before removal
backup_dir="$HOME/.joplin-mcp-backup-$(date +%Y%m%d_%H%M%S)"
cp -r "$INSTALL_DIR" "$backup_dir"
echo "Backup creado: $backup_dir"

# Remove from opencode.json
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    python3 << PYEOF
import json
import os

config_file = "$CONFIG_DIR/opencode.json"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    if 'mcp' in config and 'joplin' in config['mcp']:
        del config['mcp']['joplin']
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        print("Configuración de OpenCode actualizada")
except Exception as e:
    print(f"Error al actualizar opencode.json: {e}")
PYEOF
fi

# Remove installation directory
rm -rf "$INSTALL_DIR"

echo ""
echo "Desinstalación completada"
echo "Backup guardado en: $backup_dir"
EOF
    chmod +x "$INSTALL_DIR/uninstall.sh"
    success "Script de desinstalación creado"
}

# ============================================================
# PHASE 8: SUMMARY & COMPLETION
# ============================================================

show_summary() {
    echo ""
    echo "========================================"
    echo -e "  ${GREEN}Instalación Completada - v$VERSION${NC}"
    echo "========================================"
    echo ""
    echo "📁 Ubicación:     $INSTALL_DIR"
    echo "⚙️  Configuración: $CONFIG_DIR/opencode.json"
    echo "🔑 Token:         Configurado ✓"
    echo "✅ Tests:         Pasados ✓"
    echo ""
    echo "🚀 Para usar en OpenCode:"
    echo "   1. Reinicia OpenCode"
    echo "   2. Prueba: 'Lista mis libretas de Joplin'"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "   ~/.joplin-mcp/joplin-mcp-doctor.sh  # Diagnóstico"
    echo "   ~/.joplin-mcp/uninstall.sh          # Desinstalar"
    echo "   ./install.sh                        # Reinstalar/actualizar"
    echo ""
    echo "📋 Backup guardado en: $BACKUP_DIR"
    echo "📝 Log de instalación: $LOG_FILE"
    echo "========================================"
}

show_error_help() {
    echo ""
    echo "========================================"
    echo -e "  ${RED}ERROR EN INSTALACIÓN${NC}"
    echo "========================================"
    echo ""
    echo "Posibles soluciones:"
    echo ""
    echo "1. Verificar que Joplin esté ejecutándose"
    echo "2. Habilitar Web Clipper en Joplin:"
    echo "   Options > Web Clipper > Enable Web Clipper"
    echo ""
    echo "3. Verificar el log de instalación:"
    echo "   cat $LOG_FILE"
    echo ""
    echo "4. Ejecutar diagnóstico:"
    echo "   ~/.joplin-mcp/joplin-mcp-doctor.sh"
    echo ""
    echo "5. Restaurar backup:"
    echo "   cp $BACKUP_DIR/opencode.json.backup ~/.config/opencode/opencode.json"
    echo ""
    echo "6. Para reinstalar:"
    echo "   ./install.sh"
    echo ""
    echo "========================================"
}

# ============================================================
# MAIN EXECUTION
# ============================================================

main() {
    echo "========================================"
    echo "  Joplin MCP Installer v$VERSION"
    echo "========================================"
    echo ""
    
    # Initialize log
    mkdir -p "$INSTALL_DIR/logs" 2>/dev/null || true
    echo "=== Instalación iniciada: $(date) ===" > "$LOG_FILE"
    
    # Phase 1: Pre-checks
    detect_os
    check_system_deps
    check_joplin_installed
    check_existing_installation
    
    # Phase 2: Backup
    backup_config
    
    # Phase 3: Get token
    get_token
    
    # Phase 4: Install
    install_files
    generate_wrapper_script
    install_python_deps
    
    # Phase 5: Configure
    configure_opencode
    
    # Phase 6: Create helpers
    create_helper_scripts
    
    # Phase 7: Test
    echo ""
    log "Ejecutando tests post-instalación..."
    
    if test_mcp_server && test_mcp_tools; then
        show_summary
        echo "=== Instalación completada exitosamente: $(date) ===" >> "$LOG_FILE"
        exit 0
    else
        show_error_help
        echo "=== Instalación fallida: $(date) ===" >> "$LOG_FILE"
        exit 1
    fi
}

# Handle Ctrl+C
trap 'echo ""; error "Instalación cancelada"; exit 1' INT

# Run main
main "$@"
