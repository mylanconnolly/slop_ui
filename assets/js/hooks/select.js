import { supportsAnchor, positionFallback, whileOpen, bindValidation } from "../util.js"
import { svg as glyph, X_MARK } from "../icons.js"

/*
 * SlSelect — select-only combobox (WAI-ARIA) over a hidden native <select>.
 *
 * The native select is the source of truth: it submits with the form and
 * fires input/change so LiveView's phx-change sees every selection. The
 * hook keeps the trigger label, chips and aria-selected in sync, and adds
 * keyboard navigation. Server re-renders (new options or value) are picked
 * up in updated().
 */
const OPTION = '[role="option"]'

export default {
  mounted() {
    this.native = this.el.querySelector("select")
    this.trigger = this.el.querySelector('[role="combobox"]')
    this.listbox = this.el.querySelector('[role="listbox"]')
    this.validation = bindValidation(this.native, this.trigger, this.el.parentElement.querySelector("[data-sl-validation]"))
    this.multiple = this.el.dataset.multiple !== undefined
    this.js().ignoreAttributes(this.trigger, ["aria-expanded", "aria-activedescendant"])

    this.listbox.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open" && !supportsAnchor) {
        this.stopFallback = whileOpen(() => positionFallback(this.trigger, this.listbox, "bottom-start"))
      }
    })
    this.listbox.addEventListener("toggle", (e) => {
      const open = e.newState === "open"
      this.js().setAttribute(this.trigger, "aria-expanded", String(open))
      if (open) {
        const current = this.options().find((o) => o.getAttribute("aria-selected") === "true")
        this.activate(current || this.options()[0], { scroll: true })
      } else {
        this.stopFallback?.()
        this.activate(null)
      }
    })

    this.trigger.addEventListener("keydown", (e) => this.onKeydown(e))
    // The trigger is a div (a <button> can't contain the chip remove buttons),
    // so it is not a popover invoker: light dismiss already closed the list on
    // pointerdown, and we must not reopen it on the following click.
    this.trigger.addEventListener("pointerdown", () => (this.openAtPointerDown = this.isOpen()))
    this.trigger.addEventListener("click", (e) => {
      if (this.disabled()) return
      const remove = e.target.closest("[data-sl-remove]")
      if (remove) {
        e.preventDefault()
        this.toggleValue(remove.dataset.slRemove, false)
        return
      }
      if (this.disabled()) return
      if (this.openAtPointerDown) return
      this.listbox.showPopover()
    })

    this.listbox.addEventListener("click", (e) => {
      const opt = e.target.closest(OPTION)
      if (opt) this.choose(opt)
    })
    this.listbox.addEventListener("pointermove", (e) => {
      const opt = e.target.closest(OPTION)
      if (opt && opt !== this.active) this.activate(opt)
    })
  },

  updated() {
    this.render()
  },

  destroyed() {
    this.stopFallback?.()
    this.validation.destroy()
  },

  isOpen() {
    return this.listbox.matches(":popover-open")
  },

  disabled() {
    return this.trigger.getAttribute("aria-disabled") === "true"
  },

  options() {
    return [...this.listbox.querySelectorAll(OPTION)].filter((o) => o.getAttribute("aria-disabled") !== "true")
  },

  values() {
    return [...this.native.selectedOptions].map((o) => o.value).filter((v) => v !== "")
  },

  activate(opt, { scroll = false } = {}) {
    this.active?.removeAttribute("data-active")
    this.active = opt
    if (opt) {
      opt.setAttribute("data-active", "")
      this.trigger.setAttribute("aria-activedescendant", opt.id)
      if (scroll) opt.scrollIntoView({ block: "nearest" })
    } else {
      this.trigger.removeAttribute("aria-activedescendant")
    }
  },

  choose(opt) {
    if (this.disabled()) return
    const value = opt.dataset.value
    if (this.multiple) {
      this.toggleValue(value, !this.values().includes(value))
    } else {
      this.setValues([value])
      this.listbox.hidePopover()
      this.trigger.focus()
    }
  },

  toggleValue(value, on) {
    const set = new Set(this.values())
    on ? set.add(value) : set.delete(value)
    this.setValues([...set])
  },

  setValues(values) {
    for (const o of this.native.options) o.selected = values.includes(o.value)
    this.render()
    this.native.dispatchEvent(new Event("input", { bubbles: true }))
    this.native.dispatchEvent(new Event("change", { bubbles: true }))
  },

  /* Reflect the native select into the trigger and listbox. */
  render() {
    this.validation.sync()
    const values = this.values()
    const labels = new Map([...this.native.options].map((o) => [o.value, o.textContent.trim()]))
    const display = this.trigger.querySelector(".sl-select-value")

    for (const opt of this.listbox.querySelectorAll(OPTION)) {
      opt.setAttribute("aria-selected", String(values.includes(opt.dataset.value)))
    }

    display.replaceChildren()
    if (values.length === 0) {
      display.setAttribute("data-placeholder", "")
      display.textContent = this.el.dataset.placeholder || ""
    } else if (this.multiple) {
      display.removeAttribute("data-placeholder")
      for (const v of values) {
        const chip = document.createElement("span")
        chip.className = "sl-chip"
        chip.dataset.value = v
        chip.append(labels.get(v) ?? v)
        const btn = document.createElement("button")
        btn.disabled = this.disabled()
        btn.type = "button"
        btn.tabIndex = -1
        btn.setAttribute("aria-label", (this.el.dataset.labelRemove || "Remove __LABEL__").replace("__LABEL__", labels.get(v) ?? v))
        btn.dataset.slRemove = v
        btn.innerHTML = glyph(X_MARK)
        chip.append(btn)
        display.append(chip)
      }
    } else {
      display.removeAttribute("data-placeholder")
      display.textContent = labels.get(values[0]) ?? values[0]
    }
  },

  onKeydown(e) {
    if (this.disabled()) return
    const opts = this.options()
    const i = opts.indexOf(this.active)
    const open = this.isOpen()

    switch (e.key) {
      case "ArrowDown":
      case "ArrowUp": {
        e.preventDefault()
        if (!open) return this.listbox.showPopover()
        const next = e.key === "ArrowDown" ? Math.min(i + 1, opts.length - 1) : Math.max(i - 1, 0)
        this.activate(opts[next], { scroll: true })
        break
      }
      case "Home":
      case "End":
        if (!open) return
        e.preventDefault()
        this.activate(e.key === "Home" ? opts[0] : opts.at(-1), { scroll: true })
        break
      case "Enter":
      case " ":
        e.preventDefault()
        if (!open) return this.listbox.showPopover()
        if (this.active) this.choose(this.active)
        break
      case "Tab":
        if (open) this.listbox.hidePopover()
        break
      case "Backspace":
        if (this.multiple && !open) {
          const last = this.values().at(-1)
          if (last !== undefined) this.toggleValue(last, false)
        }
        break
      default:
        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
          e.preventDefault()
          this.typeahead(e.key, opts, i)
        }
    }
  },

  typeahead(char, opts, from) {
    clearTimeout(this.typeTimer)
    this.typed = (this.typed || "") + char.toLowerCase()
    this.typeTimer = setTimeout(() => (this.typed = ""), 500)
    const ordered = [...opts.slice(from + 1), ...opts.slice(0, from + 1)]
    const match = ordered.find((o) => o.textContent.trim().toLowerCase().startsWith(this.typed))
    if (!match) return
    if (this.isOpen()) this.activate(match, { scroll: true })
    else if (!this.multiple) this.setValues([match.dataset.value])
  },
}
