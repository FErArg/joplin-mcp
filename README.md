# Joplin MCP Server

A Model Context Protocol (MCP) server for interacting with Joplin notes.

## Features

- Search notes by keyword
- Read full note content in Markdown
- List all notebooks (folders)

## Setup

1. Install Python 3.9+ and `uv` (recommended) or `pip`
2. Create a virtual environment:
   ```bash
   uv venv
   ```
3. Install dependencies:
   ```bash
   uv pip install -r requirements.txt
   ```
4. Get your Joplin Web Clipper token from Joplin settings (Options > Web Clipper)
5. Configure environment variables:
   - `JOPLIN_TOKEN`: your web clipper token
   - `JOPLIN_PORT`: port where Joplin is running (default: 41184)
6. Update `mcp_config.json` with your token or use environment variables

## Usage with Claude Desktop

Add this server to your Claude Desktop configuration (`claude_desktop_config.json`):

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

## Tools

- `search_notes`: Search notes by query
- `read_note`: Read a specific note by ID
- `list_notebooks`: List all notebooks

## Development

The server is implemented in Python using the MCP protocol. It communicates with Joplin's Web Clipper API.

## License

MIT