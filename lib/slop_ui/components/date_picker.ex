defmodule SlopUI.Components.DatePicker do
  @moduledoc "Date, date-range and time pickers, plus an inline calendar."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  import SlopUI.Components.Form, only: [label: 1, description: 1, errors: 1]

  @doc """
  Renders a date field: a native `<input type="date">` (typed entry, mobile
  pickers, min/max validation, `phx-change`) plus a calendar popover for
  pointer and keyboard selection.

      <.date_picker field={@form[:due_on]} label="Due on" min={Date.utc_today()} />
      <.date_picker name="from" value={~D[2026-09-11]} label="From" locale="de-DE" />

  Values are ISO 8601 dates (`Date` structs or `"YYYY-MM-DD"` strings). The
  calendar is rendered by the hook in the browser's (or `locale`'s) language,
  with the locale's first day of the week. Keyboard in the calendar: arrows
  move by day and week, PageUp/PageDown by month, Home/End to week bounds,
  Enter selects, Escape closes.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :locale, :string, default: nil, doc: "BCP 47 tag; defaults to the browser's"
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autocomplete form readonly)

  def date_picker(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> date_picker()
  end

  def date_picker(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    assigns =
      assigns
      |> assign(:anchor, SlopUI.anchor_name(assigns.id))
      |> assign(:describedby, describedby(assigns.id, assigns.description, assigns.errors))

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div
        id={"#{@id}-picker"}
        class="sl-input-group sl-date-picker"
        data-size={@size}
        data-locale={@locale}
        phx-hook="SlDatePicker"
        style={"anchor-name: #{@anchor}"}
        data-label-prev={t("Previous month")}
        data-label-next={t("Next month")}
        data-label-clear={t("Clear")}
        data-label-today={t("Today")}
      >
        <input
          type="date"
          id={@id}
          name={@name}
          value={iso(@value)}
          min={iso(@min)}
          max={iso(@max)}
          class="sl-input"
          data-size={@size}
          disabled={@disabled}
          required={@required}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
          {@rest}
        />
        <span class="sl-input-adornment" data-interactive>
          <button
            type="button"
            class="sl-button"
            data-variant="ghost"
            data-size={@size}
            data-icon
            aria-label={t("Open calendar")}
            aria-haspopup="dialog"
            aria-expanded="false"
            popovertarget={"#{@id}-calendar"}
            disabled={@disabled || @rest[:readonly]}
          >
            <.icon name="calendar" />
          </button>
        </span>
      </div>
      <div
        id={"#{@id}-calendar"}
        popover
        role="dialog"
        aria-label={t("Choose a date")}
        tabindex="-1"
        class="sl-calendar"
        style={"--sl-anchor: #{@anchor}"}
      >
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders a date range: two native date inputs sharing one calendar, where
  the first click picks the start and the second the end.

      <.date_range_picker from={@form[:starts_on]} to={@form[:ends_on]} label="Dates" />
      <.date_range_picker id="trip" from_name="from" to_name="to" from_value={~D[2026-10-01]} to_value={~D[2026-10-07]} label="Trip" />
  """
  attr :id, :any, default: nil
  attr :from, Phoenix.HTML.FormField
  attr :to, Phoenix.HTML.FormField
  attr :from_name, :any
  attr :to_name, :any
  attr :from_value, :any
  attr :to_value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :locale, :string, default: nil
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global

  def date_range_picker(assigns) do
    from = assigns[:from]
    to = assigns[:to]

    errors =
      assigns.errors ++
        for f <- [from, to],
            f,
            Phoenix.Component.used_input?(f),
            e <- f.errors,
            do: SlopUI.translate_error(e)

    assigns =
      assigns
      |> assign(
        from_name: assigns[:from_name] || (from && from.name),
        to_name: assigns[:to_name] || (to && to.name),
        from_value: assigns[:from_value] || (from && from.value),
        to_value: assigns[:to_value] || (to && to.value),
        errors: errors
      )
      |> then(fn a ->
        assign(
          a,
          :id,
          a[:id] || (from && from.id) ||
            String.replace(to_string(a.from_name), ~r/[^a-zA-Z0-9_-]+/, "_")
        )
      end)

    assigns =
      assigns
      |> assign(:anchor, SlopUI.anchor_name(assigns.id))
      |> assign(:describedby, describedby(assigns.id, assigns.description, assigns.errors))

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div
        id={"#{@id}-picker"}
        class="sl-input-group sl-date-picker"
        data-size={@size}
        data-locale={@locale}
        data-range
        phx-hook="SlDatePicker"
        style={"anchor-name: #{@anchor}"}
        data-label-prev={t("Previous month")}
        data-label-next={t("Next month")}
        data-label-clear={t("Clear")}
        data-label-today={t("Today")}
        {@rest}
      >
        <input
          type="date"
          id={@id}
          name={@from_name}
          value={iso(@from_value)}
          min={iso(@min)}
          max={iso(@to_value) || iso(@max)}
          class="sl-input"
          data-size={@size}
          disabled={@disabled}
          required={@required}
          aria-label={t("Start date")}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
        />
        <span class="sl-input-adornment" data-range-sep aria-hidden="true">→</span>
        <input
          type="date"
          id={"#{@id}-end"}
          name={@to_name}
          value={iso(@to_value)}
          min={iso(@from_value) || iso(@min)}
          max={iso(@max)}
          class="sl-input"
          data-size={@size}
          disabled={@disabled}
          required={@required}
          aria-label={t("End date")}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
        />
        <span class="sl-input-adornment" data-interactive>
          <button
            type="button"
            class="sl-button"
            data-variant="ghost"
            data-size={@size}
            data-icon
            aria-label={t("Open calendar")}
            aria-haspopup="dialog"
            aria-expanded="false"
            popovertarget={"#{@id}-calendar"}
            disabled={@disabled || @rest[:readonly]}
          >
            <.icon name="calendar" />
          </button>
        </span>
      </div>
      <div
        id={"#{@id}-calendar"}
        popover
        role="dialog"
        aria-label={t("Choose dates")}
        tabindex="-1"
        class="sl-calendar"
        style={"--sl-anchor: #{@anchor}"}
      >
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders an inline calendar: a month grid that is always visible, for
  scheduling views, sidebars and availability pickers.

      <.calendar id="when" name="when" value={@date} on_change={JS.push("pick-day")} />
      <.calendar id="stay" range from_name="from" to_name="to" from_value={@from} to_value={@to} min={Date.utc_today()} />

  Hidden inputs carry the value(s) so the calendar works inside a form
  (`phx-change` fires on every pick). `on_change` runs with `phx-value-date`
  (and `phx-value-end` for ranges) once a selection is complete. Re-render
  with a new `value` to control the selection from the server.

  Keyboard: arrows move by day and week, PageUp/PageDown by month,
  Shift+PageUp/PageDown by year, Home/End to the week bounds, Enter or Space
  selects. The grid follows the WAI-ARIA grid pattern with a roving tab stop.
  """
  attr :id, :string, required: true
  attr :name, :any, default: nil, doc: "hidden input name for the (start) value"
  attr :value, :any, default: nil
  attr :range, :boolean, default: false
  attr :from_name, :any, default: nil, doc: "range: name for the start; defaults to `name`"
  attr :to_name, :any, default: nil, doc: "range: name for the end"
  attr :from_value, :any, default: nil, doc: "range: start; defaults to `value`"
  attr :to_value, :any, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :locale, :string, default: nil, doc: "BCP 47 tag; defaults to the browser's"
  attr :footer, :boolean, default: true, doc: "show the Clear / Today buttons"
  attr :label, :string, default: nil, doc: ~s|accessible name; defaults to "Calendar"|
  attr :on_change, Phoenix.LiveView.JS, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def calendar(assigns) do
    assigns =
      assign(assigns,
        from_name: assigns.from_name || assigns.name,
        from_value: assigns.from_value || assigns.value,
        label: assigns.label || t("Calendar")
      )

    ~H"""
    <div
      id={@id}
      class={[@class, "sl-calendar sl-calendar-inline"]}
      role="group"
      aria-label={@label}
      phx-hook="SlCalendar"
      data-locale={@locale}
      data-range={@range}
      data-min={iso(@min)}
      data-max={iso(@max)}
      data-footer={to_string(@footer)}
      data-on-change={@on_change}
      data-label-prev={t("Previous month")}
      data-label-next={t("Next month")}
      data-label-clear={t("Clear")}
      data-label-today={t("Today")}
      {@rest}
    >
      <input type="hidden" id={"#{@id}-value"} name={@from_name} value={iso(@from_value)} />
      <input :if={@range} type="hidden" id={"#{@id}-end"} name={@to_name} value={iso(@to_value)} />
      <div class="sl-calendar-body" phx-update="ignore" id={"#{@id}-body"}></div>
    </div>
    """
  end

  @doc """
  Renders a time field: a native `<input type="time">` (typed entry, mobile
  pickers, min/max, `phx-change`) plus a popover list of time slots.

      <.time_picker field={@form[:starts_at]} label="Starts at" step={15} min="09:00" max="17:30" />
      <.time_picker name="at" value="09:30" label="At" hour_cycle="h23" />

  Values are `"HH:MM"` strings or `Time` structs. `step` is in minutes and
  drives both the native input's granularity and the slot list. Slots are
  formatted in the browser's (or `locale`'s) convention; set `hour_cycle` to
  `"h12"` or `"h23"` to force one.

  Keyboard: the clock button (or Alt+ArrowDown in the input) opens the list;
  arrows move, PageUp/PageDown jump an hour, Home/End to the bounds, typing
  jumps to a matching slot (`9:3` or `14`), Enter selects, Escape closes.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :step, :integer, default: 30, doc: "minutes between slots"
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :locale, :string, default: nil
  attr :hour_cycle, :string, default: nil, values: [nil, "h12", "h23"]
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autocomplete form readonly)

  def time_picker(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> time_picker()
  end

  def time_picker(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    assigns =
      assigns
      |> assign(:anchor, SlopUI.anchor_name(assigns.id))
      |> assign(:describedby, describedby(assigns.id, assigns.description, assigns.errors))

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div
        id={"#{@id}-picker"}
        class="sl-input-group sl-time-picker"
        data-size={@size}
        data-locale={@locale}
        data-hour-cycle={@hour_cycle}
        data-step={@step}
        phx-hook="SlTimePicker"
        style={"anchor-name: #{@anchor}"}
      >
        <input
          type="time"
          id={@id}
          name={@name}
          value={hm(@value)}
          min={hm(@min)}
          max={hm(@max)}
          step={@step * 60}
          class="sl-input"
          data-size={@size}
          disabled={@disabled}
          required={@required}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
          {@rest}
        />
        <span class="sl-input-adornment" data-interactive>
          <button
            type="button"
            class="sl-button"
            data-variant="ghost"
            data-size={@size}
            data-icon
            aria-label={t("Choose a time")}
            aria-haspopup="listbox"
            aria-expanded="false"
            aria-controls={"#{@id}-slots"}
            popovertarget={"#{@id}-slots"}
            disabled={@disabled || @rest[:readonly]}
          >
            <.icon name="clock" />
          </button>
        </span>
      </div>
      <div
        id={"#{@id}-slots"}
        popover
        role="listbox"
        aria-label={t("Time slots")}
        tabindex="-1"
        class="sl-time-list"
        style={"--sl-anchor: #{@anchor}"}
      >
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  defp hm(nil), do: nil
  defp hm(""), do: nil
  defp hm(%Time{} = t), do: t |> Time.truncate(:second) |> Time.to_iso8601() |> String.slice(0, 5)
  defp hm(s) when is_binary(s), do: s

  defp iso(nil), do: nil
  defp iso(""), do: nil
  defp iso(%Date{} = d), do: Date.to_iso8601(d)
  defp iso(%DateTime{} = d), do: d |> DateTime.to_date() |> Date.to_iso8601()
  defp iso(%NaiveDateTime{} = d), do: d |> NaiveDateTime.to_date() |> Date.to_iso8601()
  defp iso(s) when is_binary(s), do: s

  defp describedby(id, description, errors) do
    [description && "#{id}-description", errors != [] && "#{id}-error"]
    |> Enum.filter(& &1)
    |> case do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end
end
