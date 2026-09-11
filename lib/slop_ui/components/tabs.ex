defmodule SlopUI.Components.Tabs do
  @moduledoc "Tabs following the WAI-ARIA tabs pattern."
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a tab list and its panels.

  Client-owned (default): the hook tracks the selected tab and protects it
  from server patches.

      <.tabs id="settings" default="general">
        <:tab value="general">General</:tab>
        <:tab value="billing">Billing</:tab>
        <:panel value="general">...</:panel>
        <:panel value="billing">...</:panel>
      </.tabs>

  Server-owned: pass `value` and `on_change`. The hook pushes `on_change`
  with `%{"tab" => value}` and re-selects whenever `value` changes.

      <.tabs id="settings" value={@tab} on_change={JS.push("tab")}>

  URL-owned: give tabs a `patch`, and pass `value` from the params.

      <:tab value="general" patch={~p"/settings/general"}>General</:tab>

  Keyboard: arrows move and activate, Home/End jump. Panels are focusable so
  keyboard users can reach their content directly from the tab.
  """
  attr :id, :string, required: true
  attr :default, :string, default: nil, doc: "initially selected tab value (client-owned)"
  attr :value, :string, default: nil, doc: "selected tab value (server-owned)"
  attr :on_change, JS, default: nil, doc: "pushed with phx-value-tab when a tab is selected"
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :variant, :string, default: "line", values: ~w(line pill)
  attr :label, :string, default: nil, doc: "accessible name for the tab list"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :tab, required: true do
    attr :value, :string, required: true
    attr :patch, :string
    attr :navigate, :string
    attr :disabled, :boolean
  end

  slot :panel, required: true do
    attr :value, :string, required: true
  end

  def tabs(assigns) do
    selected = assigns.value || assigns.default || hd(assigns.tab).value
    assigns = assign(assigns, selected: selected, controlled: not is_nil(assigns.value))

    ~H"""
    <div
      id={@id}
      class={[@class, "sl-tabs"]}
      data-orientation={@orientation}
      data-variant={@variant}
      data-value={@selected}
      data-controlled={@controlled}
      data-on-change={@on_change}
      phx-hook="SlTabs"
      {@rest}
    >
      <div role="tablist" class="sl-tablist" aria-label={@label} aria-orientation={@orientation}>
        <%= for tab <- @tab do %>
          <.link
            :if={tab[:patch] || tab[:navigate]}
            patch={tab[:patch]}
            navigate={tab[:navigate]}
            role="tab"
            id={"#{@id}-tab-#{tab.value}"}
            class="sl-tab"
            aria-selected={to_string(tab.value == @selected)}
            aria-controls={"#{@id}-panel-#{tab.value}"}
            aria-disabled={tab[:disabled] && "true"}
            tabindex={if tab.value == @selected, do: "0", else: "-1"}
            phx-value-tab={tab.value}
          >
            {render_slot(tab)}
          </.link>
          <button
            :if={!(tab[:patch] || tab[:navigate])}
            type="button"
            role="tab"
            id={"#{@id}-tab-#{tab.value}"}
            class="sl-tab"
            aria-selected={to_string(tab.value == @selected)}
            aria-controls={"#{@id}-panel-#{tab.value}"}
            aria-disabled={tab[:disabled] && "true"}
            tabindex={if tab.value == @selected, do: "0", else: "-1"}
            phx-value-tab={tab.value}
          >
            {render_slot(tab)}
          </button>
        <% end %>
      </div>
      <div
        :for={panel <- @panel}
        role="tabpanel"
        id={"#{@id}-panel-#{panel.value}"}
        class="sl-tabpanel"
        aria-labelledby={"#{@id}-tab-#{panel.value}"}
        tabindex="0"
        hidden={panel.value != @selected}
      >
        {render_slot(panel)}
      </div>
    </div>
    """
  end
end
