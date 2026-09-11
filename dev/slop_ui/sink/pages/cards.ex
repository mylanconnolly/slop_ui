defmodule SlopUI.Sink.Pages.Cards do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Card, :card}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example title="Variants">
      <.grid min="14rem">
        <.card :for={v <- ~w(default outline elevated sunken)} variant={v}>
          <:header title={String.capitalize(v)} description={"variant=\"#{v}\""} />
          Body text goes here.
        </.card>
      </.grid>
    </.example>

    <.example
      title="Header actions and footer"
      code={
        ~S'''
        <.card>
          <:header title="Billing" description="Manage your plan.">
            <.badge color="success" dot>Active</.badge>
          </:header>
          Body
          <:footer divider justify="end">
            <.button variant="ghost">Cancel</.button>
            <.button color="accent">Save</.button>
          </:footer>
        </.card>
        '''
      }
    >
      <.card style="max-inline-size: 32rem">
        <:header title="Billing" description="Manage your plan and payment details.">
          <.badge color="success" dot>Active</.badge>
        </:header>
        <.stack gap="sm">
          <p>You are on the <strong>Pro</strong> plan, billed monthly.</p>
          <p style="color: var(--sl-color-fg-muted); font-size: var(--sl-text-sm)">
            Next invoice on October 1.
          </p>
        </.stack>
        <:footer divider justify="end">
          <.button variant="ghost">Cancel</.button>
          <.button color="accent">Save</.button>
        </:footer>
      </.card>
    </.example>

    <.example
      title="Nested cards"
      description="Donut-scoped: the inner card's footer doesn't pick up the outer card's rules."
    >
      <.card>
        <:header title="Outer" />
        <.card variant="sunken">
          <:header title="Inner" heading_level="h3" /> Nested content
          <:footer divider>Inner footer</:footer>
        </.card>
        <:footer divider>Outer footer</:footer>
      </.card>
    </.example>
    """
  end
end
