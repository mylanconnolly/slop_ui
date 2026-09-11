defmodule SlopUI.Sink.Pages.Toasts do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Toast, :toaster},
      {SlopUI.Components.Toast, :toast}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="From flash"
      description="put_flash renders a toast through the toaster; dismissing clears the flash."
      code={~S|<.toaster flash={@flash} />|}
    >
      <.cluster>
        <.button phx-click="flash-info">put_flash(:info)</.button>
        <.button phx-click="flash-error" color="danger" variant="soft">put_flash(:error)</.button>
      </.cluster>
    </.example>

    <.example
      title="From the server"
      description="push_event without touching flash. Timer pauses on hover and focus."
      code={~S|push_event(socket, "sl:toast", %{title: "Saved", color: "success"})|}
    >
      <.cluster>
        <.button :for={c <- colors()} variant="soft" color={c} phx-click="toast" phx-value-color={c}>{c}</.button>
        <.button variant="outline" phx-click="toast-sticky">Sticky (no timer)</.button>
      </.cluster>
    </.example>

    <.example
      title="From the client"
      description="Dispatch sl:toast on window; no round trip."
      code={~S|window.dispatchEvent(new CustomEvent("sl:toast", {detail: {title: "Copied"}}))|}
    >
      <.button
        variant="outline"
        phx-click={
          Phoenix.LiveView.JS.dispatch("sl:toast",
            to: "body",
            detail: %{
              title: "Copied to clipboard",
              description: "From the client, no server involved.",
              color: "info",
              duration: 3000
            }
          )
        }
      >
        Client toast
      </.button>
    </.example>
    """
  end
end
