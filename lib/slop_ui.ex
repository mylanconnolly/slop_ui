defmodule SlopUI do
  require SlopUI.I18n

  @moduledoc """
  SlopUI is a semantic, themeable, accessible component library for Phoenix
  LiveView built on modern vanilla CSS.

  ## Setup

  Add the dependency, then in your `*_web.ex` `html_helpers`:

      import MyAppWeb.CoreComponents, except: [button: 1, input: 1, table: 1]
      use SlopUI

  Exclude any other overlapping CoreComponents functions in older apps.
  See the README for CSS bundler configuration and existing hook integration.

  Import the CSS into your `app.css` (esbuild resolves `slop_ui` via
  `NODE_PATH=deps`, which new Phoenix apps configure by default):

      @import "slop_ui/css";

  Register the hooks in `app.js`:

      import { hooks as slopHooks } from "slop_ui"
      const liveSocket = new LiveSocket("/live", Socket, { hooks: { ...slopHooks } })

  And render the theme boot script in your root layout `<head>` so the
  persisted theme applies before first paint:

      <.theme_script />

  ## Conventions

    * Every class is prefixed `sl-` and names the thing (`sl-button`,
      `sl-card-title`). Variants and sizes are `data-*` attributes; states are
      ARIA attributes or native pseudo-classes, never extra classes.
    * All styles live under the `sl` cascade layer, so your own unlayered CSS
      always wins.
    * Theming is a matter of overriding custom properties. See `tokens.css`.
  """

  defmacro __using__(_opts) do
    quote do
      import SlopUI.Components.Alert
      import SlopUI.Components.Avatar
      import SlopUI.Components.Badge
      import SlopUI.Components.Button
      import SlopUI.Components.Card
      import SlopUI.Components.Dialog
      import SlopUI.Components.Form
      import SlopUI.Components.Layout
      import SlopUI.Components.Menu
      import SlopUI.Components.Tree
      import SlopUI.Components.HoverCard
      import SlopUI.Components.Theme
      import SlopUI.Components.Tooltip
      import SlopUI.Components.Tabs
      import SlopUI.Components.Accordion
      import SlopUI.Components.Toast
      import SlopUI.Components.Table
      import SlopUI.Components.Elements
      import SlopUI.Components.Select
      import SlopUI.Components.Popover
      import SlopUI.Components.Inputs
      import SlopUI.Components.Structure
      import SlopUI.Components.Upload
      import SlopUI.Components.Command
      import SlopUI.Components.DatePicker
      import SlopUI.Components.Markdown
      import SlopUI.Components.Shell
      import SlopUI.Components.MarkdownEditor
      import SlopUI.Components.SplitPanel
      import SlopUI.Components.ScrollArea
      import SlopUI.Components.Carousel
      alias SlopUI.JS, as: SlopJS
    end
  end

  @doc """
  Translates a changeset error tuple into a string.

  Configure your own translator (for example, Gettext) with:

      config :slop_ui, translate_error: {MyAppWeb.CoreComponents, :translate_error}
  """
  @spec translate_error({String.t(), keyword()}) :: String.t()
  def translate_error({msg, opts}) do
    case Application.get_env(:slop_ui, :translate_error) do
      {mod, fun} ->
        apply(mod, fun, [{msg, opts}])

      nil ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
        end)
    end
  end

  @doc """
  Translates a LiveView upload error atom into a string. Configure your own
  translator with `config :slop_ui, translate_upload_error: {Mod, :fun}`.
  """
  @spec translate_upload_error(atom()) :: String.t()
  def translate_upload_error(error) do
    case Application.get_env(:slop_ui, :translate_upload_error) do
      {mod, fun} -> apply(mod, fun, [error])
      nil -> default_upload_error(error)
    end
  end

  defp default_upload_error(:too_large), do: SlopUI.I18n.t("File is too large")
  defp default_upload_error(:too_many_files), do: SlopUI.I18n.t("Too many files")
  defp default_upload_error(:not_accepted), do: SlopUI.I18n.t("File type is not accepted")
  defp default_upload_error(:external_client_failure), do: SlopUI.I18n.t("Upload failed")
  defp default_upload_error(other), do: other |> to_string() |> String.replace("_", " ")

  @doc false
  # Turns an arbitrary DOM id into a valid CSS dashed-ident for anchor names.
  def anchor_name(id) when is_binary(id) do
    "--sl-" <> String.replace(id, ~r/[^a-zA-Z0-9_-]/, "-")
  end
end
