defmodule SlopUI.Sink.Pages.Menus do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Menu, :menu},
      {SlopUI.Components.Menu, :context_menu},
      {SlopUI.Components.Menu, :menu_item},
      {SlopUI.Components.Menu, :menu_sub},
      {SlopUI.Components.Menu, :menu_label},
      {SlopUI.Components.Menu, :menu_separator}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Menu button"
      description="Popover API for top layer and light dismiss, anchor positioning for placement, hook for arrow keys, Home/End, typeahead. Submenus open on hover or ArrowRight; ArrowLeft closes."
      code={
        ~S'''
        <.menu id="user-menu">
          <:trigger variant="outline">Account <.icon name="chevron-down" /></:trigger>
          <.menu_label>Signed in as mc</.menu_label>
          <.menu_item><.icon name="user" /> Profile</.menu_item>
          <.menu_item navigate="/forms"><.icon name="cog" /> Settings <kbd>⌘,</kbd></.menu_item>
          <.menu_separator />
          <.menu_item color="danger"><.icon name="logout" /> Sign out</.menu_item>
        </.menu>
        '''
      }
    >
      <.cluster>
        <.menu id="user-menu">
          <:trigger variant="outline">Account <.icon name="chevron-down" /></:trigger>
          <.menu_label>Signed in as mc</.menu_label>
          <.menu_item><.icon name="user" /> Profile</.menu_item>
          <.menu_item navigate="/forms"><.icon name="cog" /> Settings <kbd>⌘,</kbd></.menu_item>
          <.menu_sub id="share-sub" label="Share">
            <:icon><.icon name="upload" /></:icon>
            <.menu_item>Copy link</.menu_item>
            <.menu_item>Email</.menu_item>
            <.menu_sub id="social-sub" label="Social">
              <.menu_item>Mastodon</.menu_item>
              <.menu_item>Bluesky</.menu_item>
            </.menu_sub>
          </.menu_sub>
          <.menu_item disabled><.icon name="plus" /> Invite (soon)</.menu_item>
          <.menu_separator />
          <.menu_item color="danger"><.icon name="logout" /> Sign out</.menu_item>
        </.menu>

        <.menu id="icon-menu" placement="bottom-end">
          <:trigger variant="ghost" icon aria_label="More actions">
            <.icon name="ellipsis" />
          </:trigger>
          <.menu_item>Duplicate</.menu_item>
          <.menu_item>Archive</.menu_item>
          <.menu_item keep_open>Toggle (stays open)</.menu_item>
          <.menu_separator />
          <.menu_item color="danger"><.icon name="trash" /> Delete</.menu_item>
        </.menu>

        <.menu id="top-menu" placement="top-start">
          <:trigger color="accent">Opens upward</:trigger>
          <.menu_item>Alpha</.menu_item>
          <.menu_item>Beta</.menu_item>
          <.menu_item>Gamma</.menu_item>
        </.menu>
      </.cluster>
    </.example>

    <.example
      title="Context menu"
      description="Right-click (or long-press where the platform maps it) opens the menu at the pointer, clamped to the viewport. Shift+F10 or the Menu key opens it beside the focused element. Items, submenus and keyboard handling are the regular menu's."
      code={
        ~S'''
        <.context_menu id="file-ctx" label="File actions">
          <.card>Right-click me</.card>
          <:menu>
            <.menu_item phx-click="open">Open</.menu_item>
            <.menu_separator />
            <.menu_item color="danger" phx-click="delete">Delete</.menu_item>
          </:menu>
        </.context_menu>
        '''
      }
    >
      <.context_menu id="file-ctx" label="File actions">
        <.card>
          <:header title="report-q3.pdf" />
          Right-click anywhere on this card, or focus it and press Shift+F10.
        </.card>
        <:menu>
          <.menu_item><.icon name="eye" /> Open</.menu_item>
          <.menu_item><.icon name="clipboard" /> Copy link</.menu_item>
          <.menu_sub id="ctx-share" label="Share">
            <:icon><.icon name="upload" /></:icon>
            <.menu_item>Email</.menu_item>
            <.menu_item>Mastodon</.menu_item>
          </.menu_sub>
          <.menu_separator />
          <.menu_item color="danger"><.icon name="trash" /> Delete</.menu_item>
        </:menu>
      </.context_menu>
    </.example>

    <.example
      title="Near the viewport edge"
      description="position-try-fallbacks flips the menu when it would overflow."
    >
      <div style="display:flex; justify-content:flex-end">
        <.menu id="edge-menu">
          <:trigger variant="outline">Right edge</:trigger>
          <.menu_item>This menu would overflow to the right</.menu_item>
          <.menu_item>so it flips to align its end edge</.menu_item>
        </.menu>
      </div>
    </.example>
    """
  end
end
