defmodule SlopUI.Sink.Pages.Tree do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  def components do
    [
      {SlopUI.Components.Tree, :tree},
      {SlopUI.Components.Tree, :tree_item}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="File browser"
      description="Client-owned selection. Arrow keys move and expand, Home/End jump, * expands siblings, typing jumps by label, Enter/Space select. Branches animate open and closed."
      code={
        ~S'''
        <.tree id="files" label="Project files" on_select={JS.push("open")}>
          <.tree_item value="lib" label="lib" expanded>
            <:icon><.icon name="folder" /></:icon>
            <.tree_item value="lib/app.ex" label="app.ex">
              <:icon><.icon name="document" /></:icon>
            </.tree_item>
          </.tree_item>
        </.tree>
        '''
      }
    >
      <div style="max-inline-size: 22rem">
        <.tree id="files" label="Project files" on_select={JS.push("tree-open")}>
          <.tree_item value="lib" label="lib" expanded>
            <:icon><.icon name="folder" /></:icon>
            <.tree_item value="lib/app.ex" label="app.ex">
              <:icon><.icon name="document" /></:icon>
            </.tree_item>
            <.tree_item value="lib/app_web" label="app_web">
              <:icon><.icon name="folder" /></:icon>
              <.tree_item value="lib/app_web/router.ex" label="router.ex">
                <:icon><.icon name="document" /></:icon>
              </.tree_item>
              <.tree_item value="lib/app_web/endpoint.ex" label="endpoint.ex">
                <:icon><.icon name="document" /></:icon>
              </.tree_item>
              <.tree_item value="lib/app_web/live" label="live">
                <:icon><.icon name="folder" /></:icon>
                <.tree_item value="lib/app_web/live/home_live.ex" label="home_live.ex">
                  <:icon><.icon name="document" /></:icon>
                </.tree_item>
              </.tree_item>
            </.tree_item>
          </.tree_item>
          <.tree_item value="test" label="test">
            <:icon><.icon name="folder" /></:icon>
            <.tree_item value="test/app_test.exs" label="app_test.exs">
              <:icon><.icon name="document" /></:icon>
            </.tree_item>
          </.tree_item>
          <.tree_item value="mix.exs" label="mix.exs" selected>
            <:icon><.icon name="document" /></:icon>
          </.tree_item>
          <.tree_item value="secrets" label="secrets.env" disabled>
            <:icon><.icon name="lock" /></:icon>
          </.tree_item>
        </.tree>
      </div>
    </.example>

    <.example
      title="Server-owned selection with links"
      description="selected comes from an assign, so the tree follows the server; items with navigate/patch/href are real links and work without JavaScript. expanded_all opens every branch."
      code={
        ~S'''
        <.tree id="docs" label="Documentation" selected={@tree_selected} expanded_all>
          <.tree_item value="guides" label="Guides">
            <.tree_item value="guides/install" label="Installation" patch={~p"/tree?doc=install"} />
          </.tree_item>
        </.tree>
        '''
      }
    >
      <.stack gap="sm">
        <p style="font-size: var(--sl-text-sm); color: var(--sl-color-fg-muted)">
          Selected: <code>{@tree_selected || "none"}</code>
        </p>
        <div style="max-inline-size: 22rem">
          <.tree id="docs" label="Documentation" selected={@tree_selected} expanded_all>
            <.tree_item value="guides" label="Guides">
              <.tree_item value="install" label="Installation" patch="/tree?doc=install" />
              <.tree_item value="theming" label="Theming" patch="/tree?doc=theming" />
              <.tree_item value="i18n" label="Translations" patch="/tree?doc=i18n" />
            </.tree_item>
            <.tree_item value="reference" label="Reference">
              <.tree_item value="components" label="Components" patch="/tree?doc=components" />
              <.tree_item value="hooks" label="Hooks" patch="/tree?doc=hooks" />
            </.tree_item>
            <.tree_item value="changelog" label="Changelog" patch="/tree?doc=changelog" />
          </.tree>
        </div>
      </.stack>
    </.example>
    """
  end
end
