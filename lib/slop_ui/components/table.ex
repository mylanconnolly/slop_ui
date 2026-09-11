defmodule SlopUI.Components.Table do
  @moduledoc "Data tables."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders a table with column and action slots. Works with lists and streams.

      <.table id="users" rows={@users} row_click={&JS.navigate(~p"/users/\#{&1}")}>
        <:col :let={user} label="Name">{user.name}</:col>
        <:col :let={user} label="Email" sort="email" sorted={@sort}>{user.email}</:col>
        <:action :let={user}>
          <.button size="sm" variant="ghost" navigate={~p"/users/\#{user}"}>Edit</.button>
        </:action>
      </.table>

  Sortable columns: give `sort` a field name and `sorted` the current
  `{field, :asc | :desc}`; the header renders a button that pushes
  `on_sort` with `phx-value-field` and `phx-value-dir`, and the `<th>`
  carries `aria-sort`.

  Selectable rows: `selectable` adds a checkbox column. Each checkbox is
  named `<id>[]` (override with `select_name`) with the row's `id` as value
  (override with `row_value`), so a surrounding form receives the selection
  as a list. Pass `selected` to render the current selection from the server;
  `on_select` runs when it changes, with `phx-value-id` + `phx-value-selected`
  for one row, `phx-value-ids` (comma separated) for a Shift+click range, or
  `phx-value-all` for the header checkbox:

      <.table id="users" rows={@users} selectable selected={@selected} on_select={JS.push("select")}>

      def handle_event("select", %{"all" => _, "selected" => on}, socket) ...
      def handle_event("select", %{"id" => id, "selected" => on}, socket) ...

  Keyboard: the checkboxes are the tab stops; Space toggles one, and the
  header checkbox toggles every row.
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  attr :caption, :string, default: nil
  attr :striped, :boolean, default: false
  attr :hover, :boolean, default: true
  attr :sticky, :boolean, default: false, doc: "sticky header inside a scrolling wrapper"
  attr :density, :string, default: "default", values: ~w(default compact)
  attr :empty, :string, default: nil, doc: ~s|defaults to "Nothing to show yet."|
  attr :on_sort, Phoenix.LiveView.JS, default: nil
  attr :sorted, :any, default: nil, doc: "{field, :asc | :desc}"
  attr :selectable, :boolean, default: false
  attr :selected, :list, default: [], doc: "values of the selected rows"
  attr :select_name, :string, default: nil, doc: ~s|checkbox name; defaults to "\#{id}[]"|

  attr :row_value, :any,
    default: nil,
    doc: "function returning a row's checkbox value; defaults to the item's `:id`"

  attr :on_select, Phoenix.LiveView.JS, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :col, required: true do
    attr :label, :string
    attr :align, :string, doc: "start | center | end"
    attr :numeric, :boolean
    attr :sort, :string, doc: "field name that makes this column sortable"
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    row_item = assigns.row_item

    assigns =
      assign(assigns,
        select_name: assigns.select_name || "#{assigns.id}[]",
        row_value: assigns.row_value || fn row -> Map.get(row_item.(row), :id) end,
        selected: Enum.map(assigns.selected, &to_string/1),
        columns:
          length(assigns.col) + if(assigns.action != [], do: 1, else: 0) +
            if(assigns.selectable, do: 1, else: 0)
      )

    ~H"""
    <div
      class={[@class, "sl-table-wrap"]}
      data-sticky={@sticky}
      phx-hook={@selectable && "SlTable"}
      id={@selectable && "#{@id}-wrap"}
      data-on-select={@on_select}
      {@rest}
    >
      <table
        id={@id}
        class="sl-table"
        data-striped={@striped}
        data-hover={@hover}
        data-density={@density}
        data-selectable={@selectable}
      >
        <caption :if={@caption}>{@caption}</caption>
        <thead>
          <tr>
            <th :if={@selectable} scope="col" class="sl-table-select-cell">
              <input
                type="checkbox"
                class="sl-checkbox sl-table-select"
                data-all
                aria-label={t("Select all rows")}
                checked={@rows != [] && Enum.all?(@rows, &(to_string(@row_value.(&1)) in @selected))}
              />
            </th>
            <th
              :for={col <- @col}
              scope="col"
              data-align={col[:align]}
              data-numeric={col[:numeric]}
              aria-sort={col[:sort] && sort_state(@sorted, col.sort)}
            >
              <button
                :if={col[:sort]}
                type="button"
                class="sl-table-sort"
                phx-click={@on_sort}
                phx-value-field={col.sort}
                phx-value-dir={next_dir(@sorted, col.sort)}
              >
                {col[:label]} <.icon name="chevron-down" />
              </button>
              <span :if={!col[:sort]}>{col[:label]}</span>
            </th>
            <th :if={@action != []} scope="col">
              <span class="sl-visually-hidden">{t("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={"#{@id}-body"}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            data-clickable={@row_click && true}
            phx-click={@row_click && @row_click.(row)}
            aria-selected={@selectable && to_string(to_string(@row_value.(row)) in @selected)}
          >
            <td :if={@selectable} class="sl-table-select-cell" phx-click={@row_click && ""}>
              <input
                type="checkbox"
                class="sl-checkbox sl-table-select"
                name={@select_name}
                value={@row_value.(row)}
                checked={to_string(@row_value.(row)) in @selected}
                aria-label={t("Select row")}
              />
            </td>
            <td :for={col <- @col} data-align={col[:align]} data-numeric={col[:numeric]}>
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []}>
              <div class="sl-table-actions">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
          <tr :if={@rows == []}>
            <td class="sl-table-empty" colspan={@columns}>
              {@empty || t("Nothing to show yet.")}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp sort_state({field, dir}, col) do
    if to_string(field) == to_string(col) do
      if dir == :desc, do: "descending", else: "ascending"
    end
  end

  defp sort_state(_, _), do: nil

  defp next_dir({field, :asc}, col) do
    if to_string(field) == to_string(col), do: "desc", else: "asc"
  end

  defp next_dir(_, _), do: "asc"
end
