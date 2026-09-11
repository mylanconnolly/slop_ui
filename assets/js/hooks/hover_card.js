import { supportsAnchor, positionFallback, whileOpen } from "../util.js"

/*
 * SlHoverCard — opens a `popover="manual"` card after the trigger is hovered
 * or focused for `data-open-delay` ms, and closes it `data-close-delay` ms
 * after the pointer (or focus) has left both the trigger and the card.
 * Escape closes it. Touch pointers are ignored so a tap activates the
 * trigger instead of previewing it.
 */
export default {
  mounted() {
    this.card = document.getElementById(`${this.el.id}-card`)
    if (!this.card) return
    this.openDelay = Number(this.el.dataset.openDelay ?? 400)
    this.closeDelay = Number(this.el.dataset.closeDelay ?? 150)

    const pointer = (fn) => (e) => e.pointerType !== "touch" && fn()

    this.el.addEventListener("pointerenter", pointer(() => this.scheduleOpen()))
    this.el.addEventListener("pointerleave", pointer(() => this.scheduleClose()))
    this.card.addEventListener("pointerenter", pointer(() => this.cancel()))
    this.card.addEventListener("pointerleave", pointer(() => this.scheduleClose()))

    this.el.addEventListener("focusin", () => this.scheduleOpen())
    this.onFocusOut = (e) => {
      const to = e.relatedTarget
      if (to && (this.el.contains(to) || this.card.contains(to))) return
      this.scheduleClose()
    }
    this.el.addEventListener("focusout", this.onFocusOut)
    this.card.addEventListener("focusout", this.onFocusOut)

    // A click on the trigger navigates or acts; the preview would only get in the way.
    this.el.addEventListener("pointerdown", () => this.close())

    this.onKey = (e) => {
      if (e.key === "Escape" && this.card.matches(":popover-open")) {
        e.stopPropagation()
        this.close()
      }
    }
    document.addEventListener("keydown", this.onKey)
  },

  cancel() {
    clearTimeout(this.timer)
  },

  scheduleOpen() {
    this.cancel()
    if (this.card.matches(":popover-open")) return
    this.timer = setTimeout(() => this.open(), this.openDelay)
  },

  scheduleClose() {
    this.cancel()
    this.timer = setTimeout(() => this.close(), this.closeDelay)
  },

  open() {
    if (this.card.matches(":popover-open")) return
    if (!supportsAnchor) {
      const ref = this.el.firstElementChild || this.el
      const placement = this.card.dataset.placement || "bottom-start"
      this.stopFallback = whileOpen(() => positionFallback(ref, this.card, placement, 8))
    }
    this.card.showPopover()
  },

  close() {
    this.cancel()
    if (!this.card.matches(":popover-open")) return
    this.card.hidePopover()
    this.stopFallback?.()
  },

  destroyed() {
    this.cancel()
    document.removeEventListener("keydown", this.onKey)
    this.stopFallback?.()
  },
}
