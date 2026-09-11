export default [
  {
    name: "tree: arrows move, Right/Left expand and collapse, Enter selects",
    path: "/tree",
    async run(p, { ok, eq }) {
      await p.focus('#files [role=treeitem][tabindex="0"]')
      eq((await p.active()).role, "treeitem", "roving tab stop on a tree item")
      await p.press("Home")
      const first = (await p.active()).text
      await p.press("ArrowDown")
      ok((await p.active()).text !== first, "ArrowDown moves to the next visible row")
      await p.press("Home")
      const expanded = await p.eval(`return document.activeElement.getAttribute("aria-expanded")`)
      if (expanded === "true") { await p.press("ArrowLeft"); eq(await p.eval(`return document.activeElement.getAttribute("aria-expanded")`), "false", "ArrowLeft collapses") }
      await p.press("ArrowRight")
      eq(await p.eval(`return document.activeElement.getAttribute("aria-expanded")`), "true", "ArrowRight expands")
      await p.press("ArrowRight")
      eq(await p.eval(`return Number(document.activeElement.getAttribute("aria-level"))`), 2, "second ArrowRight enters the branch")
      await p.press(" ")
      eq(await p.eval(`return document.activeElement.getAttribute("aria-selected")`), "true", "Space selects")
      eq(await p.eval(`return document.querySelectorAll('#files [role=treeitem][tabindex="0"]').length`), 1, "single tab stop")
    },
  },
  {
    name: "context menu: right-click opens at pointer, Shift+F10 opens from keyboard",
    path: "/menus",
    async run(p, { ok, eq }) {
      await p.eval(`const t = document.querySelector(".sl-context-menu-target"); t.scrollIntoView({block: "center"}); const b = t.getBoundingClientRect(); t.dispatchEvent(new MouseEvent("contextmenu", {bubbles: true, cancelable: true, clientX: b.x + 20, clientY: b.y + 20}))`)
      await p.waitFor(`document.querySelector(".sl-context-menu .sl-menu-list").matches(":popover-open")`)
      ok(await p.eval(`const l = document.querySelector(".sl-context-menu .sl-menu-list").getBoundingClientRect(); const b = document.querySelector(".sl-context-menu-target").getBoundingClientRect(); return Math.abs(l.x - (b.x + 20)) < 4 && Math.abs(l.y - (b.y + 20)) < 4`), "list opens at the pointer")
      await p.press("ArrowDown")
      eq((await p.active()).role, "menuitem", "arrow focuses an item")
      await p.press("Escape")
      await p.waitFor(`!document.querySelector(".sl-context-menu .sl-menu-list").matches(":popover-open")`)
      await p.focus(".sl-context-menu-target")
      await p.press("F10", { shift: true })
      await p.waitFor(`document.querySelector(".sl-context-menu .sl-menu-list").matches(":popover-open")`)
      await p.press("Escape")
      ok(await p.eval(`return document.activeElement.classList.contains("sl-context-menu-target")`), "focus returns to the target")
    },
  },
  {
    name: "hover card: opens on focus, closes on Escape",
    path: "/hover-card",
    async run(p) {
      await p.focus(".sl-hover-card a, .sl-hover-card button")
      await p.waitFor(`document.querySelector(".sl-hover-card-panel").matches(":popover-open")`, 3000)
      await p.press("Escape")
      await p.waitFor(`!document.querySelector(".sl-hover-card-panel").matches(":popover-open")`)
    },
  },
  {
    name: "calendar: grid keys move by day/week/month, Enter writes the value",
    path: "/dates",
    async run(p, { ok, eq }) {
      await p.focus('#cal-single [role=gridcell][tabindex="0"], #cal-single [role=gridcell] [tabindex="0"]')
      const date = () => p.eval(`return document.activeElement.dataset.date || document.activeElement.closest("[data-date]")?.dataset.date`)
      const d0 = await date()
      await p.press("ArrowRight")
      const d1 = await date()
      ok(d1 > d0, "ArrowRight moves forward a day")
      await p.press("ArrowDown")
      ok((await date()) > d1, "ArrowDown moves forward a week")
      await p.press("PageDown")
      ok((await date()).slice(0, 7) !== d1.slice(0, 7), "PageDown moves a month")
      await p.press("Enter")
      await p.sleep(100)
      const v = await p.eval(`return document.querySelector('#cal-single-value')?.value`)
      eq(v, await date(), "Enter selects the focused day")
    },
  },
  {
    name: "time picker: clock button opens slots, arrows + Enter fill the input",
    path: "/dates",
    async run(p, { ok }) {
      await p.click(".sl-time-picker [data-interactive] button")
      await p.waitFor(`document.querySelector(".sl-time-list").matches(":popover-open")`)
      await p.press("ArrowDown"); await p.press("ArrowDown"); await p.press("Enter")
      await p.waitFor(`!document.querySelector(".sl-time-list").matches(":popover-open")`)
      ok(/^\d{2}:\d{2}/.test(await p.eval(`return document.querySelector(".sl-time-picker input[type=time]").value`)), "time input filled")
    },
  },
  {
    name: "table: header checkbox selects all and goes indeterminate",
    path: "/tables",
    async run(p, { eq, ok }) {
      await p.click(".sl-table-select-cell .sl-table-select")
      await p.sleep(200)
      const rows = await p.eval(`return document.querySelectorAll('tbody .sl-table-select-cell input[type=checkbox]').length`)
      eq(await p.eval(`return document.querySelectorAll('tbody .sl-table-select-cell input[type=checkbox]:checked').length`), rows, "all rows selected")
      await p.eval(`document.querySelector('tbody .sl-table-select-cell input[type=checkbox]').click()`)
      await p.sleep(200)
      ok(await p.eval(`return document.querySelector(".sl-table-select-cell .sl-table-select").indeterminate`), "header goes indeterminate")
    },
  },
]
