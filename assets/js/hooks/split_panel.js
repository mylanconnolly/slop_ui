/*
 * SlSplitPanel — resizable divider between two panes.
 *
 * Writes a single custom property (--sl-split-size, percent of the container)
 * so the browser only relayouts the two flex items; aria-valuenow mirrors it.
 */
export default {
  mounted() {
    this.handle = this.el.querySelector('[role="separator"]')
    this.min = Number(this.el.dataset.min)
    this.max = Number(this.el.dataset.max)
    this.default = Number(this.el.dataset.default)
    this.key = this.el.dataset.storageKey
    this.js().ignoreAttributes(this.el, ["style", "data-dragging", "data-collapsed"])
    this.js().ignoreAttributes(this.handle, ["aria-valuenow", "aria-valuetext"])

    let stored = null
    try {
      stored = this.key && localStorage.getItem(`sl-split:${this.key}`)
    } catch {}
    this.set(stored == null || stored === "" ? this.default : Number(stored), { persist: false })

    this.handle.addEventListener("pointerdown", (e) => this.start(e))
    this.handle.addEventListener("pointermove", (e) => this.move(e))
    this.handle.addEventListener("pointerup", (e) => this.stop(e))
    this.handle.addEventListener("pointercancel", (e) => this.stop(e))
    this.handle.addEventListener("dblclick", () => this.set(this.default))
    this.handle.addEventListener("keydown", (e) => this.onKeydown(e))
  },

  vertical() {
    return this.el.dataset.orientation === "vertical"
  },

  start(e) {
    if (e.button !== 0) return
    this.handle.setPointerCapture(e.pointerId)
    this.rect = this.el.getBoundingClientRect()
    this.el.setAttribute("data-dragging", "")
    e.preventDefault()
  },

  move(e) {
    if (!this.rect) return
    const pct = this.vertical()
      ? ((e.clientY - this.rect.top) / this.rect.height) * 100
      : ((e.clientX - this.rect.left) / this.rect.width) * 100
    cancelAnimationFrame(this.raf)
    this.raf = requestAnimationFrame(() => this.set(pct, { persist: false }))
  },

  stop(e) {
    if (!this.rect) return
    this.rect = null
    this.el.removeAttribute("data-dragging")
    if (this.handle.hasPointerCapture(e.pointerId)) this.handle.releasePointerCapture(e.pointerId)
    this.persist()
  },

  onKeydown(e) {
    const step = e.shiftKey ? 10 : 1
    const grow = this.vertical() ? "ArrowDown" : "ArrowRight"
    const shrink = this.vertical() ? "ArrowUp" : "ArrowLeft"
    const now = Number(this.handle.getAttribute("aria-valuenow"))

    if (e.key === grow) this.set(now + step)
    else if (e.key === shrink) this.set(now - step)
    else if (e.key === "Home") this.set(this.min)
    else if (e.key === "End") this.set(this.max)
    else if (e.key === "Enter") this.toggleCollapse(now)
    else return
    e.preventDefault()
  },

  toggleCollapse(now) {
    if (this.el.hasAttribute("data-collapsed")) {
      this.el.removeAttribute("data-collapsed")
      this.set(this.restore ?? this.default)
    } else {
      this.restore = now
      this.el.setAttribute("data-collapsed", "")
      this.set(this.min)
    }
  },

  set(pct, { persist = true } = {}) {
    const value = Math.round(Math.min(this.max, Math.max(this.min, pct)))
    this.el.style.setProperty("--sl-split-size", `${value}%`)
    this.handle.setAttribute("aria-valuenow", String(value))
    this.handle.setAttribute("aria-valuetext", `${value}%`)
    if (value > this.min) this.el.removeAttribute("data-collapsed")
    if (persist) this.persist()
  },

  persist() {
    if (!this.key) return
    try {
      localStorage.setItem(`sl-split:${this.key}`, this.handle.getAttribute("aria-valuenow"))
    } catch {}
  },
}
