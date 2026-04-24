import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export const add = tool({
  description: "Asigna una etiqueta existente a una nota existente.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota"),
    tagId: tool.schema.string().describe("ID de la etiqueta"),
  },
  async execute(args) {
    const res = await fetch(
      `${BASE}/notes/${args.noteId}/tags?token=${TOKEN}`,
      {
        method: "POST",
        body: JSON.stringify({ id: args.tagId }),
        headers: { "Content-Type": "application/json" },
      }
    )
    if (!res.ok) {
      const error = await res.text()
      return `Error al asignar etiqueta: ${error}`
    }
    return `Etiqueta ${args.tagId} asignada a nota ${args.noteId}.`
  },
})

export const remove = tool({
  description: "Desasigna una etiqueta de una nota.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota"),
    tagId: tool.schema.string().describe("ID de la etiqueta"),
  },
  async execute(args) {
    await fetch(
      `${BASE}/notes/${args.noteId}/tags/${args.tagId}?token=${TOKEN}`,
      { method: "DELETE" }
    )
    return `Etiqueta ${args.tagId} desasignada de nota ${args.noteId}.`
  },
})

export const listTagsOfNote = tool({
  description: "Obtiene todas las etiquetas asignadas a una nota.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota"),
  },
  async execute(args) {
    const res = await fetch(
      `${BASE}/notes/${args.noteId}/tags?token=${TOKEN}&fields=id,title`
    )
    const data = await res.json()
    return JSON.stringify(data.items.map((t: any) => ({ id: t.id, title: t.title })))
  },
})
