defmodule SlopUI.Components.Command do
  @moduledoc "Command palette."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders a command palette: a dialog with a search box and grouped,
  keyboard-navigable items. Opened with the keyboard shortcut (⌘K / Ctrl+K by
  default), or with `SlopUI.JS.open_dialog("#id")`.

      <.command id="cmd" placeholder="Search commands…">
        <:group label="Navigate">
          <.command_item navigate={~p"/projects"} shortcut="G P"><.icon name="folder" /> Projects</.command_item>
        </:group>
        <:group label="Actions">
          <.command_item phx-click="new-project" hint="Creates a blank project"><.icon name="plus" /> New project</.command_item>
        </:group>
      </.command>

  Items filter as you type. For server-side search pass `on_search` (an
  event name); the hook pushes `%{"query" => text}` and you re-render the
  items. Enter activates the highlighted item and the palette closes.
  """
  attr :id, :string, required: true
  attr :placeholder, :string, default: nil, doc: ~s|defaults to "Type a command or search…"|

  attr :shortcut, :string,
    default: "k",
    doc: "key combined with ⌘ / Ctrl that opens the palette; nil disables"

  attr :on_search, :string, default: nil
  attr :loading, :boolean, default: false
  attr :empty, :string, default: nil, doc: ~s|defaults to "No results"|
  attr :footer, :boolean, default: true, doc: "show the keyboard hints footer"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(phx-target)

  slot :group, required: true do
    attr :label, :string, required: true
  end

  def command(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={[@class, "sl-dialog sl-command"]}
      data-size="lg"
      data-open="false"
      data-dismiss="true"
      data-shortcut={@shortcut}
      data-on-search={@on_search}
      closedby="any"
      aria-label={t("Command palette")}
      phx-hook="SlCommand"
      {@rest}
    >
      <div class="sl-command-header">
        <.icon name="magnifier" />
        <input
          type="text"
          id={"#{@id}-input"}
          class="sl-command-input"
          role="combobox"
          aria-autocomplete="list"
          aria-expanded="true"
          aria-controls={"#{@id}-list"}
          autocomplete="off"
          spellcheck="false"
          placeholder={@placeholder || t("Type a command or search…")}
        />
        <span :if={@loading} class="sl-spinner" role="status" aria-label={t("Searching")}></span>
        <form method="dialog">
          <kbd class="sl-kbd" style="cursor: pointer"><button
            type="submit"
            style="all: unset; cursor: pointer"
            aria-label={t("Close")}
          >Esc</button></kbd>
        </form>
      </div>
      <div id={"#{@id}-list"} class="sl-command-list" role="listbox" aria-label={t("Results")}>
        <div
          :for={{group, gi} <- Enum.with_index(@group)}
          class="sl-command-group"
          role="group"
          aria-labelledby={"#{@id}-group-#{gi}"}
        >
          <div id={"#{@id}-group-#{gi}"} class="sl-command-group-label">{group.label}</div>
          {render_slot(group)}
        </div>
        <div class="sl-command-empty" hidden>{@empty || t("No results")}</div>
      </div>
      <div :if={@footer} class="sl-command-footer">
        <span><kbd class="sl-kbd">↑</kbd><kbd class="sl-kbd">↓</kbd> {t("navigate")}</span>
        <span><kbd class="sl-kbd">↵</kbd> {t("select")}</span>
        <span><kbd class="sl-kbd">esc</kbd> {t("close")}</span>
      </div>
    </dialog>
    """
  end

  @doc "An item inside a command palette group. Renders a link when `navigate`, `patch` or `href` is set."
  attr :hint, :string, default: nil
  attr :shortcut, :string, default: nil, doc: ~s|space-separated keys, e.g. "⌘ N"|
  attr :keywords, :string, default: nil, doc: "extra words that match when filtering"
  attr :disabled, :boolean, default: false
  attr :href, :any, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def command_item(%{href: nil, navigate: nil, patch: nil} = assigns) do
    ~H"""
    <button
      type="button"
      role="option"
      class={[@class, "sl-command-item"]}
      data-keywords={@keywords}
      aria-disabled={@disabled && "true"}
      tabindex="-1"
      {@rest}
    >
      <.command_item_body hint={@hint} shortcut={@shortcut}>
        {render_slot(@inner_block)}
      </.command_item_body>
    </button>
    """
  end

  def command_item(assigns) do
    ~H"""
    <.link
      role="option"
      class={[@class, "sl-command-item"]}
      href={@href}
      navigate={@navigate}
      patch={@patch}
      data-keywords={@keywords}
      aria-disabled={@disabled && "true"}
      tabindex="-1"
      {@rest}
    >
      <.command_item_body hint={@hint} shortcut={@shortcut}>
        {render_slot(@inner_block)}
      </.command_item_body>
    </.link>
    """
  end

  attr :hint, :string, required: true
  attr :shortcut, :string, required: true
  slot :inner_block, required: true

  defp command_item_body(assigns) do
    ~H"""
    <span class="sl-command-item-label">{render_slot(@inner_block)}</span>
    <span :if={@hint} class="sl-command-item-hint">{@hint}</span>
    <span :if={@shortcut} class="sl-command-item-shortcut" aria-hidden="true">
      <kbd :for={k <- String.split(@shortcut)} class="sl-kbd">{k}</kbd>
    </span>
    """
  end
end
