export default [
  {
    name: "tabs: arrows activate and the indicator slides",
    path: "/tabs",
    async run(p, { ok, eq }) {
      await p.focus(".sl-tablist [role=tab][aria-selected=true]")
      const x0 = await p.eval(`return document.querySelector(".sl-tablist").style.getPropertyValue("--_x")`)
      await p.press("ArrowRight")
      eq((await p.active()).role, "tab", "focus stays on a tab")
      ok(await p.eval(`return document.activeElement.getAttribute("aria-selected") === "true"`), "automatic activation")
      ok(await p.eval(`return !document.getElementById(document.activeElement.getAttribute("aria-controls")).hidden`), "panel shown")
      await p.sleep(400)
      ok(await p.eval(`return document.querySelector(".sl-tablist").style.getPropertyValue("--_x")`) !== x0, "indicator moved")
      await p.press("Home")
      ok(await p.eval(`return document.activeElement === document.querySelector(".sl-tablist [role=tab]")`), "Home goes to the first tab")
    },
  },
  {
    name: "accordion: arrows move between headers, Enter toggles",
    path: "/accordion",
    async run(p, { ok, eq }) {
      await p.focus(".sl-accordion-trigger")
      await p.press("ArrowDown")
      ok(await p.eval(`return document.activeElement === document.querySelectorAll(".sl-accordion .sl-accordion-trigger")[1]`), "ArrowDown moves to the second header")
      await p.press("End")
      ok(await p.eval(`return document.activeElement === [...document.querySelector(".sl-accordion").querySelectorAll(":scope > .sl-accordion-item > .sl-accordion-trigger")].at(-1)`), "End moves to the last header")
      const open = await p.eval(`return document.activeElement.parentElement.open`)
      await p.press("Enter")
      await p.sleep(100)
      eq(await p.eval(`return document.activeElement.parentElement.open`), !open, "Enter toggles the item")
    },
  },
  {
    name: "theme toggle: sets data-theme and persists",
    path: "/themes",
    async run(p, { eq }) {
      await p.eval(`localStorage.removeItem("sl-theme")`)
      await p.click('.sl-theme-toggle label:has(input[value="dark"])')
      await p.waitFor(`document.documentElement.dataset.theme === "dark"`)
      eq(await p.eval(`return localStorage.getItem("sl-theme")`), "dark", "preference persisted")
      await p.click('.sl-theme-toggle label:has(input[value="light"])')
      await p.waitFor(`document.documentElement.dataset.theme === "light"`)
      await p.eval(`localStorage.removeItem("sl-theme")`)
    },
  },
  {
    name: "app shell: skip link is first in tab order and moves focus to main",
    path: "/templates/dashboard",
    async run(p, { eq, ok }) {
      await p.eval(`document.body.focus()`)
      await p.press("Tab")
      eq((await p.active()).cls, "sl-skip-link", "first Tab lands on the skip link")
      await p.waitFor(`getComputedStyle(document.activeElement).opacity === "1"`)
      await p.press("Enter")
      await p.sleep(100)
      eq((await p.active()).cls, "sl-app-main", "main receives focus")
    },
  },
  {
    name: "command palette: ⌘K opens, typing filters, Escape closes",
    path: "/command",
    async run(p, { ok }) {
      await p.press("k", { meta: true })
      await p.waitFor(`document.querySelector("dialog.sl-command")?.open`)
      ok(await p.eval(`return document.activeElement.classList.contains("sl-command-input")`), "input focused")
      const total = await p.eval(`return document.querySelectorAll(".sl-command-item:not([hidden])").length`)
      await p.type("zzzz")
      await p.sleep(150)
      const after = await p.eval(`return document.querySelectorAll(".sl-command-item:not([hidden])").length`)
      ok(after < total, "typing filters the list")
      await p.press("Escape")
      await p.waitFor(`!document.querySelector("dialog.sl-command").open`)
    },
  },
]
