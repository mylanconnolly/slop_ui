defmodule SlopUI.Sink.Pages.Markdown do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components, do: [{SlopUI.Components.Markdown, :markdown}]

  @sample ~S"""
  # Release notes

  SlopUI **2.1** ships the *markdown* component, built on [MDEx](https://hex.pm/packages/mdex).
  Inline `code`, ~~strikethrough~~, and footnotes[^1] all work, and so do autolinks: https://hexdocs.pm.

  ## What changed

  1. Rendering goes through the `.sl-prose` styles, so headings, tables and code follow the tokens.
  2. Output is sanitized by default; raw HTML is dropped unless you opt in.
  3. Code blocks are highlighted with Lumis in `light-dark()` colours.

  ### Checklist

  - [x] Tables
  - [x] Task lists
  - [ ] Math (not planned)

  > **Note**
  > Blockquotes pick up the muted text colour and a border in `border-strong`.

  ```elixir
  defmodule MyAppWeb.PostLive do
    use MyAppWeb, :live_view
    use SlopUI

    def render(assigns) do
      ~H"<.markdown text={@post.body} />"
    end
  end
  ```

  | Option | Default | Effect |
  |---|---|---|
  | `sanitize` | `true` | strips scripts, event handlers and unknown tags |
  | `unsafe` | `false` | allow raw HTML from the source |
  | `size` | `md` | `sm`, `md`, `lg` type scale |

  ---

  Press <kbd>⌘</kbd> <kbd>K</kbd> to search. H~2~O is water and 2^10^ is 1024.

  [^1]: Footnotes render at the end with back-links.
  """

  def render(assigns) do
    assigns = assign(assigns, :sample, @sample)

    ~H"""
    <.example
      title="Markdown"
      description="GFM with tables, task lists, strikethrough, footnotes, autolinks and highlighted code. Sanitized by default."
      code={~S|<.markdown text={@post.body} />|}
    >
      <.markdown text={@sample} />
    </.example>

    <.example
      title="Sizes and prose width"
      description="data-size scales the type; --sl-prose-max sets the measure (default 70ch)."
    >
      <.cluster gap="xl" align="start">
        <.markdown
          text="### Small\n\nCompact body copy for sidebars and cards, with `code` and a [link](#)."
          size="sm"
          style="--sl-prose-max: 24ch"
        />
        <.markdown
          text="### Large\n\nRoomier copy for long reads."
          size="lg"
          style="--sl-prose-max: 24ch"
        />
      </.cluster>
    </.example>

    <.example
      title="Sanitization"
      description="A script tag and an onclick in the source: both removed. Set unsafe to allow raw HTML and sanitize={false} to skip cleaning (only for content you fully trust)."
    >
      <.markdown
        text={
          ~S|Text with <script>alert(1)</script> a script and <a href="#" onclick="alert(2)">a handler</a> and <mark>raw mark</mark>.|
        }
        unsafe
      />
    </.example>
    """
  end
end
