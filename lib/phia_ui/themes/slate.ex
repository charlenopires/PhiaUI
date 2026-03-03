defmodule PhiaUi.Themes.Slate do
  @moduledoc "Slate preset — cool blue-grey."

  alias PhiaUi.Theme

  @doc "Returns the Slate theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "slate",
      label: "Slate",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.13 0.028 261.692)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.13 0.028 261.692)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.13 0.028 261.692)",
          primary: "oklch(0.208 0.042 265.755)",
          primary_foreground: "oklch(0.984 0.003 247.858)",
          secondary: "oklch(0.968 0.007 247.896)",
          secondary_foreground: "oklch(0.208 0.042 265.755)",
          muted: "oklch(0.968 0.007 247.896)",
          muted_foreground: "oklch(0.554 0.046 257.417)",
          accent: "oklch(0.968 0.007 247.896)",
          accent_foreground: "oklch(0.208 0.042 265.755)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.984 0.003 247.858)",
          border: "oklch(0.929 0.013 255.508)",
          input: "oklch(0.929 0.013 255.508)",
          ring: "oklch(0.208 0.042 265.755)",
          sidebar_background: "oklch(0.984 0.003 247.858)"
        },
        dark: %{
          background: "oklch(0.13 0.028 261.692)",
          foreground: "oklch(0.984 0.003 247.858)",
          card: "oklch(0.208 0.042 265.755)",
          card_foreground: "oklch(0.984 0.003 247.858)",
          popover: "oklch(0.208 0.042 265.755)",
          popover_foreground: "oklch(0.984 0.003 247.858)",
          primary: "oklch(0.984 0.003 247.858)",
          primary_foreground: "oklch(0.208 0.042 265.755)",
          secondary: "oklch(0.279 0.041 260.031)",
          secondary_foreground: "oklch(0.984 0.003 247.858)",
          muted: "oklch(0.279 0.041 260.031)",
          muted_foreground: "oklch(0.704 0.04 256.788)",
          accent: "oklch(0.279 0.041 260.031)",
          accent_foreground: "oklch(0.984 0.003 247.858)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.984 0.003 247.858)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
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
