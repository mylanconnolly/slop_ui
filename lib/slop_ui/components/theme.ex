defmodule SlopUI.Components.Theme do
  @moduledoc "Light/dark/system theme support."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Inline script for your root layout `<head>`. Applies the persisted theme and
  appearance preferences (palette, dark variant, contrast, density, radius)
  before first paint so there is no flash of the wrong scheme. Pass a `nonce`
  if you use a Content-Security-Policy.

      <.theme_script nonce={@csp_nonce} />
  """
  attr :nonce, :string, default: nil

  def theme_script(assigns) do
    ~H"""
    <script nonce={@nonce}>
      (function(){try{var r=document.documentElement,t=localStorage.getItem("sl-theme");if(t==="light"||t==="dark"){r.setAttribute("data-theme",t)}["palette","dark","contrast","density","radius"].forEach(function(k){var v=localStorage.getItem("sl-"+k);if(v){r.setAttribute("data-"+k,v)}})}catch(e){}})();
    </script>
    """
  end

  @doc """
  A three-way theme toggle (system / light / dark) rendered as a segmented
  radio group. Entirely client-owned; the server never needs to know.

      <.theme_toggle id="theme" />
  """
  attr :id, :string, default: "sl-theme-toggle"
  attr :class, :any, default: nil
  attr :rest, :global

  def theme_toggle(assigns) do
    ~H"""
    <fieldset
      id={@id}
      class={[@class, "sl-theme-toggle"]}
      phx-hook="SlThemeToggle"
      phx-update="ignore"
      {@rest}
    >
      <legend>{t("Theme")}</legend>
      <label :for={{value, label, icon} <- options()}>
        <input type="radio" name={"#{@id}-theme"} value={value} checked={value == "system"} />
        <.icon name={icon} />
        <span class="sl-visually-hidden">{label}</span>
      </label>
    </fieldset>
    """
  end

  defp options do
    [
      {"system", t("System"), "computer"},
      {"light", t("Light"), "sun"},
      {"dark", t("Dark"), "moon"}
    ]
  end
end
