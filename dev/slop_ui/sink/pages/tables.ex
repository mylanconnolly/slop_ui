defmodule SlopUI.Sink.Pages.Tables do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  alias Phoenix.LiveView.JS

  def components do
    [
      {SlopUI.Components.Table, :table}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Sortable, clickable rows"
      description="Column headers with sort push on_sort with phx-value-field and phx-value-dir; aria-sort tracks state."
      code={
        ~S|<.table id="users" rows={@users} on_sort={JS.push("sort")} sorted={@sort}><:col :let={u} label="Name" sort="name">{u.name}</:col>…</.table>|
      }
    >
      <.table
        id="users"
        rows={@users}
        row_click={fn u -> JS.push("toast", value: %{color: "info", title: u.name}) end}
        on_sort={JS.push("sort")}
        sorted={@sort}
        caption="Team members"
      >
        <:col :let={u} label="Name" sort="name">
          <.cluster gap="sm" nowrap><.avatar name={u.name} size="sm" /> {u.name}</.cluster>
        </:col>
        <:col :let={u} label="Role">{u.role}</:col>
        <:col :let={u} label="Status">
          <.badge color={if u.active, do: "success", else: "neutral"} dot>
            {if u.active, do: "Active", else: "Invited"}
          </.badge>
        </:col>
        <:col :let={u} label="Commits" sort="commits" numeric>{u.commits}</:col>
        <:action :let={u}>
          <.button
            size="sm"
            variant="ghost"
            phx-click={JS.push("toast", value: %{title: "Edit #{u.name}"})}
          >Edit</.button>
        </:action>
      </.table>
    </.example>

    <.example
      title="Selectable rows"
      description="selectable adds a checkbox column; selected renders the server's selection and on_select pushes id / ids (Shift+click range) / all with selected=true|false. Rows carry aria-selected."
      code={
        ~S|<.table id="pick" rows={@users} selectable selected={@selected_ids} on_select={JS.push("select")}>…</.table>|
      }
    >
      <.stack gap="sm">
        <.table
          id="pick"
          rows={@users}
          selectable
          selected={@selected_ids}
          on_select={JS.push("select")}
          row_click={fn u -> JS.push("toast", value: %{color: "info", title: u.name}) end}
        >
          <:col :let={u} label="Name">{u.name}</:col>
          <:col :let={u} label="Role">{u.role}</:col>
          <:col :let={u} label="Commits" numeric>{u.commits}</:col>
        </.table>
        <.badge>selected: {inspect(@selected_ids)}</.badge>
      </.stack>
    </.example>

    <.example title="Striped, compact, sticky header">
      <.table
        id="compact"
        rows={Enum.concat(@users, @users)}
        striped
        density="compact"
        sticky
        style="--sl-table-max-height: 14rem"
      >
        <:col :let={u} label="Name">{u.name}</:col>
        <:col :let={u} label="Role">{u.role}</:col>
        <:col :let={u} label="Commits" numeric>{u.commits}</:col>
      </.table>
    </.example>

    <.example title="Empty">
      <.table id="empty" rows={[]} empty="No members yet. Invite someone to get started.">
        <:col label="Name" />
        <:col label="Role" />
      </.table>
    </.example>
    """
  end
end
