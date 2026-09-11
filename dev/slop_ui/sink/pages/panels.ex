defmodule SlopUI.Sink.Pages.Panels do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.SplitPanel, :split_panel},
      {SlopUI.Components.ScrollArea, :scroll_area},
      {SlopUI.Components.Carousel, :carousel}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Split panel"
      description="Drag the divider, or focus it and use the arrow keys (Shift for 10%), Home/End, Enter to collapse, double-click to reset. The size is remembered under a storage key."
      code={
        ~S'''
        <.split_panel id="files" default={35} min={20} max={60} storage_key="sink-files">
          <:primary>…</:primary>
          <:secondary>…</:secondary>
        </.split_panel>
        '''
      }
    >
      <.split_panel
        id="files"
        default={35}
        min={20}
        max={60}
        storage_key="sink-files"
        style="block-size: 14rem; border: 1px solid var(--sl-color-border); border-radius: var(--sl-radius-md)"
      >
        <:primary>
          <div style="padding: var(--sl-space-3)">
            <p
              :for={f <- ~w(README.md mix.exs lib/ assets/ priv/)}
              style="margin: 0; padding-block: 2px"
            >
              {f}
            </p>
          </div>
        </:primary>
        <:secondary>
          <div style="padding: var(--sl-space-3)">
            <p style="margin: 0">
              The end pane takes whatever is left. Both panes scroll independently when their content overflows.
            </p>
          </div>
        </:secondary>
      </.split_panel>
    </.example>

    <.example
      title="Vertical split"
      code={
        ~S|<.split_panel id="stack" orientation="vertical" default={40} style="block-size: 16rem">…</.split_panel>|
      }
    >
      <.split_panel
        id="stack"
        orientation="vertical"
        default={40}
        style="block-size: 12rem; border: 1px solid var(--sl-color-border); border-radius: var(--sl-radius-md)"
      >
        <:primary>
          <div style="padding: var(--sl-space-3)">Editor</div>
        </:primary>
        <:secondary>
          <div style="padding: var(--sl-space-3)">Terminal</div>
        </:secondary>
      </.split_panel>
    </.example>

    <.example
      title="Scroll area"
      description="Thin scrollbars and edge shadows that fade in as you scroll (scroll-driven animations, no JavaScript). The region is focusable and named, so keyboard users can reach and scroll it."
      code={~S|<.scroll_area label="Changelog" style="max-block-size: 12rem">…</.scroll_area>|}
    >
      <.cluster gap="lg" align="start">
        <.scroll_area
          label="Changelog"
          style="max-block-size: 12rem; inline-size: 20rem; border: 1px solid var(--sl-color-border); border-radius: var(--sl-radius-md); padding-inline: var(--sl-space-3)"
        >
          <p :for={i <- 1..24}>Release 0.{i}: fixed a thing, improved another.</p>
        </.scroll_area>
        <.scroll_area
          label="Tags"
          orientation="horizontal"
          style="inline-size: 20rem; border: 1px solid var(--sl-color-border); border-radius: var(--sl-radius-md); padding: var(--sl-space-3)"
        >
          <div style="display: flex; gap: var(--sl-space-2); inline-size: max-content">
            <.badge :for={i <- 1..16} variant="soft">tag-{i}</.badge>
          </div>
        </.scroll_area>
      </.cluster>
    </.example>

    <.example
      title="Carousel"
      description="A native scroll-snap track with previous/next buttons and dot tabs. Left/Right or Home/End on any part of it move the slides; the current slide is announced politely."
      code={
        ~S'''
        <.carousel id="posts" label="Featured posts" loop>
          <:slide :for={post <- @posts}><.card>…</.card></:slide>
        </.carousel>
        '''
      }
    >
      <.carousel id="posts" label="Featured posts" loop style="max-inline-size: 36rem">
        <:slide :for={{title, body} <- slides()}>
          <.card>
            <:header>{title}</:header>
            {body}
          </.card>
        </:slide>
      </.carousel>
    </.example>

    <.example
      title="Several per view, autoplay"
      description="Autoplay pauses while hovered or focused, has a visible pause control, and never starts when the user prefers reduced motion."
      code={
        ~S|<.carousel id="logos" label="Customers" per_view={3} autoplay={3000} loop>…</.carousel>|
      }
    >
      <.carousel
        id="logos"
        label="Customers"
        per_view={3}
        autoplay={3000}
        loop
        style="max-inline-size: 36rem"
      >
        <:slide :for={i <- 1..6} label={"Customer #{i}"}>
          <div style="display: grid; place-items: center; block-size: 6rem; border: 1px dashed var(--sl-color-border-strong); border-radius: var(--sl-radius-md); font-weight: 600">
            Logo {i}
          </div>
        </:slide>
      </.carousel>
    </.example>
    """
  end

  defp slides do
    [
      {"Semantic classes", "Every class names the thing it styles."},
      {"Layers", "All styles live under one cascade layer, so your CSS wins."},
      {"Theming", "OKLCH tokens with light-dark(), six audited presets."},
      {"Hooks", "Plain JavaScript modules, registered once."}
    ]
  end
end
