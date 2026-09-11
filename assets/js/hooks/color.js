/*
 * SlColor — mirrors a native color input into its readout and preset swatches.
 *
 * The input is the source of truth: picking a preset writes its value and
 * dispatches input/change so LiveView and the form see a normal change.
 */
export default {
  mounted() {
    this.input = this.el.querySelector('input[type="color"]')
    this.output = this.el.querySelector("output")
    this.presets = [...this.el.querySelectorAll('[role="radio"]')]
    for (const p of this.presets) this.js().ignoreAttributes(p, ["aria-checked", "tabindex"])

    this.input.addEventListener("input", () => this.sync())
    for (const p of this.presets) {
      p.addEventListener("click", () => this.pick(p))
      p.addEventListener("keydown", (e) => this.onKeydown(e, p))
    }
    this.sync()
  },

  updated() {
    this.sync()
  },

  sync() {
    const value = this.input.value.toLowerCase()
    if (this.output) this.output.value = value
    let any = false
    for (const p of this.presets) {
      const on = p.dataset.value === value
      any ||= on
      p.setAttribute("aria-checked", String(on))
      p.setAttribute("tabindex", on ? "0" : "-1")
    }
    // Nothing checked: the first swatch stays reachable.
    if (!any && this.presets[0]) this.presets[0].setAttribute("tabindex", "0")
  },

  pick(p) {
    if (p.disabled) return
    this.input.value = p.dataset.value
    this.input.dispatchEvent(new Event("input", { bubbles: true }))
    this.input.dispatchEvent(new Event("change", { bubbles: true }))
    this.sync()
    p.focus()
  },

  onKeydown(e, p) {
    const i = this.presets.indexOf(p)
    const n = this.presets.length
    let target
    if (e.key === "ArrowRight" || e.key === "ArrowDown") target = this.presets[(i + 1) % n]
    else if (e.key === "ArrowLeft" || e.key === "ArrowUp") target = this.presets[(i - 1 + n) % n]
    else if (e.key === "Home") target = this.presets[0]
    else if (e.key === "End") target = this.presets[n - 1]
    else if (e.key === " " || e.key === "Enter") target = p
    else return
    e.preventDefault()
    this.pick(target)
  },
}
