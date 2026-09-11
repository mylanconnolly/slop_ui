defmodule SlopUI.Icons.Set do
  @moduledoc """
  Compile-time icon sets.

  `use SlopUI.Icons, sets: [...]` defines an `icon/1` function component in
  the calling module whose SVGs are read from disk at compile time and
  embedded in the module, so nothing is fetched at runtime and unknown names
  fail the build.

      defmodule MyAppWeb.Icons do
        use SlopUI.Icons,
          sets: [
            phosphor: [weight: :regular, icons: ~w(house users bell)],
            hero: [style: :outline, icons: ~w(arrow-path)],
            app: [dir: "assets/icons", icons: :all]
          ]
      end

      <MyAppWeb.Icons.icon name="phosphor-house" />
      <MyAppWeb.Icons.icon name="hero-arrow-path" class="sl-icon-lg" />
      <MyAppWeb.Icons.icon name="app-logo" aria-label="Acme" />

  Each set is keyed by its prefix. Names are `prefix-file-name` (the file's
  basename without `.svg`), so sets never collide.

  ## Set options

    * `:dir` – folder of `.svg` files. Required unless a preset applies.
    * `:icons` – list of names to embed, or `:all` for every file in the
      folder. Required. A name that does not exist raises at compile time with
      the closest matches.
    * `:prefix` – overrides the prefix (defaults to the key). `false` uses the
      bare file names.
    * `:preset` – `:phosphor` or `:heroicons`. Inferred from the key when the
      key is `:phosphor`, `:hero` or `:heroicons`.

  ### Phosphor

  Add the icons to your deps (git checkout, nothing compiled):

      {:phosphor, github: "phosphor-icons/core", sparse: "assets", depth: 1,
       app: false, compile: false}

  Options: `:weight` – `:regular` (default), `:thin`, `:light`, `:bold`,
  `:fill` or `:duotone`; `:dep` – the dep name if you called it something
  other than `:phosphor`.

  ### Heroicons

      {:heroicons, github: "tailwindlabs/heroicons", sparse: "optimized", depth: 1,
       app: false, compile: false}

  Options: `:style` – `:outline` (default), `:solid`, `:mini` (20px) or
  `:micro` (16px); `:dep`.

  ## Normalisation

  The root `<svg>` keeps its `viewBox` and any `fill`/`stroke` attributes;
  `width`, `height`, `xmlns`, `class` and `id` are dropped so the icon is
  sized by CSS (`1em` by default, see `.sl-icon`). Hard-coded black fills and
  strokes become `currentColor`. Everything inside the root element is kept
  as-is, so multi-layer icons (Phosphor duotone) work.

  ## Accessibility

  Icons are `aria-hidden` by default. Pass `aria-label` for a meaningful icon
  and it becomes `role="img"` instead.
  """

  @phosphor_weights ~w(regular thin light bold fill duotone)a
  @heroicons_styles %{
    outline: "24/outline",
    solid: "24/solid",
    mini: "20/solid",
    micro: "16/solid"
  }

  @doc false
  defmacro define(opts) do
    {opts, _} = Code.eval_quoted(opts, [], __CALLER__)
    sets = Keyword.fetch!(opts, :sets)
    {icons, resources} = load_sets(sets, __CALLER__)
    names = Enum.map(icons, &elem(&1, 0))

    quote do
      for resource <- unquote(resources) do
        @external_resource resource
      end

      @sl_icon_set Map.new(unquote(Macro.escape(icons)))

      @doc """
      An icon from this module's sets.

      Names: #{unquote(Enum.join(names, ", "))}
      """
      attr :name, :string, required: true, values: unquote(names)
      attr :class, :any, default: nil
      attr :rest, :global, include: ~w(aria-label role)

      Phoenix.Component.Declarative.def icon(var!(assigns)) do
        {attrs, inner} = Map.fetch!(@sl_icon_set, var!(assigns).name)
        labelled? = Map.has_key?(var!(assigns).rest, :"aria-label")

        var!(assigns) =
          assign(var!(assigns),
            svg_attrs: attrs,
            inner: Phoenix.HTML.raw(inner),
            hidden: !labelled? && "true",
            role: labelled? && "img"
          )

        ~H"""
        <svg {@svg_attrs} class={[@class, "sl-icon"]} aria-hidden={@hidden} role={@role} {@rest}>{@inner}</svg>
        """
      end

      @doc "Every icon name this module knows."
      def icon_names, do: unquote(names)
    end
  end

  @doc false
  def load_sets(sets, caller) do
    Enum.reduce(sets, {[], []}, fn {key, config}, {icons, resources} ->
      preset = config[:preset] || infer_preset(key)
      dir = resolve_dir(key, config, preset)
      prefix = if config[:prefix] == false, do: "", else: "#{config[:prefix] || key}-"
      files = Enum.sort(Path.wildcard(Path.join(dir, "*.svg")))
      available = Map.new(files, &{Path.basename(&1, ".svg"), &1})
      wanted = wanted(key, config, preset, available)

      loaded =
        for name <- wanted do
          path = Map.get(available, name) || unknown!(key, name, available, dir)
          {prefix <> canonical(name, preset, config), parse!(path, caller)}
        end

      case Enum.find(loaded, fn {name, _} -> List.keymember?(icons, name, 0) end) do
        nil ->
          :ok

        {name, _} ->
          raise ArgumentError,
                "icon #{inspect(name)} is defined by more than one set in #{inspect(caller.module)}; " <>
                  "give the sets different prefixes"
      end

      {icons ++ loaded, resources ++ [dir | Enum.map(wanted, &available[&1])]}
    end)
  end

  defp infer_preset(:phosphor), do: :phosphor
  defp infer_preset(:hero), do: :heroicons
  defp infer_preset(:heroicons), do: :heroicons
  defp infer_preset(_), do: nil

  defp resolve_dir(key, config, nil) do
    case config[:dir] do
      nil ->
        raise ArgumentError,
              "icon set #{inspect(key)} needs a :dir (or a :preset of :phosphor / :heroicons)"

      dir ->
        dir = Path.expand(dir)

        File.dir?(dir) ||
          raise ArgumentError, "icon set #{inspect(key)}: directory #{dir} does not exist"

        dir
    end
  end

  defp resolve_dir(key, config, :phosphor) do
    weight = config[:weight] || :regular

    weight in @phosphor_weights ||
      raise ArgumentError,
            "icon set #{inspect(key)}: unknown Phosphor weight #{inspect(weight)}; " <>
              "expected one of #{inspect(@phosphor_weights)}"

    dep_dir(key, config, :phosphor, ["assets/#{weight}", "#{weight}"])
  end

  defp resolve_dir(key, config, :heroicons) do
    style = config[:style] || :outline

    sub =
      @heroicons_styles[style] ||
        raise ArgumentError,
              "icon set #{inspect(key)}: unknown Heroicons style #{inspect(style)}; " <>
                "expected one of #{inspect(Map.keys(@heroicons_styles))}"

    dep_dir(key, config, :heroicons, ["optimized/#{sub}", sub])
  end

  defp dep_dir(key, config, preset, candidates) do
    case config[:dir] do
      nil ->
        dep = config[:dep] || preset
        root = Path.join(deps_path(), to_string(dep))

        Enum.find_value(candidates, fn sub ->
          dir = Path.join(root, sub)
          File.dir?(dir) && dir
        end) ||
          raise ArgumentError,
                "icon set #{inspect(key)}: #{preset} files not found under #{root} " <>
                  "(looked in #{Enum.join(candidates, ", ")}). " <>
                  "Add the dep to mix.exs and run mix deps.get, or pass :dir. See SlopUI.Icons.Set."

      _dir ->
        resolve_dir(key, config, nil)
    end
  end

  defp deps_path do
    if Code.ensure_loaded?(Mix.Project) and function_exported?(Mix.Project, :deps_path, 0),
      do: Mix.Project.deps_path(),
      else: Path.expand("deps")
  end

  defp wanted(key, config, preset, available) do
    case config[:icons] do
      nil ->
        raise ArgumentError, "icon set #{inspect(key)} needs :icons (a list of names or :all)"

      :all ->
        available |> Map.keys() |> Enum.sort()

      list when is_list(list) ->
        Enum.map(list, &file_name(to_string(&1), preset, config))
    end
  end

  # Phosphor files are `name.svg` for regular and `name-<weight>.svg` otherwise.
  defp file_name(name, :phosphor, config) do
    case config[:weight] || :regular do
      :regular -> name
      weight -> "#{name}-#{weight}"
    end
  end

  defp file_name(name, _, _), do: name

  defp canonical(file, :phosphor, config) do
    case config[:weight] || :regular do
      :regular -> file
      weight -> String.replace_suffix(file, "-#{weight}", "")
    end
  end

  defp canonical(file, _, _), do: file

  defp unknown!(key, name, available, dir) do
    close =
      available
      |> Map.keys()
      |> Enum.map(&{String.jaro_distance(&1, name), &1})
      |> Enum.filter(fn {d, _} -> d > 0.75 end)
      |> Enum.sort(:desc)
      |> Enum.take(5)
      |> Enum.map(&elem(&1, 1))

    hint = if close == [], do: "", else: " Did you mean: #{Enum.join(close, ", ")}?"

    raise ArgumentError,
          "icon set #{inspect(key)}: no icon named #{inspect(name)} in #{dir}.#{hint}"
  end

  @drop ~w(width height xmlns xmlns:xlink class id data-slot aria-hidden role focusable)

  @doc false
  def parse!(path, caller \\ nil) do
    svg = File.read!(path)

    case Regex.run(~r/<svg\b([^>]*)>(.*)<\/svg>\s*$/s, String.trim(svg)) do
      [_, attrs, inner] ->
        attrs =
          ~r/([a-zA-Z:-]+)\s*=\s*"([^"]*)"/
          |> Regex.scan(attrs)
          |> Enum.map(fn [_, k, v] -> {k, v} end)
          |> Enum.reject(fn {k, _} -> k in @drop end)
          |> Enum.map(fn {k, v} -> {k, color(v)} end)

        inner =
          inner
          |> String.trim()
          |> String.replace(~r/(fill|stroke)="(#000000|#000|black)"/i, ~S(\1="currentColor"))
          |> String.replace(~r/\s+/, " ")

        {attrs, inner}

      _ ->
        raise ArgumentError,
              "#{path} is not a single-root SVG file" <>
                if(caller, do: " (loaded by #{inspect(caller.module)})", else: "")
    end
  end

  defp color(v) when v in ["#000000", "#000", "black"], do: "currentColor"
  defp color(v), do: v
end
