defmodule SlopUI.TimePickerTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SlopUI.Components.DatePicker

  test "time picker renders a native time input with step and a listbox popover" do
    html =
      render_component(&time_picker/1,
        name: "at",
        value: ~T[09:30:00],
        label: "At",
        step: 15,
        min: "09:00",
        max: "17:30",
        hour_cycle: "h23"
      )

    assert html =~ ~s(phx-hook="SlTimePicker")
    assert html =~ ~s(type="time")
    assert html =~ ~s(value="09:30")
    assert html =~ ~s(step="900")
    assert html =~ ~s(min="09:00")
    assert html =~ ~s(max="17:30")
    assert html =~ ~s(data-step="15")
    assert html =~ ~s(data-hour-cycle="h23")
    assert html =~ ~s(aria-haspopup="listbox")
    assert html =~ ~s(popovertarget="at-slots")
    assert html =~ ~s(role="listbox")
    assert html =~ ~s(aria-label="Choose a time")
  end

  test "time picker takes a form field and shows errors" do
    form =
      Phoenix.Component.to_form(%{"starts_at" => "10:00"},
        as: :event,
        errors: [starts_at: {"is too early", []}]
      )

    html = render_component(&time_picker/1, field: form[:starts_at], label: "Starts")
    assert html =~ ~s(name="event[starts_at]")
    assert html =~ ~s(id="event_starts_at")
    assert html =~ ~s(value="10:00")
    assert html =~ "is too early"
    assert html =~ ~s(aria-invalid="true")
  end
end
