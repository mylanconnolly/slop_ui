defmodule SlopUI.Sink.Templates.List do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  import SlopUI.Sink.Templates.Chrome
  alias Phoenix.LiveView.JS

  def title, do: "Members"

  def render(assigns) do
    ~H"""
    <.app name={@name} title={title()}>
      <.stack gap="lg">
        <.page_header title="Members" description="People with access to this workspace.">
          <:actions>
            <.button variant="outline"><.icon name="upload" /> Import CSV</.button>
            <.button color="accent"><.icon name="plus" /> Invite</.button>
          </:actions>
        </.page_header>

        <.form for={%{}} as={:filters} phx-change="filters">
          <.cluster gap="sm" align="end">
            <.input
              name="q"
              value=""
              type="search"
              placeholder="Search members…"
              style="inline-size: 18rem"
            >
              <:prefix><.icon name="magnifier" /></:prefix>
            </.input>
            <.select
              name="role"
              value=""
              placeholder="Any role"
              options={~w(Owner Admin Member)}
              style="inline-size: 10rem"
            />
            <.toggle_group name="status" value="all" label="Status">
              <:option value="all">All</:option>
              <:option value="active">Active</:option>
              <:option value="invited">Invited</:option>
            </.toggle_group>
            <.button variant="ghost" size="sm" type="reset">Clear</.button>
          </.cluster>
        </.form>

        <.table
          id="members"
          rows={@users}
          on_sort={JS.push("sort")}
          sorted={@sort}
          row_click={fn _ -> JS.navigate("/templates/detail") end}
          caption="4 members"
        >
          <:col :let={u} label="Name" sort="name">
            <.cluster gap="sm" nowrap>
              <.avatar name={u.name} size="sm" />
              <span><strong>{u.name}</strong><br /><span class="sl-description">{String.downcase(
                String.replace(u.name, " ", ".")
              ) <> "@acme.com"}</span></span>
            </.cluster>
          </:col>
          <:col :let={u} label="Role">{u.role}</:col>
          <:col :let={u} label="Status">
            <.badge color={if u.active, do: "success", else: "neutral"} dot>
              {if u.active, do: "Active", else: "Invited"}
            </.badge>
          </:col>
          <:col :let={u} label="Commits" sort="commits" numeric>{u.commits}</:col>
          <:action :let={u}>
            <.menu id={"row-#{u.id}"} placement="bottom-end">
              <:trigger variant="ghost" size="sm" icon aria_label={"Actions for #{u.name}"}>
                <.icon name="ellipsis" />
              </:trigger>
              <.menu_item navigate="/templates/detail"><.icon name="user" /> View</.menu_item>
              <.menu_item><.icon name="mail" /> Resend invite</.menu_item>
              <.menu_separator />
              <.menu_item color="danger" phx-click={SlopJS.open_dialog("#remove-#{u.id}")}>
                <.icon name="trash" /> Remove
              </.menu_item>
            </.menu>
            <.alert_dialog
              id={"remove-#{u.id}"}
              title={"Remove #{u.name}?"}
              description="They will lose access immediately."
              confirm="Remove"
              on_confirm={JS.push("toast", value: %{title: "Removed #{u.name}", color: "danger"})}
            />
          </:action>
        </.table>

        <.cluster justify="between">
          <span class="sl-description">Showing 1–4 of 4</span>
          <.pagination
            page={@page_no}
            total_pages={1}
            path={&"/templates/list?page=#{&1}"}
            link="navigate"
          />
        </.cluster>
      </.stack>
    </.app>
    """
  end
end
