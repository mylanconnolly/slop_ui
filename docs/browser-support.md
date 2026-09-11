# Browser support

Verified against MDN browser-compat-data, web-features (Baseline) and caniuse
on 2026-09-10. Stable browsers at that date: Chrome 151, Firefox 155,
Safari 26.6.

Support floor: features that are Baseline (newly or widely available). Anything
below that is used only as a progressive enhancement behind `@supports`, or
gets a JavaScript fallback in the hook.

## Used freely (Baseline)

| Feature | Chrome | Safari | Firefox | Baseline |
|---|---|---|---|---|
| `@layer` | 99 | 15.4 | 97 | Widely |
| CSS nesting | 120 | 17.2 | 117 | Widely |
| `light-dark()` | 123 | 17.5 | 120 | Newly 2024-05 |
| Relative color syntax | 125 | 18 | 128 | Newly 2024-09 |
| `oklch()`, `color-mix()` | 111 | 16.2 | 113 | Widely |
| `@property` | 85 | 16.4 | 128 | Newly 2024-07 |
| `@starting-style`, `transition-behavior: allow-discrete` | 117 | 17.5 | 129 | Newly 2024-08 |
| `popover` attribute | 114 | 17 | 125 | Newly 2025-01 |
| `<dialog>`, `requestClose()` | 37 / 134 | 15.4 / 18.4 | 98 / 139 | Widely / Newly |
| `<details name>` | 120 | 17.2 | 130 | Newly 2024-09 |
| `:user-invalid`, `:has()`, `inert`, `:focus-visible` | — | — | — | Widely |
| Container size queries | 105 | 16 | 110 | Widely |
| `scrollbar-gutter` | 94 | 18.2 | 97 | Newly 2024-12 |
| `text-wrap: balance` | 114 | 17.5 | 121 | Newly 2024-05 |
| `field-sizing: content` | 123 | 26.2 | 152 | Newly 2026-06 |
| `@scope` | 118 | 17.4 (full 26.4) | 146 | Newly 2026-03 |

## Enhancement only, with fallback

| Feature | Gap | What we do |
|---|---|---|
| CSS anchor positioning | In all three stable engines (Firefox since 147, Jan 2026) but not yet Baseline; Firefox can't transition anchored insets; `position-anchor` initial value differed before Chrome 151 / Firefox 151 / Safari 27 | Wrapped in `@supports (anchor-name: none)`; `position-anchor` always set explicitly; the menu and tooltip hooks compute a fixed position when unsupported |
| `<dialog closedby>` | No Safari | Dialog hook adds backdrop-click light dismiss when `closedBy` is absent |
| `popover="hint"` | No Safari | Tooltips use `popover="manual"` |
| `interpolate-size` / `calc-size()` | Chrome only | Not used; height-to-auto uses the grid `0fr → 1fr` technique |
| `appearance: base-select` | Chrome, Safari 27+ only | Not used yet; native select is styled with `appearance: none` |
| `text-wrap: pretty` | No Firefox | Applied to paragraphs; Firefox falls back to normal wrapping |
| `@supports at-rule()` | Chrome only | Not used; `@scope` blocks are written so dropping them degrades gracefully |
| `dialog` `toggle` event | Chrome 137+, Safari 26+, Firefox 145+ | Dialog hook listens to both `close` and `toggle` and dedupes |
| CSS `if()` | Chrome only | Not used |
