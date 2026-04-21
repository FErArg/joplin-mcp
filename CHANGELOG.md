# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1] - 2025-04-21

### Added
- **Automated Installer** (`install.sh`) - Complete installation automation with:
  - OS detection (Linux, macOS, Windows WSL)
  - Dependency checking (Python 3.9+, pip, curl)
  - Automatic token detection from Joplin settings
  - Interactive token prompt with validation
  - Automatic backup of configurations
  - Post-installation testing
  - Idempotent reinstallation support
  
- **Uninstaller** (`uninstall.sh`) - Clean removal with:
  - Backup before removal
  - Automatic cleanup of OpenCode configuration
  - Preservation of user data
  
- **Diagnostic Tool** (`joplin-mcp-doctor.sh`) - Comprehensive health checks:
  - Installation verification
  - Token validation
  - Joplin connectivity testing
  - MCP server response testing
  - Configuration validation
  
- **Logging System** - Installation and operation logs:
  - `~/.joplin-mcp/logs/install.log`
  - Timestamped entries
  - Error tracking
  
- **Backup System** - Automatic backups:
  - Pre-installation backup of `opencode.json`
  - Backup of Joplin settings
  - Timestamped backup directories
  - Easy restoration process
  
- **Version Tracking** - `~/.joplin-mcp/VERSION` file

### Changed
- Improved `run_mcp.sh` as a template for installer generation
- Enhanced error handling throughout
- Better user feedback with colored output
- More robust JSON manipulation using Python

### Security
- Token stored only in user's home directory (`~/.joplin-mcp/`)
- Repository contains only placeholders
- Automatic backup prevents configuration loss
- Input validation for tokens

## [1.0] - 2025-04-21

### Added
- Initial stable release
- Three MCP tools:
  - `search_notes` - Search notes by keyword
  - `read_note` - Read full note content
  - `list_notebooks` - List all notebooks
  
- Wrapper script support for OpenCode integration
- Environment variable configuration via `JOPLIN_TOKEN`
- MCP protocol implementation with stdio transport
- Support for Joplin Web Clipper API
- Configuration examples for:
  - OpenCode
  - Claude Desktop
  
- Basic documentation and README
- `.gitignore` for Python projects

### Security
- Token placeholder in repository (`TOKEN_JOPLIN`)
- User configures token locally in wrapper script
- No sensitive data in git history

[Unreleased]: https://github.com/ferarg/joplin-mcp/compare/v1.1...HEAD
[1.1]: https://github.com/ferarg/joplin-mcp/compare/v1.0...v1.1
[1.0]: https://github.com/ferarg/joplin-mcp/releases/tag/v1.0
