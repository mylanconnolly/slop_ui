defmodule SlopUI.Gettext do
  @moduledoc """
  The library's own Gettext backend. It holds the `slop_ui` domain template
  (`priv/gettext/slop_ui.pot`) and English defaults.

  To translate SlopUI's built-in strings in your app, point the library at
  your backend and give it a `slop_ui` domain:

      # config/config.exs
      config :slop_ui, gettext_backend: MyAppWeb.Gettext

      # once, to seed your translations
      cp deps/slop_ui/priv/gettext/slop_ui.pot priv/gettext/
      mix gettext.merge priv/gettext --locale de

  Strings then follow `Gettext.get_locale/0` like the rest of your app. If you
  don't use Gettext, set `config :slop_ui, translator: {Mod, :fun}` where the
  function receives `(msgid, bindings)` and returns a string.
  """
  use Gettext.Backend, otp_app: :slop_ui
end

defmodule SlopUI.I18n do
  @moduledoc false
  # `t/2` is a macro so `mix gettext.extract` sees every msgid, while the
  # runtime path can route through the consumer's backend or translator.
  defmacro t(msgid, bindings \\ Macro.escape(%{})) do
    quote do
      require Gettext.Macros

      SlopUI.I18n.translate(unquote(msgid), unquote(bindings), fn ->
        Gettext.Macros.dgettext_with_backend(
          SlopUI.Gettext,
          "slop_ui",
          unquote(msgid),
          unquote(bindings)
        )
      end)
    end
  end

  defmacro tn(msgid, msgid_plural, n, bindings \\ Macro.escape(%{})) do
    quote do
      require Gettext.Macros

      SlopUI.I18n.translate_plural(
        unquote(msgid),
        unquote(msgid_plural),
        unquote(n),
        unquote(bindings),
        fn ->
          Gettext.Macros.dngettext_with_backend(
            SlopUI.Gettext,
            "slop_ui",
            unquote(msgid),
            unquote(msgid_plural),
            unquote(n),
            unquote(bindings)
          )
        end
      )
    end
  end

  def translate(msgid, bindings, default) do
    case config() do
      {:backend, backend} -> Gettext.dgettext(backend, "slop_ui", msgid, Map.new(bindings))
      {:translator, {mod, fun}} -> apply(mod, fun, [msgid, Map.new(bindings)])
      nil -> default.()
    end
  end

  def translate_plural(msgid, msgid_plural, n, bindings, default) do
    bindings = bindings |> Map.new() |> Map.put(:count, n)

    case config() do
      {:backend, backend} ->
        Gettext.dngettext(backend, "slop_ui", msgid, msgid_plural, n, bindings)

      {:translator, {mod, fun}} ->
        apply(mod, fun, [if(n == 1, do: msgid, else: msgid_plural), bindings])

      nil ->
        default.()
    end
  end

  defp config do
    cond do
      backend = Application.get_env(:slop_ui, :gettext_backend) -> {:backend, backend}
      translator = Application.get_env(:slop_ui, :translator) -> {:translator, translator}
      true -> nil
    end
  end
end
