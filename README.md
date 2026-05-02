# Joplin MCP Server

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/FErArg/joplin-mcp/releases)
[![Python](https://img.shields.io/badge/python-3.9+-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-GPL3-blue.svg)](LICENSE)

A Model Context Protocol (MCP) server for interacting with Joplin notes.

## Features

**v2.0.0 - 15 MCP Tools + 18 OpenCode Tools for Complete Joplin Management:**

### Supported Operating Systems
- **Linux** (Ubuntu, Debian, Fedora, etc.)
- **macOS** (OS X 10.9+)

### MCP Tools (Python server.py)

#### Read-Only Tools
- **search_notes**: Search notes by keyword across all notebooks
- **read_note**: Read full note content in Markdown format
- **list_notebooks**: List all notebooks (folders) in Joplin
- **list_tags**: List all tags in Joplin

#### Notebook Management
- **create_notebook**: Create new notebooks with optional nesting
- **update_notebook**: Rename existing notebooks
- **delete_notebook**: Delete notebooks (soft or permanent)

#### Note Management
- **create_note**: Create notes with title, body, and optional tags
- **rename_note**: Explicitly rename notes with validation
- **update_note**: Update note title and/or body content
- **update_note_content**: Update Markdown body content only
- **move_note**: Move notes between notebooks with validation
- **delete_note**: Delete individual notes (soft or permanent)

#### Tag Management
- **add_tags_to_note**: Add tags to notes (creates if non-existent)
- **remove_tags_from_note**: Remove tags from notes

### OpenCode Plugin Tools (TypeScript, opencode/tools/)

These tools are registered as OpenCode plugins and can be invoked directly from the chat.

#### Search & Read
- **joplin_search_text(query, limit?)**: Search notes by text content
- **joplin_search_by_tag(tagId, limit?)**: List notes with a specific tag
- **joplin_search_by_notebook(notebookId, limit?)**: List notes in a notebook
- **joplin_read(noteId)**: Get full note content with metadata
- **joplin_revisar_nota(noteId)**: Read and analyze a note (Spanish interface)
- **joplin_buscar_en_wiki(query, limit?)**: Search notes in WiKi_LLM notebook tree

#### Notes CRUD
- **joplin_create_note(title, body, notebookId?)**: Create a new note
- **joplin_update_note(noteId, title?, body?)**: Update note title/body
- **joplin_delete_note(noteId)**: Delete a note permanently
- **joplin_list_notes_in(notebookId)**: List notes in a specific notebook

#### Tags CRUD
- **joplin_list_tags()**: List all tags
- **joplin_create_tag(title)**: Create a new tag
- **joplin_delete_tag(tagId)**: Delete a tag
- **joplin_add_tag_to_note(noteId, tagId)**: Assign tag to note
- **joplin_remove_tag_from_note(noteId, tagId)**: Remove tag from note
- **joplin_list_tags_of_note(noteId)**: List tags of a note

#### Notebooks
- **joplin_list_notebooks()**: List all notebooks

#### Automation
- **joplin_ingestar_docs()**: Full ingestion pipeline for WiKi_LLM/Documentación (reads, tags, splits large notes, logs)

### OpenCode Commands (opencode/commands/)

Custom slash commands for recurring tasks:

| Command | Description |
|---------|-------------|
| `/buscar-en-wiki <texto>` | Searches WiKi_LLM by text. Shows title, ID, snippet, and tags. Prioritises best-matching tags when >5 results. |
| `/revisar-nota <note_id>` | Reads and analyzes a note. Shows title, full content, and tags. |

## Installation

📖 **Complete installation guide**: See [INSTALL.md](INSTALL.md) for detailed installation, configuration, and uninstallation instructions.

### Quick Installation

```bash
git clone https://github.com/FErArg/joplin-mcp.git
cd joplin-mcp
./install.sh
```

The automatic installer will detect your Joplin token, configure the environment, and validate the installation. For more options and manual configuration, consult [INSTALL.md](INSTALL.md).

## Quick Reference

| Category | Tool | Description |
|----------|------|-------------|
| **Read** | `search_notes(query)` | Search notes by keyword |
| | `read_note(note_id)` | Read full Markdown content |
| | `list_notebooks()` | List all notebooks |
| | `list_tags()` | List all tags |
| **Notebooks** | `create_notebook(name, parent_id?)` | Create notebook |
| | `update_notebook(id, new_name)` | Rename notebook |
| | `delete_notebook(id, permanent?)` | Delete (soft or permanent) |
| **Notes** | `create_note(title, body, notebook_id?, tags?)` | Create note |
| | `rename_note(id, new_title)` | Rename note |
| | `update_note(id, title?, body?)` | Update title/body |
| | `update_note_content(id, new_body)` | Update body only |
| | `move_note(id, target_notebook_id)` | Move to notebook |
| | `delete_note(id, permanent?)` | Delete (soft or permanent) |
| **Tags** | `add_tags_to_note(id, tags[])` | Add tags (auto-creates) |
| | `remove_tags_from_note(id, tags[])` | Remove tags |

For complete tool documentation and usage examples, see [agents/joplin-mcp.md](agents/joplin-mcp.md).

## Troubleshooting

```bash
~/.joplin-mcp/joplin-mcp-doctor.sh  # Full diagnostics
cat ~/.joplin-mcp/logs/install.log  # Installation logs
```

## Development

```
joplin-mcp/
├── server.py              # MCP server (Python)
├── install.sh            # Installer
├── joplin-mcp-doctor.sh   # Diagnostics
├── opencode/
│   ├── tools/             # TypeScript plugin tools
│   └── commands/          # Custom slash commands
└── agents/
    └── joplin-mcp.md      # AI Agent Handbook
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

## License

**GPL v3** - See [LICENSE](LICENSE) for details.
