defmodule SlopUI.Components.Dialog do
  @moduledoc "Modal dialogs on the native `<dialog>` element."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons
  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal dialog.

  Open it from the client with `SlopUI.JS.open_dialog/1`, or from the server
  with `show={@show}`. Close buttons inside the dialog need no JavaScript at
  all when wrapped in `<form method="dialog">`.

      <.button phx-click={SlopJS.open_dialog("#confirm")}>Delete</.button>

      <.dialog id="confirm" on_close={JS.push("cancelled")}>
        <:title>Delete post?</:title>
        <:description>This cannot be undone.</:description>
        Body content
        <:footer>
          <form method="dialog"><.button variant="outline">Cancel</.button></form>
          <.button color="danger" phx-click="delete">Delete</.button>
        </:footer>
      </.dialog>

  Accessibility: `aria-labelledby` and `aria-describedby` point at the title
  and description. Focus is trapped and restored by the platform.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false, doc: "server-controlled open state"
  attr :size, :string, default: "md", values: ~w(sm md lg xl full)
  attr :placement, :string, default: "center", values: ~w(center top)
  attr :dismissable, :boolean, default: true, doc: "close on Escape and backdrop click"
  attr :close_button, :boolean, default: true
  attr :on_open, JS, default: nil, doc: "JS command run after the dialog opens"
  attr :on_close, JS, default: nil, doc: "JS command run after the dialog closes"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :title
  slot :description
  slot :inner_block
  slot :footer

  def dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={[@class, "sl-dialog"]}
      data-size={@size}
      data-placement={@placement}
      data-open={to_string(@show)}
      data-dismiss={to_string(@dismissable)}
      data-on-open={@on_open}
      data-on-close={@on_close}
      closedby={if @dismissable, do: "any", else: "none"}
      aria-labelledby={@title != [] && "#{@id}-title"}
      aria-describedby={@description != [] && "#{@id}-description"}
      phx-hook="SlDialog"
      {@rest}
    >
      <.dialog_chrome id={@id} title={@title} description={@description} close_button={@close_button} />
      <div :if={@inner_block != []} class="sl-dialog-body">
        {render_slot(@inner_block)}
      </div>
      <div :if={@footer != []} class="sl-dialog-footer">
        {render_slot(@footer)}
      </div>
    </dialog>
    """
  end

  @doc """
  Renders a sheet: a dialog docked to a viewport edge. Same API as `dialog/1`
  plus `side`.

      <.sheet id="filters" side="right">
        <:title>Filters</:title>
        ...
      </.sheet>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :side, :string, default: "right", values: ~w(right left top bottom)
  attr :size, :string, default: "md", values: ~w(sm md lg xl)
  attr :dismissable, :boolean, default: true
  attr :close_button, :boolean, default: true
  attr :on_open, JS, default: nil
  attr :on_close, JS, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :title
  slot :description
  slot :inner_block
  slot :footer

  def sheet(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={[@class, "sl-sheet"]}
      data-side={@side}
      data-size={@size}
      data-open={to_string(@show)}
      data-dismiss={to_string(@dismissable)}
      data-on-open={@on_open}
      data-on-close={@on_close}
      closedby={if @dismissable, do: "any", else: "none"}
      aria-labelledby={@title != [] && "#{@id}-title"}
      aria-describedby={@description != [] && "#{@id}-description"}
      phx-hook="SlDialog"
      {@rest}
    >
      <.dialog_chrome id={@id} title={@title} description={@description} close_button={@close_button} />
      <div :if={@inner_block != []} class="sl-dialog-body">
        {render_slot(@inner_block)}
      </div>
      <div :if={@footer != []} class="sl-dialog-footer">
        {render_slot(@footer)}
      </div>
    </dialog>
    """
  end

  @doc """
  Renders a confirmation dialog (`role="alertdialog"`). The cancel button is
  focused first (via the hook, not the `autofocus` attribute, which browsers
  can honour on page load even inside a closed dialog) so Enter never
  confirms by accident; Escape cancels; clicking
  the backdrop does nothing.

      <.alert_dialog id="delete-post" title="Delete this post?"
        description="This permanently removes the post and its comments."
        confirm="Delete" on_confirm={JS.push("delete", value: %{id: @post.id})} />

  `on_confirm` runs and then the dialog closes.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :color, :string, default: "danger", values: ~w(danger warning info accent)
  attr :confirm, :string, default: nil, doc: ~s|defaults to "Confirm"|
  attr :cancel, :string, default: nil, doc: ~s|defaults to "Cancel"|
  attr :on_confirm, JS, required: true
  attr :on_close, JS, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block

  def alert_dialog(assigns) do
    assigns =
      assign(assigns,
        confirm_js: SlopUI.JS.close_dialog(assigns.on_confirm, "##{assigns.id}"),
        confirm: assigns.confirm || t("Confirm"),
        cancel: assigns.cancel || t("Cancel")
      )

    ~H"""
    <dialog
      id={@id}
      role="alertdialog"
      class={[@class, "sl-dialog"]}
      data-size="sm"
      data-color={@color}
      data-open={to_string(@show)}
      data-dismiss="closerequest"
      data-on-close={@on_close}
      closedby="closerequest"
      aria-labelledby={"#{@id}-title"}
      aria-describedby={@description && "#{@id}-description"}
      phx-hook="SlDialog"
      {@rest}
    >
      <div class="sl-dialog-header">
        <span class="sl-alert-dialog-icon" aria-hidden="true">
          <.icon name={if @color == "info", do: "info-circle", else: "exclamation-triangle"} />
        </span>
        <div style="flex: 1">
          <h2 id={"#{@id}-title"} class="sl-dialog-title">{@title}</h2>
          <p :if={@description} id={"#{@id}-description"} class="sl-dialog-description">
            {@description}
          </p>
        </div>
      </div>
      <div :if={@inner_block != []} class="sl-dialog-body">{render_slot(@inner_block)}</div>
      <div class="sl-dialog-footer">
        <form method="dialog">
          <button
            type="submit"
            class="sl-button"
            data-variant="outline"
            data-color="neutral"
            data-size="md"
            data-sl-autofocus
          >
            {@cancel}
          </button>
        </form>
        <button
          type="button"
          class="sl-button"
          data-variant="solid"
          data-color={@color}
          data-size="md"
          phx-click={@confirm_js}
        >
          {@confirm}
        </button>
      </div>
    </dialog>
    """
  end

  @doc false
  attr :id, :string, required: true
  attr :title, :list, required: true
  attr :description, :list, required: true
  attr :close_button, :boolean, required: true

  def dialog_chrome(assigns) do
    ~H"""
    <div :if={@title != [] or @close_button} class="sl-dialog-header">
      <div>
        <h2 :if={@title != []} id={"#{@id}-title"} class="sl-dialog-title">
          {render_slot(@title)}
        </h2>
        <p :if={@description != []} id={"#{@id}-description"} class="sl-dialog-description">
          {render_slot(@description)}
        </p>
      </div>
      <form :if={@close_button} method="dialog">
        <button
          type="submit"
          class="sl-button sl-dialog-close"
          data-variant="ghost"
          data-size="sm"
          data-icon
          aria-label={t("Close")}
        >
          <.icon name="x-mark" />
        </button>
      </form>
    </div>
    """
  end
end
