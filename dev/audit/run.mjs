// Headless palette audit runner, driven by `mix sink.audit`.
//   node dev/audit/run.mjs <base-url> <palette,...> [--json]
// Loads the sink once, then for each palette × scheme × contrast sets the
// attributes on <html> and calls window.slopAudit(). Exit 1 on any failure.
import { spawn } from "node:child_process"
import { mkdtempSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"

const [base, palettesArg, ...flags] = process.argv.slice(2)
const palettes = (palettesArg || "warm").split(",")
const json = flags.includes("--json")
const chromeBin = process.env.CHROME_BIN || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
const port = 9400 + Math.floor(Math.random() * 400)
const chrome = spawn(chromeBin, ["--headless=new", `--remote-debugging-port=${port}`, `--user-data-dir=${mkdtempSync(join(tmpdir(), "sl-audit-"))}`, "--no-first-run", "--no-default-browser-check", "about:blank"], { stdio: "ignore" })
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

let target
for (let i = 0; i < 50 && !target; i++) {
  try { target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find((t) => t.type === "page") } catch {}
  if (!target) await sleep(100)
}
const ws = new WebSocket(target.webSocketDebuggerUrl)
await new Promise((r) => (ws.onopen = r))
let id = 0; const pending = new Map()
ws.onmessage = (m) => { const msg = JSON.parse(m.data); if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id) } }
const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })) })
const evaluate = async (expression) => (await send("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true })).result?.result?.value

await send("Runtime.enable"); await send("Page.enable")
await send("Page.navigate", { url: `${base}/foundation` })
await sleep(1500)

const report = []
let failed = 0
for (const palette of palettes) {
  for (const scheme of ["light", "dark"]) {
    for (const contrast of ["", "more"]) {
      const r = await evaluate(`(() => { const h = document.documentElement; h.setAttribute("data-palette", ${JSON.stringify(palette)}); h.setAttribute("data-theme", ${JSON.stringify(scheme)}); ${contrast ? 'h.setAttribute("data-contrast", "more")' : 'h.removeAttribute("data-contrast")'}; return window.slopAudit() })()`)
      const minText = Math.min(...r.pairs.filter((p) => p.min === 4.5).map((p) => p.ratio))
      const minNonText = Math.min(...r.pairs.filter((p) => p.min === 3).map((p) => p.ratio))
      const minCvd = Math.min(...Object.values(r.cvd).flat().map((p) => p.distance))
      report.push({ palette, scheme, contrast: contrast || "normal", minText, minNonText, minCvd, fails: r.fails })
      if (r.fails.length) failed++
    }
  }
}
ws.close(); chrome.kill()

if (json) console.log(JSON.stringify(report, null, 2))
else {
  console.log("palette   scheme  contrast  min text  min non-text  min CVD Δ  result")
  for (const r of report) console.log(`${r.palette.padEnd(9)} ${r.scheme.padEnd(7)} ${r.contrast.padEnd(9)} ${String(r.minText).padEnd(9)} ${String(r.minNonText).padEnd(13)} ${String(r.minCvd).padEnd(10)} ${r.fails.length ? "FAIL" : "ok"}`)
  for (const r of report) for (const f of r.fails) console.log(`  ✖ ${r.palette}/${r.scheme}/${r.contrast}: ${f}`)
}
process.exit(failed ? 1 : 0)
