defmodule SlopUI.Components.Toast do
  @moduledoc "Toast notifications, including LiveView flash integration."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  @doc """
  Renders the toast region. Put one in your app layout.

      <.toaster flash={@flash} />

  Flash messages render as toasts (`:info` and `:error` by default, plus any
  key listed in `kinds`). Toasts can also be pushed from the server without
  touching flash:

      push_event(socket, "sl:toast", %{title: "Saved", color: "success", duration: 4000})

  or raised from the client:

      window.dispatchEvent(new CustomEvent("sl:toast", {detail: {title: "Copied"}}))

  Toasts auto-dismiss after `duration` ms (pausing on hover and focus), or
  never when `duration` is 0. Escape dismisses the focused toast.
  """
  attr :id, :string, default: "sl-toaster"
  attr :flash, :map, default: %{}

  attr(:position, :string,
    default: "bottom-end",
    values: ~w(bottom-end bottom-start bottom-center top-end top-start top-center)
  )

  attr :duration, :integer, default: 5000, doc: "default auto-dismiss in ms; 0 disables"

  attr(:kinds, :list,
    default: [info: "info", error: "danger"],
    doc: "flash keys and the toast color for each"
  )

  attr(:connection_toasts, :boolean,
    default: true,
    doc: "show connection lost / server error toasts"
  )

  attr :rest, :global

  def toaster(assigns) do
    ~H"""
    <div
      id={@id}
      class="sl-toaster"
      data-position={@position}
      data-duration={@duration}
      phx-hook="SlToaster"
      role="region"
      aria-label={t("Notifications")}
      data-label-dismiss={t("Dismiss")}
      {@rest}
    >
      <.toast
        :for={{key, color} <- @kinds}
        :if={msg = Phoenix.Flash.get(@flash, key)}
        id={"#{@id}-flash-#{key}"}
        color={color}
        title={msg}
        on_dismiss={JS.push("lv:clear-flash", value: %{key: key})}
      />
      <.toast
        :if={@connection_toasts}
        id={"#{@id}-client-error"}
        color="danger"
        title={t("We can't find the internet")}
        description={t("Attempting to reconnect…")}
        duration={0}
        closable={false}
        hidden
        phx-disconnected={JS.remove_attribute("hidden")}
        phx-connected={JS.set_attribute({"hidden", ""})}
      />
      <.toast
        :if={@connection_toasts}
        id={"#{@id}-server-error"}
        color="danger"
        title={t("Something went wrong")}
        description={t("Hang in there while we get back on track")}
        duration={0}
        closable={false}
        hidden
        phx-disconnected={JS.remove_attribute("hidden")}
        phx-connected={JS.set_attribute({"hidden", ""})}
      />
      <div id={"#{@id}-client"} phx-update="ignore" style="display: contents"></div>
    </div>
    """
  end

  @doc "A single toast. Usually rendered by `toaster/1`, but can be placed anywhere."
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, default: nil

  attr(:color, :string,
    default: "neutral",
    values: ~w(neutral accent success warning danger info)
  )

  attr :duration, :integer, default: nil, doc: "overrides the toaster default; 0 disables"
  attr :closable, :boolean, default: true
  attr :icon, :boolean, default: true
  attr :on_dismiss, JS, default: nil, doc: "run when dismissed by timer or the close button"
  attr :rest, :global, include: ~w(hidden)

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      class="sl-toast"
      role={if @color in ~w(danger warning), do: "alert", else: "status"}
      data-color={@color}
      data-duration={@duration}
      data-on-dismiss={@on_dismiss}
      tabindex="0"
      phx-remove={JS.hide(transition: {"sl-toast-leaving", "", ""}, time: 200)}
      {@rest}
    >
      <.icon :if={@icon} name={icon_for(@color)} />
      <div>
        <p class="sl-toast-title">{@title}</p>
        <p :if={@description} class="sl-toast-description">{@description}</p>
      </div>
      <button
        :if={@closable}
        type="button"
        class="sl-button sl-toast-close"
        data-variant="ghost"
        data-size="sm"
        data-icon
        aria-label={t("Dismiss")}
        data-sl-dismiss
      >
        <.icon name="x-mark" />
      </button>
    </div>
    """
  end

  @doc false
  def icon_for("success"), do: "check-circle"
  def icon_for("danger"), do: "x-circle"
  def icon_for("warning"), do: "exclamation-triangle"
  def icon_for(_), do: "info-circle"
end
