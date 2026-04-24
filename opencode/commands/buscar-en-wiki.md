---
description: Busca notas en WiKi_LLM por texto
agent: build
subtask: true
---
Busca en la libreta WiKi_LLM (y sublibretas) todas las notas que contengan el término "$ARGUMENTS" usando Joplin_search_notes.

## Para cada nota encontrada, muestra:

- Título
- ID
- Primeras 200 caracteres del contenido
- Etiquetas relevantes
- Si hay más de 5 resultados, prioriza los que tengan las etiquetas más coincidentes.
