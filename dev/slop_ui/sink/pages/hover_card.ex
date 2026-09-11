defmodule SlopUI.Sink.Pages.HoverCard do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [{SlopUI.Components.HoverCard, :hover_card}]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Hover card"
      description="Hover or focus the trigger; the card opens after a short delay and stays while the pointer is over it. Tab moves into the card; Escape closes it. Taps on touch screens activate the link instead."
      code={
        ~S'''
        <.hover_card id="ada-card">
          <:trigger><.link href="#">@ada</.link></:trigger>
          <.cluster>
            <.avatar name="Ada Lovelace" />
            <div><strong>Ada Lovelace</strong><br />Wrote the first program.</div>
          </.cluster>
        </.hover_card>
        '''
      }
    >
      <p style="max-inline-size: 40rem">
        Mentioned in this thread:{" "}
        <.hover_card id="ada-card">
          <:trigger><.link href="#">@ada</.link></:trigger>
          <.stack gap="sm">
            <.cluster gap="sm">
              <.avatar name="Ada Lovelace" size="lg" status="online" />
              <div>
                <strong>Ada Lovelace</strong>
                <div style="color: var(--sl-color-fg-muted)">@ada · Joined 1843</div>
              </div>
            </.cluster>
            <p>Wrote the first program for the Analytical Engine. Notes G enjoyer.</p>
            <.cluster gap="sm">
              <.button size="sm" color="accent">Follow</.button>
              <.button size="sm" variant="outline" href="#">Profile</.button>
            </.cluster>
          </.stack>
        </.hover_card>
        {" "}and{" "}
        <.hover_card id="grace-card" placement="top-start" open_delay={200}>
          <:trigger><.link href="#">@grace</.link></:trigger>
          <.cluster gap="sm">
            <.avatar name="Grace Hopper" size="lg" />
            <div>
              <strong>Grace Hopper</strong>
              <div style="color: var(--sl-color-fg-muted)">Opens above, 200ms delay.</div>
            </div>
          </.cluster>
        </.hover_card>
        both reviewed the change.
      </p>
    </.example>
    """
  end
end
