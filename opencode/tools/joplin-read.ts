import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Obtener el contenido completo de una nota de Joplin por su ID.",
  args: {
    noteId: tool.schema.string().describe("ID de la nota en Joplin"),
  },
  async execute(args) {
    const res = await fetch(
      `http://localhost:41184/notes/${args.noteId}?token=${process.env.JOPLIN_TOKEN}&fields=id,title,body,updated_time`
    )
    const note = await res.json()
    return `# ${note.title}\n\n${note.body}\n\n*(Actualizada: ${new Date(note.updated_time * 1000).toISOString()})*`
  },
})
