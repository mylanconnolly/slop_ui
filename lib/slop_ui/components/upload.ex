defmodule SlopUI.Components.Upload do
  @moduledoc "File upload dropzone and entry list for LiveView uploads."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  import SlopUI.Components.Form, only: [label: 1, description: 1, error: 1, errors: 1]
  import SlopUI.Components.Elements, only: [progress: 1]

  @doc """
  Renders a dropzone and the list of upload entries for a LiveView upload.

      # in mount/3
      allow_upload(socket, :attachments, accept: ~w(.png .jpg .pdf), max_entries: 5, auto_upload: true)

      # in the template, inside a form with phx-change and phx-submit
      <.upload upload={@uploads.attachments} label="Attachments" hint="PNG, JPG or PDF up to 8 MB" on_cancel="cancel-upload" />

      # in the LiveView
      def handle_event("cancel-upload", %{"ref" => ref}, socket), do: {:noreply, cancel_upload(socket, :attachments, ref)}

  Drag and drop, click-to-browse, keyboard access (the file input is focusable
  and labelled), progress, image previews, per-entry and upload-level errors
  are all handled. Errors are translated with `SlopUI.translate_upload_error/1`.
  """
  attr :upload, Phoenix.LiveView.UploadConfig, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil

  attr :hint, :string,
    default: nil,
    doc: "shown inside the dropzone, e.g. accepted types and size"

  attr :on_cancel, :string,
    default: nil,
    doc: "event name pushed with phx-value-ref to cancel an entry"

  attr :compact, :boolean, default: false, doc: "single-row dropzone"
  attr :class, :any, default: nil
  attr :rest, :global

  def upload(assigns) do
    upload = assigns.upload

    errors =
      upload |> Phoenix.Component.upload_errors() |> Enum.map(&SlopUI.translate_upload_error/1)

    assigns =
      assign(assigns,
        errors: errors,
        id: upload.ref,
        multiple: upload.max_entries > 1,
        describedby: describedby(upload.ref, assigns.description, errors)
      )

    ~H"""
    <div class={[@class, "sl-field"]} {@rest}>
      <.label :if={@label} id={"#{@id}-label"} for={@upload.ref}>{@label}</.label>
      <div
        id={"#{@id}-dropzone"}
        class="sl-dropzone"
        phx-drop-target={@upload.ref}
        phx-hook="SlDropzone"
        data-compact={@compact}
        aria-invalid={@errors != [] && "true"}
      >
        <.icon name="upload" />
        <p class="sl-dropzone-title">
          {if @multiple, do: t("Drop files here or"), else: t("Drop a file here or")}
          <label for={@upload.ref} class="sl-dropzone-browse">{t("browse")}</label>
        </p>
        <p :if={@hint} class="sl-dropzone-hint">{@hint}</p>
        <.live_file_input upload={@upload} class="sl-visually-hidden" aria-describedby={@describedby} />
      </div>
      <.description id={@id} text={@description} />
      <.errors id={@id} messages={@errors} />

      <ul :if={@upload.entries != []} class="sl-upload-entries" aria-label={t("Selected files")}>
        <li
          :for={entry <- @upload.entries}
          class="sl-upload-entry"
          data-done={entry.done?}
          aria-invalid={Phoenix.Component.upload_errors(@upload, entry) != [] && "true"}
        >
          <span class="sl-upload-preview">
            <.live_img_preview :if={image?(entry)} entry={entry} />
            <.icon :if={!image?(entry)} name="document" />
          </span>
          <div class="sl-upload-meta">
            <span class="sl-upload-name">{entry.client_name}</span>
            <span class="sl-upload-size">{format_size(entry.client_size)}</span>
          </div>
          <.progress
            :if={!entry.done?}
            class="sl-upload-progress"
            value={entry.progress}
            size="sm"
            label={t("Uploading %{name}", name: entry.client_name)}
          />
          <div :if={Phoenix.Component.upload_errors(@upload, entry) != []} class="sl-upload-errors">
            <.error :for={err <- Phoenix.Component.upload_errors(@upload, entry)}>
              {SlopUI.translate_upload_error(err)}
            </.error>
          </div>
          <div :if={@on_cancel} class="sl-upload-actions">
            <button
              type="button"
              class="sl-button"
              data-variant="ghost"
              data-size="sm"
              data-icon
              aria-label={t("Remove %{name}", name: entry.client_name)}
              phx-click={@on_cancel}
              phx-value-ref={entry.ref}
            >
              <.icon name="x-mark" />
            </button>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp image?(%{client_type: "image/" <> _}), do: true
  defp image?(_), do: false

  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"

  defp describedby(id, description, errors) do
    [description && "#{id}-description", errors != [] && "#{id}-error"]
    |> Enum.filter(& &1)
    |> case do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end
end
