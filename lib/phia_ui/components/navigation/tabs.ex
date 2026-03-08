defmodule PhiaUi.Components.Tabs do
  @moduledoc """
  Accessible content-switching Tabs component — fully server-rendered.

  `Tabs` provides accessible panel switching with a `tabs_list/1` trigger row
  and `tabs_content/1` panels. The active/inactive state is controlled by the
  `:default_value` attr and resolved entirely at render time — **no JavaScript
  hook is required**.

  ## When to use Tabs vs TabsNav

  | Component  | Use case                                                        |
  |------------|-----------------------------------------------------------------|
  | `Tabs`     | Content panels on a single page — switching hides/shows content |
  | `TabsNav`  | Page-level navigation — each tab links to a different route     |

  ## Server-driven vs client-driven switching

  ### Static tabs (no server round-trip)

  Pass a fixed `default_value` to show a specific tab on initial render.
  For purely static content where tabs never change after mount:

      <.tabs default_value="overview">
        <.tabs_list>
          <.tabs_trigger value="overview">Overview</.tabs_trigger>
          <.tabs_trigger value="details">Details</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="overview"><p>Overview content</p></.tabs_content>
        <.tabs_content value="details"><p>Details content</p></.tabs_content>
      </.tabs>

  ### Server-driven switching (LiveView event)

  Bind `phx-click` on triggers to update a LiveView assign, then pass it as
  `default_value`. The server re-renders with the new active tab:

      <%!-- In the LiveView render function --%>
      <.tabs default_value={@active_tab}>
        <.tabs_list>
          <.tabs_trigger value="overview" phx-click="set_tab" phx-value-tab="overview">
            Overview
          </.tabs_trigger>
          <.tabs_trigger value="analytics" phx-click="set_tab" phx-value-tab="analytics">
            Analytics
          </.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="overview">
          <%!-- Only rendered (not just hidden) when active --%>
          <.overview_panel metrics={@metrics} />
        </.tabs_content>
        <.tabs_content value="analytics">
          <.analytics_panel data={@analytics} />
        </.tabs_content>
      </.tabs>

      <%!-- In the LiveView module --%>
      def handle_event("set_tab", %{"tab" => tab}, socket) do
        {:noreply, assign(socket, active_tab: tab)}
      end

  ## Context propagation via :let

  To avoid passing `default_value` / `active` manually to each trigger and
  content panel, use `:let` to extract the context from `tabs/1`:

      <.tabs :let={ctx} default_value="settings">
        <.tabs_list>
          <%!-- Spread ctx into each trigger — it provides active={...} --%>
          <.tabs_trigger {ctx} value="settings">Settings</.tabs_trigger>
          <.tabs_trigger {ctx} value="billing">Billing</.tabs_trigger>
        </.tabs_list>
        <.tabs_content {ctx} value="settings">
          Settings panel
        </.tabs_content>
        <.tabs_content {ctx} value="billing">
          Billing panel
        </.tabs_content>
      </.tabs>

  `tabs/1` calls `render_slot(@inner_block, %{active: @default_value})` and
  sub-components receive this map via `:let`. Spreading `{ctx}` passes
  `active=default_value` to the sub-component as an assign.

  ## WAI-ARIA implementation

  | Element        | Role         | Key attributes                                |
  |----------------|--------------|-----------------------------------------------|
  | `tabs_list`    | `tablist`    | —                                             |
  | `tabs_trigger` | `tab`        | `aria-selected`, `aria-controls`, `id`        |
  | `tabs_content` | `tabpanel`   | `aria-labelledby`, `id`, hidden when inactive |

  The `tabs_trigger` `id` is `"trigger-{value}"` and the `tabs_content` `id`
  is `"panel-{value}"`. The cross-references (`aria-controls` / `aria-labelledby`)
  connect triggers to their panels in the accessibility tree.

  ## Complete example — settings page

      defmodule MyAppWeb.SettingsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, assign(socket, active_tab: "profile")}
        end

        def handle_event("set_tab", %{"tab" => tab}, socket) do
          {:noreply, assign(socket, active_tab: tab)}
        end

        def render(assigns) do
          ~H\"\"\"
          <div class="max-w-2xl mx-auto p-6">
            <h1 class="text-2xl font-semibold mb-6">Settings</h1>

            <.tabs default_value={@active_tab}>
              <.tabs_list class="w-full justify-start">
                <.tabs_trigger value="profile"
                  phx-click="set_tab" phx-value-tab="profile"
                  active={@active_tab}>
                  Profile
                </.tabs_trigger>
                <.tabs_trigger value="security"
                  phx-click="set_tab" phx-value-tab="security"
                  active={@active_tab}>
                  Security
                </.tabs_trigger>
                <.tabs_trigger value="notifications"
                  phx-click="set_tab" phx-value-tab="notifications"
                  active={@active_tab}>
                  Notifications
                </.tabs_trigger>
              </.tabs_list>

              <.tabs_content value="profile" active={@active_tab} class="pt-4">
                <.profile_form user={@current_user} />
              </.tabs_content>
              <.tabs_content value="security" active={@active_tab} class="pt-4">
                <.security_settings />
              </.tabs_content>
              <.tabs_content value="notifications" active={@active_tab} class="pt-4">
                <.notification_preferences />
              </.tabs_content>
            </.tabs>
          </div>
          \"\"\"
        end
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tabs/1
  # ---------------------------------------------------------------------------

  attr(:default_value, :string,
    required: true,
    doc: """
    Value of the tab that should be active on render. Must exactly match one
    of the `value` attrs of the `tabs_trigger/1` / `tabs_content/1` children.
    Drive this from a LiveView assign for server-side tab switching:
    `default_value={@active_tab}`.
    """
  )

  attr(:variant, :atom,
    values: [:underline, :solid, :pill, :scrollable],
    default: :underline,
    doc: """
    Visual style of the tabs. `:underline` (default) renders a bottom-border
    indicator; `:solid` renders the shadcn segmented-control look with `bg-muted`
    track; `:pill` renders rounded-full pill triggers; `:scrollable` renders a
    horizontally scrollable underline tab bar for many tabs.
    """
  )

  attr(:stacked_mobile, :boolean,
    default: false,
    doc: """
    When `true`, adds `flex-col sm:flex-row` to the tabs list container so
    that tab triggers stack vertically on mobile and return to horizontal
    layout on `sm:` screens and wider. Useful when there are many tabs that
    would overflow horizontally on small viewports.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper `<div>`"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div")

  slot(:inner_block,
    required: true,
    doc: """
    Tab structure: `tabs_list/1` followed by one or more `tabs_content/1` panels.
    When using `:let={ctx}`, spread `{ctx}` on each `tabs_trigger/1` and
    `tabs_content/1` to propagate the active tab value automatically.
    """
  )

  @doc """
  Renders the tabs root wrapper and exposes active-tab context via `:let`.

  `render_slot/2` is called with `%{active: @default_value}` as the context
  value. Sub-components receive this via `:let` and use the `active` key to
  determine whether they are the currently selected tab.

  ## Without :let (explicit active propagation)

      <.tabs default_value={@tab}>
        <.tabs_list>
          <.tabs_trigger value="a" active={@tab}>A</.tabs_trigger>
          <.tabs_trigger value="b" active={@tab}>B</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="a" active={@tab}>Panel A</.tabs_content>
        <.tabs_content value="b" active={@tab}>Panel B</.tabs_content>
      </.tabs>

  ## With :let (automatic context propagation)

      <.tabs :let={ctx} default_value="a">
        <.tabs_list>
          <.tabs_trigger {ctx} value="a">A</.tabs_trigger>
          <.tabs_trigger {ctx} value="b">B</.tabs_trigger>
        </.tabs_list>
        <.tabs_content {ctx} value="a">Panel A</.tabs_content>
        <.tabs_content {ctx} value="b">Panel B</.tabs_content>
      </.tabs>
  """
  def tabs(assigns) do
    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <%!-- Pass active tab value as context so sub-components can receive it via :let --%>
      {render_slot(@inner_block, %{active: @default_value, variant: @variant, stacked_mobile: @stacked_mobile})}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # tabs_list/1
  # ---------------------------------------------------------------------------

  attr(:variant, :atom,
    values: [:underline, :solid, :pill, :scrollable],
    default: :underline,
    doc: "Visual style — must match the `variant` on the parent `tabs/1`"
  )

  attr(:stacked_mobile, :boolean,
    default: false,
    doc: """
    When `true`, adds `flex-col sm:flex-row` to make tab triggers stack
    vertically on mobile and arrange horizontally on `sm:` screens and wider.
    Propagated automatically when using `:let` context from `tabs/1`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes for the tab list container. Use `"w-full"` to
    stretch the list across its parent width, or `"justify-start"` to
    left-align tabs instead of center-aligning them.
    """
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the tablist div")

  slot(:inner_block,
    required: true,
    doc: "One or more `tabs_trigger/1` components"
  )

  @doc """
  Renders the tab trigger list container (`role="tablist"`).

  The list uses `inline-flex` to size itself to its content by default.
  Override with `class="w-full"` for a full-width tab bar. The `bg-muted`
  background and `p-1` padding create the segmented-control look used by
  shadcn/ui tabs.

  ## Example

      <.tabs_list>
        <.tabs_trigger value="tab1">Tab 1</.tabs_trigger>
        <.tabs_trigger value="tab2">Tab 2</.tabs_trigger>
      </.tabs_list>

      <%!-- Full-width, left-aligned tabs --%>
      <.tabs_list class="w-full justify-start border-b bg-transparent rounded-none p-0">
        ...
      </.tabs_list>
  """
  def tabs_list(assigns) do
    ~H"""
    <div
      role="tablist"
      class={cn([list_variant_class(@variant), @stacked_mobile && "flex-col sm:flex-row", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # tabs_trigger/1
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: """
    Unique string identifying this tab trigger. Must match the `value` of the
    corresponding `tabs_content/1` panel and the `default_value` on `tabs/1`
    when this tab should be active initially.
    """
  )

  attr(:variant, :atom,
    values: [:underline, :solid, :pill, :scrollable],
    default: :underline,
    doc: "Visual style — must match the `variant` on the parent `tabs/1`"
  )

  attr(:active, :string,
    default: nil,
    doc: """
    The currently active tab value. Set to the same assign as `tabs/1`'s
    `default_value`. When `active == value`, this trigger renders in its
    selected state. When using `:let={ctx}` on `tabs/1`, this is populated
    automatically.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, the trigger is non-interactive: `pointer-events-none opacity-50`.
    Useful for premium features not available on the current plan.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the trigger button"
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value phx-value-tab),
    doc: """
    HTML attributes forwarded to the button. Use `phx-click` and
    `phx-value-tab` to drive server-side tab switching:

        <.tabs_trigger value="settings" phx-click="set_tab" phx-value-tab="settings">
          Settings
        </.tabs_trigger>
    """
  )

  slot(:inner_block, required: true, doc: "Trigger label — text, icon, or both")

  @doc """
  Renders a single tab trigger button.

  The trigger compares `active` to `value` to determine its selected state:

  - **Active**: `bg-background text-foreground shadow-sm` — visually elevated
  - **Inactive**: `hover:bg-background/50` — subtle hover, muted text

  The button renders with:
  - `role="tab"` for screen readers
  - `id="trigger-{value}"` for `aria-labelledby` cross-reference
  - `aria-selected="true|false"` to announce current state
  - `aria-controls="panel-{value}"` linking to the content panel

  ## Example

      <.tabs_trigger value="overview" active={@active_tab}
                     phx-click="set_tab" phx-value-tab="overview">
        Overview
      </.tabs_trigger>
  """
  def tabs_trigger(assigns) do
    # Compute selected once and store as an assign so we can reference it
    # in both the class list and aria-selected without duplicating the comparison
    assigns = assign(assigns, :selected, assigns.active == assigns.value)

    ~H"""
    <button
      type="button"
      role="tab"
      id={"trigger-#{@value}"}
      aria-selected={to_string(@selected)}
      aria-controls={"panel-#{@value}"}
      disabled={@disabled}
      class={cn([
        trigger_base_class(@variant),
        "ring-offset-background transition-all",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @selected && trigger_active_class(@variant),
        !@selected && trigger_inactive_class(@variant),
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private variant helpers — pattern matching only (no case/cond)
  # ---------------------------------------------------------------------------

  # tabs_list container classes per variant
  defp list_variant_class(:solid),
    do:
      "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground"

  defp list_variant_class(:underline),
    do:
      "inline-flex items-center gap-0 border-b border-border bg-transparent p-0 text-muted-foreground"

  defp list_variant_class(:pill),
    do: "inline-flex items-center gap-1 bg-transparent p-0"

  defp list_variant_class(:scrollable),
    do:
      "flex items-center gap-0 border-b border-border bg-transparent p-0 text-muted-foreground overflow-x-auto scroll-smooth"

  # trigger base shape per variant
  defp trigger_base_class(:solid),
    do:
      "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium"

  defp trigger_base_class(:underline),
    do:
      "inline-flex items-center justify-center whitespace-nowrap rounded-none px-3 py-2 text-sm font-medium border-b-2 border-transparent"

  defp trigger_base_class(:pill),
    do:
      "inline-flex items-center justify-center whitespace-nowrap rounded-full px-4 py-1.5 text-sm font-medium"

  defp trigger_base_class(:scrollable),
    do:
      "inline-flex items-center justify-center whitespace-nowrap rounded-none px-3 py-2 text-sm font-medium border-b-2 border-transparent shrink-0"

  # active trigger classes per variant
  defp trigger_active_class(:solid), do: "bg-background text-foreground shadow-sm"
  defp trigger_active_class(:underline), do: "border-b-2 border-primary text-foreground"
  defp trigger_active_class(:pill), do: "bg-primary text-primary-foreground"
  defp trigger_active_class(:scrollable), do: "border-b-2 border-primary text-foreground"

  # inactive trigger hover classes per variant
  defp trigger_inactive_class(:solid), do: "hover:bg-background/50"
  defp trigger_inactive_class(:underline), do: "text-muted-foreground hover:text-foreground"
  defp trigger_inactive_class(:pill), do: "hover:bg-muted text-muted-foreground"
  defp trigger_inactive_class(:scrollable), do: "text-muted-foreground hover:text-foreground"

  # ---------------------------------------------------------------------------
  # tabs_content/1
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: """
    Unique string matching the corresponding `tabs_trigger/1` value. The panel
    is visible when `active == value` and hidden (via `hidden` class) otherwise.
    """
  )

  attr(:active, :string,
    default: nil,
    doc: """
    The currently active tab value. Set to the same assign as `tabs/1`'s
    `default_value`. When using `:let={ctx}` on `tabs/1`, this is populated
    automatically via the spread `{ctx}`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the panel div (e.g. `\"pt-4\"`)"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the panel div")

  slot(:inner_block, required: true, doc: "Panel content — rendered only when the tab is active")

  @doc """
  Renders a tab content panel (`role="tabpanel"`).

  The panel is shown when `active == value` and hidden otherwise via Tailwind's
  `hidden` class. Content is always rendered in the HTML (for SEO and ARIA
  discoverability), but invisible when not active.

  If you want to avoid rendering inactive content at all (e.g. for expensive
  queries), conditionally render panels in your LiveView template instead:

      <%= if @active_tab == "analytics" do %>
        <.tabs_content value="analytics" active={@active_tab}>
          <.heavy_analytics_chart />
        </.tabs_content>
      <% end %>

  ## ARIA connections

  - `id="panel-{value}"` — referenced by `aria-controls="panel-{value}"` on the trigger
  - `aria-labelledby="trigger-{value}"` — references the trigger button's `id`

  ## Example

      <.tabs_content value="billing" active={@active_tab} class="pt-4">
        <.billing_form subscription={@subscription} />
      </.tabs_content>
  """
  def tabs_content(assigns) do
    # Compute visibility once to keep the template readable
    assigns = assign(assigns, :visible, assigns.active == assigns.value)

    ~H"""
    <div
      role="tabpanel"
      id={"panel-#{@value}"}
      aria-labelledby={"trigger-#{@value}"}
      class={cn([
        "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        # Hidden class makes the panel invisible when it is not the active tab.
        # The panel is still rendered in the DOM (for ARIA/SEO) but display: none.
        !@visible && "hidden",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
