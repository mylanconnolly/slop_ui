defmodule SlopUI.Sink.Pages.Buttons do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  @variants ~w(solid soft outline ghost link)

  def components do
    [
      {SlopUI.Components.Button, :button},
      {SlopUI.Components.Button, :button_group}
    ]
  end

  def render(assigns) do
    assigns = assign(assigns, variants: @variants)

    ~H"""
    <.example
      title="Variant × color"
      description="Compare emphasis and semantic colors. On narrow screens, scroll horizontally to see every variant."
      code={~S|<.button variant="soft" color="accent">Filter</.button>|}
    >
      <.scroll_area
        label="Button variants by color"
        orientation="horizontal"
        shadows={false}
        class="sink-matrix-scroll"
      >
        <div
          class="sink-matrix"
          style={"grid-template-columns: auto repeat(#{length(@variants)}, auto)"}
        >
          <span></span>
          <span :for={v <- @variants}>{v}</span>
          <%= for c <- colors() do %>
            <span>{c}</span>
            <div :for={v <- @variants}><.button variant={v} color={c}>Button</.button></div>
          <% end %>
        </div>
      </.scroll_area>
    </.example>

    <.example title="Sizes" code={~S|<.button size="sm">Small</.button>|}>
      <.cluster align="center">
        <.button size="sm">Small</.button>
        <.button>Medium</.button>
        <.button size="lg">Large</.button>
        <.button size="sm" icon aria-label="Add"><.icon name="plus" /></.button>
        <.button icon aria-label="Add"><.icon name="plus" /></.button>
        <.button size="lg" icon aria-label="Add"><.icon name="plus" /></.button>
      </.cluster>
    </.example>

    <.example title="With icons and states" code={~S|<.button loading>Saving</.button>|}>
      <.cluster>
        <.button color="accent"><.icon name="plus" /> New post</.button>
        <.button variant="outline">Settings <.icon name="chevron-down" /></.button>
        <.button loading color="accent">Saving</.button>
        <.button disabled>Disabled</.button>
        <.button variant="soft" color="danger"><.icon name="trash" /> Delete</.button>
      </.cluster>
    </.example>

    <.example
      title="Links as buttons"
      description="href, navigate or patch renders an anchor with identical styling."
    >
      <.cluster>
        <.button href="https://hexdocs.pm/phoenix_live_view" target="_blank" color="accent">Docs</.button>
        <.button patch="/badges" variant="outline">Patch to badges</.button>
        <.button navigate="/cards" variant="link">Navigate to cards</.button>
      </.cluster>
    </.example>

    <.example
      title="Button group"
      code={~S|<.button_group aria-label="Pagination">...</.button_group>|}
    >
      <.button_group aria-label="Pagination">
        <.button variant="outline">Previous</.button>
        <.button variant="outline">1</.button>
        <.button variant="outline">2</.button>
        <.button variant="outline">Next</.button>
      </.button_group>
    </.example>
    """
  end
end
