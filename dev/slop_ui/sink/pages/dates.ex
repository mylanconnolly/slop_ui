defmodule SlopUI.Sink.Pages.Dates do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  alias Phoenix.LiveView.JS

  def components,
    do: [
      {SlopUI.Components.DatePicker, :date_picker},
      {SlopUI.Components.DatePicker, :date_range_picker},
      {SlopUI.Components.DatePicker, :calendar},
      {SlopUI.Components.DatePicker, :time_picker}
    ]

  def render(assigns) do
    ~H"""
    <.form for={@date_form} phx-change="dates">
      <.stack gap="xl">
        <.example
          title="Date picker"
          description="Native date input for typing and mobile, plus a calendar popover. Arrows move by day/week, PageUp/Down by month, Enter selects."
          code={~S|<.date_picker field={@form[:due_on]} label="Due on" min={Date.utc_today()} />|}
        >
          <.grid min="16rem">
            <.date_picker
              field={@date_form[:due_on]}
              label="Due on"
              min={Date.utc_today()}
              description="Past dates are disabled."
            />
            <.date_picker
              name="birthday"
              value={~D[1815-12-10]}
              label="Birthday"
              max={Date.utc_today()}
            />
            <.date_picker name="de" value="" label="German locale" locale="de-DE" />
            <.date_picker name="off" value={Date.utc_today()} label="Disabled" disabled />
          </.grid>
          <.badge style="margin-block-start: var(--sl-space-4)">
            due_on: {@date_form[:due_on].value}
          </.badge>
        </.example>

        <.example
          title="Date range"
          description="Two inputs, one calendar: first click sets the start, second the end."
          code={
            ~S|<.date_range_picker from={@form[:starts_on]} to={@form[:ends_on]} label="Dates" />|
          }
        >
          <.stack gap="md" style="max-inline-size: 28rem">
            <.date_range_picker
              from={@date_form[:starts_on]}
              to={@date_form[:ends_on]}
              label="Trip"
              min={Date.utc_today()}
            />
            <.badge>range: {@date_form[:starts_on].value} → {@date_form[:ends_on].value}</.badge>
          </.stack>
        </.example>

        <.example
          title="Time picker"
          description="Native time input plus a popover of slots every `step` minutes within min/max. Alt+ArrowDown opens the list; arrows move, PageUp/Down jump an hour, typing jumps to a slot, Enter selects."
          code={
            ~S|<.time_picker field={@form[:starts_at]} label="Starts at" step={15} min="09:00" max="17:30" />|
          }
        >
          <.grid min="14rem">
            <.time_picker
              field={@date_form[:at]}
              label="Starts at"
              step={15}
              min="09:00"
              max="17:30"
              description="Office hours, quarter-hour slots."
            />
            <.time_picker field={@date_form[:slot]} label="Any time (24h)" hour_cycle="h23" />
            <.time_picker name="off" value="12:00" label="Disabled" disabled />
          </.grid>
          <.badge style="margin-block-start: var(--sl-space-4)">
            at: {@date_form[:at].value} · slot: {@date_form[:slot].value}
          </.badge>
        </.example>

        <.example
          title="Native time and datetime"
          description="Datetime and month are native inputs styled through input/1."
          code={~S|<.input type="datetime-local" field={@form[:when]} label="When" />|}
        >
          <.grid min="14rem">
            <.input type="datetime-local" name="when" value="" label="When" />
            <.input type="month" name="month" value="" label="Month" />
          </.grid>
        </.example>
      </.stack>
    </.form>

    <.example
      title="Inline calendar"
      description="An always-visible month grid. Arrows move by day and week, PageUp/Down by month, Shift+PageUp/Down by year, Home/End to week bounds, Enter selects. on_change pushes phx-value-date; the range version also pushes phx-value-end."
      code={~S|<.calendar id="when" name="when" value={@date} on_change={JS.push("pick-day")} />|}
    >
      <.cluster gap="xl" align="start">
        <.stack gap="sm">
          <.calendar id="cal-single" name="when" value={@cal_date} on_change={JS.push("pick-day")} />
          <.badge>picked: {@cal_date || "—"}</.badge>
        </.stack>
        <.stack gap="sm">
          <.calendar
            id="cal-range"
            range
            from_name="from"
            to_name="to"
            from_value={elem(@cal_range, 0)}
            to_value={elem(@cal_range, 1)}
            min={Date.utc_today()}
            footer={false}
            label="Stay"
            on_change={JS.push("pick-range")}
          />
          <.badge>range: {elem(@cal_range, 0) || "—"} → {elem(@cal_range, 1) || "—"}</.badge>
        </.stack>
      </.cluster>
    </.example>
    """
  end
end
