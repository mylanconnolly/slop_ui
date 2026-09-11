defmodule SlopUI.Sink.Templates.SignIn do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  def title, do: "Sign in"

  def render(assigns) do
    ~H"""
    <.auth_layout title="Welcome back" description="Sign in to your Acme workspace.">
      <:brand><.icon name="folder" /> Acme</:brand>
      <.form for={@auth_form} phx-change="auth" phx-submit="auth">
        <.stack gap="md">
          <.button variant="outline" type="button" style="inline-size: 100%"><.icon name="mail" />
          Continue with email link</.button>
          <.separator>or</.separator>
          <.input field={@auth_form[:email]} type="email" label="Email" autocomplete="email" required />
          <.password_input
            field={@auth_form[:password]}
            label="Password"
            autocomplete="current-password"
            required
          />
          <.cluster justify="between">
            <.input type="checkbox" field={@auth_form[:remember]} label="Remember me" />
            <a href="#">Forgot password?</a>
          </.cluster>
          <.button
            color="accent"
            type="submit"
            style="inline-size: 100%"
            phx-click={JS.push("toast", value: %{title: "Signed in"})}
          >Sign in</.button>
        </.stack>
      </.form>
      <:footer>New here? <.link navigate="/templates/sign-up">Create an account</.link></:footer>
    </.auth_layout>
    """
  end
end

defmodule SlopUI.Sink.Templates.SignUp do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Icons

  def title, do: "Sign up"

  def render(assigns) do
    ~H"""
    <.auth_layout title="Create your account" description="Free for 14 days, no card needed.">
      <:brand><.icon name="folder" /> Acme</:brand>
      <.stepper current={1} style="margin-block-end: var(--sl-space-4)">
        <:step title="Account" />
        <:step title="Workspace" />
        <:step title="Team" />
      </.stepper>
      <.form for={@auth_form} phx-change="auth" phx-submit="auth">
        <.stack gap="md">
          <.input field={@auth_form[:name]} label="Full name" autocomplete="name" required />
          <.input
            field={@auth_form[:email]}
            type="email"
            label="Work email"
            autocomplete="email"
            required
          />
          <.password_input
            field={@auth_form[:password]}
            label="Password"
            autocomplete="new-password"
            description="At least 12 characters."
            required
          />
          <.pin_input
            name="auth[code]"
            value=""
            label="Verification code"
            length={6}
            separator_after={3}
            description="Sent to your email."
          />
          <.input
            type="checkbox"
            name="auth[terms]"
            id="terms"
            value=""
            label="I agree to the terms and privacy policy"
            required
          />
          <.button color="accent" type="submit" style="inline-size: 100%">Continue</.button>
        </.stack>
      </.form>
      <:footer>Already have an account? <.link navigate="/templates/sign-in">Sign in</.link></:footer>
    </.auth_layout>
    """
  end
end
