defmodule PhiaUi.Themes.Rose do
  @moduledoc "Rose preset — modern rose/pink."

  alias PhiaUi.Theme

  @doc "Returns the Rose theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "rose",
      label: "Rose",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.141 0.019 13.69)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.141 0.019 13.69)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.141 0.019 13.69)",
          primary: "oklch(0.592 0.241 349.615)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.969 0.015 12.422)",
          secondary_foreground: "oklch(0.141 0.019 13.69)",
          muted: "oklch(0.969 0.015 12.422)",
          muted_foreground: "oklch(0.557 0.048 12.584)",
          accent: "oklch(0.969 0.015 12.422)",
          accent_foreground: "oklch(0.141 0.019 13.69)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.934 0.014 11.394)",
          input: "oklch(0.934 0.014 11.394)",
          ring: "oklch(0.592 0.241 349.615)",
          sidebar_background: "oklch(0.969 0.015 12.422)"
        },
        dark: %{
          background: "oklch(0.141 0.019 13.69)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.211 0.026 10.73)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.211 0.026 10.73)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.592 0.241 349.615)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.272 0.035 11.44)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.272 0.035 11.44)",
          muted_foreground: "oklch(0.71 0.035 11.44)",
          accent: "oklch(0.272 0.035 11.44)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
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
