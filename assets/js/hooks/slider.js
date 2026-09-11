/* SlSlider — keeps the readout and the filled track in sync with the range input. */
export default {
  mounted() {
    this.input = this.el.querySelector('input[type="range"]')
    this.output = this.el.querySelector("output")
    this.sync = () => {
      const { value, min, max } = this.input
      const pct = ((Number(value) - Number(min)) / (Number(max) - Number(min))) * 100
      this.input.style.setProperty("--_pct", `${pct}%`)
      if (this.output) this.output.textContent = (this.el.dataset.format || "%v").replace("%v", value)
    }
    this.input.addEventListener("input", this.sync)
    this.sync()
  },
  updated() {
    this.sync()
  },
}
