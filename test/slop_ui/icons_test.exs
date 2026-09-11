defmodule SlopUI.IconsTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]

  test "built-in icons are Phosphor fill glyphs" do
    assigns = %{}
    html = rendered_to_string(~H|<SlopUI.Icons.icon name="check" class="extra" />|)
    assert html =~ ~s(viewBox="0 0 256 256")
    assert html =~ ~s(fill="currentColor")
    assert html =~ ~s(class="extra sl-icon")
    assert html =~ ~s(aria-hidden="true")
    refute html =~ "stroke"
  end

  test "sets embed files from a folder with prefixes" do
    assert "app-logo" in SlopUI.Test.Icons.icon_names()
    assert "app-spark" in SlopUI.Test.Icons.icon_names()
    assert "spark" in SlopUI.Test.Icons.icon_names()
    assigns = %{}
    html = rendered_to_string(~H|<SlopUI.Test.Icons.icon name="app-logo" />|)
    assert html =~ ~s(viewBox="0 0 32 32")
    assert html =~ ~s(fill="currentColor")
    assert html =~ ~s(stroke="currentColor")
    refute html =~ "#000"
    refute html =~ ~s(width="32")
    refute html =~ ~s(id="logo")
  end

  test "phosphor weights map file names back to bare names" do
    names = SlopUI.Test.Icons.icon_names()
    assert "phosphor-house" in names
    assert "bold-house" in names
    assert "duo-house" in names
    assigns = %{}
    html = rendered_to_string(~H|<SlopUI.Test.Icons.icon name="duo-house" />|)
    assert html =~ ~s(opacity="0.2")
  end

  test "heroicons keep their stroke attributes without duplicate aria-hidden" do
    assigns = %{}
    html = rendered_to_string(~H|<SlopUI.Test.Icons.icon name="hero-arrow-path" />|)
    assert html =~ ~s(stroke-width="1.5")
    assert length(String.split(html, "aria-hidden")) == 2
  end

  test "a label makes the icon an image instead of hidden" do
    assigns = %{}
    html = rendered_to_string(~H|<SlopUI.Test.Icons.icon name="app-logo" aria-label="Acme" />|)
    assert html =~ ~s(role="img")
    assert html =~ ~s(aria-label="Acme")
    refute html =~ "aria-hidden"
  end

  test "unknown names fail at compile time with suggestions" do
    assert_raise ArgumentError, ~r/no icon named "hous".*Did you mean: house/, fn ->
      SlopUI.Icons.Set.load_sets(
        [phosphor: [dir: "test/fixtures/phosphor", icons: ~w(hous)]],
        %{module: X}
      )
    end
  end

  test "missing presets explain how to add the dep" do
    assert_raise ArgumentError, ~r/heroicons files not found.*deps.get/, fn ->
      SlopUI.Icons.Set.load_sets([hero: [dep: :nope, icons: ~w(x)]], %{module: X})
    end
  end

  test "colliding names across sets are rejected" do
    assert_raise ArgumentError, ~r/defined by more than one set/, fn ->
      SlopUI.Icons.Set.load_sets(
        [
          a: [dir: "test/fixtures/icons", icons: ~w(spark), prefix: false],
          b: [dir: "test/fixtures/icons", icons: ~w(spark), prefix: false]
        ],
        %{module: X}
      )
    end
  end
end
