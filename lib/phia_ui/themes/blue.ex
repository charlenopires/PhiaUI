defmodule PhiaUi.Themes.Blue do
  @moduledoc """
  The **Blue** color preset — enterprise blue with a vibrant primary.

  ## Design language

  Blue uses a cool, corporate palette centred on a saturated cobalt blue
  primary (hue angle ~263°, high chroma ~0.245). The accent and secondary
  surfaces carry a subtle blue tint to reinforce the brand color without
  overwhelming content.

  Use Blue when you want:

  - A trustworthy, professional feel common in SaaS, fintech, and enterprise
    applications.
  - A strong, recognisable primary color that clearly identifies interactive
    elements.
  - Good contrast with both white and near-black dark backgrounds.

  ## Color values

  All values are encoded in **OKLCH** (CSS Color Level 4). The three numeric
  arguments are:

  - **L** — perceived lightness, 0 (black) to 1 (white)
  - **C** — chroma (color saturation), 0 = achromatic grey
  - **H** — hue angle in degrees (0 = red, 120 = green, 240 = blue)

  The primary color `oklch(0.546 0.245 262.881)` sits in the cobalt-blue
  range. Its high chroma (0.245) makes it bold and immediately attention-
  grabbing, while its lightness (L ≈ 0.55) keeps it accessible against both
  white and dark backgrounds.

  The foreground and background use a blue-tinted near-black / pure-white,
  giving the light mode a very clean appearance with a subtle cool cast.

  ## Radius

  Uses `0.5rem` (8px at 16px base font) — a standard, slightly sharp radius
  that suits the precise, structured aesthetic of enterprise software.
  """

  alias PhiaUi.Theme

  @doc """
  Returns the Blue theme preset struct.

  ## Example

      iex> theme = PhiaUi.Themes.Blue.theme()
      iex> theme.name
      "blue"
      iex> theme.radius
      "0.5rem"
  """
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "blue",
      label: "Blue",
      radius: "0.5rem",
      colors: %{
        light: %{
          # Pure white background keeps the blue primary prominent.
          background: "oklch(1 0 0)",
          # Near-black with a subtle blue hue (H ≈ 238°) for text.
          foreground: "oklch(0.145 0.01 237.938)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.145 0.01 237.938)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.145 0.01 237.938)",
          # Cobalt blue primary — the defining color of this preset.
          primary: "oklch(0.546 0.245 262.881)",
          primary_foreground: "oklch(0.985 0 0)",
          # Secondary carries a very pale blue tint.
          secondary: "oklch(0.961 0.014 241.67)",
          secondary_foreground: "oklch(0.145 0.01 237.938)",
          muted: "oklch(0.961 0.014 241.67)",
          # Muted foreground is a medium-value blue-grey for secondary text.
          muted_foreground: "oklch(0.553 0.028 246.099)",
          accent: "oklch(0.961 0.014 241.67)",
          accent_foreground: "oklch(0.145 0.01 237.938)",
          # Destructive is a warm red, contrasting with the cool primary.
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Borders use a lightly blue-tinted grey.
          border: "oklch(0.929 0.013 255.508)",
          input: "oklch(0.929 0.013 255.508)",
          ring: "oklch(0.546 0.245 262.881)",
          sidebar_background: "oklch(0.961 0.014 241.67)"
        },
        dark: %{
          # Dark blue-tinted near-black background.
          background: "oklch(0.145 0.01 237.938)",
          foreground: "oklch(0.985 0 0)",
          # Cards are a step lighter than background, carrying a blue tint.
          card: "oklch(0.208 0.024 245.17)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.208 0.024 245.17)",
          popover_foreground: "oklch(0.985 0 0)",
          # Primary color stays identical in dark mode — consistent brand color.
          primary: "oklch(0.546 0.245 262.881)",
          primary_foreground: "oklch(0.985 0 0)",
          # Dark secondary surfaces have a noticeable blue tint.
          secondary: "oklch(0.268 0.031 243.034)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.268 0.031 243.034)",
          muted_foreground: "oklch(0.71 0.031 253.012)",
          accent: "oklch(0.268 0.031 243.034)",
          accent_foreground: "oklch(0.985 0 0)",
          # Destructive lightens in dark mode for visibility on dark backgrounds.
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Alpha-based borders adapt to any dark surface.
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.546 0.245 262.881)",
          sidebar_background: "oklch(0.208 0.024 245.17)"
        }
      },
      typography: %{
        font_sans: ~S(ui-sans-serif, system-ui, -apple-system, sans-serif),
        font_mono: ~S(ui-monospace, "Fira Code", monospace)
      },
      shadows: %{
        sm: "0 1px 2px 0 rgb(0 0 0 / 0.05)",
        md: "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)",
        lg: "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)"
      }
    }
  end
end
