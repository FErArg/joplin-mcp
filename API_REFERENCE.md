# API Reference

Complete reference for all MCP tools available in Joplin MCP v1.5.

## Overview

Joplin MCP provides **12 tools** for managing your Joplin notes through the Model Context Protocol:

- **3 Read-Only Tools** (from v1.4): Search and read notes and notebooks
- **9 Write Tools** (new in v1.5): Create, update, and delete notebooks, notes, and tags

---

## Notebook Management

### `list_notebooks`

Obtains a list of all notebooks in Joplin.

**Parameters:** None

**Returns:**
```
- Notebook Name (ID: notebook-id-123)
- Another Notebook (ID: notebook-id-456)
```

**Example Usage:**
```json
{
  "name": "list_notebooks",
  "arguments": {}
}
```

---

### `create_notebook`

Creates a new notebook in Joplin.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | string | Yes | Name of the notebook |
| `parent_id` | string | No | Parent notebook ID for nested notebooks |

**Returns:**
```
Created notebook 'WiKi_LLM' (ID: abc123def456)
```

**Example Usage:**
```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "WiKi_LLM"
  }
}
```

**Nested Notebook Example:**
```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Subfolder",
    "parent_id": "parent-notebook-id"
  }
}
```

---

### `update_notebook`

Renames an existing notebook.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `notebook_id` | string | Yes | The ID of the notebook |
| `new_name` | string | Yes | New name for the notebook |

**Returns:**
```
Updated notebook to 'New Name' (ID: abc123def456)
```

**Example Usage:**
```json
{
  "name": "update_notebook",
  "arguments": {
    "notebook_id": "abc123def456",
    "new_name": "Updated Name"
  }
}
```

---

### `delete_notebook`

Permanently deletes a notebook and all notes within it.

**⚠️ Warning:** This action cannot be undone. All notes in the notebook will be permanently deleted.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `notebook_id` | string | Yes | The ID of the notebook to delete |

**Returns:**
```
Deleted notebook (ID: abc123def456)
```

**Example Usage:**
```json
{
  "name": "delete_notebook",
  "arguments": {
    "notebook_id": "abc123def456"
  }
}
```

---

## Note Management

### `search_notes`

Searches notes in Joplin using a keyword.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `query` | string | Yes | The word or phrase to search for |

**Returns:**
```
- Note Title 1 (ID: note-id-123)
- Note Title 2 (ID: note-id-456)
```

**Example Usage:**
```json
{
  "name": "search_notes",
  "arguments": {
    "query": "project documentation"
  }
}
```

---

### `read_note`

Reads the full Markdown content of a specific note.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `note_id` | string | Yes | The note ID in Joplin |

**Returns:**
```markdown
# Note Title

Notebook ID: notebook-id-123

Full note content in Markdown...
```

**Example Usage:**
```json
{
  "name": "read_note",
  "arguments": {
    "note_id": "note-id-123"
  }
}
```

---

### `create_note`

Creates a new note in Joplin with title, body, and optional notebook and tags.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | string | Yes | Title of the note |
| `body` | string | Yes | Markdown content of the note |
| `notebook_id` | string | No | Notebook ID to place the note in |
| `tags` | array | No | List of tag names to add |

**Returns:**
```
Created note 'My New Note' (ID: note-id-789)
```

**Simple Example:**
```json
{
  "name": "create_note",
  "arguments": {
    "title": "Meeting Notes",
    "body": "## Agenda\n\n- Item 1\n- Item 2"
  }
}
```

**Full Example with Notebook and Tags:**
```json
{
  "name": "create_note",
  "arguments": {
    "title": "Project Plan",
    "body": "# Project Overview\n\nThis is the main project plan...",
    "notebook_id": "abc123def456",
    "tags": ["project", "planning", "2025"]
  }
}
```

---

### `update_note`

Updates an existing note's title, body, or notebook location.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `note_id` | string | Yes | The ID of the note to update |
| `title` | string | No | New title (optional) |
| `body` | string | No | New body content (optional) |
| `notebook_id` | string | No | New notebook ID to move to (optional) |

**Note:** At least one of `title`, `body`, or `notebook_id` must be provided.

**Returns:**
```
Updated note (ID: note-id-789)
```

**Update Title Example:**
```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "note-id-789",
    "title": "Updated Title"
  }
}
```

**Move to Different Notebook:**
```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "note-id-789",
    "notebook_id": "new-notebook-id"
  }
}
```

**Update Content:**
```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "note-id-789",
    "body": "Updated content..."
  }
}
```

---

### `delete_note`

Permanently deletes a note.

**⚠️ Warning:** This action cannot be undone.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `note_id` | string | Yes | The ID of the note to delete |

**Returns:**
```
Deleted note (ID: note-id-789)
```

**Example Usage:**
```json
{
  "name": "delete_note",
  "arguments": {
    "note_id": "note-id-789"
  }
}
```

---

## Tag Management

### `list_tags`

Obtains a list of all tags in Joplin.

**Parameters:** None

**Returns:**
```
- project (ID: tag-id-123)
- urgent (ID: tag-id-456)
- documentation (ID: tag-id-789)
```

**Example Usage:**
```json
{
  "name": "list_tags",
  "arguments": {}
}
```

---

### `add_tags_to_note`

Adds one or more tags to a note. Creates tags if they don't exist.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `note_id` | string | Yes | The ID of the note |
| `tags` | array | Yes | List of tag names to add |

**Returns:**
```
Added tag 'project' to note (ID: note-id-789)
Added tag 'urgent' to note (ID: note-id-789)
```

**Example Usage:**
```json
{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "note-id-789",
    "tags": ["project", "urgent"]
  }
}
```

---

### `remove_tags_from_note`

Removes specified tags from a note.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `note_id` | string | Yes | The ID of the note |
| `tags` | array | Yes | List of tag names to remove |

**Returns:**
```
Removed tag 'urgent' from note (ID: note-id-789)
```

**Example Usage:**
```json
{
  "name": "remove_tags_from_note",
  "arguments": {
    "note_id": "note-id-789",
    "tags": ["urgent"]
  }
}
```

---

## Error Handling

All tools return descriptive error messages when operations fail:

### Common Errors

**Authentication Error:**
```
Error: HTTP 401: Unauthorized - Invalid or missing token
```

**Not Found Error:**
```
Error: HTTP 404: Not Found - Notebook does not exist
```

**Validation Error:**
```
Error: HTTP 400: Bad Request - Title cannot be empty
```

**Network Error:**
```
Error: Network error: Connection refused
```

### Troubleshooting

1. **"Invalid or missing token"**
   - Verify JOPLIN_TOKEN is set correctly
   - Check that Web Clipper is enabled in Joplin
   - Ensure token has not been regenerated

2. **"Notebook does not exist"**
   - Use `list_notebooks` to verify the ID
   - IDs are case-sensitive

3. **"Connection refused"**
   - Verify Joplin Desktop is running
   - Check Web Clipper port (default: 41184)
   - Ensure firewall allows local connections

---

## Joplin API Endpoints Used

The following Joplin REST API endpoints are utilised:

| Tool | Method | Endpoint |
|------|--------|----------|
| list_notebooks | GET | /folders |
| create_notebook | POST | /folders |
| update_notebook | PUT | /folders/{id} |
| delete_notebook | DELETE | /folders/{id} |
| search_notes | GET | /search |
| read_note | GET | /notes/{id} |
| create_note | POST | /notes |
| update_note | PUT | /notes/{id} |
| delete_note | DELETE | /notes/{id} |
| list_tags | GET | /tags |
| add_tags_to_note | POST | /notes/{id}/tags |
| remove_tags_from_note | DELETE | /notes/{id}/tags/{tagId} |

---

## Version Compatibility

- **Joplin MCP Version:** 1.5.0
- **MCP Protocol:** 2024-11-05
- **Joplin Desktop:** 2.13+ (Web Clipper API)
- **Python:** 3.9+
- **Operating System:** Linux only (from v1.4)

---

## See Also

- [Installation Guide](./INSTALL.md) - Setup and configuration
- [Examples](./EXAMPLES.md) - Common use cases and workflows
- [Changelog](./CHANGELOG.md) - Version history and changes
