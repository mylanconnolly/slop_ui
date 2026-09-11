defmodule SlopUI.Sink.Pages.Elements do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components do
    [
      {SlopUI.Components.Avatar, :avatar},
      {SlopUI.Components.Avatar, :avatar_group},
      {SlopUI.Components.Elements, :skeleton},
      {SlopUI.Components.Elements, :progress},
      {SlopUI.Components.Elements, :spinner},
      {SlopUI.Components.Elements, :kbd},
      {SlopUI.Components.Elements, :separator},
      {SlopUI.Components.Elements, :breadcrumbs},
      {SlopUI.Components.Elements, :pagination}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Avatar"
      description="Image, initials with a stable per-name hue, or a generic icon. A broken image falls back to initials."
      code={~S|<.avatar name="Ada Lovelace" size="lg" status="online" />|}
    >
      <.stack gap="md">
        <.cluster>
          <.avatar :for={s <- ~w(xs sm md lg xl)} name="Ada Lovelace" size={s} />
          <.avatar src="https://i.pravatar.cc/96?img=5" name="Photo" size="lg" />
          <.avatar src="https://example.invalid/missing.png" name="Broken Image" size="lg" />
          <.avatar size="lg" />
        </.cluster>
        <.cluster>
          <.avatar
            :for={
              n <- [
                "Grace Hopper",
                "Linus Torvalds",
                "Margaret Hamilton",
                "Alan Turing",
                "Katherine Johnson"
              ]
            }
            name={n}
          />
          <.avatar name="Accent" color="accent" />
          <.avatar name="Danger" color="danger" />
        </.cluster>
        <.cluster>
          <.avatar :for={st <- ~w(online away busy offline)} name={String.capitalize(st)} status={st} />
          <.avatar name="Square Shape" shape="square" status="online" />
          <.avatar
            src="https://i.pravatar.cc/96?img=12"
            name="Photo"
            shape="square"
            size="lg"
            status="busy"
          />
        </.cluster>
        <.cluster>
          <.avatar_group overflow={4}>
            <.avatar name="Ada L" /><.avatar name="Grace H" /><.avatar name="Linus T" />
          </.avatar_group>
          <.avatar_group size="sm">
            <.avatar name="Ada L" size="sm" /><.avatar name="Grace H" size="sm" />
          </.avatar_group>
        </.cluster>
      </.stack>
    </.example>

    <.example title="Skeleton" code={~S|<.skeleton shape="text" width="60%" />|}>
      <.cluster gap="md" align="start" style="max-inline-size: 24rem" aria-busy="true">
        <.skeleton shape="circle" height="3rem" />
        <.stack gap="xs" style="flex: 1">
          <.skeleton shape="text" width="40%" />
          <.skeleton shape="text" />
          <.skeleton shape="text" width="80%" />
        </.stack>
      </.cluster>
    </.example>

    <.example title="Progress and spinner" code={~S|<.progress value={42} label="Uploading" />|}>
      <.stack gap="md" style="max-inline-size: 24rem">
        <.progress value={42} label="Uploading" />
        <.progress value={80} color="success" size="sm" label="Done soon" />
        <.progress label="Working" />
        <.cluster>
          <.spinner size="sm" /><.spinner /><.spinner size="lg" /> <span>with text</span>
        </.cluster>
      </.stack>
    </.example>

    <.example title="Kbd and separator">
      <.stack gap="md">
        <p>
          Press
          <.kbd>⌘</.kbd>

          <.kbd>K</.kbd>
          to open the command palette, or
          <.kbd>Esc</.kbd>
          to close it.
        </p>
        <.separator />
        <.separator>or continue with</.separator>
        <.cluster style="block-size: 2rem">
          <span>Left</span><.separator orientation="vertical" /><span>Right</span>
        </.cluster>
      </.stack>
    </.example>

    <.example
      title="Breadcrumbs"
      code={
        ~S|<.breadcrumbs><:crumb navigate="/">Home</:crumb><:crumb>Current</:crumb></.breadcrumbs>|
      }
    >
      <.breadcrumbs>
        <:crumb patch="/">Home</:crumb>
        <:crumb patch="/tables">Tables</:crumb>
        <:crumb>Elements</:crumb>
      </.breadcrumbs>
    </.example>

    <.example
      title="Pagination"
      description="Rendered from page and total_pages; links patch by default."
      code={~S|<.pagination page={@page_no} total_pages={20} path={&"/elements?page_no=#{&1}"} />|}
    >
      <.stack gap="sm">
        <.pagination page={@page_no} total_pages={20} path={&"/elements?page_no=#{&1}"} />
        <.pagination page={1} total_pages={3} path={&"/elements?page=#{&1}"} />
      </.stack>
    </.example>
    """
  end
end
