defmodule SlopUI.CounterTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]
  import SlopUI.Components.Form

  test "counter renders the count, the limit and wires aria-describedby" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.input name="bio" value="héllo" type="textarea" label="Bio" maxlength={10} counter />|
      )

    assert html =~ ~s(id="bio-counter")
    assert html =~ ~s(phx-hook="SlCounter")
    assert html =~ ~s(data-for="bio")
    assert html =~ ~s(data-max="10")
    assert html =~ ~s(<span data-count>5</span>)
    assert html =~ ~s(aria-describedby="bio-counter")
    assert html =~ ~s(maxlength="10")
    assert html =~ ~s(aria-live="polite")
  end

  test "enforce false drops maxlength from the control but keeps the limit" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.input name="t" value="" label="T" maxlength={20} counter enforce={false} />|
      )

    refute html =~ ~s(maxlength="20")
    assert html =~ ~s(data-max="20")
  end

  test "counter without maxlength shows only the count" do
    assigns = %{}
    html = rendered_to_string(~H|<.input name="t" value="abc" label="T" counter />|)
    assert html =~ ~s(<span data-count>3</span>)
    refute html =~ "data-max="
  end

  test "no counter by default" do
    assigns = %{}
    html = rendered_to_string(~H|<.input name="t" value="" label="T" maxlength={5} />|)
    refute html =~ "sl-counter"
  end
end
