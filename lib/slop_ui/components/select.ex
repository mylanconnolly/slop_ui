defmodule SlopUI.Components.Select do
  @moduledoc """
  Custom select (select-only combobox) and editable combobox with autocomplete.
  """
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  import SlopUI.Components.Form, only: [label: 1, description: 1, errors: 1]

  @doc """
  Renders a custom select. The selection lives in a hidden native `<select>`,
  so it submits with the form and triggers `phx-change` like any input.

      <.select field={@form[:role]} label="Role" placeholder="Pick a role"
        options={[{"Admin", "admin"}, {"Editor", "editor"}]} />

      <.select name="tags[]" value={["a", "b"]} label="Tags" multiple options={~w(a b c)} />

  Options are `{label, value}` tuples or plain strings. Keyboard follows the
  WAI-ARIA select-only combobox pattern: arrows, Home/End, type-ahead,
  Enter/Space select, Escape closes.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :placeholder, :string, default: nil, doc: ~s|defaults to "Select…"|
  attr :options, :list, required: true
  attr :multiple, :boolean, default: false
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global

  def select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> select()
  end

  def select(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(:id, assigns[:id] || id_from_name(assigns[:name]))

    assigns =
      assigns
      |> assign(:options, normalize_options(assigns.options))
      |> assign(:anchor, SlopUI.anchor_name(assigns.id))
      |> assign(:placeholder, assigns.placeholder || t("Select…"))
      |> assign_describedby()

    selected = selected_values(assigns.value)
    assigns = assign(assigns, :selected, selected)

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} id={"#{@id}-label"} for={"#{@id}-trigger"} required={@required}>
        {@label}
      </.label>
      <div
        id={@id}
        class="sl-select"
        phx-hook="SlSelect"
        data-multiple={@multiple}
        data-placeholder={@placeholder}
        data-label-remove={t("Remove %{label}", label: "__LABEL__")}
        {@rest}
      >
        <select
          id={"#{@id}-native"}
          name={@name}
          multiple={@multiple}
          disabled={@disabled}
          required={@required}
          hidden
          tabindex="-1"
          aria-hidden="true"
        >
          <option :if={!@multiple} value=""></option>
          <option :for={{label, value} <- @options} value={value} selected={value in @selected}>
            {label}
          </option>
        </select>
        <div
          id={"#{@id}-trigger"}
          class="sl-select-trigger"
          role="combobox"
          tabindex={if @disabled, do: "-1", else: "0"}
          aria-haspopup="listbox"
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
          aria-labelledby={@label && "#{@id}-label"}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
          aria-required={@required && "true"}
          aria-disabled={@disabled && "true"}
          data-size={@size}
          style={"anchor-name: #{@anchor}"}
        >
          <span class="sl-select-value" data-placeholder={@selected == []}>
            <%= cond do %>
              <% @selected == [] -> %>
                {@placeholder}
              <% @multiple -> %>
                <span
                  :for={{label, value} <- @options}
                  :if={value in @selected}
                  class="sl-chip"
                  data-value={value}
                >
                  {label}<button
                    type="button"
                    tabindex="-1"
                    aria-label={t("Remove %{label}", label: label)}
                    disabled={@disabled}
                    data-sl-remove={value}
                  ><.icon name="x-mark" /></button>
                </span>
              <% true -> %>
                {label_for(@options, hd(@selected))}
            <% end %>
          </span>
          <.icon name="chevron-down" />
        </div>
        <div
          id={"#{@id}-listbox"}
          popover
          role="listbox"
          tabindex="-1"
          class="sl-listbox"
          aria-labelledby={@label && "#{@id}-label"}
          aria-multiselectable={@multiple && "true"}
          style={"--sl-anchor: #{@anchor}"}
        >
          <div
            :for={{{label, value}, i} <- Enum.with_index(@options)}
            id={"#{@id}-opt-#{i}"}
            role="option"
            class="sl-option"
            data-value={value}
            aria-selected={to_string(value in @selected)}
          >
            <span class="sl-option-label">{label}</span>
          </div>
        </div>
      </div>
      <p id={"#{@id}-validation"} class="sl-error" data-sl-validation hidden></p>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders an editable combobox with autocomplete.

  Client-filtered (static options):

      <.combobox field={@form[:country]} label="Country" options={@countries} />

  Server-filtered: pass `on_search` (an event name) and update `options` in
  your `handle_event/3`. The hook pushes `%{"query" => text}` as the user types.

      <.combobox field={@form[:city]} label="City" options={@cities} on_search="search-city" loading={@searching} />

  The committed value lives in a hidden input named `name`; the visible text
  input is named `"\#{name}_query"` when `on_search` is set so it never
  collides with your schema field. Set `allow_custom` to accept free text as
  the value.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :options, :list, required: true
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []

  attr(:on_search, :string,
    default: nil,
    doc: "event pushed with %{query: text}; enables server filtering"
  )

  attr :loading, :boolean, default: false
  attr :allow_custom, :boolean, default: false
  attr :multiple, :boolean, default: false, doc: "select several values; each submits as name[]"
  attr :empty, :string, default: nil, doc: ~s|defaults to "No matches"|
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(phx-target autocomplete)

  def combobox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> combobox()
  end

  def combobox(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(:id, assigns[:id] || id_from_name(assigns[:name]))

    assigns =
      assigns
      |> assign(:options, normalize_options(assigns.options))
      |> assign(:anchor, SlopUI.anchor_name(assigns.id))
      |> assign_describedby()

    assigns =
      if assigns.multiple do
        values =
          assigns.value |> List.wrap() |> Enum.map(&to_string/1) |> Enum.reject(&(&1 == ""))

        chips = Enum.map(values, &{label_for(assigns.options, &1) || &1, &1})
        assign(assigns, value: nil, values: values, chips: chips, text: "")
      else
        value = assigns.value && to_string(assigns.value)

        assign(assigns,
          value: value,
          values: [],
          chips: [],
          text: label_for(assigns.options, value) || value || ""
        )
      end

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={"#{@id}-input"} required={@required}>{@label}</.label>
      <div
        id={@id}
        class="sl-combobox"
        phx-hook="SlCombobox"
        data-on-search={@on_search}
        data-allow-custom={@allow_custom}
        data-multiple={@multiple}
        data-name={@name}
        data-required={@required}
        data-label-required={t("Please select an option.")}
        data-label-remove={t("Remove %{label}", label: "__LABEL__")}
        {@rest}
      >
        <input
          :if={!@multiple}
          type="hidden"
          disabled={@disabled}
          id={"#{@id}-value"}
          name={@name}
          value={@value}
        />
        <input :if={@multiple} type="hidden" disabled={@disabled} name={@name} value="" />
        <div
          class={[@multiple && "sl-combobox-multi", "sl-combobox-input-wrap"]}
          style={@multiple && "anchor-name: #{@anchor}"}
        >
          <span :for={{label, value} <- @chips} class="sl-chip" data-value={value}>
            {label}<input type="hidden" disabled={@disabled} name={@name} value={value} /><button
              type="button"
              tabindex="-1"
              aria-label={t("Remove %{label}", label: label)}
              data-sl-remove={value}
              disabled={@disabled}
            ><.icon name="x-mark" /></button>
          </span>
          <input
            type="text"
            id={"#{@id}-input"}
            class="sl-input"
            role="combobox"
            aria-autocomplete="list"
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@describedby}
            aria-required={@required && "true"}
            autocomplete="off"
            spellcheck="false"
            name={@on_search && "#{@name}_query"}
            value={@text}
            placeholder={@placeholder}
            disabled={@disabled}
            data-size={@size}
            style={!@multiple && "anchor-name: #{@anchor}"}
          />
          <span class="sl-combobox-adornments">
            <span :if={@loading} class="sl-spinner" role="status" aria-label={t("Loading")}></span>
            <button
              type="button"
              class="sl-combobox-clear"
              aria-label={t("Clear")}
              tabindex="-1"
              disabled={@disabled}
              data-sl-clear
              hidden={@text == ""}
            ><.icon name="x-mark" /></button>
            <button
              type="button"
              class="sl-combobox-toggle"
              aria-label={t("Show options")}
              tabindex="-1"
              disabled={@disabled}
              data-sl-toggle
            ><.icon name="chevron-down" /></button>
          </span>
        </div>
        <div
          id={"#{@id}-listbox"}
          popover="manual"
          role="listbox"
          tabindex="-1"
          class="sl-listbox"
          aria-multiselectable={@multiple && "true"}
          style={"--sl-anchor: #{@anchor}"}
        >
          <div
            :for={{{label, value}, i} <- Enum.with_index(@options)}
            id={"#{@id}-opt-#{i}"}
            role="option"
            class="sl-option"
            data-value={value}
            data-label={label}
            aria-selected={to_string(if @multiple, do: value in @values, else: value == @value)}
          >
            <span class="sl-option-label">{label}</span>
          </div>
          <div class="sl-listbox-empty" hidden>{@empty || t("No matches")}</div>
        </div>
      </div>
      <p id={"#{@id}-validation"} class="sl-error" data-sl-validation hidden></p>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  defp id_from_name(name), do: String.replace(to_string(name), ~r/[^a-zA-Z0-9_-]+/, "_")

  defp normalize_options(options) do
    Enum.map(options, fn
      {label, value} -> {to_string(label), to_string(value)}
      value -> {to_string(value), to_string(value)}
    end)
  end

  defp selected_values(nil), do: []
  defp selected_values(""), do: []
  defp selected_values(list) when is_list(list), do: Enum.map(list, &to_string/1)
  defp selected_values(value), do: [to_string(value)]

  defp label_for(_options, nil), do: nil

  defp label_for(options, value) do
    case List.keyfind(options, value, 1) do
      {label, _} -> label
      nil -> nil
    end
  end

  defp assign_describedby(assigns) do
    ids =
      [
        "#{assigns.id}-validation",
        assigns[:description] && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-error"
      ]
      |> Enum.filter(& &1)

    assign(assigns, :describedby, if(ids == [], do: nil, else: Enum.join(ids, " ")))
  end
end
