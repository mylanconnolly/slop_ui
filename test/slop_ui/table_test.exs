defmodule SlopUI.TableTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SlopUI.Components.Table
  alias Phoenix.LiveView.JS

  defp rows, do: [%{id: 1, n: "a"}, %{id: 2, n: "b"}]
  defp cols, do: [%{label: "N", sort: "n", inner_block: fn _, row -> row.n end}]

  test "aria-sort lives on the th and the sort control is a button" do
    html = render_component(&table/1, id: "t", rows: rows(), sorted: {:n, :asc}, col: cols())
    assert html =~ ~r/<th[^>]*aria-sort="ascending"/
    assert html =~ ~s(<button type="button" class="sl-table-sort")
    assert html =~ ~s(phx-value-dir="desc")
    refute html =~ ~r/<button[^>]*aria-sort/
  end

  test "selectable renders a checkbox column, names, values and aria-selected" do
    html =
      render_component(&table/1,
        id: "t",
        rows: rows(),
        selectable: true,
        selected: [2],
        on_select: JS.push("select"),
        col: cols()
      )

    assert html =~ ~s(phx-hook="SlTable")
    assert html =~ ~s(data-on-select=)
    assert html =~ ~s(aria-label="Select all rows")
    assert html =~ ~s(name="t[]" value="1")
    assert html =~ ~s(name="t[]" value="2" checked)
    assert html =~ ~s(aria-selected="false")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(data-selectable)
  end

  test "select all is checked only when every row is selected; empty tables span the extra column" do
    all =
      render_component(&table/1,
        id: "t",
        rows: rows(),
        selectable: true,
        selected: ["1", "2"],
        col: cols()
      )

    assert all =~ ~r/data-all[^>]*checked/

    some =
      render_component(&table/1,
        id: "t",
        rows: rows(),
        selectable: true,
        selected: [1],
        col: cols()
      )

    refute some =~ ~r/data-all[^>]*checked/
    empty = render_component(&table/1, id: "t", rows: [], selectable: true, col: cols())
    assert empty =~ ~s(colspan="2")
  end

  test "row_value and select_name override defaults" do
    html =
      render_component(&table/1,
        id: "t",
        rows: rows(),
        selectable: true,
        select_name: "picked[]",
        row_value: &"row-#{&1.id}",
        col: cols()
      )

    assert html =~ ~s(name="picked[]" value="row-1")
  end

  test "plain tables have no hook or checkbox column" do
    html = render_component(&table/1, id: "t", rows: rows(), col: cols())
    refute html =~ "SlTable"
    refute html =~ "sl-table-select"
  end
end
