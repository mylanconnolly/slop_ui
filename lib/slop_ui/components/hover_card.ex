defmodule SlopUI.Components.HoverCard do
  @moduledoc "Hover cards: rich previews that open when a trigger is hovered or focused."
  use Phoenix.Component

  @doc """
  Renders a trigger and a card that appears after hovering or focusing it.

      <.hover_card id="ada-card">
        <:trigger><.link href="/u/ada">@ada</.link></:trigger>
        <.cluster>
          <.avatar name="Ada Lovelace" />
          <div><strong>Ada Lovelace</strong><br />Analytical engines.</div>
        </.cluster>
      </.hover_card>

  The trigger keeps its own semantics (a link stays a link). The card opens
  after `open_delay` ms, stays open while the pointer is over it, and closes
  `close_delay` ms after the pointer leaves both. Keyboard users get it on
  focus, can Tab into it, and dismiss it with Escape. Touch taps activate
  the trigger as usual instead of opening the card, so put nothing essential
  in the card.
  """
  attr :id, :string, required: true

  attr :placement, :string,
    default: "bottom-start",
    values: ~w(bottom-start bottom bottom-end top-start top top-end)

  attr :open_delay, :integer, default: 400, doc: "ms before opening"
  attr :close_delay, :integer, default: 150, doc: "ms before closing"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :trigger, required: true
  slot :inner_block, required: true

  def hover_card(assigns) do
    assigns = assign(assigns, :anchor, SlopUI.anchor_name(assigns.id))

    ~H"""
    <span
      id={@id}
      class={[@class, "sl-hover-card"]}
      style={"anchor-name: #{@anchor}"}
      phx-hook="SlHoverCard"
      data-open-delay={@open_delay}
      data-close-delay={@close_delay}
      {@rest}
    >
      {render_slot(@trigger)}
    </span>
    <div
      id={"#{@id}-card"}
      popover="manual"
      class="sl-hover-card-panel"
      data-placement={@placement}
      style={"--sl-anchor: #{@anchor}"}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
