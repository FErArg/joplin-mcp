# Joplin MCP Server

[![Version](https://img.shields.io/badge/version-1.8-blue.svg)](https://github.com/ferarg/joplin-mcp/releases)
[![Python](https://img.shields.io/badge/python-3.9+-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-GPL3-blue.svg)](LICENSE)

A Model Context Protocol (MCP) server for interacting with Joplin notes.

## Features

**v1.8 - 14 Specialised MCP Tools for Complete Joplin Management:**

### Read-Only Tools
- **search_notes**: Search notes by keyword across all notebooks
- **read_note**: Read full note content in Markdown format
- **list_notebooks**: List all notebooks (folders) in Joplin
- **list_tags**: List all tags in Joplin

### Notebook Management
- **create_notebook**: Create new notebooks with optional nesting
- **update_notebook**: Rename existing notebooks
- **delete_notebook**: Permanently delete notebooks

### Note Management (Specialised in v1.8)
- **create_note**: Create notes with title, body, and optional tags
- **rename_note**: Explicitly rename notes with validation
- **update_note_content**: Update Markdown body content only
- **move_note**: Move notes between notebooks with validation
- **delete_note**: Permanently delete individual notes

### Tag Management
- **add_tags_to_note**: Add tags to notes (creates if non-existent)
- **remove_tags_from_note**: Remove tags from notes

## Installation

📖 **Complete installation guide**: See [INSTALL.md](INSTALL.md) for detailed installation, configuration, and uninstallation instructions.

### Quick Installation

```bash
git clone https://github.com/ferarg/joplin-mcp.git
cd joplin-mcp
./install.sh
```

The automatic installer will detect your Joplin token, configure the environment, and validate the installation. For more options and manual configuration, consult [INSTALL.md](INSTALL.md).

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
# Verify that the token works
curl "http://localhost:41184/notes?token=YOUR_TOKEN&limit=1"

# If it fails, reinstall with new token
./install.sh
```

### Error: Joplin server not available

```bash
# Verify that Joplin responds
~/.joplin-mcp/joplin-mcp-doctor.sh

# Ensure that:
# 1. Joplin desktop is running
# 2. Web Clipper is enabled (Options > Web Clipper > Enable)
# 3. Port 41184 is available
```

### Error: MCP server not responding

```bash
# Verify installation
~/.joplin-mcp/joplin-mcp-doctor.sh

# View logs
cat ~/.joplin-mcp/logs/install.log

# Reinstall if necessary
./install.sh
```

### Recover backup

If something goes wrong, you can restore the backup:

```bash
# View available backups
ls -la ~/.joplin-mcp/backup/

# Restore opencode configuration
cp ~/.joplin-mcp/backup/20250121_143022/opencode.json.backup ~/.config/opencode/opencode.json

# Or restore everything
rm -rf ~/.joplin-mcp
cp -r ~/.joplin-mcp-backup-20250121_143022 ~/.joplin-mcp
```

## Development

### Project Structure

```
joplin-mcp/
├── install.sh              # Main installer
├── uninstall.sh            # Uninstaller
├── joplin-mcp-doctor.sh    # Diagnostic script
├── run_mcp.sh              # Wrapper template
├── server.py               # MCP server
├── requirements.txt        # Python dependencies
├── mcp_config.json         # Example for Claude Desktop
├── CHANGELOG.md            # Change history
└── README.md               # This file
```

### Testing

```bash
# Manual server test
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ~/.joplin-mcp/run_mcp.sh

# Full diagnostic
~/.joplin-mcp/joplin-mcp-doctor.sh
```

## Changelog

### v1.8 (2025-04-22)
- **New**: Specialised note operations (rename, update content, move)
- **Improved**: Input validation for all note operations
- **Changed**: Replaced generic update_note with 3 specific tools
- **Enhanced**: 14 MCP tools with clear single-purpose functions

### v1.5 (2025-04-21)
- **Major**: Full CRUD operations for notebooks and notes
- **New**: Create, update, delete notebooks (e.g., "WiKi_LLM")
- **New**: Create, update, delete notes with Markdown support
- **New**: Tag management (add, remove, list tags)
- **Enhanced**: 12 MCP tools (from 3 in v1.4)
- **Improved**: Better error handling and API coverage

### v1.4 (2025-04-21)
- Converted to Linux-only MCP server
- Removed macOS and Windows compatibility code
- Updated OS detection to Linux-only

### v1.3 (2025-04-21)
- Complete translation to British English
- Added project attribution (JoplinApp, OpenCode, MCP Protocol)
- Updated all version references to 1.3
- Security verification: no personal information leaks

### v1.2 (2025-04-21)
- Fixed installation menu logic
- Fixed backup self-copy error
- Updated all version references to 1.2

### v1.1 (2025-04-21)
- **New**: Automatic installer (`install.sh`)
- **New**: Uninstaller (`uninstall.sh`)
- **New**: Diagnostic script (`joplin-mcp-doctor.sh`)
- **New**: Automatic token detection from Joplin settings
- **New**: Token validation during installation
- **New**: Post-installation tests
- **New**: Automatic configuration backup
- **New**: Logging system
- **Improvement**: Idempotency on reinstallations
- **Improvement**: Error handling and recovery

### v1.0 (2025-04-21)
- Initial stable release
- search_notes, read_note, list_notebooks tools
- Wrapper script support for OpenCode
- Environment variable configuration
- MCP protocol implementation

## Security Notes

- **Never commit your Joplin token to git**
- The installer saves the token in `~/.joplin-mcp/run_mcp.sh` (accessible only by your user)
- The repository only contains placeholders (`TOKEN_JOPLIN`)
- Backups are saved in `~/.joplin-mcp/backup/` (check permissions)

## License

**GPL v3 License** - See [LICENSE](LICENSE) file for details

This project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

## Project Attribution

This project is built on the following technologies:

- **[JoplinApp](https://joplinapp.org/)** - The open source note-taking application
- **[OpenCode](https://github.com/anomalyco/opencode)** - AI-powered code development framework
- **[MCP Protocol](https://modelcontextprotocol.io/)** - Model Context Protocol version 2024-11-05

## Acknowledgments

This project was developed with the assistance of:

- **[DeepSeek](https://www.deepseek.com/)** - AI model used for code development, architecture design, and documentation
- **[Kimi](https://kimi.moonshot.cn/)** - AI model used for code review, optimisation, and testing

Special thanks to the open-source AI community for making tools like these accessible to developers.

## Contributing

Contributions are welcome! Please ensure:
1. No tokens or sensitive data in commits
2. Follow existing code style
3. Update README.md if adding features
4. Test with `./joplin-mcp-doctor.sh`

## Support

For issues or questions:
1. Run `~/.joplin-mcp/joplin-mcp-doctor.sh` for diagnostics
2. Check logs: `~/.joplin-mcp/logs/install.log`
3. Open an issue on GitHub
