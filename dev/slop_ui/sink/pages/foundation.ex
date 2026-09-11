defmodule SlopUI.Sink.Pages.Foundation do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Theme, :theme_toggle},
      {SlopUI.Components.Theme, :theme_script}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Surfaces"
      description="Neutral surfaces and text colors, driven by --sl-hue-neutral and --sl-neutral-chroma."
    >
      <div class="sink-swatches">
        <div
          :for={t <- ~w(bg surface surface-raised surface-sunken border border-strong)}
          class="sink-swatch"
          style={"background: var(--sl-color-#{t})"}
        >
          {t}
        </div>
        <div
          :for={t <- ~w(fg fg-muted fg-subtle)}
          class="sink-swatch"
          style={"background: var(--sl-color-#{t}); color: var(--sl-color-bg)"}
        >
          {t}
        </div>
      </div>
    </.example>

    <.example
      title="Color families"
      description="Each family: solid, solid hover, soft, and text. Lightness tuned so the pairings pass AA in both schemes."
    >
      <.stack gap="sm">
        <div :for={c <- colors()} class="sink-swatches">
          <div
            class="sink-swatch"
            style={"background: var(--sl-color-#{c}); color: var(--sl-color-#{c}-fg)"}
          >
            {c}
          </div>
          <div
            class="sink-swatch"
            style={"background: var(--sl-color-#{c}-hover); color: var(--sl-color-#{c}-fg)"}
          >
            hover
          </div>
          <div
            class="sink-swatch"
            style={"background: var(--sl-color-#{c}-soft); color: var(--sl-color-#{c}-soft-fg)"}
          >
            soft
          </div>
          <div class="sink-swatch" style={"color: var(--sl-color-#{c}-text)"}>text</div>
        </div>
      </.stack>
    </.example>

    <.example
      title="Rebranding"
      description="Override --sl-hue-accent on any element and everything inside follows. This box sets it to 160."
    >
      <div style="--sl-hue-accent: 160">
        <.cluster>
          <.button color="accent">Accent</.button>
          <.button color="accent" variant="soft">Soft</.button>
          <.badge color="accent">Badge</.badge>
          <a href="#">A link</a>
        </.cluster>
      </div>
    </.example>

    <.example
      title="Nested theme"
      description="data-theme works on any subtree because every color is light-dark()."
    >
      <.cluster>
        <.card data-theme="light" style="flex:1">
          <:header title="Always light" />
          <.cluster>
            <.button>Default</.button><.button color="accent">Accent</.button><.badge
              color="success"
              dot
            >
              OK
            </.badge>
          </.cluster>
        </.card>
        <.card data-theme="dark" style="flex:1">
          <:header title="Always dark" />
          <.cluster>
            <.button>Default</.button><.button color="accent">Accent</.button><.badge
              color="success"
              dot
            >
              OK
            </.badge>
          </.cluster>
        </.card>
      </.cluster>
    </.example>

    <.example title="Typography">
      <.stack gap="sm">
        <p style="font-size: var(--sl-text-3xl); font-weight: 600">The quick brown fox — 3xl</p>
        <p style="font-size: var(--sl-text-2xl); font-weight: 600">The quick brown fox — 2xl</p>
        <p style="font-size: var(--sl-text-xl)">The quick brown fox — xl</p>
        <p style="font-size: var(--sl-text-lg)">The quick brown fox — lg</p>
        <p>
          The quick brown fox jumps over the lazy dog — md, with a <a href="#">link</a>
          and <code>code</code>.
        </p>
        <p style="font-size: var(--sl-text-sm); color: var(--sl-color-fg-muted)">
          The quick brown fox — sm, muted
        </p>
        <p style="font-size: var(--sl-text-xs); color: var(--sl-color-fg-subtle)">
          The quick brown fox — xs, subtle
        </p>
      </.stack>
    </.example>

    <.example
      title="Focus ring"
      description="Tab through these. One outline-based ring everywhere; it survives forced-colors mode."
    >
      <.cluster>
        <.button>Button</.button>
        <a href="#">Link</a>
        <input class="sl-input" placeholder="Input" style="inline-size: 12rem" />
        <label class="sl-choice"><input type="checkbox" class="sl-checkbox" /> Check</label>
      </.cluster>
    </.example>
    """
  end
end
