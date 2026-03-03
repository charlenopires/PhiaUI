defmodule PhiaUi.Themes.Zinc do
  @moduledoc "Zinc preset — neutral dark, shadcn/ui default."

  alias PhiaUi.Theme

  @doc "Returns the Zinc theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "zinc",
      label: "Zinc",
      radius: "0.625rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.141 0.004 285.82)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.141 0.004 285.82)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.141 0.004 285.82)",
          primary: "oklch(0.211 0.005 285.82)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.967 0.001 286.38)",
          secondary_foreground: "oklch(0.211 0.005 285.82)",
          muted: "oklch(0.97 0 0)",
          muted_foreground: "oklch(0.552 0.016 286.07)",
          accent: "oklch(0.967 0.001 286.38)",
          accent_foreground: "oklch(0.211 0.005 285.82)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.922 0 0)",
          input: "oklch(0.922 0 0)",
          ring: "oklch(0.141 0.004 285.82)",
          sidebar_background: "oklch(0.985 0.001 286.38)"
        },
        dark: %{
          background: "oklch(0.141 0.004 285.82)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.211 0.005 285.82)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.211 0.005 285.82)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.985 0 0)",
          primary_foreground: "oklch(0.211 0.005 285.82)",
          secondary: "oklch(0.279 0.007 285.82)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.279 0.007 285.82)",
          muted_foreground: "oklch(0.71 0.01 286.07)",
          accent: "oklch(0.279 0.007 285.82)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
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
