defmodule SlopUI.Components.Menu do
  @moduledoc "Dropdown menus built on the popover API and anchor positioning."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders a menu button and its dropdown.

      <.menu id="user-menu" placement="bottom-end">
        <:trigger variant="outline">Account <.icon name="chevron-down" /></:trigger>
        <.menu_label>Signed in as mc</.menu_label>
        <.menu_item navigate={~p"/settings"}><.icon name="cog" /> Settings</.menu_item>
        <.menu_separator />
        <.menu_item color="danger" phx-click="logout"><.icon name="logout" /> Sign out</.menu_item>
      </.menu>

  Keyboard: Enter/Space/Arrow keys open, arrows move, Home/End jump, typing
  jumps by label, Escape and Tab close. All positioning is CSS anchor
  positioning with a JS fallback for older engines.
  """
  attr :id, :string, required: true

  attr(:placement, :string,
    default: "bottom-start",
    values: ~w(bottom-start bottom-end top-start top-end)
  )

  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger, required: true do
    attr :style, :string
    attr :variant, :string
    attr :color, :string
    attr :size, :string
    attr :icon, :boolean
    attr :aria_label, :string
    attr :class, :any
  end

  slot :inner_block, required: true

  def menu(assigns) do
    assigns = assign(assigns, :anchor, SlopUI.anchor_name(assigns.id))

    ~H"""
    <div id={@id} class={[@class, "sl-menu"]} phx-hook="SlMenu" {@rest}>
      <button
        :for={trigger <- @trigger}
        type="button"
        id={"#{@id}-trigger"}
        class={[trigger[:class], "sl-button"]}
        data-variant={trigger[:variant] || "solid"}
        data-color={trigger[:color] || "neutral"}
        data-size={trigger[:size] || "md"}
        data-icon={trigger[:icon]}
        aria-label={trigger[:aria_label]}
        popovertarget={"#{@id}-list"}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-list"}
        style={Enum.join(Enum.reject([trigger[:style], "anchor-name: #{@anchor}"], &is_nil/1), "; ")}
      >
        {render_slot(trigger)}
      </button>
      <div
        id={"#{@id}-list"}
        popover
        role="menu"
        tabindex="-1"
        class="sl-menu-list"
        data-placement={@placement}
        aria-labelledby={"#{@id}-trigger"}
        style={"--sl-anchor: #{@anchor}"}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Wraps content with a context menu that opens on right-click (or long-press
  where the platform maps it to `contextmenu`) at the pointer, and from the
  keyboard with Shift+F10 or the Menu key, anchored to the focused element.

      <.context_menu id="file-ctx" label="File actions">
        <.card>Right-click me</.card>
        <:menu>
          <.menu_item phx-click="open">Open</.menu_item>
          <.menu_item phx-click="rename">Rename</.menu_item>
          <.menu_separator />
          <.menu_item color="danger" phx-click="delete">Delete</.menu_item>
        </:menu>
      </.context_menu>

  The items support everything `menu/1` items do, submenus included. Focus
  returns to where it was when the menu closes. The wrapper is focusable so
  keyboard users can open the menu even when the content has no focusable
  element; pass `tabindex="-1"` to opt out when it does.
  """
  attr :id, :string, required: true

  attr :label, :string,
    default: nil,
    doc: ~s|accessible name of the menu, defaults to "Context menu"|

  attr :tabindex, :string, default: "0"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :menu, required: true
  slot :inner_block, required: true

  def context_menu(assigns) do
    assigns = assign(assigns, :label, assigns.label || t("Context menu"))

    ~H"""
    <div id={@id} class={[@class, "sl-context-menu"]} phx-hook="SlMenu" data-context {@rest}>
      <div
        id={"#{@id}-target"}
        class="sl-context-menu-target"
        tabindex={@tabindex}
        aria-haspopup="menu"
        aria-controls={"#{@id}-list"}
        aria-expanded="false"
        data-sl-context-target
      >
        {render_slot(@inner_block)}
      </div>
      <div
        id={"#{@id}-list"}
        popover
        role="menu"
        tabindex="-1"
        class="sl-menu-list"
        data-placement="pointer"
        aria-label={@label}
      >
        {render_slot(@menu)}
      </div>
    </div>
    """
  end

  @doc "A menu item. Renders a link when `navigate`, `patch` or `href` is set."
  attr :color, :string, default: "neutral", values: ~w(neutral danger)
  attr :disabled, :boolean, default: false
  attr :keep_open, :boolean, default: false, doc: "don't close the menu when activated"
  attr :href, :any, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(method download target)
  slot :inner_block, required: true

  def menu_item(%{href: nil, navigate: nil, patch: nil} = assigns) do
    ~H"""
    <button
      type="button"
      role="menuitem"
      tabindex="-1"
      class={[@class, "sl-menu-item"]}
      data-color={@color}
      data-keep-open={@keep_open}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  def menu_item(assigns) do
    ~H"""
    <.link
      role="menuitem"
      tabindex="-1"
      href={@href}
      navigate={@navigate}
      patch={@patch}
      class={[@class, "sl-menu-item"]}
      data-color={@color}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  A submenu: a menu item that opens a nested menu beside it.

      <.menu_sub id="share-sub" label="Share">
        <.menu_item>Copy link</.menu_item>
        <.menu_item>Email</.menu_item>
      </.menu_sub>

  Opens on hover, click, or ArrowRight; ArrowLeft and Escape close it and
  return focus to the parent item.
  """
  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :icon
  slot :inner_block, required: true

  def menu_sub(assigns) do
    assigns = assign(assigns, :anchor, SlopUI.anchor_name(assigns.id))

    ~H"""
    <div id={@id} class={[@class, "sl-menu-sub"]} {@rest}>
      <button
        type="button"
        id={"#{@id}-trigger"}
        role="menuitem"
        tabindex="-1"
        class="sl-menu-item"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-list"}
        aria-disabled={@disabled && "true"}
        popovertarget={"#{@id}-list"}
        data-sl-submenu
        style={"anchor-name: #{@anchor}"}
      >
        {render_slot(@icon)}
        <span class="sl-menu-item-label">{@label}</span>
        <.icon name="chevron-right" class="sl-menu-sub-chevron" />
      </button>
      <div
        id={"#{@id}-list"}
        popover
        role="menu"
        tabindex="-1"
        class="sl-menu-list"
        data-placement="right-start"
        aria-labelledby={"#{@id}-trigger"}
        style={"--sl-anchor: #{@anchor}"}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc "A non-interactive label inside a menu."
  slot :inner_block, required: true

  def menu_label(assigns) do
    ~H"""
    <div class="sl-menu-label" role="presentation">{render_slot(@inner_block)}</div>
    """
  end

  @doc "A separator between menu groups."
  def menu_separator(assigns) do
    ~H"""
    <hr class="sl-menu-separator" role="separator" />
    """
  end

  @doc false
  def chevron(assigns), do: ~H|<.icon name="chevron-down" />|
end
