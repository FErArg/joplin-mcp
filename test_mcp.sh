#!/bin/bash
# Test script para verificar el servidor MCP de Joplin

cd /home/ferarg/Git/joplin-mcp

export JOPLIN_TOKEN="b1fcefce79aa0fb0aa3fc85cc89031a8421302340253b984efd4cfc20d51f7c6ef98ba33f207979f9e677cca4ad361d5328a42940e8598dbe1cae1bd028439be"
export JOPLIN_PORT="41184"

echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ./venv/bin/python server.py
