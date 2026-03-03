defmodule PhiaUi.ThemeCSSTest do
  use ExUnit.Case, async: true

  alias PhiaUi.{Theme, ThemeCSS}

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp zinc_theme, do: Theme.get!(:zinc)
  defp blue_theme, do: Theme.get!(:blue)

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — structural presence
  # ---------------------------------------------------------------------------

  describe "generate/1 — structural blocks" do
    test "produces a string" do
      css = ThemeCSS.generate(zinc_theme())
      assert is_binary(css)
    end

    test "contains :root {" do
      css = ThemeCSS.generate(zinc_theme())
      assert css =~ ":root {"
    end

    test "contains .dark {" do
      css = ThemeCSS.generate(zinc_theme())
      assert css =~ ".dark {"
    end

    test "contains @theme {" do
      css = ThemeCSS.generate(zinc_theme())
      assert css =~ "@theme {"
    end

    test "contains a PhiaUI Theme comment with the theme label" do
      css = ThemeCSS.generate(zinc_theme())
      assert css =~ "PhiaUI Theme:"
      assert css =~ "Zinc"
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — light mode color variables
  # ---------------------------------------------------------------------------

  describe "generate/1 — light mode color variables" do
    setup do
      %{css: ThemeCSS.generate(zinc_theme())}
    end

    test "includes --color-background", %{css: css} do
      assert css =~ "--color-background"
    end

    test "includes --color-foreground", %{css: css} do
      assert css =~ "--color-foreground"
    end

    test "includes --color-primary", %{css: css} do
      assert css =~ "--color-primary"
    end

    test "includes --color-primary-foreground", %{css: css} do
      assert css =~ "--color-primary-foreground"
    end

    test "includes --color-secondary", %{css: css} do
      assert css =~ "--color-secondary"
    end

    test "includes --color-muted", %{css: css} do
      assert css =~ "--color-muted"
    end

    test "includes --color-accent", %{css: css} do
      assert css =~ "--color-accent"
    end

    test "includes --color-destructive", %{css: css} do
      assert css =~ "--color-destructive"
    end

    test "includes --color-border", %{css: css} do
      assert css =~ "--color-border"
    end

    test "includes --color-ring", %{css: css} do
      assert css =~ "--color-ring"
    end

    test "color values use oklch() format", %{css: css} do
      assert css =~ "oklch("
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — :root block contains light values
  # ---------------------------------------------------------------------------

  describe "generate/1 — :root block position" do
    test ":root block appears before .dark block" do
      css = ThemeCSS.generate(zinc_theme())
      root_pos = :binary.match(css, ":root {") |> elem(0)
      dark_pos = :binary.match(css, ".dark {") |> elem(0)
      assert root_pos < dark_pos
    end

    test ":root block contains --color-background with light value" do
      theme = zinc_theme()
      css = ThemeCSS.generate(theme)
      expected_value = Map.get(theme.colors.light, :background)
      [_before, root_section | _] = String.split(css, ":root {", parts: 2)
      [root_content, _after] = String.split(root_section, "}", parts: 2)
      assert root_content =~ "--color-background: #{expected_value}"
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — dark mode block
  # ---------------------------------------------------------------------------

  describe "generate/1 — dark mode variables" do
    setup do
      theme = zinc_theme()
      css = ThemeCSS.generate(theme)
      [_before, dark_section] = String.split(css, ".dark {", parts: 2)
      %{css: css, dark_section: dark_section, theme: theme}
    end

    test ".dark block contains --color-background", %{dark_section: dark_section} do
      assert dark_section =~ "--color-background"
    end

    test ".dark block contains --color-foreground", %{dark_section: dark_section} do
      assert dark_section =~ "--color-foreground"
    end

    test ".dark block contains --color-primary", %{dark_section: dark_section} do
      assert dark_section =~ "--color-primary"
    end

    test ".dark block uses oklch() values", %{dark_section: dark_section} do
      assert dark_section =~ "oklch("
    end

    test ".dark background value differs from light background value", %{theme: theme, css: css} do
      light_bg = Map.get(theme.colors.light, :background)
      dark_bg = Map.get(theme.colors.dark, :background)

      [_before_root, after_root] = String.split(css, ":root {", parts: 2)
      [root_content, _] = String.split(after_root, "}", parts: 2)

      [_before_dark, after_dark] = String.split(css, ".dark {", parts: 2)
      [dark_content, _] = String.split(after_dark, "}", parts: 2)

      assert root_content =~ "--color-background: #{light_bg}"
      assert dark_content =~ "--color-background: #{dark_bg}"
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — @theme block (radius + typography)
  # ---------------------------------------------------------------------------

  describe "generate/1 — @theme block" do
    test "includes --radius with the theme's radius value" do
      theme = zinc_theme()
      css = ThemeCSS.generate(theme)
      assert css =~ "--radius: #{theme.radius}"
    end

    test "includes typography tokens when present" do
      theme = zinc_theme()
      css = ThemeCSS.generate(theme)
      # font_sans maps to --font-sans CSS custom property
      assert css =~ "--font-sans"
    end

    test "includes --font-mono when typography has font_mono" do
      theme = zinc_theme()
      css = ThemeCSS.generate(theme)
      assert css =~ "--font-mono"
    end

    test "@theme block appears before :root block" do
      css = ThemeCSS.generate(zinc_theme())
      theme_pos = :binary.match(css, "@theme {") |> elem(0)
      root_pos = :binary.match(css, ":root {") |> elem(0)
      assert theme_pos < root_pos
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — CSS property key formatting
  # ---------------------------------------------------------------------------

  describe "generate/1 — CSS key formatting" do
    test "underscores in color keys are converted to hyphens" do
      css = ThemeCSS.generate(zinc_theme())
      # card_foreground -> --color-card-foreground
      assert css =~ "--color-card-foreground"
      refute css =~ "--color-card_foreground"
    end

    test "underscores in typography keys are converted to hyphens" do
      css = ThemeCSS.generate(zinc_theme())
      # font_sans -> --font-sans
      assert css =~ "--font-sans"
      refute css =~ "--font_sans"
    end

    test "sidebar_background key renders as --color-sidebar-background" do
      css = ThemeCSS.generate(zinc_theme())
      assert css =~ "--color-sidebar-background"
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/1 — works across all presets
  # ---------------------------------------------------------------------------

  describe "generate/1 — all presets produce valid CSS" do
    test "every preset generates a non-empty CSS string" do
      Enum.each(Theme.list(), fn key ->
        theme = Theme.get!(key)
        css = ThemeCSS.generate(theme)
        assert is_binary(css) and byte_size(css) > 0, "#{key}: expected non-empty CSS output"
      end)
    end

    test "every preset CSS contains :root {" do
      Enum.each(Theme.list(), fn key ->
        css = ThemeCSS.generate(Theme.get!(key))
        assert css =~ ":root {", "#{key}: expected ':root {' in generated CSS"
      end)
    end

    test "every preset CSS contains .dark {" do
      Enum.each(Theme.list(), fn key ->
        css = ThemeCSS.generate(Theme.get!(key))
        assert css =~ ".dark {", "#{key}: expected '.dark {' in generated CSS"
      end)
    end

    test "blue theme CSS contains blue-specific primary color" do
      theme = blue_theme()
      css = ThemeCSS.generate(theme)
      primary_value = Map.get(theme.colors.light, :primary)
      assert css =~ primary_value
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.to_json/1
  # ---------------------------------------------------------------------------

  describe "to_json/1" do
    test "produces a binary string" do
      json = ThemeCSS.to_json(zinc_theme())
      assert is_binary(json)
    end

    test "produces valid JSON (Jason can decode it)" do
      json = ThemeCSS.to_json(zinc_theme())
      assert {:ok, _decoded} = Jason.decode(json)
    end

    test "JSON contains name field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"name\""
    end

    test "JSON contains label field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"label\""
    end

    test "JSON contains colors field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"colors\""
    end

    test "JSON contains radius field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"radius\""
    end

    test "JSON contains typography field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"typography\""
    end

    test "JSON contains shadows field" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"shadows\""
    end

    test "JSON name value is \"zinc\"" do
      json = ThemeCSS.to_json(zinc_theme())
      {:ok, decoded} = Jason.decode(json)
      assert decoded["name"] == "zinc"
    end

    test "JSON contains oklch color values" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "oklch("
    end

    test "JSON contains \"light\" and \"dark\" color sections" do
      json = ThemeCSS.to_json(zinc_theme())
      assert json =~ "\"light\""
      assert json =~ "\"dark\""
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.from_json/1
  # ---------------------------------------------------------------------------

  describe "from_json/1" do
    test "returns a Theme struct from valid JSON" do
      json = ThemeCSS.to_json(zinc_theme())
      result = ThemeCSS.from_json(json)
      assert %Theme{} = result
    end

    test "raises Jason.DecodeError for invalid JSON" do
      assert_raise Jason.DecodeError, fn ->
        ThemeCSS.from_json("not valid json {{{")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.from_json/1 + to_json/1 round-trip
  # ---------------------------------------------------------------------------

  describe "from_json/1 round-trip with to_json/1" do
    setup do
      original = zinc_theme()
      json = ThemeCSS.to_json(original)
      restored = ThemeCSS.from_json(json)
      %{original: original, restored: restored}
    end

    test "name is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.name == o.name
    end

    test "label is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.label == o.label
    end

    test "radius is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.radius == o.radius
    end

    test "light background color is preserved through JSON round-trip", %{
      original: o,
      restored: r
    } do
      assert r.colors.light[:background] == o.colors.light[:background]
    end

    test "dark background color is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.colors.dark[:background] == o.colors.dark[:background]
    end

    test "light primary color is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.colors.light[:primary] == o.colors.light[:primary]
    end

    test "dark primary color is preserved through JSON round-trip", %{original: o, restored: r} do
      assert r.colors.dark[:primary] == o.colors.dark[:primary]
    end

    test "round-trip produces identical to_map output" do
      original = blue_theme()
      restored = original |> ThemeCSS.to_json() |> ThemeCSS.from_json()
      assert Theme.to_map(restored) == Theme.to_map(original)
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate_for_selector/1
  # ---------------------------------------------------------------------------

  describe "generate_for_selector/1" do
    test "contains [data-phia-theme=\"zinc\"] selector" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      assert css =~ ~s([data-phia-theme="zinc"])
    end

    test "contains .dark [data-phia-theme=\"zinc\"] selector" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      assert css =~ ~s(.dark [data-phia-theme="zinc"])
    end

    test "does NOT contain @theme block" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      refute css =~ "@theme {"
    end

    test "does NOT contain :root { selector" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      refute css =~ ":root {"
    end

    test "does NOT contain standalone .dark { selector" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      refute css =~ ~r/^\.dark \{/m
    end

    test "contains light color vars inside attribute selector" do
      theme = zinc_theme()
      css = ThemeCSS.generate_for_selector(theme)
      assert css =~ "--color-background"
      assert css =~ "--color-primary"
    end

    test "contains oklch values" do
      css = ThemeCSS.generate_for_selector(zinc_theme())
      assert css =~ "oklch("
    end

    test "uses theme name in selector (blue theme)" do
      css = ThemeCSS.generate_for_selector(blue_theme())
      assert css =~ ~s([data-phia-theme="blue"])
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate/2 — custom selector opts
  # ---------------------------------------------------------------------------

  describe "generate/2 — custom selector opts" do
    test "default opts produce same output as generate/1" do
      theme = zinc_theme()
      assert ThemeCSS.generate(theme) == ThemeCSS.generate(theme, [])
    end

    test "selector: option overrides :root selector" do
      css = ThemeCSS.generate(zinc_theme(), selector: ".my-scope")
      assert css =~ ".my-scope {"
      refute css =~ ":root {"
    end

    test "dark_selector: option overrides .dark selector" do
      css = ThemeCSS.generate(zinc_theme(), dark_selector: ".night")
      assert css =~ ".night {"
      refute css =~ ".dark {"
    end

    test "include_theme_block: false omits @theme block" do
      css = ThemeCSS.generate(zinc_theme(), include_theme_block: false)
      refute css =~ "@theme {"
    end

    test "include_theme_block: true (default) includes @theme block" do
      css = ThemeCSS.generate(zinc_theme(), include_theme_block: true)
      assert css =~ "@theme {"
    end

    test "all color vars still present with custom selector" do
      css = ThemeCSS.generate(zinc_theme(), selector: "#app")
      assert css =~ "--color-primary"
      assert css =~ "--color-background"
    end
  end

  # ---------------------------------------------------------------------------
  # ThemeCSS.generate_all/1
  # ---------------------------------------------------------------------------

  describe "generate_all/1" do
    test "contains all 8 theme selectors" do
      css = ThemeCSS.generate_all()

      Enum.each(Theme.list(), fn key ->
        assert css =~ ~s([data-phia-theme="#{key}"]), "missing selector for #{key}"
      end)
    end

    test "contains all 8 dark theme selectors" do
      css = ThemeCSS.generate_all()

      Enum.each(Theme.list(), fn key ->
        assert css =~ ~s(.dark [data-phia-theme="#{key}"]), "missing dark selector for #{key}"
      end)
    end

    test "does NOT contain any @theme blocks" do
      css = ThemeCSS.generate_all()
      refute css =~ "@theme {"
    end

    test "does NOT contain :root { selectors" do
      css = ThemeCSS.generate_all()
      refute css =~ ":root {"
    end

    test "contains header comment with usage instructions" do
      css = ThemeCSS.generate_all()
      assert css =~ "PhiaUI Themes"
      assert css =~ "data-phia-theme"
    end

    test "accepts subset of theme atoms" do
      css = ThemeCSS.generate_all([:zinc, :blue])
      assert css =~ ~s([data-phia-theme="zinc"])
      assert css =~ ~s([data-phia-theme="blue"])
      refute css =~ ~s([data-phia-theme="rose"])
    end

    test "accepts list of Theme structs" do
      themes = [Theme.get!(:rose)]
      css = ThemeCSS.generate_all(themes)
      assert css =~ ~s([data-phia-theme="rose"])
      refute css =~ ~s([data-phia-theme="zinc"])
    end

    test "produces non-empty string" do
      css = ThemeCSS.generate_all()
      assert is_binary(css) and byte_size(css) > 100
    end
  end
end
