# Joplin MCP – Agent Guidelines

## Project Overview
- Python MCP server for Joplin notes, installed globally in `~/.joplin‑mcp`
- Eight tools: `search_notes`, `read_note`, `list_notebooks`, `create_notebook`, `create_note`, `update_note`, `delete_note`, `delete_notebook`
- Fork optimised for macOS compatibility (BSD tools) while maintaining Linux support

## Installation & Setup
- **Primary installer**: `./install.sh`  
  - Detects OS, Python 3.9+, Joplin token, validates connectivity
  - Creates virtual environment, installs dependencies, configures OpenCode
  - Backs up existing OpenCode config before modifying
- **Manual installation**: See `INSTALL.md` for step‑by‑step instructions
- **Diagnostic**: `~/.joplin‑mcp/joplin‑mcp‑doctor.sh` verifies installation health

## Development Commands
- **Run local test** (placeholder token): `./test_mcp.sh`
- **Manual server test**:
  ```bash
  echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' \
    | ~/.joplin‑mcp/run_mcp.sh
  ```
- **Uninstall**: `~/.joplin‑mcp/uninstall.sh` (creates backup before removal)

## Testing & Validation
- No automated test suite; rely on the diagnostic script
- Always run `./joplin‑mcp‑doctor.sh` after making changes to core scripts
- Ensure Joplin desktop is running with Web Clipper enabled (port 41184)

## macOS Compatibility
- Scripts detect `darwin*` and use BSD‑compatible commands
- Critical fixes documented in `MACOS.md`:
  - Python version detection uses Python, not GNU `grep -oP`
  - Port checking with OS‑specific `netstat` flags
  - Process detection uses `ps aux` instead of `pgrep -f`
  - File operations use POSIX shell globs, not GNU `find` extensions
- No Homebrew GNU tools required; native macOS tools suffice

## Contribution Guidelines
1. **Never commit tokens or sensitive data** – repository uses placeholder `TOKEN_JOPLIN`
2. **Follow existing code style** – British English spelling, consistent indentation
3. **Update documentation** when adding features (README.md, INSTALL.md, CHANGELOG.md)
4. **Test with the diagnostic script** before submitting changes:
   ```bash
   ./joplin‑mcp‑doctor.sh
   ```
5. **Keep macOS compatibility** – verify changes work with both GNU and BSD toolchains

## Security Notes
- Token stored only in `~/.joplin‑mcp/run_mcp.sh` (user‑only permissions)
- Backups contain token; protect `~/.joplin‑mcp/backup/` directory
- Repository contains only placeholders; real tokens must never be committed

## File Locations
- **Source**: Repository root (`server.py`, `install.sh`, `requirements.txt`, etc.)
- **Installation**: `~/.joplin‑mcp/` (virtual environment, wrapper script, logs, backups)
- **OpenCode config**: `~/.config/opencode/opencode.json`
