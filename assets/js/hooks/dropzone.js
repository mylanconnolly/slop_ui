/*
 * SlDropzone — LiveView handles the drop itself (phx-drop-target). This hook
 * adds the drag-over styling and makes the whole zone clickable.
 */
export default {
  mounted() {
    this.input = this.el.querySelector('input[type="file"]')
    let depth = 0
    this.el.addEventListener("dragenter", () => { depth++; this.el.setAttribute("data-dragging", "") })
    this.el.addEventListener("dragleave", () => { if (--depth <= 0) { depth = 0; this.el.removeAttribute("data-dragging") } })
    this.el.addEventListener("drop", () => { depth = 0; this.el.removeAttribute("data-dragging") })
    this.el.addEventListener("click", (e) => {
      // The browse label and the input open the picker natively.
      if (e.target.closest("label, input")) return
      this.input?.click()
    })
  },
}
