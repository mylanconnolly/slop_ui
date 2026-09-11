defmodule SlopUI.Sink.Templates.Dashboard do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  import SlopUI.Sink.Templates.Chrome
  alias Phoenix.LiveView.JS

  def title, do: "Dashboard"

  def render(assigns) do
    ~H"""
    <.app name={@name} title={title()} width="wide">
      <.stack gap="lg">
        <.page_header title="Good morning, Ada" description="Here's what changed since yesterday.">
          <:actions>
            <.button variant="outline"><.icon name="upload" /> Export</.button>
            <.button color="accent"><.icon name="plus" /> New project</.button>
          </:actions>
        </.page_header>

        <.grid min="13rem" gap="md">
          <.stat label="Revenue" value="$48.2k" delta="+12.4%" trend="up" description="vs. last month">
            <:icon><.icon name="chart" /></:icon>
          </.stat>
          <.stat
            label="Active users"
            value="12,904"
            delta="+3.1%"
            trend="up"
            description="last 30 days"
          >
            <:icon><.icon name="users" /></:icon>
          </.stat>
          <.stat label="Churn" value="2.1%" delta="-0.4%" trend="down" description="vs. last month" />
          <.stat label="Open tickets" value="17" delta="0" trend="flat" description="no change" />
        </.grid>

        <.grid min="24rem" gap="md">
          <.card>
            <:header title="Recent members" description="Newest sign-ups across all teams.">
              <.button size="sm" variant="ghost" navigate="/templates/list">View all</.button>
            </:header>
            <.table
              id="recent"
              rows={Enum.take(@users, 3)}
              row_click={fn _ -> JS.navigate("/templates/detail") end}
            >
              <:col :let={u} label="Name">
                <.cluster gap="sm" nowrap><.avatar name={u.name} size="sm" /> {u.name}</.cluster>
              </:col>
              <:col :let={u} label="Role">{u.role}</:col>
              <:col :let={u} label="Status">
                <.badge color={if u.active, do: "success", else: "neutral"} dot>
                  {if u.active, do: "Active", else: "Invited"}
                </.badge>
              </:col>
            </.table>
          </.card>
          <.card>
            <:header title="Activity" />
            <.timeline>
              <:item title="Deployed v2.1" time="2h ago" color="success">
                Rolled out to all regions.
              </:item>
              <:item title="Grace Hopper joined" time="5h ago" color="accent" />
              <:item title="Flaky test quarantined" time="Yesterday" color="warning">
                Search::IndexerTest timed out twice.
              </:item>
              <:item title="Incident #212 resolved" time="2 days ago" color="info" />
            </.timeline>
          </.card>
        </.grid>

        <.card>
          <:header title="Onboarding" description="Two steps left before the workspace is ready." />
          <.stepper current={@step}>
            <:step title="Create workspace" description="Done" />
            <:step title="Invite your team" description="2 of 5 invited" />
            <:step title="Connect billing" />
            <:step title="Launch" />
          </.stepper>
          <:footer justify="end"><.button color="accent">Continue setup</.button></:footer>
        </.card>
      </.stack>
    </.app>
    """
  end
end
