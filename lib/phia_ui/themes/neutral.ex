defmodule PhiaUi.Themes.Neutral do
  @moduledoc "Neutral preset — pure grey."

  alias PhiaUi.Theme

  @doc "Returns the Neutral theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "neutral",
      label: "Neutral",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.145 0 0)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.145 0 0)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.145 0 0)",
          primary: "oklch(0.205 0 0)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.97 0 0)",
          secondary_foreground: "oklch(0.205 0 0)",
          muted: "oklch(0.97 0 0)",
          muted_foreground: "oklch(0.556 0 0)",
          accent: "oklch(0.97 0 0)",
          accent_foreground: "oklch(0.205 0 0)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.922 0 0)",
          input: "oklch(0.922 0 0)",
          ring: "oklch(0.708 0 0)",
          sidebar_background: "oklch(0.97 0 0)"
        },
        dark: %{
          background: "oklch(0.145 0 0)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.205 0 0)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.205 0 0)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.985 0 0)",
          primary_foreground: "oklch(0.205 0 0)",
          secondary: "oklch(0.269 0 0)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.269 0 0)",
          muted_foreground: "oklch(0.708 0 0)",
          accent: "oklch(0.269 0 0)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.556 0 0)",
          sidebar_background: "oklch(0.205 0 0)"
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
