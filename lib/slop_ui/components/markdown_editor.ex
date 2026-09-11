defmodule SlopUI.Components.MarkdownEditor do
  @moduledoc """
  A Markdown editor in the GitHub style: a textarea with a formatting toolbar,
  keyboard shortcuts, list continuation, a Write/Preview switch, and image
  upload by paste, drop or button through LiveView uploads.
  """
  use Phoenix.Component
  import SlopUI.Icons
  import SlopUI.I18n
  import SlopUI.Components.Form, only: [label: 1, description: 1, error: 1, errors: 1]

  @full ~w(heading bold italic strike | code code_block quote | ul ol task | link image table hr)
  @simple ~w(bold italic | link ul | image)

  @doc """
  Renders the editor.

      <.markdown_editor field={@form[:body]} label="Description" toolbar="simple" />

      <.markdown_editor
        field={@form[:body]}
        label="Description"
        toolbar="full"
        upload={@uploads.images}
      />

  ## Toolbar

  `toolbar` is `"simple"`, `"full"`, or a list of tool names in the order you
  want. Available tools: `heading bold italic strike code code_block quote ul
  ol task link image table hr`, with `"|"` as a separator. The `image` tool is
  only rendered when `upload` is given. Add your own buttons with the `:tool`
  slot; they receive the textarea id in `data-for`.

  ## Preview

  The Preview tab renders the current value with `markdown/1`, so keep the
  value in your form assigns and let `phx-change` update it (the editor
  debounces changes). Requires the optional `mdex` dependency; without it the
  Preview tab is omitted.

  ## Images

  Pass a LiveView upload config declared with `auto_upload: true` and a
  `progress` callback. Pasting or dropping an image, or using the image
  button, hands the files to the upload and inserts an "Uploading" placeholder
  at the cursor. When your callback has stored the file, push the URL back and
  the placeholder becomes `![name](url)`:

      # mount/3
      socket
      |> allow_upload(:images, accept: ~w(.png .jpg .jpeg .gif .webp), max_entries: 10,
           auto_upload: true, progress: &handle_progress/3)

      # the callback
      def handle_progress(:images, entry, socket) do
        if entry.done? do
          url = consume_uploaded_entry(socket, entry, fn %{path: path} -> {:ok, MyApp.Storage.put(path, entry)} end)
          {:noreply, SlopUI.Components.MarkdownEditor.push_image(socket, entry, url)}
        else
          {:noreply, socket}
        end
      end

  Storage is yours: local files, S3, anything that yields a URL.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 8, doc: "minimum visible lines"
  attr :toolbar, :any, default: "full", doc: ~s|"simple", "full", or a list of tool names|

  attr :upload, Phoenix.LiveView.UploadConfig,
    default: nil,
    doc: "enables image paste/drop/button"

  attr :preview, :boolean, default: true
  attr :fullscreen, :boolean, default: true, doc: "show the fullscreen toggle"
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(phx-debounce maxlength autocomplete)

  slot :tool, doc: "extra toolbar buttons; each gets data-for pointing at the textarea"

  def markdown_editor(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &SlopUI.translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> markdown_editor()
  end

  def markdown_editor(assigns) do
    assigns =
      assigns
      |> assign_new(:value, fn -> nil end)
      |> assign(
        :id,
        assigns[:id] || String.replace(to_string(assigns[:name]), ~r/[^a-zA-Z0-9_-]+/, "_")
      )

    tools = tools(assigns.toolbar, assigns.upload)
    preview? = assigns.preview and Code.ensure_loaded?(MDEx)

    assigns =
      assign(assigns,
        tools: tools,
        preview?: preview?,
        text: to_string(assigns.value || ""),
        describedby: describedby(assigns.id, assigns.description, assigns.errors)
      )

    ~H"""
    <div class={[@class, "sl-field"]}>
      <.label :if={@label} for={@id} required={@required}>{@label}</.label>
      <div
        id={"#{@id}-editor"}
        class="sl-md-editor"
        phx-hook="SlMarkdownEditor"
        aria-invalid={@errors != [] && "true"}
        data-textarea={@id}
        data-label-uploading={t("Uploading %{name}…", name: "__NAME__")}
        style={"--sl-md-rows: #{@rows}"}
      >
        <div class="sl-md-header">
          <div :if={@preview?} class="sl-md-modes" role="tablist" aria-label={t("Editor mode")}>
            <button
              type="button"
              role="tab"
              aria-selected="true"
              aria-controls={"#{@id}-write"}
              data-sl-mode="write"
            >{t("Write")}</button>
            <button
              type="button"
              role="tab"
              aria-selected="false"
              aria-controls={"#{@id}-preview"}
              data-sl-mode="preview"
            >{t("Preview")}</button>
          </div>
          <div class="sl-md-toolbar" role="toolbar" aria-label={t("Formatting")}>
            <%= for tool <- @tools do %>
              <span :if={tool == "|"} class="sl-md-sep" aria-hidden="true"></span>
              <button
                :if={tool != "|"}
                type="button"
                class="sl-button"
                data-variant="ghost"
                data-size="sm"
                data-icon
                data-sl-tool={tool}
                aria-label={tool_label(tool)}
                title={tool_label(tool)}
                tabindex="-1"
                disabled={@disabled}
              >
                <.icon name={tool_icon(tool)} />
              </button>
            <% end %>
            <span :for={tool <- @tool} data-for={@id}>{render_slot(tool)}</span>
            <span :if={@fullscreen} class="sl-md-sep" aria-hidden="true"></span>
            <button
              :if={@fullscreen}
              type="button"
              class="sl-button sl-md-fullscreen"
              data-variant="ghost"
              data-size="sm"
              data-icon
              data-sl-fullscreen
              aria-pressed="false"
              aria-label={t("Fullscreen")}
              title={t("Fullscreen")}
              tabindex="-1"
            >
              <.icon name="maximize" />
            </button>
          </div>
        </div>

        <div id={"#{@id}-write"} class="sl-md-write" role="tabpanel">
          <textarea
            id={@id}
            name={@name}
            class="sl-textarea sl-md-textarea"
            placeholder={@placeholder}
            required={@required}
            disabled={@disabled}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@describedby}
            {@rest}
          >{@text}</textarea>
          <.live_file_input
            :if={@upload}
            upload={@upload}
            class="sl-visually-hidden"
            tabindex="-1"
            aria-hidden="true"
          />
          <div :if={@upload} class="sl-md-drop-hint">{t("Drop images to upload")}</div>
        </div>

        <div :if={@preview?} id={"#{@id}-preview"} class="sl-md-preview" role="tabpanel">
          <SlopUI.Components.Markdown.markdown :if={String.trim(@text) != ""} text={@text} />
          <p :if={String.trim(@text) == ""} class="sl-md-empty">{t("Nothing to preview")}</p>
        </div>

        <div class="sl-md-footer">
          <span><.icon
            name="markdown"
            style="inline-size: 1rem; block-size: 1rem; vertical-align: -0.2em"
          /> {t("Markdown supported")}</span>
          <span :if={@upload}>{t("Paste, drop or attach images")}</span>
          <span class="sl-md-count" data-sl-count>{String.length(@text)}</span>
          <ul
            :if={@upload && Enum.any?(@upload.entries, &(!&1.done?))}
            class="sl-upload-entries"
            aria-label={t("Uploading")}
          >
            <li
              :for={entry <- @upload.entries}
              :if={!entry.done?}
              class="sl-upload-entry"
              aria-invalid={Phoenix.Component.upload_errors(@upload, entry) != [] && "true"}
            >
              <span class="sl-upload-preview"><.icon name="document" /></span>
              <div class="sl-upload-meta">
                <span class="sl-upload-name">{entry.client_name}</span>
              </div>
              <SlopUI.Components.Elements.progress
                class="sl-upload-progress"
                value={entry.progress}
                size="sm"
                label={t("Uploading %{name}", name: entry.client_name)}
              />
              <div
                :if={Phoenix.Component.upload_errors(@upload, entry) != []}
                class="sl-upload-errors"
              >
                <.error :for={err <- Phoenix.Component.upload_errors(@upload, entry)}>
                  {SlopUI.translate_upload_error(err)}
                </.error>
              </div>
            </li>
          </ul>
        </div>
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />
    </div>
    """
  end

  @doc """
  Tells the editor that an uploaded image is stored at `url`, replacing its
  "Uploading" placeholder with `![name](url)`. Call it from your upload
  `progress` callback once the entry is consumed.
  """
  def push_image(socket, %Phoenix.LiveView.UploadEntry{} = entry, url) do
    Phoenix.LiveView.push_event(socket, "sl:markdown-image", %{
      name: entry.client_name,
      size: entry.client_size,
      url: url,
      alt: Path.rootname(entry.client_name)
    })
  end

  @doc "Removes the placeholder for an entry whose upload failed."
  def push_image_error(socket, %Phoenix.LiveView.UploadEntry{} = entry) do
    Phoenix.LiveView.push_event(socket, "sl:markdown-image-error", %{
      name: entry.client_name,
      size: entry.client_size
    })
  end

  defp tools("full", upload), do: tools(@full, upload)
  defp tools("simple", upload), do: tools(@simple, upload)

  defp tools(list, upload) when is_list(list) do
    list
    |> Enum.map(&to_string/1)
    |> Enum.reject(&(&1 == "image" and is_nil(upload)))
    |> Enum.filter(&(&1 in @full))
    |> Enum.chunk_by(&(&1 == "|"))
    |> Enum.flat_map(fn
      ["|" | _] -> ["|"]
      tools -> tools
    end)
    |> trim_separators()
  end

  defp trim_separators(list) do
    list
    |> Enum.drop_while(&(&1 == "|"))
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == "|"))
    |> Enum.reverse()
  end

  defp tool_label("heading"), do: t("Heading")
  defp tool_label("bold"), do: t("Bold (⌘B)")
  defp tool_label("italic"), do: t("Italic (⌘I)")
  defp tool_label("strike"), do: t("Strikethrough")
  defp tool_label("code"), do: t("Inline code (⌘E)")
  defp tool_label("code_block"), do: t("Code block")
  defp tool_label("quote"), do: t("Quote")
  defp tool_label("ul"), do: t("Bulleted list")
  defp tool_label("ol"), do: t("Numbered list")
  defp tool_label("task"), do: t("Task list")
  defp tool_label("link"), do: t("Link (⌘K)")
  defp tool_label("image"), do: t("Attach an image")
  defp tool_label("table"), do: t("Table")
  defp tool_label("hr"), do: t("Horizontal rule")

  defp tool_icon("heading"), do: "heading"
  defp tool_icon("bold"), do: "bold"
  defp tool_icon("italic"), do: "italic"
  defp tool_icon("strike"), do: "strikethrough"
  defp tool_icon("code"), do: "code"
  defp tool_icon("code_block"), do: "code-block"
  defp tool_icon("quote"), do: "quote"
  defp tool_icon("ul"), do: "list-ul"
  defp tool_icon("ol"), do: "list-ol"
  defp tool_icon("task"), do: "list-check"
  defp tool_icon("link"), do: "link"
  defp tool_icon("image"), do: "image"
  defp tool_icon("table"), do: "table"
  defp tool_icon("hr"), do: "minus"

  defp describedby(id, description, errors) do
    [description && "#{id}-description", errors != [] && "#{id}-error"]
    |> Enum.filter(& &1)
    |> case do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end
end
