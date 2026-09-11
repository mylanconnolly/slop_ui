defmodule SlopUI.Sink.Pages.Tooltips do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Tooltip, :tooltip}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Placements"
      description="Hover or focus. Escape dismisses. The trigger has aria-describedby, so the text is available even when hidden."
      code={
        ~S|<.tooltip id="t1" text="Add a new item"><.button icon aria-label="Add"><.icon name="plus" /></.button></.tooltip>|
      }
    >
      <.cluster gap="lg">
        <.tooltip
          :for={p <- ~w(top bottom left right)}
          id={"tip-#{p}"}
          text={"Tooltip on #{p}"}
          placement={p}
        >
          <.button variant="outline">{p}</.button>
        </.tooltip>
        <.tooltip
          id="tip-icon"
          text="Add a new item to the list, which is a longer description that wraps"
        >
          <.button icon aria-label="Add"><.icon name="plus" /></.button>
        </.tooltip>
      </.cluster>
    </.example>
    """
  end
end
