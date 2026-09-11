export const supportsAnchor = typeof CSS !== "undefined" && CSS.supports("anchor-name: none")

/* Execute a Phoenix.LiveView.JS command stored in an attribute, if present. */
export function execAttr(hook, el, attr) {
  const js = el.getAttribute(attr)
  if (js) hook.liveSocket.execJS(el, js)
}

/*
 * Position `floating` relative to `reference` using fixed coordinates.
 * Fallback for browsers without CSS anchor positioning. Flips vertically
 * when there's no room, clamps horizontally to the viewport.
 */
export function positionFallback(reference, floating, placement = "bottom-start", offset = 4) {
  const r = reference.getBoundingClientRect()
  const f = floating.getBoundingClientRect()
  const vw = document.documentElement.clientWidth
  const vh = document.documentElement.clientHeight
  const [side, align = "center"] = placement.split("-")

  let top, left
  if (side === "top" || side === "bottom") {
    const fitsBelow = r.bottom + offset + f.height <= vh
    const fitsAbove = r.top - offset - f.height >= 0
    const below = side === "bottom" ? fitsBelow || !fitsAbove : !fitsAbove ? true : false
    top = below ? r.bottom + offset : r.top - offset - f.height
    if (align === "start") left = r.left
    else if (align === "end") left = r.right - f.width
    else left = r.left + r.width / 2 - f.width / 2
  } else {
    const fitsRight = r.right + offset + f.width <= vw
    const fitsLeft = r.left - offset - f.width >= 0
    const right = side === "right" ? fitsRight || !fitsLeft : !fitsLeft ? true : false
    left = right ? r.right + offset : r.left - offset - f.width
    top = r.top + r.height / 2 - f.height / 2
  }

  left = Math.max(8, Math.min(left, vw - f.width - 8))
  top = Math.max(8, Math.min(top, vh - f.height - 8))
  floating.style.top = `${Math.round(top)}px`
  floating.style.left = `${Math.round(left)}px`
}

/* Keep `fn` running on scroll/resize until the returned function is called. */
export function whileOpen(fn) {
  fn()
  const opts = { passive: true }
  window.addEventListener("scroll", fn, { ...opts, capture: true })
  window.addEventListener("resize", fn, opts)
  return () => {
    window.removeEventListener("scroll", fn, { capture: true })
    window.removeEventListener("resize", fn)
  }
}

// Keep browser constraint validation attached to the control the user sees.
// The native select remains the form control even though its UI is hidden.
export function bindValidation(control, visible, message) {
  const invalid = (event) => {
    event.preventDefault()
    message.textContent = control.validationMessage
    message.hidden = false
    const first = control.form && [...control.form.elements].find((el) => el.willValidate && !el.validity.valid)
    if (!first || first === control) visible.focus()
  }
  control.addEventListener("invalid", invalid)
  return {
    sync() {
      if (control.validity.valid || !control.willValidate) {
        message.hidden = true
        message.textContent = ""
      }
    },
    destroy() { control.removeEventListener("invalid", invalid) },
  }
}
