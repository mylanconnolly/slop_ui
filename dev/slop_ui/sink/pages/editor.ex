defmodule SlopUI.Sink.Pages.Editor do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components, do: [{SlopUI.Components.MarkdownEditor, :markdown_editor}]

  def render(assigns) do
    ~H"""
    <.form for={@editor_form} phx-change="editor" phx-submit="editor-save">
      <.stack gap="xl">
        <.example
          title="Full toolbar with image uploads"
          description="Paste or drop an image, or use the image button: the file goes through a LiveView upload, a placeholder appears at the cursor, and it's replaced with the final URL when the sink's progress callback has stored it. Switch to Preview to see it rendered."
          code={
            ~S|<.markdown_editor field={@form[:body]} label="Description" toolbar="full" upload={@uploads.images} />|
          }
        >
          <.markdown_editor
            field={@editor_form[:body]}
            label="Description"
            toolbar="full"
            upload={@uploads.md_images}
            placeholder="Write something…"
            phx-debounce="300"
            description="⌘B bold, ⌘I italic, ⌘K link, ⌘E code. Enter continues lists; Tab indents them."
          />
          <.cluster gap="sm" style="margin-block-start: var(--sl-space-3)">
            <.button type="submit" color="accent">Save</.button>
            <.badge :if={@editor_saved}>saved {String.length(@editor_saved)} chars</.badge>
          </.cluster>
        </.example>

        <.example
          title="Simple toolbar, no uploads"
          code={~S|<.markdown_editor field={@form[:note]} toolbar="simple" rows={4} />|}
        >
          <.markdown_editor
            field={@editor_form[:note]}
            label="Note"
            toolbar="simple"
            rows={4}
            placeholder="A quick note"
            phx-debounce="300"
          />
        </.example>

        <.example
          title="Custom tool list and extra buttons"
          code={
            ~S'''
            <.markdown_editor toolbar={~w(bold italic | quote code_block)} fullscreen={false}>
              <:tool><.button size="sm" variant="ghost">Insert template</.button></:tool>
            </.markdown_editor>
            '''
          }
        >
          <.markdown_editor
            name="editor[custom]"
            value="> Only quote and code here.\n\n```elixir\nIO.puts(:hi)\n```"
            label="Custom"
            toolbar={~w(bold italic | quote code_block)}
            fullscreen={false}
            rows={5}
          >
            <:tool>
              <.button
                type="button"
                size="sm"
                variant="ghost"
                phx-click={
                  Phoenix.LiveView.JS.dispatch("sl:toast",
                    to: "body",
                    detail: %{title: "Your button, your action", color: "info"}
                  )
                }
              >Insert template</.button>
            </:tool>
          </.markdown_editor>
        </.example>
      </.stack>
    </.form>
    """
  end
end
