/* SlTagInput — free-form chips; each tag is a hidden name[] input for the form. */

import { svg as glyph, X_MARK } from "../icons.js"
export default {
  mounted() {
    this.input = this.el.querySelector('input[type="text"]')
    this.name = this.el.dataset.name
    this.max = this.el.dataset.max ? Number(this.el.dataset.max) : Infinity

    this.el.addEventListener("click", (e) => {
      const remove = e.target.closest("[data-sl-remove]")
      if (remove) return this.remove(remove.closest(".sl-chip"))
      if (e.target === this.el) this.input.focus()
    })
    this.input.addEventListener("keydown", (e) => {
      if ((e.key === "Enter" || e.key === ",") && this.input.value.trim()) { e.preventDefault(); this.add(this.input.value) }
      else if (e.key === "Tab" && this.input.value.trim()) { this.add(this.input.value) }
      else if (e.key === "Backspace" && !this.input.value) { const last = this.chips().at(-1); if (last) this.remove(last) }
    })
    this.input.addEventListener("blur", () => { if (this.input.value.trim()) this.add(this.input.value) })
    this.input.addEventListener("paste", (e) => {
      const text = (e.clipboardData || window.clipboardData).getData("text")
      if (text && /[,\n]/.test(text)) { e.preventDefault(); text.split(/[,\n]/).forEach((t) => this.add(t)) }
    })
  },

  chips() { return [...this.el.querySelectorAll(".sl-chip")] },
  values() { return this.chips().map((c) => c.dataset.value) },

  add(raw) {
    const value = raw.trim()
    this.input.value = ""
    if (!value || this.values().includes(value) || this.chips().length >= this.max) return
    const chip = document.createElement("span")
    chip.className = "sl-chip"
    chip.dataset.value = value
    chip.append(value)
    const hidden = Object.assign(document.createElement("input"), { type: "hidden", name: this.name, value })
    const btn = document.createElement("button")
    btn.type = "button"; btn.tabIndex = -1; btn.dataset.slRemove = value
    btn.setAttribute("aria-label", (this.el.dataset.labelRemove || "Remove __LABEL__").replace("__LABEL__", value))
    btn.innerHTML = glyph(X_MARK)
    chip.append(hidden, btn)
    this.input.before(chip)
    this.notify()
  },

  remove(chip) {
    chip.remove()
    this.input.focus()
    this.notify()
  },

  /* LiveView only reacts to events from form controls, so fire them on the sentinel input. */
  notify() {
    const sentinel = this.el.querySelector('input[type="hidden"]')
    sentinel.dispatchEvent(new Event("input", { bubbles: true }))
    sentinel.dispatchEvent(new Event("change", { bubbles: true }))
  },
}
