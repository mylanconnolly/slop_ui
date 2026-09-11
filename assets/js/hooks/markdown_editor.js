/*
 * SlMarkdownEditor — toolbar, shortcuts, list continuation, preview switch,
 * fullscreen, and image upload via paste/drop/button through a LiveView
 * file input inside the component.
 */
const LIST_RE = /^(\s*)([-*+]|\d+\.)(\s\[[ xX]\])?\s/

export default {
  mounted() {
    this.ta = this.el.querySelector("textarea")
    this.file = this.el.querySelector('input[type="file"]')
    this.count = this.el.querySelector("[data-sl-count]")
    this.js().ignoreAttributes(this.el, ["data-preview", "data-fullscreen", "data-dragging"])

    this.el.querySelector(".sl-md-toolbar").addEventListener("click", (e) => {
      const btn = e.target.closest("[data-sl-tool]")
      if (btn) { e.preventDefault(); this.apply(btn.dataset.slTool) }
      const fs = e.target.closest("[data-sl-fullscreen]")
      if (fs) this.toggleFullscreen()
    })
    this.el.querySelector(".sl-md-toolbar").addEventListener("keydown", (e) => this.toolbarKeys(e))
    this.el.querySelector(".sl-md-modes")?.addEventListener("click", (e) => {
      const tab = e.target.closest("[data-sl-mode]")
      if (tab) this.setMode(tab.dataset.slMode)
    })

    this.ta.addEventListener("keydown", (e) => this.onKeydown(e))
    this.ta.addEventListener("input", () => this.updateCount())
    this.ta.addEventListener("paste", (e) => {
      const files = [...(e.clipboardData?.files || [])].filter((f) => f.type.startsWith("image/"))
      if (files.length && this.file) { e.preventDefault(); this.attach(files) }
    })
    let depth = 0
    this.el.addEventListener("dragenter", (e) => { if (this.file && hasFiles(e)) { depth++; this.el.setAttribute("data-dragging", "") } })
    this.el.addEventListener("dragover", (e) => { if (this.file && hasFiles(e)) e.preventDefault() })
    this.el.addEventListener("dragleave", () => { if (--depth <= 0) { depth = 0; this.el.removeAttribute("data-dragging") } })
    this.el.addEventListener("drop", (e) => {
      depth = 0; this.el.removeAttribute("data-dragging")
      const files = [...(e.dataTransfer?.files || [])].filter((f) => f.type.startsWith("image/"))
      if (files.length && this.file) { e.preventDefault(); this.attach(files) }
    })
    this.file?.addEventListener("change", () => { if (this.file.files.length && !this.attaching) this.placeholders([...this.file.files]) })

    this.handleEvent("sl:markdown-image", ({ name, url, alt }) => this.resolve(name, `![${alt || name}](${url})`))
    this.handleEvent("sl:markdown-image-error", ({ name }) => this.resolve(name, ""))
    this.onEsc = (e) => e.key === "Escape" && this.el.hasAttribute("data-fullscreen") && this.toggleFullscreen()
    document.addEventListener("keydown", this.onEsc)
    this.updateCount()
  },

  destroyed() {
    document.removeEventListener("keydown", this.onEsc)
  },

  /* ---- modes & chrome ---- */
  setMode(mode) {
    const preview = mode === "preview"
    if (preview) this.ta.dispatchEvent(new Event("input", { bubbles: true })) // flush to the server
    preview ? this.el.setAttribute("data-preview", "") : this.el.removeAttribute("data-preview")
    for (const tab of this.el.querySelectorAll("[data-sl-mode]")) tab.setAttribute("aria-selected", String(tab.dataset.slMode === mode))
    if (!preview) this.ta.focus()
  },

  toggleFullscreen() {
    const on = !this.el.hasAttribute("data-fullscreen")
    on ? this.el.setAttribute("data-fullscreen", "") : this.el.removeAttribute("data-fullscreen")
    this.el.querySelector("[data-sl-fullscreen]")?.setAttribute("aria-pressed", String(on))
  },

  toolbarKeys(e) {
    const buttons = [...this.el.querySelectorAll('.sl-md-toolbar button:not([disabled])')]
    const i = buttons.indexOf(document.activeElement)
    if (i === -1) return
    if (e.key === "ArrowRight" || e.key === "ArrowLeft") {
      e.preventDefault()
      const next = buttons[(i + (e.key === "ArrowRight" ? 1 : -1) + buttons.length) % buttons.length]
      for (const b of buttons) b.tabIndex = -1
      next.tabIndex = 0
      next.focus()
    }
  },

  updateCount() {
    if (this.count) this.count.textContent = String(this.ta.value.length)
  },

  /* ---- text primitives (undo-friendly) ---- */
  sel() { return { start: this.ta.selectionStart, end: this.ta.selectionEnd, text: this.ta.value } },

  replace(start, end, text, selStart = null, selEnd = null) {
    this.ta.focus()
    this.ta.setSelectionRange(start, end)
    let ok = false
    try { ok = document.execCommand("insertText", false, text) } catch { ok = false }
    if (!ok) { this.ta.setRangeText(text, start, end, "end"); this.ta.dispatchEvent(new Event("input", { bubbles: true })) }
    const s = selStart ?? start + text.length, e = selEnd ?? s
    this.ta.setSelectionRange(s, e)
    this.updateCount()
  },

  wrap(before, after = before, placeholder = "") {
    const { start, end, text } = this.sel()
    const inner = text.slice(start, end)
    const b = start - before.length, a = end + after.length
    // Toggle off when already wrapped.
    if (b >= 0 && text.slice(b, start) === before && text.slice(end, a) === after) {
      return this.replace(b, a, inner, b, b + inner.length)
    }
    const body = inner || placeholder
    this.replace(start, end, before + body + after, start + before.length, start + before.length + body.length)
  },

  /* Apply/remove a prefix on every selected line; numbered lists count up. */
  prefixLines(makePrefix, matcher) {
    const { start, end, text } = this.sel()
    const ls = text.lastIndexOf("\n", start - 1) + 1
    const leEnd = text.indexOf("\n", end)
    const le = leEnd === -1 ? text.length : leEnd
    const lines = text.slice(ls, le).split("\n")
    const allHave = lines.every((l) => matcher.test(l))
    const out = lines.map((l, i) => (allHave ? l.replace(matcher, "") : makePrefix(i) + l.replace(LIST_RE, ""))).join("\n")
    this.replace(ls, le, out, ls, ls + out.length)
  },

  apply(tool) {
    switch (tool) {
      case "bold": return this.wrap("**", "**", "bold")
      case "italic": return this.wrap("_", "_", "italic")
      case "strike": return this.wrap("~~", "~~", "text")
      case "code": return this.wrap("`", "`", "code")
      case "heading": return this.prefixLines(() => "## ", /^#{1,6}\s/)
      case "quote": return this.prefixLines(() => "> ", /^>\s?/)
      case "ul": return this.prefixLines(() => "- ", /^\s*[-*+]\s(?!\[)/)
      case "ol": return this.prefixLines((i) => `${i + 1}. `, /^\s*\d+\.\s/)
      case "task": return this.prefixLines(() => "- [ ] ", /^\s*[-*+]\s\[[ xX]\]\s/)
      case "code_block": {
        const { start, end, text } = this.sel()
        const inner = text.slice(start, end) || "code"
        const nl = start > 0 && text[start - 1] !== "\n" ? "\n" : ""
        const block = `${nl}\`\`\`\n${inner}\n\`\`\`\n`
        return this.replace(start, end, block, start + nl.length + 4, start + nl.length + 4 + inner.length)
      }
      case "link": {
        const { start, end, text } = this.sel()
        const inner = text.slice(start, end)
        if (/^https?:\/\//.test(inner)) return this.replace(start, end, `[](${inner})`, start + 1, start + 1)
        const label = inner || "text"
        const out = `[${label}](url)`
        return this.replace(start, end, out, start + label.length + 3, start + label.length + 6)
      }
      case "image": return this.file ? this.file.click() : this.wrap("![", "](url)", "alt")
      case "table": {
        const { start, end } = this.sel()
        return this.replace(start, end, "\n| Column | Column |\n|---|---|\n| Cell | Cell |\n")
      }
      case "hr": {
        const { start, end } = this.sel()
        return this.replace(start, end, "\n---\n")
      }
    }
  },

  onKeydown(e) {
    const mod = e.metaKey || e.ctrlKey
    if (mod && !e.shiftKey && !e.altKey) {
      const map = { b: "bold", i: "italic", k: "link", e: "code" }
      const tool = map[e.key.toLowerCase()]
      if (tool) { e.preventDefault(); return this.apply(tool) }
    }
    if (e.key === "Enter" && !mod && !e.shiftKey) return this.continueList(e)
    if (e.key === "Tab" && !mod) return this.indent(e)
  },

  /* Enter inside a list item continues it; Enter on an empty item ends the list. */
  continueList(e) {
    const { start, end, text } = this.sel()
    if (start !== end) return
    const ls = text.lastIndexOf("\n", start - 1) + 1
    const line = text.slice(ls, start)
    const m = line.match(LIST_RE)
    if (!m) return
    e.preventDefault()
    if (line.trim() === m[0].trim()) return this.replace(ls, start, "") // empty item: leave the list
    const marker = /^\d+$/.test(m[2].replace(".", "")) ? `${parseInt(m[2]) + 1}.` : m[2]
    const task = m[3] ? " [ ]" : ""
    this.replace(start, end, `\n${m[1]}${marker}${task} `)
  },

  indent(e) {
    const { start, end, text } = this.sel()
    const ls = text.lastIndexOf("\n", start - 1) + 1
    if (!LIST_RE.test(text.slice(ls))) return
    e.preventDefault()
    if (e.shiftKey) {
      if (text.slice(ls, ls + 2) === "  ") this.replace(ls, ls + 2, "", Math.max(ls, start - 2), Math.max(ls, end - 2))
    } else {
      this.replace(ls, ls, "  ", start + 2, end + 2)
    }
  },

  /* ---- images ---- */
  attach(files) {
    const dt = new DataTransfer()
    for (const f of files) dt.items.add(f)
    this.attaching = true
    this.file.files = dt.files
    this.file.dispatchEvent(new Event("input", { bubbles: true }))
    this.file.dispatchEvent(new Event("change", { bubbles: true }))
    this.attaching = false
    this.placeholders(files)
  },

  placeholders(files) {
    const tmpl = this.el.dataset.labelUploading || "Uploading __NAME__…"
    const { start, end, text } = this.sel()
    const nl = start > 0 && text[start - 1] !== "\n" ? "\n" : ""
    const out = nl + files.map((f) => `![${tmpl.replace("__NAME__", f.name)}]()`).join("\n") + "\n"
    this.replace(start, end, out)
  },

  resolve(name, replacement) {
    const tmpl = this.el.dataset.labelUploading || "Uploading __NAME__…"
    const placeholder = `![${tmpl.replace("__NAME__", name)}]()`
    const at = this.ta.value.indexOf(placeholder)
    if (at === -1) return
    const { start, end } = this.sel()
    this.replace(at, at + placeholder.length, replacement)
    // Restore the caret if it was elsewhere.
    const delta = replacement.length - placeholder.length
    if (start > at + placeholder.length) this.ta.setSelectionRange(start + delta, end + delta)
  },
}

function hasFiles(e) {
  return [...(e.dataTransfer?.types || [])].includes("Files")
}
