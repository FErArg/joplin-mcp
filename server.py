import sys
import json
import urllib.request
import urllib.parse
import os

# Configuración base
JOPLIN_TOKEN = os.environ.get("JOPLIN_TOKEN")
JOPLIN_PORT = os.environ.get("JOPLIN_PORT", "41184")
BASE_URL = f"http://localhost:{JOPLIN_PORT}"

def joplin_request(endpoint, query_params=None):
    if not JOPLIN_TOKEN:
        sys.stderr.write("WARNING: JOPLIN_TOKEN is empty or not set\n")
    
    if query_params is None:
        query_params = {}
    query_params['token'] = JOPLIN_TOKEN
    
    query_string = urllib.parse.urlencode(query_params)
    url = f"{BASE_URL}/{endpoint}?{query_string}"
    sys.stderr.write(f"DEBUG: Requesting {BASE_URL}/{endpoint} (token length: {len(JOPLIN_TOKEN) if JOPLIN_TOKEN else 0})\n")
    
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data
    except Exception as e:
        return {"error": str(e)}

def search_notes(query):
    data = joplin_request("search", {"query": query})
    if "error" in data:
        return f"Error: {data['error']}"
    
    items = data.get("items", [])
    if not items:
        return "No se encontraron notas."
    
    results = [f"- {item['title']} (ID: {item['id']})" for item in items]
    return "\n".join(results)

def read_note(note_id):
    data = joplin_request(f"notes/{note_id}", {"fields": "id,title,body"})
    if "error" in data:
        return f"Error: {data['error']}"
    
    title = data.get("title", "Sin título")
    body = data.get("body", "")
    return f"# {title}\n\n{body}"

def list_notebooks():
    data = joplin_request("folders")
    if "error" in data:
        return f"Error: {data['error']}"
    
    items = data.get("items", [])
    if not items:
        return "No se encontraron libretas."
    
    results = [f"- {item['title']} (ID: {item['id']})" for item in items]
    return "\n".join(results)

# Declaración estática de las herramientas para exponerlas vía MCP
TOOLS = [
    {
        "name": "search_notes",
        "description": "Busca notas en Joplin utilizando una palabra clave. Devuelve una lista de IDs y Títulos.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "La palabra o frase a buscar"}
            },
            "required": ["query"]
        }
    },
    {
        "name": "read_note",
        "description": "Lee el contenido completo en Markdown de una nota específica dado su ID.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "note_id": {"type": "string", "description": "El ID de la nota en Joplin"}
            },
            "required": ["note_id"]
        }
    },
    {
        "name": "list_notebooks",
        "description": "Obtiene una lista de todos los cuadernos (libretas) en Joplin.",
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
                    "version": "1.0.0"
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
        
        if tool_name == "search_notes":
            result_text = search_notes(args.get("query", ""))
        elif tool_name == "read_note":
            result_text = read_note(args.get("note_id", ""))
        elif tool_name == "list_notebooks":
            result_text = list_notebooks()
        else:
            result_text = f"Herramienta desconocida: {tool_name}"
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
        
    # Las notificaciones (como notifications/initialized, ping, o cancel) no tienen un ID que requiera respuesta directa
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
    # Bucle infinito para recibir comandos a través de standard input (stdio)
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
