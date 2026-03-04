defmodule PhiaUi do
  @moduledoc """
  PhiaUI — a shadcn/ui-inspired component library for Phoenix LiveView.

  PhiaUI brings the composable, anatomy-driven design system of
  [shadcn/ui](https://ui.shadcn.com) to the Phoenix ecosystem. Every component
  is a stateless HEEx function component that integrates with
  `Phoenix.HTML.Form`, Ecto changesets, and LiveView's JS command system. There
  are no npm dependencies and no Alpine.js. JS hooks (where required) are
  plain vanilla JavaScript files that you own after ejection.

  ## Architecture

  PhiaUI is organised into five layers:

  ### 1. PrimitiveComponents

  Stateless, zero-JS layout and display components:

  - `PhiaUi.Components.Button` — 6 variants × 4 sizes, composable with icons
  - `PhiaUi.Components.Card` — `card/1`, `card_header/1`, `card_title/1`, `card_description/1`, `card_content/1`, `card_footer/1`
  - `PhiaUi.Components.Badge` — 4 semantic variants (default, secondary, destructive, outline)
  - `PhiaUi.Components.Table` — streams-compatible; `table/1` through `table_caption/1`
  - `PhiaUi.Components.Icon` — Lucide SVG sprite, 4 sizes

  ### 2. FormIntegration

  Fully integrated with `Phoenix.HTML.FormField` and Ecto changeset errors:

  - `PhiaUi.Components.Input` — `phia_input/1` — label + input + description + errors
  - `PhiaUi.Components.Textarea` — `phia_textarea/1` — multi-line with auto error display
  - `PhiaUi.Components.Select` — `phia_select/1` — native `<select>` + chevron icon overlay
  - `PhiaUi.Components.Form` — `form_field/1`, `form_label/1`, `form_message/1`
  - `PhiaUi.Components.TagsInput` — `tags_input/1` — CSV hidden input, PhiaTagsInput hook
  - `PhiaUi.Components.ImageUpload` — `image_upload/1` — native LiveView uploads + drop zone
  - `PhiaUi.Components.RichTextEditor` — `rich_text_editor/1` — 14 toolbar commands, zero npm

  ### 3. InteractiveComponents

  WAI-ARIA compliant components backed by lightweight JS hooks:

  - `PhiaUi.Components.Dialog` — `dialog/1` — focus trap, Escape, scroll lock (PhiaDialog)
  - `PhiaUi.Components.DropdownMenu` — `dropdown_menu/1` — smart positioning, arrow keys (PhiaDropdownMenu)
  - `PhiaUi.Components.Accordion` — `accordion/1` — single / multiple mode via `Phoenix.LiveView.JS`

  ### 4. DashboardShell

  Enterprise-grade layout shell using CSS Grid on desktop and a Flexbox drawer on mobile:

  - `PhiaUi.Components.Shell` — `shell/1` — `grid-cols-[240px_1fr] h-screen`
  - `PhiaUi.Components.Shell` — `sidebar/1`, `sidebar_item/1`, `topbar/1`, `mobile_sidebar_toggle/1`

  ### 5. DashboardWidgets

  Composed analytics widgets for BI dashboards and KPI monitors:

  - `PhiaUi.Components.StatCard` — `stat_card/1` — trend indicators, icon and footer slots
  - `PhiaUi.Components.MetricGrid` — `metric_grid/1` — responsive 1–4 column grid
  - `PhiaUi.Components.ChartShell` — `chart_shell/1` — titled card wrapper for any charting library

  ## Installation

  Add PhiaUI to your `mix.exs` dependencies:

      def deps do
        [
          {:phia_ui, "~> 0.1"}
        ]
      end

  Then run the installer to copy hooks and the Tailwind theme into your project:

      mix phia.install

  To add individual components as ejectable source files:

      mix phia.add Button
      mix phia.add Card Badge Table

  ## Quick Start

  A minimal LiveView using several PhiaUI components:

      defmodule MyAppWeb.DemoLive do
        use MyAppWeb, :live_view

        import PhiaUi.Components.Button
        import PhiaUi.Components.Card
        import PhiaUi.Components.Badge
        import PhiaUi.Components.Input

        def render(assigns) do
          ~H\"\"\"
          <.card>
            <.card_header>
              <.card_title>Welcome</.card_title>
              <.card_description>
                Manage your account settings.
                <.badge variant={:secondary}>Beta</.badge>
              </.card_description>
            </.card_header>
            <.card_content>
              <.form for={@form} phx-change="validate" phx-submit="save">
                <.phia_input field={@form[:email]} label="Email" phx-debounce="blur" />
                <.button type="submit" class="mt-4">Save</.button>
              </.form>
            </.card_content>
          </.card>
          \"\"\"
        end
      end

  ## ClassMerger / cn/1

  `PhiaUi.ClassMerger.cn/1` is PhiaUI's Tailwind class conflict resolver —
  equivalent to `clsx` + `tailwind-merge` in the JS ecosystem, implemented
  natively in Elixir without any external dependencies.

  Pass a list of class strings (or `nil` / `false` values, which are ignored).
  When two classes target the same Tailwind utility group (e.g. `px-2` and
  `px-4`), the **last one wins**:

      cn(["px-2 py-1", nil, "px-4"])
      #=> "py-1 px-4"

  Every component accepts an `:class` attribute that is merged through `cn/1`,
  so you can safely override individual utilities without worrying about
  duplication:

      <.button class="px-8">Wide Button</.button>

  ## JS Hooks

  Three components use vanilla JS hooks for accessible behaviour that cannot be
  achieved with `Phoenix.LiveView.JS` alone: `PhiaDialog`, `PhiaDropdownMenu`,
  `PhiaTagsInput`, and `PhiaRichTextEditor`. After running `mix phia.install`,
  these hook files are copied into your `assets/js/hooks/` directory and wired
  into your LiveSocket automatically.

  ## Ejectable Architecture

  Every component can be ejected — copied as editable source into your project —
  so you always own the code:

      mix phia.add Button Card Badge

  Ejected files appear under `lib/your_app_web/components/` and are fully
  independent of the PhiaUI package. You can modify them freely without
  upgrading or forking.
  """

  @doc false
  def hello, do: :world
end
