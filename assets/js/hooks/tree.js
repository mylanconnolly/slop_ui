/*
 * SlTree — WAI-ARIA tree view.
 *
 * Rows (`[role="treeitem"]`) carry the state; a branch row is followed by a
 * `.sl-tree-children` wrapper holding its `[role="group"]`. The hook owns
 * expansion (aria-expanded), roving focus (tabindex) and, unless the tree is
 * server-controlled (`data-controlled="true"`), selection (aria-selected).
 *
 * Keyboard: ArrowUp/Down move, ArrowRight expands or enters a branch,
 * ArrowLeft collapses or goes to the parent, Home/End jump, `*` expands all
 * siblings, printable keys type-ahead, Enter/Space select (Enter also toggles
 * a branch or follows a link).
 */
export default {
  mounted() {
    this.controlled = this.el.dataset.controlled === "true"

    for (const row of this.rows()) {
      this.js().ignoreAttributes(row, this.controlled ? ["aria-expanded", "tabindex"] : ["aria-expanded", "tabindex", "aria-selected"])
    }

    if (this.el.dataset.expandedAll !== undefined) {
      for (const row of this.rows()) if (row.hasAttribute("aria-expanded")) row.setAttribute("aria-expanded", "true")
    }

    this.sync()

    this.el.addEventListener("click", (e) => {
      const row = e.target.closest('[role="treeitem"]')
      if (!row || !this.el.contains(row) || this.disabled(row)) return
      if (e.target.closest(".sl-tree-toggle")) {
        e.preventDefault()
        this.toggle(row)
        this.focusRow(row)
        return
      }
      if (this.isBranch(row) && !this.isLink(row)) this.toggle(row)
      this.select(row, { emit: true })
      this.focusRow(row)
    })

    this.el.addEventListener("keydown", (e) => this.onKeydown(e))

    // Clicking a row focuses it, so the roving tabindex follows the pointer.
    this.el.addEventListener("focusin", (e) => {
      const row = e.target.closest('[role="treeitem"]')
      if (row) this.setTabStop(row)
    })
  },

  updated() {
    this.sync()
  },

  sync() {
    this.annotate()
    if (this.controlled) {
      const value = this.el.dataset.selected
      for (const row of this.rows()) this.js().setAttribute(row, "aria-selected", String(row.dataset.value === value))
    }
    const current = this.rows().find((r) => r.tabIndex === 0)
    if (!current || !this.isVisible(current)) {
      const selected = this.rows().find((r) => r.getAttribute("aria-selected") === "true" && this.isVisible(r))
      this.setTabStop(selected || this.visibleRows()[0])
    }
  },

  rows() {
    return [...this.el.querySelectorAll('[role="treeitem"]')]
  },

  visibleRows() {
    return this.rows().filter((r) => this.isVisible(r))
  },

  isVisible(row) {
    let wrap = row.parentElement.closest(".sl-tree-children")
    while (wrap) {
      if (wrap.previousElementSibling?.getAttribute("aria-expanded") !== "true") return false
      wrap = wrap.parentElement.closest(".sl-tree-children")
    }
    return true
  },

  isBranch(row) {
    return row.hasAttribute("aria-expanded")
  },

  isLink(row) {
    return row.tagName === "A"
  },

  disabled(row) {
    return row.getAttribute("aria-disabled") === "true"
  },

  parentRow(row) {
    return row.parentElement.closest(".sl-tree-children")?.previousElementSibling || null
  },

  childRows(row) {
    const group = row.nextElementSibling?.querySelector(':scope > [role="group"]')
    return group ? [...group.querySelectorAll(':scope > li > [role="treeitem"]')] : []
  },

  siblingRows(row) {
    return [...row.parentElement.parentElement.querySelectorAll(':scope > li > [role="treeitem"]')]
  },

  /* aria-level / aria-setsize / aria-posinset for screen readers. */
  annotate() {
    const walk = (list, level) => {
      const rows = [...list.querySelectorAll(':scope > li > [role="treeitem"]')]
      rows.forEach((row, i) => {
        row.setAttribute("aria-level", level)
        row.setAttribute("aria-setsize", rows.length)
        row.setAttribute("aria-posinset", i + 1)
        const group = row.nextElementSibling?.querySelector(':scope > [role="group"]')
        if (group) walk(group, level + 1)
      })
    }
    walk(this.el, 1)
  },

  setTabStop(row) {
    if (!row) return
    for (const r of this.rows()) r.tabIndex = -1
    row.tabIndex = 0
  },

  focusRow(row) {
    if (!row) return
    this.setTabStop(row)
    row.focus()
  },

  expand(row, open) {
    if (!this.isBranch(row)) return
    this.js().setAttribute(row, "aria-expanded", String(open))
  },

  toggle(row) {
    this.expand(row, row.getAttribute("aria-expanded") !== "true")
  },

  select(row, { emit }) {
    if (this.disabled(row)) return
    if (!this.controlled) {
      for (const r of this.rows()) this.js().setAttribute(r, "aria-selected", String(r === row))
    }
    if (emit) {
      const onSelect = this.el.getAttribute("data-on-select")
      if (onSelect) this.liveSocket.execJS(row, onSelect, "click")
    }
  },

  onKeydown(e) {
    const row = e.target.closest('[role="treeitem"]')
    if (!row || e.altKey || e.ctrlKey || e.metaKey) return
    const rows = this.visibleRows()
    const i = rows.indexOf(row)

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault()
        this.focusRow(rows[Math.min(i + 1, rows.length - 1)])
        break
      case "ArrowUp":
        e.preventDefault()
        this.focusRow(rows[Math.max(i - 1, 0)])
        break
      case "ArrowRight":
        e.preventDefault()
        if (!this.isBranch(row)) return
        if (row.getAttribute("aria-expanded") === "true") this.focusRow(this.childRows(row)[0])
        else this.expand(row, true)
        break
      case "ArrowLeft":
        e.preventDefault()
        if (row.getAttribute("aria-expanded") === "true") this.expand(row, false)
        else this.focusRow(this.parentRow(row))
        break
      case "Home":
        e.preventDefault()
        this.focusRow(rows[0])
        break
      case "End":
        e.preventDefault()
        this.focusRow(rows.at(-1))
        break
      case "*":
        e.preventDefault()
        for (const s of this.siblingRows(row)) this.expand(s, true)
        break
      case " ":
        e.preventDefault()
        this.select(row, { emit: true })
        break
      case "Enter":
        if (this.disabled(row)) { e.preventDefault(); return }
        if (this.isLink(row)) { this.select(row, { emit: true }); return } // native navigation
        e.preventDefault()
        if (this.isBranch(row)) this.toggle(row)
        this.select(row, { emit: true })
        break
      default:
        if (e.key.length === 1 && e.key !== " ") this.typeahead(e.key, rows, i)
    }
  },

  typeahead(char, rows, from) {
    clearTimeout(this.typeTimer)
    this.typed = (this.typed || "") + char.toLowerCase()
    this.typeTimer = setTimeout(() => (this.typed = ""), 500)
    const ordered = [...rows.slice(from + 1), ...rows.slice(0, from + 1)]
    const label = (r) => (r.querySelector(".sl-tree-label") || r).textContent.trim().toLowerCase()
    const match = ordered.find((r) => label(r).startsWith(this.typed))
    if (match) this.focusRow(match)
  },
}
