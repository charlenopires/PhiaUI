defmodule PhiaUi.Theme.ThemeCSSTest do
  use ExUnit.Case, async: true

  @theme_path Path.join([File.cwd!(), "priv/templates/theme/theme.css"])

  @light_tokens ~w(
    --color-background
    --color-foreground
    --color-card
    --color-card-foreground
    --color-popover
    --color-popover-foreground
    --color-primary
    --color-primary-foreground
    --color-secondary
    --color-secondary-foreground
    --color-muted
    --color-muted-foreground
    --color-accent
    --color-accent-foreground
    --color-destructive
    --color-destructive-foreground
    --color-border
    --color-input
    --color-ring
  )

  setup_all do
    assert File.exists?(@theme_path),
           "Expected #{@theme_path} to exist"

    {:ok, css: File.read!(@theme_path)}
  end

  describe "file structure" do
    test "contains @theme block", %{css: css} do
      assert css =~ "@theme {"
    end

    test "contains dark mode media query", %{css: css} do
      assert css =~ "@media (prefers-color-scheme: dark)"
    end
  end

  describe "light mode tokens (task #2)" do
    test "all 19 required tokens are defined", %{css: css} do
      Enum.each(@light_tokens, fn token ->
        assert css =~ token,
               "Expected light token '#{token}' to be present in theme.css"
      end)
    end

    test "token values use oklch() format", %{css: css} do
      assert css =~ "oklch(",
             "Expected token values to use oklch() color format"
    end

    test "has exactly 19 light mode tokens", %{css: css} do
      count = Enum.count(@light_tokens, fn token -> css =~ token end)
      assert count == 19
    end
  end

  describe "dark mode tokens (task #3)" do
    test "dark mode block redefines background token", %{css: css} do
      [_light, dark_section] = String.split(css, "@media (prefers-color-scheme: dark)", parts: 2)
      assert dark_section =~ "--color-background:"
    end

    test "dark mode block redefines foreground token", %{css: css} do
      [_light, dark_section] = String.split(css, "@media (prefers-color-scheme: dark)", parts: 2)
      assert dark_section =~ "--color-foreground:"
    end

    test "dark mode block uses oklch() values", %{css: css} do
      [_light, dark_section] = String.split(css, "@media (prefers-color-scheme: dark)", parts: 2)
      assert dark_section =~ "oklch("
    end
  end

  describe "--radius token (task #4)" do
    test "defines --radius", %{css: css} do
      assert css =~ "--radius:"
    end

    test "--radius value is 0.625rem", %{css: css} do
      assert css =~ "--radius: 0.625rem"
    end
  end

  describe "sidebar token (task #5)" do
    test "defines --color-sidebar-background", %{css: css} do
      assert css =~ "--color-sidebar-background:"
    end

    test "sidebar token is present in dark mode too", %{css: css} do
      [_light, dark_section] = String.split(css, "@media (prefers-color-scheme: dark)", parts: 2)
      assert dark_section =~ "--color-sidebar-background:"
    end
  end

  describe "no hardcoded palette colors" do
    test "does not use hex color values", %{css: css} do
      refute css =~ ~r/#[0-9a-fA-F]{3,6}\b/
    end
  end
end
