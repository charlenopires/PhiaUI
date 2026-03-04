defmodule PhiaUi.Themes.Zinc do
  @moduledoc """
  The **Zinc** color preset — neutral dark, the shadcn/ui default.

  ## Design language

  Zinc is an achromatic palette built around warm-neutral grey tones with a
  barely-perceptible warm hue (hue angle ~285°). It is the default preset for
  shadcn/ui and the reference starting point for PhiaUI.

  Use Zinc when you want:

  - A professional, unobtrusive UI that puts content first.
  - Maximum compatibility with existing Tailwind grey-based designs.
  - A dark mode that feels genuinely dark (near-black background) without being
    harsh.

  ## Color values

  All values are encoded in **OKLCH** (CSS Color Level 4). The three numeric
  arguments are:

  - **L** — perceived lightness, 0 (black) to 1 (white)
  - **C** — chroma (color saturation), 0 = achromatic grey
  - **H** — hue angle in degrees (0-360), irrelevant when C is near 0

  The near-zero chroma values (C ≈ 0.004–0.016) give zinc its characteristic
  "warm grey" look — just enough hue to avoid the clinical coldness of pure
  neutral greys.

  ## Radius

  Uses `0.625rem` (10px at 16px base font) — slightly rounder than a sharp
  `0.5rem`, giving a friendly yet restrained appearance.
  """

  alias PhiaUi.Theme

  @doc """
  Returns the Zinc theme preset struct.

  ## Example

      iex> theme = PhiaUi.Themes.Zinc.theme()
      iex> theme.name
      "zinc"
      iex> theme.radius
      "0.625rem"
  """
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "zinc",
      label: "Zinc",
      radius: "0.625rem",
      colors: %{
        light: %{
          # Pure white page background.
          background: "oklch(1 0 0)",
          # Near-black text with a trace of warm hue.
          foreground: "oklch(0.141 0.004 285.82)",
          # Cards share the page background in light mode.
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.141 0.004 285.82)",
          # Popovers / dropdowns also use the page background.
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.141 0.004 285.82)",
          # Primary is near-black — text-as-action style (like shadcn/ui default).
          primary: "oklch(0.211 0.005 285.82)",
          primary_foreground: "oklch(0.985 0 0)",
          # Secondary is a very light grey, used for subtle fills.
          secondary: "oklch(0.967 0.001 286.38)",
          secondary_foreground: "oklch(0.211 0.005 285.82)",
          # Muted is used for disabled states and de-emphasised content.
          muted: "oklch(0.97 0 0)",
          muted_foreground: "oklch(0.552 0.016 286.07)",
          # Accent mirrors secondary — hover backgrounds on menu items, etc.
          accent: "oklch(0.967 0.001 286.38)",
          accent_foreground: "oklch(0.211 0.005 285.82)",
          # Destructive uses a standard red (hue ~27°, warm-red).
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Light-mode borders are very pale grey.
          border: "oklch(0.922 0 0)",
          input: "oklch(0.922 0 0)",
          ring: "oklch(0.141 0.004 285.82)",
          sidebar_background: "oklch(0.985 0.001 286.38)"
        },
        dark: %{
          # Near-black background — L ≈ 0.14 is distinctly dark without being
          # pure black, which aids contrast with card surfaces.
          background: "oklch(0.141 0.004 285.82)",
          foreground: "oklch(0.985 0 0)",
          # Cards sit slightly lighter than the background to create depth.
          card: "oklch(0.211 0.005 285.82)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.211 0.005 285.82)",
          popover_foreground: "oklch(0.985 0 0)",
          # Primary in dark mode inverts to near-white, consistent with the
          # text-as-action philosophy — primary actions are high-contrast.
          primary: "oklch(0.985 0 0)",
          primary_foreground: "oklch(0.211 0.005 285.82)",
          # Secondary and muted are mid-dark greys for secondary surfaces.
          secondary: "oklch(0.279 0.007 285.82)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.279 0.007 285.82)",
          muted_foreground: "oklch(0.71 0.01 286.07)",
          accent: "oklch(0.279 0.007 285.82)",
          accent_foreground: "oklch(0.985 0 0)",
          # Destructive lightens in dark mode (higher L) for visibility on
          # dark backgrounds while staying within accessible contrast ratios.
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          # Dark-mode borders use alpha transparency to adapt to any surface.
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.552 0.016 286.07)",
          sidebar_background: "oklch(0.211 0.005 285.82)"
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
