/*
 * SinkBuilder — theme builder page hook. Sliders/selects write custom properties
 * and data attributes onto the preview root, the audit re-runs on every change,
 * and the generated override block is shown for copy/paste.
 */
const HUES = ["neutral", "accent", "success", "warning", "danger", "info"]
const CHROMAS = ["neutral", "accent"]

export default {
  mounted() {
    this.preview = this.el.querySelector("[data-preview]")
    this.out = this.el.querySelector("[data-output]")
    this.results = this.el.querySelector("[data-results]")
    this.cvd = this.el.querySelector("[data-cvd]")
    this.el.addEventListener("input", () => this.apply())
    this.el.addEventListener("change", () => this.apply())
    this.el.querySelector("[data-reset]")?.addEventListener("click", () => { this.el.querySelector("form").reset(); this.apply() })
    this.apply()
  },

  values() {
    const f = new FormData(this.el.querySelector("form"))
    return Object.fromEntries(f.entries())
  },

  apply() {
    const v = this.values()
    const root = this.preview
    const lines = []
    root.removeAttribute("data-palette")
    for (const h of HUES) { root.style.setProperty(`--sl-hue-${h}`, v[`hue-${h}`]); lines.push(`  --sl-hue-${h}: ${v[`hue-${h}`]};`) }
    for (const c of CHROMAS) { root.style.setProperty(`--sl-${c}-chroma`, v[`chroma-${c}`]); lines.push(`  --sl-${c}-chroma: ${v[`chroma-${c}`]};`) }
    for (const attr of ["theme", "dark", "contrast", "density", "radius"]) {
      const val = v[attr]
      if (val && val !== "default" && val !== "system") root.setAttribute(`data-${attr}`, val)
      else root.removeAttribute(`data-${attr}`)
    }
    for (const [k, label] of Object.entries({ "hue-neutral": "Neutral hue", "hue-accent": "Accent hue", "hue-success": "Success hue", "hue-warning": "Warning hue", "hue-danger": "Danger hue", "hue-info": "Info hue", "chroma-neutral": "Neutral chroma", "chroma-accent": "Accent chroma" })) {
      const out = this.el.querySelector(`output[for="builder-${k}"]`)
      if (out) out.textContent = v[k]
    }
    const attrs = ["dark", "contrast", "density", "radius"].filter((a) => v[a] && v[a] !== "default").map((a) => ` data-${a}="${v[a]}"`).join("")
    this.out.textContent = `/* Paste after slop_ui.css */\n:root {\n${lines.join("\n")}\n}${attrs ? `\n\n<!-- and on <html> -->\n<html${attrs}>` : ""}`
    this.audit()
  },

  audit() {
    const r = window.slopAudit(this.preview)
    const minText = Math.min(...r.pairs.filter((p) => p.min === 4.5).map((p) => p.ratio))
    const minNonText = Math.min(...r.pairs.filter((p) => p.min === 3).map((p) => p.ratio))
    const summary = this.el.querySelector("[data-summary]")
    summary.textContent = r.fails.length ? `${r.fails.length} problem${r.fails.length > 1 ? "s" : ""}` : "All pairings pass"
    summary.dataset.color = r.fails.length ? "danger" : "success"
    this.el.querySelector("[data-min-text]").textContent = minText.toFixed(2)
    this.el.querySelector("[data-min-nontext]").textContent = minNonText.toFixed(2)

    this.results.replaceChildren(...r.pairs.map((p) => {
      const tr = document.createElement("tr")
      tr.innerHTML = `<td>${p.label}</td><td><span class="sink-swatch-pair"><i style="background:${p.b}"></i><i style="background:${p.a}"></i></span></td><td data-numeric>${p.ratio.toFixed(2)}</td><td data-numeric>${p.min}</td><td><span class="sl-badge" data-size="sm" data-color="${p.ok ? "success" : "danger"}">${p.ok ? "pass" : "fail"}</span></td>`
      return tr
    }))
    this.cvd.replaceChildren(...Object.entries(r.cvd).map(([kind, pairs]) => {
      const tr = document.createElement("tr")
      const worst = [...pairs].sort((a, b) => a.distance - b.distance).slice(0, 3)
      tr.innerHTML = `<td>${kind}</td>` + worst.map((p) => `<td>${p.pair} <span class="sl-badge" data-size="sm" data-color="${p.distance < r.cvdMin ? "danger" : "success"}">${p.distance}</span></td>`).join("")
      return tr
    }))
  },
}
