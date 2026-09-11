/*
 * SlCarousel — buttons, dots and autoplay for a scroll-snap track.
 *
 * The track scrolls natively; this hook only scrolls it programmatically and
 * mirrors the current slide into the dots, the buttons and a live region.
 */
export default {
  mounted() {
    this.track = this.el.querySelector(".sl-carousel-track")
    this.slides = [...this.track.querySelectorAll(".sl-carousel-slide")]
    this.dots = [...this.el.querySelectorAll(".sl-carousel-dot")]
    this.prev = this.el.querySelector("[data-sl-prev]")
    this.next = this.el.querySelector("[data-sl-next]")
    this.pauseBtn = this.el.querySelector("[data-sl-pause]")
    this.announce = this.el.querySelector("[data-sl-announce]")
    this.loop = "loop" in this.el.dataset
    this.interval = Number(this.el.dataset.autoplay) || 0
    this.reduced = matchMedia("(prefers-reduced-motion: reduce)").matches
    this.index = 0
    this.paused = false

    for (const d of this.dots) this.js().ignoreAttributes(d, ["aria-selected", "tabindex"])
    for (const b of [this.prev, this.next]) b && this.js().ignoreAttributes(b, "disabled")
    if (this.pauseBtn) this.js().ignoreAttributes(this.pauseBtn, "aria-pressed")

    this.prev?.addEventListener("click", () => this.go(this.index - 1, { user: true }))
    this.next?.addEventListener("click", () => this.go(this.index + 1, { user: true }))
    this.pauseBtn?.addEventListener("click", () => this.togglePause())
    for (const dot of this.dots) {
      dot.addEventListener("click", () => this.go(Number(dot.dataset.index) - 1, { user: true }))
    }

    this.el.addEventListener("keydown", (e) => this.onKeydown(e))
    this.el.addEventListener("pointerenter", () => this.hold(true))
    this.el.addEventListener("pointerleave", () => this.hold(false))
    this.el.addEventListener("focusin", () => this.hold(true))
    this.el.addEventListener("focusout", (e) => {
      if (!this.el.contains(e.relatedTarget)) this.hold(false)
    })

    // Track the slide the user scrolled to by hand (touch, wheel, keys).
    this.onScroll = () => {
      if (this.busy) return
      clearTimeout(this.scrollTimer)
      this.scrollTimer = setTimeout(() => this.sync(this.nearest(), { user: false }), 120)
    }
    this.onScrollEnd = () => {
      this.busy = false
      clearTimeout(this.scrollTimer)
      this.sync(this.nearest(), { user: false })
    }
    this.track.addEventListener("scroll", this.onScroll, { passive: true })
    this.track.addEventListener("scrollend", this.onScrollEnd)

    this.sync(0, { user: false })
    if (this.interval && !this.reduced) this.play()
  },

  destroyed() {
    this.stop()
    clearTimeout(this.scrollTimer)
    clearTimeout(this.busyTimer)
  },

  nearest() {
    const x = this.track.scrollLeft
    let best = 0
    let dist = Infinity
    this.slides.forEach((s, i) => {
      const d = Math.abs(s.offsetLeft - this.track.offsetLeft - x)
      if (d < dist) {
        dist = d
        best = i
      }
    })
    return best
  },

  go(i, { user }) {
    const n = this.slides.length
    if (this.loop) i = (i + n) % n
    else i = Math.min(n - 1, Math.max(0, i))
    const slide = this.slides[i]
    // Ignore the scroll events our own smooth scroll produces until it ends
    // (scrollend), with a timeout in case nothing needed to move.
    this.busy = !this.reduced
    clearTimeout(this.busyTimer)
    this.busyTimer = setTimeout(() => (this.busy = false), 1500)
    this.track.scrollTo({
      left: slide.offsetLeft - this.track.offsetLeft,
      behavior: this.reduced ? "instant" : "smooth",
    })
    this.sync(i, { user })
  },

  sync(i, { user }) {
    if (i === this.index && this.synced) return
    this.synced = true
    this.index = i
    const n = this.slides.length
    this.dots.forEach((d, j) => {
      d.setAttribute("aria-selected", String(j === i))
      d.setAttribute("tabindex", j === i ? "0" : "-1")
    })
    if (!this.loop) {
      if (this.prev) this.prev.disabled = i === 0
      if (this.next) this.next.disabled = i === n - 1
    }
    if (user && this.announce) {
      this.announce.textContent = this.el.dataset.labelSlide.replace("%{n}", i + 1).replace("%{total}", n)
    }
  },

  onKeydown(e) {
    const t = e.target
    if (t.matches("input, textarea, select, [contenteditable]")) return
    const n = this.slides.length
    let i
    if (e.key === "ArrowRight" || e.key === "ArrowDown") i = this.index + 1
    else if (e.key === "ArrowLeft" || e.key === "ArrowUp") i = this.index - 1
    else if (e.key === "Home") i = 0
    else if (e.key === "End") i = n - 1
    else return
    e.preventDefault()
    this.go(i, { user: true })
    // Roving focus on the dots follows the selection.
    if (t.matches(".sl-carousel-dot")) this.dots[this.index]?.focus()
  },

  play() {
    this.stop()
    const n = this.slides.length
    this.timer = setInterval(() => this.go((this.index + 1) % n, { user: false }), this.interval)
    this.track.setAttribute("aria-live", "off")
  },

  stop() {
    clearInterval(this.timer)
    this.timer = null
  },

  hold(on) {
    if (!this.interval || this.paused || this.reduced) return
    if (on) this.stop()
    else this.play()
  },

  togglePause() {
    this.paused = !this.paused
    const d = this.el.dataset
    this.pauseBtn.setAttribute("aria-pressed", String(this.paused))
    this.pauseBtn.textContent = this.paused ? d.labelPlay : d.labelPause
    if (this.paused) {
      this.stop()
      this.track.setAttribute("aria-live", "polite")
    } else if (!this.reduced) this.play()
  },
}
