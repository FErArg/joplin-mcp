import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Listar todas las libretas (notebooks) de Joplin.",
  args: {},
  async execute() {
    const res = await fetch(
      `http://localhost:41184/folders?token=${process.env.JOPLIN_TOKEN}&fields=id,title`
    )
    const data = await res.json()
    return JSON.stringify(data.items.map((f: any) => ({ id: f.id, title: f.title })))
  },
})
