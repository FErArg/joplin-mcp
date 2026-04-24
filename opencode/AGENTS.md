# AGENTS.md — WiKi_LLM

## Contexto

Esta wiki está gestionada mediante **JoplinAPP** y sirve como base de conocimiento para un sistema **RAG** (Retrieval‑Augmented Generation). Toda la estructura, metadatos y convenciones están definidas para facilitar la ingestión, el chunking semántico y la navegación.

---

## Limitación de accesos
Solo puedes acceder a la información que se encuentra dentro la Libreta Joplin `WiKi_LLM`, y sublibretas

---

## Estructura de libretas (Joplin)

Libreta raíz: `WiKi_LLM` (ID: `036da0b015ba4346a6a32a4eac8b1fed`)

| Libreta | ID | Propósito |
|---------|----|-----------|
| `Documentación` | `7a98bf8bb8bc45698b8c4760369860f3` | Fuentes primarias en Markdown |
| `Proyectos` | `bf9cfa2b83884c07b8a4ee32981bbcca` | Sub‑libretas por proyecto (una por proyecto) |
| `research` | `e5f3bd0076ab4a71bb6c08e2fcb13563` | Notas derivadas de búsquedas importantes |
| `reference` | `315ebf2c1af2433da4a63cdc2dd141a2` | Artículos, papers, enlaces de referencia, Artefactos procesados, notas de ingest y salidas en formato Markdown |
| `_templates` | `1cd80fe6dfd242528789a6ac3a9f33f9` | Plantillas reutilizables |

### Notas del sistema (raíz)

| Nota | ID | Función |
|------|----|---------|
| `Index` | `9184a850d9404902a5a222813797ebc0` | Catálogo maestro de la wiki. Debe actualizarse tras cada ingesta significativa. |
| `Logs` | `5a1d3f113cc144dbbadcc8b1306746fe` | Registro cronológico solo‑adición (append‑only). |
| `_templates/note.md` | `43dc2e8595b240ff8c2dabcbdf2a8641` | Plantilla base obligatoria para nuevas notas. |

---

## Idioma

- **Todas las notas deben redactarse en castellano**, aunque el contenido original esté en otro idioma.
- Resúmenes, metadatos y enlaces siempre en español.

---

## Plantilla base (`_templates/note.md`)

Toda nota nueva DEBE seguir esta estructura:

```markdown
# {{title}}

*Resumen: Escribe aquí un breve resumen de 2-3 líneas sobre el contenido de la nota.*

---

## Metadatos
- **Fecha de creación:** {{date}} {{time}}
- **Última modificación:** {{date}} {{time}}
- **Etiquetas:** #etiqueta1 #etiqueta2
- **Libreta:** {{notebook}}
- **Fuente:** (URL, libro, artículo, conversación…)

---

## Contenido

### 1. Introducción / Contexto

### 2. Detalles principales

### 3. Alias / Terminología
- **Término principal**: también conocido como *alias1*, *alias2*.

---

## Enlaces relacionados
- Tipo de enlace MarkDown: [Acta Europea sobre AI](:/cd82e8c8f2ba4ea683e6e8c1d563d973)
- Tipo de enlace WebLink: [Recurso externo](https://example.com)

### Enlaces con ancla
Para apuntar a una sección específica dentro de una nota, use el formato [texto](:/note_id#encabezado). El #encabezado debe coincidir con el texto del encabezado en minúsculas y con guiones. Ejemplo: [Índice](:/9e4c4fe1411246f9a189e58dc9335a9f#contenido). Se recomienda usar anclas solo si la nota destino es larga; para notas cortas basta con el enlace simple.

Nota sobre enlaces internos:
- Uso obligatorio: los enlaces a notas internas deben seguir la sintaxis de Joplin; el identificador interno comienza con `:/` seguido del note_id (32 caracteres hex). Ejemplo de enlace válido: `[Acta Europea sobre AI](:/cd82e8c8f2ba4ea683e6e8c1d563d973)`
  - `Index.md` y `Log.md` están ubicados en la libreta raíz `WiKi_LLM` y deben usarse como referencia central para índices y registros.
  - La libreta `Documentación` está anidada dentro de `WiKi_LLM`; al enlazar notas de esa libreta use siempre el ID interno (`:/note_id`).
  - Ejemplo combinado (título + libreta): `[Acta Europea sobre AI](:/cd82e8c8f2ba4ea683e6e8c1d563d973) — WiKi_LLM/Documentación`

---

## Referencias
1. Autor, *Título*, editorial/año.
```

---

## Buenas prácticas

1. **Resumen obligatorio** al inicio de cada nota (2-3 líneas).
2. **Terminología consistente**: un término por concepto. Añadir alias explícitos.
3. **Enlaces internos Joplin**: usar formato `:/id` (ej. `[Index](:/9e4c4fe1411246f9a189e58dc9335a9f)`).
4. **Notas focalizadas**: máximo ~1000 palabras. Si crece, dividir en notas hijas.
5. **Metadatos completos**: fecha, etiquetas, fuente.
6. **Alias documentados**: en sección "Alias / Terminología".

---

## Formato de Log (`Log.md`)

Registro **append‑only**. Cada entrada:

```markdown
## [YYYY-MM-DD] tipo | Descripción
```

**Tipos válidos:** `ingest`, `query`, `lint`, `refactor`, `archive`, `create`.

Ejemplo:
```markdown
## [2026-04-23] ingest | Artículo sobre vector databases
```

Esto permite parsear con herramientas Unix:
```bash
grep "^## \[" log.md | tail -5
```

---

## Procedimiento para nuevos proyectos

1. Crear una **sub‑libreta** dentro de `WiKi_LLM/Proyectos`.
2. Dentro de la sub‑libreta, crear:
   - `Index` — catálogo específico del proyecto.
   - `Logs` — registro de actividad del proyecto.
3. Actualizar `WiKi_LLM/Index` para reflejar el nuevo proyecto.
4. Añadir entrada en `WiKi_LLM/Logs`.

---

## Procedimiento para ingestar documentos

1. Crear nota en la libreta correspondiente (libreta `reference`).
2. Aplicar la plantilla `_templates/note.md`.
3. Rellenar resumen, metadatos, alias y contenido.
4. Añadir enlaces internos a notas relacionadas si existen.
5. Actualizar `Index` (sección correspondiente: Entidades, Conceptos, Fuentes, Referencias).
6. Añadir entrada en `Logs` con tipo `ingest`.
7. Si supera ~1000 palabras, dividir en notas hijas y enlazar.
8. No modificar el contenido original de la nota a ingestar, solo modifica etiquetas

---

## Conexión con Joplin

- **API**: Joplin expone una API REST (puerto por defecto 41184 con token).
- **Herramientas disponibles** en este entorno:
  - `Joplin_create_notebook` — crear libretas/sub‑libretas (`parent_id` para anidar).
  - `Joplin_create_note` — crear notas (`notebook_id` obligatorio).
  - `Joplin_update_note_content` — actualizar cuerpo de nota existente.
  - `Joplin_move_note` — mover notas entre libretas.
  - `Joplin_add_tags_to_note` / `Joplin_remove_tags_from_note` — gestión de etiquetas.
  - `Joplin_list_notebooks`, `Joplin_search_notes`, `Joplin_read_note` — exploración.

**IDs clave a memorizar** (para generar enlaces `Título nota:/id` sin consultar constantemente):
- Raíz `WiKi_LLM`: `036da0b015ba4346a6a32a4eac8b1fed`
- `Index`: `9184a850d9404902a5a222813797ebc0`
- `Logs`: `5a1d3f113cc144dbbadcc8b1306746fe`
- `note.md` (template): `43dc2e8595b240ff8c2dabcbdf2a8641`

---

## Convenciones de nomenclatura

- **Libretas**: PascalCase para proyectos, minúsculas para carpetas sistema (`research`, `reference`, `_templates`).
- **Notas**: `PascalCase.md` para índices y logs; título descriptivo para contenido.
- **Etiquetas**: lowercase, sin espacios, con guiones (ej. `#vector-database`, `#rag-pipeline`).

---

# Reglas del agente

- Tienes acceso a una wiki interna en Joplin llamada `WiKi_LLM` a través de las herramientas MCP de `joplin_mcp`.
- Cuando el usuario haga una pregunta técnica, **usa siempre** `Joplin_search_notes` y `Joplin_read_note` para buscar información relevante antes de responder.
- No inventes datos que no estén en la wiki. Si no encuentras nada, indícalo claramente.
- Las herramientas MCP están disponibles como `Joplin_search_notes`, `Joplin_read_note`, etc.
---

## Configuración necesaria

Antes de usar cualquier herramienta, asegúrate de que la variable `JOPLIN_TOKEN` esté configurada en el entorno. Si no lo está, informa al usuario y detente.

## Herramientas disponibles

### Búsqueda y lectura

- **`joplin_search_text`** – Busca notas por texto en título/contenido.  
  *Úsalo cuando el usuario pida buscar información sin especificar libreta.*  
  Parámetros: `query` (obligatorio), `limit` (opcional, defecto 15).

- **`joplin_search_byTag`** – Busca notas que tengan una etiqueta específica (por ID).  
  *Úsalo cuando el usuario pida notas con una etiqueta concreta.*  
  Parámetros: `tagId` (obligatorio), `limit` (opcional, defecto 20).

- **`joplin_search_byNotebook`** – Busca notas dentro de una libreta (por ID).  
  *Úsalo cuando el usuario pida notas de una libreta específica.*  
  Parámetros: `notebookId` (obligatorio), `limit` (opcional, defecto 20).

- **`joplin_read`** – Lee el contenido completo de una nota por su ID.  
  *Úsalo siempre que tengas un ID de nota y necesites su contenido completo.*  
  Parámetros: `noteId` (obligatorio).

- **`revisar_nota`** – Lee y analiza una nota: muestra título, contenido, etiquetas y fecha.  
  *Similar a joplin_read pero con formato más detallado.*  
  Parámetros: `noteId` (obligatorio).

- **`buscar_en_wiki`** – Busca notas en la libreta **WiKi_LLM** (y sublibretas) por texto.  
  *Úsalo cuando el usuario pida buscar específicamente en la wiki.*  
  Parámetros: `query` (obligatorio), `limit` (opcional, defecto 10).

### Libretas

- **`joplin_notebooks`** – Lista todas las libretas.  
  *Sin parámetros. Úsalo para explorar la estructura de libretas.*

- **`joplin_notes_in`** – Lista las notas de una libreta (título e ID).  
  Parámetros: `notebookId` (obligatorio).

### CRUD de notas

- **`joplin_notes_create`** – Crea una nueva nota.  
  Parámetros: `title` (obligatorio), `body` (obligatorio), `notebookId` (opcional).

- **`joplin_notes_update`** – Actualiza título y/o cuerpo de una nota existente.  
  Parámetros: `noteId` (obligatorio), `title` (opcional), `body` (opcional).

- **`joplin_notes_deleteNote`** – Elimina una nota permanentemente.  
  Parámetros: `noteId` (obligatorio).

### Etiquetas

- **`joplin_tags_list`** – Lista todas las etiquetas disponibles.  
  *Sin parámetros. Úsalo antes de buscar por tag si no conoces el ID.*

- **`joplin_tags_create`** – Crea una nueva etiqueta.  
  Parámetros: `title` (obligatorio).

- **`joplin_tags_deleteTag`** – Elimina una etiqueta por ID.  
  Parámetros: `tagId` (obligatorio).

### Asignación de etiquetas

- **`joplin_tag_note_add`** – Asigna una etiqueta a una nota.  
  Parámetros: `noteId` (obligatorio), `tagId` (obligatorio).

- **`joplin_tag_note_remove`** – Desasigna una etiqueta de una nota.  
  Parámetros: `noteId` (obligatorio), `tagId` (obligatorio).

- **`joplin_tag_note_listTagsOfNote`** – Lista las etiquetas de una nota.  
  Parámetros: `noteId` (obligatorio).

## Flujo de trabajo recomendado

1. **Pregunta genérica** → usa `joplin_search_text`.
2. **Búsqueda en wiki** → usa `buscar_en_wiki`.
3. **Búsqueda por etiqueta** → primero `joplin_tags_list`, luego `joplin_search_byTag`.
4. **Lectura profunda** → `joplin_read` o `revisar_nota`.
5. **Crear/editar/eliminar** → tools CRUD correspondientes.
6. **Organizar** → tools de etiquetas.
7. **Ingestación masiva** → solo si el usuario lo pide explícitamente, usar `ingestar_docs`.

## Notas importantes

- Siempre que devuelvas IDs (de notas, libretas o etiquetas), incluye también el título para que el usuario pueda identificarlos.
- Si una tool devuelve un error, indícalo claramente y sugiere posibles causas (token, conectividad, ID incorrecto).
- Para `ingestar_docs`, recomienda primero ejecutar con `dryRun=true` para ver qué haría antes de ejecutarlo realmente.
 
---

*Última actualización de este AGENTS.md:* 2026-04-24 (IDs actualizados tras recrear estructura)
