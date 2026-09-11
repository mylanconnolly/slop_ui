import { getTheme, setTheme, setPreference, PREFERENCES } from "../theme.js"

/* SlThemeToggle — binds the radio group to theme state. */
export default {
  mounted() {
    this.sync()
    this.el.addEventListener("change", (e) => {
      if (e.target.matches('input[type="radio"]')) setTheme(e.target.value)
    })
    this.onTheme = () => this.sync()
    document.addEventListener("sl:theme", this.onTheme)
    this.onSet = (e) => {
      if (e.detail?.theme) setTheme(e.detail.theme)
      for (const name of PREFERENCES) if (name in (e.detail || {})) setPreference(name, e.detail[name])
    }
    window.addEventListener("sl:set-theme", this.onSet)
  },

  sync() {
    const theme = getTheme()
    for (const input of this.el.querySelectorAll('input[type="radio"]')) {
      input.checked = input.value === theme
    }
  },

  destroyed() {
    document.removeEventListener("sl:theme", this.onTheme)
    window.removeEventListener("sl:set-theme", this.onSet)
  },
}
