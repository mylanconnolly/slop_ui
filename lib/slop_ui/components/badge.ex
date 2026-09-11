defmodule SlopUI.Components.Badge do
  @moduledoc "Badges and status pills."
  use Phoenix.Component

  @doc """
  Renders a badge.

      <.badge>Draft</.badge>
      <.badge color="success" dot>Active</.badge>
      <.badge variant="solid" color="danger">3</.badge>
  """
  attr :variant, :string, default: "soft", values: ~w(soft solid outline)

  attr(:color, :string,
    default: "neutral",
    values: ~w(neutral accent success warning danger info)
  )

  attr :size, :string, default: "md", values: ~w(sm md)
  attr :dot, :boolean, default: false, doc: "leading status dot"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span
      class={[@class, "sl-badge"]}
      data-variant={@variant}
      data-color={@color}
      data-size={@size}
      data-dot={@dot}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
