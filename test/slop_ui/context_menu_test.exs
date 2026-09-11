defmodule SlopUI.ContextMenuTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.Menu

  test "renders a focusable target and a pointer-placed menu" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.context_menu id="ctx">
        <p>Target</p>
        <:menu>
          <.menu_item>Open</.menu_item>
        </:menu>
      </.context_menu>
      """)

    assert html =~ ~s(<div id="ctx" class="sl-context-menu" phx-hook="SlMenu" data-context>)

    assert html =~
             ~r/id="ctx-target"[^>]*tabindex="0"[^>]*aria-haspopup="menu"[^>]*aria-controls="ctx-list"[^>]*aria-expanded="false"/

    assert html =~
             ~r/id="ctx-list" popover role="menu"[^>]*data-placement="pointer"[^>]*aria-label="Context menu"/

    assert html =~ ~s(role="menuitem")
    refute html =~ "popovertarget"
  end

  test "label and tabindex can be customised" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.context_menu id="ctx" label="Row actions" tabindex="-1">
        <button>Already focusable</button>
        <:menu>
          <.menu_item>Edit</.menu_item>
        </:menu>
      </.context_menu>
      """)

    assert html =~ ~s(aria-label="Row actions")
    assert html =~ ~r/id="ctx-target"[^>]*tabindex="-1"/
  end
end
