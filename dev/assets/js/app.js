import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as slopHooks } from "../../../assets/js/index.js"
import "./audit.js"
import SinkBuilder from "./builder.js"
import SinkAppearance from "./appearance.js"
import { applyPreferences } from "../../../assets/js/theme.js"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { ...slopHooks, SinkBuilder, SinkAppearance },
})

applyPreferences()
liveSocket.connect()
window.liveSocket = liveSocket
