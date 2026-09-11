/*
 * SlopUI JavaScript entry point.
 *
 *   import { hooks as slopHooks } from "slop_ui"
 *   new LiveSocket("/live", Socket, { hooks: { ...slopHooks, ...myHooks } })
 *
 * The default Phoenix esbuild config resolves `slop_ui` through NODE_PATH=deps.
 */
import SlDialog from "./hooks/dialog.js"
import SlMenu from "./hooks/menu.js"
import SlTree from "./hooks/tree.js"
import SlHoverCard from "./hooks/hover_card.js"
import SlTooltip from "./hooks/tooltip.js"
import SlThemeToggle from "./hooks/theme_toggle.js"
import SlTabs from "./hooks/tabs.js"
import SlAccordion from "./hooks/accordion.js"
import SlToaster from "./hooks/toaster.js"
import SlSelect from "./hooks/select.js"
import SlCombobox from "./hooks/combobox.js"
import SlPopover from "./hooks/popover.js"
import SlSlider from "./hooks/slider.js"
import SlNumber from "./hooks/number.js"
import SlDropzone from "./hooks/dropzone.js"
import SlCommand from "./hooks/command.js"
import SlDatePicker from "./hooks/date_picker.js"
import SlCalendar from "./hooks/calendar.js"
import SlTimePicker from "./hooks/time_picker.js"
import SlTable from "./hooks/table.js"
import SlPinInput from "./hooks/pin_input.js"
import SlTagInput from "./hooks/tag_input.js"
import SlCopy from "./hooks/copy.js"
import SlPassword from "./hooks/password.js"
import SlMarkdownEditor from "./hooks/markdown_editor.js"
import SlCounter from "./hooks/counter.js"
import SlSplitPanel from "./hooks/split_panel.js"
import SlCarousel from "./hooks/carousel.js"
import SlChoiceGroup from "./hooks/choice_group.js"
import SlColor from "./hooks/color.js"

export { getTheme, setTheme, applyTheme, resolvedScheme, getPreference, setPreference, applyPreferences, PREFERENCES, THEME_STORAGE_KEY } from "./theme.js"

/*
 * Avatars: if the image fails to load, drop it so the initials underneath show.
 * `error` doesn't bubble, so listen in the capture phase once for the document.
 */
if (typeof document !== "undefined") {
  document.addEventListener(
    "error",
    (e) => {
      const img = e.target
      if (img instanceof HTMLImageElement && img.parentElement?.classList.contains("sl-avatar")) img.remove()
    },
    true
  )
}

export const hooks = { SlChoiceGroup, SlDialog, SlMenu, SlTree, SlHoverCard, SlTooltip, SlThemeToggle, SlTabs, SlAccordion, SlToaster, SlSelect, SlCombobox, SlPopover, SlSlider, SlNumber, SlDropzone, SlCommand, SlDatePicker, SlCalendar, SlTimePicker, SlTable, SlPinInput, SlTagInput, SlCopy, SlPassword, SlMarkdownEditor, SlCounter, SlSplitPanel, SlCarousel, SlColor }
export default hooks
