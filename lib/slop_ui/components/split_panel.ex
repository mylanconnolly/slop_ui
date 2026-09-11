defmodule SlopUI.Components.SplitPanel do
  @moduledoc "Two panes with a draggable, keyboard-operable divider."
  use Phoenix.Component
  import SlopUI.I18n

  @doc """
  Renders two panes separated by a resizable divider.

      <.split_panel id="editor" default={40} min={20} max={70} storage_key="editor-split">
        <:primary><.scroll_area style="max-block-size: 20rem">…</.scroll_area></:primary>
        <:secondary>Preview</:secondary>
      </.split_panel>

      <.split_panel id="stack" orientation="vertical" style="block-size: 24rem">…</.split_panel>

  Sizes are percentages of the container and apply to the `primary` pane; the
  `secondary` pane takes the rest. The divider is a `role="separator"` with
  `aria-valuenow`; drag it with a pointer or focus it and use the keyboard:
  arrows resize by 1% (10% with Shift), Home/End jump to `min`/`max`, Enter
  collapses to `min` and back, double-click restores `default`. With
  `storage_key` the size is remembered in `localStorage`.
  """
  attr :id, :string, required: true
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :default, :integer, default: 50, doc: "initial size of the primary pane, percent"
  attr :min, :integer, default: 10
  attr :max, :integer, default: 90
  attr :storage_key, :string, default: nil, doc: "localStorage key to remember the size"

  attr :label, :string,
    default: nil,
    doc: ~s|divider's accessible name, defaults to "Resize panels"|

  attr :style, :string, default: nil, doc: "inline style; vertical splits need a block-size"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :primary, required: true, doc: "the sized pane"
  slot :secondary, required: true, doc: "takes the remaining space"

  def split_panel(assigns) do
    assigns = assign(assigns, :label, assigns.label || t("Resize panels"))

    ~H"""
    <div
      id={@id}
      class={[@class, "sl-split"]}
      data-orientation={@orientation}
      data-min={@min}
      data-max={@max}
      data-default={@default}
      data-storage-key={@storage_key}
      style={"--sl-split-size: #{@default}%;#{@style}"}
      phx-hook="SlSplitPanel"
      {@rest}
    >
      <div id={"#{@id}-primary"} class="sl-split-pane" data-pane="primary">
        {render_slot(@primary)}
      </div>
      <div
        class="sl-split-handle"
        role="separator"
        tabindex="0"
        aria-orientation={if @orientation == "horizontal", do: "vertical", else: "horizontal"}
        aria-label={@label}
        aria-controls={"#{@id}-primary"}
        aria-valuemin={@min}
        aria-valuemax={@max}
        aria-valuenow={@default}
        aria-valuetext={"#{@default}%"}
      >
      </div>
      <div id={"#{@id}-secondary"} class="sl-split-pane" data-pane="secondary">
        {render_slot(@secondary)}
      </div>
    </div>
    """
  end
end
