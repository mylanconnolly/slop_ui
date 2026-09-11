defmodule SlopUI.Sink.Pages.Accordion do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Accordion, :accordion}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Exclusive"
      description="Native <details name>: one open at a time, zero JavaScript. Animated where ::details-content is supported."
      code={~S|<.accordion id="faq" exclusive><:item title="…" open>…</:item></.accordion>|}
    >
      <.accordion id="faq" exclusive>
        <:item title="Can I cancel at any time?" open>
          Yes. Cancel from the billing page; access continues until the end of the period.
        </:item>
        <:item title="Do you offer refunds?">Within 30 days of purchase, no questions asked.</:item>
        <:item title="Is there a free tier?">
          There is, with generous limits for hobby projects.
        </:item>
      </.accordion>
    </.example>

    <.example title="Separated, multiple open">
      <.accordion id="multi" variant="separated">
        <:item title="First">Independent items can all be open.</:item>
        <:item title="Second" open>This one starts open.</:item>
        <:item title="Third">And this one closed.</:item>
      </.accordion>
    </.example>
    """
  end
end
