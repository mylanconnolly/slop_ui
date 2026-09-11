// Browser smoke-test runner, driven by `mix sink.smoke`.
//   node dev/smoke/run.mjs <base-url> [name,name] [--json]
// Launches headless Chrome, loads every scenario in ./tests/*.mjs and runs
// them one after another in a single tab. Exit 1 on any failure.
import { spawn } from "node:child_process"
import { mkdtempSync, readdirSync } from "node:fs"
import { tmpdir } from "node:os"
import { join, dirname } from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const [base, filterArg = "", ...flags] = process.argv.slice(2)
const filters = filterArg.split(",").filter(Boolean)
const json = flags.includes("--json")
const chromeBin = process.env.CHROME_BIN || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const port = 9400 + Math.floor(Math.random() * 400)
const chrome = spawn(chromeBin, [...(process.env.CHROME_NO_SANDBOX === "1" ? ["--no-sandbox"] : []), "--headless=new", `--remote-debugging-port=${port}`, `--user-data-dir=${mkdtempSync(join(tmpdir(), "sl-smoke-"))}`, "--no-first-run", "--no-default-browser-check", "--window-size=1280,900", "about:blank"], { stdio: ["ignore", "ignore", "pipe"] })
let chromeError = ""
chrome.stderr.on("data", (chunk) => { chromeError = (chromeError + chunk).slice(-8000) })
chrome.on("error", (error) => { chromeError += error.message })
process.on("exit", () => chrome.kill())
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

// One browser connection and one tab. Scenarios navigate to a fresh page
// each, which resets all page state; closing/reopening tabs per scenario
// crashed headless Chrome 152 after a few cycles.
let browser
for (let i = 0; i < 300 && !browser; i++) {
  try { browser = (await (await fetch(`http://127.0.0.1:${port}/json/version`)).json()).webSocketDebuggerUrl } catch {}
  if (!browser) await sleep(100)
}
if (!browser) throw new Error(`Chrome failed to start (${chromeBin}): ${chromeError}`)
const ws = new WebSocket(browser)
await new Promise((r) => (ws.onopen = r))
ws.onclose = (e) => { console.error(`browser connection closed unexpectedly (code ${e.code}); Chrome probably crashed`); chrome.kill(); process.exit(1) }
let id = 0; const pending = new Map()
let events = []
let sessionId = null
ws.onmessage = (m) => { const msg = JSON.parse(m.data); if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id) } else if (msg.method) events.push(msg) }
const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); if (process.env.SMOKE_DEBUG) console.error("->", method, sessionId); ws.send(JSON.stringify({ id: i, method, params, sessionId: sessionId || undefined })) })

async function openTab() {
  const { result: { targetId } } = await send("Target.createTarget", { url: "about:blank" })
  const { result } = await send("Target.attachToTarget", { targetId, flatten: true })
  sessionId = result.sessionId
  events = []
  await send("Runtime.enable"); await send("Page.enable")
  await send("Emulation.setFocusEmulationEnabled", { enabled: true })
  return targetId
}
async function closeTab(targetId) {
  sessionId = null
  await send("Target.closeTarget", { targetId })
}

// ---- page API handed to scenarios -------------------------------------------
const KEYS = {
  Enter: [13, "Enter"], Escape: [27, "Escape"], Tab: [9, "Tab"], Backspace: [8, "Backspace"], Delete: [46, "Delete"],
  " ": [32, "Space"], ArrowLeft: [37, "ArrowLeft"], ArrowUp: [38, "ArrowUp"], ArrowRight: [39, "ArrowRight"], ArrowDown: [40, "ArrowDown"],
  Home: [36, "Home"], End: [35, "End"], PageUp: [33, "PageUp"], PageDown: [34, "PageDown"], F10: [121, "F10"], ContextMenu: [93, "ContextMenu"],
}
const page = {
  sleep,
  async goto(path) {
    await send("Page.navigate", { url: `${base}${path}` })
    await this.waitFor(`document.querySelector("[data-phx-main]")?.classList.contains("phx-connected")`, 8000)
    await sleep(150)
  },
  // Runs an async function body in the page; `return` gives the value back.
  async eval(body) {
    const r = await send("Runtime.evaluate", { expression: `(async () => { ${body} })()`, awaitPromise: true, returnByValue: true })
    if (r.result?.exceptionDetails) throw new Error(r.result.exceptionDetails.exception?.description || "page error")
    return r.result?.result?.value
  },
  async waitFor(expr, timeout = 2000) {
    const started = Date.now()
    while (Date.now() - started < timeout) {
      if (await this.eval(`return !!(${expr})`)) return true
      await sleep(50)
    }
    throw new Error(`timed out waiting for: ${expr}`)
  },
  async rect(selector) {
    const r = await this.eval(`const el = document.querySelector(${JSON.stringify(selector)}); if (!el) return null; el.scrollIntoView({block: "center"}); const b = el.getBoundingClientRect(); return {x: b.x + b.width / 2, y: b.y + b.height / 2}`)
    if (!r) throw new Error(`no element for ${selector}`)
    return r
  },
  async click(selector, { button = "left" } = {}) {
    const { x, y } = await this.rect(selector)
    await send("Input.dispatchMouseEvent", { type: "mouseMoved", x, y })
    await send("Input.dispatchMouseEvent", { type: "mousePressed", x, y, button, clickCount: 1 })
    await send("Input.dispatchMouseEvent", { type: "mouseReleased", x, y, button, clickCount: 1 })
    await sleep(80)
  },
  async hover(selector) {
    const { x, y } = await this.rect(selector)
    await send("Input.dispatchMouseEvent", { type: "mouseMoved", x, y })
  },
  async focus(selector) {
    await this.eval(`document.querySelector(${JSON.stringify(selector)}).focus()`)
  },
  async press(key, { shift = false, meta = false, ctrl = false, alt = false } = {}) {
    const modifiers = (alt ? 1 : 0) | (ctrl ? 2 : 0) | (meta ? 4 : 0) | (shift ? 8 : 0)
    const [code, codeName] = KEYS[key] || [key.toUpperCase().charCodeAt(0), `Key${key.toUpperCase()}`]
    const printable = key.length === 1 && !meta && !ctrl
    // Enter needs a char payload for native activation (summary, buttons, links).
    const text = printable ? key : key === "Enter" ? "\r" : undefined
    await send("Input.dispatchKeyEvent", { type: text ? "keyDown" : "rawKeyDown", key, code: codeName, windowsVirtualKeyCode: code, nativeVirtualKeyCode: code, modifiers, text, unmodifiedText: text })
    await send("Input.dispatchKeyEvent", { type: "keyUp", key, code: codeName, windowsVirtualKeyCode: code, nativeVirtualKeyCode: code, modifiers })
    await sleep(60)
  },
  async type(text) {
    for (const ch of text) await this.press(ch)
  },
  async active() {
    return this.eval(`const a = document.activeElement; return a ? {tag: a.tagName, id: a.id, cls: a.className, role: a.getAttribute("role"), text: a.textContent.trim().slice(0, 40)} : null`)
  },
}
export const ok = (cond, msg) => { if (!cond) throw new Error(msg) }
export const eq = (a, b, msg) => { if (a !== b) throw new Error(`${msg}: expected ${JSON.stringify(b)}, got ${JSON.stringify(a)}`) }

// When the page's main thread is busy, pause the debugger and report where.
async function hungStack() {
  send("Debugger.enable")
  send("Debugger.pause")
  await sleep(1500)
  const paused = events.find((e) => e.method === "Debugger.paused")
  if (!paused) return " (page did not pause; not a JavaScript loop?)"
  const frames = paused.params.callFrames.slice(0, 8).map((f) => `${f.functionName || "(anon)"} ${f.url.split("/").pop()}:${f.location.lineNumber + 1}`)
  send("Debugger.resume")
  return "\n     busy at: " + frames.join(" < ")
}

// ---- run --------------------------------------------------------------------
const dir = join(dirname(fileURLToPath(import.meta.url)), "tests")
const scenarios = []
for (const file of readdirSync(dir).filter((f) => f.endsWith(".mjs")).sort()) {
  const mod = await import(pathToFileURL(join(dir, file)))
  for (const s of mod.default) scenarios.push({ file, ...s })
}
await openTab()
const selected = scenarios.filter((s) => filters.length === 0 || filters.some((f) => s.name.includes(f) || s.file.includes(f)))
const results = []
for (const s of selected) {
  const started = Date.now()
  if (process.env.SMOKE_DEBUG) console.error(`== ${s.name}`)
  events = []
  try {
    // A hung page (busy main thread) must fail the scenario, not the run.
    await Promise.race([
      (async () => { await page.goto(s.path); await s.run(page, { ok, eq }) })(),
      sleep(20000).then(() => { throw new Error("scenario timed out after 20s") }),
    ])
    results.push({ name: s.name, ok: true, ms: Date.now() - started })
  } catch (e) {
    let error = e.message
    if (error.startsWith("scenario timed out")) error += await hungStack()
    results.push({ name: s.name, ok: false, ms: Date.now() - started, error })
  }
}
ws.onclose = null; ws.close(); chrome.kill()

const failed = results.filter((r) => !r.ok)
if (json) console.log(JSON.stringify(results, null, 2))
else {
  for (const r of results) console.log(`${r.ok ? "ok  " : "FAIL"} ${r.name.padEnd(48)} ${String(r.ms).padStart(5)}ms${r.ok ? "" : `\n     ${r.error}`}`)
  console.log(`\n${results.length - failed.length} passed, ${failed.length} failed`)
}
process.exit(failed.length ? 1 : 0)
