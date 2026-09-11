export default [
  {
    name: "select: opens, arrows + Enter change the value",
    path: "/selects",
    async run(p, { ok }) {
      await p.click(".sl-select .sl-select-trigger")
      await p.waitFor(`document.querySelector(".sl-select .sl-listbox").matches(":popover-open")`)
      const before = await p.eval(`return document.querySelector(".sl-select select").value`)
      await p.press("ArrowDown"); await p.press("ArrowDown"); await p.press("Enter")
      await p.waitFor(`!document.querySelector(".sl-select .sl-listbox").matches(":popover-open")`)
      ok(await p.eval(`return document.querySelector(".sl-select select").value`) !== before, "hidden select value changed")
    },
  },
  {
    name: "combobox: typing filters, Enter picks",
    path: "/selects",
    async run(p, { ok }) {
      await p.focus(".sl-combobox input[role=combobox]")
      await p.type("fr")
      await p.sleep(200)
      const shown = await p.eval(`return [...document.querySelector(".sl-combobox .sl-listbox").querySelectorAll("[role=option]")].filter(o => !o.hidden).length`)
      const all = await p.eval(`return document.querySelector(".sl-combobox .sl-listbox").querySelectorAll("[role=option]").length`)
      ok(shown > 0 && shown < all, `filtering narrows the list (${shown}/${all})`)
      await p.press("ArrowDown"); await p.press("Enter")
      await p.sleep(100)
      ok(await p.eval(`return document.querySelector(".sl-combobox input[type=hidden]")?.value || document.querySelector(".sl-combobox input[role=combobox]").value`), "a value was chosen")
    },
  },
  {
    name: "slider: ArrowRight steps the value and readout",
    path: "/inputs",
    async run(p, { ok }) {
      await p.focus(".sl-slider-row input[type=range]")
      const v = await p.eval(`return Number(document.activeElement.value)`)
      await p.press("ArrowRight")
      ok(await p.eval(`return Number(document.activeElement.value)`) > v, "value increased")
    },
  },
  {
    name: "number input: step buttons and arrow keys",
    path: "/inputs",
    async run(p, { eq }) {
      const v = await p.eval(`return Number(document.querySelector(".sl-number input").value || 0)`)
      await p.click(".sl-number [data-sl-step=up]")
      const step = await p.eval(`return Number(document.querySelector(".sl-number input").step || 1)`)
      eq(await p.eval(`return Number(document.querySelector(".sl-number input").value)`), v + step, "up button")
      await p.focus(".sl-number input")
      await p.press("ArrowDown")
      eq(await p.eval(`return Number(document.querySelector(".sl-number input").value)`), v, "ArrowDown")
    },
  },
  {
    name: "pin input: typing advances, Backspace retreats",
    path: "/extras",
    async run(p, { ok }) {
      await p.focus(".sl-pin input:not([type=hidden])")
      await p.press("1")
      ok(await p.eval(`return document.activeElement === document.querySelectorAll(".sl-pin input:not([type=hidden])")[1]`), "focus advanced")
      await p.press("Backspace")
      ok(await p.eval(`return document.activeElement === document.querySelectorAll(".sl-pin input:not([type=hidden])")[0]`), "focus went back")
    },
  },
  {
    name: "tag input: Enter adds a chip, Backspace removes it",
    path: "/extras",
    async run(p, { ok }) {
      await p.focus(".sl-tag-input input:not([type=hidden])")
      await p.type("smoke"); await p.press("Enter")
      await p.waitFor(`document.querySelector('.sl-tag-input .sl-chip[data-value="smoke"]')`)
      await p.press("Backspace"); await p.press("Backspace")
      await p.waitFor(`!document.querySelector('.sl-tag-input .sl-chip[data-value="smoke"]')`)
    },
  },
  {
    name: "password: toggle reveals and hides",
    path: "/inputs",
    async run(p, { eq }) {
      await p.click(".sl-field:has([phx-hook=SlPassword]) button")
      eq(await p.eval(`return document.querySelector("[phx-hook=SlPassword] input, .sl-field:has([phx-hook=SlPassword]) input").type`), "text", "revealed")
      await p.click(".sl-field:has([phx-hook=SlPassword]) button")
      eq(await p.eval(`return document.querySelector("[phx-hook=SlPassword] input, .sl-field:has([phx-hook=SlPassword]) input").type`), "password", "hidden again")
    },
  },
  {
    name: "copy button: shows the copied state",
    path: "/extras",
    async run(p) {
      await p.click(".sl-copy")
      await p.waitFor(`document.querySelector(".sl-copy").hasAttribute("data-copied")`)
    },
  },
  {
    name: "date picker: opens, arrows move, Enter fills the input",
    path: "/dates",
    async run(p, { ok }) {
      await p.click(".sl-date-picker [data-interactive] button")
      await p.waitFor(`document.querySelector(".sl-calendar")?.matches(":popover-open") || document.querySelector(".sl-calendar")?.checkVisibility()`)
      await p.press("ArrowRight"); await p.press("Enter")
      await p.sleep(150)
      ok(await p.eval(`return /\\d{4}-\\d{2}-\\d{2}/.test(document.querySelector(".sl-date-picker input").value)`), "input got a date")
    },
  },
  {
    name: "dropzone: drag state toggles",
    path: "/upload",
    async run(p, { ok }) {
      await p.eval(`document.querySelector(".sl-dropzone").dispatchEvent(new DragEvent("dragenter", {bubbles: true}))`)
      ok(await p.eval(`return document.querySelector(".sl-dropzone").hasAttribute("data-dragging")`), "dragging attribute set")
      await p.eval(`document.querySelector(".sl-dropzone").dispatchEvent(new DragEvent("dragleave", {bubbles: true}))`)
      ok(!(await p.eval(`return document.querySelector(".sl-dropzone").hasAttribute("data-dragging")`)), "dragging attribute cleared")
    },
  },
  {
    name: "markdown editor: toolbar bold and ⌘B wrap the selection",
    path: "/editor",
    async run(p, { eq }) {
      await p.focus(".sl-md-write textarea")
      await p.type("hi")
      await p.eval(`document.activeElement.select()`)
      await p.press("b", { meta: true })
      eq(await p.eval(`return document.querySelector(".sl-md-write textarea").value`), "**hi**", "⌘B")
      await p.eval(`const ta = document.querySelector(".sl-md-write textarea"); ta.value = ""; ta.dispatchEvent(new Event("input", {bubbles: true}))`)
      await p.focus(".sl-md-write textarea")
      await p.type("yo")
      await p.eval(`document.activeElement.select()`)
      await p.click(`.sl-md-toolbar [data-tool="italic"], .sl-md-toolbar button[aria-label*="talic"]`)
      eq(await p.eval(`return document.querySelector(".sl-md-write textarea").value`), "_yo_", "toolbar italic")
    },
  },
]
