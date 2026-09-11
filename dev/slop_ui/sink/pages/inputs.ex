defmodule SlopUI.Sink.Pages.Inputs do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Inputs, :slider},
      {SlopUI.Components.Inputs, :number_input},
      {SlopUI.Components.Inputs, :password_input},
      {SlopUI.Components.Inputs, :color_input}
    ]
  end

  def render(assigns) do
    ~H"""
    <.form for={@choice_form} phx-change="choices">
      <.stack gap="xl">
        <.example
          title="Adornments"
          description="Prefix and suffix slots render inside the field frame; mark control adornments as interactive."
          code={
            ~S|<.input field={@form[:price]} label="Price"><:prefix>$</:prefix><:suffix>USD</:suffix></.input>|
          }
        >
          <.grid min="16rem">
            <.input name="price" value="" label="Price" placeholder="0.00" inputmode="decimal">
              <:prefix>$</:prefix><:suffix>USD</:suffix>
            </.input>
            <.input name="q" value="" type="search" label="Search" placeholder="Search…">
              <:prefix><.icon name="magnifier" /></:prefix>
            </.input>
            <.input name="site" value="" label="Website" placeholder="example.com">
              <:prefix>https://</:prefix>
            </.input>
            <.input name="email2" value="" type="email" label="Email" placeholder="you">
              <:suffix>@company.com</:suffix>
            </.input>
            <.input name="key" value="sk-live-…" label="API key" readonly>
              <:suffix interactive><.button variant="ghost" size="sm">Copy</.button></:suffix>
            </.input>
            <.input name="amount" value="" label="Amount" placeholder="0">
              <:suffix interactive>
                <select class="sl-native-select" name="currency" aria-label="Currency"><option>
                  USD
                </option><option>EUR</option></select>
              </:suffix>
            </.input>
          </.grid>
        </.example>

        <.example
          title="Password"
          description="Show/hide toggle with a pressed state; the input type flips."
          code={
            ~S|<.password_input field={@form[:password]} label="Password" autocomplete="current-password" />|
          }
        >
          <.password_input
            name="pw"
            value="hunter2"
            label="Password"
            autocomplete="current-password"
            style="max-inline-size: 20rem"
          />
        </.example>

        <.example
          title="Color"
          description="The native color input as a swatch with its hex readout, plus preset swatches as a radio group (arrow keys move, Space picks). The input stays the source of truth."
          code={
            ~S'''
            <.color_input name="brand" value="#7c3aed" label="Brand color"
              presets={[{"Violet", "#7c3aed"}, {"Teal", "#0d9488"}, {"Amber", "#d97706"}, "#dc2626", "#f5f5f4", "#1c1917"]} />
            '''
          }
        >
          <.color_input
            name="brand"
            value="#7c3aed"
            label="Brand color"
            description="Pick a preset or open the native picker."
            presets={[
              {"Violet", "#7c3aed"},
              {"Teal", "#0d9488"},
              {"Amber", "#d97706"},
              "#dc2626",
              "#f5f5f4",
              "#1c1917"
            ]}
          />
        </.example>

        <.example
          title="Slider"
          description="Native range input with a readout; the hook only paints the fill and updates the output."
          code={
            ~S|<.slider field={@form[:volume]} label="Volume" min={0} max={100} step={5} format="%v%" />|
          }
        >
          <.stack gap="lg" style="max-inline-size: 28rem">
            <.slider
              field={@choice_form[:volume]}
              label="Volume"
              min={0}
              max={100}
              step={5}
              format="%v%"
            />
            <.slider
              name="temp"
              value={21}
              label="Temperature"
              min={-10}
              max={40}
              marks={["-10°", "15°", "40°"]}
              color="danger"
              description="With marks and a color."
            />
            <.slider name="off" value={30} label="Disabled" disabled />
            <.badge>volume: {@choice_form[:volume].value}</.badge>
          </.stack>
        </.example>

        <.example
          title="Number input"
          description="Steppers drive the native input, honouring min, max and step."
          code={~S|<.number_input field={@form[:qty]} label="Quantity" min={1} max={10} />|}
        >
          <.cluster gap="lg" align="start">
            <.number_input
              field={@choice_form[:qty]}
              label="Quantity"
              min={1}
              max={10}
              style="inline-size: 10rem"
            />
            <.number_input
              name="weight"
              value="2.5"
              label="Weight (kg)"
              step="0.5"
              min="0"
              size="sm"
              style="inline-size: 10rem"
            />
            <.number_input
              name="n-err"
              value=""
              label="With error"
              errors={["is required"]}
              required
              style="inline-size: 10rem"
            />
            <.badge>qty: {@choice_form[:qty].value}</.badge>
          </.cluster>
        </.example>
      </.stack>
    </.form>
    """
  end
end
