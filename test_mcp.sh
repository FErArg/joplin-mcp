#!/bin/bash
# Test script para verificar el servidor MCP de Joplin

cd /home/ferarg/Git/joplin-mcp

export JOPLIN_TOKEN="TOKEN_JOPLIN"
export JOPLIN_PORT="41184"

echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ./venv/bin/python server.py
