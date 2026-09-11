defmodule SlopUI.Sink.Pages.Structure do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components do
    [
      {SlopUI.Components.Structure, :page_header},
      {SlopUI.Components.Structure, :empty_state},
      {SlopUI.Components.Structure, :description_list}
    ]
  end

  def render(assigns) do
    ~H"""
    <.example
      title="Page header"
      code={
        ~S|<.page_header title="Projects" description="…"><:eyebrow><.breadcrumbs>…</.breadcrumbs></:eyebrow><:actions><.button>New</.button></:actions></.page_header>|
      }
    >
      <.page_header
        title="Projects"
        description="Everything your team is working on, in one place."
        heading_level="h2"
      >
        <:eyebrow>
          <.breadcrumbs>
            <:crumb patch="/">Home</:crumb><:crumb>Projects</:crumb>
          </.breadcrumbs>
        </:eyebrow>
        <:actions>
          <.button variant="outline">Import</.button>
          <.button color="accent"><.icon name="plus" /> New project</.button>
        </:actions>
      </.page_header>
      <p style="color: var(--sl-color-fg-muted)">Page content follows.</p>
    </.example>

    <.example
      title="Empty state"
      code={
        ~S|<.empty_state title="No projects yet" description="…"><:icon><.icon name="inbox" /></:icon><:actions>…</:actions></.empty_state>|
      }
    >
      <.stack gap="md">
        <.empty_state
          title="No projects yet"
          description="Projects group your work and let you invite collaborators. Create your first one to get started."
        >
          <:icon><.icon name="inbox" /></:icon>
          <:actions>
            <.button color="accent"><.icon name="plus" /> New project</.button>
            <.button variant="ghost">Import from GitHub</.button>
          </:actions>
        </.empty_state>
        <.empty_state title="No results" description="Try a different search." variant="plain" />
      </.stack>
    </.example>

    <.example
      title="Description list"
      code={~S|<.description_list divider><:item label="Name">Ada</:item></.description_list>|}
    >
      <.grid min="20rem" gap="lg">
        <.card>
          <:header title="Horizontal, divided" heading_level="h3" />
          <.description_list divider>
            <:item label="Name">Ada Lovelace</:item>
            <:item label="Email">ada@analytical.engine</:item>
            <:item label="Role">
              <.badge color="accent">Owner</.badge>
            </:item>
            <:item label="Joined">December 10, 1815</:item>
          </.description_list>
        </.card>
        <.card>
          <:header title="Vertical" heading_level="h3" />
          <.description_list orientation="vertical">
            <:item label="Name">Grace Hopper</:item>
            <:item label="Status">
              <.badge color="success" dot>Active</.badge>
            </:item>
            <:item label="Bio">
              Invented the first compiler and popularised machine-independent programming languages.
            </:item>
          </.description_list>
        </.card>
      </.grid>
    </.example>
    """
  end
end
