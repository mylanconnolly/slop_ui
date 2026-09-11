import { supportsAnchor, positionFallback, whileOpen } from "../util.js"

const ITEM = '[role="menuitem"], [role="menuitemcheckbox"], [role="menuitemradio"]'

/*
 * SlMenu — WAI-ARIA menu button pattern on top of the popover API.
 *
 * Popover gives us the top layer, light dismiss and Escape. Anchor positioning
 * (or the fallback) places the list. This hook adds what the platform lacks:
 * aria-expanded, roving focus with arrow keys, Home/End, typeahead, and
 * close-on-select.
 */
export default {
  mounted() {
    this.context = this.el.dataset.context !== undefined
    this.trigger = this.el.querySelector(this.context ? "[data-sl-context-target]" : "[popovertarget]")
    this.list = this.el.querySelector("[popover]")
    if (!this.trigger || !this.list) return
    this.js().ignoreAttributes(this.trigger, "aria-expanded")

    this.list.addEventListener("beforetoggle", (e) => {
      if (e.newState === "open" && !supportsAnchor && !this.context) this.startFallback()
    })

    this.list.addEventListener("toggle", (e) => {
      const open = e.newState === "open"
      this.js().setAttribute(this.trigger, "aria-expanded", String(open))
      if (open) {
        this.focusItem(this.openFromKeyboard === "last" ? this.items().at(-1) : this.items()[0])
      } else {
        this.stopFallback?.()
        if (this.list.contains(document.activeElement) || document.activeElement === document.body) {
          ;(this.returnFocus || this.trigger).focus()
        }
        this.returnFocus = null
      }
      this.openFromKeyboard = null
    })

    if (this.context) this.mountContext()
    else {
      this.trigger.addEventListener("keydown", (e) => {
        if (e.key === "ArrowDown" || e.key === "ArrowUp") {
          e.preventDefault()
          this.openFromKeyboard = e.key === "ArrowUp" ? "last" : "first"
          this.list.matches(":popover-open") ? this.focusItem(this.items()[0]) : this.list.showPopover()
        }
      })
    }

    this.list.addEventListener("keydown", (e) => this.onKeydown(e))

    this.list.addEventListener("click", (e) => {
      const item = e.target.closest(ITEM)
      if (!item || item.getAttribute("aria-disabled") === "true") return
      if (item.dataset.slSubmenu !== undefined) return // the popovertarget toggles the submenu
      if (item.dataset.keepOpen === undefined) this.list.hidePopover() // closes nested popovers too
    })

    // Roving tabindex: pointer hover moves focus so keyboard and mouse agree.
    // Hovering a submenu item opens it; hovering a sibling closes open submenus.
    this.list.addEventListener("pointermove", (e) => {
      const item = e.target.closest(ITEM)
      if (!item) return
      if (item !== document.activeElement) this.focusItem(item)
      const list = item.closest('[role="menu"]')
      clearTimeout(this.hoverTimer)
      if (item.dataset.slSubmenu !== undefined) {
        this.hoverTimer = setTimeout(() => this.openSubmenu(item, { focus: false }), 120)
      } else {
        this.hoverTimer = setTimeout(() => this.closeSubmenusIn(list), 200)
      }
    })

    // Submenu aria-expanded + fallback positioning + focus handling.
    for (const sub of this.el.querySelectorAll(".sl-menu-sub")) {
      const trigger = sub.querySelector("[data-sl-submenu]")
      const list = sub.querySelector('[role="menu"]')
      this.js().ignoreAttributes(trigger, "aria-expanded")
      list.addEventListener("beforetoggle", (e) => {
        if (e.newState === "open" && !supportsAnchor) {
          list._stop = whileOpen(() => positionFallback(trigger, list, "right-start", 4))
        }
      })
      list.addEventListener("toggle", (e) => {
        const open = e.newState === "open"
        this.js().setAttribute(trigger, "aria-expanded", String(open))
        if (!open) {
          list._stop?.()
          if (list.contains(document.activeElement)) this.focusItem(trigger)
        }
      })
    }
  },

  /*
   * Context menu mode: right-click opens at the pointer; Shift+F10 or the
   * Menu key opens beside whatever is focused inside the target.
   */
  mountContext() {
    this.trigger.addEventListener("contextmenu", (e) => {
      if (e.target.closest("[popover]")) return
      e.preventDefault()
      this.openContext({ x: e.clientX, y: e.clientY, from: document.activeElement })
    })
    this.trigger.addEventListener("keydown", (e) => {
      const key = e.key === "ContextMenu" || (e.key === "F10" && e.shiftKey)
      if (!key || e.target.closest("[popover]")) return
      e.preventDefault()
      const ref = this.trigger.contains(e.target) ? e.target : this.trigger
      this.openContext({ ref, from: e.target })
    })
    // Right-clicking the open menu must not summon the browser's own menu.
    this.list.addEventListener("contextmenu", (e) => e.preventDefault())
  },

  openContext({ x, y, ref, from }) {
    this.returnFocus = from && from !== document.body ? from : this.trigger
    if (this.list.matches(":popover-open")) this.list.hidePopover()
    this.stopFallback?.()
    if (ref) {
      this.stopFallback = whileOpen(() => positionFallback(ref, this.list, "bottom-start", 4))
    } else {
      this.stopFallback = whileOpen(() => this.placeAtPoint(x, y))
    }
    this.list.showPopover()
    if (ref) positionFallback(ref, this.list, "bottom-start", 4)
    else this.placeAtPoint(x, y)
  },

  placeAtPoint(x, y) {
    const list = this.list
    const vw = document.documentElement.clientWidth
    const vh = document.documentElement.clientHeight
    const w = list.offsetWidth
    const h = list.offsetHeight
    let left = x
    let top = y
    if (left + w > vw - 8) left = Math.max(8, x - w)
    if (top + h > vh - 8) top = Math.max(8, y - h)
    list.style.left = `${Math.round(left)}px`
    list.style.top = `${Math.round(top)}px`
  },

  /* Items of one menu level only (submenus have their own). */
  items(list = this.list) {
    return [...list.querySelectorAll(`:scope > ${ITEM}, :scope > .sl-menu-sub > ${ITEM}`)].filter(
      (el) => el.getAttribute("aria-disabled") !== "true" && !el.disabled && !el.hidden
    )
  },

  focusItem(item) {
    if (!item) return this.list.focus()
    for (const el of this.el.querySelectorAll(ITEM)) el.tabIndex = -1
    item.tabIndex = 0
    item.focus()
  },

  openSubmenu(trigger, { focus }) {
    if (trigger.getAttribute("aria-disabled") === "true") return
    const list = document.getElementById(trigger.getAttribute("popovertarget"))
    this.closeSubmenusIn(trigger.closest('[role="menu"]'), list)
    if (!list.matches(":popover-open")) list.showPopover()
    if (focus) this.focusItem(this.items(list)[0])
  },

  closeSubmenusIn(list, except = null) {
    for (const sub of list.querySelectorAll(':scope > .sl-menu-sub > [role="menu"]')) {
      if (sub !== except && sub.matches(":popover-open")) sub.hidePopover()
    }
  },

  onKeydown(e) {
    const list = document.activeElement.closest('[role="menu"]') || this.list
    const items = this.items(list)
    if (items.length === 0) return
    const i = items.indexOf(document.activeElement)
    const current = document.activeElement

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault()
        this.focusItem(items[(i + 1) % items.length])
        break
      case "ArrowUp":
        e.preventDefault()
        this.focusItem(items[(i - 1 + items.length) % items.length])
        break
      case "ArrowRight":
        if (current.dataset.slSubmenu !== undefined) { e.preventDefault(); this.openSubmenu(current, { focus: true }) }
        break
      case "ArrowLeft":
        if (list !== this.list) { e.preventDefault(); list.hidePopover() }
        break
      case "Enter":
      case " ":
        if (current.dataset.slSubmenu !== undefined) { e.preventDefault(); this.openSubmenu(current, { focus: true }) }
        break
      case "Home":
        e.preventDefault()
        this.focusItem(items[0])
        break
      case "End":
        e.preventDefault()
        this.focusItem(items.at(-1))
        break
      case "Tab":
        this.list.hidePopover()
        break
      default:
        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) this.typeahead(e.key, items, i)
    }
  },

  typeahead(char, items, from) {
    clearTimeout(this.typeTimer)
    this.typed = (this.typed || "") + char.toLowerCase()
    this.typeTimer = setTimeout(() => (this.typed = ""), 500)
    const ordered = [...items.slice(from + 1), ...items.slice(0, from + 1)]
    const match = ordered.find((el) => el.textContent.trim().toLowerCase().startsWith(this.typed))
    if (match) this.focusItem(match)
  },

  startFallback() {
    const placement = this.list.dataset.placement || "bottom-start"
    this.stopFallback = whileOpen(() => positionFallback(this.trigger, this.list, placement))
  },

  destroyed() {
    this.stopFallback?.()
  },
}
