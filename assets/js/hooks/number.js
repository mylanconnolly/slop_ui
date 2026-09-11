/* SlNumber — stepper buttons drive the native number input so min/max/step apply. */
export default {
  mounted() {
    this.input = this.el.querySelector('input[type="number"]')
    this.el.addEventListener("click", (e) => {
      const btn = e.target.closest("[data-sl-step]")
      if (!btn || this.input.disabled || this.input.readOnly) return
      try {
        btn.dataset.slStep === "up" ? this.input.stepUp() : this.input.stepDown()
      } catch {
        return
      }
      this.input.dispatchEvent(new Event("input", { bubbles: true }))
      this.input.dispatchEvent(new Event("change", { bubbles: true }))
      this.input.focus()
      this.bounds()
    })
    this.input.addEventListener("input", () => this.bounds())
    this.bounds()
  },
  updated() {
    this.bounds()
  },
  /* Mark the buttons disabled at the edges without removing them from the DOM. */
  bounds() {
    const v = this.input.value === "" ? null : Number(this.input.value)
    const min = this.input.min === "" ? -Infinity : Number(this.input.min)
    const max = this.input.max === "" ? Infinity : Number(this.input.max)
    const down = this.el.querySelector('[data-sl-step="down"]')
    const up = this.el.querySelector('[data-sl-step="up"]')
    if (down) down.setAttribute("aria-disabled", String(v !== null && v <= min))
    if (up) up.setAttribute("aria-disabled", String(v !== null && v >= max))
  },
}
