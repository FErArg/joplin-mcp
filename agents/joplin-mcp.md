# Joplin MCP Server - AI Agent Handbook

## Overview

MCP Server para interacturar con Joplin (notas, notebooks, tags) via Model Context Protocol.

- **Version**: 2.0.0
- **Protocol**: MCP 2024-11-05
- **OS**: Linux + macOS
- **Config Key**: `joplin_mcp`

---

## MCP Tools (15)

### Read-Only
| Tool | Parameters | Returns |
|------|------------|----------|
| `search_notes` | `query: string` | Lista de notas (ID + título) |
| `read_note` | `note_id: string` | Contenido Markdown completo |
| `list_notebooks` | — | Lista de notebooks (ID + título) |
| `list_tags` | — | Lista de tags (ID + título) |

### Notebooks
| Tool | Parameters | Returns |
|------|------------|----------|
| `create_notebook` | `name: string`, `parent_id?: string` | Notebook creado |
| `update_notebook` | `notebook_id: string`, `new_name: string` | Notebook renombrado |
| `delete_notebook` | `notebook_id: string`, `permanent?: boolean` | Notebook eliminado |

### Notes
| Tool | Parameters | Returns |
|------|------------|----------|
| `create_note` | `title: string`, `body: string`, `notebook_id?: string`, `tags?: string[]` | Nota creada |
| `rename_note` | `note_id: string`, `new_title: string` | Nota renombrada |
| `update_note` | `note_id: string`, `title?: string`, `body?: string` | Nota actualizada |
| `update_note_content` | `note_id: string`, `new_body: string` | Body actualizado |
| `move_note` | `note_id: string`, `target_notebook_id: string` | Nota movida |
| `delete_note` | `note_id: string`, `permanent?: boolean` | Nota eliminada |

### Tags
| Tool | Parameters | Returns |
|------|------------|----------|
| `add_tags_to_note` | `note_id: string`, `tags: string[]` | Tags añadidos (crea si no existen) |
| `remove_tags_from_note` | `note_id: string`, `tags: string[]` | Tags eliminados |

---

## OpenCode Plugin Tools (TypeScript)

Tools adicionales en `opencode/tools/` para uso directo desde chat:

| Tool | Description |
|------|-------------|
| `joplin_search_text(query, limit?)` | Buscar por texto |
| `joplin_search_by_tag(tagId, limit?)` | Buscar por tag |
| `joplin_search_by_notebook(notebookId, limit?)` | Listar por notebook |
| `joplin_read(noteId)` | Leer nota completa con metadata |
| `joplin_buscar_en_wiki(query, limit?)` | Buscar en WiKi_LLM |

## OpenCode Commands

Commands en `opencode/commands/`:

| Command | Description |
|---------|-------------|
| `mcp_joplin_ingestar_docs` | Ingestar documentos a Joplin |
| `mcp_joplin_notas_recientes` | Listar notas recientes |

---

## Usage Patterns

### Búsqueda y Lectura
```
1. search_notes("keyword") → obtener note_ids
2. read_note(note_id) → leer contenido completo
```

### Gestión de Notebooks
```
1. list_notebooks() → ver notebooks disponibles
2. create_notebook("Nombre", parent_id?) → crear notebook
3. move_note(note_id, notebook_id) → mover nota entre notebooks
```

### Gestión de Notas
```
1. create_note(title, body, notebook_id?, tags?) → crear nota
2. update_note(note_id, title?, body?) → actualizar ambos
3. update_note_content(note_id, new_body) → solo body
4. rename_note(note_id, new_title) → solo título
5. delete_note(note_id, permanent?) → eliminar (trash o permanente)
```

### Gestión de Tags
```
1. add_tags_to_note(note_id, ["tag1", "tag2"]) → añadir tags
2. Tags se crean automáticamente si no existen
```

---

## Important Conventions

### Note IDs
- Todos los IDs son **strings UUID** de Joplin
- Obtener IDs via `search_notes`, `list_notebooks`, `read_note`

### Notebooks (Folders)
- `parent_id` opcional para notebooks anidados
- Verificar existencia con `list_notebooks()`

### Tags
- Se crean automáticamente si no existen
- Búsqueda es case-sensitive

### Soft vs Permanent Delete
- `permanent=false` (default): Mueve a Trash
- `permanent=true`: Eliminación permanente

### Errores
- Retorna `{"error": "message"}`
- Input vacío retorna error específico

---

## Quick Reference

```python
# Leer nota
read_note(note_id) → "# Título\n\nNotebook ID: xxx\n\nbody markdown"

# Mover nota entre notebooks  
move_note(note_id, target_notebook_id)

# Buscar y crear
search_notes("query") → IDs
create_note("Título", "# Body markdown", notebook_id, ["tag1"])

# Gestionar tags
add_tags_to_note(note_id, ["importante", "proyecto"])
```

---

## Debugging

```bash
~/.joplin-mcp/joplin-mcp-doctor.sh  # Diagnóstico
~/.joplin-mcp/logs/install.log     # Logs
```
