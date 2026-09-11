import { supportsAnchor, positionFallback, whileOpen } from "../util.js"
import { createMonthGrid, parseISO, ISO, today } from "../calendar.js"

/*
 * SlDatePicker — calendar popover over native date input(s).
 *
 * The inputs are the source of truth (typed entry, min/max, phx-change all
 * native). The hook renders the shared month grid, keeps it in sync with the
 * inputs, and writes selections back by setting input.value and firing
 * input/change. Range mode: first pick sets start, second sets end.
 */
export default {
  mounted() {
    this.inputs = [...this.el.querySelectorAll('input[type="date"]')]
    this.range = this.el.dataset.range !== undefined
    this.button = this.el.querySelector("[popovertarget]")
    this.cal = document.getElementById(this.button.getAttribute("popovertarget"))
    this.js().ignoreAttributes(this.button, "aria-expanded")

    const L = this.el.dataset
    this.grid = createMonthGrid(this.cal, {
      locale: L.locale,
      labels: { prev: L.labelPrev, next: L.labelNext, clear: L.labelClear, today: L.labelToday },
      range: this.range,
      values: () => [parseISO(this.inputs[0].value), this.range ? parseISO(this.inputs[1].value) : null],
      bounds: () => [parseISO(this.inputs[0].min), parseISO(this.inputs[this.range ? 1 : 0].max)],
      onSelect: ([a, b], done) => {
        if (this.inputs.some((input) => input.disabled || input.readOnly)) return
        this.setInput(this.inputs[0], a)
        if (this.range) this.setInput(this.inputs[1], b)
        if (done && (a || !this.range)) this.cal.hidePopover()
        else if (!a) this.grid.render()
      },
    })

    this.cal.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open") {
        this.grid.view = null
        this.grid.pending = null
        this.grid.focusIso = null
        this.grid.render()
        if (!supportsAnchor) this.stopFallback = whileOpen(() => positionFallback(this.el, this.cal, "bottom-start", 8))
      }
    })
    this.cal.addEventListener("toggle", (e) => {
      const open = e.newState === "open"
      this.js().setAttribute(this.button, "aria-expanded", String(open))
      if (open) this.grid.focusDay(parseISO(this.inputs[0].value) || today())
      else { this.stopFallback?.(); if (this.cal.contains(document.activeElement) || document.activeElement === document.body) this.button.focus() }
    })
    for (const input of this.inputs) input.addEventListener("input", () => this.isOpen() && this.grid.render())
  },

  updated() {
    if (this.isOpen()) this.grid.render()
  },

  destroyed() {
    this.stopFallback?.()
  },

  isOpen() { return this.cal.matches(":popover-open") },

  setInput(input, d) {
    if (input.disabled || input.readOnly) return
    input.value = d ? ISO(d) : ""
    input.dispatchEvent(new Event("input", { bubbles: true }))
    input.dispatchEvent(new Event("change", { bubbles: true }))
  },
}
