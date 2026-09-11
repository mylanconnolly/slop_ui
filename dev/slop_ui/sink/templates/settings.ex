defmodule SlopUI.Sink.Templates.Settings do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  import SlopUI.Sink.Templates.Chrome
  alias Phoenix.LiveView.JS

  def title, do: "Settings"

  def render(assigns) do
    ~H"""
    <.app name={@name} title={title()} width="narrow">
      <.stack gap="lg">
        <.page_header title="Settings" description="Manage your profile, preferences and billing." />
        <.tabs
          id="settings"
          value={@settings_tab}
          on_change={JS.push("settings-tab")}
          variant="pill"
          label="Settings sections"
        >
          <:tab value="profile">Profile</:tab>
          <:tab value="preferences">Preferences</:tab>
          <:tab value="billing">Billing</:tab>
          <:tab value="danger">Danger zone</:tab>

          <:panel value="profile">
            <.form for={@form} phx-change="settings" phx-submit="settings">
              <.card>
                <:header
                  title="Profile"
                  heading_level="h2"
                  description="How you appear to your team."
                />
                <.stack gap="lg">
                  <.cluster gap="md">
                    <.avatar name={@form[:name].value} size="xl" />
                    <.stack gap="xs">
                      <.button variant="outline" size="sm">Change photo</.button><span class="sl-description">PNG or JPG, up to 2 MB.</span>
                    </.stack>
                  </.cluster>
                  <.grid min="14rem">
                    <.input field={@form[:name]} label="Name" required /><.input
                      field={@form[:email]}
                      type="email"
                      label="Email"
                      required
                    />
                  </.grid>
                  <.input
                    field={@form[:bio]}
                    type="textarea"
                    label="Bio"
                    description="A short line for your profile card."
                  />
                  <.tag_input name="settings[skills][]" value={~w(elixir css)} label="Skills" />
                </.stack>
                <:footer divider justify="end">
                  <.button variant="ghost" type="reset">Cancel</.button>
                  <.button
                    color="accent"
                    type="submit"
                    phx-click={JS.push("toast", value: %{title: "Profile saved"})}
                  >Save changes</.button>
                </:footer>
              </.card>
            </.form>
          </:panel>

          <:panel value="preferences">
            <.form for={@form} phx-change="settings">
              <.stack gap="md">
                <.card>
                  <:header title="Notifications" heading_level="h2" />
                  <.stack gap="md">
                    <.input
                      type="switch"
                      field={@form[:notify]}
                      label="Email me when someone mentions me"
                    />
                    <.checkbox_group
                      name="settings[channels][]"
                      value={~w(email)}
                      label="Channels"
                      orientation="horizontal"
                      options={~w(email sms push)}
                    />
                    <.radio_group
                      name="settings[digest]"
                      value="daily"
                      label="Digest"
                      variant="cards"
                      orientation="horizontal"
                      options={[
                        %{label: "Daily", value: "daily", description: "One summary each morning"},
                        %{label: "Weekly", value: "weekly", description: "Monday roundup"},
                        %{label: "Off", value: "off"}
                      ]}
                    />
                  </.stack>
                </.card>
                <.card>
                  <:header
                    title="Appearance"
                    heading_level="h2"
                    description="These use the library's own preference system."
                  />
                  <.cluster gap="md" align="end">
                    <.select
                      field={@form[:language]}
                      label="Language"
                      options={[{"English", "en"}, {"Deutsch", "de"}, {"Français", "fr"}]}
                      style="inline-size: 12rem"
                    />
                    <.stack gap="xs">
                      <span class="sl-label">Theme</span><.theme_toggle id="settings-theme" />
                    </.stack>
                  </.cluster>
                </.card>
              </.stack>
            </.form>
          </:panel>

          <:panel value="billing">
            <.stack gap="md">
              <.card>
                <:header title="Plan" heading_level="h2">
                  <.badge color="accent">Pro</.badge>
                </:header>
                <.description_list divider>
                  <:item label="Seats">10 of 25 used</:item>
                  <:item label="Renews">October 1, 2026</:item>
                  <:item label="Payment">
                    <.cluster gap="sm"><.icon name="credit-card" /> Visa ending 4242</.cluster>
                  </:item>
                </.description_list>
                <:footer divider justify="end">
                  <.button variant="outline">Change plan</.button><.button color="accent">Update card</.button>
                </:footer>
              </.card>
              <.alert color="info" title="Invoices are emailed">
                Each invoice goes to the billing contact on the first of the month.
              </.alert>
            </.stack>
          </:panel>

          <:panel value="danger">
            <.card style="border-color: color-mix(in oklch, var(--sl-color-danger) 40%, transparent)">
              <:header
                title="Delete workspace"
                heading_level="h2"
                description="This removes every project, member and file. It cannot be undone."
              />
              <:footer justify="end">
                <.button color="danger" phx-click={SlopJS.open_dialog("#delete-ws")}>Delete workspace…</.button>
              </:footer>
            </.card>
            <.alert_dialog
              id="delete-ws"
              title="Delete this workspace?"
              description="Type the workspace name to confirm in a real app."
              confirm="Delete forever"
              on_confirm={JS.push("toast", value: %{title: "Deleted", color: "danger"})}
            />
          </:panel>
        </.tabs>
      </.stack>
    </.app>
    """
  end
end
