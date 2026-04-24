import sys
import json
import urllib.request
import urllib.parse
import os

# Configuration
JOPLIN_TOKEN = os.environ.get("JOPLIN_TOKEN")
JOPLIN_PORT = os.environ.get("JOPLIN_PORT", "41184")
BASE_URL = f"http://localhost:{JOPLIN_PORT}"


def joplin_request(endpoint, query_params=None, method="GET", data=None):
    """Makes a request to the Joplin API."""
    if not JOPLIN_TOKEN:
        sys.stderr.write("WARNING: JOPLIN_TOKEN is empty or not set\n")
    
    if query_params is None:
        query_params = {}
    query_params['token'] = JOPLIN_TOKEN
    
    query_string = urllib.parse.urlencode(query_params)
    url = f"{BASE_URL}/{endpoint}?{query_string}"
    
    if method == "GET":
        sys.stderr.write(f"DEBUG: GET {BASE_URL}/{endpoint}\n")
    else:
        sys.stderr.write(f"DEBUG: {method} {BASE_URL}/{endpoint}\n")
    
    try:
        headers = {"Content-Type": "application/json"}
        
        if data is not None:
            json_data = json.dumps(data).encode('utf-8')
            req = urllib.request.Request(url, data=json_data, headers=headers, method=method)
        else:
            req = urllib.request.Request(url, headers=headers, method=method)
        
        with urllib.request.urlopen(req) as response:
            response_data = response.read().decode('utf-8')
            if response_data:
                return json.loads(response_data)
            return {}
    except urllib.error.HTTPError as e:
        error_msg = f"HTTP {e.code}: {e.reason}"
        try:
            error_body = e.read().decode('utf-8')
            if error_body:
                error_msg += f" - {error_body}"
        except:
            pass
        return {"error": error_msg}
    except Exception as e:
        return {"error": str(e)}


def search_notes(query):
    """Searches notes in Joplin using a keyword."""
    data = joplin_request("search", {"query": query, "type": "note"})
    if "error" in data:
        return f"Error: {data['error']}"
    
    items = data.get("items", [])
    if not items:
        return "No notes found."
    
    results = [f"- {item['title']} (ID: {item['id']})" for item in items]
    return "\n".join(results)


def read_note(note_id):
    """Reads the full Markdown content of a specific note."""
    data = joplin_request(f"notes/{note_id}", {"fields": "id,title,body,parent_id"})
    if "error" in data:
        return f"Error: {data['error']}"
    
    title = data.get("title", "Untitled")
    body = data.get("body", "")
    parent_id = data.get("parent_id", "")
    return f"# {title}\n\nNotebook ID: {parent_id}\n\n{body}"


def list_notebooks():
    """Obtains a list of all notebooks in Joplin."""
    data = joplin_request("folders")
    if "error" in data:
        return f"Error: {data['error']}"
    
    items = data.get("items", [])
    if not items:
        return "No notebooks found."
    
    results = [f"- {item['title']} (ID: {item['id']})" for item in items]
    return "\n".join(results)


def create_notebook(name, parent_id=None):
    """Creates a new notebook in Joplin."""
    payload = {"title": name}
    if parent_id:
        payload["parent_id"] = parent_id
    
    data = joplin_request("folders", method="POST", data=payload)
    if "error" in data:
        return f"Error creating notebook: {data['error']}"
    
    notebook_id = data.get("id", "unknown")
    return f"Created notebook '{name}' (ID: {notebook_id})"


def delete_notebook(notebook_id):
    """Deletes a notebook and all its notes."""
    data = joplin_request(f"folders/{notebook_id}", method="DELETE")
    if "error" in data:
        return f"Error deleting notebook: {data['error']}"
    
    return f"Deleted notebook (ID: {notebook_id})"


def update_notebook(notebook_id, new_name):
    """Updates a notebook's title."""
    payload = {"title": new_name}
    data = joplin_request(f"folders/{notebook_id}", method="PUT", data=payload)
    if "error" in data:
        return f"Error updating notebook: {data['error']}"
    
    return f"Updated notebook to '{new_name}' (ID: {notebook_id})"


def create_note(title, body, notebook_id=None, tags=None):
    """Creates a new note in Joplin."""
    payload = {
        "title": title,
        "body": body,
        "source": "joplin-mcp"
    }
    
    if notebook_id:
        payload["parent_id"] = notebook_id
    
    data = joplin_request("notes", method="POST", data=payload)
    if "error" in data:
        return f"Error creating note: {data['error']}"
    
    note_id = data.get("id", "unknown")
    
    # Add tags if specified
    if tags and isinstance(tags, list):
        for tag in tags:
            add_tag_to_note(note_id, tag)
    
    return f"Created note '{title}' (ID: {note_id})"


def rename_note(note_id, new_title):
    """Renames a note."""
    if not new_title or not new_title.strip():
        return "Error: New title cannot be empty."
    
    payload = {"title": new_title.strip()}
    data = joplin_request(f"notes/{note_id}", method="PUT", data=payload)
    if "error" in data:
        return f"Error renaming note: {data['error']}"
    
    return f"Renamed note to '{new_title}' (ID: {note_id})"


def update_note_content(note_id, new_body):
    """Updates a note's body content."""
    if new_body is None:
        return "Error: New body content must be specified."
    
    payload = {"body": new_body}
    data = joplin_request(f"notes/{note_id}", method="PUT", data=payload)
    if "error" in data:
        return f"Error updating note content: {data['error']}"
    
    return f"Updated note content (ID: {note_id})"


def move_note(note_id, target_notebook_id):
    """Moves a note to a different notebook."""
    if not target_notebook_id:
        return "Error: Target notebook ID must be specified."
    
    # Verify target notebook exists
    check = joplin_request(f"folders/{target_notebook_id}")
    if "error" in check:
        return f"Error: Target notebook not found (ID: {target_notebook_id})"
    
    payload = {"parent_id": target_notebook_id}
    data = joplin_request(f"notes/{note_id}", method="PUT", data=payload)
    if "error" in data:
        return f"Error moving note: {data['error']}"
    
    notebook_name = check.get("title", "Unknown")
    return f"Moved note to notebook '{notebook_name}' (ID: {note_id})"


def delete_note(note_id):
    """Deletes a note permanently."""
    data = joplin_request(f"notes/{note_id}", method="DELETE")
    if "error" in data:
        return f"Error deleting note: {data['error']}"
    
    return f"Deleted note (ID: {note_id})"


def add_tag_to_note(note_id, tag_name):
    """Adds a tag to a note. Creates the tag if it doesn't exist."""
    # First, check if tag exists
    tags_data = joplin_request("tags", {"query": tag_name})
    tag_id = None
    
    if "items" in tags_data:
        for tag in tags_data["items"]:
            if tag.get("title") == tag_name:
                tag_id = tag.get("id")
                break
    
    # Create tag if it doesn't exist
    if not tag_id:
        create_response = joplin_request("tags", method="POST", data={"title": tag_name})
        if "error" in create_response:
            # If SQLITE_CONSTRAINT, the tag was likely created by a concurrent call — re-fetch it
            if "SQLITE_CONSTRAINT" in create_response["error"]:
                retry_data = joplin_request("tags", {"query": tag_name})
                if "items" in retry_data:
                    for tag in retry_data["items"]:
                        if tag.get("title") == tag_name:
                            tag_id = tag.get("id")
                            break
                if not tag_id:
                    return f"Error creating tag (conflict): {create_response['error']}"
            else:
                return f"Error creating tag: {create_response['error']}"
        else:
            tag_id = create_response.get("id")

    if not tag_id:
        return f"Error: Could not find or create tag '{tag_name}'."

    # Add tag to note
    add_response = joplin_request(f"notes/{note_id}/tags", method="POST", data={"id": tag_id})
    if "error" in add_response:
        return f"Error adding tag: {add_response['error']}"

    return f"Added tag '{tag_name}' to note (ID: {note_id})"


def remove_tag_from_note(note_id, tag_name):
    """Removes a tag from a note."""
    # Find the tag
    tags_data = joplin_request(f"notes/{note_id}/tags")
    tag_id = None
    
    if "items" in tags_data:
        for tag in tags_data["items"]:
            if tag.get("title") == tag_name:
                tag_id = tag.get("id")
                break
    
    if not tag_id:
        return f"Tag '{tag_name}' not found on this note."
    
    # Remove tag from note
    data = joplin_request(f"notes/{note_id}/tags/{tag_id}", method="DELETE")
    if "error" in data:
        return f"Error removing tag: {data['error']}"
    
    return f"Removed tag '{tag_name}' from note (ID: {note_id})"


def list_tags():
    """Lists all tags in Joplin."""
    data = joplin_request("tags")
    if "error" in data:
        return f"Error: {data['error']}"
    
    items = data.get("items", [])
    if not items:
        return "No tags found."
    
    results = [f"- {item['title']} (ID: {item['id']})" for item in items]
    return "\n".join(results)


# Static declaration of tools for MCP exposure
TOOLS = [
    {
        "name": "search_notes",
        "description": "Searches notes in Joplin using a keyword. Returns a list of IDs and titles.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "The word or phrase to search for"}
            },
            "required": ["query"]
        }
    },
    {
        "name": "read_note",
        "description": "Reads the full Markdown content of a specific note given its ID.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The note ID in Joplin"}
            },
            "required": ["note_id"]
        }
    },
    {
        "name": "list_notebooks",
        "description": "Obtains a list of all notebooks in Joplin.",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "create_notebook",
        "description": "Creates a new notebook in Joplin. Optionally specify a parent notebook for nested organisation.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "Name of the notebook"},
                "parent_id": {"type": "string", "description": "Optional parent notebook ID for nested notebooks"}
            },
            "required": ["name"]
        }
    },
    {
        "name": "delete_notebook",
        "description": "Permanently deletes a notebook and all notes within it. Use with caution.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "notebook_id": {"type": "string", "description": "The ID of the notebook to delete"}
            },
            "required": ["notebook_id"]
        }
    },
    {
        "name": "update_notebook",
        "description": "Renames an existing notebook.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "notebook_id": {"type": "string", "description": "The ID of the notebook"},
                "new_name": {"type": "string", "description": "New name for the notebook"}
            },
            "required": ["notebook_id", "new_name"]
        }
    },
    {
        "name": "create_note",
        "description": "Creates a new note in Joplin with title, body, and optional notebook and tags.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "title": {"type": "string", "description": "Title of the note"},
                "body": {"type": "string", "description": "Markdown content of the note"},
                "notebook_id": {"type": "string", "description": "Optional notebook ID to place the note in"},
                "tags": {"type": "array", "items": {"type": "string"}, "description": "Optional list of tags to add"}
            },
            "required": ["title", "body"]
        }
    },
    {
        "name": "rename_note",
        "description": "Renames an existing note to a new title.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note to rename"},
                "new_title": {"type": "string", "description": "The new title for the note"}
            },
            "required": ["note_id", "new_title"]
        }
    },
    {
        "name": "update_note_content",
        "description": "Updates the Markdown body content of an existing note.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note to update"},
                "new_body": {"type": "string", "description": "The new Markdown content"}
            },
            "required": ["note_id", "new_body"]
        }
    },
    {
        "name": "move_note",
        "description": "Moves a note to a different notebook.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note to move"},
                "target_notebook_id": {"type": "string", "description": "The ID of the destination notebook"}
            },
            "required": ["note_id", "target_notebook_id"]
        }
    },
    {
        "name": "delete_note",
        "description": "Permanently deletes a note. Use with caution.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note to delete"}
            },
            "required": ["note_id"]
        }
    },
    {
        "name": "add_tags_to_note",
        "description": "Adds one or more tags to a note. Creates tags if they don't exist.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note"},
                "tags": {"type": "array", "items": {"type": "string"}, "description": "List of tag names to add"}
            },
            "required": ["note_id", "tags"]
        }
    },
    {
        "name": "remove_tags_from_note",
        "description": "Removes specified tags from a note.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "The ID of the note"},
                "tags": {"type": "array", "items": {"type": "string"}, "description": "List of tag names to remove"}
            },
            "required": ["note_id", "tags"]
        }
    },
    {
        "name": "list_tags",
        "description": "Obtains a list of all tags in Joplin.",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    }
]


def handle_request(msg):
    method = msg.get("method")
    msg_id = msg.get("id")
    
    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {}
                },
                "serverInfo": {
                    "name": "joplin_mcp_raw",
                    "version": "1.8.4"
                }
            }
        }
        
    elif method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "tools": TOOLS
            }
        }
        
    elif method == "tools/call":
        params = msg.get("params", {})
        tool_name = params.get("name")
        args = params.get("arguments", {})
        
        result_text = ""
        is_error = False
        
        # Existing tools (v1.4)
        if tool_name == "search_notes":
            result_text = search_notes(args.get("query", ""))
        elif tool_name == "read_note":
            result_text = read_note(args.get("note_id", ""))
        elif tool_name == "list_notebooks":
            result_text = list_notebooks()
        
        # Notebook management tools (v1.8)
        elif tool_name == "create_notebook":
            result_text = create_notebook(
                args.get("name", ""),
                args.get("parent_id")
            )
        elif tool_name == "delete_notebook":
            result_text = delete_notebook(args.get("notebook_id", ""))
        elif tool_name == "update_notebook":
            result_text = update_notebook(
                args.get("notebook_id", ""),
                args.get("new_name", "")
            )
        
        # Note management tools (v1.8) - Specialised operations
        elif tool_name == "create_note":
            result_text = create_note(
                args.get("title", ""),
                args.get("body", ""),
                args.get("notebook_id"),
                args.get("tags", [])
            )
        elif tool_name == "rename_note":
            result_text = rename_note(
                args.get("note_id", ""),
                args.get("new_title", "")
            )
        elif tool_name == "update_note_content":
            result_text = update_note_content(
                args.get("note_id", ""),
                args.get("new_body", "")
            )
        elif tool_name == "move_note":
            result_text = move_note(
                args.get("note_id", ""),
                args.get("target_notebook_id", "")
            )
        elif tool_name == "delete_note":
            result_text = delete_note(args.get("note_id", ""))
        
        # Tag management tools (v1.8)
        elif tool_name == "add_tags_to_note":
            note_id = args.get("note_id", "")
            tags = args.get("tags", [])
            if not note_id:
                result_text = "Error: note_id is required."
                is_error = True
            elif not tags or not isinstance(tags, list):
                result_text = "Error: tags must be a non-empty list."
                is_error = True
            else:
                results = []
                for tag in tags:
                    result = add_tag_to_note(note_id, tag)
                    # Suppress noisy SQLITE_CONSTRAINT from user output when tag already exists
                    if "SQLITE_CONSTRAINT" in result and "Added tag" not in result:
                        results.append(f"Added tag '{tag}' to note (ID: {note_id})")
                    else:
                        results.append(result)
                result_text = "\n".join(results)
        elif tool_name == "remove_tags_from_note":
            note_id = args.get("note_id", "")
            tags = args.get("tags", [])
            results = []
            for tag in tags:
                results.append(remove_tag_from_note(note_id, tag))
            result_text = "\n".join(results)
        elif tool_name == "list_tags":
            result_text = list_tags()
        
        else:
            result_text = f"Unknown tool: {tool_name}"
            is_error = True
            
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "content": [
                    {
                        "type": "text",
                        "text": result_text
                    }
                ],
                "isError": is_error
            }
        }
        
    # Notifications (notifications/initialised, ping, or cancel) don't have an ID requiring direct response
    if msg_id is not None:
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "error": {
                "code": -32601,
                "message": f"Method {method} not supported"
            }
        }
    return None


def main():
    # Infinite loop to receive commands via standard input (stdio)
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
            
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
            
        response = handle_request(msg)
        if response:
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
