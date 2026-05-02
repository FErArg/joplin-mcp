# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-05-02

### Added
- **Multi-OS Support**: Linux + macOS compatibility
  - OS detection: `linux-gnu*` and `darwin*`
  - Joplin path detection for both platforms
  - BSD-compatible commands for macOS (netstat, lsof, ps)

### Changed
- **15 MCP Tools** (from 14): Added `update_note(note_id, title?, body?)` for flexible note updates
- **permanent flag**: Added to `delete_note` and `delete_notebook` for permanent deletion
- **Input Validation**: Enhanced validation across all functions
- **Config Key**: Changed from `joplin` to `joplin_mcp` for OpenCode configuration
- **DEBUG Log**: Shows token length only (security improvement)

### Technical
- **server.py**: Base from macOS fork v2.2.0 with robustness improvements
- **install.sh**: Multi-OS detection, BSD-compatible commands, better error handling
- **joplin-mcp-doctor.sh**: OS-aware diagnostic checks

### Security
- **Token Protection**: DEBUG logs only show token length, never the token itself

## [1.8.5] - 2026-05-02

### Security
- **DEBUG log mask**: Token is now masked (`[token masked]`) in debug logs to prevent accidental token exposure

## [1.8.4] - 2026-04-24

### Added
- **install.sh deploys OpenCode plugin files**: The installer now copies
  `opencode/tools/` (.ts) and `opencode/commands/` (.md) to
  `~/.config/opencode/` for automatic availability.

## [1.8.2] - 2026-04-24

### Fixed
- **SQLITE_CONSTRAINT race condition**: Tag creation now handles concurrent
  unique constraint violations by retrying the search instead of failing
  (`server.py` — `add_tag_to_note()`).

### Added
- **OpenCode integration documentation**: Full listing of 18 OpenCode plugin
  tools and 2 custom slash commands in README.md.
- **Input validation**: `add_tags_to_note` now validates `note_id` and `tags`
  before processing, returning clear errors for missing required fields.
- **dryRun parameter**: `ingestar_docs` tool now supports `dryRun=true` to
  simulate the process without writing any changes to Joplin.
- **Configurable chunking**: `ingestar_docs` now accepts `maxWordCount` and
  `chunkSize` parameters to control document splitting behaviour.

### Changed
- **Project structure**: Updated to document `opencode/` directory with
  tools/ and commands/ subdirectories.

## [1.8] - 2025-04-22

### Changed
- **Specialised Note Operations**:
  - Replaced generic `update_note` with three specialised tools:
    - `rename_note(note_id, new_title)` - Explicitly renames notes with validation
    - `update_note_content(note_id, new_body)` - Updates Markdown body only
    - `move_note(note_id, target_notebook_id)` - Moves notes between notebooks with validation
  - Each tool has clear, single-purpose functionality
  - Better error messages for each operation type

### Improved
- **Note Management**:
  - Input validation: Empty titles are rejected
  - Notebook existence verification before moving notes
  - Descriptive success messages showing old and new values
  - Clear separation of concerns between operations

### Technical
- **Tool Clarity**: 14 specialised MCP tools (up from 12)
- **Validation**: Pre-operation checks prevent errors
- **Error Handling**: Specific error messages for each failure type

## [1.5] - 2025-04-21

### Added
- **Full CRUD Operations for Notebooks**:
  - `create_notebook(name, parent_id)` - Creates new notebooks with optional nesting
  - `delete_notebook(notebook_id)` - Permanently deletes notebooks and their contents
  - `update_notebook(notebook_id, new_name)` - Renames existing notebooks
  - Enables creation of structured notebook hierarchies like "WiKi_LLM"

- **Full CRUD Operations for Notes**:
  - `create_note(title, body, notebook_id, tags)` - Creates notes with optional placement and tags
  - `update_note(note_id, title, body, notebook_id)` - Updates note content or location
  - `delete_note(note_id)` - Permanently deletes individual notes
  - Supports Markdown content and tag associations

- **Tag Management System**:
  - `add_tags_to_note(note_id, tags)` - Adds multiple tags to notes (creates if non-existent)
  - `remove_tags_from_note(note_id, tags)` - Removes specified tags from notes
  - `list_tags()` - Displays all tags in Joplin
  - Automatic tag creation and association handling

- **Enhanced API Infrastructure**:
  - Refactored `joplin_request()` to support POST, PUT, DELETE operations
  - Improved error handling with specific HTTP error codes and messages
  - Better debug logging for all API operations
  - Maintains backward compatibility with all v1.4 tools

### Changed
- **Expanded Tool Set**: From 3 tools to 12 tools (300% increase in functionality)
- **Improved Error Messages**: More descriptive errors for API failures and validation issues
- **British English Consistency**: All new tool descriptions use British spelling and terminology

### Technical
- **Code Organisation**: Modular function structure for better maintainability
- **API Coverage**: Complete coverage of Joplin REST API for folders, notes, and tags
- **Input Validation**: Schema-based validation for all new tools via MCP protocol

## [1.4] - 2025-04-21

### Changed
- **Converted to Linux-Only MCP Server**:
  - Removed macOS detection (`darwin*`) from `install.sh`
  - Removed Windows detection (`msys`, `cygwin`) from `install.sh`
  - Eliminated macOS Joplin path (`~/Library/Application Support/Joplin/`)
  - Updated OS detection to Linux-only with explicit error for unsupported systems
  - Updated documentation to reflect Linux-only support

### Removed
- Cross-platform compatibility code for macOS and Windows
- macOS-specific Joplin configuration paths
- Windows WSL support references

## [1.3] - 2025-04-21

### Changed
- **Complete Translation to British English**:
  - Translated all user-facing text in `install.sh`, `joplin-mcp-doctor.sh`, `uninstall.sh`
  - Translated tool descriptions in `server.py` to British English
  - Translated complete `README.md` and `INSTALL.md` documentation
  - Applied British spelling throughout: "colour", "centre", "analyse", "organisation"

### Added
- **Project Attribution**:
  - Added links to [JoplinApp](https://joplinapp.org/) in README.md
  - Added links to [OpenCode](https://github.com/anomalyco/opencode) in README.md
  - Documented MCP Protocol version (2024-11-05)
  - Added "Acknowledgements" section with project references

### Security
- **Privacy Verification**:
  - Verified no personal information leaks in codebase
  - Confirmed no hardcoded tokens, passwords, or private paths
  - All sensitive data uses placeholders (`TOKEN_JOPLIN`)

## [1.2] - 2025-04-21

### Fixed
- **Installation Menu Logic** (`install.sh`):
  - Fixed menu to show "Instalar" option for fresh installations
  - Now correctly differentiates between fresh install and existing installation
  - Shows appropriate options based on installation state

- **Backup Self-Copy Error** (`install.sh`):
  - Fixed backup function trying to copy directory into itself
  - Added exclusion of `backup/` directory during backup process
  - Added fallback to `find` command when `rsync` is not available

- **Version Consistency**:
  - Updated all version references from v1.1 to v1.2
  - Synchronized versions across: install.sh, server.py, joplin-mcp-doctor.sh, README.md

- **Personal Information Removal**:
  - Removed hardcoded personal path from `test_mcp.sh`
  - Now uses `$(dirname "$0")` for portability

## [1.1] - 2025-04-21

### Added
- **Automated Installer** (`install.sh`) - Complete installation automation with:
  - OS detection (Linux only)
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
- Better user feedback with coloured output
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

[Unreleased]: https://github.com/FErArg/joplin-mcp/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/FErArg/joplin-mcp/compare/v1.8.5...v2.0.0
[1.8.5]: https://github.com/FErArg/joplin-mcp/compare/v1.8.4...v1.8.5
[1.8.4]: https://github.com/FErArg/joplin-mcp/compare/v1.8.2...v1.8.4
[1.8.2]: https://github.com/FErArg/joplin-mcp/compare/v1.8...v1.8.2
[1.8]: https://github.com/FErArg/joplin-mcp/compare/v1.5...v1.8
[1.5]: https://github.com/FErArg/joplin-mcp/compare/v1.4...v1.5
[1.4]: https://github.com/FErArg/joplin-mcp/compare/v1.3...v1.4
[1.3]: https://github.com/FErArg/joplin-mcp/compare/v1.2...v1.3
[1.2]: https://github.com/FErArg/joplin-mcp/compare/v1.1...v1.2
[1.1]: https://github.com/FErArg/joplin-mcp/compare/v1.0...v1.1
[1.0]: https://github.com/FErArg/joplin-mcp/releases/tag/v1.0
