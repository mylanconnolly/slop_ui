defmodule SlopUI.CalendarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SlopUI.Components.DatePicker
  alias Phoenix.LiveView.JS

  test "inline calendar renders a hook container with hidden value input and labels" do
    html =
      render_component(&calendar/1,
        id: "cal",
        name: "when",
        value: ~D[2026-09-11],
        on_change: JS.push("pick")
      )

    assert html =~ ~s(phx-hook="SlCalendar")
    assert html =~ ~s(role="group")
    assert html =~ ~s(aria-label="Calendar")
    assert html =~ ~s(<input type="hidden" id="cal-value" name="when" value="2026-09-11">)
    assert html =~ ~s(data-on-change=)
    assert html =~ ~s(data-label-prev="Previous month")
    assert html =~ ~s(phx-update="ignore")
    refute html =~ "cal-end"
  end

  test "range calendar renders both hidden inputs and bounds" do
    html =
      render_component(&calendar/1,
        id: "stay",
        range: true,
        from_name: "from",
        to_name: "to",
        from_value: "2026-10-01",
        to_value: ~D[2026-10-07],
        min: ~D[2026-09-01],
        footer: false,
        label: "Stay"
      )

    assert html =~ ~s(data-range)
    assert html =~ ~s(name="from" value="2026-10-01")
    assert html =~ ~s(name="to" value="2026-10-07")
    assert html =~ ~s(data-min="2026-09-01")
    assert html =~ ~s(data-footer="false")
    assert html =~ ~s(aria-label="Stay")
  end

  test "date picker still renders the popover calendar and native input" do
    html = render_component(&date_picker/1, name: "d", value: ~D[2026-01-02], label: "Date")
    assert html =~ ~s(phx-hook="SlDatePicker")
    assert html =~ ~s(type="date")
    assert html =~ ~s(popovertarget="d-calendar")
    assert html =~ ~s(role="dialog")
  end
end
