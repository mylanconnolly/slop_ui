defmodule SlopUI.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/mylanconnolly/slop_ui"

  def project do
    [
      app: :slop_ui,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      aliases: aliases(),
      name: "SlopUI",
      description:
        "A semantic, themeable, accessible component library for Phoenix LiveView built on modern vanilla CSS.",
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Library dependencies
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_html, "~> 4.2"},
      {:gettext, "~> 1.0"},
      {:mdex, "~> 0.13", optional: true},

      # Kitchen sink (dev only)

      {:bandit, "~> 1.7", only: :dev},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:esbuild, "~> 0.10", only: :dev},
      {:phosphor,
       github: "phosphor-icons/core",
       sparse: "assets",
       depth: 1,
       app: false,
       compile: false,
       only: :dev},
      {:jason, "~> 1.4"},

      # Docs
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:makeup_eex, "~> 2.0", only: :dev, runtime: false},
      {:makeup_html, "~> 0.2.0", only: :dev, runtime: false},
      {:lumis, "~> 0.8", only: :dev}
    ]
  end

  defp aliases do
    [
      dev: "run --no-halt dev.exs",
      "assets.build": ["esbuild sink"],
      "assets.test": ["cmd node --test assets/js/*.test.js assets/js/hooks/*.test.js"],
      "sink.smoke": ["sink.smoke"],
      "assets.watch": ["esbuild sink --watch"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files:
        ~w(lib assets priv/gettext priv/phosphor docs package.json mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "docs/browser-support.md", "CHANGELOG.md"]
    ]
  end
end
