#!/bin/bash
# Joplin MCP Installer v2.2.0
# Complete installer with validation, backup, and tests

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"
JOPLIN_CONFIG_DIR="$HOME/.config/joplin-desktop"
LOG_FILE="$INSTALL_DIR/logs/install.log"
BACKUP_DIR="$INSTALL_DIR/backup/$(date +%Y%m%d_%H%M%S)"
VERSION="2.0.0"

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

detect_os() {
    log "Detecting operating system..."

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi

    success "Operating system detected: $OS"
}

check_system_deps() {
    log "Checking system dependencies..."

    local deps_ok=true

    if ! command -v python3 &> /dev/null; then
        error "Python 3 is not installed"
        deps_ok=false
    else
        PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        success "Python 3 found: $PYTHON_VERSION"

        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)"; then
            success "Compatible Python version (>= 3.9)"
        else
            warning "Python < 3.9 detected. There may be compatibility issues."
        fi
    fi

    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        error "pip is not installed"
        deps_ok=false
    else
        success "pip found"
    fi

    if ! command -v curl &> /dev/null; then
        warning "curl is not installed (required for validation)"
        deps_ok=false
    else
        success "curl found"
    fi

    if [ "$deps_ok" = false ]; then
        error "Critical dependencies missing. Please install them and try again."
        exit 1
    fi
}

check_joplin_installed() {
    log "Checking Joplin installation..."

    local joplin_found=false
    local settings_path=""

    if [ -d "$JOPLIN_CONFIG_DIR" ]; then
        joplin_found=true
        settings_path="$JOPLIN_CONFIG_DIR/settings.json"
    elif [ -d "$HOME/.var/app/net.cozic.joplin_desktop" ]; then
        joplin_found=true
        settings_path="$HOME/.var/app/net.cozic.joplin_desktop/config/joplin-desktop/settings.json"
    elif [ -d "$HOME/Library/Application Support/Joplin" ]; then
        joplin_found=true
        settings_path="$HOME/Library/Application Support/Joplin/settings.json"
    fi

    if [ "$joplin_found" = true ]; then
        success "Joplin found"

        if command -v lsof &> /dev/null; then
            if [ "$OS" = "macos" ]; then
                if lsof -i :41184 2>/dev/null | grep -i listen >/dev/null 2>&1; then
                    success "Web Clipper appears to be enabled (port 41184)"
                else
                    warning "Web Clipper not detected on port 41184"
                    warning "Enable it in Joplin: Options > Web Clipper > Enable Web Clipper"
                fi
            else
                if lsof -Pi :41184 -sTCP:LISTEN -t >/dev/null 2>&1 || \
                   netstat -tuln 2>/dev/null | grep -q ':41184'; then
                    success "Web Clipper appears to be enabled (port 41184)"
                else
                    warning "Web Clipper not detected on port 41184"
                    warning "Enable it in Joplin: Options > Web Clipper > Enable Web Clipper"
                fi
            fi
        elif command -v netstat &> /dev/null; then
            if [ "$OS" = "macos" ]; then
                if netstat -an 2>/dev/null | grep -q "\.41184.*LISTEN"; then
                    success "Web Clipper appears to be enabled (port 41184)"
                else
                    warning "Web Clipper not detected on port 41184"
                fi
            else
                if netstat -tuln 2>/dev/null | grep -q ':41184'; then
                    success "Web Clipper appears to be enabled (port 41184)"
                else
                    warning "Web Clipper not detected on port 41184"
                fi
            fi
        fi
    else
        warning "Joplin not found in standard locations"
        warning "Ensure you have Joplin installed and configured"
    fi
}

check_existing_installation() {
    log "Checking previous installation..."

    echo ""
    echo "Select an option:"

    if [ -d "$INSTALL_DIR" ]; then
        warning "Previous installation detected in $INSTALL_DIR"
        echo "1) Reinstall (remove everything and install again)"
        echo "2) Update (preserve configuration)"
        echo "3) Cancel"
        echo ""
        read -p "Option [1-3]: " choice

        case $choice in
            1)
                log "Performing complete reinstall..."
                backup_existing
                rm -rf "$INSTALL_DIR"
                mkdir -p "$INSTALL_DIR/logs"
                ;;
            2)
                log "Updating existing installation..."
                UPDATE_MODE=true
                ;;
            3)
                log "Installation cancelled by user"
                exit 0
                ;;
            *)
                error "Invalid option"
                exit 1
                ;;
        esac
    else
        echo "1) Install"
        echo "2) Cancel"
        echo ""
        read -p "Option [1-2]: " choice

        case $choice in
            1)
                log "Proceeding with installation..."
                ;;
            2)
                log "Installation cancelled by user"
                exit 0
                ;;
            *)
                error "Invalid option"
                exit 1
                ;;
        esac
    fi
}

backup_existing() {
    log "Creating backup of existing installation..."
    mkdir -p "$BACKUP_DIR"

    if [ -d "$INSTALL_DIR" ]; then
        if command -v rsync &>/dev/null; then
            rsync -a --exclude="backup" "$INSTALL_DIR/" "$BACKUP_DIR/"
        else
            for item in "$INSTALL_DIR"/*; do
                if [ -e "$item" ] && [ "$(basename "$item")" != "backup" ]; then
                    cp -r "$item" "$BACKUP_DIR/"
                fi
            done
        fi
        success "Installation backup saved to: $BACKUP_DIR"
    fi
}

backup_config() {
    log "Creating backup of configurations..."

    mkdir -p "$BACKUP_DIR"

    if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
        cp "$CONFIG_DIR/opencode.jsonc" "$BACKUP_DIR/opencode.jsonc.backup"
        success "Backup of opencode.jsonc created"
    elif [ -f "$CONFIG_DIR/opencode.json" ]; then
        cp "$CONFIG_DIR/opencode.json" "$BACKUP_DIR/opencode.json.backup"
        success "Backup of opencode.json created"
    fi

    if [ -f "$JOPLIN_CONFIG_DIR/settings.json" ]; then
        cp "$JOPLIN_CONFIG_DIR/settings.json" "$BACKUP_DIR/joplin-settings.json.backup"
        success "Backup of Joplin settings created"
    fi

    echo "$BACKUP_DIR" > "$INSTALL_DIR/LATEST_BACKUP" 2>/dev/null || true

    success "Backup saved to: $BACKUP_DIR"
}

search_joplin_token() {
    log "Searching for Joplin token..."

    local settings_files=(
        "$JOPLIN_CONFIG_DIR/settings.json"
        "$HOME/.var/app/net.cozic.joplin_desktop/config/joplin-desktop/settings.json"
        "$HOME/Library/Application Support/Joplin/settings.json"
    )

    for settings_file in "${settings_files[@]}"; do
        if [ -f "$settings_file" ]; then
            log "Analysing: $settings_file"

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
                success "Token found in settings.json"
                return 0
            fi
        fi
    done

    return 1
}

validate_token() {
    local token=$1
    local port=${JOPLIN_PORT:-41184}

    log "Validating token with Joplin..."

    local response
    response=$(curl -s "http://localhost:$port/notes?token=$token&limit=1" 2>/dev/null || echo "")

    if echo "$response" | grep -q '"items"'; then
        success "Token valid - Successful connection with Joplin"
        return 0
    else
        error "Invalid token or Joplin not responding"
        return 1
    fi
}

check_write_permissions() {
    local token=$1
    local port=${JOPLIN_PORT:-41184}

    log "Checking write permissions..."

    local test_name="MCP_Test_$(date +%s)"
    local response
    response=$(curl -s -X POST "http://localhost:$port/folders?token=$token" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"$test_name\"}" 2>/dev/null || echo "")

    if echo "$response" | grep -q '"id"'; then
        local folder_id
        folder_id=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)

        if [ -n "$folder_id" ]; then
            curl -s -X DELETE "http://localhost:$port/folders/$folder_id?token=$token" > /dev/null 2>&1
        fi

        success "Write permissions confirmed - Full v2.0.0 functionality available"
        return 0
    else
        warning "Write permissions not available - Token may have read-only access"
        warning "v2.0.0 features (create, update, delete) will not work"
        return 1
    fi
}

prompt_for_token() {
    log "Requesting token from user..."

    echo ""
    echo "========================================"
    echo "  TOKEN CONFIGURATION"
    echo "========================================"
    echo ""
    echo "Token not found automatically."
    echo ""
    echo "To obtain your token:"
    echo "  1. Open Joplin"
    echo "  2. Go to Options > Web Clipper"
    echo "  3. Enable 'Enable Web Clipper' if not enabled"
    echo "  4. Copy the token from 'API Token'"
    echo ""

    while true; do
        read -s -p "Enter your Joplin token: " TOKEN
        echo ""

        if [ ${#TOKEN} -lt 10 ]; then
            error "Token too short. Must be at least 10 characters."
            continue
        fi

        if validate_token "$TOKEN"; then
            break
        else
            echo ""
            warning "Could not validate token. Possible causes:"
            warning "  - Joplin is not running"
            warning "  - Web Clipper is not enabled"
            warning "  - The port is different from 41184"
            echo ""
            read -p "Do you wish to continue anyway? (y/n): " continue_anyway
            if [ "$continue_anyway" = "y" ]; then
                break
            fi
        fi
    done
}

get_token() {
    if ! search_joplin_token; then
        prompt_for_token
    fi

    echo ""
    echo "Token configured: ${TOKEN:0:10}... (${#TOKEN} characters)"
    read -p "Is this correct? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        prompt_for_token
    fi

    echo ""
    check_write_permissions "$TOKEN"
}

install_files() {
    log "Installing files..."

    mkdir -p "$INSTALL_DIR"/{bin,logs,backup}

    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    if [ -f "$SCRIPT_DIR/server.py" ]; then
        cp "$SCRIPT_DIR/server.py" "$INSTALL_DIR/"
        success "server.py installed"
    else
        error "server.py not found in script directory"
        exit 1
    fi

    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/"
        success "requirements.txt installed"
    else
        error "requirements.txt not found"
        exit 1
    fi

    echo "$VERSION" > "$INSTALL_DIR/VERSION"

    if [ -d "$SCRIPT_DIR/opencode/tools" ]; then
        mkdir -p "$CONFIG_DIR/tools"
        cp "$SCRIPT_DIR/opencode/tools/"*.ts "$CONFIG_DIR/tools/" 2>/dev/null || true
        success "OpenCode tools copied to $CONFIG_DIR/tools/"
    fi

    if [ -d "$SCRIPT_DIR/opencode/commands" ]; then
        mkdir -p "$CONFIG_DIR/commands"
        cp "$SCRIPT_DIR/opencode/commands/"*.md "$CONFIG_DIR/commands/" 2>/dev/null || true
        success "OpenCode commands copied to $CONFIG_DIR/commands/"
    fi

    success "Files installed to: $INSTALL_DIR"
}

generate_wrapper_script() {
    log "Generating wrapper script..."

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
    success "Wrapper script created: $INSTALL_DIR/run_mcp.sh"
}

install_python_deps() {
    log "Installing Python dependencies..."

    if [ ! -d "$INSTALL_DIR/venv" ]; then
        python3 -m venv "$INSTALL_DIR/venv"
        success "Virtual environment created"
    fi

    source "$INSTALL_DIR/venv/bin/activate"

    log "Upgrading pip..."
    pip install --upgrade pip >> "$LOG_FILE" 2>&1

    log "Installing dependencies..."
    pip install -r "$INSTALL_DIR/requirements.txt" >> "$LOG_FILE" 2>&1

    success "Dependencies installed"
}

configure_opencode() {
    log "Configuring OpenCode..."

    local config_file="$CONFIG_DIR/opencode.json"
    if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
        config_file="$CONFIG_DIR/opencode.jsonc"
    fi

    mkdir -p "$CONFIG_DIR"

    CONFIG_FILE="$config_file" INSTALL_DIR="$INSTALL_DIR" python3 <<'EOF'
import json
import os
import re

config_file = os.environ['CONFIG_FILE']
install_dir = os.environ['INSTALL_DIR']

def strip_jsonc(text):
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == '/' and nxt == '/':
            i += 2
            while i < len(text) and text[i] not in '\r\n':
                i += 1
            continue

        if ch == '/' and nxt == '*':
            i += 2
            while i + 1 < len(text) and text[i:i + 2] != '*/':
                i += 1
            i += 2
            continue

        cleaned.append(ch)
        i += 1

    text = ''.join(cleaned)
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == ',':
            j = i + 1
            while j < len(text) and text[j].isspace():
                j += 1
            if j < len(text) and text[j] in '}]':
                i += 1
                continue

        cleaned.append(ch)
        i += 1

    return ''.join(cleaned)

config = {}
if os.path.exists(config_file):
    with open(config_file, 'r', encoding='utf-8') as f:
        raw = f.read()

    try:
        config = json.loads(raw)
    except json.JSONDecodeError:
        try:
            config = json.loads(strip_jsonc(raw))
        except json.JSONDecodeError as exc:
            raise SystemExit(f"Error: could not parse {config_file}: {exc}")

if 'mcp' not in config:
    config['mcp'] = {}

config['mcp']['joplin_mcp'] = {
    'type': 'local',
    'command': [f'{install_dir}/run_mcp.sh'],
    'enabled': True
}

with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print(f"Configuration updated: {config_file}")
EOF

    if [ $? -eq 0 ]; then
        success "OpenCode configured correctly"
    else
        error "Error configuring OpenCode"
        return 1
    fi
}

test_mcp_server() {
    log "Testing MCP server..."

    local response
    response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)

    if echo "$response" | grep -q '"jsonrpc"'; then
        success "MCP server responding correctly"
        return 0
    else
        error "MCP server not responding correctly"
        return 1
    fi
}

test_mcp_tools() {
    log "Testing MCP tools..."

    local response
    response=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)

    if echo "$response" | grep -q '"tools"'; then
        success "MCP tools available"

        local tool_count
        tool_count=$(echo "$response" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('result',{}).get('tools',[])))" 2>/dev/null || echo "?")
        success "Number of tools: $tool_count"

        if [ "$tool_count" = "15" ]; then
            success "All v2.0.0 tools present (15 tools)"
        elif [ "$tool_count" = "8" ]; then
            warning "Only v2.1 tools detected (8 tools). v2.0.0 has 15 tools."
        else
            warning "Unexpected tool count: $tool_count. Expected 15 for v2.0.0."
        fi

        return 0
    else
        error "Could not load MCP tools"
        return 1
    fi
}

create_helper_scripts() {
    log "Creating helper scripts..."

    cat > "$INSTALL_DIR/joplin-mcp-doctor.sh" << 'EOF'
#!/bin/bash
# Joplin MCP Doctor - Diagnostic script

INSTALL_DIR="$HOME/.joplin-mcp"
CONFIG_DIR="$HOME/.config/opencode"
JOPLIN_CONFIG_DIR="$HOME/.config/joplin-desktop"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

echo "========================================"
echo "  Joplin MCP Doctor v2.2.0"
echo "========================================"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗${NC} Joplin MCP is not installed in $INSTALL_DIR"
    echo ""
    echo "Run the installer first:"
    echo "  ./install.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} Installation found: $INSTALL_DIR"
echo ""

if [ -f "$INSTALL_DIR/VERSION" ]; then
    echo "Installed version: $(cat $INSTALL_DIR/VERSION)"
    echo ""
fi

echo -e "${BLUE}Checking files:${NC}"
[ -f "$INSTALL_DIR/server.py" ] && echo -e "  ${GREEN}✓${NC} server.py" || echo -e "  ${RED}✗${NC} server.py not found"
[ -f "$INSTALL_DIR/run_mcp.sh" ] && echo -e "  ${GREEN}✓${NC} run_mcp.sh" || echo -e "  ${RED}✗${NC} run_mcp.sh not found"
[ -f "$INSTALL_DIR/requirements.txt" ] && echo -e "  ${GREEN}✓${NC} requirements.txt" || echo -e "  ${RED}✗${NC} requirements.txt not found"
[ -f "$INSTALL_DIR/venv/bin/python" ] && echo -e "  ${GREEN}✓${NC} Virtual environment" || echo -e "  ${RED}✗${NC} Virtual environment not found"

echo ""
echo -e "${BLUE}Checking token:${NC}"
if [ -f "$INSTALL_DIR/run_mcp.sh" ]; then
    JOPLIN_TOKEN=$(grep "export JOPLIN_TOKEN" "$INSTALL_DIR/run_mcp.sh" | cut -d'"' -f2)
    JOPLIN_PORT=$(grep "export JOPLIN_PORT" "$INSTALL_DIR/run_mcp.sh" | cut -d'"' -f2)

    if [ -n "$JOPLIN_TOKEN" ] && [ "$JOPLIN_TOKEN" != "TOKEN_JOPLIN" ]; then
        echo -e "  ${GREEN}✓${NC} Token configured (${#JOPLIN_TOKEN} characters)"
        echo -e "  ${GREEN}✓${NC} Port configured: ${JOPLIN_PORT:-41184}"
    else
        echo -e "  ${RED}✗${NC} Token not configured or is placeholder"
        echo "     Run ./install.sh to configure"
    fi
fi

echo ""
echo -e "${BLUE}Checking Joplin:${NC}"
port="${JOPLIN_PORT:-41184}"

if [ "$OS" = "macos" ]; then
    if ps aux | grep -i "[j]oplin" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Joplin process detected"
    else
        echo -e "  ${YELLOW}⚠${NC} Joplin process not detected"
    fi
else
    if pgrep -f "joplin" > /dev/null 2>&1 || pgrep -f "Joplin" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Joplin process detected"
    else
        echo -e "  ${YELLOW}⚠${NC} Joplin process not detected"
    fi
fi

if command -v lsof &> /dev/null; then
    if [ "$OS" = "macos" ]; then
        if lsof -i :$port 2>/dev/null | grep -i listen >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Port $port is listening"
        else
            echo -e "  ${YELLOW}⚠${NC} Port $port is not listening"
        fi
    else
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Port $port is listening"
        else
            echo -e "  ${YELLOW}⚠${NC} Port $port is not listening"
        fi
    fi
elif command -v netstat &> /dev/null; then
    if [ "$OS" = "macos" ]; then
        if netstat -an 2>/dev/null | grep -q "\.$port.*LISTEN"; then
            echo -e "  ${GREEN}✓${NC} Port $port is listening"
        else
            echo -e "  ${YELLOW}⚠${NC} Port $port is not listening"
        fi
    else
        if netstat -tuln 2>/dev/null | grep -q ":$port"; then
            echo -e "  ${GREEN}✓${NC} Port $port is listening"
        else
            echo -e "  ${YELLOW}⚠${NC} Port $port is not listening"
        fi
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Cannot verify port (install lsof or netstat)"
fi

echo ""
echo -e "${BLUE}Testing connection to Joplin:${NC}"
if curl -s "http://localhost:$port/ping" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Joplin responds on port $port"
else
    echo -e "  ${YELLOW}⚠${NC} Joplin does not respond on port $port"
    echo "     Make sure that:"
    echo "     1. Joplin is running"
    echo "     2. Web Clipper is enabled (Options > Web Clipper)"
fi

if [ -n "$JOPLIN_TOKEN" ] && [ "$JOPLIN_TOKEN" != "TOKEN_JOPLIN" ]; then
    echo ""
    echo -e "${BLUE}Validating token:${NC}"
    if curl -s "http://localhost:$port/notes?token=$JOPLIN_TOKEN&limit=1" 2>/dev/null | grep -q '"items"'; then
        echo -e "  ${GREEN}✓${NC} Valid token - Successful connection"
    else
        echo -e "  ${RED}✗${NC} Invalid or rejected token"
        echo "     Run ./install.sh to reconfigure"
    fi
fi

echo ""
echo -e "${BLUE}Testing MCP server:${NC}"
if [ -f "$INSTALL_DIR/run_mcp.sh" ]; then
    response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)

    if [ -n "$response" ] && echo "$response" | grep -q '"jsonrpc"'; then
        echo -e "  ${GREEN}✓${NC} MCP server responds"

        tools_response=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | "$INSTALL_DIR/run_mcp.sh" 2>/dev/null | head -1)
        if echo "$tools_response" | grep -q '"tools"'; then
            tool_count=$(echo "$tools_response" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('result',{}).get('tools',[])))" 2>/dev/null || echo "?")
            echo -e "  ${GREEN}✓${NC} Tools available: $tool_count"
        fi
    else
        echo -e "  ${RED}✗${NC} MCP server does not respond correctly"
        echo "     Check the log: $INSTALL_DIR/logs/install.log"
    fi
else
    echo -e "  ${RED}✗${NC} run_mcp.sh not found"
fi

echo ""
echo -e "${BLUE}Checking OpenCode configuration:${NC}"
if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
    if grep -q '"joplin_mcp"' "$CONFIG_DIR/opencode.jsonc"; then
        echo -e "  ${GREEN}✓${NC} Joplin configuration found in opencode.jsonc"
    else
        echo -e "  ${YELLOW}⚠${NC} Joplin configuration not found"
    fi
elif [ -f "$CONFIG_DIR/opencode.json" ]; then
    if grep -q '"joplin_mcp"' "$CONFIG_DIR/opencode.json"; then
        echo -e "  ${GREEN}✓${NC} Joplin configuration found in opencode.json"
    else
        echo -e "  ${YELLOW}⚠${NC} Joplin configuration not found"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} OpenCode config not found"
fi

echo ""
echo -e "${BLUE}Available backups:${NC}"
latest_backup=$(cat "$INSTALL_DIR/LATEST_BACKUP" 2>/dev/null || echo "")
if [ -n "$latest_backup" ] && [ -d "$latest_backup" ]; then
    echo -e "  ${GREEN}✓${NC} Latest backup: $latest_backup"
else
    echo "  ℹ No recent backup information"
fi

echo ""
echo "========================================"
echo -e "  ${GREEN}Diagnostics completed${NC}"
echo "========================================"
echo ""
echo "If you encounter issues:"
echo "  1. Check the log: $INSTALL_DIR/logs/install.log"
echo "  2. Reinstall: ./install.sh"
echo "  3. Uninstall and reinstall: ./uninstall.sh && ./install.sh"
echo ""
echo "========================================"
EOF
    chmod +x "$INSTALL_DIR/joplin-mcp-doctor.sh"
    success "Doctor script created"

    cat > "$INSTALL_DIR/uninstall.sh" << 'UNINSTALL_EOF'
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
echo "  - Configuration at: $CONFIG_DIR/opencode.json or $CONFIG_DIR/opencode.jsonc"
echo ""

read -p "Continue? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Cancelled"
    exit 0
fi

backup_dir="$HOME/.joplin-mcp-backup-$(date +%Y%m%d_%H%M%S)"
if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "$backup_dir"
    echo -e "${GREEN}✓${NC} Backup created: $backup_dir"
fi

if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
    CONFIG_FILE="$CONFIG_DIR/opencode.jsonc" python3 <<'PYEOF'
import json
import os
import re

config_file = os.environ['CONFIG_FILE']

def strip_jsonc(text):
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == '/' and nxt == '/':
            i += 2
            while i < len(text) and text[i] not in '\r\n':
                i += 1
            continue

        if ch == '/' and nxt == '*':
            i += 2
            while i + 1 < len(text) and text[i:i + 2] != '*/':
                i += 1
            i += 2
            continue

        cleaned.append(ch)
        i += 1

    text = ''.join(cleaned)
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == ',':
            j = i + 1
            while j < len(text) and text[j].isspace():
                j += 1
            if j < len(text) and text[j] in '}]':
                i += 1
                continue

        cleaned.append(ch)
        i += 1

    return ''.join(cleaned)

try:
    with open(config_file, 'r', encoding='utf-8') as f:
        raw = f.read()

    try:
        config = json.loads(raw)
    except json.JSONDecodeError:
        config = json.loads(strip_jsonc(raw))

    if 'mcp' in config and 'joplin_mcp' in config['mcp']:
        del config['mcp']['joplin_mcp']
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
            f.write("\n")
        print("OpenCode configuration updated")
except Exception as e:
    print(f"Error updating opencode.jsonc: {e}")
PYEOF
elif [ -f "$CONFIG_DIR/opencode.json" ]; then
    CONFIG_FILE="$CONFIG_DIR/opencode.json" python3 <<'PYEOF'
import json
import os
import re

config_file = os.environ['CONFIG_FILE']

def strip_jsonc(text):
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == '/' and nxt == '/':
            i += 2
            while i < len(text) and text[i] not in '\r\n':
                i += 1
            continue

        if ch == '/' and nxt == '*':
            i += 2
            while i + 1 < len(text) and text[i:i + 2] != '*/':
                i += 1
            i += 2
            continue

        cleaned.append(ch)
        i += 1

    text = ''.join(cleaned)
    cleaned = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        ch = text[i]

        if in_string:
            cleaned.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            cleaned.append(ch)
            i += 1
            continue

        if ch == ',':
            j = i + 1
            while j < len(text) and text[j].isspace():
                j += 1
            if j < len(text) and text[j] in '}]':
                i += 1
                continue

        cleaned.append(ch)
        i += 1

    return ''.join(cleaned)

try:
    with open(config_file, 'r', encoding='utf-8') as f:
        raw = f.read()

    try:
        config = json.loads(raw)
    except json.JSONDecodeError:
        config = json.loads(strip_jsonc(raw))

    if 'mcp' in config and 'joplin_mcp' in config['mcp']:
        del config['mcp']['joplin_mcp']
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
            f.write("\n")
        print("OpenCode configuration updated")
except Exception as e:
    print(f"Error updating opencode.json: {e}")
PYEOF
fi

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
UNINSTALL_EOF
    chmod +x "$INSTALL_DIR/uninstall.sh"
    success "Uninstall script created"
}

show_summary() {
    echo ""
    echo "========================================"
    echo -e "  ${GREEN}Installation Completed - v$VERSION${NC}"
    echo "========================================"
    echo ""
    echo "📁 Location:      $INSTALL_DIR"
    if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
        echo "⚙️  Configuration: $CONFIG_DIR/opencode.jsonc"
    else
        echo "⚙️  Configuration: $CONFIG_DIR/opencode.json"
    fi
    echo "🔑 Token:         Configured ✓"
    echo "✅ Tests:         Passed ✓"
    echo ""
    echo "🚀 To use in OpenCode:"
    echo "   1. Restart OpenCode"
    echo "   2. Try: 'List my Joplin notebooks'"
    echo ""
    echo "🔧 Useful commands:"
    echo "   ~/.joplin-mcp/joplin-mcp-doctor.sh  # Diagnostics"
    echo "   ~/.joplin-mcp/uninstall.sh          # Uninstall"
    echo "   ./install.sh                        # Reinstall/update"
    echo ""
    echo "📋 Backup saved to: $BACKUP_DIR"
    echo "📝 Installation log: $LOG_FILE"
    echo "========================================"
}

show_error_help() {
    echo ""
    echo "========================================"
    echo -e "  ${RED}INSTALLATION ERROR${NC}"
    echo "========================================"
    echo ""
    echo "Possible solutions:"
    echo ""
    echo "1. Verify that Joplin is running"
    echo "2. Enable Web Clipper in Joplin:"
    echo "   Options > Web Clipper > Enable Web Clipper"
    echo ""
    echo "3. Check the installation log:"
    echo "   cat $LOG_FILE"
    echo ""
    echo "4. Run diagnostics:"
    echo "   ~/.joplin-mcp/joplin-mcp-doctor.sh"
    echo ""
    echo "5. Restore backup:"
    echo "   cp $BACKUP_DIR/opencode.json.backup ~/.config/opencode/opencode.json"
    echo ""
    echo "6. To reinstall:"
    echo "   ./install.sh"
    echo ""
    echo "========================================"
}

main() {
    echo "========================================"
    echo "  Joplin MCP Installer v$VERSION"
    echo "========================================"
    echo ""

    mkdir -p "$INSTALL_DIR/logs" 2>/dev/null || true
    echo "=== Installation started: $(date) ===" > "$LOG_FILE"

    detect_os
    check_system_deps
    check_joplin_installed
    check_existing_installation

    backup_config

    get_token

    install_files
    generate_wrapper_script

    configure_opencode

    install_python_deps
    create_helper_scripts

    echo ""
    log "Running post-installation tests..."

    if test_mcp_server && test_mcp_tools; then
        show_summary
        echo "=== Installation completed successfully: $(date) ===" >> "$LOG_FILE"
        exit 0
    else
        show_error_help
        echo "=== Installation failed: $(date) ===" >> "$LOG_FILE"
        exit 1
    fi
}

trap 'echo ""; error "Installation cancelled"; exit 1' INT

main "$@"