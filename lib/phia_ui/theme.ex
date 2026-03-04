defmodule PhiaUi.Theme do
  @moduledoc """
  Theme definition struct and API for PhiaUI.

  A `%PhiaUi.Theme{}` describes a complete visual design system: color palettes
  for light and dark modes, typographic scale, border radius, and shadow
  definitions.

  ## Color format

  All color values use **OKLCH** notation (CSS Color Level 4), for example:

      "oklch(0.546 0.245 262.881)"

  OKLCH is a perceptually uniform color space that provides:

  - **Wider gamut** — can express P3 and Rec2020 colors beyond sRGB.
  - **Perceptual uniformity** — equal numeric steps produce equal perceptual
    differences, making it easy to construct accessible color ramps.
  - **Predictable lightness** — the `L` channel maps directly to human-perceived
    lightness, so dark-mode pairs are straightforward to reason about.

  ## Color token mapping

  Each theme defines the following semantic tokens (both light and dark variants):

  | Token                  | Usage                                              |
  |------------------------|----------------------------------------------------|
  | `background`           | Page / panel background                            |
  | `foreground`           | Default text color                                 |
  | `card`                 | Card surface background                            |
  | `card_foreground`      | Text on cards                                      |
  | `popover`              | Popover / dropdown background                      |
  | `popover_foreground`   | Text in popovers                                   |
  | `primary`              | Primary action color (buttons, links)              |
  | `primary_foreground`   | Text on primary-colored surfaces                   |
  | `secondary`            | Secondary / subtle surface                         |
  | `secondary_foreground` | Text on secondary surfaces                         |
  | `muted`                | Muted / disabled surface                           |
  | `muted_foreground`     | Muted / placeholder text                           |
  | `accent`               | Hover / focus highlight surface                    |
  | `accent_foreground`    | Text on accent surfaces                            |
  | `destructive`          | Error / delete action color                        |
  | `destructive_foreground` | Text on destructive surfaces                     |
  | `border`               | Default border color                               |
  | `input`                | Form input border color                            |
  | `ring`                 | Focus ring color                                   |
  | `sidebar_background`   | Sidebar / navigation rail background               |

  Token keys with underscores (e.g., `card_foreground`) are converted to
  hyphenated CSS custom properties (e.g., `--color-card-foreground`) by
  `PhiaUi.ThemeCSS`.

  ## Built-in presets

  Use `PhiaUi.Theme.get/1` to retrieve a built-in preset by atom key:

      {:ok, theme} = PhiaUi.Theme.get(:blue)
      {:ok, theme} = PhiaUi.Theme.get(:zinc)

  ## Available presets

  | Key        | Description                              |
  |------------|------------------------------------------|
  | `:zinc`    | Neutral dark — shadcn/ui default         |
  | `:slate`   | Cool blue-grey, slightly cooler than zinc|
  | `:blue`    | Enterprise blue, vibrant primary         |
  | `:rose`    | Modern rose/pink, warm and playful       |
  | `:orange`  | Energetic orange, bold and attention-    |
  | `:green`   | Success green, calm and natural          |
  | `:violet`  | Premium violet, creative and distinctive |
  | `:neutral` | Pure achromatic grey, zero chroma        |

  ## JSON schema

  Themes can be serialised to / deserialised from JSON via `PhiaUi.ThemeCSS`:

      %{
        "name"  => "my-brand",
        "label" => "My Brand",
        "colors" => %{
          "light" => %{"background" => "oklch(1 0 0)", ...},
          "dark"  => %{"background" => "oklch(0.145 0 0)", ...}
        },
        "radius"     => "0.5rem",
        "typography" => %{"font_sans" => "Inter, system-ui, sans-serif"},
        "shadows"    => %{}
      }

  ## Custom themes

  You can construct a `%PhiaUi.Theme{}` directly and pass it to
  `PhiaUi.ThemeCSS.generate/2`:

      theme = %PhiaUi.Theme{
        name: "brand",
        label: "Acme Brand",
        radius: "0.25rem",
        colors: %{
          light: %{background: "oklch(1 0 0)", primary: "oklch(0.6 0.2 30)", ...},
          dark:  %{background: "oklch(0.1 0 0)", primary: "oklch(0.6 0.2 30)", ...}
        }
      }

      css = PhiaUi.ThemeCSS.generate(theme)
  """

  @enforce_keys [:name, :label, :colors, :radius]
  defstruct [
    :name,
    :label,
    :colors,
    radius: "0.625rem",
    typography: %{},
    shadows: %{}
  ]

  @type color_map :: %{atom() => String.t()}

  @type t :: %__MODULE__{
          name: String.t(),
          label: String.t(),
          colors: %{light: color_map(), dark: color_map()},
          radius: String.t(),
          typography: map(),
          shadows: map()
        }

  # Maps the preset atom keys used in the public API to the module that
  # implements the `theme/0` callback. Keeping this as a compile-time map
  # means `Theme.get/1` is a simple map lookup with no runtime dispatch.
  @presets %{
    zinc: PhiaUi.Themes.Zinc,
    slate: PhiaUi.Themes.Slate,
    blue: PhiaUi.Themes.Blue,
    rose: PhiaUi.Themes.Rose,
    orange: PhiaUi.Themes.Orange,
    green: PhiaUi.Themes.Green,
    violet: PhiaUi.Themes.Violet,
    neutral: PhiaUi.Themes.Neutral
  }

  @doc """
  Returns all available built-in preset theme names as a list of atoms.

  The order is not guaranteed; sort the result if you need stable ordering.

  ## Example

      iex> themes = PhiaUi.Theme.list()
      iex> :zinc in themes
      true
      iex> :blue in themes
      true
  """
  @spec list() :: [atom()]
  def list, do: Map.keys(@presets)

  @doc """
  Retrieves a built-in preset theme by its atom key.

  Returns `{:ok, %PhiaUi.Theme{}}` on success or `{:error, :not_found}` when
  the key is not a known preset.

  ## Examples

      iex> {:ok, theme} = PhiaUi.Theme.get(:blue)
      iex> theme.name
      "blue"
      iex> theme.label
      "Blue"

      iex> PhiaUi.Theme.get(:unknown)
      {:error, :not_found}
  """
  @spec get(atom()) :: {:ok, t()} | {:error, :not_found}
  def get(key) when is_atom(key) do
    case Map.fetch(@presets, key) do
      {:ok, mod} -> {:ok, mod.theme()}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Retrieves a built-in preset theme by its atom key, raising on failure.

  Prefer `get/1` in application code. Use this variant in scripts or tests
  where a missing theme is a programming error.

  ## Examples

      iex> theme = PhiaUi.Theme.get!(:zinc)
      iex> theme.name
      "zinc"

  Raises `ArgumentError` for unknown keys:

      iex> PhiaUi.Theme.get!(:unknown)
      ** (ArgumentError) Unknown theme preset: :unknown
  """
  @spec get!(atom()) :: t()
  def get!(key) do
    case get(key) do
      {:ok, theme} -> theme
      {:error, :not_found} -> raise ArgumentError, "Unknown theme preset: #{inspect(key)}"
    end
  end

  @doc """
  Creates a `%PhiaUi.Theme{}` struct from a JSON-decoded map.

  Accepts string keys as produced by `Jason.decode/1`. Both light and dark
  color maps are converted to atom-keyed maps internally (e.g.,
  `"card_foreground"` becomes `:card_foreground`).

  Falls back to sensible defaults when optional fields (`radius`, `typography`,
  `shadows`) are absent from the map.

  ## Example

      iex> map = %{
      ...>   "name" => "custom",
      ...>   "label" => "Custom",
      ...>   "colors" => %{
      ...>     "light" => %{"background" => "oklch(1 0 0)"},
      ...>     "dark"  => %{"background" => "oklch(0.1 0 0)"}
      ...>   }
      ...> }
      iex> theme = PhiaUi.Theme.from_map(map)
      iex> theme.name
      "custom"
  """
  @spec from_map(map()) :: t()
  def from_map(%{"name" => name, "label" => label, "colors" => colors} = map) do
    light = Map.get(colors, "light", %{})
    dark = Map.get(colors, "dark", %{})

    %__MODULE__{
      name: name,
      label: label,
      colors: %{light: atomise_keys(light), dark: atomise_keys(dark)},
      radius: Map.get(map, "radius", "0.625rem"),
      typography: map |> Map.get("typography", %{}) |> atomise_keys(),
      shadows: map |> Map.get("shadows", %{}) |> atomise_keys()
    }
  end

  @doc """
  Converts a `%PhiaUi.Theme{}` to a JSON-serialisable map with string keys.

  The output map is suitable for passing to `Jason.encode!/1` or for storing
  in a database. Atom keys in `colors`, `typography`, and `shadows` are
  stringified.

  ## Example

      iex> theme = PhiaUi.Theme.get!(:zinc)
      iex> map = PhiaUi.Theme.to_map(theme)
      iex> map["name"]
      "zinc"
      iex> is_map(map["colors"]["light"])
      true
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = theme) do
    %{
      "name" => theme.name,
      "label" => theme.label,
      "colors" => %{
        "light" => stringify_keys(theme.colors.light),
        "dark" => stringify_keys(theme.colors.dark)
      },
      "radius" => theme.radius,
      "typography" => stringify_keys(theme.typography),
      "shadows" => stringify_keys(theme.shadows)
    }
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Converts string-keyed maps (from JSON decoding) to atom-keyed maps.
  #
  # Uses `String.to_existing_atom/1` to prevent atom table exhaustion from
  # untrusted input. If an unknown key is encountered (e.g., from a future
  # theme format), falls back to keeping the original string keys.
  defp atomise_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  rescue
    # An unrecognised key (not yet in the atom table) would raise ArgumentError.
    # In that case we keep the original string key so the rest of the map is
    # still usable.
    ArgumentError -> Map.new(map, fn {k, v} -> {k, v} end)
  end

  # Converts atom-keyed maps to string-keyed maps for JSON serialisation.
  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end
end
