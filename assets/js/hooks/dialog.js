import { execAttr } from "../util.js"

/*
 * SlDialog — thin hook over native <dialog>.
 *
 * Open/close from the server:   <.dialog show={@show}>          (data-open)
 * Open/close from JS commands:  SlopUI.JS.open_dialog("#id")    (sl:open event)
 * Close from markup:            <form method="dialog"><button>  (native, no JS)
 *
 * The platform handles focus trapping, Escape, inert background, and focus
 * restoration. We add: light dismiss where `closedby` is unsupported, the
 * on_open/on_close JS commands, and protecting `open` from server patches.
 *
 * Open/close transitions are detected from both the classic `close` event and
 * the newer `toggle` event (Chrome 137+, Safari 26+, Firefox 145+), whichever
 * fires first; a state flag dedupes them.
 */
export default {
  mounted() {
    this.js().ignoreAttributes(this.el, "open")
    this.wasOpen = false

    this.el.addEventListener("sl:open", () => this.open())
    this.el.addEventListener("sl:close", () => this.close())
    this.el.addEventListener("sl:toggle", () => (this.el.open ? this.close() : this.open()))

    this.el.addEventListener("close", () => this.sync())
    this.el.addEventListener("toggle", () => this.sync())

    // Escape when not dismissable. Browsers with `closedby` handle this natively.
    this.el.addEventListener("cancel", (e) => {
      if (this.el.dataset.dismiss === "false") e.preventDefault()
    })

    // Light dismiss fallback (Safari has no `closedby` as of Sept 2026).
    // data-dismiss: "true" (Escape + backdrop), "closerequest" (Escape only), "false" (neither).
    if (!("closedBy" in this.el) || this.el.hasAttribute("data-backdrop-surface")) {
      this.el.addEventListener("click", (e) => {
        if (e.target === this.el && this.el.dataset.dismiss === "true") this.close()
      })
    }

    if (this.el.dataset.open === "true") this.open()
  },

  updated() {
    const want = this.el.dataset.open
    if (want === "true" && !this.el.open) this.open()
    if (want === "false" && this.el.open) this.close()
  },

  destroyed() {
    if (this.el.open) this.el.close()
  },

  /* Fire on_open / on_close exactly once per transition, whatever caused it. */
  sync() {
    const isOpen = this.el.open
    if (isOpen === this.wasOpen) return
    this.wasOpen = isOpen
    execAttr(this, this.el, isOpen ? "data-on-open" : "data-on-close")
  },

  open() {
    if (this.el.open) return
    // Measure the scrollbar before the scroll lock removes it, so the CSS can
    // pad the page by the same amount and nothing shifts.
    const scrollbar = window.innerWidth - document.documentElement.clientWidth
    document.documentElement.style.setProperty("--sl-scrollbar-width", `${scrollbar}px`)
    this.el.showModal()
    // Preferred initial focus (e.g. the safe action of an alert dialog).
    this.el.querySelector("[data-sl-autofocus]")?.focus()
    this.sync()
  },

  close() {
    if (!this.el.open) return
    this.el.close()
    this.sync()
  },
}
