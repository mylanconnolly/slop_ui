defmodule SlopUI.Sink.Pages.Popover do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components, do: [{SlopUI.Components.Popover, :popover}]

  def render(assigns) do
    ~H"""
    <.example
      title="Popover"
      description="Anchored panel with any content. Focus moves in on open and back to the trigger on close. Escape and outside clicks dismiss."
      code={
        ~S|<.popover id="info" title="What's included"><:trigger>Details</:trigger><p>…</p></.popover>|
      }
    >
      <.cluster gap="lg">
        <.popover id="pop-info" title="What's included">
          <:trigger>Details</:trigger>
          <.stack gap="sm" align="start">
            <p>Unlimited projects, 10 seats, and priority support.</p>
            <.button size="sm" color="accent">Upgrade</.button>
          </.stack>
        </.popover>
        <.popover id="pop-form" title="Rename project" placement="bottom">
          <:trigger variant="soft">Rename</:trigger>
          <.stack gap="sm" style="inline-size: 16rem">
            <.input name="rename" value="Website" label="Name" />
            <.cluster justify="end" gap="sm">
              <.button
                size="sm"
                variant="ghost"
                popovertarget="pop-form-panel"
                popovertargetaction="hide"
              >Cancel</.button>
              <.button size="sm" color="accent">Save</.button>
            </.cluster>
          </.stack>
        </.popover>
        <.popover id="pop-icon" placement="top">
          <:trigger variant="ghost" icon aria_label="Help"><.icon name="info-circle" /></:trigger>
          <p>No title: the panel is a plain popover, not a dialog.</p>
        </.popover>
        <.popover id="pop-manual" title="Sticky" dismissable={false}>
          <:trigger variant="outline">Not dismissable</:trigger>
          <p>Outside clicks don't close this. Use Escape or the button.</p>
          <.button
            size="sm"
            variant="outline"
            popovertarget="pop-manual-panel"
            popovertargetaction="hide"
            style="margin-block-start: var(--sl-space-2)"
          >Close</.button>
        </.popover>
      </.cluster>
    </.example>
    """
  end
end
