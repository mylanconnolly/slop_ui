import { supportsAnchor, positionFallback, whileOpen, bindValidation } from "../util.js"
import { parseQuery, match, highlightNodes } from "../match.js"

/*
 * SlCombobox — editable combobox with list autocomplete (WAI-ARIA).
 *
 * Client mode: options are static; the hook filters them as you type.
 * Server mode (`data-on-search`): the hook pushes {query} and the server
 * re-renders the options; the hook keeps the list open across patches.
 *
 * The committed value lives in the hidden input; choosing an option sets it
 * and fires input/change for LiveView.
 */
import { svg as glyph, X_MARK } from "../icons.js"

const OPTION = '[role="option"]'

export default {
  mounted() {
    this.hidden = this.el.querySelector('input[type="hidden"]')
    this.input = this.el.querySelector('[role="combobox"]')
    this.listbox = this.el.querySelector('[role="listbox"]')
    this.empty = this.listbox.querySelector(".sl-listbox-empty")
    this.clearBtn = this.el.querySelector("[data-sl-clear]")
    this.serverMode = !!this.el.dataset.onSearch
    this.allowCustom = this.el.dataset.allowCustom !== undefined
    this.multiple = this.el.dataset.multiple !== undefined
    this.validation = bindValidation(this.input, this.input, this.el.parentElement.querySelector("[data-sl-validation]"))
    this.syncValidity()
    this.js().ignoreAttributes(this.input, ["aria-expanded", "aria-activedescendant"])
    this.js().ignoreAttributes(this.clearBtn, "hidden")

    if (this.multiple) {
      const wrap = this.el.querySelector(".sl-combobox-input-wrap")
      wrap.addEventListener("click", (e) => {
        if (this.disabled()) return
        const remove = e.target.closest("[data-sl-remove]")
        if (remove) { e.preventDefault(); this.removeValue(remove.dataset.slRemove); this.input.focus(); return }
        if (e.target === wrap) this.input.focus()
      })
    }

    this.input.addEventListener("input", () => this.onInput())
    this.input.addEventListener("keydown", (e) => this.onKeydown(e))
    this.input.addEventListener("focus", () => { if (this.input.value && !this.serverMode) this.open() })
    this.input.addEventListener("blur", () => setTimeout(() => this.onBlur(), 120))

    this.el.querySelector("[data-sl-toggle]").addEventListener("click", () => {
      if (this.disabled()) return
      this.input.focus()
      this.isOpen() ? this.close() : this.open({ showAll: true })
    })
    this.clearBtn.addEventListener("click", () => {
      if (this.disabled()) return
      if (this.multiple) { this.input.value = ""; this.clearBtn.hidden = true; this.filter() }
      else this.commit("", "")
      this.input.focus()
      if (this.serverMode) this.search("")
    })

    this.listbox.addEventListener("pointerdown", (e) => e.preventDefault()) // keep focus in the input
    this.listbox.addEventListener("click", (e) => {
      const opt = e.target.closest(OPTION)
      if (opt) this.choose(opt)
    })
    this.listbox.addEventListener("pointermove", (e) => {
      const opt = e.target.closest(OPTION)
      if (opt && opt !== this.active) this.activate(opt)
    })
    this.listbox.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open" && !supportsAnchor) {
        this.stopFallback = whileOpen(() => positionFallback(this.input, this.listbox, "bottom-start"))
      }
    })
    this.listbox.addEventListener("toggle", (e) => {
      this.js().setAttribute(this.input, "aria-expanded", String(e.newState === "open"))
      if (e.newState !== "open") { this.stopFallback?.(); this.activate(null) }
    })
  },

  updated() {
    if (this.multiple) this.syncSelected()
    this.syncValidity()
    if (this.disabled()) { this.close(); return }
    // Server delivered new options while typing: keep the list open and refresh.
    if (this.serverMode && document.activeElement === this.input && this.input.value !== "") this.open()
    else if (this.isOpen()) this.filter()
  },

  destroyed() {
    clearTimeout(this.searchTimer)
    this.validation.destroy()
    this.stopFallback?.()
  },

  disabled() { return this.input.matches(":disabled") },

  isOpen() { return this.listbox.matches(":popover-open") },
  options() { return [...this.listbox.querySelectorAll(OPTION)].filter((o) => !o.hidden && o.getAttribute("aria-disabled") !== "true") },

  open({ showAll = false } = {}) {
    if (this.disabled()) return
    this.filter(showAll ? "" : this.input.value)
    if (!this.isOpen()) this.listbox.showPopover()
    // Highlight the current value, or the best match while a query is typed,
    // so Enter always has something to act on.
    const opts = this.options()
    const selected = opts.find((o) => o.getAttribute("aria-selected") === "true")
    const best = this.input.value.trim() && this.best?.opt && !this.best.opt.hidden ? this.best.opt : null
    this.activate((this.input.value.trim() ? best || opts[0] : selected) || null, { scroll: true })
  },

  close() {
    if (this.isOpen()) this.listbox.hidePopover()
  },

  /* Client-side filtering: word-prefix / substring tokens, "quoted phrases", diacritic folding. */
  filter(query = this.input.value) {
    const tokens = this.serverMode ? [] : parseQuery(query)
    let visible = 0
    this.best = null
    for (const opt of this.listbox.querySelectorAll(OPTION)) {
      const label = opt.dataset.label ?? opt.textContent
      const target = opt.querySelector(".sl-option-label") || opt
      const hit = match(label, tokens)
      opt.hidden = !hit
      if (hit) {
        visible++
        if (!this.best || hit.score > this.best.score) this.best = { score: hit.score, opt }
        if (hit.ranges.length) target.replaceChildren(...highlightNodes(label, hit.ranges))
        else if (target.querySelector("mark")) target.textContent = label
      }
    }
    this.empty.hidden = visible > 0
  },

  onInput() {
    if (this.disabled()) return
    const text = this.input.value
    this.clearBtn.hidden = text === ""
    if (this.multiple) {
      if (this.serverMode) { clearTimeout(this.searchTimer); this.searchTimer = setTimeout(() => this.search(text), 200) }
      this.open()
      return
    }
    if (this.allowCustom) this.setHidden(text)
    else if (this.hidden.value !== "") this.setHidden("")
    if (this.serverMode) {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => this.search(text), 200)
    }
    this.open()
  },

  search(query) {
    const target = this.el.getAttribute("phx-target")
    const event = this.el.dataset.onSearch
    target ? this.pushEventTo(target, event, { query }) : this.pushEvent(event, { query })
  },

  onBlur() {
    if (this.disabled()) return
    if (this.el.contains(document.activeElement)) return
    if (this.multiple) {
      if (this.allowCustom && this.input.value.trim()) this.addValue(this.input.value.trim(), this.input.value.trim())
      this.input.value = ""
      this.clearBtn.hidden = true
      this.close()
      return
    }
    // Revert uncommitted text unless custom values are allowed.
    if (!this.allowCustom && this.hidden.value === "") this.input.value = ""
    else if (!this.allowCustom) {
      const opt = this.listbox.querySelector(`${OPTION}[data-value="${CSS.escape(this.hidden.value)}"]`)
      if (opt) this.input.value = opt.dataset.label ?? opt.textContent.trim()
    }
    this.clearBtn.hidden = this.input.value === ""
    this.close()
  },

  activate(opt, { scroll = false } = {}) {
    this.active?.removeAttribute("data-active")
    this.active = opt
    if (opt) {
      opt.setAttribute("data-active", "")
      this.input.setAttribute("aria-activedescendant", opt.id)
      if (scroll) opt.scrollIntoView({ block: "nearest" })
    } else {
      this.input.removeAttribute("aria-activedescendant")
    }
  },

  choose(opt) {
    if (this.disabled()) return
    const label = opt.dataset.label ?? opt.textContent.trim()
    if (this.multiple) {
      // Toggle, keep the list open, clear the query so the next pick starts fresh.
      this.values().includes(opt.dataset.value) ? this.removeValue(opt.dataset.value) : this.addValue(opt.dataset.value, label)
      this.input.value = ""
      this.clearBtn.hidden = true
      this.filter("")
      this.activate(opt)
      this.input.focus()
      return
    }
    this.commit(opt.dataset.value, label)
    this.close()
    this.input.focus()
  },

  commit(value, text) {
    this.input.value = text
    this.clearBtn.hidden = text === ""
    for (const o of this.listbox.querySelectorAll(OPTION)) o.setAttribute("aria-selected", String(o.dataset.value === value && value !== ""))
    this.setHidden(value)
  },

  setHidden(value) {
    if (this.hidden.value === value) { this.syncValidity(); return }
    this.hidden.value = value
    this.syncValidity()
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }))
    this.hidden.dispatchEvent(new Event("change", { bubbles: true }))
  },

  values() {
    return [...this.el.querySelectorAll(".sl-chip")].map((chip) => chip.dataset.value)
  },

  addValue(value, label) {
    if (this.disabled() || !value || this.values().includes(value)) return
    const chip = document.createElement("span")
    chip.className = "sl-chip"
    chip.dataset.value = value
    chip.append(label)
    const hidden = Object.assign(document.createElement("input"), { type: "hidden", name: this.el.dataset.name, value })
    const button = document.createElement("button")
    button.type = "button"
    button.tabIndex = -1
    button.dataset.slRemove = value
    button.setAttribute("aria-label", this.el.dataset.labelRemove.replace("__LABEL__", label))
    button.innerHTML = glyph(X_MARK)
    chip.append(hidden, button)
    this.input.before(chip)
    this.notifySelected()
  },

  removeValue(value) {
    if (this.disabled()) return
    const chip = [...this.el.querySelectorAll(".sl-chip")].find((chip) => chip.dataset.value === value)
    if (!chip) return
    chip.remove()
    this.notifySelected()
  },

  syncSelected() {
    const selected = this.values()
    for (const option of this.listbox.querySelectorAll(OPTION)) {
      option.setAttribute("aria-selected", String(selected.includes(option.dataset.value)))
    }
    this.syncValidity()
  },

  notifySelected() {
    this.syncSelected()
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }))
    this.hidden.dispatchEvent(new Event("change", { bubbles: true }))
  },

  syncValidity() {
    const missing = this.el.hasAttribute("data-required") &&
      (this.multiple ? this.values().length === 0 : this.hidden.value === "")
    this.input.setCustomValidity(missing ? this.el.dataset.labelRequired : "")
    this.validation?.sync()
  },

  onKeydown(e) {
    if (this.disabled()) return
    const opts = this.options()
    const i = opts.indexOf(this.active)
    switch (e.key) {
      case "ArrowDown":
        e.preventDefault()
        if (!this.isOpen()) return this.open({ showAll: this.input.value === "" })
        this.activate(opts[Math.min(i + 1, opts.length - 1)], { scroll: true })
        break
      case "ArrowUp":
        e.preventDefault()
        if (!this.isOpen()) return this.open({ showAll: this.input.value === "" })
        this.activate(opts[Math.max(i - 1, 0)], { scroll: true })
        break
      case "Home":
      case "End":
        if (!this.isOpen() || e.altKey) return
        // Only hijack when the list has an active option; otherwise let the caret move.
        if (this.active) { e.preventDefault(); this.activate(e.key === "Home" ? opts[0] : opts.at(-1), { scroll: true }) }
        break
      case "Enter":
        if (this.isOpen() && this.active) { e.preventDefault(); this.choose(this.active) }
        else if (this.multiple && this.allowCustom && this.input.value.trim()) { e.preventDefault(); this.addValue(this.input.value.trim(), this.input.value.trim()); this.input.value = ""; this.clearBtn.hidden = true }
        else if (this.isOpen()) { e.preventDefault(); this.close() }
        break
      case "Backspace":
        if (this.multiple && this.input.value === "") { const last = this.values().at(-1); if (last !== undefined) this.removeValue(last) }
        break
      case "Escape":
        if (this.isOpen()) { e.preventDefault(); this.close() }
        else if (this.input.value) { this.commit("", ""); if (this.serverMode) this.search("") }
        break
      case "Tab":
        this.close()
        break
    }
  },
}
