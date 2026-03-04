defmodule PhiaUi.ThemeCSS do
  @moduledoc """
  Generates CSS custom property declarations from a `%PhiaUi.Theme{}` struct.

  This module is responsible for converting PhiaUI theme data into valid CSS
  strings. It supports three output modes that cover the most common scenarios:

  ## 1. Root-scoped CSS (single active theme)

  Use `generate/2` when you want one theme to apply globally to your
  application. The output uses `:root` and `.dark` selectors.

      theme = PhiaUi.Theme.get!(:blue)
      css = PhiaUi.ThemeCSS.generate(theme)
      # => "/* PhiaUI Theme: Blue */\\n@theme { ... }\\n:root { ... }\\n.dark { ... }"

  Inject the output as a `<style>` tag or write it to `assets/css/theme.css`
  via `mix phia.theme apply blue`.

  ## 2. Attribute-scoped CSS (multi-theme, one theme per block)

  Use `generate_for_selector/1` to scope a theme to a `[data-phia-theme]`
  attribute selector instead of `:root`. This is the format used by
  `mix phia.theme install`.

      css = PhiaUi.ThemeCSS.generate_for_selector(theme)
      # => ~s([data-phia-theme="blue"] { ... }\\n.dark [data-phia-theme="blue"] { ... })

  The resulting CSS is activated by setting the `data-phia-theme` attribute on
  any ancestor element:

      <html data-phia-theme="blue" class="dark">

  ## 3. All themes in one file

  Use `generate_all/1` to combine every preset into a single CSS file, each
  scoped to its own `[data-phia-theme]` selector. This is the output of
  `mix phia.theme install`.

      css = PhiaUi.ThemeCSS.generate_all()
      # => one block per theme, sorted alphabetically

      # Or for a subset of presets:
      css = PhiaUi.ThemeCSS.generate_all([:zinc, :blue])

  ## JSON round-trip

  Themes can be serialised to JSON and back for storage, sharing, or editing:

      json  = PhiaUi.ThemeCSS.to_json(theme)
      theme = PhiaUi.ThemeCSS.from_json(json)

  ## CSS custom property naming convention

  Color tokens use `--color-{name}` with underscores replaced by hyphens:

  - `:card_foreground` → `--color-card-foreground`
  - `:primary` → `--color-primary`
  - `:sidebar_background` → `--color-sidebar-background`

  Non-color tokens (radius, typography) are emitted inside an `@theme { }`
  block using the `--radius` and `--font-*` naming scheme.
  """

  alias PhiaUi.Theme

  @doc """
  Generates a CSS string from a `%PhiaUi.Theme{}` struct.

  Produces:

  - An optional `@theme { }` block with radius and typography tokens (controlled
    by the `:include_theme_block` option).
  - A light-mode block using the `:selector` (default `":root"`).
  - A dark-mode block using the `:dark_selector` (default `".dark"`).

  ## Options

  - `:selector` — CSS selector for light-mode variables (default: `":root"`)
  - `:dark_selector` — CSS selector for dark-mode variables (default: `".dark"`)
  - `:include_theme_block` — emit the `@theme { }` block (default: `true`)

  ## Examples

      iex> theme = PhiaUi.Theme.get!(:zinc)
      iex> css = PhiaUi.ThemeCSS.generate(theme)
      iex> String.contains?(css, ":root {")
      true
      iex> String.contains?(css, ".dark {")
      true
      iex> String.contains?(css, "@theme {")
      true

  Override the selector for a custom scope:

      iex> theme = PhiaUi.Theme.get!(:blue)
      iex> css = PhiaUi.ThemeCSS.generate(theme, selector: "#app", dark_selector: "#app.dark")
      iex> String.contains?(css, "#app {")
      true

  Omit the `@theme` block when composing multiple themes:

      iex> theme = PhiaUi.Theme.get!(:rose)
      iex> css = PhiaUi.ThemeCSS.generate(theme, include_theme_block: false)
      iex> String.contains?(css, "@theme {")
      false
  """
  @spec generate(Theme.t(), keyword()) :: String.t()
  def generate(%Theme{} = theme, opts \\ []) do
    selector = Keyword.get(opts, :selector, ":root")
    dark_selector = Keyword.get(opts, :dark_selector, ".dark")
    include_theme_block = Keyword.get(opts, :include_theme_block, true)

    light_vars = color_vars(theme.colors.light)
    dark_vars = color_vars(theme.colors.dark)

    theme_block =
      if include_theme_block do
        """
        @theme {
        #{theme_vars(theme)}}

        """
      else
        ""
      end

    """
    /* PhiaUI Theme: #{theme.label} */
    #{theme_block}#{selector} {
    #{light_vars}}

    #{dark_selector} {
    #{dark_vars}}
    """
  end

  @doc """
  Generates a CSS string scoped to `[data-phia-theme="<name>"]` attribute
  selectors, without any `@theme { }` block or `:root` selector.

  This is the multi-theme format: multiple themes can coexist in the same CSS
  file, each activated by setting `data-phia-theme` on an ancestor element.
  Dark mode is handled by prefixing the selector with `.dark`.

  The output for the `:blue` theme looks like:

      [data-phia-theme="blue"] {
        --color-background: oklch(1 0 0);
        --color-primary: oklch(0.546 0.245 262.881);
        ...
      }

      .dark [data-phia-theme="blue"] {
        --color-background: oklch(0.145 0.01 237.938);
        ...
      }

  ## Example

      iex> theme = PhiaUi.Theme.get!(:blue)
      iex> css = PhiaUi.ThemeCSS.generate_for_selector(theme)
      iex> String.contains?(css, ~s([data-phia-theme="blue"]))
      true
      iex> String.contains?(css, ~s(.dark [data-phia-theme="blue"]))
      true
  """
  @spec generate_for_selector(Theme.t()) :: String.t()
  def generate_for_selector(%Theme{} = theme) do
    light_selector = ~s([data-phia-theme="#{theme.name}"])
    dark_selector = ~s(.dark [data-phia-theme="#{theme.name}"])

    light_vars = color_vars(theme.colors.light)
    dark_vars = color_vars(theme.colors.dark)

    """
    /* PhiaUI Theme: #{theme.label} */
    #{light_selector} {
    #{light_vars}}

    #{dark_selector} {
    #{dark_vars}}
    """
  end

  @doc """
  Generates a complete CSS string containing all (or a selected subset of)
  themes, each scoped to its `[data-phia-theme]` attribute selector.

  This is the output written by `mix phia.theme install`. The resulting file
  is designed to be imported into `assets/css/app.css` and does not contain
  any `@theme { }` blocks — those remain in the base `theme.css`.

  Themes are sorted alphabetically by name for deterministic, diffable output.

  ## Arguments

  - `nil` (default) — includes all built-in presets from `Theme.list/0`.
  - A list of atoms, e.g. `[:zinc, :blue, :rose]` — loads those named presets.
  - A list of `%Theme{}` structs — uses the structs directly (custom themes).

  ## Examples

      iex> css = PhiaUi.ThemeCSS.generate_all()
      iex> String.contains?(css, ~s([data-phia-theme="zinc"]))
      true
      iex> String.contains?(css, ~s([data-phia-theme="blue"]))
      true

  Subset of themes:

      iex> css = PhiaUi.ThemeCSS.generate_all([:zinc, :blue])
      iex> String.contains?(css, ~s([data-phia-theme="zinc"]))
      true
      iex> String.contains?(css, ~s([data-phia-theme="rose"]))
      false

  The generated file begins with a usage comment:

      /* PhiaUI Themes — generated by mix phia.theme install
       * Usage: import this file and set data-phia-theme on any ancestor element
       * Example: <html data-phia-theme="blue" class="dark">
       */
  """
  @spec generate_all([atom() | Theme.t()] | nil) :: String.t()
  def generate_all(themes \\ nil) do
    resolved =
      themes
      |> resolve_themes()
      |> Enum.sort_by(fn %Theme{name: name} -> name end)

    header = """
    /* PhiaUI Themes — generated by mix phia.theme install
     * Usage: import this file and set data-phia-theme on any ancestor element
     * Example: <html data-phia-theme="blue" class="dark">
     */
    """

    body = Enum.map_join(resolved, "\n", &generate_for_selector/1)

    header <> "\n" <> body
  end

  @doc """
  Serialises a `%PhiaUi.Theme{}` to a pretty-printed JSON string.

  The output can be redirected to a file and later restored with `from_json/1`
  or passed to `mix phia.theme import`. Requires `:jason` as a dependency
  (available as a transitive dependency of Phoenix).

  ## Example

      iex> theme = PhiaUi.Theme.get!(:zinc)
      iex> json = PhiaUi.ThemeCSS.to_json(theme)
      iex> String.contains?(json, "\\"name\\"")
      true
      iex> String.contains?(json, "\\"zinc\\"")
      true
  """
  @spec to_json(Theme.t()) :: String.t()
  def to_json(%Theme{} = theme) do
    theme
    |> Theme.to_map()
    |> Jason.encode!(pretty: true)
  end

  @doc """
  Deserialises a JSON string into a `%PhiaUi.Theme{}` struct.

  Expects the JSON schema produced by `to_json/1`. Raises `Jason.DecodeError`
  for malformed JSON and `KeyError` if required fields (`name`, `label`,
  `colors`) are missing.

  ## Example

      iex> theme = PhiaUi.Theme.get!(:zinc)
      iex> json = PhiaUi.ThemeCSS.to_json(theme)
      iex> restored = PhiaUi.ThemeCSS.from_json(json)
      iex> restored.name
      "zinc"
      iex> restored.label
      "Zinc"
  """
  @spec from_json(String.t()) :: Theme.t()
  def from_json(json) when is_binary(json) do
    json
    |> Jason.decode!()
    |> Theme.from_map()
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Normalises the `themes` argument of `generate_all/1` into a list of
  # `%Theme{}` structs. Handles nil (all presets), atom keys, and Theme structs.
  defp resolve_themes(nil) do
    Theme.list() |> Enum.map(&Theme.get!/1)
  end

  defp resolve_themes(list) when is_list(list) do
    Enum.map(list, fn
      %Theme{} = theme -> theme
      key when is_atom(key) -> Theme.get!(key)
    end)
  end

  # Converts a color map (atom-keyed) into sorted CSS custom property lines.
  #
  # Sorting by key name ensures deterministic output across Elixir versions,
  # which is important for diffing generated CSS files in version control.
  # Underscores in key names are converted to hyphens to match CSS conventions:
  #   :card_foreground → --color-card-foreground
  defp color_vars(colors) when is_map(colors) do
    colors
    |> Enum.sort_by(fn {k, _} -> to_string(k) end)
    |> Enum.map_join("", fn {key, value} ->
      css_key = key |> to_string() |> String.replace("_", "-")
      "  --color-#{css_key}: #{value};\n"
    end)
  end

  # Converts radius and typography fields into @theme-compatible CSS lines.
  #
  # The `--radius` variable sets the base corner radius used by all components.
  # Typography keys follow the same underscore-to-hyphen convention as colors:
  #   :font_sans → --font-sans
  #   :font_mono → --font-mono
  defp theme_vars(%Theme{} = theme) do
    radius_line = "  --radius: #{theme.radius};\n"

    font_lines =
      theme.typography
      |> Enum.sort_by(fn {k, _} -> to_string(k) end)
      |> Enum.map_join("", fn {key, value} ->
        css_key = key |> to_string() |> String.replace("_", "-")
        "  --#{css_key}: #{value};\n"
      end)

    radius_line <> font_lines
  end
end
