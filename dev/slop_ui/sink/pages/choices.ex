defmodule SlopUI.Sink.Pages.Choices do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Form, :radio_group},
      {SlopUI.Components.Form, :checkbox_group},
      {SlopUI.Components.Button, :toggle},
      {SlopUI.Components.Button, :toggle_group}
    ]
  end

  def render(assigns) do
    ~H"""
    <.form for={@choice_form} phx-change="choices">
      <.stack gap="xl">
        <.example
          title="Radio group"
          description="From an options list. Strings, {label, value} tuples, or maps with description and disabled."
          code={
            ~S|<.radio_group field={@form[:plan]} label="Plan" options={[{"Free", "free"}, {"Pro", "pro"}]} />|
          }
        >
          <.cluster gap="xl" align="start">
            <.radio_group
              field={@choice_form[:plan]}
              label="Plan"
              options={[{"Free", "free"}, {"Pro", "pro"}, {"Team", "team"}]}
            />
            <.radio_group
              field={@choice_form[:size]}
              label="Size"
              orientation="horizontal"
              options={~w(S M L XL)}
            />
            <.badge>plan: {@choice_form[:plan].value} · size: {@choice_form[:size].value}</.badge>
          </.cluster>
        </.example>

        <.example
          title="Card variant"
          code={
            ~S|<.radio_group field={@form[:plan]} label="Plan" variant="cards" options={[%{label: "Pro", value: "pro", description: "For teams"}]} />|
          }
        >
          <.radio_group
            field={@choice_form[:tier]}
            label="Tier"
            variant="cards"
            orientation="horizontal"
            options={[
              %{label: "Starter", value: "starter", description: "For hobby projects. 1 seat."},
              %{label: "Pro", value: "pro", description: "For small teams. 10 seats."},
              %{
                label: "Enterprise",
                value: "enterprise",
                description: "Contact sales.",
                disabled: true
              }
            ]}
          />
        </.example>

        <.example
          title="Checkbox group"
          description="Submits under name[] with a hidden empty value so an unchecked group still sends the key."
          code={
            ~S|<.checkbox_group field={@form[:channels]} label="Notify via" options={~w(Email SMS Push)} />|
          }
        >
          <.cluster gap="xl" align="start">
            <.checkbox_group
              field={@choice_form[:channels]}
              label="Notify via"
              orientation="horizontal"
              options={~w(Email SMS Push)}
              description="Pick any."
            />
            <.badge>
              channels: {@choice_form[:channels].value
              |> List.wrap()
              |> Enum.reject(&(&1 == ""))
              |> Enum.join(", ")}
            </.badge>
          </.cluster>
        </.example>

        <.example
          title="Toggle"
          description="A pressable button with aria-pressed."
          code={~S|<.toggle pressed={@bold} phx-click="toggle-bold" aria-label="Bold">B</.toggle>|}
        >
          <.cluster>
            <.toggle pressed={@bold} phx-click="toggle-bold" aria-label="Bold" icon>
              <strong>B</strong>
            </.toggle>
            <.toggle pressed={!@bold} variant="soft" color="accent">Soft toggle</.toggle>
            <.toggle pressed={false} variant="ghost">Off</.toggle>
          </.cluster>
        </.example>

        <.example
          title="Toggle group"
          description="Real radios or checkboxes styled as a segmented control: form-native, keyboard-native, no JS."
          code={
            ~S|<.toggle_group field={@form[:align]} label="Alignment"><:option value="left">Left</:option>…</.toggle_group>|
          }
        >
          <.cluster gap="lg">
            <.toggle_group field={@choice_form[:align]} label="Alignment">
              <:option value="left" aria_label="Align left">
                <.icon name="chevron-down" style="rotate: 90deg" />
              </:option>
              <:option value="center" aria_label="Align center"><.icon name="minus" /></:option>
              <:option value="right" aria_label="Align right">
                <.icon name="chevron-down" style="rotate: -90deg" />
              </:option>
            </.toggle_group>
            <.toggle_group field={@choice_form[:period]} label="Period" size="md">
              <:option value="day">Day</:option>
              <:option value="week">Week</:option>
              <:option value="month">Month</:option>
              <:option value="year" disabled>Year</:option>
            </.toggle_group>
            <.toggle_group field={@choice_form[:days]} label="Days" multiple>
              <:option :for={d <- ~w(Mo Tu We Th Fr Sa Su)} value={d}>{d}</:option>
            </.toggle_group>
            <.badge>
              align: {@choice_form[:align].value} · period: {@choice_form[:period].value} · days: {@choice_form[
                :days
              ].value
              |> List.wrap()
              |> Enum.reject(&(&1 == ""))
              |> Enum.join(",")}
            </.badge>
          </.cluster>
        </.example>
      </.stack>
    </.form>
    """
  end
end
