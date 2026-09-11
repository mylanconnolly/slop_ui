defmodule SlopUI.CarouselTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.Carousel

  test "renders slides, dots and controls with carousel semantics" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.carousel id="c" label="Posts" loop>
        <:slide>One</:slide>
        <:slide label="Second">Two</:slide>
      </.carousel>
      """)

    assert html =~ ~s(aria-roledescription="carousel")
    assert html =~ ~s(aria-label="Posts")
    assert html =~ ~s(data-loop)
    assert html =~ ~s(phx-hook="SlCarousel")
    assert html =~ ~s(aria-roledescription="slide")
    assert html =~ ~s(aria-label="1 of 2")
    assert html =~ ~s(aria-label="Second")
    assert html =~ ~s(role="tablist")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(aria-label="Previous slide")
    assert html =~ ~s(aria-label="Next slide")
    assert html =~ ~s(aria-live="polite")
    refute html =~ "data-sl-pause"
  end

  test "autoplay adds a pause control and per_view a custom property" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.carousel id="c" label="Logos" per_view={3} autoplay={2000} dots={false} controls={false}>
        <:slide>One</:slide>
      </.carousel>
      """)

    assert html =~ ~s(data-autoplay="2000")
    assert html =~ ~s(--sl-carousel-per-view: 3)
    assert html =~ ~s(data-sl-pause)
    assert html =~ ~s(aria-pressed="false")
    refute html =~ ~s(role="tablist")
    refute html =~ "data-sl-prev"
  end
end
