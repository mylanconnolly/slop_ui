import { supportsAnchor, positionFallback, whileOpen } from "../util.js"

/*
 * SlTooltip — shows a `popover="manual"` tooltip on hover and keyboard focus.
 * The trigger already carries aria-describedby, so screen readers get the
 * text whether or not the popover is visible. Escape dismisses (WCAG 1.4.13).
 */
export default {
  mounted() {
    this.tip = document.getElementById(this.el.getAttribute("aria-describedby"))
    if (!this.tip) return
    this.delay = Number(this.el.dataset.delay ?? 300)

    const show = () => {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => this.show(), this.delay)
    }
    const hide = () => {
      clearTimeout(this.timer)
      this.hide()
    }

    this.el.addEventListener("pointerenter", show)
    this.el.addEventListener("pointerleave", hide)
    this.el.addEventListener("focusin", show)
    this.el.addEventListener("focusout", hide)
    this.el.addEventListener("pointerdown", hide)
    this.onKey = (e) => e.key === "Escape" && hide()
    document.addEventListener("keydown", this.onKey)
  },

  show() {
    if (this.tip.matches(":popover-open")) return
    if (!supportsAnchor) {
      const ref = this.el.firstElementChild || this.el
      const placement = this.tip.dataset.placement || "top"
      this.stopFallback = whileOpen(() => positionFallback(ref, this.tip, placement, 8))
    }
    this.tip.showPopover()
  },

  hide() {
    if (!this.tip.matches(":popover-open")) return
    this.tip.hidePopover()
    this.stopFallback?.()
  },

  destroyed() {
    clearTimeout(this.timer)
    document.removeEventListener("keydown", this.onKey)
    this.stopFallback?.()
  },
}
