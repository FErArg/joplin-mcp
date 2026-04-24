import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Obtener todas las notas de una libreta específica.",
  args: {
    notebookId: tool.schema.string().describe("ID de la libreta"),
  },
  async execute(args) {
    const res = await fetch(
      `http://localhost:41184/folders/${args.notebookId}/notes?token=${process.env.JOPLIN_TOKEN}&fields=id,title`
    )
    const data = await res.json()
    return JSON.stringify(data.items.map((n: any) => ({ id: n.id, title: n.title })))
  },
})
