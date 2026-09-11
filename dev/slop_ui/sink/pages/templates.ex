defmodule SlopUI.Sink.Pages.Templates do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Shell, :app_shell},
      {SlopUI.Components.Shell, :sidebar},
      {SlopUI.Components.Shell, :nav},
      {SlopUI.Components.Shell, :nav_group},
      {SlopUI.Components.Shell, :nav_item},
      {SlopUI.Components.Shell, :nav_collapsible},
      {SlopUI.Components.Shell, :topbar_end},
      {SlopUI.Components.Shell, :indicator},
      {SlopUI.Components.Shell, :auth_layout}
    ]
  end

  @templates [
    {"dashboard", "Dashboard", "Stats, recent table, activity timeline, onboarding stepper.",
     "chart"},
    {"list", "List", "Page header, filter toolbar, sortable table with row menus, pagination.",
     "users"},
    {"detail", "Detail",
     "Header with avatar and actions, tabs, description list, usage, timeline.", "user"},
    {"settings", "Settings",
     "Server-owned tabs, profile form, preference groups, billing, danger zone.", "cog"},
    {"sign-in", "Sign in", "Centred auth layout with social button, separator and remember-me.",
     "lock"},
    {"sign-up", "Sign up", "Auth layout with a stepper, pin input and terms checkbox.", "mail"}
  ]

  def render(assigns) do
    assigns = assign(assigns, :templates, @templates)

    ~H"""
    <.example
      title="Full-page templates"
      description="Each opens in a new tab as a complete page built only from library components: app shell, navigation, topbar with search and notifications, and the auth layout. Resize below 64rem to see the sidebar become a sheet."
    >
      <.grid min="16rem" gap="md">
        <.card :for={{slug, name, desc, icon} <- @templates}>
          <:header title={name} heading_level="h3" description={desc}>
            <.icon
              name={icon}
              style="inline-size: 1.25rem; block-size: 1.25rem; color: var(--sl-color-fg-subtle)"
            />
          </:header>
          <:footer justify="end">
            <.button
              size="sm"
              variant="outline"
              href={"/templates/#{slug}"}
              target="_blank"
              rel="noopener"
            >Open</.button>
          </:footer>
        </.card>
      </.grid>
    </.example>

    <.example
      title="Shell pieces in isolation"
      code={
        ~S|<.nav><.nav_group label="Workspace"><.nav_item navigate="/" current><.icon name="home" /> Home</.nav_item></.nav_group></.nav>|
      }
    >
      <.grid min="16rem" gap="lg">
        <div
          class="sl-sidebar"
          style="position: static; block-size: auto; border-radius: var(--sl-radius-lg); border: 1px solid var(--sl-color-border)"
        >
          <a href="#" class="sl-sidebar-brand"><.icon name="folder" /> Acme</a>
          <.nav label="Example">
            <.nav_group label="Workspace">
              <.nav_item href="#" current><.icon name="home" /> Dashboard</.nav_item>
              <.nav_item href="#" badge="12" badge_color="accent">
                <.icon name="inbox" /> Inbox
              </.nav_item>
              <.nav_collapsible label="Settings" open>
                <:icon><.icon name="cog" /></:icon>
                <.nav_item href="#">Profile</.nav_item>
                <.nav_item href="#">Billing</.nav_item>
              </.nav_collapsible>
            </.nav_group>
          </.nav>
        </div>
        <.stack gap="md">
          <.cluster gap="md">
            <.indicator count={3} label="3 unread">
              <.button variant="outline" icon aria-label="Notifications"><.icon name="bell" /></.button>
            </.indicator>
            <.indicator count={120}>
              <.button variant="outline" icon aria-label="Messages"><.icon name="mail" /></.button>
            </.indicator>
            <.indicator dot color="success"><.avatar name="Ada Lovelace" /></.indicator>
          </.cluster>
          <p class="sl-description">
            Indicators: a count (capped with +), or a dot; the marker is described for assistive tech via label.
          </p>
        </.stack>
      </.grid>
    </.example>
    """
  end
end
