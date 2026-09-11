defmodule SlopUITest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "button renders variant, color and size as data attributes" do
    html =
      render_component(&button/1,
        variant: "soft",
        color: "accent",
        size: "sm",
        inner_block: [%{inner_block: fn _, _ -> "Save" end}]
      )

    assert html =~ ~r/class="sl-button ?"/
    assert html =~ ~s(data-variant="soft")
    assert html =~ ~s(data-color="accent")
    assert html =~ ~s(data-size="sm")
    assert html =~ ~s(type="button")
  end

  test "loading button is busy and aria-disabled with literal true" do
    html =
      render_component(&button/1,
        loading: true,
        inner_block: [%{inner_block: fn _, _ -> "Save" end}]
      )

    assert html =~ ~s(aria-busy="true")
    assert html =~ ~s(aria-disabled="true")
    assert html =~ "data-loading"
  end

  test "input wires description and errors via aria-describedby" do
    html =
      render_component(&input/1,
        id: "email",
        name: "email",
        value: "",
        label: "Email",
        description: "Never shared",
        errors: ["is invalid"]
      )

    assert html =~ ~s(aria-invalid="true")
    assert html =~ ~s(aria-describedby="email-description email-error")
    assert html =~ ~r/<label for="email" class="sl-label ?"/
    assert html =~ ~s(id="email-error")
  end

  test "dialog carries labelling and hook attributes" do
    html =
      render_component(&dialog/1,
        id: "d",
        title: [%{inner_block: fn _, _ -> "Title" end}],
        inner_block: [%{inner_block: fn _, _ -> "Body" end}]
      )

    assert html =~ ~s(phx-hook="SlDialog")
    assert html =~ ~s(aria-labelledby="d-title")
    assert html =~ ~s(closedby="any")
    assert html =~ ~s(<form method="dialog">)
  end

  test "translate_error interpolates bindings by default" do
    assert SlopUI.translate_error({"must be at least %{count}", count: 3}) == "must be at least 3"
  end

  test "anchor_name sanitises ids into dashed idents" do
    assert SlopUI.anchor_name("user.menu:1") == "--sl-user-menu-1"
  end
end

defmodule SlopUI.BatchTwoTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  defp slot(text), do: [%{inner_block: fn _, _ -> text end}]

  test "tabs render ARIA relationships and hidden panels" do
    html =
      render_component(&tabs/1,
        id: "t",
        default: "b",
        tab: [
          %{value: "a", inner_block: fn _, _ -> "A" end},
          %{value: "b", inner_block: fn _, _ -> "B" end}
        ],
        panel: [
          %{value: "a", inner_block: fn _, _ -> "PA" end},
          %{value: "b", inner_block: fn _, _ -> "PB" end}
        ]
      )

    assert html =~ ~s(role="tablist")
    assert html =~ ~s(id="t-tab-a" class="sl-tab" aria-selected="false" aria-controls="t-panel-a")
    assert html =~ ~s(id="t-tab-b" class="sl-tab" aria-selected="true")

    assert html =~
             ~s(id="t-panel-a" class="sl-tabpanel" aria-labelledby="t-tab-a" tabindex="0" hidden)

    refute html =~
             ~s(id="t-panel-b" class="sl-tabpanel" aria-labelledby="t-tab-b" tabindex="0" hidden)

    refute html =~ "data-controlled"
  end

  test "accordion uses details with a shared name when exclusive" do
    html =
      render_component(&accordion/1,
        id: "faq",
        exclusive: true,
        item: [%{title: "Q", open: true, inner_block: fn _, _ -> "A" end}]
      )

    assert html =~ ~s(<details id="faq-0" class="sl-accordion-item" name="faq" open>)
    assert html =~ ~s(<summary class="sl-accordion-trigger">)
  end

  test "toaster renders flash as toasts with clear-flash dismiss" do
    html = render_component(&toaster/1, flash: %{"info" => "Saved"})
    assert html =~ ~s(role="status")
    assert html =~ "Saved"
    assert html =~ "lv:clear-flash"
    assert html =~ ~s(phx-update="ignore")
  end

  test "table renders sortable headers with aria-sort" do
    html =
      render_component(&table/1,
        id: "t",
        rows: [%{n: "a"}],
        sorted: {:n, :desc},
        col: [%{label: "N", sort: "n", inner_block: fn _, row -> row.n end}]
      )

    assert html =~ ~s(aria-sort="descending")
    assert html =~ ~s(phx-value-dir="asc")
  end

  test "pagination collapses ranges and marks the current page" do
    html = render_component(&pagination/1, page: 7, total_pages: 20, path: &"/p?page=#{&1}")
    assert html =~ ~s(aria-current="page")
    assert html =~ "…"
    assert html =~ ~s(href="/p?page=8")
    refute html =~ ~s(href="/p?page=15")
  end

  test "avatar falls back to initials with a stable hue and labels status" do
    html = render_component(&avatar/1, name: "Ada Lovelace", status: "online")
    assert html =~ ">AL<"
    assert html =~ ~s(aria-label="Ada Lovelace, online")
    assert html =~ ~s(style="--_hue: #{:erlang.phash2("Ada Lovelace", 360)}")
    assert html =~ ~s(class="sl-avatar-status" data-status="online")

    assert render_component(&avatar/1, name: "Ada Lovelace") ==
             render_component(&avatar/1, name: "Ada Lovelace")
  end

  test "avatar with src still renders initials underneath for fallback" do
    html = render_component(&avatar/1, name: "Ada Lovelace", src: "/a.png")
    assert html =~ ~s(<img src="/a.png" alt="" loading="lazy" decoding="async">)
    assert html =~ ">AL<"
  end

  test "avatar group renders an overflow marker" do
    html =
      render_component(&avatar_group/1,
        overflow: 4,
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      )

    assert html =~ ~s(aria-label="4 more")
    assert html =~ "+4"
  end

  test "progress exposes value and indeterminate state" do
    assert render_component(&progress/1, value: 40) =~ ~s(aria-valuenow="40")
    assert render_component(&progress/1, []) =~ "data-indeterminate"
  end

  test "sheet reuses the dialog hook with a side" do
    html = render_component(&sheet/1, id: "s", side: "left", title: slot("T"))
    assert html =~ ~r/class="sl-sheet ?"/
    assert html =~ ~s(data-side="left")
    assert html =~ ~s(phx-hook="SlDialog")
  end
end

defmodule SlopUI.SelectTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "select renders a hidden native select with the selection and an ARIA combobox trigger" do
    form = Phoenix.Component.to_form(%{"role" => "editor"}, as: :pick)

    html =
      render_component(&select/1,
        field: form[:role],
        label: "Role",
        options: [{"Admin", "admin"}, {"Editor", "editor"}]
      )

    assert html =~
             ~s(<select id="pick_role-native" name="pick[role]" hidden tabindex="-1" aria-hidden="true">)

    assert html =~ ~r{<option value="editor" selected>\s*Editor\s*</option>}
    assert html =~ ~s(role="combobox")
    assert html =~ ~s(aria-haspopup="listbox")
    assert html =~ ~s(aria-labelledby="pick_role-label")
    assert html =~ ~s(<label id="pick_role-label" for="pick_role-trigger")
    assert html =~ ~s(role="option" class="sl-option" data-value="editor" aria-selected="true")
    assert html =~ ~s(phx-hook="SlSelect")
    refute html =~ "<button"
  end

  test "multiple select renders chips and a multiple native select" do
    html =
      render_component(&select/1, name: "tags[]", value: ["a"], options: ~w(a b), multiple: true)

    assert html =~ ~s(name="tags[]" multiple)
    assert html =~ ~s(class="sl-chip" data-value="a")
    assert html =~ ~s(aria-multiselectable="true")
    assert html =~ ~s(id="tags_")
  end

  test "combobox renders hidden value, editable combobox input, and listbox" do
    html =
      render_component(&combobox/1,
        name: "country",
        value: "fr",
        options: [{"France", "fr"}, {"Spain", "es"}]
      )

    assert html =~ ~s(<input type="hidden" id="country-value" name="country" value="fr">)
    assert html =~ ~s(role="combobox")
    assert html =~ ~s(aria-autocomplete="list")
    assert html =~ ~s(value="France")
    assert html =~ ~s(popover="manual")
    assert html =~ ~s(data-value="fr" data-label="France" aria-selected="true")
  end

  test "server-filtered combobox names its text input separately" do
    html = render_component(&combobox/1, name: "city", options: [], on_search: "search")
    assert html =~ ~s(data-on-search="search")
    assert html =~ ~s(name="city_query")
  end
end

defmodule SlopUI.TooltipTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "tooltip trigger anchors with a real box and describes the trigger" do
    html =
      render_component(&tooltip/1,
        id: "t",
        text: "Help",
        inner_block: [%{inner_block: fn _, _ -> "?" end}]
      )

    assert html =~ ~s(style="anchor-name: --sl-t")
    refute html =~ "display:contents"
    assert html =~ ~s(aria-describedby="t-tip")
    assert html =~ ~s(id="t-tip" role="tooltip" popover="manual")
    assert html =~ ~s(style="--sl-anchor: --sl-t")
  end
end

defmodule SlopUI.PhaseOneTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  defp slot(text), do: [%{inner_block: fn _, _ -> text end}]

  test "popover wires trigger and panel with anchor names" do
    html =
      render_component(&popover/1,
        id: "p",
        title: "T",
        trigger: slot("Open"),
        inner_block: slot("Body")
      )

    assert html =~ ~s(popovertarget="p-panel")
    assert html =~ ~s(popover="auto" role="dialog" aria-labelledby="p-title")
    assert html =~ ~s(style="anchor-name: --sl-p")
    assert html =~ ~s(phx-hook="SlPopover")
  end

  test "radio group renders a fieldset of radios with descriptions" do
    html =
      render_component(&radio_group/1,
        name: "plan",
        value: "pro",
        label: "Plan",
        variant: "cards",
        options: [%{label: "Pro", value: "pro", description: "Teams"}, {"Free", "free"}]
      )

    assert html =~ ~s(<legend>)
    assert html =~ ~s(data-variant="cards")
    assert html =~ ~r{type="radio" id="plan-0" name="plan" value="pro" checked}
    assert html =~ ~s(class="sl-choice-description">Teams<)
  end

  test "checkbox group sends a hidden empty value and array name" do
    html =
      render_component(&checkbox_group/1,
        name: "tags[]",
        value: ["a"],
        label: "Tags",
        options: ~w(a b)
      )

    assert html =~ ~s(<input type="hidden" name="tags[]" value="">)
    assert html =~ ~r{type="checkbox" id="tags_-0" name="tags\[\]" value="a" checked}
  end

  test "input adornments wrap the control in an input group" do
    html =
      render_component(&input/1,
        name: "price",
        value: "",
        prefix: slot("$"),
        suffix: [%{interactive: true, inner_block: fn _, _ -> "x" end}]
      )

    assert html =~ ~s(class="sl-input-group")
    assert html =~ ~s(class="sl-input-adornment">$<)
    assert html =~ ~s(class="sl-input-adornment" data-interactive>)
    refute render_component(&input/1, name: "plain", value: "") =~ "sl-input-group"
  end

  test "toggle and toggle group" do
    assert render_component(&toggle/1, pressed: true, inner_block: slot("B")) =~
             ~s(aria-pressed="true")

    html =
      render_component(&toggle_group/1,
        name: "align",
        value: "left",
        label: "Align",
        option: [
          %{value: "left", inner_block: fn _, _ -> "L" end},
          %{value: "right", inner_block: fn _, _ -> "R" end}
        ]
      )

    assert html =~ ~s(<legend>Align</legend>)
    assert html =~ ~r{type="radio" id="align-0" name="align" value="left" checked}
  end

  test "alert dialog is an alertdialog with cancel focused and confirm that closes" do
    html =
      render_component(&alert_dialog/1,
        id: "d",
        title: "Sure?",
        on_confirm: Phoenix.LiveView.JS.push("go")
      )

    assert html =~ ~s(role="alertdialog")
    assert html =~ ~s(closedby="closerequest")
    assert html =~ ~s(autofocus)
    assert html =~ ~s(&quot;push&quot;,{&quot;event&quot;:&quot;go&quot;})
    assert html =~ ~s(sl:close)
  end

  test "slider computes the fill percentage and readout" do
    html = render_component(&slider/1, name: "v", value: 25, min: 0, max: 50, format: "%v%")
    assert html =~ ~s(style="--_pct: 50.0%")
    assert html =~ ~s(<output for="v">25%</output>)
  end

  test "number input renders steppers around a native number input" do
    html = render_component(&number_input/1, name: "qty", value: 2, min: 1, max: 5)
    assert html =~ ~s(data-sl-step="down")
    assert html =~ ~s(data-sl-step="up")
    assert html =~ ~r{type="number" id="qty" name="qty" value="2" min="1" max="5" step="1"}
  end

  test "structure components render their landmarks" do
    assert render_component(&page_header/1, title: "T", actions: slot("A")) =~
             ~s(<h1 class="sl-page-title">T</h1>)

    assert render_component(&empty_state/1, title: "Nothing") =~
             ~s(class="sl-empty-state-title">Nothing<)

    html =
      render_component(&description_list/1,
        divider: true,
        item: [%{label: "K", inner_block: fn _, _ -> "V" end}]
      )

    assert html =~ ~s(<dt>K</dt>)
    assert html =~ ~s(<dd>V</dd>)
  end
end

defmodule SlopUI.PhaseTwoTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "command palette renders a labelled dialog with combobox input and grouped options" do
    html =
      render_component(&command/1,
        id: "cmd",
        group: [%{label: "Nav", inner_block: fn _, _ -> "" end}]
      )

    assert html =~ ~s(phx-hook="SlCommand")
    assert html =~ ~s(data-shortcut="k")

    assert html =~
             ~s(role="combobox" aria-autocomplete="list" aria-expanded="true" aria-controls="cmd-list")

    assert html =~ ~s(role="group" aria-labelledby="cmd-group-0")
  end

  test "command items render as option buttons or links with shortcuts" do
    html =
      render_component(&command_item/1,
        shortcut: "⌘ N",
        hint: "New",
        inner_block: [%{inner_block: fn _, _ -> "New" end}]
      )

    assert html =~ ~s(<button type="button" role="option" class="sl-command-item")
    assert html =~ ~s(<kbd class="sl-kbd">⌘</kbd>)

    link =
      render_component(&command_item/1,
        navigate: "/x",
        inner_block: [%{inner_block: fn _, _ -> "Go" end}]
      )

    assert link =~ ~s(href="/x")
    assert link =~ ~s(role="option")
  end

  test "upload errors translate with defaults" do
    assert SlopUI.translate_upload_error(:too_large) == "File is too large"
    assert SlopUI.translate_upload_error(:not_accepted) == "File type is not accepted"
  end
end

defmodule SlopUI.DatePickerTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "date picker renders a native date input with ISO values and a calendar popover" do
    html =
      render_component(&date_picker/1,
        name: "due",
        value: ~D[2026-09-11],
        min: ~D[2026-09-01],
        label: "Due"
      )

    assert html =~ ~r{<input type="date" id="due" name="due" value="2026-09-11" min="2026-09-01"}
    assert html =~ ~s(phx-hook="SlDatePicker")
    assert html =~ ~s(popovertarget="due-calendar")
    assert html =~ ~s(id="due-calendar" popover role="dialog")
    assert html =~ ~s(style="--sl-anchor: --sl-due")
  end

  test "date range picker renders two inputs bounded by each other" do
    html =
      render_component(&date_range_picker/1,
        id: "trip",
        from_name: "from",
        to_name: "to",
        from_value: "2026-10-01",
        to_value: "2026-10-07"
      )

    assert html =~ ~r{name="from" value="2026-10-01" min="" max="2026-10-07"} or
             html =~ ~r{name="from" value="2026-10-01" max="2026-10-07"}

    assert html =~ ~r{id="trip-end" name="to" value="2026-10-07" min="2026-10-01"}
    assert html =~ "data-range"
  end
end

defmodule SlopUI.ExtrasTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  defp slot(text), do: [%{inner_block: fn _, _ -> text end}]

  test "pin input renders one box per character plus a hidden combined value" do
    html = render_component(&pin_input/1, name: "code", value: "12", length: 4)
    assert html =~ ~s(<input type="hidden" name="code" value="12">)
    assert length(Regex.scan(~r/maxlength="1"/, html)) == 4
    assert html =~ ~s(autocomplete="one-time-code")
    assert html =~ ~s(phx-hook="SlPinInput")
  end

  test "tag input renders chips with hidden inputs and an empty sentinel" do
    html = render_component(&tag_input/1, name: "tags[]", value: ["a", "b"])
    assert html =~ ~s(<input type="hidden" name="tags[]" value="">)
    assert html =~ ~s(<input type="hidden" name="tags[]" value="a">)
    assert html =~ ~s(class="sl-chip" data-value="b")
  end

  test "rating renders radios or a static image" do
    html = render_component(&rating/1, name: "stars", value: 3, label: "Rate")
    assert html =~ ~s(<legend>Rate</legend>)
    assert html =~ ~r{type="radio" name="stars" value="3" checked}
    ro = render_component(&rating/1, value: 4, readonly: true, label: "Avg")
    assert ro =~ ~s(role="img" aria-label="Avg: 4 of 5")
    assert length(Regex.scan(~r/data-filled/, ro)) == 4
  end

  test "stepper marks complete, current and upcoming" do
    html =
      render_component(&stepper/1,
        current: 2,
        step: [%{title: "A"}, %{title: "B"}, %{title: "C"}]
      )

    assert html =~ ~s(data-state="complete")
    assert html =~ ~s(data-state="current" aria-current="step")
    assert html =~ ~s(data-state="upcoming")
  end

  test "timeline, stat, collapsible and copy button render" do
    assert render_component(&timeline/1,
             item: [
               %{title: "T", time: "now", color: "success", inner_block: fn _, _ -> "body" end}
             ]
           ) =~ ~s(data-color="success")

    assert render_component(&stat/1, label: "L", value: "1", delta: "+1", trend: "up") =~
             ~s(data-trend="up")

    html =
      render_component(&collapsible/1, id: "c", trigger: slot("More"), inner_block: slot("Body"))

    assert html =~ ~s(<details id="c" class="sl-collapsible">)
    assert render_component(&copy_button/1, value: "x") =~ ~s(phx-hook="SlCopy")
  end
end

defmodule SlopUI.I18nTest do
  use ExUnit.Case
  import Phoenix.LiveViewTest
  use SlopUI

  defmodule Translator do
    def translate(msgid, bindings), do: "[#{msgid}|#{inspect(Map.to_list(bindings))}]"
  end

  test "defaults to the library backend (English msgids)" do
    html = render_component(&dialog/1, id: "d")
    assert html =~ ~s(aria-label="Close")
    assert render_component(&spinner/1, []) =~ ~s(aria-label="Loading")
  end

  test "a configured translator function receives msgid and bindings" do
    Application.put_env(:slop_ui, :translator, {Translator, :translate})

    try do
      assert render_component(&dialog/1, id: "d") =~ ~s(aria-label="[Close|[]]")
      html = render_component(&tag_input/1, name: "t[]", value: ["a"])
      assert html =~ ~s(aria-label="[Remove %{label}|[label: &quot;a&quot;]]")
    after
      Application.delete_env(:slop_ui, :translator)
    end
  end

  test "hooks receive translated labels via data attributes" do
    html = render_component(&date_picker/1, name: "d", value: nil)
    assert html =~ ~s(data-label-prev="Previous month")
    assert render_component(&toaster/1, flash: %{}) =~ ~s(data-label-dismiss="Dismiss")
  end
end

defmodule SlopUI.SubmenuAndMultiComboboxTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "menu_sub renders a submenu item with its own anchored menu" do
    html =
      render_component(&menu_sub/1,
        id: "share",
        label: "Share",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      )

    assert html =~ ~s(role="menuitem")
    assert html =~ ~s(aria-haspopup="menu")
    assert html =~ ~s(popovertarget="share-list")
    assert html =~ ~s(data-sl-submenu)

    assert html =~
             ~s(id="share-list" popover role="menu" tabindex="-1" class="sl-menu-list" data-placement="right-start")

    assert html =~ ~s(style="--sl-anchor: --sl-share")
  end

  test "multiple combobox renders chips, hidden name[] inputs, and a multiselectable listbox" do
    html =
      render_component(&combobox/1,
        name: "langs[]",
        value: ["fr", "es"],
        multiple: true,
        options: [{"French", "fr"}, {"Spanish", "es"}, {"German", "de"}]
      )

    assert html =~ ~s(<input type="hidden" name="langs[]" value="">)
    assert html =~ ~s(class="sl-chip" data-value="fr")
    assert html =~ ~s(<input type="hidden" name="langs[]" value="es">)
    assert html =~ ~s(aria-multiselectable="true")
    assert html =~ ~s(data-value="fr" data-label="French" aria-selected="true")
    assert html =~ ~s(data-value="de" data-label="German" aria-selected="false")
    assert html =~ ~s(data-multiple)
    refute html =~ ~s(id="langs_-value")
  end
end

defmodule SlopUI.MarkdownTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "renders GFM into a prose container and sanitizes by default" do
    html =
      render_component(&markdown/1,
        text: "# T\n\n- [x] done\n\n<script>x()</script>\n\n| a |\n|---|\n| 1 |"
      )

    assert html =~ ~s(class="sl-prose")
    assert html =~ "<h1>T</h1>"
    assert html =~ ~s(<input type="checkbox" checked="" disabled="">)
    assert html =~ "<table>"
    refute html =~ "<script"
  end

  test "unsafe keeps raw HTML but sanitization still strips dangerous bits" do
    html =
      render_component(&markdown/1,
        text: ~s|<mark>hi</mark> <a href="#" onclick="x()">l</a>|,
        unsafe: true
      )

    assert html =~ "<mark>hi</mark>"
    refute html =~ "onclick"
  end
end

defmodule SlopUI.ShellTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  defp slot(text), do: [%{inner_block: fn _, _ -> text end}]

  test "app shell renders sidebar twice (column + sheet), a topbar with toggle, and main" do
    html =
      render_component(&app_shell/1,
        id: "app",
        sidebar: slot("SIDE"),
        topbar: slot("TOP"),
        inner_block: slot("MAIN")
      )

    assert length(Regex.scan(~r/SIDE/, html)) == 2
    assert html =~ ~s(class="sl-sheet sl-sidebar-sheet")
    assert html =~ ~s(class="sl-button sl-topbar-toggle")
    assert html =~ ~s(<main id="app-main" class="sl-app-main" data-width="default" tabindex="-1">)
    assert html =~ ~s(<a href="#app-main" class="sl-skip-link">Skip to content</a>)
  end

  test "nav item marks the current page and renders a badge" do
    html =
      render_component(&nav_item/1,
        navigate: "/x",
        current: true,
        badge: "3",
        inner_block: slot("Inbox")
      )

    assert html =~ ~s(aria-current="page")
    assert html =~ ~s(class="sl-badge" data-size="sm" data-color="neutral">3<)
  end

  test "indicator caps counts and labels the marker" do
    html = render_component(&indicator/1, count: 120, label: "many", inner_block: slot("x"))
    assert html =~ ~s(aria-label="many">99+<)
    dot = render_component(&indicator/1, dot: true, inner_block: slot("x"))
    assert dot =~ ~s(aria-hidden="true")
  end

  test "auth layout has a heading landmark and footer" do
    html =
      render_component(&auth_layout/1, title: "Hi", inner_block: slot("F"), footer: slot("foot"))

    assert html =~ ~s(<h1 class="sl-auth-title">Hi</h1>)
    assert html =~ ~s(class="sl-auth-footer">foot<)
  end

  test "password input renders a reveal toggle" do
    html = render_component(&password_input/1, name: "pw", value: "")
    assert html =~ ~s(type="password")
    assert html =~ ~s(aria-label="Show password" aria-pressed="false" data-sl-reveal)
    assert html =~ ~s(phx-hook="SlPassword")
  end
end

defmodule SlopUI.MarkdownEditorTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "renders toolbar presets, modes, and the textarea" do
    html = render_component(&markdown_editor/1, name: "body", value: "hi", toolbar: "simple")
    assert html =~ ~s(phx-hook="SlMarkdownEditor")
    assert html =~ ~s(role="toolbar")
    assert html =~ ~s(data-sl-tool="bold")
    refute html =~ ~s(data-sl-tool="image"), "image tool needs an upload"
    refute html =~ ~s(data-sl-tool="table"), "simple preset has no table"
    assert html =~ ~s(<textarea id="body" name="body" class="sl-textarea sl-md-textarea")
    assert html =~ ~s(data-sl-mode="preview")
  end

  test "custom tool lists keep order, drop unknown tools, and trim separators" do
    html =
      render_component(&markdown_editor/1,
        name: "b",
        value: "",
        toolbar: ~w(| quote bogus italic | | bold |),
        preview: false,
        fullscreen: false
      )

    tools = Regex.scan(~r/data-sl-tool="(\w+)"/, html) |> Enum.map(fn [_, t] -> t end)
    assert tools == ["quote", "italic", "bold"]
    assert length(Regex.scan(~r/sl-md-sep/, html)) == 1
    refute html =~ "sl-md-modes"
  end
end

defmodule SlopUI.StepperPulseTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  use SlopUI

  test "pulse is opt-in" do
    steps = [%{title: "A"}, %{title: "B"}]
    refute render_component(&stepper/1, current: 1, step: steps) =~ "data-pulse"
    assert render_component(&stepper/1, current: 1, pulse: true, step: steps) =~ "data-pulse"
  end
end
