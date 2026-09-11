/* SinkAppearance — header controls that persist appearance preferences. */
import { setPreference, getPreference } from "../../../assets/js/theme.js"

export default {
  mounted() {
    for (const select of this.el.querySelectorAll("select[data-pref]")) {
      select.value = getPreference(select.dataset.pref) || "default"
      select.addEventListener("change", () => setPreference(select.dataset.pref, select.value))
    }
  },
}
