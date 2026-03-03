defmodule PhiaUi.Themes.Orange do
  @moduledoc "Orange preset — energetic orange."

  alias PhiaUi.Theme

  @doc "Returns the Orange theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "orange",
      label: "Orange",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.145 0.012 38.87)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.145 0.012 38.87)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.145 0.012 38.87)",
          primary: "oklch(0.646 0.222 41.116)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.966 0.019 49.315)",
          secondary_foreground: "oklch(0.145 0.012 38.87)",
          muted: "oklch(0.966 0.019 49.315)",
          muted_foreground: "oklch(0.553 0.028 58.5)",
          accent: "oklch(0.966 0.019 49.315)",
          accent_foreground: "oklch(0.145 0.012 38.87)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.929 0.015 49.315)",
          input: "oklch(0.929 0.015 49.315)",
          ring: "oklch(0.646 0.222 41.116)",
          sidebar_background: "oklch(0.966 0.019 49.315)"
        },
        dark: %{
          background: "oklch(0.145 0.012 38.87)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.211 0.019 36.41)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.211 0.019 36.41)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.646 0.222 41.116)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.272 0.028 37.25)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.272 0.028 37.25)",
          muted_foreground: "oklch(0.71 0.028 41.116)",
          accent: "oklch(0.272 0.028 37.25)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.646 0.222 41.116)",
          sidebar_background: "oklch(0.211 0.019 36.41)"
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
