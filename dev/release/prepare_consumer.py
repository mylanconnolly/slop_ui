"""Configure a freshly generated Phoenix 1.8 app for the release smoke test.

Run after extracting the Hex archive into APP/deps/slop_ui.
"""
import sys
from pathlib import Path

root = Path(sys.argv[1])
def edit(name, old, new):
    path = root / name
    source = path.read_text()
    assert old in source, f'Generator layout changed: {name}'
    path.write_text(source.replace(old, new, 1))

edit('mix.exs', '      {:phoenix,', '      {:slop_ui, path: "deps/slop_ui"},\n      {:phoenix,')
edit('lib/release_consumer_web.ex', 'import ReleaseConsumerWeb.CoreComponents',
     'import ReleaseConsumerWeb.CoreComponents, except: [button: 1, input: 1, table: 1]\n      use SlopUI')
edit('assets/js/app.js', 'import "phoenix_html"', 'import "phoenix_html"\nimport {hooks as slopHooks} from "slop_ui"')
edit('assets/js/app.js', 'hooks: {...colocatedHooks}', 'hooks: {...colocatedHooks, ...slopHooks}')
(root / 'assets/css').mkdir(exist_ok=True)
(root / 'assets/css/app.css').write_text('@import "slop_ui/css";\n')
edit('config/config.exs', 'js/app.js --bundle', 'js/app.js css/app.css --bundle')
edit('config/config.exs', '--outdir=../priv/static/assets/js', '--outdir=../priv/static/assets')
edit('lib/release_consumer_web/components/layouts/root.html.heex',
     '    <link phx-track-static rel="stylesheet"', '    <.theme_script />\n    <link phx-track-static rel="stylesheet"')
(root / 'lib/release_consumer_web/live').mkdir(exist_ok=True)
(root / 'lib/release_consumer_web/live/install_live.ex').write_text('''defmodule ReleaseConsumerWeb.InstallLive do
  use ReleaseConsumerWeb, :live_view
  def render(assigns) do
    ~H"""
    <.button color="accent" phx-click={SlopJS.open_dialog("#confirm")}>Open</.button>
    <.dialog id="confirm">
      <:title>Installation check</:title>
      <form method="dialog"><.button type="submit">Cancel</.button></form>
    </.dialog>
    <.input id="email" name="email" type="email" label="Email" required />
    <.select id="role" name="role" label="Role" options={~w(admin member)} />
    """
  end
end
''')
edit('lib/release_consumer_web/router.ex', '    get "/", PageController, :home',
     '    get "/", PageController, :home\n    live "/install", InstallLive')
(root / 'test/release_consumer_web/install_test.exs').write_text('''defmodule ReleaseConsumerWeb.InstallTest do
  use ReleaseConsumerWeb.ConnCase
  import Phoenix.LiveViewTest

  test "library renders in a real LiveView without optional or dev dependencies", %{conn: conn} do
    refute Code.ensure_loaded?(MDEx)
    refute Code.ensure_loaded?(Lumis)
    refute Code.ensure_loaded?(ExDoc)
    refute Code.ensure_loaded?(SlopUI.Sink.Live)
    {:ok, view, html} = live(conn, "/install")
    assert html =~ "Installation check"
    assert has_element?(view, "button.sl-button")
    assert has_element?(view, "input#email[required]")
    assert has_element?(view, "[phx-hook=SlSelect]")
    assert has_element?(view, "form[method=dialog] button[type=submit]")
  end
end
''')
print('Consumer configured with documented imports, hooks, styles, and root theme script')
