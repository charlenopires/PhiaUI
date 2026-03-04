defmodule PhiaUi.Components.DarkModeToggle do
  @moduledoc """
  Dark mode toggle button component powered by the `PhiaDarkMode` vanilla JS hook.

  Clicking the button toggles the `.dark` CSS class on the `<html>` element.
  The preference is persisted in `localStorage` under two keys for backward
  compatibility:

  - `localStorage['phia-mode']` — canonical key (`"light"` or `"dark"`)
  - `localStorage['phia-theme']` — legacy key (kept for apps that depended on the old key)

  The hook also fires the `phia:theme-changed` custom DOM event after each
  toggle, allowing other hooks (notably `PhiaChart`) to re-initialise with
  the correct ECharts dark theme.

  ## How dark mode works

  PhiaUI dark mode is CSS-class-driven, not media-query-driven:

  1. `theme.css` contains `@custom-variant dark (&:where(.dark, .dark *));`
     which defines the `dark:` Tailwind variant to match any element inside
     a `.dark` ancestor.
  2. The `PhiaDarkMode` hook adds or removes `.dark` from `<html>` on click.
  3. All dark-mode styles cascade automatically from the CSS custom properties
     defined in the `@theme` block.

  This approach gives the user (not the OS) full control over the mode, and
  allows toggling mid-session without any server round-trip.

  ## Setup

  1. Copy the hook (or run `mix phia.add dark_mode`):

         # priv/templates/js/hooks/dark_mode.js
         import PhiaDarkMode from "./hooks/dark_mode"

  2. Register it in `app.js`:

         import PhiaDarkMode from "./hooks/dark_mode"
         let liveSocket = new LiveSocket("/live", Socket, {
           hooks: { PhiaDarkMode }
         })

  3. Add the `dark` custom variant to `priv/static/theme.css`:

         @custom-variant dark (&:where(.dark, .dark *));

  ## Anti-FOUC (Flash of Unstyled Content)

  Without special handling, the browser renders the page in light mode for a
  brief moment before JavaScript loads and restores the dark preference from
  `localStorage`. This causes a visible "flash" on reload.

  Prevent it by adding this inline `<script>` to the `<head>` of your layout
  **before** any `<link>` stylesheet tag:

      <script>
        (function() {
          // Restore dark/light mode before first paint to avoid FOUC
          var mode = localStorage.getItem('phia-mode') || localStorage.getItem('phia-theme');
          if (mode === 'dark' || (!mode && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
          }
          // Restore color theme preset (set by PhiaTheme hook)
          var ct = localStorage.getItem('phia-color-theme');
          if (ct) document.documentElement.setAttribute('data-phia-theme', ct);
        })();
      </script>

  The script is intentionally tiny (no external dependencies) so it executes
  synchronously before any CSS is parsed. It checks `phia-mode` first (new
  key), then falls back to `phia-theme` (legacy), then falls back to
  `prefers-color-scheme` media query for first-time visitors.

  ## Color theme switching (separate from dark mode)

  Dark mode (light/dark) and color theme (zinc, blue, rose, etc.) are two
  independent dimensions. Use the `PhiaTheme` hook (from `mix phia.theme
  install`) for runtime color preset switching:

      <%!-- Dropdown that switches the active color preset at runtime --%>
      <select phx-hook="PhiaTheme" id="color-theme-select">
        <option value="zinc">Zinc</option>
        <option value="blue">Blue</option>
        <option value="rose">Rose</option>
      </select>

      <%!-- Or a set of click targets --%>
      <button phx-hook="PhiaTheme" id="btn-blue" data-theme="blue">Blue</button>

  ## Usage example

      <%!-- In the topbar of shell/1 --%>
      <:topbar>
        <.mobile_sidebar_toggle />
        <span class="ml-2 font-semibold">Acme</span>
        <div class="ml-auto flex items-center gap-2">
          <.dark_mode_toggle id="topbar-dm-toggle" />
          <span class="text-sm text-muted-foreground">Jane</span>
        </div>
      </:topbar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:id, :string,
    required: true,
    doc: """
    Unique ID for the toggle button element. Required because `phx-hook`
    targets elements by ID. Use a stable, page-unique string like
    `"header-dark-mode-toggle"`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the button element")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the button element (e.g. `aria-label`, `data-*`)"
  )

  @doc """
  Renders the dark mode toggle button.

  The button renders **both** the sun icon (light mode indicator) and moon icon
  (dark mode indicator) simultaneously. The `PhiaDarkMode` hook controls which
  icon is visible via Tailwind's `dark:` variant:

  - `.dark:hidden` — sun is shown in light mode, hidden in dark
  - `.hidden.dark:block` — moon is hidden in light mode, shown in dark

  This technique avoids a JavaScript-driven icon swap and relies purely on CSS,
  which means the correct icon is visible as soon as the `.dark` class is
  toggled on `<html>` — even before any re-render.

  The `aria-label` on the button reads `"Switch to dark mode"` statically.
  This is intentional: the hook updates the label dynamically after mounting.
  Server-rendered HTML always defaults to the "before click" state.

  ## Example

      <.dark_mode_toggle id="my-toggle" />

      <%!-- With extra classes for positioning --%>
      <.dark_mode_toggle id="sidebar-toggle" class="ml-auto" />
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
      <%# Sun icon — rendered in light mode (no .dark ancestor on <html>).
          aria-hidden because the button's aria-label describes the action. %>
      <span class="block dark:hidden" aria-hidden="true">
        <.icon name="sun" size={:sm} />
      </span>
      <%# Moon icon — rendered when .dark class is present on <html>.
          Hidden by default; dark: variant makes it visible in dark mode. %>
      <span class="hidden dark:block" aria-hidden="true">
        <.icon name="moon" size={:sm} />
      </span>
      <%# Screen-reader label — provides context when the button lacks visible text %>
      <span class="sr-only">Toggle theme</span>
    </button>
    """
  end
end
