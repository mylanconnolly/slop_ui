defmodule Mix.Tasks.Sink.Smoke do
  @shortdoc "Runs the browser smoke tests for every JavaScript hook"
  @moduledoc """
  Boots the kitchen sink on a random port and drives headless Chrome through
  the DevTools protocol, running the scenarios in `dev/smoke/tests/*.mjs`.
  Each scenario opens a sink page, performs real clicks and key presses, and
  asserts on the resulting DOM, so every hook's behaviour (open/close, arrow
  keys, focus management, value changes) is checked end to end.

      mix sink.smoke                 # everything
      mix sink.smoke menu tabs       # scenarios whose name contains a word
      mix sink.smoke --json

  Needs Google Chrome; set CHROME_BIN to point at another Chromium build.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, filters, _} = OptionParser.parse(args, strict: [json: :boolean])

    Mix.Task.run("app.start")
    Application.put_env(:phoenix, :serve_endpoints, true)
    Application.put_env(:slop_ui, SlopUI.Sink.Endpoint, endpoint_config())
    Mix.Task.run("esbuild", ["sink"])

    {:ok, _} =
      Supervisor.start_link([{Phoenix.PubSub, name: SlopUI.Sink.PubSub}, SlopUI.Sink.Endpoint],
        strategy: :one_for_one
      )

    {:ok, {_ip, port}} = SlopUI.Sink.Endpoint.server_info(:http)
    script = Path.join([File.cwd!(), "dev", "smoke", "run.mjs"])
    flags = if opts[:json], do: ["--json"], else: []

    {_output, status} =
      System.cmd("node", [script, "http://127.0.0.1:#{port}", Enum.join(filters, ",") | flags],
        stderr_to_stdout: true,
        into: IO.stream(:stdio, :line)
      )

    if status != 0, do: Mix.raise("smoke tests failed")
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
