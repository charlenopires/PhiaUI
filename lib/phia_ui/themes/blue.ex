defmodule PhiaUi.Themes.Blue do
  @moduledoc "Blue preset — enterprise blue."

  alias PhiaUi.Theme

  @doc "Returns the Blue theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "blue",
      label: "Blue",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.145 0.01 237.938)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.145 0.01 237.938)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.145 0.01 237.938)",
          primary: "oklch(0.546 0.245 262.881)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.961 0.014 241.67)",
          secondary_foreground: "oklch(0.145 0.01 237.938)",
          muted: "oklch(0.961 0.014 241.67)",
          muted_foreground: "oklch(0.553 0.028 246.099)",
          accent: "oklch(0.961 0.014 241.67)",
          accent_foreground: "oklch(0.145 0.01 237.938)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.929 0.013 255.508)",
          input: "oklch(0.929 0.013 255.508)",
          ring: "oklch(0.546 0.245 262.881)",
          sidebar_background: "oklch(0.961 0.014 241.67)"
        },
        dark: %{
          background: "oklch(0.145 0.01 237.938)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.208 0.024 245.17)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.208 0.024 245.17)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.546 0.245 262.881)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.268 0.031 243.034)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.268 0.031 243.034)",
          muted_foreground: "oklch(0.71 0.031 253.012)",
          accent: "oklch(0.268 0.031 243.034)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
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
