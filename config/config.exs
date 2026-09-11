import Config

# This config only affects the library's own dev/test environment (the kitchen
# sink). Dependency config files are never loaded by consuming applications.
# The Lumis-enabled MDEx NIF, so the kitchen sink shows highlighted Markdown.
config :mdex_native, syntax_highlighter: :lumis

if Mix.env() == :dev do
  config :phoenix, :json_library, Jason

  # Kitchen sink endpoint. Lives here (not in dev.exs) because Phoenix reads
  # some endpoint keys at compile time and validates them at boot.
  config :slop_ui, SlopUI.Sink.Endpoint,
    adapter: Bandit.PhoenixAdapter,
    url: [host: "localhost"],
    http: [port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: String.duplicate("slopui", 12),
    live_view: [signing_salt: "slop_ui_sink_salt"],
    debug_errors: true,
    check_origin: false,
    code_reloader: true,
    pubsub_server: SlopUI.Sink.PubSub,
    render_errors: [formats: [html: SlopUI.Sink.ErrorHTML], layout: false],
    watchers: [esbuild: {Esbuild, :install_and_run, [:sink, ~w(--watch)]}],
    live_reload: [
      patterns: [
        ~r"priv/static/sink/.*(js|css)$",
        ~r"lib/slop_ui/.*(ex|heex)$",
        ~r"dev/slop_ui/.*(ex|heex)$"
      ]
    ]

  config :esbuild,
    version: "0.25.0",
    sink: [
      args:
        ~w(js/app.js css/app.css --bundle --target=es2022 --outdir=../../priv/static/sink --log-level=warning),
      cd: Path.expand("../dev/assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
end
