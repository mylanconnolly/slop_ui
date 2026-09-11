defmodule SlopUI.Sink.Pages.Forms do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Form, :input},
      {SlopUI.Components.Form, :label},
      {SlopUI.Components.Form, :fieldset},
      {SlopUI.Components.Form, :error}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Live form"
      description="Backed by a LiveView form with validate/save. Errors appear after interaction, wired via aria-describedby and aria-invalid."
      code={~S|<.input field={@form[:email]} type="email" label="Email" required />|}
    >
      <.form for={@form} phx-change="validate" phx-submit="save" style="max-inline-size: 28rem">
        <.stack gap="lg">
          <.input field={@form[:name]} label="Name" placeholder="Ada Lovelace" required />
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            description="We never share it."
            required
          />
          <.input
            field={@form[:role]}
            type="select"
            label="Role"
            prompt="Choose a role"
            options={["Admin", "Editor", "Viewer"]}
          />
          <.input
            field={@form[:bio]}
            type="textarea"
            label="Bio"
            description="Grows with content where field-sizing is supported."
          />
          <.input field={@form[:agree]} type="checkbox" label="I agree to the terms" />
          <.input field={@form[:notify]} type="switch" label="Email me updates" />
          <.cluster>
            <.button type="submit" color="accent">Save</.button>
            <.button type="reset" variant="ghost">Reset</.button>
          </.cluster>
        </.stack>
      </.form>
    </.example>

    <.example title="Sizes and states">
      <.stack gap="md" style="max-inline-size: 28rem">
        <.input name="a" value="" size="sm" label="Small" placeholder="Small input" />
        <.input name="b" value="" label="Medium" placeholder="Medium input" />
        <.input name="c" value="" size="lg" label="Large" placeholder="Large input" />
        <.input name="d" value="Read only" label="Disabled" disabled />
        <.input name="e" value="bad" label="With server error" errors={["is not valid"]} />
      </.stack>
    </.example>

    <.example title="Choices">
      <.cluster gap="lg" align="start">
        <.fieldset legend="Plan">
          <.input type="radio" name="plan" id="plan-free" value="free" label="Free" checked />
          <.input type="radio" name="plan" id="plan-pro" value="pro" label="Pro" />
          <.input type="radio" name="plan" id="plan-team" value="team" label="Team" disabled />
        </.fieldset>
        <.fieldset legend="Options">
          <.input type="checkbox" name="opt1" id="opt1" label="Checked" checked />
          <.input type="checkbox" name="opt2" id="opt2" label="Unchecked" />
          <.input type="switch" name="opt3" id="opt3" label="Switch on" checked />
          <.input type="switch" name="opt4" id="opt4" label="Switch off" />
        </.fieldset>
      </.cluster>
    </.example>

    <.example
      title="Character counter"
      description="Live count under the control. With maxlength the browser blocks typing past the limit; enforce={false} lets it overrun and only warns. Remaining characters are announced after a pause."
      code={
        ~S'''
        <.input name="bio" type="textarea" label="Bio" maxlength={120} counter />
        <.input name="title" label="Title" maxlength={20} counter enforce={false} />
        '''
      }
    >
      <.grid min="16rem">
        <.input
          name="bio"
          value="Semantic, themeable, accessible."
          type="textarea"
          label="Bio"
          maxlength={120}
          counter
        />
        <.input
          name="title"
          value="A title that is already too long"
          label="Title"
          description="Soft limit: the count warns but typing continues."
          maxlength={20}
          counter
          enforce={false}
        />
      </.grid>
    </.example>

    <.example title="Native input types">
      <.grid min="12rem">
        <.input name="date" value="" type="date" label="Date" />
        <.input name="time" value="" type="time" label="Time" />
        <.input name="num" value="" type="number" label="Number" min="0" max="10" />
        <.input name="color" value="#6d5ce7" type="color" label="Color" />
        <.input name="file" value="" type="file" label="File" />
        <.input name="search" value="" type="search" label="Search" placeholder="Search…" />
      </.grid>
    </.example>
    """
  end
end
