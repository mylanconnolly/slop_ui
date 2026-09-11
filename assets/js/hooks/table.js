/*
 * SlTable — row selection for tables rendered with `selectable`.
 *
 * Checkboxes are the source of truth (they carry `name` for forms and the
 * server renders `checked` from `selected`). The hook keeps the header
 * checkbox (all / some / none, `indeterminate`) and each row's aria-selected
 * in step, supports Shift+click ranges, and runs `data-on-select` with
 * phx-value-id / phx-value-ids / phx-value-all plus phx-value-selected.
 */
export default {
  mounted() {
    this.el.addEventListener("change", (e) => {
      const box = e.target
      if (!box.matches(".sl-table-select")) return
      if (box.dataset.all !== undefined) return this.selectAll(box.checked)
      this.rowChanged(box, e)
    })
    this.el.addEventListener("click", (e) => {
      const box = e.target
      if (!box.matches?.(".sl-table-select")) return
      if (box.dataset.all === undefined) this.shift = e.shiftKey
      // Don't let a checkbox click count as a row click (phx-click on the <tr>).
      e.stopPropagation()
    })
    this.sync()
  },

  updated() {
    this.sync()
  },

  boxes() {
    return [...this.el.querySelectorAll("tbody .sl-table-select")]
  },

  header() {
    return this.el.querySelector("thead .sl-table-select")
  },

  sync() {
    const boxes = this.boxes()
    for (const b of boxes) this.mark(b)
    const head = this.header()
    if (!head) return
    const on = boxes.filter((b) => b.checked).length
    head.checked = boxes.length > 0 && on === boxes.length
    head.indeterminate = on > 0 && on < boxes.length
  },

  mark(box) {
    const row = box.closest("tr")
    if (row) this.js().setAttribute(row, "aria-selected", String(box.checked))
  },

  rowChanged(box, e) {
    const boxes = this.boxes()
    let changed = [box]
    if (this.shift && this.last && this.last !== box && boxes.includes(this.last)) {
      const [a, b] = [boxes.indexOf(this.last), boxes.indexOf(box)].sort((x, y) => x - y)
      changed = boxes.slice(a, b + 1)
      for (const other of changed) other.checked = box.checked
    }
    this.shift = false
    this.last = box
    this.sync()
    if (changed.length === 1) this.emit(box, { id: box.value, selected: box.checked })
    else this.emit(box, { ids: changed.map((c) => c.value).join(","), selected: box.checked })
  },

  selectAll(checked) {
    for (const b of this.boxes()) if (!b.disabled) b.checked = checked
    this.sync()
    this.emit(this.header(), { all: "true", selected: checked })
  },

  emit(el, values) {
    const js = this.el.getAttribute("data-on-select")
    if (!js) return
    for (const k of ["id", "ids", "all"]) el.removeAttribute(`phx-value-${k}`)
    for (const [k, v] of Object.entries(values)) el.setAttribute(`phx-value-${k}`, String(v))
    this.liveSocket.execJS(el, js)
  },
}
