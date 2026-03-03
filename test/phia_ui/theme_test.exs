defmodule PhiaUi.ThemeTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Theme

  # ---------------------------------------------------------------------------
  # Theme.list/0
  # ---------------------------------------------------------------------------

  describe "list/0" do
    test "returns exactly 8 preset keys" do
      assert length(Theme.list()) == 8
    end

    test "includes :zinc" do
      assert :zinc in Theme.list()
    end

    test "includes :slate" do
      assert :slate in Theme.list()
    end

    test "includes :blue" do
      assert :blue in Theme.list()
    end

    test "includes :rose" do
      assert :rose in Theme.list()
    end

    test "includes :orange" do
      assert :orange in Theme.list()
    end

    test "includes :green" do
      assert :green in Theme.list()
    end

    test "includes :violet" do
      assert :violet in Theme.list()
    end

    test "includes :neutral" do
      assert :neutral in Theme.list()
    end

    test "returns a list of atoms" do
      assert Enum.all?(Theme.list(), &is_atom/1)
    end
  end

  # ---------------------------------------------------------------------------
  # Theme.get/1
  # ---------------------------------------------------------------------------

  describe "get/1 with valid keys" do
    test "returns {:ok, theme} for :zinc" do
      assert {:ok, %Theme{}} = Theme.get(:zinc)
    end

    test "returns {:ok, theme} for :slate" do
      assert {:ok, %Theme{}} = Theme.get(:slate)
    end

    test "returns {:ok, theme} for :blue" do
      assert {:ok, %Theme{}} = Theme.get(:blue)
    end

    test "returns {:ok, theme} for :rose" do
      assert {:ok, %Theme{}} = Theme.get(:rose)
    end

    test "returns {:ok, theme} for :orange" do
      assert {:ok, %Theme{}} = Theme.get(:orange)
    end

    test "returns {:ok, theme} for :green" do
      assert {:ok, %Theme{}} = Theme.get(:green)
    end

    test "returns {:ok, theme} for :violet" do
      assert {:ok, %Theme{}} = Theme.get(:violet)
    end

    test "returns {:ok, theme} for :neutral" do
      assert {:ok, %Theme{}} = Theme.get(:neutral)
    end
  end

  describe "get/1 with invalid key" do
    test "returns {:error, :not_found} for unknown atom" do
      assert {:error, :not_found} = Theme.get(:does_not_exist)
    end

    test "returns {:error, :not_found} for :purple" do
      assert {:error, :not_found} = Theme.get(:purple)
    end

    test "returns {:error, :not_found} for :dark" do
      assert {:error, :not_found} = Theme.get(:dark)
    end
  end

  # ---------------------------------------------------------------------------
  # Theme.get!/1
  # ---------------------------------------------------------------------------

  describe "get!/1 with valid keys" do
    test "returns theme struct for :zinc" do
      theme = Theme.get!(:zinc)
      assert %Theme{} = theme
    end

    test "returns theme struct for :blue" do
      theme = Theme.get!(:blue)
      assert %Theme{} = theme
    end

    test "returns theme struct for :slate" do
      theme = Theme.get!(:slate)
      assert %Theme{} = theme
    end
  end

  describe "get!/1 with invalid key" do
    test "raises ArgumentError for unknown key" do
      assert_raise ArgumentError, fn ->
        Theme.get!(:does_not_exist)
      end
    end

    test "error message includes the unknown key" do
      assert_raise ArgumentError, ~r/does_not_exist/, fn ->
        Theme.get!(:does_not_exist)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Preset name fields
  # ---------------------------------------------------------------------------

  describe "preset name fields" do
    test "zinc theme has name \"zinc\"" do
      {:ok, theme} = Theme.get(:zinc)
      assert theme.name == "zinc"
    end

    test "slate theme has name \"slate\"" do
      {:ok, theme} = Theme.get(:slate)
      assert theme.name == "slate"
    end

    test "blue theme has name \"blue\"" do
      {:ok, theme} = Theme.get(:blue)
      assert theme.name == "blue"
    end

    test "rose theme has name \"rose\"" do
      {:ok, theme} = Theme.get(:rose)
      assert theme.name == "rose"
    end

    test "orange theme has name \"orange\"" do
      {:ok, theme} = Theme.get(:orange)
      assert theme.name == "orange"
    end

    test "green theme has name \"green\"" do
      {:ok, theme} = Theme.get(:green)
      assert theme.name == "green"
    end

    test "violet theme has name \"violet\"" do
      {:ok, theme} = Theme.get(:violet)
      assert theme.name == "violet"
    end

    test "neutral theme has name \"neutral\"" do
      {:ok, theme} = Theme.get(:neutral)
      assert theme.name == "neutral"
    end
  end

  # ---------------------------------------------------------------------------
  # Preset struct fields — zinc as canonical reference
  # ---------------------------------------------------------------------------

  describe "zinc preset struct" do
    setup do
      {:ok, theme} = Theme.get(:zinc)
      %{theme: theme}
    end

    test "has a non-empty label", %{theme: theme} do
      assert is_binary(theme.label) and byte_size(theme.label) > 0
    end

    test "has a radius string", %{theme: theme} do
      assert is_binary(theme.radius)
    end

    test "has light color map", %{theme: theme} do
      assert is_map(theme.colors.light)
      refute map_size(theme.colors.light) == 0
    end

    test "has dark color map", %{theme: theme} do
      assert is_map(theme.colors.dark)
      refute map_size(theme.colors.dark) == 0
    end

    test "light colors include :background", %{theme: theme} do
      assert Map.has_key?(theme.colors.light, :background)
    end

    test "light colors include :primary", %{theme: theme} do
      assert Map.has_key?(theme.colors.light, :primary)
    end

    test "dark colors include :background", %{theme: theme} do
      assert Map.has_key?(theme.colors.dark, :background)
    end

    test "dark colors include :primary", %{theme: theme} do
      assert Map.has_key?(theme.colors.dark, :primary)
    end

    test "has typography map", %{theme: theme} do
      assert is_map(theme.typography)
    end

    test "has shadows map", %{theme: theme} do
      assert is_map(theme.shadows)
    end
  end

  # ---------------------------------------------------------------------------
  # Theme.to_map/1
  # ---------------------------------------------------------------------------

  describe "to_map/1" do
    setup do
      {:ok, theme} = Theme.get(:zinc)
      %{theme: theme, map: Theme.to_map(theme)}
    end

    test "produces a map", %{map: map} do
      assert is_map(map)
    end

    test "map has \"name\" key", %{map: map} do
      assert Map.has_key?(map, "name")
    end

    test "map has \"label\" key", %{map: map} do
      assert Map.has_key?(map, "label")
    end

    test "map has \"colors\" key", %{map: map} do
      assert Map.has_key?(map, "colors")
    end

    test "map has \"radius\" key", %{map: map} do
      assert Map.has_key?(map, "radius")
    end

    test "map has \"typography\" key", %{map: map} do
      assert Map.has_key?(map, "typography")
    end

    test "map has \"shadows\" key", %{map: map} do
      assert Map.has_key?(map, "shadows")
    end

    test "colors map has \"light\" key", %{map: map} do
      assert Map.has_key?(map["colors"], "light")
    end

    test "colors map has \"dark\" key", %{map: map} do
      assert Map.has_key?(map["colors"], "dark")
    end

    test "name value is a binary", %{map: map} do
      assert is_binary(map["name"])
    end

    test "name value equals zinc", %{map: map} do
      assert map["name"] == "zinc"
    end

    test "light colors have string keys", %{map: map} do
      light = map["colors"]["light"]
      assert Enum.all?(Map.keys(light), &is_binary/1)
    end

    test "dark colors have string keys", %{map: map} do
      dark = map["colors"]["dark"]
      assert Enum.all?(Map.keys(dark), &is_binary/1)
    end

    test "light colors include \"background\"", %{map: map} do
      assert Map.has_key?(map["colors"]["light"], "background")
    end

    test "light colors include \"primary\"", %{map: map} do
      assert Map.has_key?(map["colors"]["light"], "primary")
    end
  end

  # ---------------------------------------------------------------------------
  # Theme.from_map/1 round-trip
  # ---------------------------------------------------------------------------

  describe "from_map/1 round-trip with to_map/1" do
    setup do
      {:ok, original} = Theme.get(:zinc)
      map = Theme.to_map(original)
      restored = Theme.from_map(map)
      %{original: original, map: map, restored: restored}
    end

    test "returns a Theme struct", %{restored: restored} do
      assert %Theme{} = restored
    end

    test "name is preserved", %{original: original, restored: restored} do
      assert restored.name == original.name
    end

    test "label is preserved", %{original: original, restored: restored} do
      assert restored.label == original.label
    end

    test "radius is preserved", %{original: original, restored: restored} do
      assert restored.radius == original.radius
    end

    test "light background color is preserved", %{original: original, restored: restored} do
      assert restored.colors.light[:background] == original.colors.light[:background]
    end

    test "dark background color is preserved", %{original: original, restored: restored} do
      assert restored.colors.dark[:background] == original.colors.dark[:background]
    end

    test "light primary color is preserved", %{original: original, restored: restored} do
      assert restored.colors.light[:primary] == original.colors.light[:primary]
    end

    test "dark primary color is preserved", %{original: original, restored: restored} do
      assert restored.colors.dark[:primary] == original.colors.dark[:primary]
    end
  end

  describe "from_map/1 with custom map" do
    test "builds struct from minimal map" do
      map = %{
        "name" => "custom",
        "label" => "Custom",
        "colors" => %{
          "light" => %{"background" => "oklch(1 0 0)", "foreground" => "oklch(0.1 0 0)"},
          "dark" => %{"background" => "oklch(0.1 0 0)", "foreground" => "oklch(1 0 0)"}
        },
        "radius" => "0.5rem"
      }

      theme = Theme.from_map(map)

      assert %Theme{} = theme
      assert theme.name == "custom"
      assert theme.label == "Custom"
      assert theme.radius == "0.5rem"
    end

    test "uses default radius when not provided" do
      map = %{
        "name" => "minimal",
        "label" => "Minimal",
        "colors" => %{"light" => %{}, "dark" => %{}}
      }

      theme = Theme.from_map(map)

      assert theme.radius == "0.625rem"
    end

    test "uses empty map for typography when not provided" do
      map = %{
        "name" => "minimal",
        "label" => "Minimal",
        "colors" => %{"light" => %{}, "dark" => %{}}
      }

      theme = Theme.from_map(map)

      assert theme.typography == %{}
    end

    test "uses empty map for shadows when not provided" do
      map = %{
        "name" => "minimal",
        "label" => "Minimal",
        "colors" => %{"light" => %{}, "dark" => %{}}
      }

      theme = Theme.from_map(map)

      assert theme.shadows == %{}
    end
  end

  # ---------------------------------------------------------------------------
  # All presets — structural completeness
  # ---------------------------------------------------------------------------

  describe "all presets structural completeness" do
    test "every preset has both light and dark color maps" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)
        assert is_map(theme.colors.light), "#{key}: expected light color map"
        assert is_map(theme.colors.dark), "#{key}: expected dark color map"
        refute map_size(theme.colors.light) == 0, "#{key}: expected non-empty light map"
        refute map_size(theme.colors.dark) == 0, "#{key}: expected non-empty dark map"
      end)
    end

    test "every preset light map includes :background and :primary" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)

        assert Map.has_key?(theme.colors.light, :background),
               "#{key}: missing :background in light"

        assert Map.has_key?(theme.colors.light, :primary), "#{key}: missing :primary in light"
      end)
    end

    test "every preset dark map includes :background and :primary" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)
        assert Map.has_key?(theme.colors.dark, :background), "#{key}: missing :background in dark"
        assert Map.has_key?(theme.colors.dark, :primary), "#{key}: missing :primary in dark"
      end)
    end

    test "every preset has a non-empty name matching its key" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)
        assert theme.name == to_string(key), "#{key}: expected name '#{key}', got '#{theme.name}'"
      end)
    end

    test "every preset has a non-empty label" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)

        assert is_binary(theme.label) and byte_size(theme.label) > 0,
               "#{key}: expected non-empty label"
      end)
    end

    test "every preset color value uses oklch format" do
      Enum.each(Theme.list(), fn key ->
        {:ok, theme} = Theme.get(key)

        Enum.each(theme.colors.light, fn {color_key, value} ->
          assert String.starts_with?(value, "oklch("),
                 "#{key} light :#{color_key}: expected oklch value, got '#{value}'"
        end)
      end)
    end
  end
end
