import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN

export const list = tool({
  description: "Lista todas las etiquetas de Joplin. Devuelve id y título.",
  args: {},
  async execute() {
    const res = await fetch(`${BASE}/tags?token=${TOKEN}&fields=id,title`)
    const data = await res.json()
    return JSON.stringify(data.items.map((t: any) => ({ id: t.id, title: t.title })))
  },
})

export const create = tool({
  description: "Crea una nueva etiqueta en Joplin.",
  args: {
    title: tool.schema.string().describe("Nombre de la etiqueta"),
  },
  async execute(args) {
    const res = await fetch(`${BASE}/tags?token=${TOKEN}`, {
      method: "POST",
      body: JSON.stringify({ title: args.title }),
      headers: { "Content-Type": "application/json" },
    })
    const data = await res.json()
    return JSON.stringify({ id: data.id, title: data.title })
  },
})

export const deleteTag = tool({
  description: "Elimina una etiqueta de Joplin por su ID.",
  args: {
    tagId: tool.schema.string().describe("ID de la etiqueta a eliminar"),
  },
  async execute(args) {
    await fetch(`${BASE}/tags/${args.tagId}?token=${TOKEN}`, { method: "DELETE" })
    return `Etiqueta ${args.tagId} eliminada correctamente.`
  },
})
