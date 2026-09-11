/* SlPassword — toggles a password input between hidden and shown. */
export default {
  mounted() {
    this.input = this.el.querySelector("input")
    this.btn = this.el.querySelector("[data-sl-reveal]")
    this.js().ignoreAttributes(this.input, "type")
    this.js().ignoreAttributes(this.btn, ["aria-pressed", "aria-label"])
    this.btn.addEventListener("click", () => {
      const show = this.input.type === "password"
      this.input.type = show ? "text" : "password"
      this.btn.setAttribute("aria-pressed", String(show))
      this.btn.setAttribute("aria-label", show ? this.el.dataset.labelHide : this.el.dataset.labelShow)
      this.el.querySelector('[data-when="hidden"]').hidden = show
      this.el.querySelector('[data-when="shown"]').hidden = !show
      this.input.focus()
    })
  },
}
