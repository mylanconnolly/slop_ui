import { test } from "node:test"
import assert from "node:assert/strict"
import SlDialog from "./dialog.js"

// Minimal stand-ins for <dialog> and the LiveView hook context.
function mount(dataOpen = "false") {
  const listeners = {}
  const el = {
    id: "d",
    open: false,
    dataset: { open: dataOpen, dismiss: "true" },
    closedBy: "any",
    hasAttribute: () => false,
    getAttribute: () => null,
    querySelector: () => null,
    addEventListener: (type, fn) => (listeners[type] ||= []).push(fn),
    showModal() { this.open = true },
    close() { this.open = false },
  }
  const hook = Object.create(SlDialog)
  Object.assign(hook, { el, js: () => ({ ignoreAttributes() {} }), liveSocket: { execJS() {} } })
  globalThis.window ??= { innerWidth: 0 }
  globalThis.document ??= { documentElement: { clientWidth: 0, style: { setProperty() {} } } }
  hook.mounted()
  const dispatch = (type) => (listeners[type] || []).forEach((fn) => fn())
  return { el, hook, dispatch }
}

test("a JS-opened dialog survives server patches that leave data-open unchanged", () => {
  const { el, hook, dispatch } = mount("false")
  dispatch("sl:open")
  assert.equal(el.open, true)
  hook.updated() // e.g. phx-change re-render while typing
  assert.equal(el.open, true)
})

test("server changes to data-open still open and close the dialog", () => {
  const { el, hook } = mount("false")
  el.dataset.open = "true"
  hook.updated()
  assert.equal(el.open, true)
  el.dataset.open = "false"
  hook.updated()
  assert.equal(el.open, false)
})

test("a dialog the user dismissed is not reopened by an unrelated patch", () => {
  const { el, hook } = mount("true")
  assert.equal(el.open, true)
  el.close() // Escape / backdrop
  hook.updated()
  assert.equal(el.open, false)
})
