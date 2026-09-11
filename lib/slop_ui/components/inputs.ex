defmodule SlopUI.Components.Inputs do
  @moduledoc "Specialised inputs: slider, number, pin, tag, rating, password and color."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  import SlopUI.Components.Form, only: [label: 1, description: 1, errors: 1]

  @doc """
  Renders a range slider with a live value readout.

      <.slider field={@form[:volume]} label="Volume" min={0} max={100} step={5} />
      <.slider name="temp" value={20} label="Temperature" min={-10} max={40} marks={["-10°", "40°"]} />

  Built on the native range input: it submits with the form, fires
  `phx-change`, and is keyboard accessible without JavaScript. The hook only
  updates the readout and the filled track.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :min, :any, default: 0
  attr :max, :any, default: 100
  attr :step, :any, default: 1
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :show_value, :boolean, default: true
  attr :format, :string, default: "%v", doc: ~s|readout format, "%v" is the value, e.g. "%v%"|
  attr :marks, :list, default: [], doc: "labels spread under the track"
  attr :color, :string, default: "accent", values: ~w(accent success danger)
  attr :disabled, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(list)

  def slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> slider()
  end

  def slider(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(:id, assigns[:id] || to_string(assigns[:name]))

    value = to_number(assigns.value) || to_number(assigns.min)
    pct = percent(value, to_number(assigns.min), to_number(assigns.max))

    assigns =
      assign(assigns,
        value: value,
        pct: pct,
        readout: String.replace(assigns.format, "%v", to_string(value))
      )

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <div id={"#{@id}-slider"} class="sl-slider-row" phx-hook="SlSlider" data-format={@format}>
        <input
          type="range"
          id={@id}
          name={@name}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          class="sl-slider"
          data-color={@color}
          style={"--_pct: #{@pct}%"}
          disabled={@disabled}
          aria-describedby={describedby(@id, @description, @errors)}
          {@rest}
        />
        <output :if={@show_value} for={@id}>{@readout}</output>
      </div>
      <div :if={@marks != []} class="sl-slider-marks" aria-hidden="true">
        <span :for={m <- @marks}>{m}</span>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders a number input with decrement and increment buttons.

      <.number_input field={@form[:qty]} label="Quantity" min={1} max={10} />

  The buttons step the native input, so `min`, `max` and `step` are honoured
  and `phx-change` fires as if the user typed.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :step, :any, default: 1
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(placeholder autocomplete inputmode readonly)

  def number_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> number_input()
  end

  def number_input(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(:id, assigns[:id] || to_string(assigns[:name]))

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div id={"#{@id}-number"} class="sl-input-group sl-number" data-size={@size} phx-hook="SlNumber">
        <span class="sl-input-adornment" data-interactive>
          <button
            type="button"
            class="sl-button"
            data-variant="ghost"
            data-size={@size}
            data-icon
            aria-label={t("Decrease")}
            data-sl-step="down"
            tabindex="-1"
            disabled={@disabled}
          >
            <.icon name="minus" />
          </button>
        </span>
        <input
          type="number"
          id={@id}
          name={@name}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          class="sl-input"
          inputmode="decimal"
          disabled={@disabled}
          required={@required}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={describedby(@id, @description, @errors)}
          {@rest}
        />
        <span class="sl-input-adornment" data-interactive>
          <button
            type="button"
            class="sl-button"
            data-variant="ghost"
            data-size={@size}
            data-icon
            aria-label={t("Increase")}
            data-sl-step="up"
            tabindex="-1"
            disabled={@disabled}
          >
            <.icon name="plus" />
          </button>
        </span>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  defp describedby(id, description, errors) do
    [description && "#{id}-description", errors != [] && "#{id}-error"]
    |> Enum.filter(& &1)
    |> case do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end

  defp to_number(nil), do: nil
  defp to_number(""), do: nil
  defp to_number(n) when is_number(n), do: n

  defp to_number(s) when is_binary(s) do
    case Float.parse(s) do
      {f, _} -> if f == trunc(f), do: trunc(f), else: f
      :error -> nil
    end
  end

  defp percent(v, min, max)
       when is_number(v) and is_number(min) and is_number(max) and max > min do
    Float.round((v - min) / (max - min) * 100, 2)
  end

  defp percent(_, _, _), do: 0

  @doc """
  Renders a one-time-code input: one box per character, auto-advancing, with
  paste support. The combined value submits under `name` via a hidden input.

      <.pin_input field={@form[:code]} label="Verification code" length={6} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :length, :integer, default: 6
  attr :type, :string, default: "numeric", values: ~w(numeric alphanumeric)
  attr :mask, :boolean, default: false, doc: "hide characters like a password"
  attr :separator_after, :integer, default: nil, doc: "draw a separator after this many boxes"
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global

  def pin_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> pin_input()
  end

  def pin_input(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    chars = assigns.value |> to_string() |> String.graphemes()

    assigns =
      assign(assigns,
        chars: chars,
        describedby: describedby(assigns.id, assigns.description, assigns.errors)
      )

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} id={"#{@id}-label"} for={"#{@id}-0"}>{@label}</.label>
      <div
        id={@id}
        class="sl-pin"
        role="group"
        aria-labelledby={@label && "#{@id}-label"}
        aria-describedby={@describedby}
        phx-hook="SlPinInput"
        data-length={@length}
        data-type={@type}
        {@rest}
      >
        <input type="hidden" name={@name} value={@value} />
        <%= for i <- 0..(@length - 1) do %>
          <input
            type={if @mask, do: "password", else: "text"}
            id={"#{@id}-#{i}"}
            value={Enum.at(@chars, i)}
            inputmode={if @type == "numeric", do: "numeric", else: "text"}
            autocomplete={if i == 0, do: "one-time-code", else: "off"}
            pattern={if @type == "numeric", do: "[0-9]*"}
            maxlength="1"
            aria-label={t("Character %{n} of %{total}", n: i + 1, total: @length)}
            aria-invalid={@errors != [] && "true"}
            disabled={@disabled}
          />
          <span
            :if={@separator_after && i + 1 == @separator_after && i + 1 < @length}
            class="sl-pin-sep"
            aria-hidden="true"
          >–</span>
        <% end %>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders a free-form tag input. Each tag submits as `name[]`; Enter, comma
  or Tab adds the typed text, Backspace removes the last tag.

      <.tag_input field={@form[:tags]} label="Tags" placeholder="Add a tag…" />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any, doc: "list of tags"
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :placeholder, :string, default: nil, doc: ~s|defaults to "Add…"|
  attr :max, :integer, default: nil
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global

  def tag_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name <> "[]" end)
    |> assign_new(:value, fn -> field.value end)
    |> tag_input()
  end

  def tag_input(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> [] end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    tags = assigns.value |> List.wrap() |> Enum.map(&to_string/1) |> Enum.reject(&(&1 == ""))

    assigns =
      assign(assigns,
        tags: tags,
        describedby: describedby(assigns.id, assigns.description, assigns.errors)
      )

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={"#{@id}-input"}>{@label}</.label>
      <div
        id={@id}
        class="sl-tag-input"
        phx-hook="SlTagInput"
        data-name={@name}
        data-max={@max}
        data-label-remove={t("Remove %{label}", label: "__LABEL__")}
        aria-invalid={@errors != [] && "true"}
        {@rest}
      >
        <input type="hidden" name={@name} value="" />
        <span :for={tag <- @tags} class="sl-chip" data-value={tag}>
          {tag}<input type="hidden" name={@name} value={tag} /><button
            type="button"
            tabindex="-1"
            aria-label={t("Remove %{label}", label: tag)}
            data-sl-remove={tag}
            disabled={@disabled}
          ><.icon name="x-mark" /></button>
        </span>
        <input
          type="text"
          id={"#{@id}-input"}
          placeholder={@placeholder || t("Add…")}
          autocomplete="off"
          disabled={@disabled}
          aria-describedby={@describedby}
        />
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Renders a star rating. Interactive ratings are radio buttons (form-native,
  keyboard-native); `readonly` renders static stars.

      <.rating field={@form[:stars]} label="Your rating" />
      <.rating value={4} readonly label="Average rating" show_value />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, required: true, doc: "accessible name (visually hidden)"
  attr :max, :integer, default: 5
  attr :readonly, :boolean, default: false
  attr :show_value, :boolean, default: false
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :field, Phoenix.HTML.FormField
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  def rating(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> rating()
  end

  def rating(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] ||
          String.replace(to_string(assigns[:name] || "rating"), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    assigns = assign(assigns, :current, to_number(assigns.value) || 0)

    ~H"""
    <fieldset
      :if={!@readonly}
      id={@id}
      class={[@class, "sl-rating"]}
      data-size={@size}
      disabled={@disabled}
      {@rest}
    >
      <legend>{@label}</legend>
      <label :for={i <- 1..@max} title={t("%{n} of %{total}", n: i, total: @max)}>
        <input
          type="radio"
          name={@name}
          value={i}
          checked={@current == i}
          aria-label={t("%{n} of %{total}", n: i, total: @max)}
        />
        <.star />
      </label>
      <span :if={@show_value} class="sl-rating-value">{@current}/{@max}</span>
    </fieldset>
    <div
      :if={@readonly}
      id={@id}
      class={[@class, "sl-rating"]}
      data-size={@size}
      role="img"
      aria-label={"#{@label}: #{@current} of #{@max}"}
      {@rest}
    >
      <span :for={i <- 1..@max} class="sl-rating-star" data-filled={i <= @current} aria-hidden="true"><.star /></span>
      <span :if={@show_value} class="sl-rating-value" aria-hidden="true">{@current}/{@max}</span>
    </div>
    """
  end

  defp star(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="1.5"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="m12 3 2.8 5.9 6.4.8-4.7 4.4 1.2 6.4L12 17.3l-5.7 3.2 1.2-6.4L2.8 9.7l6.4-.8L12 3Z" />
    </svg>
    """
  end

  @doc """
  A password field with a show/hide toggle.

      <.password_input field={@form[:password]} label="Password" autocomplete="current-password" required />

  The toggle is a pressed-state button labelled "Show password"; the input's
  type flips between password and text. Everything else matches `input/1`.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autocomplete placeholder minlength maxlength pattern readonly)

  def password_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> password_input()
  end

  def password_input(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    assigns =
      assign(assigns, :describedby, describedby(assigns.id, assigns.description, assigns.errors))

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div
        id={"#{@id}-password"}
        class="sl-input-group"
        data-size={@size}
        phx-hook="SlPassword"
        data-label-show={t("Show password")}
        data-label-hide={t("Hide password")}
      >
        <input
          type="password"
          id={@id}
          name={@name}
          value={@value}
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
            aria-label={t("Show password")}
            aria-pressed="false"
            data-sl-reveal
            disabled={@disabled}
          >
            <.icon name="eye" data-when="hidden" />
            <.icon name="eye-off" data-when="shown" hidden />
          </button>
        </span>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  A color field: the native color input shown as a swatch, its hex value
  beside it, and optional preset swatches.

      <.color_input field={@form[:brand]} label="Brand color" />
      <.color_input name="accent" value="#7c3aed" label="Accent"
        presets={[{"Violet", "#7c3aed"}, {"Teal", "#0d9488"}, "#dc2626"]} />

  The native `<input type="color">` stays the source of truth, so the form
  submits it and `phx-change` fires as usual; picking a preset writes to the
  input and dispatches its events. Presets are a radio group: arrow keys move
  between swatches, Space or Enter picks one, and each swatch is named by its
  label or hex value.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any, doc: "hex color like #7c3aed"
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :presets, :list, default: [], doc: ~s|hex strings or {label, hex} tuples|
  attr :presets_label, :string, default: nil, doc: ~s|defaults to "Preset colors"|
  attr :show_value, :boolean, default: true
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :required, :boolean, default: false
  attr :style, :string, default: nil, doc: "inline style for the field wrapper"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autocomplete form list)

  def color_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> color_input()
  end

  def color_input(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    value = normalize_hex(assigns.value)

    assigns =
      assign(assigns,
        value: value,
        presets: Enum.map(assigns.presets, &normalize_preset/1),
        presets_label: assigns.presets_label || t("Preset colors"),
        describedby: describedby(assigns.id, assigns.description, assigns.errors)
      )

    ~H"""
    <div class={[@class, "sl-field"]} style={@style}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div id={"#{@id}-color"} class="sl-color" data-size={@size} phx-hook="SlColor">
        <span class="sl-color-swatch">
          <input
            type="color"
            id={@id}
            name={@name}
            value={@value}
            class="sl-color-input"
            disabled={@disabled}
            required={@required}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@describedby}
            {@rest}
          />
        </span>
        <output :if={@show_value} for={@id} class="sl-color-value" aria-hidden="true">{@value}</output>
        <div
          :if={@presets != []}
          class="sl-color-presets"
          role="radiogroup"
          aria-label={@presets_label}
        >
          <button
            :for={{{label, hex}, i} <- Enum.with_index(@presets)}
            type="button"
            role="radio"
            class="sl-color-preset"
            style={"--_swatch: #{hex}"}
            data-value={hex}
            aria-checked={to_string(hex == @value)}
            aria-label={label}
            tabindex={
              if hex == @value or (i == 0 and @value not in Enum.map(@presets, &elem(&1, 1))),
                do: "0",
                else: "-1"
            }
            disabled={@disabled}
          >
            <.icon name="check" />
          </button>
        </div>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  defp normalize_preset({label, hex}), do: {to_string(label), normalize_hex(hex)}
  defp normalize_preset(hex), do: {normalize_hex(hex), normalize_hex(hex)}

  defp normalize_hex(nil), do: "#000000"
  defp normalize_hex(""), do: "#000000"

  defp normalize_hex(<<"#", r, g, b>>), do: String.downcase(<<"#", r, r, g, g, b, b>>)

  defp normalize_hex(hex) when is_binary(hex) do
    hex = if String.starts_with?(hex, "#"), do: hex, else: "#" <> hex
    String.downcase(hex)
  end
end
