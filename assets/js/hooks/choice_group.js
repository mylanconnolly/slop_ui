/* A required checkbox group means at least one enabled choice, not every choice. */
export default {
  mounted() {
    this.onChange = () => this.sync()
    this.onReset = () => { clearTimeout(this.resetTimer); this.resetTimer = setTimeout(() => this.sync(), 0) }
    this.el.addEventListener("change", this.onChange)
    this.form = this.el.closest("form")
    this.form?.addEventListener("reset", this.onReset)
    this.sync()
  },
  updated() { this.sync() },
  sync() {
    const inputs = [...this.el.querySelectorAll('input[type="checkbox"]')]
    const enabled = inputs.filter((input) => !input.matches(":disabled"))
    const missing = this.el.hasAttribute("data-required") && !enabled.some((input) => input.checked)
    for (const input of inputs) input.required = missing && input === enabled[0]
  },
  destroyed() {
    clearTimeout(this.resetTimer)
    this.el.removeEventListener("change", this.onChange)
    this.form?.removeEventListener("reset", this.onReset)
  },
}
