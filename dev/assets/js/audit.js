/*
 * Browser-side palette audit. Exposed as window.slopAudit(root) so both the
 * kitchen sink's theme builder and `mix sink.audit` (via CDP) can call it.
 *
 * Measures WCAG 2 contrast for every token pairing the theme promises, and
 * simulates protan/deutan/tritan vision to check the semantic families stay
 * distinguishable. Returns { pairs: [{label, a, b, ratio, min, ok}], cvd: {...}, fails: [...] }.
 */
const FAMILIES = ["accent", "success", "warning", "danger", "info"]

export function audit(root = document.documentElement) {
  const cv = document.createElement("canvas")
  cv.width = cv.height = 1
  const ctx = cv.getContext("2d", { willReadFrequently: true })
  const probe = document.createElement("div")
  probe.style.display = "none"
  root.append(probe)

  const rgb = (token) => {
    probe.style.color = `var(${token})`
    const c = getComputedStyle(probe).color
    ctx.fillStyle = "#fff"; ctx.fillRect(0, 0, 1, 1)
    ctx.fillStyle = c; ctx.fillRect(0, 0, 1, 1)
    const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data
    return [r, g, b]
  }
  const lin = (c) => { c /= 255; return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4 }
  const lum = ([r, g, b]) => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
  const contrast = (a, b) => { const [h, l] = [lum(a), lum(b)].sort((x, y) => y - x); return (h + 0.05) / (l + 0.05) }
  const hex = ([r, g, b]) => "#" + [r, g, b].map((v) => v.toString(16).padStart(2, "0")).join("")

  const pairs = [
    ["text on page", "--sl-color-fg", "--sl-color-bg", 4.5],
    ["text on surface", "--sl-color-fg", "--sl-color-surface", 4.5],
    ["text on sunken", "--sl-color-fg", "--sl-color-surface-sunken", 4.5],
    ["muted text on page", "--sl-color-fg-muted", "--sl-color-bg", 4.5],
    ["muted text on sunken", "--sl-color-fg-muted", "--sl-color-surface-sunken", 4.5],
    ["subtle text on page", "--sl-color-fg-subtle", "--sl-color-bg", 4.5],
    ["subtle text on surface", "--sl-color-fg-subtle", "--sl-color-surface", 4.5],
    ["placeholder on sunken", "--sl-color-fg-subtle", "--sl-color-surface-sunken", 4.5],
    ["link on page", "--sl-color-accent-text", "--sl-color-bg", 4.5],
    ["link on sunken", "--sl-color-accent-text", "--sl-color-surface-sunken", 4.5],
    ["input border", "--sl-color-border-strong", "--sl-color-surface", 3],
    ["focus ring on page", "--sl-color-focus", "--sl-color-bg", 3],
    ["focus ring on surface", "--sl-color-focus", "--sl-color-surface", 3],
    ["neutral button text", "--sl-color-neutral-fg", "--sl-color-neutral", 4.5],
    ["neutral soft text", "--sl-color-neutral-soft-fg", "--sl-color-neutral-soft", 4.5],
  ]
  for (const f of FAMILIES) {
    pairs.push([`${f} button text`, `--sl-color-${f}-fg`, `--sl-color-${f}`, 4.5])
    pairs.push([`${f} button on page`, `--sl-color-${f}`, `--sl-color-bg`, 3])
    pairs.push([`${f} soft text`, `--sl-color-${f}-soft-fg`, `--sl-color-${f}-soft`, 4.5])
    pairs.push([`${f} text on page`, `--sl-color-${f}-text`, `--sl-color-bg`, 4.5])
    pairs.push([`${f} text on surface`, `--sl-color-${f}-text`, `--sl-color-surface`, 4.5])
  }
  const results = pairs.map(([label, a, b, min]) => {
    const ra = rgb(a), rb = rgb(b)
    const ratio = contrast(ra, rb)
    return { label, a: hex(ra), b: hex(rb), ratio: Math.round(ratio * 100) / 100, min, ok: ratio >= min }
  })

  // Colour-vision simulation (Viénot/Brettel-style linear-RGB matrices) and Lab distance.
  const M = {
    protan: [[0.567, 0.433, 0], [0.558, 0.442, 0], [0, 0.242, 0.758]],
    deutan: [[0.625, 0.375, 0], [0.7, 0.3, 0], [0, 0.3, 0.7]],
    tritan: [[0.95, 0.05, 0], [0, 0.433, 0.567], [0, 0.475, 0.525]],
  }
  const toLab = ([r, g, b]) => {
    const [R, G, B] = [r, g, b].map(lin)
    let x = (R * 0.4124 + G * 0.3576 + B * 0.1805) / 0.95047, y = R * 0.2126 + G * 0.7152 + B * 0.0722, z = (R * 0.0193 + G * 0.1192 + B * 0.9505) / 1.08883
    const f = (t) => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116)
    ;[x, y, z] = [x, y, z].map(f)
    return [116 * y - 16, 500 * (x - y), 200 * (y - z)]
  }
  const sim = (c, m) => {
    const l = c.map(lin)
    return m.map((row) => row[0] * l[0] + row[1] * l[1] + row[2] * l[2]).map((v) => {
      v = Math.max(0, Math.min(1, v))
      return Math.round(255 * (v <= 0.0031308 ? 12.92 * v : 1.055 * v ** (1 / 2.4) - 0.055))
    })
  }
  const dE = (a, b) => Math.hypot(...toLab(a).map((v, i) => v - toLab(b)[i]))
  const cvd = {}
  const solids = Object.fromEntries(FAMILIES.map((f) => [f, rgb(`--sl-color-${f}`)]))
  for (const [name, m] of Object.entries(M)) {
    cvd[name] = []
    for (let i = 0; i < FAMILIES.length; i++)
      for (let j = i + 1; j < FAMILIES.length; j++)
        cvd[name].push({ pair: `${FAMILIES[i]}/${FAMILIES[j]}`, distance: Math.round(dE(sim(solids[FAMILIES[i]], m), sim(solids[FAMILIES[j]], m))) })
  }

  probe.remove()
  const CVD_MIN = 15
  const fails = [
    ...results.filter((r) => !r.ok).map((r) => `${r.label}: ${r.ratio} < ${r.min} (${r.a} on ${r.b})`),
    ...Object.entries(cvd).flatMap(([k, v]) => v.filter((p) => p.distance < CVD_MIN).map((p) => `${k}: ${p.pair} too close (${p.distance} < ${CVD_MIN})`)),
  ]
  return { pairs: results, cvd, fails, cvdMin: CVD_MIN }
}

if (typeof window !== "undefined") window.slopAudit = audit
