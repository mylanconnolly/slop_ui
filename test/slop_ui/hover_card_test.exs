defmodule SlopUI.HoverCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.HoverCard

  test "renders an anchored manual popover with delays" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.hover_card id="hc" placement="top" open_delay={100} close_delay={50}>
        <:trigger><a href="/u/ada">@ada</a></:trigger>
        <p>Ada</p>
      </.hover_card>
      """)

    assert html =~
             ~r/<span id="hc" class="sl-hover-card" style="anchor-name: --sl-hc"[^>]*phx-hook="SlHoverCard"[^>]*data-open-delay="100"[^>]*data-close-delay="50"/

    assert html =~ ~s(<a href="/u/ada">@ada</a>)

    assert html =~
             ~r/<div id="hc-card" popover="manual" class="sl-hover-card-panel" data-placement="top" style="--sl-anchor: --sl-hc">/

    assert html =~ "<p>Ada</p>"
  end
end
