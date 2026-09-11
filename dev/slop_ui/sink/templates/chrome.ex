defmodule SlopUI.Sink.Templates.Chrome do
  @moduledoc "The shared shell used by the app-style templates."
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  attr :name, :string, required: true
  attr :title, :string, required: true
  attr :width, :string, default: "default"

  attr :crumbs, :list,
    default: [],
    doc: "{label, path} pairs rendered between the brand and the page"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.app_shell id="app" width={@width}>
      <:sidebar>
        <.sidebar brand="Acme" brand_href="/templates/dashboard">
          <:logo><.icon name="folder" /></:logo>
          <.nav>
            <.nav_group>
              <.nav_item navigate="/templates/dashboard" current={@name == "dashboard"}>
                <.icon name="home" /> Dashboard
              </.nav_item>
              <.nav_item navigate="/templates/list" current={@name == "list"} badge="4">
                <.icon name="users" /> Members
              </.nav_item>
              <.nav_item navigate="/templates/detail" current={@name == "detail"}>
                <.icon name="user" /> Member detail
              </.nav_item>
            </.nav_group>
            <.nav_group label="Account">
              <.nav_collapsible label="Settings" open={@name == "settings"}>
                <:icon><.icon name="cog" /></:icon>
                <.nav_item navigate="/templates/settings" current={@name == "settings"}>
                  Profile
                </.nav_item>
                <.nav_item href="#">Billing</.nav_item>
                <.nav_item href="#">Notifications</.nav_item>
              </.nav_collapsible>
              <.nav_item navigate="/templates/sign-in"><.icon name="lock" /> Sign in page</.nav_item>
              <.nav_item navigate="/templates/sign-up"><.icon name="mail" /> Sign up page</.nav_item>
            </.nav_group>
          </.nav>
          <:footer>
            <.menu id="sidebar-user" placement="top-start">
              <:trigger
                variant="ghost"
                class="sl-nav-item"
                style="inline-size: 100%; justify-content: flex-start"
              >
                <.avatar name="Ada Lovelace" size="sm" status="online" /> <span>Ada Lovelace</span>
              </:trigger>
              <.menu_item navigate="/templates/settings"><.icon name="cog" /> Settings</.menu_item>
              <.menu_item navigate="/"><.icon name="folder" /> Kitchen sink</.menu_item>
              <.menu_separator />
              <.menu_item color="danger" navigate="/templates/sign-in">
                <.icon name="logout" /> Sign out
              </.menu_item>
            </.menu>
          </:footer>
        </.sidebar>
      </:sidebar>
      <:topbar>
        <.breadcrumbs>
          <:crumb navigate="/templates/dashboard">Acme</:crumb>
          <:crumb :for={{label, path} <- @crumbs} navigate={path}>{label}</:crumb>
          <:crumb>{@title}</:crumb>
        </.breadcrumbs>
        <.topbar_end>
          <.button variant="outline" size="sm" phx-click={JS.dispatch("sl:open", to: "#cmd")}><.icon name="magnifier" />
          Search
          <.kbd>⌘K</.kbd></.button>
          <.indicator count={3} label="3 unread notifications">
            <.button
              variant="ghost"
              size="sm"
              icon
              aria-label="Notifications"
              phx-click={JS.push("toast", value: %{title: "3 unread notifications", color: "info"})}
            ><.icon name="bell" /></.button>
          </.indicator>
          <.theme_toggle id="tpl-theme" />
        </.topbar_end>
      </:topbar>
      {render_slot(@inner_block)}
      <.command id="cmd">
        <:group label="Go to">
          <.command_item navigate="/templates/dashboard">
            <.icon name="home" /> Dashboard
          </.command_item>
          <.command_item navigate="/templates/list"><.icon name="users" /> Members</.command_item>
          <.command_item navigate="/templates/settings"><.icon name="cog" /> Settings</.command_item>
        </:group>
      </.command>
    </.app_shell>
    """
  end
end
