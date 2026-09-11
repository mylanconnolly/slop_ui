defmodule SlopUI.Sink.Endpoint do
  use Phoenix.Endpoint, otp_app: :slop_ui

  @session_options [
    store: :cookie,
    key: "_slop_ui_sink",
    signing_salt: "slop_ui_sink",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Plug.Static, at: "/", from: "priv/static/sink", gzip: false

  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.Session, @session_options
  plug SlopUI.Sink.Router
end
