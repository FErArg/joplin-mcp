#!/bin/bash
# Wrapper script para ejecutar el servidor MCP de Joplin con variables de entorno
# Ubicación preferida: ~/.config/opencode/mcp/joplin-mcp.sh

export JOPLIN_TOKEN="REEMPLAZA_CON_TU_TOKEN_DE_WEB_CLIPPER"
export JOPLIN_PORT="41184"

cd "$(dirname "$0")"
exec ./venv/bin/python server.py
