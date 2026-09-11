defmodule SlopUI.Sink.Helpers do
  @moduledoc "Kitchen-sink page helpers."
  use Phoenix.Component

  @doc "A titled example block with the rendered demo and optional code."
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :code, :string, default: nil
  attr :theme, :string, default: nil, doc: "force a scheme for the demo area"
  slot :inner_block, required: true

  def example(assigns) do
    ~H"""
    <section class="sink-example">
      <h2>{@title}</h2>
      <p :if={@description} class="sink-example-description">{@description}</p>
      <div class="sink-demo" data-theme={@theme}>
        {render_slot(@inner_block)}
      </div>
      <details :if={@code} class="sink-code">
        <summary>Code</summary>
        {highlight(@code)}
      </details>
    </section>
    """
  end

  @doc "Highlights a HEEx snippet with Lumis. Colors use light-dark(), so they follow the page theme."
  def highlight(code) do
    code
    |> String.trim()
    |> Lumis.highlight!(
      formatter:
        {:html_multi_themes,
         language: "heex",
         themes: [light: "github_light", dark: "github_dark"],
         default_theme: "light-dark()"}
    )
    |> Phoenix.HTML.raw()
  end

  @colors ~w(neutral accent success warning danger info)
  def colors, do: @colors
end
