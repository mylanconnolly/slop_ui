defmodule SlopUI.Components.Button do
  @moduledoc """
  Buttons and button groups.
  """
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders a button, or a link styled as a button when `href`, `navigate` or
  `patch` is given.

  ## Examples

      <.button>Save</.button>
      <.button variant="soft" color="accent" size="sm">Filter</.button>
      <.button navigate={~p"/posts/new"} color="accent">New post</.button>
      <.button icon aria-label="Close"><.icon name="x-mark" /></.button>
      <.button loading={@saving}>Save</.button>
  """
  attr :type, :string, default: "button"
  attr :variant, :string, default: "solid", values: ~w(solid soft outline ghost link)

  attr(:color, :string,
    default: "neutral",
    values: ~w(neutral accent success warning danger info)
  )

  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :icon, :boolean, default: false, doc: "square icon-only button; requires aria-label"
  attr :loading, :boolean, default: false, doc: "shows a spinner and marks the button busy"
  attr :href, :any, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :any, default: nil

  attr(:rest, :global,
    include:
      ~w(disabled form name value formaction formmethod popovertarget popovertargetaction autofocus method download target rel)
  )

  slot :inner_block, required: true

  def button(%{href: nil, navigate: nil, patch: nil} = assigns) do
    assigns =
      assign(
        assigns,
        :rest,
        Map.put(assigns.rest, :disabled, assigns.loading || assigns.rest[:disabled] || false)
      )

    ~H"""
    <button
      type={@type}
      class={[@class, "sl-button"]}
      data-variant={@variant}
      data-color={@color}
      data-size={@size}
      data-icon={@icon}
      data-loading={@loading}
      aria-busy={@loading && "true"}
      aria-disabled={@loading && "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # A loading navigation action is temporarily a native disabled button.
  def button(%{loading: true} = assigns) do
    assigns |> assign(href: nil, navigate: nil, patch: nil, type: "button") |> button()
  end

  def button(assigns) do
    ~H"""
    <.link
      href={@href}
      navigate={@navigate}
      patch={@patch}
      class={[@class, "sl-button"]}
      data-variant={@variant}
      data-color={@color}
      data-size={@size}
      data-icon={@icon}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Groups adjacent buttons into a single visual unit.

      <.button_group aria-label="Pagination">
        <.button variant="outline">Prev</.button>
        <.button variant="outline">Next</.button>
      </.button_group>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def button_group(assigns) do
    ~H"""
    <div role="group" class={[@class, "sl-button-group"]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A pressable toggle button (`aria-pressed`).

      <.toggle pressed={@bold} phx-click="toggle-bold" aria-label="Bold"><.icon name="bold" /></.toggle>
  """
  attr :pressed, :boolean, default: false
  attr :variant, :string, default: "outline", values: ~w(solid soft outline ghost)
  attr :color, :string, default: "neutral", values: ~w(neutral accent success warning danger info)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :icon, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def toggle(assigns) do
    ~H"""
    <button
      type="button"
      class={[@class, "sl-button"]}
      data-variant={@variant}
      data-color={@color}
      data-size={@size}
      data-icon={@icon}
      aria-pressed={to_string(@pressed)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  A segmented control backed by real radio (or checkbox) inputs, so it works
  in forms, fires `phx-change`, and is keyboard accessible without JavaScript.

      <.toggle_group name="align" value="left" label="Alignment">
        <:option value="left" aria_label="Align left"><.icon name="align-left" /></:option>
        <:option value="center">Center</:option>
      </.toggle_group>

      <.toggle_group field={@form[:days]} label="Days" multiple>…</.toggle_group>
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any, doc: "selected value, or list of values when multiple"
  attr :label, :string, required: true, doc: "accessible name (visually hidden)"
  attr :multiple, :boolean, default: false
  attr :size, :string, default: "sm", values: ~w(sm md)
  attr :field, Phoenix.HTML.FormField
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form)

  slot :option, required: true do
    attr :value, :string, required: true
    attr :aria_label, :string
    attr :disabled, :boolean
  end

  def toggle_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> toggle_group()
  end

  def toggle_group(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    selected = assigns.value |> List.wrap() |> Enum.map(&to_string/1)
    assigns = assign(assigns, :selected, selected)

    ~H"""
    <fieldset id={@id} class={[@class, "sl-toggle-group"]} data-size={@size} {@rest}>
      <legend>{@label}</legend>
      <input :if={@multiple} type="hidden" name={@name} value="" />
      <label :for={{opt, i} <- Enum.with_index(@option)} aria-label={opt[:aria_label]}>
        <input
          type={if @multiple, do: "checkbox", else: "radio"}
          id={"#{@id}-#{i}"}
          name={@name}
          value={opt.value}
          checked={opt.value in @selected}
          disabled={opt[:disabled]}
        />
        {render_slot(opt)}
      </label>
    </fieldset>
    """
  end

  @doc """
  A button that copies `value` (or the text of the element matched by
  `target`) to the clipboard and briefly shows a copied state.

      <.copy_button value={@api_key} />
      <.copy_button target="#snippet" label="Copy code" />
  """
  attr :value, :string, default: nil
  attr :target, :string, default: nil, doc: "CSS selector of an element whose text to copy"
  attr :label, :string, default: nil, doc: ~s|defaults to "Copy"|
  attr :copied_label, :string, default: nil, doc: ~s|defaults to "Copied"|
  attr :variant, :string, default: "outline", values: ~w(solid soft outline ghost)
  attr :size, :string, default: "sm", values: ~w(sm md lg)
  attr :icon, :boolean, default: false, doc: "icon-only; the label becomes the aria-label"
  attr :class, :any, default: nil
  attr :rest, :global

  def copy_button(assigns) do
    assigns =
      assign(assigns,
        id: assigns[:rest][:id] || "copy-#{:erlang.phash2({assigns.value, assigns.target})}",
        label: assigns.label || t("Copy"),
        copied_label: assigns.copied_label || t("Copied")
      )

    ~H"""
    <button
      type="button"
      id={@id}
      class={[@class, "sl-button sl-copy"]}
      data-variant={@variant}
      data-color="neutral"
      data-size={@size}
      data-icon={@icon}
      data-value={@value}
      data-target={@target}
      data-copied-label={@copied_label}
      aria-label={@icon && @label}
      phx-hook="SlCopy"
      {@rest}
    >
      <.icon name="clipboard" />
      <span :if={!@icon} class="sl-copy-label">{@label}</span>
    </button>
    """
  end
end
