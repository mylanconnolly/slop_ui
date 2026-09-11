defmodule SlopUI.Sink.Live do
  use Phoenix.LiveView, layout: false
  use SlopUI
  alias SlopUI.Sink.Pages

  @pages [
    {"foundation", "Foundation", Pages.Foundation},
    {"themes", "Themes", Pages.Themes},
    {"icons", "Icons", Pages.Icons},
    {"buttons", "Buttons", Pages.Buttons},
    {"badges", "Badges", Pages.Badges},
    {"cards", "Cards", Pages.Cards},
    {"forms", "Forms", Pages.Forms},
    {"alerts", "Alerts", Pages.Alerts},
    {"dialogs", "Dialogs", Pages.Dialogs},
    {"menus", "Menus", Pages.Menus},
    {"tree", "Tree", Pages.Tree},
    {"hover-card", "Hover card", Pages.HoverCard},
    {"tooltips", "Tooltips", Pages.Tooltips},
    {"tabs", "Tabs", Pages.Tabs},
    {"accordion", "Accordion", Pages.Accordion},
    {"toasts", "Toasts", Pages.Toasts},
    {"tables", "Tables", Pages.Tables},
    {"selects", "Selects", Pages.Selects},
    {"choices", "Choices", Pages.Choices},
    {"inputs", "Inputs", Pages.Inputs},
    {"popover", "Popover", Pages.Popover},
    {"structure", "Structure", Pages.Structure},
    {"upload", "Upload", Pages.Upload},
    {"command", "Command", Pages.Command},
    {"dates", "Dates", Pages.Dates},
    {"extras", "Extras", Pages.Extras},
    {"markdown", "Markdown", Pages.Markdown},
    {"editor", "Editor", Pages.Editor},
    {"templates", "Templates", Pages.Templates},
    {"elements", "Elements", Pages.Elements},
    {"layout", "Layout", Pages.Layout},
    {"panels", "Panels", Pages.Panels}
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> allow_upload(:attachments,
       accept: ~w(.png .jpg .jpeg .pdf),
       max_entries: 3,
       max_file_size: 2_000_000,
       auto_upload: true
     )
     |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1, auto_upload: true)
     |> allow_upload(:md_images,
       accept: ~w(.png .jpg .jpeg .gif .webp),
       max_entries: 10,
       max_file_size: 5_000_000,
       auto_upload: true,
       progress: &handle_md_progress/3
     )
     |> assign(
       editor_form: to_form(%{"body" => "", "note" => ""}, as: :editor),
       editor_saved: nil
     )
     |> assign(saved_uploads: [])
     |> assign(
       pages: @pages,
       dialog_open: false,
       tree_selected: nil,
       form: blank_form(),
       flash_alert: true,
       tab: "week",
       users: users(),
       sort: {:name, :asc},
       pick_form:
         to_form(
           %{
             "role" => "",
             "tags" => [],
             "country" => "",
             "city" => "",
             "languages" => ["france"]
           },
           as: :pick
         ),
       cities: Pages.Selects.cities(),
       choice_form:
         to_form(
           %{
             "plan" => "pro",
             "size" => "M",
             "tier" => "pro",
             "channels" => ["Email"],
             "align" => "left",
             "period" => "week",
             "days" => ["Mo", "We"],
             "volume" => "40",
             "qty" => "2",
             "code" => "",
             "tags" => ["elixir", "css"],
             "stars" => "3"
           },
           as: :choice
         ),
       bold: true,
       step: 2,
       date_form:
         to_form(%{"due_on" => "", "starts_on" => "", "ends_on" => "", "at" => "", "slot" => ""},
           as: :dates
         ),
       cal_date: nil,
       cal_range: {nil, nil},
       selected_ids: [2],
       searching: false,
       page_no: 7
     )}
  end

  def handle_params(params, _uri, socket) do
    slug = params["page"] || "foundation"

    socket =
      if p = params["page_no"], do: assign(socket, page_no: String.to_integer(p)), else: socket

    socket = if d = params["doc"], do: assign(socket, tree_selected: d), else: socket

    case List.keyfind(@pages, slug, 0) do
      {^slug, title, mod} ->
        {:noreply, assign(socket, slug: slug, page_title: title, page: mod)}

      nil ->
        {:noreply, push_patch(socket, to: "/")}
    end
  end

  def handle_event("open-dialog", _, socket), do: {:noreply, assign(socket, dialog_open: true)}
  def handle_event("close-dialog", _, socket), do: {:noreply, assign(socket, dialog_open: false)}
  def handle_event("dismiss-alert", _, socket), do: {:noreply, assign(socket, flash_alert: false)}
  def handle_event("reset-alert", _, socket), do: {:noreply, assign(socket, flash_alert: true)}
  def handle_event("tab", %{"tab" => tab}, socket), do: {:noreply, assign(socket, tab: tab)}

  def handle_event("tree-open", %{"value" => v}, socket),
    do: {:noreply, put_flash(socket, :info, "Opened #{v}")}

  def handle_event("flash-info", _, socket),
    do: {:noreply, put_flash(socket, :info, "Profile saved.")}

  def handle_event("flash-error", _, socket),
    do: {:noreply, put_flash(socket, :error, "Could not save profile.")}

  def handle_event("toast", params, socket) do
    color = params["color"] || "neutral"

    {:noreply,
     push_event(socket, "sl:toast", %{
       title: params["title"] || "#{String.capitalize(color)} toast",
       description: params["title"] && "Pushed from a row click.",
       color: color
     })}
  end

  def handle_event("toast-sticky", _, socket) do
    {:noreply,
     push_event(socket, "sl:toast", %{
       title: "I stay until dismissed",
       color: "warning",
       duration: 0
     })}
  end

  def handle_event("pick", %{"pick" => params}, socket) do
    # The demo splits the fields across several forms, so merge into the existing params.
    params = Map.merge(socket.assigns.pick_form.params, params)
    {:noreply, assign(socket, pick_form: to_form(params, as: :pick))}
  end

  def handle_event("editor", %{"editor" => params}, socket) do
    params = Map.merge(socket.assigns.editor_form.params, params)
    {:noreply, assign(socket, editor_form: to_form(params, as: :editor))}
  end

  def handle_event("editor-save", %{"editor" => params}, socket) do
    {:noreply, socket |> assign(editor_saved: params["body"] || "") |> put_flash(:info, "Saved")}
  end

  def handle_event("upload-validate", _, socket), do: {:noreply, socket}

  def handle_event("cancel-upload", %{"ref" => ref}, socket),
    do: {:noreply, cancel_upload(socket, :attachments, ref)}

  def handle_event("cancel-avatar", %{"ref" => ref}, socket),
    do: {:noreply, cancel_upload(socket, :avatar, ref)}

  def handle_event("upload-save", _, socket) do
    names =
      consume_uploaded_entries(socket, :attachments, fn _meta, entry ->
        {:ok, entry.client_name}
      end)

    {:noreply,
     socket |> assign(saved_uploads: names) |> put_flash(:info, "Saved #{length(names)} file(s)")}
  end

  def handle_event("choices", %{"choice" => params}, socket) do
    params = Map.merge(socket.assigns.choice_form.params, params)
    {:noreply, assign(socket, choice_form: to_form(params, as: :choice))}
  end

  def handle_event("dates", %{"dates" => params}, socket) do
    params = Map.merge(socket.assigns.date_form.params, params)
    {:noreply, assign(socket, date_form: to_form(params, as: :dates))}
  end

  def handle_event("step", %{"dir" => dir}, socket) do
    {:noreply, update(socket, :step, &max(1, min(4, &1 + String.to_integer(dir))))}
  end

  def handle_event("toggle-bold", _, socket), do: {:noreply, update(socket, :bold, &(!&1))}

  def handle_event("search-city", %{"query" => q}, socket) do
    q = String.downcase(q)
    cities = Enum.filter(Pages.Selects.cities(), &String.contains?(String.downcase(&1), q))
    {:noreply, assign(socket, cities: cities)}
  end

  def handle_event("sort", %{"field" => field, "dir" => dir}, socket) do
    field = String.to_existing_atom(field)
    dir = String.to_existing_atom(dir)
    users = Enum.sort_by(socket.assigns.users, &Map.get(&1, field), dir)
    {:noreply, assign(socket, users: users, sort: {field, dir})}
  end

  def handle_event("validate", %{"profile" => params}, socket) do
    {:noreply, assign(socket, form: validate_form(params))}
  end

  def handle_event("save", %{"profile" => params}, socket) do
    form = validate_form(params)

    if form.errors == [] do
      {:noreply, socket |> assign(form: blank_form()) |> put_flash(:info, "Saved")}
    else
      {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("pick-day", %{"date" => date}, socket),
    do: {:noreply, assign(socket, cal_date: date)}

  def handle_event("pick-range", %{"date" => a, "end" => b}, socket),
    do: {:noreply, assign(socket, cal_range: {a, b})}

  def handle_event("select", %{"all" => _, "selected" => on}, socket),
    do:
      {:noreply,
       assign(socket,
         selected_ids: if(on == "true", do: Enum.map(socket.assigns.users, & &1.id), else: [])
       )}

  def handle_event("select", %{"ids" => ids, "selected" => on}, socket),
    do: {:noreply, update(socket, :selected_ids, &toggle_ids(&1, String.split(ids, ","), on))}

  def handle_event("select", %{"id" => id, "selected" => on}, socket),
    do: {:noreply, update(socket, :selected_ids, &toggle_ids(&1, [id], on))}

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <.app_shell id="sink" class="sink" width="wide">
      <:sidebar>
        <.sidebar brand="SlopUI" brand_href="/" class="sink-sidebar">
          <.nav label="Components">
            <.nav_group>
              <.nav_item
                :for={{slug, title, _} <- @pages}
                patch={"/#{slug}"}
                current={@slug == slug}
                phx-click={
                  SlopJS.close_dialog("#sink-nav") |> Phoenix.LiveView.JS.focus(to: "#sink-main")
                }
              >
                {title}
              </.nav_item>
            </.nav_group>
          </.nav>
        </.sidebar>
      </:sidebar>
      <:topbar>
        <.breadcrumbs>
          <:crumb href="/">SlopUI</:crumb>
          <:crumb>{@page_title}</:crumb>
        </.breadcrumbs>
      </:topbar>
      <.page_header title={@page_title} divider={false} class="sink-header">
        <:actions>
          <.appearance_controls :if={@slug == "themes"} id="appearance-inline" />
          <.popover
            :if={@slug != "themes"}
            id="appearance-menu"
            title="Appearance"
            placement="bottom-end"
            class="sink-appearance-menu"
          >
            <:trigger size="sm">Appearance</:trigger>
            <.appearance_controls id="appearance-panel" />
          </.popover>
        </:actions>
      </.page_header>
      <.stack gap="xl">
        {@page.render(assigns)}
      </.stack>
      <SlopUI.Sink.Reference.reference components={@page.components()} />
      <.toaster flash={@flash} />
    </.app_shell>
    """
  end

  # Store finished editor images under priv/static/sink/uploads and tell the editor the URL.
  def handle_md_progress(:md_images, entry, socket) do
    if entry.done? do
      url =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          dir = Path.join(["priv", "static", "sink", "uploads"])
          File.mkdir_p!(dir)
          name = "#{entry.uuid}#{Path.extname(entry.client_name)}"
          File.cp!(path, Path.join(dir, name))
          {:ok, "/uploads/#{name}"}
        end)

      {:noreply, SlopUI.Components.MarkdownEditor.push_image(socket, entry, url)}
    else
      {:noreply, socket}
    end
  end

  def users do
    [
      %{id: 1, name: "Ada Lovelace", role: "Owner", active: true, commits: 1342},
      %{id: 2, name: "Grace Hopper", role: "Admin", active: true, commits: 987},
      %{id: 3, name: "Linus Torvalds", role: "Member", active: false, commits: 12},
      %{id: 4, name: "Margaret Hamilton", role: "Member", active: true, commits: 451}
    ]
  end

  defp toggle_ids(current, ids, on) do
    ids = Enum.map(ids, &String.to_integer/1)
    if on == "true", do: Enum.uniq(current ++ ids), else: current -- ids
  end

  defp blank_form,
    do: to_form(%{"name" => "", "email" => "", "role" => "", "bio" => ""}, as: :profile)

  defp validate_form(params) do
    errors =
      []
      |> maybe_error(:name, params["name"] in [nil, ""], "can't be blank")
      |> maybe_error(:email, not String.contains?(params["email"] || "", "@"), "must contain @")
      |> maybe_error(:role, params["role"] in [nil, ""], "pick a role")
      |> maybe_error(:agree, params["agree"] != "true", "must be accepted")

    to_form(params, as: :profile, errors: errors, action: :validate)
  end

  defp maybe_error(errors, _field, false, _msg), do: errors
  defp maybe_error(errors, field, true, msg), do: [{field, {msg, []}} | errors]
  attr :id, :string, required: true

  defp appearance_controls(assigns) do
    ~H"""
    <div id={@id} class="sink-appearance" phx-hook="SinkAppearance" phx-update="ignore">
      <select class="sl-native-select" data-size="sm" data-pref="palette" aria-label="Palette">
        <option value="default">Palette: warm</option>
        <option :for={p <- ~w(cool slate forest ocean mono)} value={p}>Palette: {p}</option>
      </select>
      <select class="sl-native-select" data-size="sm" data-pref="density" aria-label="Density">
        <option value="default">Density: default</option>
        <option value="compact">Density: compact</option>
        <option value="comfortable">Density: comfortable</option>
      </select>
      <select class="sl-native-select" data-size="sm" data-pref="radius" aria-label="Radius">
        <option value="default">Radius: default</option>
        <option :for={r <- ~w(none sm lg full)} value={r}>Radius: {r}</option>
      </select>
      <select
        class="sl-native-select"
        data-size="sm"
        data-pref="contrast"
        aria-label="Contrast"
      >
        <option value="default">Contrast: default</option>
        <option value="more">Contrast: more</option>
      </select>
      <select
        class="sl-native-select"
        data-size="sm"
        data-pref="dark"
        aria-label="Dark variant"
      >
        <option value="default">Dark: dim</option>
        <option value="black">Dark: black</option>
      </select>
      <.theme_toggle id={"#{@id}-theme"} />
    </div>
    """
  end
end
