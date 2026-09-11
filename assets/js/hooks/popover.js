import { supportsAnchor, positionFallback, whileOpen } from "../util.js"

/*
 * SlPopover — anchored panel. The popover API handles top layer, light
 * dismiss and Escape; anchor positioning handles placement. This hook keeps
 * aria-expanded in sync, moves focus into the panel, and returns it.
 */
export default {
  mounted() {
    this.trigger = this.el.querySelector("[popovertarget]")
    this.panel = this.el.querySelector("[popover]")
    if (!this.trigger || !this.panel) return
    this.js().ignoreAttributes(this.trigger, "aria-expanded")

    this.panel.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open" && !supportsAnchor) {
        this.stopFallback = whileOpen(() => positionFallback(this.trigger, this.panel, this.panel.dataset.placement || "bottom-start", 8))
      }
    })
    this.panel.addEventListener("toggle", (e) => {
      const open = e.newState === "open"
      this.js().setAttribute(this.trigger, "aria-expanded", String(open))
      if (open) {
        const first = this.panel.querySelector('a[href], button:not([disabled]), input:not([disabled]), select, textarea, [tabindex]:not([tabindex="-1"])')
        ;(first || this.panel).focus({ preventScroll: true })
      } else {
        this.stopFallback?.()
        if (this.panel.contains(document.activeElement) || document.activeElement === document.body) this.trigger.focus()
      }
    })
    // Manual popovers (dismissable={false}) still close on Escape from inside.
    this.panel.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && this.panel.getAttribute("popover") === "manual") this.panel.hidePopover()
    })
  },

  destroyed() {
    this.stopFallback?.()
  },
}
