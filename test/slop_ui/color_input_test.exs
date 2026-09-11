defmodule SlopUI.ColorInputTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.Inputs

  test "renders the native input, readout and preset radio group" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.color_input name="c" value="#ABC" label="Color" presets={[{"Violet", "#7c3aed"}, "#abc"]} />|
      )

    assert html =~ ~s(type="color")
    assert html =~ ~s(value="#aabbcc")
    assert html =~ ~s(phx-hook="SlColor")
    assert html =~ ~s(<output for="c" class="sl-color-value" aria-hidden="true">#aabbcc</output>)
    assert html =~ ~s(role="radiogroup")
    assert html =~ ~s(aria-label="Preset colors")
    assert html =~ ~s(aria-label="Violet")
    assert html =~ ~s(data-value="#7c3aed")
    assert html =~ ~s(aria-checked="false")
    assert html =~ ~s(data-value="#aabbcc" aria-checked="true" aria-label="#aabbcc" tabindex="0")
  end

  test "works with a form field and defaults to black" do
    assigns = %{form: Phoenix.Component.to_form(%{}, as: :p)}
    html = rendered_to_string(~H|<.color_input field={@form[:brand]} label="Brand" />|)
    assert html =~ ~s(id="p_brand")
    assert html =~ ~s(name="p[brand]")
    assert html =~ ~s(value="#000000")
    refute html =~ "radiogroup"
  end
end
