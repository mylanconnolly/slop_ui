defmodule SlopUI.Sink.Pages.Selects do
  use Phoenix.Component
  use SlopUI
  import SlopUI.Sink.Helpers

  @roles [
    {"Administrator", "admin"},
    {"Editor", "editor"},
    {"Viewer", "viewer"},
    {"Billing only", "billing"}
  ]
  @tags ~w(elixir phoenix liveview css html accessibility design)

  def components do
    [
      {SlopUI.Components.Select, :select},
      {SlopUI.Components.Select, :combobox}
    ]
  end

  def render(assigns) do
    assigns = assign(assigns, roles: @roles, tags: @tags)

    ~H"""
    <.example
      title="Select"
      description="A hidden native <select> holds the value, so the form submits and phx-change fires normally. Keyboard: arrows, Home/End, type-ahead, Enter, Escape."
      code={
        ~S|<.select field={@form[:role]} label="Role" placeholder="Pick a role" options={[{"Administrator", "admin"}, …]} />|
      }
    >
      <.form for={@pick_form} phx-change="pick" style="max-inline-size: 28rem">
        <.stack gap="lg">
          <.select
            field={@pick_form[:role]}
            label="Role"
            placeholder="Pick a role"
            options={@roles}
            description="Single value."
          />
          <.select
            field={@pick_form[:tags]}
            label="Tags"
            placeholder="Add tags"
            options={@tags}
            multiple
            description="Multiple values with chips; Backspace removes the last one."
          />
          <.select name="disabled" value="editor" label="Disabled" options={@roles} disabled />
          <.select name="err" value="" label="With error" options={@roles} errors={["pick one"]} />
          <.cluster gap="sm">
            <.badge>role: {@pick_form[:role].value || "—"}</.badge>
            <.badge>tags: {Enum.join(List.wrap(@pick_form[:tags].value), ", ")}</.badge>
          </.cluster>
        </.stack>
      </.form>
    </.example>

    <.example
      title="Combobox, client filtered"
      description="Static options filtered in the browser. Tokens match word prefixes or substrings in any order (u s → United States), and 'quoted phrases' in double quotes match literally, accents are ignored. Value is committed only when an option is chosen."
      code={~S|<.combobox field={@form[:country]} label="Country" options={@countries} />|}
    >
      <.form for={@pick_form} phx-change="pick" style="max-inline-size: 28rem">
        <.stack gap="lg">
          <.combobox
            field={@pick_form[:country]}
            label="Country"
            placeholder="Start typing…"
            options={countries()}
          />
          <.combobox
            name="free"
            value=""
            label="Free text allowed"
            placeholder="Pick or type anything"
            options={@tags}
            allow_custom
          />
          <.combobox
            field={@pick_form[:languages]}
            label="Languages (multiple)"
            placeholder="Add languages…"
            options={countries()}
            multiple
            description="Chips share the frame; Backspace removes the last one; picks keep the list open."
          />
          <.badge>
            languages: {@pick_form[:languages].value
            |> List.wrap()
            |> Enum.reject(&(&1 == ""))
            |> Enum.join(", ")}
          </.badge>
          <.badge>country: {@pick_form[:country].value || "—"}</.badge>
        </.stack>
      </.form>
    </.example>

    <.example
      title="Combobox, server filtered"
      description="on_search pushes {query}; the LiveView replaces options. Try 'san'."
      code={
        ~S|<.combobox field={@form[:city]} label="City" options={@cities} on_search="search-city" loading={@searching} />|
      }
    >
      <.form for={@pick_form} phx-change="pick" style="max-inline-size: 28rem">
        <.stack gap="lg">
          <.combobox
            field={@pick_form[:city]}
            label="City"
            placeholder="Search cities…"
            options={@cities}
            on_search="search-city"
            loading={@searching}
            empty="No cities match"
          />
          <.badge>city: {@pick_form[:city].value || "—"}</.badge>
        </.stack>
      </.form>
    </.example>
    """
  end

  def countries do
    [
      "Argentina",
      "Australia",
      "Austria",
      "Belgium",
      "Brazil",
      "Canada",
      "Chile",
      "China",
      "Colombia",
      "Croatia",
      "Denmark",
      "Egypt",
      "Finland",
      "France",
      "Germany",
      "Greece",
      "Hungary",
      "Iceland",
      "India",
      "Indonesia",
      "Ireland",
      "Israel",
      "Italy",
      "Japan",
      "Kenya",
      "Mexico",
      "Netherlands",
      "New Zealand",
      "Nigeria",
      "Norway",
      "Peru",
      "Philippines",
      "Poland",
      "Portugal",
      "Romania",
      "Singapore",
      "South Africa",
      "South Korea",
      "Spain",
      "Sweden",
      "Switzerland",
      "Thailand",
      "Turkey",
      "Ukraine",
      "United Kingdom",
      "United States",
      "Vietnam"
    ]
    |> Enum.map(&{&1, &1 |> String.downcase() |> String.replace(" ", "-")})
  end

  def cities do
    [
      "San Francisco",
      "San Diego",
      "San Jose",
      "San Antonio",
      "Santa Fe",
      "Santiago",
      "Sanaa",
      "Seattle",
      "Portland",
      "Boston",
      "Austin",
      "Denver",
      "Chicago",
      "Miami",
      "Toronto",
      "Vancouver",
      "Montreal",
      "London",
      "Paris",
      "Berlin",
      "Madrid",
      "Rome",
      "Lisbon",
      "Dublin",
      "Tokyo",
      "Osaka",
      "Sydney",
      "Melbourne"
    ]
  end
end
