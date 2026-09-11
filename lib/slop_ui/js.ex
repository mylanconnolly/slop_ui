defmodule SlopUI.JS do
  @moduledoc """
  `Phoenix.LiveView.JS` helpers for driving SlopUI components from the client
  without a server round trip.

      <.button phx-click={SlopJS.open_dialog("#confirm")}>Delete</.button>
  """
  alias Phoenix.LiveView.JS

  @doc "Opens the dialog matched by `selector`."
  def open_dialog(js \\ %JS{}, selector), do: JS.dispatch(js, "sl:open", to: selector)

  @doc "Closes the dialog matched by `selector`."
  def close_dialog(js \\ %JS{}, selector), do: JS.dispatch(js, "sl:close", to: selector)

  @doc "Toggles the dialog matched by `selector`."
  def toggle_dialog(js \\ %JS{}, selector), do: JS.dispatch(js, "sl:toggle", to: selector)
end
