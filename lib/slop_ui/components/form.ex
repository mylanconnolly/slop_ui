defmodule SlopUI.Components.Form do
  @moduledoc """
  Form fields with labels, descriptions and errors wired together with the
  correct `id`/`for`/`aria-describedby`/`aria-invalid` relationships.
  """
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders an input with label, description and errors.

  Mirrors the API of the Phoenix generator's `input/1`, so it accepts a
  `Phoenix.HTML.FormField` and reads name, id, value and errors from it.

      <.input field={@form[:email]} type="email" label="Email" />
      <.input field={@form[:bio]} type="textarea" label="Bio" description="Keep it short." />
      <.input field={@form[:role]} type="select" label="Role" options={["Admin", "Editor"]} prompt="Choose" />
      <.input field={@form[:agree]} type="checkbox" label="I agree" />
      <.input field={@form[:notify]} type="switch" label="Email notifications" />
      <.input field={@form[:bio]} type="textarea" label="Bio" maxlength={280} counter />
      <.input field={@form[:title]} label="Title" maxlength={60} counter enforce={false} />

  With `counter`, a live "n / max" readout sits under the control and turns
  red at the limit. `maxlength` normally blocks typing past the limit; pass
  `enforce={false}` to let the user overrun and only warn (the count turns
  red and the control gets the invalid outline).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :description, :string, default: nil

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select switch tel text textarea time url week)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox, radio and switch inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :counter, :boolean, default: false, doc: "live character count (uses maxlength when set)"

  attr :enforce, :boolean,
    default: true,
    doc: "false lets the user type past maxlength; the counter only warns"

  attr :class, :any, default: nil

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                pattern placeholder readonly required rows step inputmode enterkeyhint)
  )

  slot :prefix, doc: "adornment rendered inside the field frame, before the control" do
    attr :interactive, :boolean,
      doc: "the adornment is a control (button, select): no padding, divider"
  end

  slot :suffix, doc: "adornment rendered inside the field frame, after the control" do
    attr :interactive, :boolean
  end

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: type} = assigns) when type in ~w(checkbox switch) do
    assigns =
      assigns
      |> assign_new(:checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)
      |> assign_describedby()

    ~H"""
    <div class={[@class, "sl-field"]} data-type={@type}>
      <label class="sl-choice">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          role={if @type == "switch", do: "switch"}
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={"sl-#{@type}"}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
          {@rest}
        />
        <span>{@label}</span>
      </label>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    assigns = assign_describedby(assigns)

    ~H"""
    <label class={[@class, "sl-choice"]}>
      <input
        type="radio"
        id={@id}
        name={@name}
        value={@value}
        checked={@checked}
        class="sl-radio"
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@describedby}
        {@rest}
      />
      <span>{@label}</span>
    </label>
    """
  end

  def input(%{type: "select"} = assigns) do
    assigns = assign_describedby(assigns)

    ~H"""
    <div class={[@class, "sl-field"]}>
      <.label :if={@label} for={@id} required={@rest[:required]}>{@label}</.label>
      <select
        id={@id}
        name={@name}
        class="sl-native-select"
        data-size={@size}
        multiple={@multiple}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@describedby}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    assigns = assigns |> assign_counter() |> assign_describedby()

    ~H"""
    <div class={[@class, "sl-field"]}>
      <.label :if={@label} for={@id} required={@rest[:required]}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class="sl-textarea"
        data-size={@size}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@describedby}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.counter :if={@counter} id={@id} value={@value} max={@max} />
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  # All other inputs: text, email, number, date, ...
  def input(assigns) do
    assigns = assigns |> assign_counter() |> assign_describedby()

    ~H"""
    <div class={[@class, "sl-field"]}>
      <.label :if={@label} for={@id} required={@rest[:required]}>{@label}</.label>
      <.frame prefix={@prefix} suffix={@suffix} size={@size}>
        <input
          type={@type}
          id={@id}
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class="sl-input"
          data-size={@size}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@describedby}
          {@rest}
        />
      </.frame>
      <.counter :if={@counter} id={@id} value={@value} max={@max} />
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  # Wraps a control in an input group when adornments are given.
  attr :prefix, :list, required: true
  attr :suffix, :list, required: true
  attr :size, :string, required: true
  slot :inner_block, required: true

  defp frame(%{prefix: [], suffix: []} = assigns) do
    ~H"""
    {render_slot(@inner_block)}
    """
  end

  defp frame(assigns) do
    ~H"""
    <div class="sl-input-group" data-size={@size}>
      <span :for={p <- @prefix} class="sl-input-adornment" data-interactive={p[:interactive]}>{render_slot(
        p
      )}</span>
      {render_slot(@inner_block)}
      <span :for={s <- @suffix} class="sl-input-adornment" data-interactive={s[:interactive]}>{render_slot(
        s
      )}</span>
    </div>
    """
  end

  @doc """
  Renders a group of radio buttons from an options list.

      <.radio_group field={@form[:plan]} label="Plan" options={[{"Free", "free"}, {"Pro", "pro"}]} />
      <.radio_group field={@form[:plan]} label="Plan" variant="cards" options={[
        %{label: "Free", value: "free", description: "For hobby projects"},
        %{label: "Pro", value: "pro", description: "For teams", disabled: true}
      ]} />

  Options are strings, `{label, value}` tuples, or maps with `:label`,
  `:value`, and optional `:description` and `:disabled`.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, required: true, doc: "the legend"
  attr :description, :string, default: nil
  attr :options, :list, required: true
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :variant, :string, default: "default", values: ~w(default cards)
  attr :orientation, :string, default: "vertical", values: ~w(vertical horizontal)
  attr :required, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form)

  def radio_group(assigns), do: choice_group(assigns, "radio")

  @doc """
  Renders a group of checkboxes from an options list. Values submit as a list
  under `name[]`, with a hidden empty value so an unchecked group still sends
  the key.

      <.checkbox_group field={@form[:channels]} label="Notify via" options={~w(Email SMS Push)} orientation="horizontal" />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any, doc: "list of selected values"
  attr :label, :string, required: true
  attr :description, :string, default: nil
  attr :options, :list, required: true
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :variant, :string, default: "default", values: ~w(default cards)
  attr :orientation, :string, default: "vertical", values: ~w(vertical horizontal)
  attr :required, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form)

  def checkbox_group(assigns), do: choice_group(assigns, "checkbox")

  defp choice_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns, type) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> if type == "checkbox", do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> choice_group(type)
  end

  defp choice_group(assigns, type) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    selected = assigns.value |> List.wrap() |> Enum.map(&to_string/1)

    assigns =
      assigns
      |> assign(
        type: type,
        selected: selected,
        options: Enum.map(assigns.options, &normalize_option/1)
      )
      |> assign_describedby()

    ~H"""
    <fieldset
      id={@id}
      class={[@class, "sl-fieldset"]}
      phx-hook={@type == "checkbox" && "SlChoiceGroup"}
      data-required={@required}
      aria-describedby={@describedby}
      aria-required={@required && "true"}
      aria-invalid={@errors != [] && "true"}
      {@rest}
    >
      <legend data-required={@required}>{@label}</legend>
      <.description id={@id} text={@description} />
      <div class="sl-choice-group" data-variant={@variant} data-orientation={@orientation}>
        <input :if={@type == "checkbox"} type="hidden" name={@name} value="" />
        <label :for={{opt, i} <- Enum.with_index(@options)} class="sl-choice">
          <input
            type={@type}
            id={"#{@id}-#{i}"}
            name={@name}
            value={opt.value}
            checked={opt.value in @selected}
            disabled={opt.disabled}
            required={@required && @type == "radio"}
            class={"sl-#{@type}"}
          />
          <span>
            <span class="sl-choice-label">{opt.label}</span>
            <span :if={opt.description} class="sl-choice-description">{opt.description}</span>
          </span>
        </label>
      </div>
      <.errors id={@id} messages={@errors} />
    </fieldset>
    """
  end

  defp normalize_option(%{} = m) do
    %{
      label: to_string(m.label),
      value: to_string(m.value),
      description: m[:description],
      disabled: m[:disabled] || false
    }
  end

  defp normalize_option({label, value}),
    do: %{label: to_string(label), value: to_string(value), description: nil, disabled: false}

  defp normalize_option(value),
    do: %{label: to_string(value), value: to_string(value), description: nil, disabled: false}

  # Pulls maxlength out of `rest` when the limit is soft, so the counter can
  # warn without the browser blocking input.
  defp assign_counter(%{counter: false} = assigns), do: assign(assigns, :max, nil)

  defp assign_counter(assigns) do
    max = assigns.rest[:maxlength]

    # The counter references the control by id, so derive one from the name
    # when the caller gave neither an id nor a form field.
    assigns =
      assign(
        assigns,
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    rest =
      if assigns.enforce, do: assigns.rest, else: Map.delete(assigns.rest, :maxlength)

    assign(assigns, max: max, rest: rest)
  end

  @doc false
  attr :id, :string, required: true
  attr :value, :any, default: nil
  attr :max, :any, default: nil

  def counter(assigns) do
    assigns = assign(assigns, :count, assigns.value |> to_string() |> String.length())

    ~H"""
    <span
      id={"#{@id}-counter"}
      class="sl-counter"
      phx-hook="SlCounter"
      data-for={@id}
      data-max={@max}
      data-label-remaining-one={t("%{count} character remaining", count: "%{count}")}
      data-label-remaining-other={t("%{count} characters remaining", count: "%{count}")}
      data-label-over-one={t("%{count} character over the limit", count: "%{count}")}
      data-label-over-other={t("%{count} characters over the limit", count: "%{count}")}
      data-label-count={t("%{count} characters", count: "%{count}")}
    >
      <span data-count>{@count}</span><span :if={@max} data-max> / {@max}</span>
      <span class="sl-visually-hidden" aria-live="polite" data-live></span>
    </span>
    """
  end

  defp assign_describedby(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign_new(:checked, fn -> false end)

    ids =
      [
        assigns[:counter] && "#{assigns.id}-counter",
        assigns[:description] && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-error"
      ]
      |> Enum.filter(& &1)

    assign(assigns, :describedby, if(ids == [], do: nil, else: Enum.join(ids, " ")))
  end

  @doc "Renders a label."
  attr :id, :string, default: nil
  attr :for, :string, default: nil
  attr :required, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label id={@id} for={@for} class={[@class, "sl-label"]} data-required={@required} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc false
  attr :id, :string, required: true
  attr :text, :string, default: nil

  def description(assigns) do
    ~H"""
    <p :if={@text} id={"#{@id}-description"} class="sl-description">{@text}</p>
    """
  end

  @doc """
  Renders a single error message. Use `errors` for multiple messages associated
  with the same field.
  """
  attr :id, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p id={@id && "#{@id}-error"} class="sl-error">
      <.icon name="exclamation-triangle" style="inline-size:1em;block-size:1em" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc "Renders all field errors under a single accessible description ID."
  attr :id, :string, required: true
  attr :messages, :list, default: []

  def errors(assigns) do
    ~H"""
    <div :if={@messages != []} id={"#{@id}-error"}>
      <.error :for={message <- @messages}>{message}</.error>
    </div>
    """
  end

  @doc """
  Groups related controls (typically radios) under a legend.

      <.fieldset legend="Plan">
        <.input type="radio" name="plan" value="free" label="Free" checked />
        <.input type="radio" name="plan" value="pro" label="Pro" />
      </.fieldset>
  """
  attr :legend, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form name)
  slot :inner_block, required: true

  def fieldset(assigns) do
    ~H"""
    <fieldset class={[@class, "sl-fieldset"]} {@rest}>
      <legend>{@legend}</legend>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end
end
