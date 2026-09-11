defmodule SlopUI.Sink.ContractLive do
  @moduledoc false
  use Phoenix.LiveView, layout: false
  use SlopUI

  def mount(_, _, socket), do: {:ok, assign(socket, values: [], submissions: 0)}

  def handle_event("change", %{"tags" => tags}, socket) do
    {:noreply, assign(socket, :values, Enum.reject(tags, &(&1 == "")))}
  end

  def handle_event("change", _, socket), do: {:noreply, socket}
  def handle_event("replace", _, socket), do: {:noreply, assign(socket, :values, ["b"])}
  def handle_event("submit", _, socket), do: {:noreply, update(socket, :submissions, &(&1 + 1))}

  def render(assigns) do
    ~H"""
    <main style="padding: 2rem; max-width: 40rem">
      <form id="multi-form" phx-change="change" phx-submit="submit">
        <.combobox
          id="multi"
          name="tags[]"
          label="Tags"
          options={[{"Alpha", "a"}, {"Beta", "b"}]}
          value={@values}
          multiple
          required
        />
        <.button type="submit">Submit</.button>
      </form>
      <.button id="replace" phx-click="replace">Replace selection</.button>
      <output id="values">{Enum.join(@values, ",")}</output>
      <form id="custom-form" phx-submit="submit">
        <.combobox
          id="custom"
          name="custom[]"
          label="Custom tags"
          options={[]}
          multiple
          allow_custom
          required
        />
        <.button type="submit">Submit</.button>
      </form>
      <form id="single-form" phx-submit="submit">
        <.combobox id="single" name="single" label="Single" options={~w(a b)} required />
        <.button type="submit">Submit</.button>
      </form>
      <form id="select-form" phx-submit="submit">
        <.select id="select" name="select" label="Select" options={~w(a b)} required />
        <.button type="submit">Submit</.button>
      </form>
      <form id="radio-form" phx-submit="submit">
        <.radio_group id="radio" name="radio" label="Radio" options={~w(a b)} required />
        <.button type="submit">Submit</.button>
      </form>
      <form id="checks-form" phx-submit="submit">
        <.checkbox_group id="checks" name="checks[]" label="Checks" options={~w(a b)} required />
        <.button type="submit">Submit</.button>
      </form>
      <form id="disabled-form" phx-submit="submit">
        <.combobox
          id="disabled"
          name="disabled"
          label="Disabled"
          options={~w(a b)}
          value="a"
          disabled
        />
        <.combobox
          id="disabled-multi"
          name="disabled_multi[]"
          label="Disabled multiple"
          options={~w(a b)}
          value={["a"]}
          multiple
          disabled
        />
        <.select
          id="disabled-select"
          name="disabled_select[]"
          label="Disabled select"
          options={~w(a b)}
          value={["a"]}
          multiple
          disabled
        />
      </form>
      <.date_picker id="readonly-date" name="date" label="Date" value="2026-09-11" readonly />
      <.time_picker id="readonly-time" name="time" label="Time" value="09:00" readonly />
      <.button id="loading" loading phx-click="submit">Loading</.button>
      <.button id="loading-link" href="/buttons" loading>Loading link</.button>
      <.input id="errors" name="errors" label="Errors" errors={["First error", "Second error"]} />
      <output id="submissions">{@submissions}</output>
    </main>
    """
  end
end
