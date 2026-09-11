# SlopUI

A semantic, themeable, accessible component library for Phoenix LiveView,
built on modern vanilla CSS. No Tailwind, no utility classes, no build step
beyond the esbuild you already have.

- **Semantic classes.** `sl-button`, `sl-card-title`, `sl-menu-item`. Variants and
  sizes are `data-*` attributes; states are ARIA attributes and native
  pseudo-classes, so accessibility is load-bearing rather than decorative.
- **Cascade layers.** Everything lives under `@layer sl`, so your own CSS wins
  without specificity fights.
- **Theming with tokens.** OKLCH colors, `light-dark()` for automatic light and
  dark schemes, `data-theme` to force one on the page or any subtree, and a
  single `--sl-hue-accent` to rebrand.
- **Native first.** `<dialog>`, the popover API, CSS anchor positioning,
  `@starting-style` animations, `:user-invalid`. Hooks only add what the
  platform lacks (roving focus, typeahead, state sync with LiveView).
- **WCAG-minded.** AA contrast pairings in both schemes, one outline-based
  focus ring, 24px+ targets, reduced-motion and forced-colors support,
  ARIA wiring generated for you.

## Installation

```elixir
def deps do
  [{:slop_ui, "~> 0.1"}]
end
```

Requires Phoenix LiveView 1.1 or later.

In `lib/my_app_web.ex`, inside `html_helpers`, replace the generated
CoreComponents import and add SlopUI:

```elixir
import MyAppWeb.CoreComponents, except: [button: 1, input: 1, table: 1]
use SlopUI
```

These exclusions match Phoenix 1.8. If your CoreComponents defines other
overlapping names (such as `label/1` or `error/1`), exclude those too.

In `assets/css/app.css` (the default Phoenix esbuild config resolves `slop_ui`
via `NODE_PATH=deps`):

```css
@import "slop_ui/css";
```

Make sure your CSS is processed by your asset bundler. With plain esbuild,
include both `js/app.js` and `css/app.css` in its arguments and use
`--outdir=../priv/static/assets` so the output matches Phoenix’s
`/assets/js/app.js` and `/assets/css/app.css` layout links.

In `assets/js/app.js`, merge these hooks with your existing hooks (including
Phoenix’s colocated hooks, if present):

```javascript
import { hooks as slopHooks } from "slop_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...slopHooks },
  params: { _csrf_token: csrfToken },
})
```

In your root layout `<head>`, before the stylesheet, so the persisted theme
applies before first paint:

```heex
<.theme_script />
```

## Usage

```heex
<.button color="accent" phx-click={SlopJS.open_dialog("#confirm")}>Delete</.button>

<.dialog id="confirm" on_close={JS.push("cancelled")}>
  <:title>Delete post?</:title>
  <:description>This cannot be undone.</:description>
  <:footer>
    <form method="dialog"><.button type="submit" variant="outline">Cancel</.button></form>
    <.button color="danger" phx-click="delete">Delete</.button>
  </:footer>
</.dialog>

<.input field={@form[:email]} type="email" label="Email" required />

<.menu id="user-menu" placement="bottom-end">
  <:trigger variant="outline">Account</:trigger>
  <.menu_item navigate={~p"/settings"}>Settings</.menu_item>
  <.menu_separator />
  <.menu_item color="danger" phx-click="logout">Sign out</.menu_item>
</.menu>

<.theme_toggle />
```

## Components

| Group | Components |
|---|---|
| Actions | `button`, `button_group`, `toggle`, `toggle_group`, `copy_button`, `menu` (+ `menu_item`, `menu_sub`, `menu_label`, `menu_separator`), `context_menu`, `command` (⌘K palette) |
| Forms | `input` (text, textarea, select, checkbox, radio, switch… with `prefix`/`suffix` adornments), `password_input`, `label`, `fieldset`, `error`, `radio_group`, `checkbox_group`, `select` (custom, single/multiple), `combobox` (client or server filtered), `slider`, `number_input`, `pin_input`, `tag_input`, `rating`, `color_input`, `date_picker`, `date_range_picker`, `calendar`, `time_picker`, `upload` (LiveView uploads dropzone); `counter` on any text input |
| Overlays | `dialog`, `alert_dialog`, `sheet`, `popover`, `hover_card`, `tooltip`, `toaster` / `toast` |
| Content | `card`, `table` (sortable, selectable rows), `tree`, `carousel`, `accordion`, `collapsible`, `tabs`, `alert`, `badge`, `avatar`, `avatar_group`, `skeleton`, `progress`, `spinner`, `kbd`, `separator`, `description_list`, `stat`, `timeline`, `stepper`, `empty_state` |
| Navigation | `breadcrumbs`, `pagination`, `page_header` |
| Content (cont.) | `markdown` (GFM via the optional `mdex` dependency, rendered into `.sl-prose`), `markdown_editor` (toolbar, shortcuts, preview, image uploads) |
| Shell | `app_shell`, `sidebar`, `nav`, `nav_group`, `nav_item`, `nav_collapsible`, `topbar_end`, `indicator`, `auth_layout` |
| Layout | `stack`, `cluster`, `grid`, `container`, `split_panel`, `scroll_area` |
| Theme | `theme_toggle`, `theme_script` |

Every interactive component follows the matching WAI-ARIA Authoring Practices
pattern and is driven by native platform features first: `<dialog>` for
modals and sheets, the popover API for menus, tooltips and listboxes,
`<details name>` for accordions, and a hidden native `<select>` behind the
custom select so forms and `phx-change` work unchanged.

### Form behavior

`required` prevents empty submission for native inputs, custom selects,
comboboxes, and choice groups. A required checkbox group needs at least one
enabled selection. Combobox validation checks the committed value, not the
search query; with `allow_custom`, free text can become a value. Invalid custom
controls show their validation message and receive focus on the visible control.

`disabled` applies to auxiliary controls and excludes disabled combobox values
from form submission. `readonly` date/time pickers also disable popup selection.
Loading buttons use native `disabled`; a loading navigation button temporarily
renders as a disabled button, then becomes a link again when loading ends.

### Keyboard support

Every component with its own interaction model implements the matching
WAI-ARIA keyboard pattern, and `mix sink.smoke` exercises each one in a real
browser. In short: arrow keys move within menus, tabs, accordions, trees,
listboxes, radio-style groups and calendar grids; Home/End jump to the ends;
Enter/Space activate; Escape closes any overlay and returns focus to what
opened it. Details worth knowing:

- **Tree**: ArrowRight expands or enters a branch, ArrowLeft collapses or goes
  to the parent, `*` expands all siblings, typing jumps to a label.
- **Context menu**: Shift+F10 or the Menu key opens it beside the focused
  element; right-click opens it at the pointer.
- **Calendar and date pickers**: arrows move by day and week, PageUp/PageDown
  by month, Shift+PageUp/PageDown by year, Home/End to the week bounds.
- **Time picker**: Alt+ArrowDown opens the slot list; typing `14` or `9:3`
  jumps to a slot.
- **Split panel**: arrows resize the divider by 1% (Shift for 10%), Home/End
  collapse to the limits, Enter collapses and restores.
- **Carousel**: arrows and Home/End move slides; autoplay pauses on hover and
  focus and has a visible Pause control.
- **App shell**: a "Skip to content" link is the first tab stop and moves
  focus to `<main>`.

### Newer components in brief

- **Tree view.** `<.tree>` with nested `<.tree_item>`s. Selection is
  client-owned unless you pass `selected`; `on_select` receives the item's
  value. Items with `navigate`, `patch` or `href` are real links and work
  without JavaScript. Branches animate; `expanded` and `expanded_all` set the
  initial state.
- **Context menu.** `<.context_menu>` wraps any content and opens its
  `<:menu>` items on right-click or from the keyboard, reusing menu items,
  submenus and separators.
- **Hover card.** `<.hover_card>` shows rich preview content when its
  `<:trigger>` is hovered or focused, after a delay, and stays open while the
  pointer is over the card. Touch taps activate the trigger instead, so keep
  the card supplementary.
- **Calendar.** `<.calendar id="when" name="when" value={@date}
  on_change={JS.push("pick-day")} />` is an always-visible month grid; add
  `range` with `from_name`/`to_name` for a start and end. Hidden inputs carry
  ISO values so it works in forms. `min`/`max` disable days and
  `footer={false}` hides Clear/Today.
- **Time picker.** `<.time_picker field={@form[:starts_at]} step={15}
  min="09:00" max="17:30" />` is a native time input plus a popover of slots,
  formatted for the browser's locale (`hour_cycle="h23"` forces 24h).
- **Table selection.** Add `selectable` for a checkbox column named
  `<id>[]` (override with `select_name`/`row_value`). Pass `selected` and
  `on_select={JS.push("select")}`; the event carries `id`, `ids` (Shift+click
  range) or `all`. The header checkbox reflects all/some/none with a real
  indeterminate state, and sortable headers put `aria-sort` on the `<th>`.
- **Character counter.** Add `counter` to a text input or textarea for a live
  "n / max" readout. With `maxlength` the browser stops input at the limit;
  `enforce={false}` makes it a soft limit that turns red instead. Screen
  readers hear the remaining count after a typing pause.
- **Split panel.** `<.split_panel id="editor" default={40} min={20} max={70}
  storage_key="editor">` with `:primary` and `:secondary` slots. Sizes persist
  under `storage_key`; vertical splits need a `block-size`.
- **Scroll area.** `<.scroll_area label="Changelog" style="max-block-size:
  16rem">` is a named, focusable scroll region with thin scrollbars and edge
  shadows driven by scroll-timeline animations, no JavaScript.
  `orientation="horizontal"` or `"both"`; `shadows={false}` turns shadows off.
- **Carousel.** `<.carousel id="posts" label="Featured" loop>` with `:slide`
  entries is a scroll-snap track with previous/next buttons and dot tabs;
  `per_view` shows several slides, `autoplay={4000}` advances on a timer and
  stays off under reduced motion. The current slide is announced politely.
- **Color input.** `<.color_input field={@form[:brand]} presets={[{"Violet",
  "#7c3aed"}, "#0d9488"]} />` wraps the native color input as a swatch with
  its hex value and an optional preset radio group. The native input stays the
  source of truth, so forms and `phx-change` work unchanged.

## App shell and templates

`app_shell` gives you the page frame: a sidebar that becomes a modal sheet
below 64rem, a sticky topbar, and the main area. `sidebar`, `nav`,
`nav_group`, `nav_item` and `nav_collapsible` build the navigation with
`aria-current` on the active page; `indicator` puts a count or dot on a
button; `auth_layout` centres a sign-in or sign-up panel.

The kitchen sink ships six full-page templates built only from library
components, under `/templates/*`: dashboard, list, detail, settings, sign-in
and sign-up. They're the fastest way to see how the pieces compose, and the
source in `dev/slop_ui/sink/templates/` is meant to be copied.

## Markdown

`<.markdown text={@body} />` renders GitHub-flavoured Markdown through
[MDEx](https://hex.pm/packages/mdex), an optional dependency:

```elixir
{:mdex, "~> 0.13"}
```

Output lands in a `.sl-prose` container, which styles headings, lists, task
lists, tables, blockquotes, code and footnotes from the tokens, so it follows
palette, density and scheme. The result is sanitized by default and raw HTML
is dropped unless you pass `unsafe`. For highlighted code blocks add Lumis
and select the Lumis-enabled MDEx NIF:

```elixir
{:lumis, "~> 0.8"}
config :mdex_native, syntax_highlighter: :lumis
```

`.sl-prose` also works on its own for any HTML you render yourself.

### Markdown editor

`<.markdown_editor field={@form[:body]} toolbar="full" upload={@uploads.images} />`
is a GitHub-style editor: a Markdown textarea with a formatting toolbar
(`"simple"`, `"full"`, or your own list of tools plus a `:tool` slot), keyboard
shortcuts, list continuation and indenting, a Write/Preview switch rendered by
`markdown`, and a fullscreen mode.

Images go through LiveView uploads. Pass an upload declared with
`auto_upload: true` and a `progress` callback; pasting, dropping, or attaching
an image inserts an "Uploading" placeholder, and once your callback has stored
the file it pushes the URL back with `SlopUI.Components.MarkdownEditor.push_image/3`,
which turns the placeholder into `![name](url)`. Storage is yours (local,
S3, anywhere that yields a URL); the module docs carry the full recipe and the
kitchen sink's Editor page runs it end to end.

## Client-side search syntax

The combobox (client mode) and the command palette share one matcher:

- Tokens are separated by spaces and must all match, in any order.
- A token matches the start of any word, or, if it's two or more characters,
  anywhere inside the label. So `u s` finds United States and `gdom` finds
  United Kingdom, while a lone `u` never matches as a substring.
- `"quoted text"` matches literally, spaces included.
- Accents are ignored: `sao` finds São Paulo.
- The best-scoring match is highlighted first, so Enter picks it; word-start
  hits outrank substring hits. Command items also match their `keywords`
  and hint text, without highlighting.

The matcher lives in `assets/js/match.js` and has its own tests: `mix assets.test`.

## Translations

Every built-in string (button labels like "Close" and "Dismiss", calendar
navigation, upload errors, the command palette footer, and so on) goes
through Gettext under the `slop_ui` domain. English is the default. To
translate them in your app, point the library at your backend and seed your
`priv/gettext` with the shipped template:

```elixir
# config/config.exs
config :slop_ui, gettext_backend: MyAppWeb.Gettext
```

```
cp deps/slop_ui/priv/gettext/slop_ui.pot priv/gettext/
mix gettext.merge priv/gettext --locale de
```

Strings then follow `Gettext.get_locale/0` like the rest of your app. Without
Gettext, set `config :slop_ui, translator: {Mod, :fun}`; the function gets
`(msgid, bindings)` and returns a string. Any default label can also be
overridden per call through the component's own attribute.

## Icons

The glyphs the library's own chrome uses (`<.icon name="check" />`, about
fifty of them) are [Phosphor](https://phosphoricons.com) regular-weight icons
vendored into `SlopUI.Icons`, so the library carries no icon dependency
(MIT; see `priv/phosphor/LICENSE`).

For your app's icons, define a module with `use SlopUI.Icons`. SVGs are read
at compile time and embedded, a name that does not exist fails the build with
the closest matches, and editing a file recompiles the module:

```elixir
defmodule MyAppWeb.Icons do
  use SlopUI.Icons,
    sets: [
      phosphor: [weight: :regular, icons: ~w(house users bell)],
      duo: [preset: :phosphor, weight: :duotone, icons: ~w(heart)],
      hero: [style: :outline, icons: ~w(arrow-path)],
      app: [dir: "assets/icons", icons: :all]
    ]
end
```

```heex
<MyAppWeb.Icons.icon name="phosphor-house" />
<MyAppWeb.Icons.icon name="hero-arrow-path" class="sl-icon-lg" />
<MyAppWeb.Icons.icon name="app-logo" aria-label="Acme" />
```

Each set is keyed by its prefix (`prefix: false` drops it). The Phosphor and
Heroicons presets read from git deps that are checked out but never compiled:

```elixir
{:phosphor, github: "phosphor-icons/core", sparse: "assets", depth: 1, app: false, compile: false},
{:heroicons, github: "tailwindlabs/heroicons", sparse: "optimized", depth: 1, app: false, compile: false}
```

Phosphor weights: `:regular`, `:thin`, `:light`, `:bold`, `:fill`, `:duotone`.
Heroicons styles: `:outline`, `:solid`, `:mini`, `:micro`. Any folder of SVGs
works as a custom set; `width`/`height`/`id`/`class` are stripped and black
fills become `currentColor`. Icons render `aria-hidden` unless you pass
`aria-label`, and size with the font (`.sl-icon`, `.sl-icon-sm/lg/xl`).

## Theming

Three tiers: global tokens, component tokens, component rules. Override at
whichever level you need, in your own (unlayered) CSS:

```css
:root {
  --sl-hue-accent: 160;          /* rebrand everything */
  --sl-radius-md: 0.25rem;       /* squarer controls */
}

.sl-button { --sl-button-radius: 9999px; }   /* one component */
```

Theme modes:

- No attribute: follows `prefers-color-scheme`.
- `<html data-theme="dark">`: forced. The `theme_toggle` component and the
  `setTheme()` JS export manage this and persist it in `localStorage`.
- `<aside data-theme="dark">`: any subtree can pin a scheme.

### Presets and appearance axes

Import `slop_ui/assets/css/themes.css` after the main stylesheet to get six
audited colour presets, then set attributes on `<html>` or any subtree:

| Attribute | Values | Effect |
|---|---|---|
| `data-palette` | `warm` (default), `cool`, `slate`, `forest`, `ocean`, `mono` | hue and chroma set; every lightness value stays as audited |
| `data-dark` | `black` | true-black dark surfaces for OLED screens |
| `data-contrast` | `more` | darker secondary text, stronger borders, 3px focus ring; also applied automatically for `prefers-contrast: more` |
| `data-density` | `compact`, `comfortable` | scales spacing and control heights; targets never drop below 24px |
| `data-radius` | `none`, `sm`, `lg`, `full` | scales every corner |

All of these persist through the JS `setPreference(name, value)` export and
are applied before first paint by `theme_script`. To re-theme a subtree with
custom hues, give it `data-palette="custom"` (any name) and override the hue
variables on it: derived tokens are recomputed on any element carrying one of
these attributes.

### Auditing a palette

`mix sink.audit` boots the kitchen sink in headless Chrome and measures every
token pairing for each preset in light and dark, with and without
`data-contrast="more"`. It fails if any text pairing is under 4.5:1, any
non-text pairing under 3:1, or two semantic colours land within ΔE 15 under
simulated protan, deutan or tritan vision. The kitchen sink's Themes page has
a live builder that runs the same audit as you drag the hue sliders and
prints the override block to paste.

## Development

```
mix deps.get
mix dev            # kitchen sink at http://localhost:4000
mix test           # component render tests
mix assets.test    # JavaScript unit tests (search matcher)
mix sink.audit     # palette contrast and colour-vision audit (needs Chrome)
mix sink.smoke     # browser smoke tests for every hook: real clicks and key presses (needs Chrome)
```

The kitchen sink under `dev/` renders every component in every variant, with
a theme toggle, and doubles as the manual accessibility test bed. Its CSS is
deliberately unlayered to prove that consumer styles override the library.

See `docs/browser-support.md` for the feature support matrix and fallbacks.

## Release checks

GitHub Actions runs formatting, compilation, ExUnit and JavaScript tests on
Elixir 1.18/OTP 27 and Elixir 1.20/OTP 29. It also builds docs with warnings
as errors, validates the Hex archive, installs that archive in a fresh
Phoenix app without optional Markdown dependencies, and runs Chrome interaction
and palette-contrast checks. CI does not publish packages.

To run the package installation check locally:

```sh
mix archive.install hex phx_new 1.8.9 --force
bash dev/release/check_consumer.sh
```

The check creates and removes a temporary app, renders a real LiveView, and
bundles both CSS and JavaScript from the archive. It requires Python 3.12+
and network access for fresh dependencies.
