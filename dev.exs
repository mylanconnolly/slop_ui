# Kitchen sink development server.
#
#     $ mix dev            # http://localhost:4000
#     $ iex -S mix dev
#
# Everything here is dev-only; nothing in this file ships with the package.
Logger.configure(level: :debug)

Application.put_env(:phoenix, :serve_endpoints, true)

# Warm the syntax highlighter so the first page doesn't pay for parser loading.
Lumis.Languages.load(["heex"])

Task.async(fn ->
  children = [
    {Phoenix.PubSub, name: SlopUI.Sink.PubSub},
    SlopUI.Sink.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
