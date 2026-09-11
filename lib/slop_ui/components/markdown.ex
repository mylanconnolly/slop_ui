defmodule SlopUI.Components.Markdown do
  @moduledoc """
  Markdown rendering with [MDEx](https://hex.pm/packages/mdex). MDEx is an
  optional dependency: add `{:mdex, "~> 0.13"}` to use this component.
  """
  use Phoenix.Component

  # These calls are guarded at runtime because MDEx is optional for consumers.
  @compile {:no_warn_undefined,
            [{MDEx, :to_html!, 2}, {MDEx.Document, :default_sanitize_options, 0}]}

  @doc """
  Renders Markdown as HTML inside a `.sl-prose` container styled with the
  library's tokens (headings, lists, tables, code, blockquotes, task lists,
  footnotes).

      <.markdown text={@post.body} />
      <.markdown text={@readme} sanitize={false} unsafe />

  GitHub-flavoured extensions are on by default (tables, strikethrough, task
  lists, autolinks, footnotes). Output is sanitized unless `sanitize={false}`,
  and raw HTML in the source is dropped unless `unsafe` is set.

  Code blocks are highlighted with Lumis, in `light-dark()` colours that follow
  the page's scheme, when the Lumis-enabled MDEx NIF is selected:

      config :mdex_native, syntax_highlighter: :lumis

  Without that, code blocks render unhighlighted but otherwise styled.
  """
  attr :text, :string, required: true

  attr :sanitize, :boolean,
    default: true,
    doc: "clean the produced HTML (recommended for user content)"

  attr :unsafe, :boolean, default: false, doc: "allow raw HTML from the source"

  attr :extension, :list,
    default: [],
    doc: "extra MDEx extension options, merged over the defaults"

  attr :themes, :list,
    default: [light: "github_light", dark: "github_dark"],
    doc: "Lumis themes for code blocks"

  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global

  def markdown(assigns) do
    assigns = assign(assigns, :html, render_html(assigns))

    ~H"""
    <div class={[@class, "sl-prose"]} data-size={@size} {@rest}>
      {@html}
    </div>
    """
  end

  @default_extension [
    table: true,
    strikethrough: true,
    tasklist: true,
    autolink: true,
    footnotes: true,
    superscript: true
  ]

  # Default sanitizer plus what GFM task lists and footnotes need to survive it:
  # the checkbox inputs, the footnotes <section>, and the ids the footnote
  # links point at.
  @sanitize_extras [
    add_tags: ["input", "section"],
    add_tag_attributes: %{
      "input" => ["type", "checked", "disabled"],
      "section" => ["class", "data-footnotes"],
      "sup" => ["class"],
      "li" => ["id"],
      "a" => ["id", "data-footnote-ref", "data-footnote-backref", "aria-label"]
    },
    add_tag_attribute_values: %{
      "input" => %{"type" => ["checkbox"]},
      "section" => %{"class" => ["footnotes"]}
    }
  ]

  @doc false
  def render_html(%{text: text} = assigns) do
    unless Code.ensure_loaded?(MDEx) do
      raise "SlopUI.Components.Markdown requires the :mdex dependency. Add {:mdex, \"~> 0.13\"} to your deps."
    end

    options = [
      extension: Keyword.merge(@default_extension, assigns[:extension] || []),
      render: [unsafe: assigns[:unsafe] || false],
      syntax_highlight: syntax_highlight(assigns[:themes]),
      sanitize:
        if(assigns[:sanitize] == false,
          do: nil,
          else: Keyword.merge(MDEx.Document.default_sanitize_options(), @sanitize_extras)
        )
    ]

    text |> to_string() |> MDEx.to_html!(options) |> Phoenix.HTML.raw()
  end

  # Code-block highlighting needs the Lumis-enabled MDEx NIF, which is opt-in,
  # plus the :lumis package for its themes:
  #   config :mdex_native, syntax_highlighter: :lumis
  #   {:lumis, "~> 0.8"}
  # Without both, code blocks render as plain <pre><code>.
  defp syntax_highlight(themes) do
    if Application.get_env(:mdex_native, :syntax_highlighter) == :lumis and
         Code.ensure_loaded?(Lumis) do
      [
        engine: :lumis,
        opts: [
          formatter:
            {:html_multi_themes,
             themes: themes || [light: "github_light", dark: "github_dark"],
             default_theme: "light-dark()"}
        ]
      ]
    else
      nil
    end
  end
end
