defmodule SlopUI.Sink.Pages.Badges do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Badge, :badge}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example title="Variant × color" code={~S|<.badge color="success" dot>Active</.badge>|}>
      <.scroll_area
        label="Badge variants by color"
        orientation="horizontal"
        shadows={false}
        class="sink-matrix-scroll"
      >
        <div class="sink-matrix" style="grid-template-columns: auto repeat(3, auto)">
          <span></span>
          <span :for={v <- ~w(soft solid outline)}>{v}</span>
          <%= for c <- colors() do %>
            <span>{c}</span>
            <div :for={v <- ~w(soft solid outline)}>
              <.badge variant={v} color={c}>Badge</.badge>
            </div>
          <% end %>
        </div>
      </.scroll_area>
    </.example>

    <.example title="Dots and sizes">
      <.cluster>
        <.badge color="success" dot>Active</.badge>
        <.badge color="warning" dot>Pending</.badge>
        <.badge color="danger" dot>Failed</.badge>
        <.badge size="sm">small</.badge>
        <.badge size="sm" variant="solid" color="accent">3</.badge>
      </.cluster>
    </.example>
    """
  end
end
