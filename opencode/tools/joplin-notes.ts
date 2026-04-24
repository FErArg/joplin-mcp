import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export const create = tool({
  description: "Crea una nueva nota en Joplin. Opcionalmente asigna a una libreta.",
  args: {
    title: tool.schema.string().describe("Título de la nota"),
    body: tool.schema.string().describe("Contenido en Markdown"),
    notebookId: tool.schema.string().optional().describe("ID de la libreta destino"),
  },
  async execute(args) {
    const payload: any = { title: args.title, body: args.body }
    if (args.notebookId) payload.parent_id = args.notebookId
    const res = await fetch(`${BASE}/notes?token=${TOKEN}`, {
      method: "POST",
      body: JSON.stringify(payload),
      headers: { "Content-Type": "application/json" },
    })
    const data = await res.json()
    return JSON.stringify({ id: data.id, title: data.title })
  },
})

export const update = tool({
  description: "Actualiza el título y/o cuerpo de una nota existente.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota"),
    title: tool.schema.string().optional().describe("Nuevo título"),
    body: tool.schema.string().optional().describe("Nuevo contenido Markdown"),
  },
  async execute(args) {
    const payload: any = {}
    if (args.title) payload.title = args.title
    if (args.body) payload.body = args.body
    const res = await fetch(`${BASE}/notes/${args.noteId}?token=${TOKEN}`, {
      method: "PUT",
      body: JSON.stringify(payload),
      headers: { "Content-Type": "application/json" },
    })
    const data = await res.json()
    return JSON.stringify({ id: data.id, title: data.title, updated: data.updated_time })
  },
})

export const deleteNote = tool({
  description: "Elimina una nota de Joplin permanentemente.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota a eliminar"),
  },
  async execute(args) {
    await fetch(`${BASE}/notes/${args.noteId}?token=${TOKEN}`, { method: "DELETE" })
    return `Nota ${args.noteId} eliminada correctamente.`
  },
})
