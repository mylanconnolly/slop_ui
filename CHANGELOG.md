# Changelog

## 0.1.1 — 2026-09-28

### Fixed

- `SlDialog` no longer closes a dialog opened with `SlopUI.JS.open_dialog/1` when the server re-renders it — for example on the first `phx-change` keystroke in a form inside the dialog. The hook now acts on `data-open` only when the server changes it, so a dialog the user dismissed is also no longer reopened by an unrelated patch.

## 0.1.0 — 2026-09-11

Initial public release.

- Phoenix LiveView components for actions, forms, overlays, navigation, data display, and application layouts.
- Semantic CSS with cascade layers, light/dark themes, palette presets, density and radius preferences, and accessible focus styles.
- Keyboard interactions and form integration for custom selects, comboboxes, date/time pickers, choice groups, and other interactive controls.
- Optional Markdown rendering and editing through MDEx, plus compile-time SVG icon sets.
- A kitchen sink and six application templates, including responsive sidebar navigation.
- Packaged CSS/JavaScript entry points, Gettext templates, browser-support documentation, and component examples.
