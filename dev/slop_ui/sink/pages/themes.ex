defmodule SlopUI.Sink.Pages.Themes do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers
  import SlopUI.Icons

  def components,
    do: [{SlopUI.Components.Theme, :theme_toggle}, {SlopUI.Components.Theme, :theme_script}]

  @presets ~w(warm cool slate forest ocean mono)

  def render(assigns) do
    assigns = assign(assigns, presets: @presets)

    ~H"""
    <.example
      title="Presets"
      description="Each preset changes only hues and chroma; lightness stays as audited. Set data-palette on <html> or any subtree. The header selects persist your choice."
      code={~S|<html data-palette="slate" data-density="compact" data-radius="lg" data-dark="black">|}
    >
      <.grid min="17rem">
        <div
          :for={p <- @presets}
          data-palette={p}
          class="sink-builder-preview"
          style="padding: var(--sl-space-4)"
        >
          <.stack gap="sm">
            <.cluster justify="between">
              <strong>{p}</strong>
              <.badge color="accent" dot>accent</.badge>
            </.cluster>
            <.cluster gap="sm">
              <.button size="sm" color="accent">Primary</.button>
              <.button size="sm">Neutral</.button>
              <.button size="sm" variant="outline">Outline</.button>
            </.cluster>
            <.cluster gap="xs">
              <.badge :for={c <- ~w(success warning danger info)} color={c}>{c}</.badge>
            </.cluster>
            <.input name={"preset-#{p}"} value="" placeholder="Input" size="sm" />
          </.stack>
        </div>
      </.grid>
    </.example>

    <.example
      title="Density and radius"
      description="data-density scales spacing and control heights (targets never drop below 24px); data-radius scales every corner."
    >
      <.grid min="14rem">
        <div
          :for={{d, r} <- [{"compact", "none"}, {"default", "default"}, {"comfortable", "full"}]}
          data-density={d != "default" && d}
          data-radius={r != "default" && r}
          class="sink-builder-preview"
          style="padding: var(--sl-space-4)"
        >
          <.stack gap="sm">
            <strong>density: {d} · radius: {r}</strong>
            <.cluster gap="sm">
              <.button color="accent">Save</.button><.button variant="outline">Cancel</.button>
            </.cluster>
            <.input name={"dr-#{d}"} value="" placeholder="Input" />
            <.card padding="sm">
              <.badge color="success" dot>Card</.badge>
            </.card>
          </.stack>
        </div>
      </.grid>
    </.example>

    <.example
      title="Contrast: more and dark: black"
      description="prefers-contrast: more applies automatically; data-contrast=more forces it. data-dark=black drops the dark surfaces to a true-black floor."
    >
      <.grid min="17rem">
        <div data-contrast="more" class="sink-builder-preview">
          <.stack gap="sm">
            <strong>contrast: more</strong>
            <p style="color: var(--sl-color-fg-muted)">
              Muted text is darker, borders stronger, focus ring 3px.
            </p>
            <.input name="cm" value="" placeholder="Placeholder text" />
            <.cluster gap="sm">
              <.button variant="outline">Outline</.button><.badge>Badge</.badge>
            </.cluster>
          </.stack>
        </div>
        <div data-theme="dark" data-dark="black" class="sink-builder-preview">
          <.stack gap="sm">
            <strong>dark: black</strong>
            <.card padding="sm">Surface on a black page</.card>
            <.cluster gap="sm">
              <.button color="accent">Accent</.button><.button variant="outline">Outline</.button>
            </.cluster>
          </.stack>
        </div>
      </.grid>
    </.example>

    <.example
      title="Theme builder"
      description="Drag the hues and chroma; the preview, the audit and the override block update live. The audit runs the same checks as mix sink.audit."
    >
      <div id="builder" class="sink-builder" phx-hook="SinkBuilder" phx-update="ignore">
        <form class="sink-builder-controls" onsubmit="return false">
          <label :for={
            {h, default} <- [
              {"neutral", 70},
              {"accent", 305},
              {"success", 145},
              {"warning", 85},
              {"danger", 20},
              {"info", 240}
            ]
          }>
            <span>{String.capitalize(h)} hue</span>
            <output for={"builder-hue-#{h}"}>{default}</output>
            <input
              type="range"
              id={"builder-hue-#{h}"}
              name={"hue-#{h}"}
              min="0"
              max="359"
              value={default}
              class="sl-slider"
            />
          </label>
          <label :for={{c, default, max} <- [{"neutral", "0.016", "0.05"}, {"accent", "0.18", "0.3"}]}>
            <span>{String.capitalize(c)} chroma</span>
            <output for={"builder-chroma-#{c}"}>{default}</output>
            <input
              type="range"
              id={"builder-chroma-#{c}"}
              name={"chroma-#{c}"}
              min="0"
              max={max}
              step="0.002"
              value={default}
              class="sl-slider"
            />
          </label>
          <label><span>Scheme</span><select name="theme" class="sl-native-select" data-size="sm"><option value="light">
            light
          </option><option value="dark">dark</option></select></label>
          <label><span>Dark variant</span><select name="dark" class="sl-native-select" data-size="sm"><option value="default">
            dim
          </option><option value="black">black</option></select></label>
          <label><span>Contrast</span><select name="contrast" class="sl-native-select" data-size="sm"><option value="default">
            default
          </option><option value="more">more</option></select></label>
          <label><span>Density</span><select name="density" class="sl-native-select" data-size="sm"><option value="default">
            default
          </option><option value="compact">compact</option><option value="comfortable">
            comfortable
          </option></select></label>
          <label><span>Radius</span><select name="radius" class="sl-native-select" data-size="sm"><option value="default">
            default
          </option><option value="none">none</option><option value="sm">sm</option><option value="lg">
            lg
          </option><option value="full">full</option></select></label>
          <.cluster gap="sm">
            <.button type="button" size="sm" variant="outline" data-reset>Reset</.button>
            <.badge data-summary>…</.badge>
          </.cluster>
          <p class="sink-muted">
            min text <strong data-min-text>–</strong>
            · min non-text <strong data-min-nontext>–</strong>
          </p>
        </form>

        <div>
          <div class="sink-builder-preview" data-preview data-theme="light">
            <.stack gap="md">
              <.page_header
                title="Preview"
                description="Every family, in the pairings the audit checks."
                heading_level="h3"
                divider={false}
              >
                <:actions>
                  <.button color="accent"><.icon name="plus" /> Primary</.button><.button variant="outline">Outline</.button>
                </:actions>
              </.page_header>
              <.cluster gap="sm">
                <.button
                  :for={c <- ~w(neutral accent success warning danger info)}
                  color={c}
                  size="sm"
                >{c}</.button>
              </.cluster>
              <.cluster gap="sm">
                <.button
                  :for={c <- ~w(neutral accent success warning danger info)}
                  color={c}
                  size="sm"
                  variant="soft"
                >{c}</.button>
              </.cluster>
              <.grid min="12rem" gap="sm">
                <.alert
                  :for={c <- ~w(accent success warning danger info)}
                  color={c}
                  title={String.capitalize(c)}
                >
                  Soft surface with a <a href="#">link</a>.
                </.alert>
              </.grid>
              <.grid min="12rem" gap="sm">
                <.input name="b1" value="" label="Input" placeholder="Placeholder" />
                <.input name="b2" value="bad" label="Invalid" errors={["is invalid"]} />
                <.select name="b3" value="" label="Select" options={~w(One Two)} />
              </.grid>
              <.card>
                <:header title="Card" description="Muted description text." />
                <.description_list>
                  <:item label="Muted">Body text on a surface</:item>
                  <:item label="Subtle">
                    <span style="color: var(--sl-color-fg-subtle)">Subtle text</span>
                  </:item>
                </.description_list>
              </.card>
            </.stack>
          </div>
          <pre class="sink-builder-output" data-output></pre>
          <h3 style="margin-block: var(--sl-space-6) var(--sl-space-2); font-size: var(--sl-text-lg); font-weight: 600">
            Contrast
          </h3>
          <div class="sl-table-wrap">
            <table class="sl-table" data-density="compact">
              <thead>
                <tr>
                  <th>Pairing</th><th>Colors</th><th data-numeric>Ratio</th><th data-numeric>Min</th><th>
                  </th>
                </tr>
              </thead>
              <tbody data-results></tbody>
            </table>
          </div>
          <h3 style="margin-block: var(--sl-space-6) var(--sl-space-2); font-size: var(--sl-text-lg); font-weight: 600">
            Colour vision: closest semantic pairs (ΔE, ≥15 wanted)
          </h3>
          <div class="sl-table-wrap">
            <table class="sl-table" data-density="compact">
              <thead>
                <tr>
                  <th>Simulation</th><th colspan="3">Closest pairs</th>
                </tr>
              </thead>
              <tbody data-cvd></tbody>
            </table>
          </div>
        </div>
      </div>
    </.example>
    """
  end
end
