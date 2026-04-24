import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export default tool({
  description: "Busca notas en la libreta WiKi_LLM (y sublibretas) por texto. Devuelve título, ID, snippet y etiquetas.",
  args: {
    query: tool.schema.string().describe("Término de búsqueda"),
    limit: tool.schema.number().optional().default(10).describe("Máximo de resultados"),
  },
  async execute(args) {
    if (!TOKEN) {
      return "Error: La variable de entorno JOPLIN_TOKEN no está configurada. Consulta la sección de configuración en el HOWTO."
    }

    // 1. Obtener el ID de la libreta "WiKi_LLM"
    const foldersRes = await fetch(
      `${BASE}/folders?token=${TOKEN}&fields=id,title`
    )
    const foldersData = await foldersRes.json()
    const wikiFolder = foldersData.items.find((f: any) => f.title === "WiKi_LLM")
    if (!wikiFolder) {
      return "No se encontró la libreta 'WiKi_LLM'."
    }

    // 2. Buscar notas en toda la libreta (API search busca en todo, filtramos después)
    const searchRes = await fetch(
      `${BASE}/search?query=${encodeURIComponent(args.query)}&limit=${args.limit * 3}&token=${TOKEN}&fields=id,title,body,updated_time`
    )
    const searchData = await searchRes.json()

    // 3. Filtrar notas que pertenezcan a WiKi_LLM o sublibretas
    const allFolders = foldersData.items.map((f: any) => f.id)
    // Obtener IDs de sublibretas de WiKi_LLM
    const getSubfolderIds = async (parentId: string): Promise<string[]> => {
      const res = await fetch(
        `${BASE}/folders?token=${TOKEN}&fields=id,parent_id`
      )
      const data = await res.json()
      const children = data.items.filter((f: any) => f.parent_id === parentId)
      const descendants = await Promise.all(children.map((c: any) => getSubfolderIds(c.id)))
      return [parentId, ...children.map((c: any) => c.id), ...descendants.flat()]
    }
    const validFolderIds = await getSubfolderIds(wikiFolder.id)

    let notes = await Promise.all(
      searchData.items.map(async (note: any) => {
        // Verificar si la nota está en la libreta o sublibretas
        const noteRes = await fetch(
          `${BASE}/notes/${note.id}?token=${TOKEN}&fields=parent_id`
        )
        const noteData = await noteRes.json()
        if (!validFolderIds.includes(noteData.parent_id)) return null

        // Obtener etiquetas de la nota
        const tagsRes = await fetch(
          `${BASE}/notes/${note.id}/tags?token=${TOKEN}&fields=id,title`
        )
        const tagsData = await tagsRes.json()
        const tags = tagsData.items.map((t: any) => t.title)

        return {
          id: note.id,
          title: note.title,
          snippet: note.body?.substring(0, 200) || "",
          tags,
        }
      })
    )

    // Filtrar nulos y limitar
    notes = notes.filter(Boolean).slice(0, args.limit)

    // Si hay más de 5, priorizar por coincidencia de etiquetas
    if (notes.length > 5) {
      notes.sort((a: any, b: any) => b.tags.length - a.tags.length)
    }

    return JSON.stringify(notes, null, 2)
  },
})
