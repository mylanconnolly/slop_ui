defmodule SlopUI.FormContractTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "loading overrides an explicit false disabled flag for buttons and links" do
    for attrs <- [[], [href: "/next"], [navigate: "/next"], [patch: "/next"]] do
      html =
        render_component(
          &button/1,
          attrs ++
            [
              loading: true,
              rest: %{disabled: false},
              inner_block: [%{inner_block: fn _, _ -> "Wait" end}]
            ]
        )

      assert html =~ "<button"
      assert html =~ ~s(disabled)
      assert html =~ ~s(data-loading)
      refute html =~ "<a "
    end
  end

  test "all field errors share a single description container" do
    for component <- [
          &input/1,
          &number_input/1,
          &password_input/1,
          &date_picker/1,
          &time_picker/1
        ] do
      html = render_component(component, id: "field", name: "field", errors: ["First", "Second"])
      assert length(Regex.scan(~r/id="field-error"/, html)) == 1
      assert html =~ ~r/<div id="field-error">.*First.*Second.*<\/div>/s
    end
  end

  test "required radios participate in native constraint validation" do
    html =
      render_component(&radio_group/1,
        id: "plan",
        name: "plan",
        label: "Plan",
        options: ~w(a b),
        required: true
      )

    assert length(Regex.scan(~r/<input[^>]+type="radio"[^>]+required/, html)) == 2
  end

  test "readonly native date and time inputs disable popup buttons" do
    for component <- [&date_picker/1, &time_picker/1] do
      html = render_component(component, id: "when", name: "when", rest: %{readonly: true})
      assert html =~ ~r/<button[^>]+disabled/s
    end
  end

  test "disabled combobox disables hidden values and every auxiliary button" do
    html =
      render_component(&combobox/1,
        id: "tags",
        name: "tags[]",
        options: ~w(a b),
        value: ["a"],
        multiple: true,
        disabled: true
      )

    controls = Regex.scan(~r/<(?:input|button)\b[^>]*>/s, html)
    assert length(controls) == 6
    assert Enum.all?(controls, fn [control] -> control =~ "disabled" end)
  end

  test "Hex includes its asset manifest and all explicitly listed files exist" do
    files = Mix.Project.config()[:package][:files]
    assert "package.json" in files
    assert Enum.all?(files, &File.exists?/1)
  end
end
