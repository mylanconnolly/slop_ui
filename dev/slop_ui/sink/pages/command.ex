defmodule SlopUI.Sink.Pages.Command do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  def components,
    do: [{SlopUI.Components.Command, :command}, {SlopUI.Components.Command, :command_item}]

  def render(assigns) do
    ~H"""
    <.example
      title="Command palette"
      description="Press ⌘K (Ctrl+K) anywhere on this page, or use the button. Type to filter (n p → New project, double-quoted text for literal phrases); arrows move; Enter activates."
      code={
        ~S|<.command id="cmd"><:group label="Navigate"><.command_item navigate="/x" shortcut="G P">Projects</.command_item></:group></.command>|
      }
    >
      <.cluster>
        <.button variant="outline" phx-click={SlopJS.open_dialog("#cmd")}>
          <.icon name="magnifier" /> Open palette
          <.kbd>⌘K</.kbd>
        </.button>
      </.cluster>

      <.command id="cmd" placeholder="Search pages and actions…">
        <:group label="Pages">
          <.command_item :for={{slug, title, _} <- @pages} patch={"/#{slug}"} keywords="page go to">
            <.icon name="folder" /> {title}
          </.command_item>
        </:group>
        <:group label="Actions">
          <.command_item
            phx-click={JS.push("toast", value: %{title: "New project", color: "success"})}
            shortcut="⌘ N"
            hint="Creates a blank project"
          >
            <.icon name="plus" /> New project
          </.command_item>
          <.command_item phx-click={JS.push("flash-info")} keywords="notification">
            <.icon name="info-circle" /> Show a flash message
          </.command_item>
          <.command_item
            phx-click={JS.dispatch("sl:open", to: "#confirm-from-cmd")}
            hint="Opens a dialog"
          >
            <.icon name="trash" /> Delete something…
          </.command_item>
          <.command_item disabled hint="Coming soon"><.icon name="cog" /> Preferences</.command_item>
        </:group>
        <:group label="Theme">
          <.command_item
            :for={
              {t, label, icon} <- [
                {"light", "Light theme", "sun"},
                {"dark", "Dark theme", "moon"},
                {"system", "System theme", "computer"}
              ]
            }
            phx-click={JS.dispatch("sl:set-theme", to: "body", detail: %{theme: t})}
          >
            <.icon name={icon} /> {label}
          </.command_item>
        </:group>
      </.command>

      <.alert_dialog
        id="confirm-from-cmd"
        title="Delete something?"
        confirm="Delete"
        on_confirm={JS.push("toast", value: %{title: "Deleted", color: "danger"})}
      />
    </.example>
    """
  end
end
