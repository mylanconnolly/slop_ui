defmodule SlopUI.ScrollAreaTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.ScrollArea

  test "renders a focusable named region" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.scroll_area label="Log" style="max-block-size: 4rem">x</.scroll_area>|
      )

    assert html =~ ~s(class="sl-scroll-area")
    assert html =~ ~s(role="region")
    assert html =~ ~s(aria-label="Log")
    assert html =~ ~s(tabindex="0")
    assert html =~ ~s(data-shadows)
    assert html =~ ~s(data-orientation="vertical")
  end

  test "shadows can be turned off" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.scroll_area label="Log" shadows={false} orientation="horizontal">x</.scroll_area>|
      )

    refute html =~ "data-shadows"
    assert html =~ ~s(data-orientation="horizontal")
  end
end
