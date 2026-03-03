defmodule PhiaUi.Theme do
  @moduledoc """
  Theme definition struct and API for PhiaUI.

  A `%PhiaUi.Theme{}` describes a complete visual design system:
  color palettes for light and dark modes, typographic scale, border radius,
  and shadow definitions.

  ## Built-in presets

  Use `PhiaUi.Theme.get/1` to retrieve a built-in preset:

      PhiaUi.Theme.get(:blue)
      PhiaUi.Theme.get(:zinc)

  ## Available presets

  | Key       | Description                       |
  |-----------|-----------------------------------|
  | `:zinc`   | Neutral dark — shadcn/ui default  |
  | `:slate`  | Cool blue-grey                    |
  | `:blue`   | Enterprise blue                   |
  | `:rose`   | Modern rose/pink                  |
  | `:orange` | Energetic orange                  |
  | `:green`  | Success green                     |
  | `:violet` | Premium violet                    |
  | `:neutral`| Pure grey                         |

  ## JSON schema

  Themes can be exported to / imported from JSON via `PhiaUi.ThemeCSS`:

      %{
        "name" => "my-brand",
        "label" => "My Brand",
        "colors" => %{
          "light" => %{"background" => "oklch(1 0 0)", ...},
          "dark"  => %{"background" => "oklch(0.145 0 0)", ...}
        },
        "radius" => "0.5rem",
        "typography" => %{"font_sans" => "Inter, system-ui, sans-serif"}
      }
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

  @type color_map :: %{String.t() => String.t()}

  @type t :: %__MODULE__{
          name: String.t(),
          label: String.t(),
          colors: %{light: color_map(), dark: color_map()},
          radius: String.t(),
          typography: map(),
          shadows: map()
        }

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
  Returns all available preset theme names as a list of atoms.

      iex> PhiaUi.Theme.list()
      [:zinc, :slate, :blue, :rose, :orange, :green, :violet, :neutral]
  """
  @spec list() :: [atom()]
  def list, do: Map.keys(@presets)

  @doc """
  Retrieves a built-in preset theme by key.

  Returns `{:ok, %PhiaUi.Theme{}}` on success, `{:error, :not_found}` for unknown keys.

      iex> {:ok, theme} = PhiaUi.Theme.get(:blue)
      iex> theme.name
      "blue"
  """
  @spec get(atom()) :: {:ok, t()} | {:error, :not_found}
  def get(key) when is_atom(key) do
    case Map.fetch(@presets, key) do
      {:ok, mod} -> {:ok, mod.theme()}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Retrieves a built-in preset theme. Raises if not found.
  """
  @spec get!(atom()) :: t()
  def get!(key) do
    case get(key) do
      {:ok, theme} -> theme
      {:error, :not_found} -> raise ArgumentError, "Unknown theme preset: #{inspect(key)}"
    end
  end

  @doc """
  Creates a `%PhiaUi.Theme{}` from a JSON-decoded map.

  Accepts string keys as produced by `Jason.decode/1`.
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

  @doc "Converts a `%PhiaUi.Theme{}` to a JSON-serialisable map."
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

  defp atomise_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  rescue
    ArgumentError -> Map.new(map, fn {k, v} -> {k, v} end)
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end
end
