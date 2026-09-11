export default [
  {
    name: "dialog opens on sl:open, traps focus, closes on Escape",
    path: "/dialogs",
    async run(p, { ok }) {
      await p.eval(`document.querySelector("dialog.sl-dialog").dispatchEvent(new CustomEvent("sl:open"))`)
      await p.waitFor(`document.querySelector("dialog.sl-dialog").open`)
      ok(await p.eval(`return document.querySelector("dialog.sl-dialog").contains(document.activeElement)`), "focus moved into the dialog")
      await p.press("Escape")
      await p.waitFor(`!document.querySelector("dialog.sl-dialog").open`)
      ok(!(await p.eval(`return document.documentElement.hasAttribute("data-sl-scroll-lock") || getComputedStyle(document.body).overflow === "hidden"`)), "scroll lock released")
    },
  },
  {
    name: "sheet opens and closes",
    path: "/dialogs",
    async run(p) {
      await p.eval(`document.querySelector("dialog.sl-sheet").dispatchEvent(new CustomEvent("sl:open"))`)
      await p.waitFor(`document.querySelector("dialog.sl-sheet").open`)
      await p.press("Escape")
      await p.waitFor(`!document.querySelector("dialog.sl-sheet").open`)
    },
  },
  {
    name: "menu: click opens, arrows move, Escape returns focus to trigger",
    path: "/menus",
    async run(p, { ok, eq }) {
      await p.click(".sl-menu > button")
      await p.waitFor(`document.querySelector(".sl-menu .sl-menu-list").matches(":popover-open")`)
      await p.press("ArrowDown")
      eq((await p.active()).role, "menuitem", "ArrowDown focuses a menu item")
      const first = (await p.active()).text
      await p.press("ArrowDown")
      ok((await p.active()).text !== first, "second ArrowDown moves to the next item")
      await p.press("End")
      const last = (await p.active()).text
      await p.press("Home")
      ok((await p.active()).text !== last, "Home moves to the first item")
      await p.press("Escape")
      await p.waitFor(`!document.querySelector(".sl-menu .sl-menu-list").matches(":popover-open")`)
      eq((await p.active()).tag, "BUTTON", "focus returns to the trigger")
    },
  },
  {
    name: "menu: ArrowRight opens a submenu",
    path: "/menus",
    async run(p, { ok }) {
      const has = await p.eval(`return !!document.querySelector(".sl-menu-sub")`)
      if (!has) return
      await p.eval(`document.querySelector(".sl-menu:has(.sl-menu-sub) > button").click()`)
      await p.waitFor(`document.querySelector(".sl-menu:has(.sl-menu-sub) .sl-menu-list").matches(":popover-open")`)
      await p.eval(`document.querySelector(".sl-menu-sub > [role=menuitem]").focus()`)
      await p.press("ArrowRight")
      await p.waitFor(`document.querySelector(".sl-menu-sub .sl-menu-list").matches(":popover-open")`)
      ok((await p.active()).role === "menuitem", "focus lands inside the submenu")
      await p.press("ArrowLeft")
      await p.waitFor(`!document.querySelector(".sl-menu-sub .sl-menu-list").matches(":popover-open")`)
    },
  },
  {
    name: "popover: click toggles, Escape closes",
    path: "/popover",
    async run(p) {
      await p.click(".sl-popover > button")
      await p.waitFor(`document.querySelector(".sl-popover-panel").matches(":popover-open")`)
      await p.press("Escape")
      await p.waitFor(`!document.querySelector(".sl-popover-panel").matches(":popover-open")`)
    },
  },
  {
    name: "tooltip: shows on focus, hides on Escape",
    path: "/tooltips",
    async run(p) {
      await p.focus(".sl-tooltip-trigger > *")
      await p.waitFor(`document.querySelector(".sl-tooltip").matches(":popover-open")`, 3000)
      await p.press("Escape")
      await p.waitFor(`!document.querySelector(".sl-tooltip").matches(":popover-open")`)
    },
  },
  {
    name: "toaster: client toast appears and dismisses",
    path: "/toasts",
    async run(p, { eq }) {
      const before = await p.eval(`return document.querySelectorAll(".sl-toast").length`)
      await p.eval(`window.dispatchEvent(new CustomEvent("sl:toast", {detail: {title: "Smoke", color: "success"}}))`)
      await p.waitFor(`document.querySelectorAll(".sl-toast").length === ${before + 1}`)
      await p.eval(`[...document.querySelectorAll(".sl-toast")].at(-1).querySelector("[data-sl-dismiss]").click()`)
      await p.sleep(600)
      eq(await p.eval(`return document.querySelectorAll(".sl-toast").length`), before, "toast removed")
    },
  },
]
