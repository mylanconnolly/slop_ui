/* SlPinInput — one box per character; combined value lives in the hidden input. */
export default {
  mounted() {
    this.hidden = this.el.querySelector('input[type="hidden"]')
    this.boxes = [...this.el.querySelectorAll('input:not([type="hidden"])')]
    this.numeric = this.el.dataset.type === "numeric"

    this.boxes.forEach((box, i) => {
      box.addEventListener("input", () => {
        let v = box.value.replace(this.numeric ? /\D/g : /[^a-zA-Z0-9]/g, "")
        if (v.length > 1) return this.fill(v, i)
        box.value = v
        if (v && i < this.boxes.length - 1) this.boxes[i + 1].focus()
        this.commit()
      })
      box.addEventListener("keydown", (e) => {
        if (e.key === "Backspace" && !box.value && i > 0) { e.preventDefault(); this.boxes[i - 1].value = ""; this.boxes[i - 1].focus(); this.commit() }
        else if (e.key === "ArrowLeft" && i > 0) { e.preventDefault(); this.boxes[i - 1].focus() }
        else if (e.key === "ArrowRight" && i < this.boxes.length - 1) { e.preventDefault(); this.boxes[i + 1].focus() }
      })
      box.addEventListener("focus", () => box.select())
      box.addEventListener("paste", (e) => {
        const text = (e.clipboardData || window.clipboardData).getData("text")
        if (text) { e.preventDefault(); this.fill(text, i) }
      })
    })
  },

  /* Distribute a string across boxes starting at index `from`. */
  fill(text, from) {
    const chars = text.replace(this.numeric ? /\D/g : /[^a-zA-Z0-9]/g, "").split("")
    let i = from
    for (const c of chars) { if (i >= this.boxes.length) break; this.boxes[i++].value = c }
    this.boxes[Math.min(i, this.boxes.length - 1)].focus()
    this.commit()
  },

  commit() {
    const value = this.boxes.map((b) => b.value).join("")
    if (this.hidden.value === value) return
    this.hidden.value = value
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }))
    this.hidden.dispatchEvent(new Event("change", { bubbles: true }))
    if (value.length === this.boxes.length) this.el.dispatchEvent(new CustomEvent("sl:pin:complete", { bubbles: true, detail: { value } }))
  },
}
