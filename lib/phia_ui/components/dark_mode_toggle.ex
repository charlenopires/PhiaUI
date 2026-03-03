defmodule PhiaUi.Components.DarkModeToggle do
  @moduledoc """
  Dark mode toggle component with PhiaDarkMode vanilla JS hook.

  Toggles the `.dark` class on the `<html>` element, persists preference
  in `localStorage['phia-theme']`, and respects `prefers-color-scheme` on
  first visit. Fires `phia:theme-changed` custom event for integration with
  other hooks (e.g. PhiaChart dark mode re-render).

  ## Example

      <.dark_mode_toggle id="theme-toggle" />

  ## Anti-FOUC

  Add this inline script to your `<head>` **before** any stylesheet:

      <script>
        (function() {
          var theme = localStorage.getItem('phia-theme');
          if (theme === 'dark' || (!theme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
          }
        })();
      </script>

  ## Hook setup

      import PhiaDarkMode from "./hooks/dark_mode"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDarkMode }
      })

  ## theme.css

  Ensure `priv/static/theme.css` contains:

      @custom-variant dark (&:where(.dark, .dark *));

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr :id, :string, required: true, doc: "Unique ID for the toggle button"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global

  @doc """
  Renders the dark mode toggle button.

  Both sun and moon icons are rendered; the hook hides/shows them via CSS
  based on the current theme class on `<html>`.
  """
  def dark_mode_toggle(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="PhiaDarkMode"
      aria-label="Switch to dark mode"
      class={cn([
        "inline-flex h-9 w-9 items-center justify-center rounded-md",
        "border border-transparent text-sm transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "focus:outline-none focus:ring-1 focus:ring-ring",
        @class
      ])}
      {@rest}
    >
      <%!-- Sun icon — visible in light mode, hidden in dark mode --%>
      <span class="block dark:hidden" aria-hidden="true">
        <.icon name="sun" size={:sm} />
      </span>
      <%!-- Moon icon — hidden in light mode, visible in dark mode --%>
      <span class="hidden dark:block" aria-hidden="true">
        <.icon name="moon" size={:sm} />
      </span>
      <span class="sr-only">Toggle theme</span>
    </button>
    """
  end
end
