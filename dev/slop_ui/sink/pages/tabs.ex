defmodule SlopUI.Sink.Pages.Tabs do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  def components do
    [
      {SlopUI.Components.Tabs, :tabs}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Client-owned"
      description="Selection lives in the browser. Arrow keys move and activate; Home/End jump."
      code={
        ~S|<.tabs id="t1" default="general"><:tab value="general">General</:tab>…<:panel value="general">…</:panel></.tabs>|
      }
    >
      <.tabs id="t1" default="general" label="Settings">
        <:tab value="general"><.icon name="cog" /> General</:tab>
        <:tab value="billing">Billing</:tab>
        <:tab value="team">Team</:tab>
        <:tab value="danger" disabled>Danger zone</:tab>
        <:panel value="general">
          <p>General settings panel.</p>
        </:panel>
        <:panel value="billing">
          <p>Billing panel.</p>
        </:panel>
        <:panel value="team">
          <p>Team panel.</p>
        </:panel>
        <:panel value="danger">
          <p>Never shown; the tab is disabled.</p>
        </:panel>
      </.tabs>
    </.example>

    <.example
      title="Server-owned"
      description="value comes from an assign, on_change pushes with phx-value-tab. The badge is rendered by the server."
      code={~S|<.tabs id="t2" value={@tab} on_change={JS.push("tab")}>|}
    >
      <.stack gap="sm">
        <.badge color="accent">assign: {@tab}</.badge>
        <.tabs id="t2" value={@tab} on_change={JS.push("tab")} variant="pill" label="Period">
          <:tab value="day">Day</:tab>
          <:tab value="week">Week</:tab>
          <:tab value="month">Month</:tab>
          <:panel value="day">Daily numbers.</:panel>
          <:panel value="week">Weekly numbers.</:panel>
          <:panel value="month">Monthly numbers.</:panel>
        </.tabs>
      </.stack>
    </.example>

    <.example title="Vertical">
      <.tabs id="t3" orientation="vertical" default="a" label="Sections">
        <:tab value="a">Profile</:tab>
        <:tab value="b">Notifications</:tab>
        <:tab value="c">Security</:tab>
        <:panel value="a">Profile panel.</:panel>
        <:panel value="b">Notifications panel.</:panel>
        <:panel value="c">Security panel.</:panel>
      </.tabs>
    </.example>
    """
  end
end
