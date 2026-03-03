defmodule PhiaUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :phia_ui,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PhiaUi.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme"
    ]
  end

  defp package do
    [
      name: "phia_ui",
      description: "shadcn/ui-inspired component library for Phoenix LiveView with eject-based distribution. Optimised for enterprise dashboards.",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/phiaui/phia_ui"},
      files: ~w(lib priv mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.1"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end
