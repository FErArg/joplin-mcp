#!/bin/bash
# Wrapper script para ejecutar el servidor MCP de Joplin con variables de entorno

export JOPLIN_TOKEN="b1fcefce79aa0fb0aa3fc85cc89031a8421302340253b984efd4cfc20d51f7c6ef98ba33f207979f9e677cca4ad361d5328a42940e8598dbe1cae1bd028439be"
export JOPLIN_PORT="41184"

cd /home/ferarg/Git/joplin-mcp
exec ./venv/bin/python server.py
