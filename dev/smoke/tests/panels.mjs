export default [
  {
    name: "split panel: arrows resize the divider, Home/End hit the limits, Enter collapses",
    path: "/panels",
    async run(p, { ok, eq }) {
      await p.eval(`localStorage.clear()`)
      await p.focus("#files .sl-split-handle")
      const v0 = await p.eval(`return Number(document.activeElement.getAttribute("aria-valuenow"))`)
      await p.press("ArrowRight")
      eq(await p.eval(`return Number(document.activeElement.getAttribute("aria-valuenow"))`), v0 + 1, "ArrowRight adds 1%")
      await p.press("ArrowRight", { shift: true })
      eq(await p.eval(`return Number(document.activeElement.getAttribute("aria-valuenow"))`), v0 + 11, "Shift+ArrowRight adds 10%")
      await p.press("Home")
      eq(await p.eval(`return Number(document.activeElement.getAttribute("aria-valuenow"))`), Number(await p.eval(`return document.activeElement.getAttribute("aria-valuemin")`)), "Home hits min")
      await p.press("End")
      eq(await p.eval(`return Number(document.activeElement.getAttribute("aria-valuenow"))`), Number(await p.eval(`return document.activeElement.getAttribute("aria-valuemax")`)), "End hits max")
      await p.press("Enter")
      ok(await p.eval(`return document.querySelector("#files").hasAttribute("data-collapsed")`), "Enter collapses")
      await p.press("Enter")
      ok(!(await p.eval(`return document.querySelector("#files").hasAttribute("data-collapsed")`)), "Enter restores")
    },
  },
  {
    name: "carousel: next button and arrow keys move slides, dots follow",
    path: "/panels",
    async run(p, { ok, eq }) {
      const dots = `[...document.querySelectorAll("#posts .sl-carousel-dot")]`
      const current = () => p.eval(`return ${dots}.findIndex(d => d.getAttribute("aria-selected") === "true")`)
      eq(await current(), 0, "starts on the first slide")
      await p.focus("#posts .sl-carousel-track")
      await p.press("ArrowRight")
      await p.waitFor(`${dots}.findIndex(d => d.getAttribute("aria-selected") === "true") === 1`, 3000)
      await p.press("End")
      await p.waitFor(`${dots}.at(-1).getAttribute("aria-selected") === "true"`, 3000)
      await p.press("Home")
      await p.waitFor(`${dots}[0].getAttribute("aria-selected") === "true"`, 3000)
      ok(await p.eval(`return document.querySelector("#posts [data-sl-announce]").textContent.length > 0`), "slide change announced")
    },
  },
  {
    name: "color input: preset arrows move and pick, native input fires change",
    path: "/inputs",
    async run(p, { ok, eq }) {
      await p.eval(`window.__changes = 0; document.querySelector(".sl-color input[type=color]").addEventListener("change", () => window.__changes++)`)
      await p.focus('.sl-color [role=radio][tabindex="0"]')
      const first = await p.eval(`return document.querySelector(".sl-color input[type=color]").value`)
      await p.press("ArrowRight")
      eq((await p.active()).role, "radio", "focus stays on a preset")
      eq(await p.eval(`return document.activeElement.getAttribute("aria-checked")`), "true", "ArrowRight picks the next preset")
      ok(await p.eval(`return document.querySelector(".sl-color input[type=color]").value`) !== first, "native input follows")
      ok(await p.eval(`return window.__changes > 0`), "change event fired on the native input")
    },
  },
  {
    name: "counter: updates per keystroke and flags the soft limit",
    path: "/forms",
    async run(p, { ok }) {
      await p.focus('input[name="title"]')
      await p.eval(`document.activeElement.value = ""; document.activeElement.dispatchEvent(new Event("input", {bubbles: true}))`)
      await p.type("x".repeat(21))
      await p.sleep(100)
      const el = `document.querySelector('.sl-counter[data-for="' + document.activeElement.id + '"]')`
      ok(await p.eval(`return ${el}.textContent.includes("21")`), "counter shows 21")
      ok(await p.eval(`return ${el}.dataset.state === "over"`), "over state set")
    },
  },
]
