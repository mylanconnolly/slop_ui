/*
 * SlTabs — WAI-ARIA tabs with automatic activation.
 *
 * Client-owned (no `value`): the hook owns selection and shields the
 * aria-selected/tabindex/hidden attributes from server patches.
 * Server-owned (`value` given): the server renders selection; the hook only
 * handles keyboard focus movement and pushes `on_change`.
 */
export default {
  mounted() {
    this.list = this.el.querySelector('[role="tablist"]')
    this.controlled = this.el.dataset.controlled === "true"

    if (!this.controlled) {
      for (const tab of this.tabs()) this.js().ignoreAttributes(tab, ["aria-selected", "tabindex"])
      for (const panel of this.panels()) this.js().ignoreAttributes(panel, "hidden")
    }
    this.js().ignoreAttributes(this.list, ["style", "data-indicator"])

    // Keep the sliding indicator aligned when tabs resize (fonts, wrapping).
    this.resizer = new ResizeObserver(() => this.placeIndicator())
    this.resizer.observe(this.list)
    for (const tab of this.tabs()) this.resizer.observe(tab)
    this.placeIndicator()

    this.list.addEventListener("click", (e) => {
      const tab = e.target.closest('[role="tab"]')
      if (!tab || tab.getAttribute("aria-disabled") === "true") return
      // Links (patch/navigate) let LiveView drive selection via `value`.
      if (tab.tagName === "A") return
      this.select(tab, { emit: true })
    })

    this.list.addEventListener("keydown", (e) => this.onKeydown(e))
  },

  updated() {
    if (this.controlled) {
      const tab = this.tabFor(this.el.dataset.value)
      if (tab && tab.getAttribute("aria-selected") !== "true") this.select(tab, { emit: false })
    }
    this.placeIndicator()
  },

  destroyed() {
    this.resizer?.disconnect()
  },

  // Measures the selected tab and hands its box to CSS, which draws and
  // animates one shared indicator instead of a border per tab.
  placeIndicator() {
    const tab = this.tabs().find((t) => t.getAttribute("aria-selected") === "true")
    if (!tab || tab.offsetParent !== this.list) {
      this.list.removeAttribute("data-indicator")
      return
    }
    const s = this.list.style
    s.setProperty("--_x", tab.offsetLeft)
    s.setProperty("--_y", tab.offsetTop)
    s.setProperty("--_w", tab.offsetWidth)
    s.setProperty("--_h", tab.offsetHeight)
    this.list.setAttribute("data-indicator", "")
  },

  tabs() {
    return [...this.list.querySelectorAll('[role="tab"]')]
  },

  enabledTabs() {
    return this.tabs().filter((t) => t.getAttribute("aria-disabled") !== "true")
  },

  panels() {
    return [...this.el.querySelectorAll(':scope > [role="tabpanel"]')]
  },

  tabFor(value) {
    return this.tabs().find((t) => t.getAttribute("phx-value-tab") === value)
  },

  select(tab, { emit }) {
    for (const t of this.tabs()) {
      const on = t === tab
      this.js().setAttribute(t, "aria-selected", String(on))
      this.js().setAttribute(t, "tabindex", on ? "0" : "-1")
    }
    for (const p of this.panels()) {
      if (p.id === tab.getAttribute("aria-controls")) this.js().removeAttribute(p, "hidden")
      else this.js().setAttribute(p, "hidden", "")
    }
    this.placeIndicator()
    if (emit) {
      const onChange = this.el.getAttribute("data-on-change")
      if (onChange) this.liveSocket.execJS(tab, onChange, "click")
    }
  },

  onKeydown(e) {
    const tabs = this.enabledTabs()
    const i = tabs.indexOf(document.activeElement)
    if (i === -1) return
    const vertical = this.el.dataset.orientation === "vertical"
    const prev = vertical ? "ArrowUp" : "ArrowLeft"
    const next = vertical ? "ArrowDown" : "ArrowRight"
    let target

    if (e.key === next) target = tabs[(i + 1) % tabs.length]
    else if (e.key === prev) target = tabs[(i - 1 + tabs.length) % tabs.length]
    else if (e.key === "Home") target = tabs[0]
    else if (e.key === "End") target = tabs.at(-1)
    else return

    e.preventDefault()
    target.focus()
    // Automatic activation; links activate through their own navigation.
    if (target.tagName === "A") target.click()
    else this.select(target, { emit: true })
  },
}
