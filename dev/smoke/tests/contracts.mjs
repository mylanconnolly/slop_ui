export default [
  {
    name: "contracts: multiple combobox commits, removes, and accepts server patches",
    path: "/_contracts",
    async run(p, { eq, ok }) {
      await p.focus("#multi-input")
      await p.type("Alpha"); await p.press("Enter")
      await p.waitFor(`document.querySelector('#values').textContent === 'a'`)
      eq(await p.eval(`return document.querySelector('#multi [role=option][data-value=a]').getAttribute('aria-selected')`), "true", "selected survives patch")
      await p.press("Escape")
      await p.focus("#multi-input"); await p.press("Backspace")
      await p.waitFor(`document.querySelector('#values').textContent === ''`)
      await p.click("#replace")
      await p.waitFor(`document.querySelector('#multi .sl-chip')?.dataset.value === 'b'`)
      eq(await p.eval(`return document.querySelector('#multi [role=option][data-value=b]').getAttribute('aria-selected')`), "true", "server selection reflected")
      await p.click("#multi [data-sl-remove]")
      await p.waitFor(`document.querySelector('#values').textContent === ''`)
      await p.focus("#custom-input"); await p.type("New tag"); await p.press("Enter")
      eq(await p.eval(`return new FormData(document.querySelector('#custom-form')).getAll('custom[]').filter(Boolean).join(',')`), "New tag", "custom tag submitted once")
      ok(await p.eval(`return document.querySelector('#custom-form').checkValidity()`), "selected custom tag satisfies required")
    },
  },
  {
    name: "contracts: required fields block submission and focus the visible control",
    path: "/_contracts",
    async run(p, { eq, ok }) {
      ok(await p.eval(`return [...document.querySelectorAll("[data-sl-validation]")].every(el => !el.checkVisibility())`), "validation messages start hidden")
      for (const [form, focus] of [["multi", "multi-input"], ["single", "single-input"], ["select", "select-trigger"], ["radio", "radio-0"], ["checks", "checks-0"]]) {
        await p.click(`#${form}-form button[type=submit]`)
        eq((await p.active()).id, focus, `${form} invalid focus`)
        eq(await p.eval(`return document.querySelector('#submissions').textContent`), "0", `${form} blocked submission`)
      }
      await p.click("#checks-1")
      ok(await p.eval(`return document.querySelector('#checks-form').checkValidity()`), "one checkbox is sufficient")
      await p.click("#checks-1")
      ok(!(await p.eval(`return document.querySelector('#checks-form').checkValidity()`)), "removing last choice invalidates group")
      await p.click("#radio-1")
      ok(await p.eval(`return document.querySelector('#radio-form').checkValidity()`), "radio choice valid")
      await p.focus("#select-trigger"); await p.press("ArrowDown"); await p.press("Enter")
      ok(await p.eval(`return document.querySelector('#select-form').checkValidity()`), "select choice valid")
      await p.focus("#single-input"); await p.type("a"); await p.press("Enter")
      ok(await p.eval(`return document.querySelector('#single-form').checkValidity()`), "committed single choice valid")
      await p.focus("#single-input"); await p.type("x")
      ok(!(await p.eval(`return document.querySelector('#single-form').checkValidity()`)), "uncommitted query is invalid")
    },
  },
  {
    name: "contracts: disabled, readonly, loading, and multiple errors",
    path: "/_contracts",
    async run(p, { eq, ok }) {
      ok(await p.eval(`return [...document.querySelectorAll('#disabled-form input, #disabled-form select, #disabled-form button')].every(el => el.disabled)`), "every disabled control is disabled")
      eq(await p.eval(`return [...new FormData(document.querySelector('#disabled-form'))].length`), 0, "disabled values do not submit")
      for (const id of ["readonly-date", "readonly-time"]) {
        ok(await p.eval(`return document.querySelector('#${id}').readOnly`), `${id} readonly`)
        ok(await p.eval(`return document.querySelector('#${id}').closest('.sl-date-picker, .sl-time-picker').querySelector('button').disabled`), `${id} popup disabled`)
      }
      for (const id of ["loading", "loading-link"]) {
        ok(await p.eval(`const el = document.querySelector('#${id}'); return el.tagName === 'BUTTON' && el.disabled && el.hasAttribute('data-loading')`), `${id} disabled and loading`)
        await p.eval(`document.querySelector('#${id}').click()`)
        await p.focus(`#${id}`)
        ok((await p.active()).id !== id, `${id} cannot receive keyboard focus`)
      }
      eq(await p.eval(`return document.querySelector('#submissions').textContent`), "0", "loading actions never dispatched")
      eq(await p.eval(`return document.querySelectorAll('#errors-error').length`), 1, "one error description ID")
      ok(await p.eval(`const text = document.querySelector('#errors-error').textContent; return text.includes('First error') && text.includes('Second error')`), "both errors described")
    },
  },
]
