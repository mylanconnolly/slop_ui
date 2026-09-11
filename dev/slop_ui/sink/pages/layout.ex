defmodule SlopUI.Sink.Pages.Layout do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Layout, :stack},
      {SlopUI.Components.Layout, :cluster},
      {SlopUI.Components.Layout, :grid},
      {SlopUI.Components.Layout, :container}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example title="Stack" code={~S|<.stack gap="sm">…</.stack>|}>
      <.stack gap="sm" style="max-inline-size: 20rem">
        <.card :for={i <- 1..3} padding="sm">Item {i}</.card>
      </.stack>
    </.example>

    <.example title="Cluster" code={~S|<.cluster justify="between">…</.cluster>|}>
      <.cluster justify="between">
        <.cluster gap="sm">
          <.badge>One</.badge><.badge>Two</.badge><.badge>Three</.badge>
        </.cluster>
        <.button size="sm">Action</.button>
      </.cluster>
    </.example>

    <.example title="Grid" code={~S|<.grid min="10rem">…</.grid>|}>
      <.grid min="10rem">
        <.card :for={i <- 1..7} padding="sm" variant="sunken">Cell {i}</.card>
      </.grid>
    </.example>
    """
  end
end
