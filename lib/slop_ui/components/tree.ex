defmodule SlopUI.Components.Tree do
  @moduledoc "Tree views (WAI-ARIA tree pattern) for file browsers, navigation and hierarchies."
  use Phoenix.Component
  import SlopUI.Icons

  @doc """
  Renders a tree. Nest `tree_item/1` components inside; items with children
  become expandable branches.

      <.tree id="files" label="Project files" on_select={JS.push("open")}>
        <.tree_item value="src" label="src" expanded>
          <:icon><.icon name="folder" /></:icon>
          <.tree_item value="src/app.ex" label="app.ex" />
          <.tree_item value="src/app_web" label="app_web">
            <.tree_item value="src/app_web/router.ex" label="router.ex" />
          </.tree_item>
        </.tree_item>
        <.tree_item value="mix.exs" label="mix.exs" navigate={~p"/files/mix.exs"} />
      </.tree>

  Selection is client-owned by default: clicking or pressing Enter/Space
  selects an item and runs `on_select` with `phx-value-value` set to the
  item's value (`phx-value-*` from `on_select`'s target are included too).
  Pass `selected` to make the server own it instead: the tree then follows the
  assign and `on_select` is how you update it. Items with `navigate`, `patch`
  or `href` are links and work without JavaScript.

  Keyboard: ArrowUp/ArrowDown move, ArrowRight expands or moves into a
  branch, ArrowLeft collapses or moves to the parent, Home/End jump, `*`
  expands every sibling, typing jumps to the next item starting with those
  letters, Enter/Space select (Enter also toggles a branch or follows a link).
  """
  attr :id, :string, required: true
  attr :label, :string, default: nil, doc: "accessible name; or use `labelledby`"
  attr :labelledby, :string, default: nil
  attr :selected, :any, default: nil, doc: "server-owned selected value"
  attr :expanded_all, :boolean, default: false, doc: "start with every branch open"
  attr :on_select, Phoenix.LiveView.JS, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def tree(assigns) do
    ~H"""
    <ul
      id={@id}
      role="tree"
      class={[@class, "sl-tree"]}
      aria-label={@label}
      aria-labelledby={@labelledby}
      data-selected={@selected}
      data-controlled={to_string(@selected != nil)}
      data-expanded-all={@expanded_all && "true"}
      data-on-select={@on_select}
      phx-hook="SlTree"
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  @doc """
  An item in a `tree/1`. Children (nested `tree_item`s in the inner block)
  make it a branch that can expand and collapse.

      <.tree_item value="docs" label="Docs" expanded>
        <:icon><.icon name="folder" /></:icon>
        <.tree_item value="docs/readme" label="README.md" />
      </.tree_item>
  """
  attr :value, :string, required: true
  attr :label, :string, required: true
  attr :expanded, :boolean, default: false
  attr :selected, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :href, :any, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(method download target)
  slot :icon
  slot :inner_block

  def tree_item(assigns) do
    assigns = assign(assigns, :branch, branch?(assigns.inner_block))

    ~H"""
    <li role="none" class={[@class, "sl-tree-item"]}>
      <.row
        branch={@branch}
        link={@href || @navigate || @patch}
        href={@href}
        navigate={@navigate}
        patch={@patch}
        value={@value}
        expanded={@expanded}
        selected={@selected}
        disabled={@disabled}
        rest={@rest}
      >
        <span class="sl-tree-toggle" data-leaf={!@branch && "true"} aria-hidden="true">
          <.icon name="chevron-right" />
        </span>
        {render_slot(@icon)}
        <span class="sl-tree-label">{@label}</span>
      </.row>
      <div :if={@branch} class="sl-tree-children">
        <ul role="group" class="sl-tree-group">
          {render_slot(@inner_block)}
        </ul>
      </div>
    </li>
    """
  end

  # An item is a branch when its inner block has content other than the
  # whitespace HEEx leaves around extracted `<:icon>` slots. The slot's
  # rendered struct exposes that through `static` alone, without running
  # the dynamic parts: one static chunk means nothing dynamic in between.
  defp branch?([]), do: false

  defp branch?(inner_block) do
    case Phoenix.Component.__render_slot__(nil, inner_block, nil) do
      %Phoenix.LiveView.Rendered{static: static} ->
        length(static) > 1 or Enum.any?(static, &(String.trim(&1) != ""))

      nil ->
        false

      _ ->
        true
    end
  end

  attr :branch, :boolean, required: true
  attr :link, :any, required: true
  attr :href, :any
  attr :navigate, :any
  attr :patch, :any
  attr :value, :string
  attr :expanded, :boolean
  attr :selected, :boolean
  attr :disabled, :boolean
  attr :rest, :map
  slot :inner_block, required: true

  defp row(%{link: nil} = assigns) do
    ~H"""
    <div
      role="treeitem"
      class="sl-tree-row"
      tabindex="-1"
      data-value={@value}
      phx-value-value={@value}
      aria-expanded={@branch && to_string(@expanded)}
      aria-selected={to_string(@selected)}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp row(assigns) do
    ~H"""
    <.link
      role="treeitem"
      class="sl-tree-row"
      tabindex="-1"
      href={@href}
      navigate={@navigate}
      patch={@patch}
      data-value={@value}
      phx-value-value={@value}
      aria-expanded={@branch && to_string(@expanded)}
      aria-selected={to_string(@selected)}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
