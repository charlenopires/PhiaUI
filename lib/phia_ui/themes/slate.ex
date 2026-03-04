defmodule PhiaUi.Themes.Slate do
  @moduledoc """
  The **Slate** color preset — cool blue-grey.

  ## Design language

  Slate is a cooler, more saturated variant of Zinc. Where Zinc uses near-zero
  chroma (barely tinted grey), Slate has noticeably more chroma (C ≈ 0.028–
  0.046) concentrated in the blue-indigo range (hue angle ~260–265°). The
  result is a palette that reads as a refined dark blue-grey — sophisticated,
  calm, and serious.

  Use Slate when you want:

  - A professional palette with more personality than pure neutral grey.
  - A look that pairs well with blue or indigo accent elements.
  - An alternative to Zinc for teams that find Zinc too "warm".

  ## Slate vs Zinc

  Both Slate and Zinc are neutral-dark presets, but they differ in one key way:

  - **Zinc** (H ≈ 285°, C ≈ 0.004) — slightly warm grey with almost no hue.
  - **Slate** (H ≈ 262–265°, C ≈ 0.028–0.046) — distinctly cool blue-grey
    with enough chroma to read as a colour-tinted neutral.

  ## Color values

  All values are encoded in **OKLCH** (CSS Color Level 4). The three numeric
  arguments are:

  - **L** — perceived lightness, 0 (black) to 1 (white)
  - **C** — chroma (color saturation), 0 = achromatic grey
  - **H** — hue angle in degrees (0 = red, 120 = green, 240 = blue)

  The dark-mode background `oklch(0.13 0.028 261.692)` is slightly darker and
  more saturated than Zinc's, giving dark-mode UIs a distinctly "dark slate"
  character rather than a plain dark grey.

  ## Radius

  Uses `0.5rem` (8px at 16px base font) — a standard, precise radius that
  complements the structured feel of the slate palette.
  """

  alias PhiaUi.Theme

  @doc """
  Returns the Slate theme preset struct.

  ## Example

      iex> theme = PhiaUi.Themes.Slate.theme()
      iex> theme.name
      "slate"
      iex> theme.radius
      "0.5rem"
  """
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "slate",
      label: "Slate",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          # Blue-tinted near-black foreground (H ≈ 262°, distinctly cool).
          foreground: "oklch(0.13 0.028 261.692)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.13 0.028 261.692)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.13 0.028 261.692)",
          # Primary uses the same cool blue-indigo as the foreground — a
          # dark blue that reads as "neutral primary" similar to Zinc but cooler.
          primary: "oklch(0.208 0.042 265.755)",
          primary_foreground: "oklch(0.984 0.003 247.858)",
          # Secondary uses a very pale blue-grey tint.
          secondary: "oklch(0.968 0.007 247.896)",
          secondary_foreground: "oklch(0.208 0.042 265.755)",
          muted: "oklch(0.968 0.007 247.896)",
          # Muted foreground has noticeable blue hue for a coherent palette.
          muted_foreground: "oklch(0.554 0.046 257.417)",
          accent: "oklch(0.968 0.007 247.896)",
          accent_foreground: "oklch(0.208 0.042 265.755)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.984 0.003 247.858)",
          # Borders carry a clear blue hue, reinforcing the slate character.
          border: "oklch(0.929 0.013 255.508)",
          input: "oklch(0.929 0.013 255.508)",
          ring: "oklch(0.208 0.042 265.755)",
          sidebar_background: "oklch(0.984 0.003 247.858)"
        },
        dark: %{
          # Deep blue-grey background — darker and more saturated than Zinc.
          background: "oklch(0.13 0.028 261.692)",
          foreground: "oklch(0.984 0.003 247.858)",
          card: "oklch(0.208 0.042 265.755)",
          card_foreground: "oklch(0.984 0.003 247.858)",
          popover: "oklch(0.208 0.042 265.755)",
          popover_foreground: "oklch(0.984 0.003 247.858)",
          # Primary inverts to near-white in dark mode (text-as-action style).
          primary: "oklch(0.984 0.003 247.858)",
          primary_foreground: "oklch(0.208 0.042 265.755)",
          # Secondary surfaces carry a strong blue tint in dark mode.
          secondary: "oklch(0.279 0.041 260.031)",
          secondary_foreground: "oklch(0.984 0.003 247.858)",
          muted: "oklch(0.279 0.041 260.031)",
          muted_foreground: "oklch(0.704 0.04 256.788)",
          accent: "oklch(0.279 0.041 260.031)",
          accent_foreground: "oklch(0.984 0.003 247.858)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.984 0.003 247.858)",
          # Alpha-based borders adapt to any dark surface.
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          # Ring uses the muted foreground — a mid-chroma blue.
          ring: "oklch(0.554 0.046 257.417)",
          sidebar_background: "oklch(0.208 0.042 265.755)"
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
