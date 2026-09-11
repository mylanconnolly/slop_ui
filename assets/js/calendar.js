/*
 * Month grid shared by the date picker popover (SlDatePicker) and the inline
 * calendar (SlCalendar). Renders into a container, handles clicks and the
 * WAI-ARIA grid keyboard map, and reports selections back through `onSelect`.
 *
 *   const grid = createMonthGrid(container, {
 *     locale, labels, range, footer,
 *     values: () => [start, end],          // Date | null
 *     bounds: () => [min, max],            // Date | null
 *     onSelect: ([start, end], done) => {} // done: range complete / single pick
 *   })
 *   grid.render(); grid.focusDay(date)
 */
import { svg, CHEVRON_LEFT, CHEVRON_RIGHT } from "./icons.js"

export const ISO = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`
export const parseISO = (s) => (s && /^\d{4}-\d{2}-\d{2}$/.test(s) ? new Date(Number(s.slice(0, 4)), Number(s.slice(5, 7)) - 1, Number(s.slice(8, 10))) : null)
export const addDays = (d, n) => new Date(d.getFullYear(), d.getMonth(), d.getDate() + n)
export const addMonths = (d, n) => new Date(d.getFullYear(), d.getMonth() + n, 1)
export const today = () => { const t = new Date(); return new Date(t.getFullYear(), t.getMonth(), t.getDate()) }

export function createMonthGrid(el, opts) {
  const locale = opts.locale || navigator.language
  const weekInfo = new Intl.Locale(locale).getWeekInfo?.() || new Intl.Locale(locale).weekInfo
  const firstDay = (weekInfo?.firstDay ?? 7) % 7 // 0 = Sunday
  const fmtMonth = new Intl.DateTimeFormat(locale, { month: "long", year: "numeric" })
  const fmtWeekday = new Intl.DateTimeFormat(locale, { weekday: "short" })
  const fmtWeekdayLong = new Intl.DateTimeFormat(locale, { weekday: "long" })
  const fmtFull = new Intl.DateTimeFormat(locale, { dateStyle: "full" })
  const L = opts.labels || {}

  const grid = {
    view: null,
    pending: null, // first pick of a range
    focusIso: null,

    disabled(d) {
      const [min, max] = opts.bounds()
      return (min && d < min) || (max && d > max)
    },

    render() {
      // Re-rendering replaces the buttons; keep keyboard focus on the same day.
      const focused = el.contains(document.activeElement) ? document.activeElement.dataset?.date : null
      const [s, e] = opts.values()
      const view = grid.view || s || today()
      grid.view = addMonths(view, 0)
      const first = grid.view
      const lead = (first.getDay() - firstDay + 7) % 7
      const start = addDays(first, -lead)
      const todayIso = ISO(today())
      const from = grid.pending || s
      const to = grid.pending ? null : e
      const sel = new Set([s, e].filter(Boolean).map(ISO))
      const tabStop = grid.tabStop(sel, todayIso)

      let days = ""
      for (let i = 0; i < 42; i++) {
        const d = addDays(start, i), iso = ISO(d)
        const outside = d.getMonth() !== first.getMonth()
        const inRange = opts.range && from && to && d > from && d < to
        const attrs = [
          `data-date="${iso}"`, outside ? "data-outside" : "",
          iso === todayIso ? 'data-today aria-current="date"' : "",
          sel.has(iso) ? 'aria-selected="true"' : 'aria-selected="false"',
          inRange ? "data-in-range" : "",
          opts.range && from && to && iso === ISO(from) ? "data-range-start" : "",
          opts.range && to && iso === ISO(to) ? "data-range-end" : "",
          grid.disabled(d) ? 'aria-disabled="true"' : "",
          `aria-label="${fmtFull.format(d)}"`,
          `tabindex="${iso === tabStop ? 0 : -1}"`,
        ].filter(Boolean).join(" ")
        days += `<button type="button" role="gridcell" class="sl-calendar-day" ${attrs}>${d.getDate()}</button>`
      }

      const weekdays = Array.from({ length: 7 }, (_, i) => {
        const d = addDays(start, i)
        return `<div class="sl-calendar-weekday" role="columnheader" aria-label="${fmtWeekdayLong.format(d)}">${fmtWeekday.format(d)}</div>`
      }).join("")

      const footer = opts.footer === false ? "" : `
        <div class="sl-calendar-footer">
          <button type="button" class="sl-button" data-variant="ghost" data-size="sm" data-action="clear">${L.clear || "Clear"}</button>
          <button type="button" class="sl-button" data-variant="ghost" data-size="sm" data-action="today">${L.today || "Today"}</button>
        </div>`

      el.innerHTML = `
        <div class="sl-calendar-header">
          <button type="button" class="sl-button" data-variant="ghost" data-size="sm" data-icon aria-label="${L.prev || "Previous month"}" data-nav="-1">${svg(CHEVRON_LEFT)}</button>
          <div class="sl-calendar-title" aria-live="polite">${fmtMonth.format(first)}</div>
          <button type="button" class="sl-button" data-variant="ghost" data-size="sm" data-icon aria-label="${L.next || "Next month"}" data-nav="1">${svg(CHEVRON_RIGHT)}</button>
        </div>
        <div class="sl-calendar-grid" role="grid" aria-label="${fmtMonth.format(first)}"><div role="row" class="sl-calendar-row">${weekdays}</div>${rows(days)}</div>${footer}`
      if (focused) (el.querySelector(`[data-date="${focused}"]`) || el.querySelector('[role="gridcell"][tabindex="0"]'))?.focus()
    },

    // The single tab stop: the focused day if it is in view, else the selection, today, or the 1st.
    tabStop(sel, todayIso) {
      const inView = (iso) => iso && parseISO(iso).getMonth() === grid.view.getMonth() && parseISO(iso).getFullYear() === grid.view.getFullYear()
      if (inView(grid.focusIso)) return grid.focusIso
      const selected = [...sel].find(inView)
      if (selected) return selected
      if (inView(todayIso)) return todayIso
      return ISO(grid.view)
    },

    setView(d) { grid.view = addMonths(d, 0); grid.render() },

    focusDay(d) {
      let btn = el.querySelector(`[data-date="${ISO(d)}"]`)
      if (!btn || btn.hasAttribute("data-outside")) { grid.view = addMonths(d, 0); grid.render(); btn = el.querySelector(`[data-date="${ISO(d)}"]`) }
      for (const b of el.querySelectorAll(".sl-calendar-day")) b.tabIndex = -1
      btn.tabIndex = 0
      grid.focusIso = ISO(d)
      btn.focus()
    },

    pick(d) {
      if (grid.disabled(d)) return
      if (!opts.range) return opts.onSelect([d, null], true)
      if (!grid.pending) {
        grid.pending = d
        opts.onSelect([d, null], false)
        grid.render()
        grid.focusDay(d)
      } else {
        let a = grid.pending, b = d
        if (b < a) [a, b] = [b, a]
        grid.pending = null
        opts.onSelect([a, b], true)
      }
    },

    clear() {
      grid.pending = null
      opts.onSelect([null, null], true)
    },

    onClick(e) {
      const nav = e.target.closest("[data-nav]")
      if (nav) { grid.view = addMonths(grid.view, Number(nav.dataset.nav)); grid.render(); return }
      const action = e.target.closest("[data-action]")
      if (action?.dataset.action === "today") return grid.pick(today())
      if (action?.dataset.action === "clear") return grid.clear()
      const day = e.target.closest("[data-date]")
      if (day) grid.pick(parseISO(day.dataset.date))
    },

    onKeydown(e) {
      const day = e.target.closest("[data-date]")
      if (!day) return
      const d = parseISO(day.dataset.date)
      const moves = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -7, ArrowDown: 7 }
      if (e.key in moves) { e.preventDefault(); return grid.focusDay(addDays(d, moves[e.key])) }
      if (e.key === "PageUp" || e.key === "PageDown") {
        e.preventDefault()
        const n = (e.key === "PageUp" ? -1 : 1) * (e.shiftKey ? 12 : 1)
        const target = new Date(d.getFullYear(), d.getMonth() + n + 1, 0) // last day of target month
        return grid.focusDay(new Date(target.getFullYear(), target.getMonth(), Math.min(d.getDate(), target.getDate())))
      }
      if (e.key === "Home" || e.key === "End") {
        e.preventDefault()
        const off = (d.getDay() - firstDay + 7) % 7
        return grid.focusDay(addDays(d, e.key === "Home" ? -off : 6 - off))
      }
      if (e.key === "Enter" || e.key === " ") { e.preventDefault(); grid.pick(d) }
    },
  }

  el.addEventListener("click", grid.onClick)
  el.addEventListener("keydown", grid.onKeydown)
  return grid
}

// Wrap 42 day buttons into 6 role="row" groups.
function rows(days) {
  const cells = days.split("</button>").filter(Boolean).map((c) => c + "</button>")
  let out = ""
  for (let r = 0; r < 6; r++) out += `<div role="row" class="sl-calendar-row">${cells.slice(r * 7, r * 7 + 7).join("")}</div>`
  return out
}
