defmodule PhiaUi.Themes.Violet do
  @moduledoc "Violet preset — premium violet."

  alias PhiaUi.Theme

  @doc "Returns the Violet theme preset."
  @spec theme() :: Theme.t()
  def theme do
    %Theme{
      name: "violet",
      label: "Violet",
      radius: "0.5rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.141 0.017 293.28)",
          card: "oklch(1 0 0)",
          card_foreground: "oklch(0.141 0.017 293.28)",
          popover: "oklch(1 0 0)",
          popover_foreground: "oklch(0.141 0.017 293.28)",
          primary: "oklch(0.541 0.281 293.009)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.965 0.022 296.58)",
          secondary_foreground: "oklch(0.141 0.017 293.28)",
          muted: "oklch(0.965 0.022 296.58)",
          muted_foreground: "oklch(0.553 0.032 293.28)",
          accent: "oklch(0.965 0.022 296.58)",
          accent_foreground: "oklch(0.141 0.017 293.28)",
          destructive: "oklch(0.577 0.245 27.325)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(0.93 0.022 293.28)",
          input: "oklch(0.93 0.022 293.28)",
          ring: "oklch(0.541 0.281 293.009)",
          sidebar_background: "oklch(0.965 0.022 296.58)"
        },
        dark: %{
          background: "oklch(0.141 0.017 293.28)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.209 0.025 292.58)",
          card_foreground: "oklch(0.985 0 0)",
          popover: "oklch(0.209 0.025 292.58)",
          popover_foreground: "oklch(0.985 0 0)",
          primary: "oklch(0.541 0.281 293.009)",
          primary_foreground: "oklch(0.985 0 0)",
          secondary: "oklch(0.271 0.033 293.28)",
          secondary_foreground: "oklch(0.985 0 0)",
          muted: "oklch(0.271 0.033 293.28)",
          muted_foreground: "oklch(0.71 0.033 293.28)",
          accent: "oklch(0.271 0.033 293.28)",
          accent_foreground: "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          destructive_foreground: "oklch(0.985 0 0)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.541 0.281 293.009)",
          sidebar_background: "oklch(0.209 0.025 292.58)"
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
