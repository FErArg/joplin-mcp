import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export default tool({
  description: `Lee y analiza una nota de Joplin por su ID.
  Devuelve título, contenido completo y etiquetas (tags).
  Si la nota no existe, indica que no se encontró.`,
  args: {
    noteId: tool.schema.string().describe("ID de la nota en Joplin"),
  },
  async execute(args) {
    if (!TOKEN) {
      return "Error: La variable de entorno JOPLIN_TOKEN no está configurada."
    }

    try {
      // 1. Obtener la nota
      const noteRes = await fetch(
        `${BASE}/notes/${args.noteId}?token=${TOKEN}&fields=id,title,body,updated_time`
      )
      if (!noteRes.ok) {
        if (noteRes.status === 404) {
          return `No se encontró la nota con ID '${args.noteId}'.`
        }
        return `Error al obtener la nota: ${noteRes.status} - ${await noteRes.text()}`
      }
      const note = await noteRes.json()

      // 2. Obtener las etiquetas de la nota
      const tagsRes = await fetch(
        `${BASE}/notes/${args.noteId}/tags?token=${TOKEN}&fields=id,title`
      )
      const tagsData = await tagsRes.json()
      const tags = tagsData.items.map((t: any) => t.title).join(", ") || "(sin etiquetas)"

      // 3. Devolver la información formateada
      return [
        `## ${note.title}`,
        ``,
        `**ID:** ${note.id}`,
        `**Actualizada:** ${new Date(note.updated_time * 1000).toISOString()}`,
        `**Etiquetas:** ${tags}`,
        ``,
        `### Contenido`,
        ``,
        note.body || "(sin contenido)",
      ].join("\n")
    } catch (err: any) {
      return `Error inesperado: ${err.message}`
    }
  },
})
