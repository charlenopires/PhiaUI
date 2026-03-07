defmodule PhiaUi.MixProject do
  use Mix.Project

  @version "0.1.7"

  def project do
    [
      app: :phia_ui,
      version: @version,
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
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "docs/components/buttons.md",
        "docs/components/calendar.md",
        "docs/components/cards.md",
        "docs/components/data.md",
        "docs/components/display.md",
        "docs/components/feedback.md",
        "docs/components/forms.md",
        "docs/components/inputs.md",
        "docs/components/layout.md",
        "docs/components/media.md",
        "docs/components/navigation.md",
        "docs/components/overlay.md",
        "docs/components/animation.md",
        "docs/components/background.md",
        "docs/components/editor.md",
        "docs/components/interaction.md",
        "docs/components/surface.md",
        "docs/components/typography.md",
        "docs/guides/theme-system.md",
        "docs/guides/tutorial-booking.md",
        "docs/guides/tutorial-cms.md",
        "docs/guides/tutorial-dashboard.md",
        "docs/guides/tutorial-livebook.md"
      ],
      main: "readme",
      source_url: "https://github.com/phiaui/phia_ui",
      source_ref: "v#{@version}",
      groups_for_extras: [
        Guides: ~r/docs\/guides\/.*/,
        Components: ~r/docs\/components\/.*/
      ]
    ]
  end

  defp package do
    [
      name: "phia_ui",
      description:
        "shadcn/ui-inspired component library for Phoenix LiveView with eject-based distribution. CSS-first theme system, 343 components across 16 categories, full Calendar Suite, Chart Suite, Animation Suite, DnD Suite, Editor Suite, Typography Suite, and enterprise analytics widgets.",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/phiaui/phia_ui"},
      files: ~w(lib priv docs mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.1"},
      {:eqrcode, "~> 0.2"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end
