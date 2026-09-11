/*
 * SlAccordion — keyboard movement between <details> headers
 * (WAI-ARIA accordion pattern). Toggling stays native.
 */
export default {
  mounted() {
    this.el.addEventListener("keydown", (e) => {
      if (!e.target.matches(".sl-accordion-trigger")) return
      const triggers = [...this.el.querySelectorAll(":scope > .sl-accordion-item > .sl-accordion-trigger")]
      const i = triggers.indexOf(e.target)
      let target
      if (e.key === "ArrowDown") target = triggers[(i + 1) % triggers.length]
      else if (e.key === "ArrowUp") target = triggers[(i - 1 + triggers.length) % triggers.length]
      else if (e.key === "Home") target = triggers[0]
      else if (e.key === "End") target = triggers.at(-1)
      else return
      e.preventDefault()
      target.focus()
    })
  },
}
