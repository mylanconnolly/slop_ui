defmodule SlopUI.Components.Tooltip do
  @moduledoc "Tooltips."
  use Phoenix.Component

  @doc """
  Wraps a trigger with a tooltip.

      <.tooltip id="help-tip" text="Opens the help center">
        <.button icon aria-label="Help">?</.button>
      </.tooltip>

  The trigger gets `aria-describedby` pointing at the tooltip, so assistive
  technology reads it regardless of hover state. Shown on hover and on
  keyboard focus; dismissed with Escape.
  """
  attr :id, :string, required: true
  attr :text, :string, required: true
  attr :placement, :string, default: "top", values: ~w(top bottom left right)
  attr :delay, :integer, default: 300, doc: "ms before showing"
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def tooltip(assigns) do
    assigns = assign(assigns, :anchor, SlopUI.anchor_name(assigns.id))

    ~H"""
    <span
      id={@id}
      class={[@class, "sl-tooltip-trigger"]}
      style={"anchor-name: #{@anchor}"}
      phx-hook="SlTooltip"
      aria-describedby={"#{@id}-tip"}
      data-delay={@delay}
    >
      {render_slot(@inner_block)}
    </span>
    <div
      id={"#{@id}-tip"}
      role="tooltip"
      popover="manual"
      class="sl-tooltip"
      data-placement={@placement}
      style={"--sl-anchor: #{@anchor}"}
    >
      {@text}
    </div>
    """
  end
end
