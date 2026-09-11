defmodule SlopUI.Sink.Pages.Upload do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  def components, do: [{SlopUI.Components.Upload, :upload}]

  def render(assigns) do
    ~H"""
    <.example
      title="Dropzone"
      description="Built on LiveView uploads with auto_upload. Drag files in, click anywhere in the zone, or Tab to the input and press Enter. Try a .txt file to see a rejection."
      code={
        ~S|<.upload upload={@uploads.attachments} label="Attachments" hint="PNG, JPG or PDF up to 2 MB, max 3 files" on_cancel="cancel-upload" />|
      }
    >
      <.form
        for={%{}}
        as={:upload}
        phx-change="upload-validate"
        phx-submit="upload-save"
        style="max-inline-size: 36rem"
      >
        <.stack gap="md">
          <.upload
            upload={@uploads.attachments}
            label="Attachments"
            hint="PNG, JPG or PDF up to 2 MB, max 3 files"
            on_cancel="cancel-upload"
          />
          <.cluster>
            <.button
              type="submit"
              color="accent"
              disabled={
                @uploads.attachments.entries == [] or
                  not Enum.all?(@uploads.attachments.entries, & &1.done?)
              }
            >Save {length(@uploads.attachments.entries)} file(s)</.button>
            <.badge :if={@saved_uploads != []}>saved: {Enum.join(@saved_uploads, ", ")}</.badge>
            <span :if={Enum.any?(@uploads.attachments.entries, &(!&1.done?))} class="sink-muted">
              Remove rejected files to enable saving.
            </span>
          </.cluster>
        </.stack>
      </.form>
    </.example>

    <.example
      title="Compact"
      description="A single-row zone for tight layouts, single file."
      code={~S|<.upload upload={@uploads.avatar} compact />|}
    >
      <.form
        for={%{}}
        as={:avatar}
        phx-change="upload-validate"
        phx-submit="upload-save"
        style="max-inline-size: 36rem"
      >
        <.upload upload={@uploads.avatar} label="Avatar" compact on_cancel="cancel-avatar" />
      </.form>
    </.example>
    """
  end
end
