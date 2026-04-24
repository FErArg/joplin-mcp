# Manual de uso: Tools de Joplin para OpenCode

Este manual describe todas las herramientas (Custom Tools) disponibles para interactuar con tu base de notas de Joplin desde OpenCode. Las herramientas permiten buscar, leer, crear, actualizar y eliminar notas, gestionar libretas y etiquetas, y ejecutar procesos automatizados.

---

## Requisitos previos

1. **Joplin** instalado y con el Web Clipper activo (Settings → Web Clipper → Enable Web Clipper Service).
2. **Token de API**: Cópialo desde Settings → Web Clipper → Authorization Token.
3. **Variable de entorno** `JOPLIN_TOKEN` configurada (ver sección de configuración más abajo).
4. **OpenCode** funcionando con soporte para Custom Tools (archivos `.ts` en `opencode/tools/`).

### Configuración de `JOPLIN_TOKEN`

**Opción A – Variable de entorno del sistema (recomendada):**

```bash
export JOPLIN_TOKEN="tu_token_aqui"
opencode   # lanza OpenCode desde la misma terminal
```

Para hacerlo permanente, añade la línea a `~/.bashrc` o `~/.zshrc`.

**Opción B – Definir en `opencode.json`:**

```json
{
  "env": {
    "JOPLIN_TOKEN": "tu_token_aqui"
  }
}
```

---

## Estructura de la wiki (referencia)

Según la configuración de la wiki `WiKi_LLM` [1], la libreta raíz tiene el ID `036da0b015ba4346a6a32a4eac8b1fed` y contiene las siguientes sublibretas y notas del sistema:

| Libreta | ID | Propósito |
|---------|----|-----------|
| `Documentación` | `7a98bf8bb8bc45698b8c4760369860f3` | Fuentes primarias en Markdown |
| `Proyectos` | `bf9cfa2b83884c07b8a4ee32981bbcca` | Sub‑libretas por proyecto |
| `research` | `e5f3bd0076ab4a71bb6c08e2fcb13563` | Notas derivadas de búsquedas |
| `reference` | `315ebf2c1af2433da4a63cdc2dd141a2` | Artículos, papers, referencias |
| `_templates` | `1cd80fe6dfd242528789a6ac3a9f33f9` | Plantillas reutilizables |

| Nota del sistema | ID | Función |
|------------------|----|---------|
| `Index` | `9184a850d9404902a5a222813797ebc0` | Catálogo maestro |
| `Logs` | `5a1d3f113cc144dbbadcc8b1306746fe` | Registro cronológico |
| `_templates/note.md` | `43dc2e8595b240ff8c2dabcbdf2a8641` | Plantilla base |

---

## Herramientas disponibles

### 1. Búsqueda y lectura

#### `joplin-search/text`
Busca notas por texto en el título o contenido. Devuelve ID, título y un snippet del contenido.

**Export:** `text` en `opencode/tools/joplin-search.ts`

| Parámetro | Tipo   | Obligatorio | Descripción                     |
|-----------|--------|-------------|----------------------------------|
| `query`   | string | Sí          | Término de búsqueda              |
| `limit`   | number | No          | Máximo de resultados (defecto 15)|

**Ejemplo de uso:**

> *"Busca notas que contengan 'arquitectura'."*

**Respuesta esperada:**
```json
[
  { "id": "n1", "title": "Arquitectura del sistema", "snippet": "La arquitectura se basa en microservicios..." },
  { "id": "n2", "title": "Notas de la reunión", "snippet": "Hablamos sobre la arquitectura actual..." }
]
```

---

#### `joplin-search/byTag`
Busca todas las notas que tienen una etiqueta específica (por ID de etiqueta).

**Export:** `byTag` en `opencode/tools/joplin-search.ts`

| Parámetro | Tipo   | Obligatorio | Descripción                     |
|-----------|--------|-------------|----------------------------------|
| `tagId`   | string | Sí          | ID de la etiqueta                |
| `limit`   | number | No          | Máximo de resultados (defecto 20)|

**Ejemplo de uso:**

> *"Dame las notas con la etiqueta 'importante'."*
> (El agente primero listará las etiquetas y luego usará el ID correspondiente.)

**Respuesta esperada:**
```json
[
  { "id": "n1", "title": "Tareas críticas" },
  { "id": "n3", "title": "Documentación pendiente" }
]
```

---

#### `joplin-search/byNotebook`
Busca notas dentro de una libreta específica (por ID de libreta).

**Export:** `byNotebook` en `opencode/tools/joplin-search.ts`

| Parámetro    | Tipo   | Obligatorio | Descripción                     |
|--------------|--------|-------------|----------------------------------|
| `notebookId` | string | Sí          | ID de la libreta                 |
| `limit`      | number | No          | Máximo de resultados (defecto 20)|

**Ejemplo de uso:**

> *"Lista las notas de la libreta 'Trabajo'."*

**Respuesta esperada:**
```json
[
  { "id": "n1", "title": "Reunión lunes" },
  { "id": "n4", "title": "Informe mensual" }
]
```

---

#### `joplin-read`
Lee el contenido completo de una nota a partir de su ID (default export).

**Archivo:** `opencode/tools/joplin-read.ts`

| Parámetro | Tipo   | Obligatorio | Descripción           |
|-----------|--------|-------------|-----------------------|
| `noteId`  | string | Sí          | ID de la nota en Joplin |

**Ejemplo de uso:**

> *"Usa joplin-read para mostrarme el contenido de la nota con id 'abc123'."*

**Respuesta esperada:**
```
# Título de la nota
Contenido en markdown...
*(Actualizada: 2025-03-15T10:30:00.000Z)*
```

---

#### `joplin-revisar-nota`
Lee y analiza una nota: muestra título, contenido completo, etiquetas y fecha. Similar a `joplin-read` pero con formato más detallado (default export).

**Archivo:** `opencode/tools/joplin-revisar-nota.ts`

| Parámetro | Tipo   | Obligatorio | Descripción           |
|-----------|--------|-------------|-----------------------|
| `noteId`  | string | Sí          | ID de la nota en Joplin |

**Ejemplo de uso:**

> *"Revisa la nota con ID 'abc123'."*

**Respuesta esperada:**
```
## Título de la nota

**ID:** abc123
**Actualizada:** 2025-03-15T10:30:00.000Z
**Etiquetas:** importante, proyecto-x

### Contenido
...
```

---

#### `joplin-buscar-en-wiki`
Busca notas en la libreta **WiKi_LLM** (y sublibretas) por texto. Ideal para búsquedas dentro de la wiki (default export).

**Archivo:** `opencode/tools/joplin-buscar-en-wiki.ts`

| Parámetro | Tipo   | Obligatorio | Descripción                     |
|-----------|--------|-------------|----------------------------------|
| `query`   | string | Sí          | Término de búsqueda              |
| `limit`   | number | No          | Máximo de resultados (defecto 10)|

**Ejemplo de uso:**

> *"Busca en WiKi_LLM notas sobre microservicios."*

**Respuesta esperada:**
```json
[
  { "id": "n1", "title": "Microservicios: patrones", "snippet": "Los patrones más comunes son...", "tags": ["arquitectura"] },
  { "id": "n2", "title": "Comparativa monolitos vs microservicios", "snippet": "Los microservicios ofrecen...", "tags": [] }
]
```

---

### 2. Libretas

#### `joplin-notebooks`
Lista todas las libretas disponibles (default export).

**Archivo:** `opencode/tools/joplin-notebooks.ts`

*Sin parámetros.*

**Ejemplo de uso:**

> *"Lista mis libretas de Joplin."*

**Respuesta esperada:**
```json
[
  { "id": "lib1", "title": "Trabajo" },
  { "id": "lib2", "title": "Personal" }
]
```

---

#### `joplin-notes-in`
Obtiene todas las notas de una libreta específica (solo títulos e IDs, default export).

**Archivo:** `opencode/tools/joplin-notes-in.ts`

| Parámetro    | Tipo   | Obligatorio | Descripción               |
|--------------|--------|-------------|---------------------------|
| `notebookId` | string | Sí          | ID de la libreta          |

**Ejemplo de uso:**

> *"Dame las notas de la libreta 'lib1'."*

**Respuesta esperada:**
```json
[
  { "id": "n1", "title": "Reunión lunes" },
  { "id": "n2", "title": "Tareas pendientes" }
]
```

---

### 3. CRUD de notas

#### `joplin-notes/create`
Crea una nueva nota en Joplin. Opcionalmente puedes asignarla a una libreta.

**Export:** `create` en `opencode/tools/joplin-notes.ts`

| Parámetro    | Tipo   | Obligatorio | Descripción                  |
|--------------|--------|-------------|------------------------------|
| `title`      | string | Sí          | Título de la nota            |
| `body`       | string | Sí          | Contenido en Markdown        |
| `notebookId` | string | No          | ID de la libreta destino     |

**Ejemplo de uso:**

> *"Crea una nota llamada 'Ideas para el proyecto' con el siguiente contenido: 'Usar React con TypeScript'. Asígnala a la libreta con id 'lib123'."*

**Respuesta esperada:**
```json
{ "id": "nuevo_id", "title": "Ideas para el proyecto" }
```

---

#### `joplin-notes/update`
Actualiza el título y/o cuerpo de una nota existente.

**Export:** `update` en `opencode/tools/joplin-notes.ts`

| Parámetro | Tipo   | Obligatorio | Descripción               |
|-----------|--------|-------------|---------------------------|
| `noteId`  | string | Sí          | ID de la nota a actualizar |
| `title`   | string | No          | Nuevo título              |
| `body`    | string | No          | Nuevo contenido Markdown  |

**Ejemplo de uso:**

> *"Actualiza la nota con id 'abc123': cambia el título a 'Nuevo título' y el cuerpo a 'Contenido actualizado'."*

**Respuesta esperada:**
```json
{ "id": "abc123", "title": "Nuevo título", "updated": 1710518400 }
```

---

#### `joplin-notes/deleteNote`
Elimina una nota permanentemente.

**Export:** `deleteNote` en `opencode/tools/joplin-notes.ts`

| Parámetro | Tipo   | Obligatorio | Descripción              |
|-----------|--------|-------------|--------------------------|
| `noteId`  | string | Sí          | ID de la nota a eliminar |

**Ejemplo de uso:**

> *"Elimina la nota con id 'abc123'."*

**Respuesta esperada:**
```
Nota abc123 eliminada correctamente.
```

---

### 4. Etiquetas

#### `joplin-tags/list`
Lista todas las etiquetas con su ID y título.

**Export:** `list` en `opencode/tools/joplin-tags.ts`

*Sin parámetros.*

**Ejemplo de uso:**

> *"Muestra todas las etiquetas que tengo."*

**Respuesta esperada:**
```json
[
  { "id": "tag1", "title": "importante" },
  { "id": "tag2", "title": "urgente" }
]
```

---

#### `joplin-tags/create`
Crea una nueva etiqueta.

**Export:** `create` en `opencode/tools/joplin-tags.ts`

| Parámetro | Tipo   | Obligatorio | Descripción              |
|-----------|--------|-------------|--------------------------|
| `title`   | string | Sí          | Nombre de la etiqueta    |

**Ejemplo de uso:**

> *"Crea una etiqueta llamada 'proyecto-x'."*

**Respuesta esperada:**
```json
{ "id": "nueva_tag", "title": "proyecto-x" }
```

---

#### `joplin-tags/deleteTag`
Elimina una etiqueta por su ID.

**Export:** `deleteTag` en `opencode/tools/joplin-tags.ts`

| Parámetro | Tipo   | Obligatorio | Descripción                    |
|-----------|--------|-------------|--------------------------------|
| `tagId`   | string | Sí          | ID de la etiqueta a eliminar   |

**Ejemplo de uso:**

> *"Elimina la etiqueta con id 'tag1'."*

**Respuesta esperada:**
```
Etiqueta tag1 eliminada correctamente.
```

---

### 5. Asignación de etiquetas a notas

#### `joplin-tag-note/add`
Asigna una etiqueta existente a una nota existente.

**Export:** `add` en `opencode/tools/joplin-tag-note.ts`

| Parámetro | Tipo   | Obligatorio | Descripción              |
|-----------|--------|-------------|--------------------------|
| `noteId`  | string | Sí          | ID de la nota            |
| `tagId`   | string | Sí          | ID de la etiqueta        |

**Ejemplo de uso:**

> *"Asigna la etiqueta 'tag1' a la nota 'n1'."*

**Respuesta esperada:**
```
Etiqueta tag1 asignada a nota n1.
```

---

#### `joplin-tag-note/remove`
Desasigna una etiqueta de una nota.

**Export:** `remove` en `opencode/tools/joplin-tag-note.ts`

| Parámetro | Tipo   | Obligatorio | Descripción              |
|-----------|--------|-------------|--------------------------|
| `noteId`  | string | Sí          | ID de la nota            |
| `tagId`   | string | Sí          | ID de la etiqueta        |

**Ejemplo de uso:**

> *"Quita la etiqueta 'tag1' de la nota 'n1'."*

**Respuesta esperada:**
```
Etiqueta tag1 desasignada de nota n1.
```

---

#### `joplin-tag-note/listTagsOfNote`
Obtiene todas las etiquetas asignadas a una nota.

**Export:** `listTagsOfNote` en `opencode/tools/joplin-tag-note.ts`

| Parámetro | Tipo   | Obligatorio | Descripción        |
|-----------|--------|-------------|--------------------|
| `noteId`  | string | Sí          | ID de la nota      |

**Ejemplo de uso:**

> *"¿Qué etiquetas tiene la nota 'n1'?"*

**Respuesta esperada:**
```json
[
  { "id": "tag1", "title": "importante" },
  { "id": "tag2", "title": "urgente" }
]
```

---

### 6. Procesos automatizados

#### `joplin-ingestar-docs`
Ejecuta el proceso completo de ingestación y reestructuración de notas en WiKi_LLM/Documentación. Lee notas no procesadas, las divide si superan las 1000 palabras, asigna metadatos y etiquetas, actualiza el Index y Logs (default export).

**Archivo:** `opencode/tools/joplin-ingestar-docs.ts`

*Sin parámetros.*

**Ejemplo de uso:**

> *"Ejecuta la ingestación de documentos."*

**Respuesta esperada:**
```
## Resumen de ingestación
- Total notas encontradas: 45
- Notas saltadas (ya procesadas): 12
- Notas procesadas: 33
- Notas hijas creadas: 0
- Errores: 0
```
