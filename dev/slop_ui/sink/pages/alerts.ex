defmodule SlopUI.Sink.Pages.Alerts do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  alias Phoenix.LiveView.JS

  def components do
    [
      {SlopUI.Components.Alert, :alert}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Colors"
      code={~S|<.alert color="success" title="Saved">Your changes are live.</.alert>|}
    >
      <.stack gap="sm">
        <.alert :for={c <- colors()} color={c} title={String.capitalize(c)}>
          This is a {c} alert with a title and a <a href="#">link</a>.
        </.alert>
      </.stack>
    </.example>

    <.example title="Without title or icon">
      <.stack gap="sm">
        <.alert color="info">Just a line of text.</.alert>
        <.alert color="warning" icon={false}>No icon, still announced.</.alert>
      </.stack>
    </.example>

    <.example title="Dismissable" description="Client-side dismiss with JS.hide, or a server event.">
      <.stack gap="sm">
        <.alert id="client-alert" color="accent" on_close={JS.hide(to: "#client-alert")}>
          Dismissed on the client with JS.hide.
        </.alert>
        <.alert :if={@flash_alert} color="success" on_close={JS.push("dismiss-alert")}>
          Dismissed via a server event.
        </.alert>
        <div :if={!@flash_alert}>
          <.button size="sm" variant="outline" phx-click="reset-alert">Bring it back</.button>
        </div>
      </.stack>
    </.example>
    """
  end
end
