defmodule SlopUI.Components.Shell do
  @moduledoc "Application shell: sidebar, topbar, navigation, auth layout, indicator."
  use Phoenix.Component
  import SlopUI.Icons
  import SlopUI.I18n

  @doc """
  The page frame: a sidebar (which becomes a sheet on narrow screens), a
  sticky topbar, and the main area.

      <.app_shell id="app">
        <:sidebar>
          <.sidebar brand="Acme" brand_href={~p"/"}>
            <.nav>
              <.nav_group label="Workspace">
                <.nav_item navigate={~p"/"} current={@live_action == :home}><.icon name="folder" /> Projects</.nav_item>
              </.nav_group>
            </.nav>
            <:footer><.button variant="ghost" size="sm">Sign out</.button></:footer>
          </.sidebar>
        </:sidebar>
        <:topbar>
          <.breadcrumbs>…</.breadcrumbs>
          <:end><.theme_toggle /></:end>
        </:topbar>
        Page content
      </.app_shell>

  The sidebar slot is rendered once for the desktop column and once inside a
  `sheet` for narrow viewports, so avoid ids inside it. Set
  `--sl-sidebar-width` and `--sl-topbar-height` to change the geometry.
  """
  attr :id, :string, required: true

  attr :width, :string,
    default: "default",
    values: ~w(default narrow wide),
    doc: "content measure"

  attr :class, :any, default: nil
  attr :rest, :global

  slot :sidebar

  slot :topbar do
    attr :class, :any
  end

  slot :inner_block, required: true

  def app_shell(assigns) do
    ~H"""
    <div id={@id} class={[@class, "sl-app-shell"]} data-sidebar={@sidebar == [] && "none"} {@rest}>
      <a href={"##{@id}-main"} class="sl-skip-link">{t("Skip to content")}</a>
      <%= if @sidebar != [] do %>
        {render_slot(@sidebar)}
        <dialog
          id={"#{@id}-nav"}
          class="sl-sheet sl-sidebar-sheet"
          data-side="left"
          data-size="sm"
          data-open="false"
          data-dismiss="true"
          data-backdrop-surface
          closedby="any"
          aria-label={t("Navigation")}
          phx-hook="SlDialog"
        >
          <form method="dialog" class="sl-sidebar-close">
            <button
              type="submit"
              class="sl-button"
              data-variant="outline"
              data-size="md"
              data-icon
              aria-label={t("Close")}
            ><.icon name="x-mark" /></button>
          </form>
          {render_slot(@sidebar)}
        </dialog>
      <% end %>
      <header :for={topbar <- @topbar} class={[topbar[:class], "sl-topbar"]}>
        <button
          :if={@sidebar != []}
          type="button"
          class="sl-button sl-topbar-toggle"
          data-variant="ghost"
          data-size="sm"
          data-icon
          aria-label={t("Open navigation")}
          phx-click={SlopUI.JS.open_dialog("##{@id}-nav")}
        >
          <.icon name="menu" />
        </button>
        {render_slot(topbar)}
      </header>
      <main id={"#{@id}-main"} class="sl-app-main" data-width={@width} tabindex="-1">
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  @doc "Topbar content helpers: put things at the end of the bar."
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def topbar_end(assigns) do
    ~H"""
    <div class={[@class, "sl-topbar-end"]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  @doc "The sidebar column: brand, navigation, and a footer pinned to the bottom."
  attr :brand, :string, default: nil
  attr :brand_href, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :logo, doc: "an icon or image rendered before the brand name"
  slot :inner_block, required: true
  slot :footer

  def sidebar(assigns) do
    ~H"""
    <aside class={[@class, "sl-sidebar"]} {@rest}>
      <.link :if={@brand} href={@brand_href || "/"} class="sl-sidebar-brand">
        {render_slot(@logo)}
        <span>{@brand}</span>
      </.link>
      <div class="sl-sidebar-body">
        {render_slot(@inner_block)}
      </div>
      <div :if={@footer != []} class="sl-sidebar-footer">{render_slot(@footer)}</div>
    </aside>
    """
  end

  @doc "A navigation landmark holding groups of items."
  attr :label, :string, default: nil, doc: "accessible name; defaults to Main"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def nav(assigns) do
    ~H"""
    <nav class={[@class, "sl-nav"]} aria-label={@label || t("Main")} {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc "A labelled group of navigation items."
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def nav_group(assigns) do
    ~H"""
    <div class={[@class, "sl-nav-group"]} {@rest}>
      <div :if={@label} class="sl-nav-group-label">{@label}</div>
      <ul class="sl-nav-list" role="list">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  @doc """
  A navigation link. `current` marks the active page with `aria-current`.
  A `badge` renders a count or status on the right.

      <.nav_item navigate={~p"/inbox"} current={@page == :inbox} badge="12"><.icon name="inbox" /> Inbox</.nav_item>
  """
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :any, default: nil
  attr :current, :boolean, default: false
  attr :badge, :string, default: nil
  attr :badge_color, :string, default: "neutral"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(method target)
  slot :inner_block, required: true

  def nav_item(assigns) do
    ~H"""
    <li>
      <.link
        navigate={@navigate}
        patch={@patch}
        href={@href}
        class={[@class, "sl-nav-item"]}
        aria-current={@current && "page"}
        {@rest}
      >
        {render_slot(@inner_block)}
        <span :if={@badge} class="sl-badge" data-size="sm" data-color={@badge_color}>{@badge}</span>
      </.link>
    </li>
    """
  end

  @doc """
  A collapsible navigation group on `<details>`, for nested sections.

      <.nav_collapsible label="Settings" open={@page in ~w(profile billing)a}>
        <:icon><.icon name="cog" /></:icon>
        <.nav_item navigate={~p"/settings/profile"}>Profile</.nav_item>
      </.nav_collapsible>
  """
  attr :label, :string, required: true
  attr :open, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :icon
  slot :inner_block, required: true

  def nav_collapsible(assigns) do
    ~H"""
    <li>
      <details class={[@class, "sl-nav-collapsible"]} open={@open} {@rest}>
        <summary>
          <span class="sl-nav-item">
            {render_slot(@icon)}
            <span class="sl-nav-item-label">{@label}</span>
            <.icon name="chevron-down" class="sl-nav-caret" />
          </span>
        </summary>
        <ul class="sl-nav-list" role="list">
          {render_slot(@inner_block)}
        </ul>
      </details>
    </li>
    """
  end

  @doc """
  Wraps a control with a dot or count marker, for notification buttons.

      <.indicator count={3}><.button variant="ghost" icon aria-label="Notifications"><.icon name="bell" /></.button></.indicator>
      <.indicator dot color="success"><.avatar name="Ada" /></.indicator>
  """
  attr :count, :integer, default: nil
  attr :dot, :boolean, default: false
  attr :max, :integer, default: 99
  attr :color, :string, default: "danger", values: ~w(danger accent success)

  attr :label, :string,
    default: nil,
    doc: "accessible description of the marker, e.g. \"3 unread\""

  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def indicator(assigns) do
    ~H"""
    <span class={[@class, "sl-indicator"]} data-color={@color} {@rest}>
      {render_slot(@inner_block)}
      <span
        :if={@dot || @count}
        class="sl-indicator-mark"
        aria-hidden={is_nil(@label) && "true"}
        aria-label={@label}
      >{count_text(@count, @max)}</span>
    </span>
    """
  end

  defp count_text(nil, _), do: nil
  defp count_text(n, max) when n > max, do: "#{max}+"
  defp count_text(n, _), do: to_string(n)

  @doc """
  A centred panel for sign-in, sign-up, and similar pages.

      <.auth_layout title="Welcome back" description="Sign in to continue.">
        <:brand><.icon name="folder" /> Acme</:brand>
        <.form …>…</.form>
        <:footer>New here? <.link navigate={~p"/signup"}>Create an account</.link></:footer>
      </.auth_layout>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :brand
  slot :inner_block, required: true
  slot :footer

  def auth_layout(assigns) do
    ~H"""
    <div class={[@class, "sl-auth"]} {@rest}>
      <div class="sl-auth-panel">
        <div :if={@brand != []} class="sl-auth-brand">{render_slot(@brand)}</div>
        <div class="sl-auth-heading">
          <h1 class="sl-auth-title">{@title}</h1>
          <p :if={@description} class="sl-auth-description">{@description}</p>
        </div>
        <div class="sl-card" data-padding="lg">
          <div class="sl-card-body">{render_slot(@inner_block)}</div>
        </div>
        <p :if={@footer != []} class="sl-auth-footer">{render_slot(@footer)}</p>
      </div>
    </div>
    """
  end
end
