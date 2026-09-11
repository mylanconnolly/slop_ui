defmodule SlopUI.Components.Accordion do
  @moduledoc "Accordion on native `<details>` elements. Works without JavaScript; the hook only adds arrow-key movement between headers."
  use Phoenix.Component
  import SlopUI.Icons

  @doc """
  Renders an accordion.

      <.accordion id="faq" exclusive>
        <:item title="Can I cancel?" open>Yes, any time.</:item>
        <:item title="Do you offer refunds?">Within 30 days.</:item>
      </.accordion>

  `exclusive` uses the `name` attribute so opening one item closes the others,
  entirely in the browser. Items animate open and closed where the browser
  supports `::details-content`. Keyboard: Enter/Space toggle (native),
  ArrowUp/ArrowDown move between headers, Home/End jump to the first/last.
  """
  attr :id, :string, required: true
  attr :exclusive, :boolean, default: false
  attr :variant, :string, default: "default", values: ~w(default separated)
  attr :heading_level, :string, default: "h3"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :title, :string, required: true
    attr :open, :boolean
    attr :id, :string
  end

  def accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={[@class, "sl-accordion"]}
      data-variant={@variant}
      phx-hook="SlAccordion"
      {@rest}
    >
      <details
        :for={{item, i} <- Enum.with_index(@item)}
        id={item[:id] || "#{@id}-#{i}"}
        class="sl-accordion-item"
        name={@exclusive && @id}
        open={item[:open]}
      >
        <summary class="sl-accordion-trigger">
          <.dynamic_tag tag_name={@heading_level} style="display: contents; font: inherit">
            {item.title}
          </.dynamic_tag>
          <.icon name="chevron-down" />
        </summary>
        <div class="sl-accordion-content">
          <div class="sl-accordion-body">
            {render_slot(item)}
          </div>
        </div>
      </details>
    </div>
    """
  end
end
