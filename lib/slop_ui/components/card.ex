defmodule SlopUI.Components.Card do
  @moduledoc "Cards."
  use Phoenix.Component

  @doc """
  Renders a card with optional header and footer.

      <.card>
        <:header title="Billing" description="Manage your plan." />
        Body content
        <:footer divider justify="end">
          <.button>Save</.button>
        </:footer>
      </.card>

  The `:header` slot renders its inner block after the title block, which is
  where actions go. The `:title` and `:description` slot attrs keep the
  heading semantics correct without you writing them.
  """
  attr :variant, :string, default: "default", values: ~w(default outline elevated sunken)
  attr :padding, :string, default: "md", values: ~w(none sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :header do
    attr :title, :string
    attr :description, :string
    attr :heading_level, :string, doc: "h2 (default) through h6"
  end

  slot :inner_block

  slot :footer do
    attr :divider, :boolean
    attr :justify, :string, doc: "start | end | between"
  end

  def card(assigns) do
    ~H"""
    <div class={[@class, "sl-card"]} data-variant={@variant} data-padding={@padding} {@rest}>
      <div :for={header <- @header} class="sl-card-header">
        <div :if={header[:title] || header[:description]}>
          <.dynamic_tag
            :if={header[:title]}
            tag_name={header[:heading_level] || "h2"}
            class="sl-card-title"
          >
            {header.title}
          </.dynamic_tag>
          <p :if={header[:description]} class="sl-card-description">{header.description}</p>
        </div>
        {if header[:inner_block], do: render_slot(header)}
      </div>
      <div :if={@inner_block != []} class="sl-card-body">
        {render_slot(@inner_block)}
      </div>
      <div
        :for={footer <- @footer}
        class="sl-card-footer"
        data-divider={footer[:divider]}
        data-justify={footer[:justify]}
      >
        {if footer[:inner_block], do: render_slot(footer)}
      </div>
    </div>
    """
  end
end
