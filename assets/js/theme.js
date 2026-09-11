/*
 * Theme state. Three modes for the colour scheme:
 *   "system" - no data-theme attribute; CSS follows prefers-color-scheme
 *   "light"  - <html data-theme="light">
 *   "dark"   - <html data-theme="dark">
 *
 * Plus optional appearance preferences, each a data attribute on <html>:
 *   palette  (data-palette: warm | cool | slate | forest | ember | mono)
 *   dark     (data-dark: dim | black)
 *   contrast (data-contrast: more)
 *   density  (data-density: compact | comfortable)
 *   radius   (data-radius: none | sm | md | lg | full)
 *
 * Everything persists in localStorage. `SlopUI.theme_script/1` renders a tiny
 * inline script that applies the stored values before first paint.
 */
export const THEME_STORAGE_KEY = "sl-theme"
const THEMES = ["system", "light", "dark"]
export const PREFERENCES = ["palette", "dark", "contrast", "density", "radius"]

export function getTheme() {
  try {
    const stored = localStorage.getItem(THEME_STORAGE_KEY)
    return THEMES.includes(stored) ? stored : "system"
  } catch {
    return "system"
  }
}

export function setTheme(theme) {
  if (!THEMES.includes(theme)) theme = "system"
  try {
    if (theme === "system") localStorage.removeItem(THEME_STORAGE_KEY)
    else localStorage.setItem(THEME_STORAGE_KEY, theme)
  } catch {
    /* storage unavailable: theme still applies for this page */
  }
  applyTheme(theme)
}

export function applyTheme(theme = getTheme()) {
  const root = document.documentElement
  if (theme === "system") root.removeAttribute("data-theme")
  else root.setAttribute("data-theme", theme)
  document.dispatchEvent(new CustomEvent("sl:theme", { detail: { theme } }))
}

/* Resolved scheme, useful for things like chart palettes. */
export function resolvedScheme() {
  const theme = getTheme()
  if (theme !== "system") return theme
  return matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
}

/* ---- appearance preferences ---- */
export function getPreference(name) {
  try {
    return localStorage.getItem(`sl-${name}`) || null
  } catch {
    return null
  }
}

/* Pass null (or "default") to clear. */
export function setPreference(name, value) {
  if (!PREFERENCES.includes(name)) return
  if (value === "default" || value === "") value = null
  try {
    value ? localStorage.setItem(`sl-${name}`, value) : localStorage.removeItem(`sl-${name}`)
  } catch {
    /* ignore */
  }
  applyPreference(name, value)
}

export function applyPreference(name, value = getPreference(name)) {
  const root = document.documentElement
  if (value) root.setAttribute(`data-${name}`, value)
  else root.removeAttribute(`data-${name}`)
  document.dispatchEvent(new CustomEvent("sl:preference", { detail: { name, value } }))
}

export function applyPreferences() {
  for (const name of PREFERENCES) applyPreference(name)
}
