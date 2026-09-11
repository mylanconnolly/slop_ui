defmodule SlopUI.Components.Popover do
  @moduledoc "Anchored popovers with arbitrary content."
  use Phoenix.Component

  @doc """
  Renders a trigger button and an anchored, light-dismissable panel.

      <.popover id="plan-info" title="What's included">
        <:trigger variant="ghost" size="sm">Details</:trigger>
        <p>Unlimited projects and 10 seats.</p>
      </.popover>

  With a `title`, the panel is a labelled non-modal dialog. Focus moves into
  the panel on open (first focusable element, else the panel) and returns to
  the trigger on close. Escape and outside clicks close it unless
  `dismissable={false}`.
  """
  attr :id, :string, required: true
  attr :title, :string, default: nil

  attr :placement, :string,
    default: "bottom-start",
    values: ~w(bottom-start bottom bottom-end top-start top top-end)

  attr :dismissable, :boolean, default: true
  attr :padding, :string, default: "md", values: ~w(md none)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger, required: true do
    attr :style, :string
    attr :variant, :string
    attr :color, :string
    attr :size, :string
    attr :icon, :boolean
    attr :aria_label, :string
    attr :class, :any
  end

  slot :inner_block, required: true

  def popover(assigns) do
    assigns = assign(assigns, :anchor, SlopUI.anchor_name(assigns.id))

    ~H"""
    <div id={@id} class={[@class, "sl-popover"]} phx-hook="SlPopover" {@rest}>
      <button
        :for={trigger <- @trigger}
        type="button"
        id={"#{@id}-trigger"}
        class={[trigger[:class], "sl-button"]}
        data-variant={trigger[:variant] || "outline"}
        data-color={trigger[:color] || "neutral"}
        data-size={trigger[:size] || "md"}
        data-icon={trigger[:icon]}
        aria-label={trigger[:aria_label]}
        popovertarget={"#{@id}-panel"}
        aria-expanded="false"
        aria-controls={"#{@id}-panel"}
        style={Enum.join(Enum.reject([trigger[:style], "anchor-name: #{@anchor}"], &is_nil/1), "; ")}
      >
        {render_slot(trigger)}
      </button>
      <div
        id={"#{@id}-panel"}
        popover={if @dismissable, do: "auto", else: "manual"}
        role={@title && "dialog"}
        aria-labelledby={@title && "#{@id}-title"}
        tabindex="-1"
        class="sl-popover-panel"
        data-placement={@placement}
        data-padding={@padding}
        style={"--sl-anchor: #{@anchor}"}
      >
        <h3 :if={@title} id={"#{@id}-title"} class="sl-popover-title">{@title}</h3>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
