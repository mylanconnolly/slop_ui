defmodule SlopUI.TreeTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.Tree
  alias Phoenix.LiveView.JS

  defp tree_html(assigns) do
    rendered_to_string(~H"""
    <.tree id="t" label="Files" on_select={JS.push("open")}>
      <.tree_item value="src" label="src" expanded>
        <.tree_item value="src/a.ex" label="a.ex" selected />
        <.tree_item value="src/b.ex" label="b.ex" navigate="/b" />
      </.tree_item>
      <.tree_item value="mix.exs" label="mix.exs" disabled />
    </.tree>
    """)
  end

  test "renders the ARIA tree structure" do
    html = tree_html(%{})
    assert html =~ ~s(<ul id="t" role="tree" class="sl-tree" aria-label="Files")
    assert html =~ ~s(data-controlled="false")
    assert html =~ ~s(phx-hook="SlTree")
    assert html =~ ~s(data-on-select=)
    assert html =~ ~s(role="group")
  end

  test "branches carry aria-expanded and leaves do not" do
    html = tree_html(%{})
    assert html =~ ~r/data-value="src"[^>]*aria-expanded="true"/
    refute html =~ ~r/data-value="src\/a\.ex"[^>]*aria-expanded/
    assert html =~ ~r/data-value="src\/a\.ex"[^>]*aria-selected="true"/
    assert html =~ ~r/data-value="mix\.exs"[^>]*aria-disabled="true"/
    assert html =~ ~s(data-leaf="true")
  end

  test "an icon slot alone does not make a branch" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.tree id="t" label="Files">
        <.tree_item value="a" label="A">
          <:icon><span>i</span></:icon>
        </.tree_item>
        <.tree_item value="b" label="B">
          <:icon><span>i</span></:icon>
          <.tree_item value="b/c" label="C" />
        </.tree_item>
      </.tree>
      """)

    refute html =~ ~r/data-value="a"[^>]*aria-expanded/
    assert html =~ ~r/data-value="b"[^>]*aria-expanded="false"/
    assert length(String.split(html, "sl-tree-children")) == 2
  end

  test "link items render anchors with the treeitem role" do
    html = tree_html(%{})

    assert html =~
             ~r/<a href="\/b" data-phx-link="redirect"[^>]*role="treeitem"[^>]*data-value="src\/b\.ex"/

    assert html =~ ~s(phx-value-value="src/b.ex")
  end

  test "server-owned selection marks the tree controlled" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.tree id="t" label="Docs" selected="b" expanded_all>
        <.tree_item value="a" label="A" />
      </.tree>
      """)

    assert html =~ ~s(data-selected="b")
    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(data-expanded-all="true")
  end
end
