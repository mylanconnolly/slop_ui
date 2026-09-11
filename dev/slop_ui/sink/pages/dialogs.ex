defmodule SlopUI.Sink.Pages.Dialogs do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  alias Phoenix.LiveView.JS

  def components do
    [
      {SlopUI.Components.Dialog, :dialog},
      {SlopUI.Components.Dialog, :alert_dialog},
      {SlopUI.Components.Dialog, :sheet}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Client-driven"
      description="Opened with SlopJS.open_dialog, no round trip. Close via Escape, backdrop, the X, or the Cancel button (a <form method=dialog>, zero JS)."
      code={
        ~S'''
        <.button phx-click={SlopJS.open_dialog("#confirm")}>Open</.button>
        <.dialog id="confirm">
          <:title>Delete post?</:title>
          <:description>This cannot be undone.</:description>
          <:footer>
            <form method="dialog"><.button variant="outline">Cancel</.button></form>
            <.button color="danger">Delete</.button>
          </:footer>
        </.dialog>
        '''
      }
    >
      <.cluster>
        <.button phx-click={SlopJS.open_dialog("#confirm")} color="danger" variant="soft">Delete post…</.button>
        <.button phx-click={SlopJS.open_dialog("#big")} variant="outline">Large, scrolling</.button>
        <.button phx-click={SlopJS.open_dialog("#strict")} variant="outline">Not dismissable</.button>
      </.cluster>

      <.dialog id="confirm" size="sm">
        <:title>Delete post?</:title>
        <:description>This permanently removes the post and its comments.</:description>
        <:footer>
          <form method="dialog"><.button variant="outline">Cancel</.button></form>
          <.button color="danger" phx-click={SlopJS.close_dialog("#confirm")}>Delete</.button>
        </:footer>
      </.dialog>

      <.dialog id="big" size="lg" placement="top">
        <:title>Terms of service</:title>
        <.stack gap="md">
          <p :for={_ <- 1..12}>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Body scrolls; header and footer stay put.
            Background scroll is locked with html:has(dialog[open]).
          </p>
        </.stack>
        <:footer>
          <form method="dialog"><.button color="accent">Accept</.button></form>
        </:footer>
      </.dialog>

      <.dialog id="strict" dismissable={false} close_button={false}>
        <:title>Choose to continue</:title>
        <:description>Escape and backdrop clicks are disabled. You must pick.</:description>
        <:footer>
          <form method="dialog"><.button variant="outline">Later</.button></form>
          <form method="dialog"><.button color="accent">Continue</.button></form>
        </:footer>
      </.dialog>
    </.example>

    <.example
      title="Alert dialog"
      description="A confirm: role=alertdialog, cancel focused first, Escape cancels, backdrop clicks ignored. on_confirm runs, then it closes."
      code={
        ~S|<.alert_dialog id="del" title="Delete this post?" description="…" confirm="Delete" on_confirm={JS.push("delete")} />|
      }
    >
      <.cluster>
        <.button color="danger" variant="soft" phx-click={SlopJS.open_dialog("#alert-danger")}>Delete…</.button>
        <.button color="warning" variant="soft" phx-click={SlopJS.open_dialog("#alert-warning")}>Discard changes…</.button>
        <.button variant="outline" phx-click={SlopJS.open_dialog("#alert-info")}>Sign out…</.button>
      </.cluster>
      <.alert_dialog
        id="alert-danger"
        title="Delete this post?"
        description="This permanently removes the post and all 12 comments. This cannot be undone."
        confirm="Delete post"
        on_confirm={JS.push("toast", value: %{title: "Deleted", color: "danger"})}
      />
      <.alert_dialog
        id="alert-warning"
        color="warning"
        title="Discard unsaved changes?"
        description="You have edits that haven't been saved."
        confirm="Discard"
        cancel="Keep editing"
        on_confirm={JS.push("toast", value: %{title: "Discarded", color: "warning"})}
      />
      <.alert_dialog
        id="alert-info"
        color="info"
        title="Sign out of all devices?"
        confirm="Sign out"
        on_confirm={JS.push("toast", value: %{title: "Signed out", color: "info"})}
      >
        <p>You will need to sign in again on your phone and laptop.</p>
      </.alert_dialog>
    </.example>

    <.example
      title="Sheets"
      description="A dialog docked to an edge; same hook, same API, plus side."
      code={~S|<.sheet id="filters" side="right"><:title>Filters</:title>…</.sheet>|}
    >
      <.cluster>
        <.button
          :for={side <- ~w(right left top bottom)}
          variant="outline"
          phx-click={SlopJS.open_dialog("#sheet-#{side}")}
        >{side}</.button>
      </.cluster>
      <.sheet :for={side <- ~w(right left top bottom)} id={"sheet-#{side}"} side={side}>
        <:title>Filters</:title>
        <:description>Docked to the {side}.</:description>
        <.stack gap="md">
          <.input name="q" value="" label="Search" placeholder="Search…" />
          <.input
            type="select"
            name="status"
            value=""
            label="Status"
            options={["Any", "Active", "Invited"]}
          />
          <.input type="switch" name="mine" id={"mine-#{side}"} value="" label="Only mine" />
        </.stack>
        <:footer>
          <form method="dialog"><.button variant="outline">Cancel</.button></form>
          <.button color="accent" phx-click={SlopJS.close_dialog("#sheet-#{side}")}>Apply</.button>
        </:footer>
      </.sheet>
    </.example>

    <.example
      title="Server-driven"
      description="show={@dialog_open}; the hook reconciles data-open on every patch while JS.ignore_attributes protects the native open attribute."
      code={~S|<.dialog id="server" show={@dialog_open} on_close={JS.push("close-dialog")}>|}
    >
      <.cluster>
        <.button phx-click="open-dialog" color="accent">Open from server</.button>
        <.badge color={if @dialog_open, do: "success", else: "neutral"} dot>
          assign: {@dialog_open}
        </.badge>
      </.cluster>
      <.dialog id="server" show={@dialog_open} on_close={JS.push("close-dialog")}>
        <:title>Server owns this</:title>
        <:description>
          Closing it (any way) pushes close-dialog so the assign stays in sync.
        </:description>
        <.input name="x" value="" label="Focus lands in the dialog" placeholder="Type here" />
        <:footer>
          <.button color="accent" phx-click="close-dialog">Done</.button>
        </:footer>
      </.dialog>
    </.example>
    """
  end
end
