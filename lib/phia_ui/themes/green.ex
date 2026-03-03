defmodule PhiaUi.Themes.Green do
  @moduledoc "Green preset — success green."

  alias PhiaUi.Theme

  @doc "Returns the Green theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "green",
      label: "Green",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.147 0.037 135.965)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.147 0.037 135.965)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.147 0.037 135.965)",
          primary: "oklch(0.527 0.154 150.069)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.962 0.032 155.37)",
          secondary_foreground: "oklch(0.147 0.037 135.965)",
          muted: "oklch(0.962 0.032 155.37)",
          muted_foreground: "oklch(0.553 0.05 140.83)",
          accent: "oklch(0.962 0.032 155.37)",
          accent_foreground: "oklch(0.147 0.037 135.965)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.935 0.028 150.069)",
          input: "oklch(0.935 0.028 150.069)",
          ring: "oklch(0.527 0.154 150.069)",
          sidebar_background: "oklch(0.962 0.032 155.37)"
        },
        dark: %{
          background: "oklch(0.147 0.037 135.965)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.21 0.051 140.37)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.21 0.051 140.37)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.527 0.154 150.069)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.27 0.059 144.54)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.27 0.059 144.54)",
          muted_foreground: "oklch(0.71 0.059 150.069)",
          accent: "oklch(0.27 0.059 144.54)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.527 0.154 150.069)",
          sidebar_background: "oklch(0.21 0.051 140.37)"
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
