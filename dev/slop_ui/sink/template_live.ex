defmodule SlopUI.Sink.TemplateLive do
  @moduledoc "Full-page templates rendered without the kitchen sink chrome."
  use Phoenix.LiveView, layout: false
  use SlopUI
  alias SlopUI.Sink.Templates

  @templates %{
    "dashboard" => Templates.Dashboard,
    "list" => Templates.List,
    "detail" => Templates.Detail,
    "settings" => Templates.Settings,
    "sign-in" => Templates.SignIn,
    "sign-up" => Templates.SignUp
  }

  def templates, do: @templates

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       users: SlopUI.Sink.Live.users(),
       sort: {:name, :asc},
       page_no: 1,
       step: 2,
       settings_tab: "profile",
       form:
         to_form(
           %{
             "name" => "Ada Lovelace",
             "email" => "ada@example.com",
             "bio" => "",
             "notify" => "true",
             "plan" => "pro",
             "language" => "en"
           },
           as: :settings
         ),
       auth_form:
         to_form(%{"email" => "", "password" => "", "name" => "", "remember" => "false"},
           as: :auth
         )
     )}
  end

  def handle_params(%{"name" => name}, _uri, socket) do
    case Map.fetch(@templates, name) do
      {:ok, mod} -> {:noreply, assign(socket, template: mod, name: name, page_title: mod.title())}
      :error -> {:noreply, push_navigate(socket, to: "/templates/dashboard")}
    end
  end

  def handle_event("sort", %{"field" => field, "dir" => dir}, socket) do
    field = String.to_existing_atom(field)
    dir = String.to_existing_atom(dir)

    {:noreply,
     assign(socket,
       users: Enum.sort_by(socket.assigns.users, &Map.get(&1, field), dir),
       sort: {field, dir}
     )}
  end

  def handle_event("settings-tab", %{"tab" => tab}, socket),
    do: {:noreply, assign(socket, settings_tab: tab)}

  def handle_event("settings", %{"settings" => params}, socket),
    do: {:noreply, assign(socket, form: to_form(params, as: :settings))}

  def handle_event("auth", %{"auth" => params}, socket),
    do: {:noreply, assign(socket, auth_form: to_form(params, as: :auth))}

  def handle_event("toast", params, socket),
    do:
      {:noreply,
       push_event(socket, "sl:toast", %{
         title: params["title"] || "Done",
         color: params["color"] || "success"
       })}

  def handle_event(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    {@template.render(assigns)}
    <.toaster flash={@flash} />
    """
  end
end
