import { tool } from "@opencode-ai/plugin"

const BASE = "http://localhost:41184"
const TOKEN = process.env.JOPLIN_TOKEN
if (!TOKEN) throw new Error("JOPLIN_TOKEN no configurado")

// Helper para peticiones GET
async function apiGet(endpoint: string) {
  const res = await fetch(`${BASE}${endpoint}&token=${TOKEN}`)
  if (!res.ok) throw new Error(`GET ${endpoint} falló: ${res.status}`)
  return res.json()
}

// Helper para peticiones POST/PUT
async function apiPost(endpoint: string, body: any, method = "POST") {
  const res = await fetch(`${BASE}${endpoint}&token=${TOKEN}`, {
    method,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  })
  if (!res.ok) throw new Error(`${method} ${endpoint} falló: ${res.status}`)
  return res.json()
}

// Obtener sublibretas recursivamente
async function getSubtree(folderId: string): Promise<string[]> {
  const data = await apiGet(`/folders?fields=id,parent_id`)
  const children = data.items.filter((f: any) => f.parent_id === folderId)
  const descendants = await Promise.all(children.map((c: any) => getSubtree(c.id)))
  return [folderId, ...children.map((c: any) => c.id), ...descendants.flat()]
}

export default tool({
  description: `Ejecuta el proceso completo de ingestación y reestructuración de notas en WiKi_LLM/Documentación. 
  1. Obtiene árbol de libretas. 
  2. Lista notas sin procesar (sin etiqueta #ingested ni #procesado). 
  3. Para cada nota: lee, añade etiquetas de metadatos, divide si >1000 palabras, marca procesado, registra en log.
  4. Devuelve resumen.`,
  args: {},
  async execute() {
    const log: string[] = []
    let totalEncontradas = 0
    let saltadas = 0
    let procesadas = 0
    let hijasCreadas = 0
    const errores: string[] = []

    try {
      // 1. Obtener el árbol de libretas
      const foldersData = await apiGet(`/folders?fields=id,title,parent_id`)
      const wikiFolder = foldersData.items.find((f: any) => f.title === "WiKi_LLM")
      if (!wikiFolder) return "No se encontró la libreta WiKi_LLM."

      // Buscar "Documentación" dentro de WiKi_LLM
      const docFolder = foldersData.items.find(
        (f: any) => f.title === "Documentación" && f.parent_id === wikiFolder.id
      )
      if (!docFolder) return "No se encontró la libreta Documentación dentro de WiKi_LLM."

      const docTree = await getSubtree(docFolder.id)

      // 2. Listar notas sin procesar de todas las libretas del árbol
      for (const folderId of docTree) {
        const notesData = await apiGet(
          `/folders/${folderId}/notes?fields=id,title,body&limit=100`
        )
        totalEncontradas += notesData.items.length

        for (const note of notesData.items) {
          // Leer etiquetas de la nota
          const tagsRes = await apiGet(`/notes/${note.id}/tags?fields=title`)
          const tags = tagsRes.items.map((t: any) => t.title)

          // Saltar si tiene #ingested o #procesado
          if (tags.includes("#ingested") || tags.includes("#procesado")) {
            saltadas++
            continue
          }

          // 3. Procesar nota
          try {
            // 3.1 Leer nota completa (ya tenemos title y body)
            const noteFull = await apiGet(`/notes/${note.id}?fields=id,title,body,parent_id`)

            // 3.2 Añadir etiquetas de metadatos
            const resumenTag = `resumen:${noteFull.body?.substring(0, 200).replace(/\n/g, " ").trim().substring(0, 60)}`
            const fecha = new Date().toISOString().split("T")[0]
            await apiPost(`/notes/${note.id}/tags`, { title: resumenTag })
            await apiPost(`/notes/${note.id}/tags`, { title: "fuente:Documentación" })
            await apiPost(`/notes/${note.id}/tags`, { title: `fecha:${fecha}` })

            const hijasIds: string[] = []

            // 3.3 Dividir si >1000 palabras
            const wordCount = noteFull.body?.split(/\s+/).length || 0
            if (wordCount > 1000) {
              // Dividir en chunks semánticos (por simplicidad, cada ~800 palabras)
              const words = noteFull.body?.split(/\s+/) || []
              const chunkSize = 800
              for (let i = 0; i < words.length; i += chunkSize) {
                const chunk = words.slice(i, i + chunkSize).join(" ")
                const hija = await apiPost(`/notes`, {
                  title: `${noteFull.title} - parte ${Math.floor(i / chunkSize) + 1}`,
                  body: chunk,
                  parent_id: noteFull.parent_id,
                })
                hijasIds.push(hija.id)
                hijasCreadas++

                // Añadir etiquetas a la hija
                await apiPost(`/notes/${hija.id}/tags`, { title: `Padre:${noteFull.id}` })
                await apiPost(`/notes/${hija.id}/tags`, { title: `resumen:${chunk.substring(0, 200).replace(/\n/g, " ").substring(0, 60)}` })
                await apiPost(`/notes/${hija.id}/tags`, { title: "fuente:Documentación" })
                await apiPost(`/notes/${hija.id}/tags`, { title: `fecha:${fecha}` })
                await apiPost(`/notes/${hija.id}/tags`, { title: "#procesado" })
              }

              // Añadir etiqueta hijas a la original
              await apiPost(`/notes/${note.id}/tags`, { title: `hijas:${hijasIds.join(",")}` })
            }

            // 3.4 Marcar como procesada
            await apiPost(`/notes/${note.id}/tags`, { title: "#procesado" })

            // 3.5 Registrar en log
            const logRes = await apiGet(`/search?query=Log&fields=id,title,body`)
            const logNote = logRes.items.find((n: any) =>
              n.title === "Log" && n.body?.includes("Wiki_LLM/Logs/Log.md")
            )
            if (logNote) {
              const logEntry = `${fecha} | refactor | Nota ${note.title} procesada | :/${note.id}\n`
              await apiPost(`/notes/${logNote.id}`, {
                body: (logNote.body || "") + logEntry,
              }, "PUT")
            }

            procesadas++
          } catch (err: any) {
            errores.push(`Error procesando nota ${note.id} (${note.title}): ${err.message}`)
          }
        }
      }

      // 4. Resumen
      return [
        "## Resumen de ingestación",
        `- Total notas encontradas: ${totalEncontradas}`,
        `- Notas saltadas (ya procesadas): ${saltadas}`,
        `- Notas procesadas: ${procesadas}`,
        `- Notas hijas creadas: ${hijasCreadas}`,
        errores.length ? `- Errores: ${errores.length}` : "",
        ...errores.map(e => `  - ${e}`),
      ].join("\n")
    } catch (err: any) {
      return `Error general: ${err.message}`
    }
  },
})
