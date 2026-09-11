defmodule SlopUI.Sink.Pages.Extras do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Inputs, :pin_input},
      {SlopUI.Components.Inputs, :tag_input},
      {SlopUI.Components.Inputs, :rating},
      {SlopUI.Components.Structure, :stepper},
      {SlopUI.Components.Structure, :timeline},
      {SlopUI.Components.Structure, :stat},
      {SlopUI.Components.Structure, :collapsible},
      {SlopUI.Components.Button, :copy_button}
    ]
  end

  def render(assigns) do
    ~H"""
    <.form for={@choice_form} phx-change="choices">
      <.stack gap="xl">
        <.example
          title="Pin input"
          description="Auto-advances, Backspace steps back, paste distributes. Submits the combined value."
          code={~S|<.pin_input field={@form[:code]} label="Verification code" length={6} />|}
        >
          <.cluster gap="xl" align="start">
            <.pin_input
              field={@choice_form[:code]}
              label="Verification code"
              length={6}
              separator_after={3}
            />
            <.pin_input name="pin" value="" label="Masked, 4 digits" length={4} mask />
            <.badge>code: {@choice_form[:code].value}</.badge>
          </.cluster>
        </.example>

        <.example
          title="Tag input"
          description="Enter, comma or Tab adds; Backspace removes the last. Each tag submits as name[]."
          code={~S|<.tag_input field={@form[:tags]} label="Tags" />|}
        >
          <.stack gap="sm" style="max-inline-size: 28rem">
            <.tag_input
              field={@choice_form[:tags]}
              label="Tags"
              placeholder="Add a tag…"
              max={6}
              description="Up to 6 tags."
            />
            <.badge>
              tags: {@choice_form[:tags].value
              |> List.wrap()
              |> Enum.reject(&(&1 == ""))
              |> Enum.join(", ")}
            </.badge>
          </.stack>
        </.example>

        <.example
          title="Rating"
          description="Radio buttons under the hood: keyboard and form native. Hover previews."
          code={~S|<.rating field={@form[:stars]} label="Your rating" />|}
        >
          <.cluster gap="xl" align="center">
            <.rating field={@choice_form[:stars]} label="Your rating" show_value />
            <.rating value={4} readonly label="Average" show_value size="sm" />
            <.rating value={2} readonly label="Large" size="lg" />
          </.cluster>
        </.example>

        <.example
          title="Stepper"
          code={
            ~S|<.stepper current={2}><:step title="Account" /><:step title="Profile" /><:step title="Done" /></.stepper>|
          }
        >
          <.stack gap="lg">
            <.stepper current={@step}>
              <:step title="Account" description="Email and password" />
              <:step title="Profile" description="Name and avatar" />
              <:step title="Team" description="Invite people" />
              <:step title="Done" />
            </.stepper>
            <.cluster gap="sm">
              <.button
                size="sm"
                variant="outline"
                phx-click="step"
                phx-value-dir="-1"
                disabled={@step <= 1}
              >Back</.button>
              <.button
                size="sm"
                color="accent"
                phx-click="step"
                phx-value-dir="1"
                disabled={@step >= 4}
              >Next</.button>
            </.cluster>
            <.stepper current={3} pulse>
              <:step title="Queued" />
              <:step title="Building" description="42s" />
              <:step title="Deploying" description="Rolling out to 3 regions" />
              <:step title="Done" />
            </.stepper>
            <p class="sl-description">
              pulse: the current marker breathes for a task that advances on its own. Off by default; leave it off for forms.
            </p>
            <.stepper current={2} orientation="vertical" style="max-inline-size: 20rem">
              <:step title="Order placed" description="September 9" />
              <:step title="Shipped" description="In transit" />
              <:step title="Delivered" />
            </.stepper>
          </.stack>
        </.example>

        <.example
          title="Timeline"
          code={
            ~S|<.timeline><:item title="Deployed v2.1" time="2h ago" color="success">…</:item></.timeline>|
          }
        >
          <.timeline style="max-inline-size: 32rem">
            <:item title="Deployed v2.1" time="2h ago" color="success">
              Rolled out to all regions without incident.
            </:item>
            <:item title="Build passed" time="3h ago" color="accent" />
            <:item title="Flaky test quarantined" time="Yesterday" color="warning">
              Search::IndexerTest timed out twice.
            </:item>
            <:item title="Incident opened" time="2 days ago" color="danger">
              Elevated 5xx rate on the API.
            </:item>
          </.timeline>
        </.example>

        <.example
          title="Stat"
          code={
            ~S|<.stat label="Revenue" value="$48.2k" delta="+12.4%" trend="up" description="vs. last month" />|
          }
        >
          <.grid min="12rem">
            <.stat
              label="Revenue"
              value="$48.2k"
              delta="+12.4%"
              trend="up"
              description="vs. last month"
            >
              <:icon><.icon name="check-circle" /></:icon>
            </.stat>
            <.stat label="Churn" value="2.1%" delta="-0.4%" trend="down" description="vs. last month" />
            <.stat label="Active users" value="12,904" description="last 30 days" />
            <.stat label="Uptime" value="99.98%" delta="0.00%" trend="flat" />
          </.grid>
        </.example>

        <.example
          title="Collapsible"
          code={
            ~S|<.collapsible id="more"><:trigger>Show advanced options</:trigger>…</.collapsible>|
          }
        >
          <.collapsible id="advanced">
            <:trigger>Advanced options</:trigger>
            <.stack gap="md" style="max-inline-size: 24rem">
              <.input name="adv1" value="" label="Webhook URL" placeholder="https://" />
              <.input type="switch" name="adv2" id="adv2" value="" label="Retry on failure" />
            </.stack>
          </.collapsible>
        </.example>

        <.example
          title="Copy button"
          code={~S|<.copy_button value={@api_key} /> <.copy_button target="#snippet" icon />|}
        >
          <.cluster gap="md">
            <.input name="api" value="sk-live-4f8a…" label="API key" readonly>
              <:suffix interactive>
                <.copy_button value="sk-live-4f8a-example" variant="ghost" />
              </:suffix>
            </.input>
            <.cluster gap="sm">
              <code
                id="snippet"
                style="padding: var(--sl-space-2); background: var(--sl-color-surface-sunken); border-radius: var(--sl-radius-sm)"
              >mix deps.get</code>
              <.copy_button target="#snippet" icon label="Copy command" />
            </.cluster>
          </.cluster>
        </.example>
      </.stack>
    </.form>
    """
  end
end
