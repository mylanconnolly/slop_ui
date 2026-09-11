/*
 * SlToaster — manages the toast region.
 *
 * Toasts arrive three ways: rendered by the server (flash), pushed with
 * `push_event(socket, "sl:toast", %{...})`, or raised on the client with
 * `window.dispatchEvent(new CustomEvent("sl:toast", {detail}))`.
 *
 * Each toast auto-dismisses after its `data-duration` (or the region's
 * default), pausing while hovered or focused. Dismissal runs the toast's
 * `data-on-dismiss` JS command (flash toasts use it to clear the flash), then
 * removes client-created toasts from the DOM.
 */

import { svg as glyph, X_MARK } from "../icons.js"
import { statusIcon } from "../status_icons.js"

export default {
  mounted() {
    this.timers = new Map()
    this.observe()

    this.el.addEventListener("click", (e) => {
      const btn = e.target.closest("[data-sl-dismiss]")
      if (btn) this.dismiss(btn.closest(".sl-toast"))
    })
    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        const toast = e.target.closest(".sl-toast")
        if (toast) this.dismiss(toast)
      }
    })
    this.el.addEventListener("pointerenter", (e) => this.pause(e.target.closest?.(".sl-toast")), true)
    this.el.addEventListener("pointerleave", (e) => this.resume(e.target.closest?.(".sl-toast")), true)
    this.el.addEventListener("focusin", (e) => this.pause(e.target.closest(".sl-toast")))
    this.el.addEventListener("focusout", (e) => this.resume(e.target.closest(".sl-toast")))

    this.handleEvent("sl:toast", (detail) => this.add(detail))
    this.onWindowToast = (e) => this.add(e.detail || {})
    window.addEventListener("sl:toast", this.onWindowToast)

    for (const toast of this.el.querySelectorAll(".sl-toast")) this.arm(toast)
  },

  updated() {
    for (const toast of this.el.querySelectorAll(".sl-toast")) this.arm(toast)
  },

  destroyed() {
    window.removeEventListener("sl:toast", this.onWindowToast)
    this.observer?.disconnect()
    for (const t of this.timers.values()) clearTimeout(t.id)
  },

  /* Watch for removed toasts to clean up their timers. */
  observe() {
    this.observer = new MutationObserver((records) => {
      for (const r of records) for (const n of r.removedNodes) this.timers.delete(n)
    })
    this.observer.observe(this.el, { childList: true, subtree: true })
  },

  durationFor(toast) {
    const own = toast.dataset.duration
    return Number(own !== undefined && own !== "" ? own : this.el.dataset.duration || 0)
  },

  arm(toast) {
    if (this.timers.has(toast) || toast.hidden) return
    const ms = this.durationFor(toast)
    if (ms <= 0) return this.timers.set(toast, { id: null, remaining: 0 })
    this.timers.set(toast, { id: setTimeout(() => this.dismiss(toast), ms), remaining: ms, started: Date.now() })
  },

  pause(toast) {
    const t = toast && this.timers.get(toast)
    if (!t || !t.id) return
    clearTimeout(t.id)
    t.remaining -= Date.now() - t.started
    t.id = null
    t.paused = true
  },

  resume(toast) {
    const t = toast && this.timers.get(toast)
    if (!t || !t.paused) return
    t.paused = false
    t.started = Date.now()
    t.id = setTimeout(() => this.dismiss(toast), Math.max(t.remaining, 500))
  },

  dismiss(toast) {
    if (!toast || !toast.isConnected) return
    const t = this.timers.get(toast)
    if (t?.id) clearTimeout(t.id)
    this.timers.delete(toast)

    const onDismiss = toast.getAttribute("data-on-dismiss")
    if (onDismiss) this.liveSocket.execJS(toast, onDismiss)

    if (toast.dataset.client !== undefined) {
      toast.classList.add("sl-toast-leaving")
      toast.addEventListener("animationend", () => toast.remove(), { once: true })
      setTimeout(() => toast.remove(), 400)
    }
  },

  add({ title, description, color = "neutral", duration, icon = true }) {
    const toast = document.createElement("div")
    const urgent = color === "danger" || color === "warning"
    toast.className = "sl-toast"
    toast.dataset.color = color
    toast.dataset.client = ""
    toast.tabIndex = 0
    toast.setAttribute("role", urgent ? "alert" : "status")
    if (duration !== undefined) toast.dataset.duration = String(duration)

    const iconSvg = icon ? statusIcon(color) : ""
    toast.innerHTML = `
      ${iconSvg}
      <div>
        <p class="sl-toast-title"></p>
        ${description ? '<p class="sl-toast-description"></p>' : ""}
      </div>
      <button type="button" class="sl-button sl-toast-close" data-variant="ghost" data-size="sm" data-icon aria-label="${this.el.dataset.labelDismiss || "Dismiss"}" data-sl-dismiss>${glyph(X_MARK)}</button>`
    toast.querySelector(".sl-toast-title").textContent = title || ""
    if (description) toast.querySelector(".sl-toast-description").textContent = description

    const container = this.el.querySelector('[phx-update="ignore"]') || this.el
    container.append(toast)
    this.arm(toast)
    return toast
  },

}
