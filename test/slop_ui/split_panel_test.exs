defmodule SlopUI.SplitPanelTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.SplitPanel

  test "renders two panes and an accessible separator" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.split_panel id="s" default={30} min={10} max={80} storage_key="k">
        <:primary>A</:primary>
        <:secondary>B</:secondary>
      </.split_panel>
      """)

    assert html =~ ~s(phx-hook="SlSplitPanel")
    assert html =~ ~s(style="--sl-split-size: 30%;")
    assert html =~ ~s(data-storage-key="k")
    assert html =~ ~s(role="separator")
    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ ~s(aria-valuenow="30")
    assert html =~ ~s(aria-valuemin="10")
    assert html =~ ~s(aria-valuemax="80")
    assert html =~ ~s(aria-controls="s-primary")
    assert html =~ ~s(aria-label="Resize panels")
    assert html =~ ~s(tabindex="0")
  end

  test "vertical orientation flips the separator's orientation" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.split_panel id="s" orientation="vertical">
        <:primary>A</:primary><:secondary>B</:secondary>
      </.split_panel>
      """)

    assert html =~ ~s(data-orientation="vertical")
    assert html =~ ~s(aria-orientation="horizontal")
  end
end
