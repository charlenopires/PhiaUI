defmodule PhiaUi.Themes.Rose do
  @moduledoc """
  The **Rose** color preset — modern rose/pink, warm and expressive.

  ## Design language

  Rose uses a vibrant magenta-pink primary (hue angle ~350°, near the
  red-magenta boundary) with warm rose-tinted neutral surfaces. It projects
  a modern, creative, and slightly feminine aesthetic.

  Use Rose when you want:

  - A distinctive, memorable brand palette that stands out from blue-grey defaults.
  - A warm UI for lifestyle, beauty, wellness, or creative applications.
  - An expressive color scheme that pairs well with white space and minimal layout.

  ## Color values

  All values are encoded in **OKLCH** (CSS Color Level 4). The three numeric
  arguments are:

  - **L** — perceived lightness, 0 (black) to 1 (white)
  - **C** — chroma (color saturation), 0 = achromatic grey
  - **H** — hue angle in degrees (0/360 = red, 180 = cyan, 300 = magenta)

  The primary `oklch(0.592 0.241 349.615)` sits at hue 350° — a vivid rose
  that is neither a pure red nor a pure pink. Its high chroma (0.241) gives it
  the saturation needed to work as a call-to-action color while the medium
  lightness (L ≈ 0.59) keeps it accessible against white backgrounds.

  The neutral surfaces use a subtle rose hue (H ≈ 11–13°, C ≈ 0.015–0.019) so
  that even the backgrounds carry a hint of warmth, unifying the palette.

  ## Destructive vs primary

  Rose is unusual in that its primary color (a cool-leaning rose/pink) is
  distinctly different from the destructive color (a warmer red at H ≈ 27°).
  This separation ensures users can tell "primary action" apart from
  "danger/delete" even though both are in the red-pink family.

  ## Radius

  Uses `0.5rem` (8px at 16px base font) — a standard, balanced radius that
  avoids competing with the expressiveness of the rose palette.
  """

  alias PhiaUi.Theme

  @doc """
  Returns the Rose theme preset struct.

  ## Example

      iex> theme = PhiaUi.Themes.Rose.theme()
      iex> theme.name
      "rose"
      iex> theme.radius
      "0.5rem"
  """
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "rose",
      label: "Rose",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          # Near-black with a warm rose hue (H ≈ 14°) for cohesive text tone.
          foreground: "oklch(0.141 0.019 13.69)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.141 0.019 13.69)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.141 0.019 13.69)",
          # Vivid rose-pink primary — the defining color of this preset.
          primary: "oklch(0.592 0.241 349.615)",
          primary_foreground: "oklch(0.985 0 0)",
          # Secondary has a very pale rose tint — barely visible but coherent.
          secondary: "oklch(0.969 0.015 12.422)",
          secondary_foreground: "oklch(0.141 0.019 13.69)",
          muted: "oklch(0.969 0.015 12.422)",
          # Muted foreground is a mid-value warm-rose for secondary text.
          muted_foreground: "oklch(0.557 0.048 12.584)",
          accent: "oklch(0.969 0.015 12.422)",
          accent_foreground: "oklch(0.141 0.019 13.69)",
          # Destructive uses a warmer, darker red — clearly distinct from the
          # cooler rose primary so users can tell danger from action.
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Borders have a rose-tinted hue for a warm, consistent appearance.
          border: "oklch(0.934 0.014 11.394)",
          input: "oklch(0.934 0.014 11.394)",
          ring: "oklch(0.592 0.241 349.615)",
          sidebar_background: "oklch(0.969 0.015 12.422)"
        },
        dark: %{
          # Deep warm-dark background with a rose hue (H ≈ 14°).
          background: "oklch(0.141 0.019 13.69)",
          foreground: "oklch(0.985 0 0)",
          # Cards sit a step lighter with a richer rose tint.
          card: "oklch(0.211 0.026 10.73)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.211 0.026 10.73)",
          popover_foreground: "oklch(0.985 0 0)",
          # Primary retains its vivid rose in dark mode — consistent identity.
          primary: "oklch(0.592 0.241 349.615)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.272 0.035 11.44)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.272 0.035 11.44)",
          # Muted foreground is a light-warm rose — readable on dark surfaces.
          muted_foreground: "oklch(0.71 0.035 11.44)",
          accent: "oklch(0.272 0.035 11.44)",
          accent_foreground: "oklch(0.985 0 0)",
          # Destructive lightens in dark mode for accessible contrast.
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Alpha-based borders adapt cleanly to the warm dark background.
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.592 0.241 349.615)",
          sidebar_background: "oklch(0.211 0.026 10.73)"
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
