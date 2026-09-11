defmodule SlopUI.Components.Layout do
  @moduledoc """
  Layout primitives: composition, not utilities. A stack spaces children
  vertically, a cluster groups them horizontally with wrapping, a grid
  auto-fits columns.
  """
  use Phoenix.Component

  @gaps ~w(none xs sm md lg xl)

  @doc "Vertical stack."
  attr :gap, :string, default: "md", values: @gaps
  attr :align, :string, default: nil, values: [nil, "start", "center", "end"]
  attr :tag, :string, default: "div"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def stack(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[@class, "sl-stack"]}
      data-gap={@gap}
      data-align={@align}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc "Horizontal cluster that wraps."
  attr :gap, :string, default: "md", values: @gaps
  attr :align, :string, default: nil, values: [nil, "start", "center", "end", "baseline"]
  attr :justify, :string, default: nil, values: [nil, "start", "center", "end", "between"]
  attr :nowrap, :boolean, default: false
  attr :tag, :string, default: "div"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def cluster(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[@class, "sl-cluster"]}
      data-gap={@gap}
      data-align={@align}
      data-justify={@justify}
      data-nowrap={@nowrap}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc "Auto-fitting grid. `min` is the minimum column width."
  attr :gap, :string, default: "md", values: @gaps
  attr :min, :string, default: "16rem"
  attr :tag, :string, default: "div"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def grid(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[@class, "sl-grid"]}
      data-gap={@gap}
      style={"--sl-grid-min: #{@min}"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc "Centered, max-width container."
  attr :max, :string, default: nil, doc: "max inline size, e.g. \"60rem\""
  attr :tag, :string, default: "div"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[@class, "sl-container"]}
      style={@max && "--sl-container-max: #{@max}"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end
end
