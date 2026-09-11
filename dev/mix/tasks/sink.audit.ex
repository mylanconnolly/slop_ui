defmodule Mix.Tasks.Sink.Audit do
  @shortdoc "Audits every colour preset for WCAG contrast and colour-vision distinctiveness"
  @moduledoc """
  Boots the kitchen sink on a random port, drives headless Chrome through the
  DevTools protocol, and measures every token pairing for each palette in
  light and dark, with and without `data-contrast="more"`.

      mix sink.audit                 # all presets
      mix sink.audit warm cool       # some presets
      mix sink.audit --json

  Fails (exit 1) if any text pairing is under 4.5:1, any non-text pairing
  under 3:1, or any two semantic colours land within ΔE 15 of each other
  under simulated protan, deutan or tritan vision.

  Needs Google Chrome; set CHROME_BIN to point at another Chromium build.
  """
  use Mix.Task

  @presets ~w(warm cool slate forest ocean mono)

  @impl true
  def run(args) do
    {opts, palettes, _} = OptionParser.parse(args, strict: [json: :boolean])
    palettes = if palettes == [], do: @presets, else: palettes

    Mix.Task.run("app.start")
    Application.put_env(:phoenix, :serve_endpoints, true)
    Application.put_env(:slop_ui, SlopUI.Sink.Endpoint, endpoint_config())
    Mix.Task.run("esbuild", ["sink"])

    {:ok, _} =
      Supervisor.start_link([{Phoenix.PubSub, name: SlopUI.Sink.PubSub}, SlopUI.Sink.Endpoint],
        strategy: :one_for_one
      )

    {:ok, {_ip, port}} = SlopUI.Sink.Endpoint.server_info(:http)

    script = Path.join([File.cwd!(), "dev", "audit", "run.mjs"])
    flags = if opts[:json], do: ["--json"], else: []

    {output, status} =
      System.cmd("node", [script, "http://127.0.0.1:#{port}", Enum.join(palettes, ",") | flags],
        stderr_to_stdout: true
      )

    Mix.shell().info(output)

    if status != 0, do: Mix.raise("palette audit failed")
  end

  defp endpoint_config do
    :slop_ui
    |> Application.get_env(SlopUI.Sink.Endpoint, [])
    |> Keyword.merge(
      http: [port: 0],
      watchers: [],
      code_reloader: false,
      live_reload: [patterns: []],
      server: true
    )
  end
end
