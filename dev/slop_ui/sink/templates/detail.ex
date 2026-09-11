defmodule SlopUI.Sink.Templates.Detail do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  import SlopUI.Sink.Templates.Chrome
  alias Phoenix.LiveView.JS

  def title, do: "Ada Lovelace"

  def render(assigns) do
    ~H"""
    <.app name={@name} title={title()} crumbs={[{"Members", "/templates/list"}]}>
      <.stack gap="lg">
        <.page_header title="Ada Lovelace" description="Owner · joined December 10, 1815">
          <:eyebrow>
            <.cluster gap="sm"><.avatar name="Ada Lovelace" size="lg" status="online" /></.cluster>
          </:eyebrow>
          <:actions>
            <.button variant="outline"><.icon name="mail" /> Message</.button>
            <.menu id="detail-actions" placement="bottom-end">
              <:trigger variant="outline">More <.icon name="chevron-down" /></:trigger>
              <.menu_item><.icon name="cog" /> Change role</.menu_item>
              <.menu_item><.icon name="lock" /> Reset password</.menu_item>
              <.menu_separator />
              <.menu_item color="danger" phx-click={SlopJS.open_dialog("#deactivate")}>
                <.icon name="trash" /> Deactivate
              </.menu_item>
            </.menu>
          </:actions>
        </.page_header>

        <.tabs id="detail-tabs" default="overview" label="Sections">
          <:tab value="overview">Overview</:tab>
          <:tab value="activity">Activity</:tab>
          <:tab value="security">Security</:tab>
          <:panel value="overview">
            <.grid min="20rem" gap="md">
              <.card>
                <:header title="Profile" heading_level="h3" />
                <.description_list divider>
                  <:item label="Email">
                    ada@acme.com
                    <.copy_button value="ada@acme.com" variant="ghost" icon label="Copy email" />
                  </:item>
                  <:item label="Role">
                    <.badge color="accent">Owner</.badge>
                  </:item>
                  <:item label="Teams">
                    <.cluster gap="xs">
                      <.badge>Platform</.badge><.badge>Design</.badge>
                    </.cluster>
                  </:item>
                  <:item label="Timezone">Europe/London</:item>
                  <:item label="Two-factor">
                    <.badge color="success" dot>Enabled</.badge>
                  </:item>
                </.description_list>
              </.card>
              <.card>
                <:header title="Usage" heading_level="h3" />
                <.stack gap="md">
                  <div>
                    <.cluster justify="between">
                      <span>Storage</span><span class="sl-description">6.2 of 10 GB</span>
                    </.cluster><.progress value={62} label="Storage used" />
                  </div>
                  <div>
                    <.cluster justify="between">
                      <span>API calls</span><span class="sl-description">840k of 1M</span>
                    </.cluster><.progress value={84} color="warning" label="API calls used" />
                  </div>
                  <.rating value={4} readonly label="Satisfaction" show_value size="sm" />
                </.stack>
              </.card>
            </.grid>
          </:panel>
          <:panel value="activity">
            <.card>
              <.timeline>
                <:item title="Signed in from London" time="10 minutes ago" color="success" />
                <:item title="Changed workspace name" time="Yesterday" color="accent">
                  From "Acme Inc" to "Acme".
                </:item>
                <:item title="Failed sign-in attempt" time="3 days ago" color="danger">
                  Wrong password, from a new device.
                </:item>
              </.timeline>
            </.card>
          </:panel>
          <:panel value="security">
            <.card>
              <:header title="Sessions" heading_level="h3" description="Devices currently signed in." />
              <.empty_state
                title="No other sessions"
                description="Only this device is signed in."
                variant="plain"
              >
                <:icon><.icon name="lock" /></:icon>
              </.empty_state>
            </.card>
          </:panel>
        </.tabs>
      </.stack>
      <.alert_dialog
        id="deactivate"
        title="Deactivate Ada Lovelace?"
        description="They will be signed out everywhere and lose access."
        confirm="Deactivate"
        on_confirm={JS.push("toast", value: %{title: "Deactivated", color: "danger"})}
      />
    </.app>
    """
  end
end
