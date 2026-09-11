/* SlCopy — copies data-value or the target element's text; shows a copied state briefly. */
export default {
  mounted() {
    this.el.addEventListener("click", async () => {
      const target = this.el.dataset.target && document.querySelector(this.el.dataset.target)
      const text = this.el.dataset.value ?? (target ? target.value ?? target.textContent : "")
      try {
        await navigator.clipboard.writeText(text)
      } catch {
        return
      }
      const label = this.el.querySelector(".sl-copy-label")
      const original = label?.textContent
      const originalAria = this.el.getAttribute("aria-label")
      this.el.setAttribute("data-copied", "")
      if (label) label.textContent = this.el.dataset.copiedLabel
      else this.el.setAttribute("aria-label", this.el.dataset.copiedLabel)
      clearTimeout(this.timer)
      this.timer = setTimeout(() => {
        this.el.removeAttribute("data-copied")
        if (label) label.textContent = original
        else if (originalAria) this.el.setAttribute("aria-label", originalAria)
      }, 1500)
    })
  },
  destroyed() { clearTimeout(this.timer) },
}
