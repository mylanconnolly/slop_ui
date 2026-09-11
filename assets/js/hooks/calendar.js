import { createMonthGrid, parseISO, ISO } from "../calendar.js"

/*
 * SlCalendar — inline month grid.
 *
 * Hidden input(s) inside the element hold the ISO value(s) and take part in
 * forms; picking a day updates them, fires input/change, and runs the
 * `data-on-change` JS command with phx-value-date / phx-value-end. When the
 * server re-renders new values the grid follows them.
 */
export default {
  mounted() {
    this.inputs = [...this.el.querySelectorAll('input[type="hidden"]')]
    this.range = this.el.dataset.range !== undefined
    this.body = this.el.querySelector(".sl-calendar-body")
    this.lastServer = this.serverValues()

    const L = this.el.dataset
    this.grid = createMonthGrid(this.body, {
      locale: L.locale,
      labels: { prev: L.labelPrev, next: L.labelNext, clear: L.labelClear, today: L.labelToday },
      range: this.range,
      footer: L.footer !== "false",
      values: () => [parseISO(this.inputs[0].value), this.range ? parseISO(this.inputs[1].value) : null],
      bounds: () => [parseISO(L.min), parseISO(L.max)],
      onSelect: ([a, b], done) => {
        this.setInput(this.inputs[0], a)
        if (this.range) this.setInput(this.inputs[1], b)
        this.grid.render()
        if (done) this.emit(a, b)
      },
    })
    this.grid.render()
  },

  updated() {
    // Adopt the server's values only when they changed; otherwise keep the client selection.
    const now = this.serverValues()
    if (now !== this.lastServer) {
      this.lastServer = now
      for (const [i, v] of now.split("|").entries()) if (this.inputs[i]) this.inputs[i].value = v
      this.grid.pending = null
    }
    this.grid.render()
  },

  serverValues() {
    return this.inputs.map((i) => i.getAttribute("value") || "").join("|")
  },

  setInput(input, d) {
    input.value = d ? ISO(d) : ""
    input.dispatchEvent(new Event("input", { bubbles: true }))
    input.dispatchEvent(new Event("change", { bubbles: true }))
  },

  emit(a, b) {
    const js = this.el.getAttribute("data-on-change")
    if (!js) return
    this.el.setAttribute("phx-value-date", a ? ISO(a) : "")
    if (this.range) this.el.setAttribute("phx-value-end", b ? ISO(b) : "")
    this.liveSocket.execJS(this.el, js)
  },
}
