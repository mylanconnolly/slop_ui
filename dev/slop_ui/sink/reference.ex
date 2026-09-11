defmodule SlopUI.Sink.Reference do
  @moduledoc """
  Renders API reference tables for components straight from their
  `Phoenix.Component` metadata (`attr`/`slot` declarations) and `@doc` strings,
  so the kitchen sink can never drift from the code.
  """
  use Phoenix.Component

  attr :components, :list, required: true, doc: "list of {module, function_name}"

  def reference(assigns) do
    assigns = assign(assigns, :entries, Enum.map(assigns.components, &entry/1))

    ~H"""
    <section :if={@entries != []} class="sink-reference">
      <h2>Reference</h2>
      <article :for={e <- @entries} id={"ref-#{e.name}"} class="sink-ref">
        <h3>
          <code>&lt;.{e.name} /&gt;</code> <span class="sink-ref-module">{inspect(e.module)}</span>
        </h3>
        <div class="sink-ref-doc">
          <SlopUI.Components.Markdown.markdown :if={e.doc} text={fenced(e.doc)} />
        </div>

        <h4 :if={e.attrs != []}>Attributes</h4>
        <div :if={e.attrs != []} class="sl-table-wrap">
          <table class="sl-table" data-density="compact">
            <thead>
              <tr>
                <th>Name</th><th>Type</th><th>Default</th><th>Description</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={a <- e.attrs}>
                <td>
                  <code>{a.name}</code><span :if={a.required} class="sink-required" title="required">*</span>
                </td>
                <td><code>{type(a)}</code></td>
                <td><code :if={has_default?(a)}>{inspect(a.opts[:default])}</code></td>
                <td>
                  {a.doc}
                  <div :if={a.opts[:values]} class="sink-values">
                    <span :for={v <- a.opts[:values]} class="sl-badge" data-size="sm">{inspect(v)}</span>
                  </div>
                  <span :if={a.type == :global and a.opts[:include]} class="sink-muted">
                    Also accepts: {Enum.join(a.opts[:include], ", ")}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <h4 :if={e.slots != []}>Slots</h4>
        <div :if={e.slots != []} class="sl-table-wrap">
          <table class="sl-table" data-density="compact">
            <thead>
              <tr>
                <th>Name</th><th>Description</th><th>Slot attributes</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={s <- e.slots}>
                <td>
                  <code>{s.name}</code><span :if={s.required} class="sink-required" title="required">*</span>
                </td>
                <td>{s.doc}</td>
                <td>
                  <span :if={s.attrs == []} class="sink-muted">—</span>
                  <ul :if={s.attrs != []} class="sink-slot-attrs">
                    <li :for={a <- s.attrs}>
                      <code>{a.name}</code> <span class="sink-muted">{type(a)}</span>
                      <span :if={a.doc}> — {a.doc}</span>
                      <span :if={a.opts[:values]}> ({Enum.map_join(a.opts[:values], " | ", &inspect/1)})</span>
                    </li>
                  </ul>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </article>
    </section>
    """
  end

  defp entry({module, fun}) do
    meta = module.__components__()[fun] || %{attrs: [], slots: []}
    attrs = Enum.sort_by(meta.attrs, & &1.line)

    slots =
      meta.slots
      |> Enum.sort_by(& &1.line)
      |> Enum.map(fn s ->
        %{
          name: s.name,
          required: s.required,
          doc: s[:doc] || s.opts[:doc],
          attrs: Enum.sort_by(Map.get(s, :attrs, []), & &1.line)
        }
      end)

    %{module: module, name: fun, doc: fetch_doc(module, fun), attrs: attrs, slots: slots}
  end

  defp fetch_doc(module, fun) do
    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {_, _, _, %{"en" => doc}, _} <-
           Enum.find(docs, &match?({{:function, ^fun, 1}, _, _, _, _}, &1)) do
      doc
    else
      _ -> nil
    end
  end

  defp has_default?(%{opts: opts}), do: Keyword.has_key?(opts, :default)

  defp type(%{type: :global}), do: "global"

  defp type(%{type: t})
       when is_atom(t) and t in ~w(string boolean integer float atom list map any fun)a,
       do: Atom.to_string(t)

  defp type(%{type: t}) when is_atom(t), do: t |> inspect() |> String.split(".") |> List.last()
  defp type(%{type: t}), do: inspect(t)

  # Minimal markdown: paragraphs, 4-space code blocks (highlighted), and "* " bullets.
  # Phoenix.Component appends generated "## Attributes" / "## Slots" sections;
  # the tables below cover those, so only the author-written part is kept.
  # Indented example blocks become fenced blocks with a guessed language so
  # Lumis can highlight them.
  defp fenced(doc) do
    doc
    |> String.split(~r/\n## (Attributes|Slots)\n/, parts: 2)
    |> hd()
    |> String.split("\n")
    |> fence_indented([])
    |> Enum.join("\n")
  end

  defp fence_indented([], acc), do: Enum.reverse(acc)

  defp fence_indented(["    " <> _ = line | rest], acc) do
    {code, rest} = Enum.split_while(rest, &(String.starts_with?(&1, "    ") or &1 == ""))

    code =
      [line | code]
      |> Enum.map(&String.replace_prefix(&1, "    ", ""))
      |> Enum.join("\n")
      |> String.trim_trailing()

    lang = if String.contains?(code, "<"), do: "heex", else: "elixir"
    fence_indented(rest, ["```", code, "```#{lang}" | acc])
  end

  defp fence_indented([line | rest], acc), do: fence_indented(rest, [line | acc])
end
