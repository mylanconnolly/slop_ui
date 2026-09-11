/*
 * SlCounter — live character count for a text control.
 *
 * Sits on the `.sl-counter` element; `data-for` names the control. The
 * visible "n / max" updates on every keystroke; a visually hidden polite live
 * region announces the remaining count after typing pauses, so screen readers
 * aren't flooded.
 */
export default {
  mounted() {
    this.input = document.getElementById(this.el.dataset.for)
    this.count = this.el.querySelector("[data-count]")
    this.live = this.el.querySelector("[data-live]")
    this.max = Number(this.el.dataset.max) || null
    this.js().ignoreAttributes(this.el, "data-state")
    if (!this.input) return
    this.onInput = () => this.update(true)
    this.input.addEventListener("input", this.onInput)
    this.update(false)
  },

  updated() {
    this.update(false)
  },

  destroyed() {
    this.input?.removeEventListener("input", this.onInput)
    clearTimeout(this.timer)
  },

  update(announce) {
    const n = [...(this.input.value || "")].length
    this.count.textContent = String(n)
    const state = this.max === null ? null : n > this.max ? "over" : n === this.max ? "limit" : null
    if (state) this.el.setAttribute("data-state", state)
    else this.el.removeAttribute("data-state")

    if (!announce) return
    clearTimeout(this.timer)
    this.timer = setTimeout(() => (this.live.textContent = this.message(n)), 800)
  },

  message(n) {
    const d = this.el.dataset
    if (this.max === null) return d.labelCount.replace("%{count}", n)
    const diff = this.max - n
    if (diff >= 0) return (diff === 1 ? d.labelRemainingOne : d.labelRemainingOther).replace("%{count}", diff)
    return (-diff === 1 ? d.labelOverOne : d.labelOverOther).replace("%{count}", -diff)
  },
}
