# Joplin MCP Server v1.0

[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/ferarg/joplin-mcp/releases/tag/v1.0)
[![Python](https://img.shields.io/badge/python-3.9+-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

A Model Context Protocol (MCP) server for interacting with Joplin notes.

## Features

- **search_notes**: Search notes by keyword across all notebooks
- **read_note**: Read full note content in Markdown format
- **list_notebooks**: List all notebooks (folders) in Joplin

## Quick Start

1. **Install dependencies**:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Get your Joplin Web Clipper token**:
   - Open Joplin → Options → Web Clipper → Show token

3. **Configure your MCP client** (see sections below)

## Configuration

### OpenCode

Create the wrapper script at `~/.config/opencode/mcp/joplin-mcp.sh`:

```bash
#!/bin/bash
export JOPLIN_TOKEN="YOUR_TOKEN_HERE"
export JOPLIN_PORT="41184"
exec /path/to/joplin-mcp/venv/bin/python /path/to/joplin-mcp/server.py
```

Add to `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "joplin": {
      "type": "local",
      "command": ["/home/YOUR_USER/.config/opencode/mcp/joplin-mcp.sh"],
      "enabled": true
    }
  }
}
```

### Claude Desktop

Add to your Claude Desktop configuration (`claude_desktop_config.json`):

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
        "server.py"
      ],
      "env": {
        "JOPLIN_TOKEN": "YOUR_TOKEN_HERE",
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
- Verify your Joplin Web Clipper token is correct
- Ensure the token is properly exported in your wrapper script
- Test with: `curl "http://localhost:41184/notes?token=YOUR_TOKEN"`

### Error: Joplin server not available
- Ensure Joplin desktop app is running
- Verify Web Clipper is enabled in Joplin settings
- Check the port (default: 41184)

### Environment variable not set
The server reads `JOPLIN_TOKEN` from environment variables. If using a wrapper script, ensure:
1. The script is executable: `chmod +x joplin-mcp.sh`
2. The path in `opencode.json` is absolute
3. The token is properly quoted

## Development

### Project Structure
```
joplin-mcp/
├── server.py          # Main MCP server implementation
├── requirements.txt   # Python dependencies
├── run_mcp.sh         # Example wrapper script (template)
├── test_mcp.sh        # Test script (template)
├── mcp_config.json    # Example Claude Desktop config
└── README.md          # This file
```

### Running Tests
```bash
# Set your token
export JOPLIN_TOKEN="YOUR_TOKEN"
export JOPLIN_PORT="41184"

# Test the server
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ./venv/bin/python server.py
```

## Changelog

### v1.0 (2025-04-21)
- Initial stable release
- Implemented search_notes, read_note, list_notebooks tools
- Added wrapper script support for OpenCode
- Environment variable configuration
- MCP protocol implementation

## Security Notes

- **Never commit your Joplin token to git**
- Use wrapper scripts or environment variables
- The repository contains placeholder tokens (`TOKEN_JOPLIN`, `YOUR_TOKEN_HERE`)
- Keep your wrapper script in a secure location (e.g., `~/.config/opencode/mcp/`)

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please ensure:
1. No tokens or sensitive data in commits
2. Follow existing code style
3. Update README.md if adding features

## Support

For issues or questions, please open an issue on GitHub.
