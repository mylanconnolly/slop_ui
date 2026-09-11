defmodule SlopUI.Components.Alert do
  @moduledoc "Inline alerts."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders an alert. Uses `role="alert"` for danger/warning (assertive) and
  `role="status"` otherwise (polite), so live announcements match urgency.

      <.alert color="success" title="Saved">Your changes are live.</.alert>
      <.alert color="danger" on_close={JS.hide(to: "#err")} id="err">Something broke.</.alert>
  """
  attr :id, :string, default: nil

  attr(:color, :string,
    default: "neutral",
    values: ~w(neutral accent success warning danger info)
  )

  attr :title, :string, default: nil
  attr :icon, :boolean, default: true
  attr :on_close, Phoenix.LiveView.JS, default: nil, doc: "when given, renders a close button"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def alert(assigns) do
    assigns = assign(assigns, :icon_name, icon_for(assigns.color))

    ~H"""
    <div
      id={@id}
      role={if @color in ~w(danger warning), do: "alert", else: "status"}
      class={[@class, "sl-alert"]}
      data-color={@color}
      {@rest}
    >
      <.icon :if={@icon} name={@icon_name} />
      <div class="sl-alert-body">
        <p :if={@title} class="sl-alert-title">{@title}</p>
        {render_slot(@inner_block)}
      </div>
      <button
        :if={@on_close}
        type="button"
        class="sl-button sl-alert-close"
        data-variant="ghost"
        data-size="sm"
        data-icon
        aria-label={t("Dismiss")}
        phx-click={@on_close}
      >
        <.icon name="x-mark" />
      </button>
    </div>
    """
  end

  defp icon_for("success"), do: "check-circle"
  defp icon_for("danger"), do: "x-circle"
  defp icon_for("warning"), do: "exclamation-triangle"
  defp icon_for(_), do: "info-circle"
end
