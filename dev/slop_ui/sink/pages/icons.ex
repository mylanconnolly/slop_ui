defmodule SlopUI.Sink.Pages.Icons do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Icons, :icon},
      {SlopUI.Sink.Icons, :icon}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Built-in icons"
      description="The glyphs the library's own chrome uses, vendored from Phosphor (regular weight, MIT). They inherit the text color and size (1em), so they sit correctly in buttons, menus and alerts."
      code={~S|<.icon name="check" />|}
    >
      <ul class="sink-icon-grid">
        <li :for={name <- Enum.sort(SlopUI.Icons.names())}>
          <.icon name={name} />
          <code>{name}</code>
        </li>
      </ul>
    </.example>

    <.example
      title="Your own sets"
      description="use SlopUI.Icons embeds SVGs from Phosphor, Heroicons or a folder of your own at compile time. Names are prefixed per set; an unknown name fails the build with the closest matches."
      code={
        ~S'''
        defmodule MyAppWeb.Icons do
          use SlopUI.Icons,
            sets: [
              phosphor: [icons: ~w(house users bell)],
              duo: [preset: :phosphor, weight: :duotone, icons: ~w(heart)],
              hero: [style: :outline, icons: ~w(arrow-path)],
              app: [dir: "assets/icons", icons: :all]
            ]
        end

        <MyAppWeb.Icons.icon name="phosphor-house" />
        <MyAppWeb.Icons.icon name="duo-heart" class="sl-icon-lg" />
        <MyAppWeb.Icons.icon name="app-logo" aria-label="Acme" />
        '''
      }
    >
      <ul class="sink-icon-grid">
        <li :for={name <- SlopUI.Sink.Icons.icon_names()}>
          <SlopUI.Sink.Icons.icon name={name} />
          <code>{name}</code>
        </li>
      </ul>
    </.example>

    <.example
      title="Sizing and color"
      description="Icons are 1em by default; sl-icon-sm/lg/xl scale them, or set font-size on the parent. Color comes from the text color, and duotone layers keep their opacity."
      code={
        ~S|<span style="color: var(--sl-color-accent)"><SlopUI.Sink.Icons.icon name="duo-rocket-launch" class="sl-icon-xl" /></span>|
      }
    >
      <.cluster gap="lg" align="center">
        <SlopUI.Sink.Icons.icon name="phosphor-rocket-launch" class="sl-icon-sm" />
        <SlopUI.Sink.Icons.icon name="phosphor-rocket-launch" />
        <SlopUI.Sink.Icons.icon name="phosphor-rocket-launch" class="sl-icon-lg" />
        <SlopUI.Sink.Icons.icon name="phosphor-rocket-launch" class="sl-icon-xl" />
        <span style="color: var(--sl-color-accent)">
          <SlopUI.Sink.Icons.icon name="duo-rocket-launch" class="sl-icon-xl" />
        </span>
        <span style="color: var(--sl-color-danger)">
          <SlopUI.Sink.Icons.icon name="fill-heart" class="sl-icon-xl" />
        </span>
        <.button color="accent">
          <SlopUI.Sink.Icons.icon name="phosphor-rocket-launch" /> Launch
        </.button>
        <.button variant="outline">
          <SlopUI.Sink.Icons.icon name="bold-star" /> Star
        </.button>
        <.badge color="success"><SlopUI.Sink.Icons.icon name="fill-lightning" /> Fast</.badge>
      </.cluster>
    </.example>
    """
  end
end
