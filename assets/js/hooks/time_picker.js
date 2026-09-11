import { supportsAnchor, positionFallback, whileOpen } from "../util.js"

/*
 * SlTimePicker — slot listbox over a native time input.
 *
 * The input stays the source of truth (typing, mobile pickers, min/max,
 * phx-change). The button opens a popover listbox of slots every `step`
 * minutes between min and max; picking one writes the input and fires
 * input/change. Alt+ArrowDown on the input also opens the list.
 */
const pad = (n) => String(n).padStart(2, "0")
const toMin = (s) => (s && /^\d{2}:\d{2}/.test(s) ? Number(s.slice(0, 2)) * 60 + Number(s.slice(3, 5)) : null)
const fromMin = (m) => `${pad(Math.floor(m / 60))}:${pad(m % 60)}`

export default {
  mounted() {
    this.input = this.el.querySelector('input[type="time"]')
    this.button = this.el.querySelector("[popovertarget]")
    this.list = document.getElementById(this.button.getAttribute("popovertarget"))
    this.js().ignoreAttributes(this.button, "aria-expanded")

    const L = this.el.dataset
    const fmtOpts = { hour: "numeric", minute: "2-digit" }
    if (L.hourCycle) fmtOpts.hourCycle = L.hourCycle
    this.fmt = new Intl.DateTimeFormat(L.locale || navigator.language, fmtOpts)

    this.list.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open") {
        this.render()
        if (!supportsAnchor) this.stopFallback = whileOpen(() => positionFallback(this.el, this.list, "bottom-start", 8))
      }
    })
    this.list.addEventListener("toggle", (e) => {
      const open = e.newState === "open"
      this.js().setAttribute(this.button, "aria-expanded", String(open))
      if (open) this.focusOption(this.selectedOrNearest())
      else { this.stopFallback?.(); if (this.list.contains(document.activeElement) || document.activeElement === document.body) this.button.focus() }
    })
    this.list.addEventListener("click", (e) => {
      const opt = e.target.closest("[data-value]")
      if (opt) this.choose(opt.dataset.value)
    })
    this.list.addEventListener("keydown", (e) => this.onKeydown(e))
    this.input.addEventListener("keydown", (e) => {
      if (e.altKey && e.key === "ArrowDown" && !this.button.disabled && !this.input.readOnly) { e.preventDefault(); this.list.showPopover() }
    })
    this.input.addEventListener("input", () => this.isOpen() && this.render())
  },

  updated() {
    if (this.isOpen()) this.render()
  },

  destroyed() {
    this.stopFallback?.()
  },

  isOpen() { return this.list.matches(":popover-open") },
  options() { return [...this.list.querySelectorAll("[data-value]")] },

  slots() {
    const step = Math.max(1, Number(this.el.dataset.step) || 30)
    const min = toMin(this.input.min) ?? 0
    const max = toMin(this.input.max) ?? 24 * 60 - 1
    const out = []
    for (let m = min; m <= max; m += step) out.push(fromMin(m))
    return out
  },

  label(value) {
    const d = new Date(2000, 0, 1, Number(value.slice(0, 2)), Number(value.slice(3, 5)))
    return this.fmt.format(d)
  },

  render() {
    const current = this.input.value.slice(0, 5)
    this.list.innerHTML = this.slots()
      .map((v) => `<button type="button" role="option" class="sl-time-option" data-value="${v}" aria-selected="${v === current}" tabindex="-1">${this.label(v)}</button>`)
      .join("")
  },

  selectedOrNearest() {
    const opts = this.options()
    const current = toMin(this.input.value)
    if (current === null) return opts[0]
    return opts.find((o) => toMin(o.dataset.value) >= current) || opts.at(-1)
  },

  focusOption(opt) {
    if (!opt) return
    for (const o of this.options()) o.tabIndex = -1
    opt.tabIndex = 0
    opt.focus()
    opt.scrollIntoView({ block: "nearest" })
  },

  choose(value) {
    if (this.input.disabled || this.input.readOnly) return
    this.input.value = value
    this.input.dispatchEvent(new Event("input", { bubbles: true }))
    this.input.dispatchEvent(new Event("change", { bubbles: true }))
    this.list.hidePopover()
  },

  onKeydown(e) {
    const opts = this.options()
    const i = opts.indexOf(document.activeElement)
    if (i === -1) return
    switch (e.key) {
      case "ArrowDown": e.preventDefault(); return this.focusOption(opts[Math.min(i + 1, opts.length - 1)])
      case "ArrowUp": e.preventDefault(); return this.focusOption(opts[Math.max(i - 1, 0)])
      case "Home": e.preventDefault(); return this.focusOption(opts[0])
      case "End": e.preventDefault(); return this.focusOption(opts.at(-1))
      case "PageDown": e.preventDefault(); return this.focusOption(opts[Math.min(i + this.perHour(), opts.length - 1)])
      case "PageUp": e.preventDefault(); return this.focusOption(opts[Math.max(i - this.perHour(), 0)])
      case "Enter":
      case " ": e.preventDefault(); return this.choose(opts[i].dataset.value)
      case "Tab": return this.list.hidePopover()
      default:
        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) { e.preventDefault(); this.typeahead(e.key, opts, i) }
    }
  },

  perHour() {
    return Math.max(1, Math.round(60 / (Number(this.el.dataset.step) || 30)))
  },

  // Matches the visible label ("9:3" → 9:30) or the 24h value ("14" → 14:00).
  typeahead(char, opts, from) {
    clearTimeout(this.typeTimer)
    this.typed = (this.typed || "") + char.toLowerCase()
    this.typeTimer = setTimeout(() => (this.typed = ""), 700)
    const ordered = [...opts.slice(from + 1), ...opts.slice(0, from + 1)]
    const norm = (s) => s.toLowerCase().replace(/\s+/g, "")
    const match =
      ordered.find((o) => norm(o.textContent).startsWith(norm(this.typed))) ||
      ordered.find((o) => o.dataset.value.startsWith(this.typed))
    if (match) this.focusOption(match)
  },
}
