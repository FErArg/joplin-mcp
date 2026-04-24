import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export const text = tool({
  description: "Busca notas por texto en el contenido/título. Devuelve id, título y snippet.",
  args: {
    query: tool.schema.string().describe("Término de búsqueda"),
    limit: tool.schema.number().optional().default(15).describe("Máx. resultados"),
  },
  async execute(args) {
    const res = await fetch(
      `${BASE}/search?query=${encodeURIComponent(args.query)}&limit=${args.limit}&token=${TOKEN}&fields=id,title,body`
    )
    const data = await res.json()
    return JSON.stringify(
      data.items.map((n: any) => ({
        id: n.id,
        title: n.title,
        snippet: n.body?.substring(0, 250) || "",
      }))
    )
  },
})

export const byTag = tool({
  description: "Busca todas las notas que tienen una etiqueta específica.",
  args: {
    tagId: tool.schema.string().describe("ID de la etiqueta"),
    limit: tool.schema.number().optional().default(20).describe("Máx. resultados"),
  },
  async execute(args) {
    const res = await fetch(
      `${BASE}/tags/${args.tagId}/notes?token=${TOKEN}&limit=${args.limit}&fields=id,title`
    )
    const data = await res.json()
    return JSON.stringify(data.items.map((n: any) => ({ id: n.id, title: n.title })))
  },
})

export const byNotebook = tool({
  description: "Busca notas dentro de una libreta específica.",
  args: {
    notebookId: tool.schema.string().describe("ID de la libreta"),
    limit: tool.schema.number().optional().default(20).describe("Máx. resultados"),
  },
  async execute(args) {
    const res = await fetch(
      `${BASE}/folders/${args.notebookId}/notes?token=${TOKEN}&limit=${args.limit}&fields=id,title`
    )
    const data = await res.json()
    return JSON.stringify(data.items.map((n: any) => ({ id: n.id, title: n.title })))
  },
})
