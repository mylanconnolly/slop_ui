import { execAttr } from "../util.js"
import { parseQuery, match, highlightNodes } from "../match.js"

/*
 * SlCommand — command palette on a native <dialog>.
 * Opens on ⌘K / Ctrl+K (data-shortcut) or `sl:open`; filters items client-side
 * or pushes `data-on-search`; arrows/Home/End move, Enter activates, Escape
 * closes natively.
 */
const ITEM = '[role="option"]'

export default {
  mounted() {
    this.js().ignoreAttributes(this.el, "open")
    this.input = this.el.querySelector(".sl-command-input")
    this.list = this.el.querySelector('[role="listbox"]')
    this.empty = this.list.querySelector(".sl-command-empty")
    this.serverMode = !!this.el.dataset.onSearch

    this.el.addEventListener("sl:open", () => this.open())
    this.el.addEventListener("sl:close", () => this.el.close())
    this.el.addEventListener("sl:toggle", () => (this.el.open ? this.el.close() : this.open()))
    this.el.addEventListener("toggle", () => this.sync())
    this.el.addEventListener("close", () => this.sync())

    // Light dismiss fallback where `closedby` is unsupported.
    if (!("closedBy" in this.el)) this.el.addEventListener("click", (e) => e.target === this.el && this.el.close())

    this.onKey = (e) => {
      const key = this.el.dataset.shortcut
      if (key && (e.metaKey || e.ctrlKey) && e.key.toLowerCase() === key.toLowerCase()) {
        e.preventDefault()
        this.el.open ? this.el.close() : this.open()
      }
    }
    document.addEventListener("keydown", this.onKey)

    this.input.addEventListener("input", () => this.onInput())
    this.input.addEventListener("keydown", (e) => this.onKeydown(e))
    this.list.addEventListener("pointermove", (e) => {
      const item = e.target.closest(ITEM)
      if (item && item !== this.active) this.activate(item)
    })
    this.list.addEventListener("click", (e) => {
      const item = e.target.closest(ITEM)
      if (item && item.getAttribute("aria-disabled") !== "true") this.close()
    })
  },

  updated() {
    if (this.el.open) this.filter()
  },

  destroyed() {
    document.removeEventListener("keydown", this.onKey)
    clearTimeout(this.searchTimer)
    if (this.el.open) this.el.close()
  },

  open() {
    if (this.el.open) return
    this.input.value = ""
    this.filter()
    this.el.showModal()
    this.input.focus()
    this.sync()
  },

  close() {
    if (this.el.open) this.el.close()
  },

  sync() {
    const isOpen = this.el.open
    if (isOpen === this.wasOpen) return
    this.wasOpen = isOpen
    execAttr(this, this.el, isOpen ? "data-on-open" : "data-on-close")
    if (!isOpen) this.activate(null)
  },

  items() {
    return [...this.list.querySelectorAll(ITEM)].filter((i) => !i.hidden && i.getAttribute("aria-disabled") !== "true")
  },

  onInput() {
    if (this.serverMode) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        const target = this.el.getAttribute("phx-target")
        const payload = { query: this.input.value }
        target ? this.pushEventTo(target, this.el.dataset.onSearch, payload) : this.pushEvent(this.el.dataset.onSearch, payload)
      }, 150)
    } else {
      this.filter()
    }
  },

  /* Client filtering: tokens match word prefixes or substrings, "quoted phrases" literally,
     data-keywords count for matching; empty groups hide; the best match is highlighted first. */
  filter() {
    const tokens = this.serverMode ? [] : parseQuery(this.input.value)
    let visible = 0
    let best = null
    for (const item of this.list.querySelectorAll(ITEM)) {
      const label = item.querySelector(".sl-command-item-label")
      const text = label.dataset.text ?? (label.dataset.text = label.textContent.trim())
      const hint = item.querySelector(".sl-command-item-hint")?.textContent || ""
      const hit = match(text, tokens, [item.dataset.keywords || "", hint].join(" ").trim())
      item.hidden = !hit
      if (!hit) {
        if (label.querySelector("mark")) label.replaceChildren(...label.querySelectorAll(":scope > svg"), text)
        continue
      }
      visible++
      if (item.getAttribute("aria-disabled") !== "true" && (!best || hit.score > best.score)) best = { score: hit.score, item }
      // Keep leading icons; put the (possibly highlighted) text in one span so the
      // label's flex gap never splits the text around the <mark>s.
      if (hit.ranges.length || label.querySelector("mark")) {
        const icons = [...label.querySelectorAll(":scope > svg")]
        const span = document.createElement("span")
        span.append(...(hit.ranges.length ? highlightNodes(text, hit.ranges) : [text]))
        label.replaceChildren(...icons, span)
      }
    }
    for (const group of this.list.querySelectorAll(".sl-command-group")) {
      group.hidden = !group.querySelector(`${ITEM}:not([hidden])`)
    }
    this.empty.hidden = visible > 0
    this.activate(best?.item || this.items()[0] || null)
  },

  activate(item) {
    this.active?.removeAttribute("data-active")
    this.active = item
    if (item) {
      item.setAttribute("data-active", "")
      this.input.setAttribute("aria-activedescendant", item.id || "")
      item.scrollIntoView({ block: "nearest" })
    } else {
      this.input.removeAttribute("aria-activedescendant")
    }
  },

  onKeydown(e) {
    const items = this.items()
    const i = items.indexOf(this.active)
    switch (e.key) {
      case "ArrowDown": e.preventDefault(); this.activate(items[Math.min(i + 1, items.length - 1)]); break
      case "ArrowUp": e.preventDefault(); this.activate(items[Math.max(i - 1, 0)]); break
      case "Home": e.preventDefault(); this.activate(items[0]); break
      case "End": e.preventDefault(); this.activate(items.at(-1)); break
      case "Enter":
        e.preventDefault()
        if (this.active) { this.active.click(); this.close() }
        break
    }
  },
}
