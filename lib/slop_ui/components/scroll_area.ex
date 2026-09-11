defmodule SlopUI.Components.ScrollArea do
  @moduledoc "A scroll container with thin styled scrollbars and optional edge shadows."
  use Phoenix.Component

  @doc """
  Renders a scrollable region.

      <.scroll_area label="Changelog" style="max-block-size: 16rem">
        <p :for={entry <- @entries}>{entry}</p>
      </.scroll_area>

      <.scroll_area label="Timeline" orientation="horizontal" shadows={false}>…</.scroll_area>

  Constrain it with `max-block-size` (or `max-inline-size` for horizontal)
  through `style` or your own class. The region is focusable and named, so
  keyboard users can tab to it and scroll with the arrow keys. Shadows fade in
  at the edges that have more content, driven by scroll-timeline animations
  where supported and simply absent elsewhere. No JavaScript.
  """
  attr :label, :string, required: true, doc: "accessible name of the region"
  attr :orientation, :string, default: "vertical", values: ~w(vertical horizontal both)
  attr :shadows, :boolean, default: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def scroll_area(assigns) do
    ~H"""
    <div
      class={[@class, "sl-scroll-area"]}
      data-orientation={@orientation}
      data-shadows={@shadows}
      role="region"
      aria-label={@label}
      tabindex="0"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
