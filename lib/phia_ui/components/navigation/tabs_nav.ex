defmodule PhiaUi.Components.TabsNav do
  @moduledoc """
  Horizontal tab navigation component for page-level and section-level routing.

  `TabsNav` renders accessible tab-style navigation using `<a>` links rather
  than `<button>` elements, making it suitable for route-based navigation where
  each tab corresponds to a different URL or live action.

  ## When to use TabsNav vs Tabs

  | Component  | Use case                                                       |
  |------------|----------------------------------------------------------------|
  | `TabsNav`  | Route-based navigation — tabs link to different pages/actions  |
  | `Tabs`     | Content panels — tabs switch content on the same page          |

  Use `TabsNav` with `@live_action` to highlight the current section:

      <.tabs_nav>
        <.tabs_nav_item href="/dashboard" active={@live_action == :index}>
          Dashboard
        </.tabs_nav_item>
        <.tabs_nav_item href="/analytics" active={@live_action == :analytics}>
          Analytics
        </.tabs_nav_item>
      </.tabs_nav>

  ## Visual variants

  Three visual styles are available via the `:variant` attribute:

  | Variant      | Appearance                                              | Best for                  |
  |--------------|---------------------------------------------------------|---------------------------|
  | `:underline` | Bottom border indicator on active tab (default)         | Standard page navigation  |
  | `:pills`     | Filled primary background on active tab, rounded        | Compact section switching |
  | `:segment`   | Segmented control inside a muted container, no border   | Dense dashboards          |

  ## Underline variant (default)

      <.tabs_nav>
        <.tabs_nav_item href="/overview" active>Overview</.tabs_nav_item>
        <.tabs_nav_item href="/analytics">Analytics</.tabs_nav_item>
        <.tabs_nav_item href="/reports">Reports</.tabs_nav_item>
      </.tabs_nav>

  ## Pills variant

      <.tabs_nav variant={:pills}>
        <.tabs_nav_item href="#overview" variant={:pills} active>Overview</.tabs_nav_item>
        <.tabs_nav_item href="#analytics" variant={:pills}>Analytics</.tabs_nav_item>
      </.tabs_nav>

  ## Segment variant

  The segment variant wraps items inside a `bg-muted` container with `p-1`,
  creating the look of a segmented control (similar to iOS segment pickers):

      <.tabs_nav variant={:segment}>
        <.tabs_nav_item href="#day"   variant={:segment} active>Day</.tabs_nav_item>
        <.tabs_nav_item href="#week"  variant={:segment}>Week</.tabs_nav_item>
        <.tabs_nav_item href="#month" variant={:segment}>Month</.tabs_nav_item>
      </.tabs_nav>

  ## Driven by live_action

      defmodule MyAppWeb.ReportsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, socket}
        end

        def handle_params(%{"section" => section}, _uri, socket) do
          {:noreply, assign(socket, section: section)}
        end

        def render(assigns) do
          ~H\"\"\"
          <.tabs_nav>
            <.tabs_nav_item href="/reports" active={@section == "overview"}>
              Overview
            </.tabs_nav_item>
            <.tabs_nav_item href="/reports/revenue" active={@section == "revenue"}>
              Revenue
            </.tabs_nav_item>
            <.tabs_nav_item href="/reports/users" active={@section == "users"}>
              Users
            </.tabs_nav_item>
          </.tabs_nav>

          <%!-- Render different content based on section --%>
          <%= case @section do %>
            <% "overview" -> %> <.overview_content />
            <% "revenue"  -> %> <.revenue_report data={@revenue} />
            <% "users"    -> %> <.users_report data={@users} />
          <% end %>
          \"\"\"
        end
      end

  ## Dashboard tabs with phx-click (no navigation)

  When you want tab-like navigation without changing the URL, use `phx-click`
  on an in-page anchor and drive state from LiveView assigns:

      <.tabs_nav variant={:pills}>
        <.tabs_nav_item
          href="#"
          variant={:pills}
          active={@view == "chart"}
          phx-click="set_view"
          phx-value-view="chart"
        >
          Chart
        </.tabs_nav_item>
        <.tabs_nav_item
          href="#"
          variant={:pills}
          active={@view == "table"}
          phx-click="set_view"
          phx-value-view="table"
        >
          Table
        </.tabs_nav_item>
      </.tabs_nav>

  ## Accessibility

  - `role="tablist"` on the `<nav>` container with `aria-orientation="horizontal"`
  - `role="tab"` on each `<a>` item
  - `aria-selected="true|false"` reflects active state
  - `tabindex="0"` on the active item; `tabindex="-1"` on inactive items
    (keyboard navigation follows the ARIA tabs pattern)
  - Disabled items: no `href`, `pointer-events-none opacity-50`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tabs_nav/1
  # ---------------------------------------------------------------------------

  attr(:variant, :atom,
    values: [:underline, :pills, :segment, :scrollable],
    default: :underline,
    doc: """
    Visual style variant for the tab navigation container.

    - `:underline` — bottom border on the container; active tab has
      `border-b-2 border-primary` indicator
    - `:pills` — no container border; active tab has `bg-primary
      text-primary-foreground` filled pill
    - `:segment` — `bg-muted p-1 rounded-lg` container; active tab has
      `bg-background text-foreground shadow-sm`
    - `:scrollable` — horizontally scrollable underline variant for many tabs
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the nav element")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<nav>` element (e.g. `aria-label`)"
  )

  slot(:inner_block, required: true, doc: "`tabs_nav_item/1` components")

  @doc """
  Renders a horizontal tab navigation container.

  ## Variant reference

  | Variant      | Container classes                              |
  |--------------|------------------------------------------------|
  | `:underline` | `inline-flex items-center border-b w-full gap-4` |
  | `:pills`     | `inline-flex items-center gap-1`               |
  | `:segment`   | `inline-flex items-center rounded-lg bg-muted p-1 gap-0.5` |

  ## Example

      <.tabs_nav variant={:segment}>
        <.tabs_nav_item href="#week"  variant={:segment} active>Week</.tabs_nav_item>
        <.tabs_nav_item href="#month" variant={:segment}>Month</.tabs_nav_item>
        <.tabs_nav_item href="#year"  variant={:segment}>Year</.tabs_nav_item>
      </.tabs_nav>
  """
  def tabs_nav(assigns) do
    ~H"""
    <nav
      role="tablist"
      aria-orientation="horizontal"
      class={cn([tabs_nav_class(@variant), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string,
    default: "#",
    doc: """
    Navigation href for the anchor element. Use a real URL for route-based
    navigation (`"/analytics"`), an anchor hash for same-page navigation
    (`"#revenue"`), or `"#"` with `phx-click` for purely LiveView-driven state.
    """
  )

  attr(:active, :boolean,
    default: false,
    doc: """
    Whether this tab is currently selected. Drives active styles and
    `aria-selected`. Typically derived from `@live_action` or a local assign:
    `active={@live_action == :analytics}`.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, the tab is non-interactive: `href` is set to `nil` (preventing
    navigation), and `pointer-events-none opacity-50` is applied. Use for
    features that are coming soon or not available on the current plan.
    """
  )

  attr(:variant, :atom,
    values: [:underline, :pills, :segment, :scrollable],
    default: :underline,
    doc: """
    Visual style variant. Must match the parent `tabs_nav/1` variant so the
    active/inactive styles are consistent. When using `tabs_nav/1` you are
    responsible for passing the same variant to each item.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the anchor element")

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to the `<a>` element. Use `phx-click` and
    `phx-value-*` for LiveView-driven tab switching without route changes.
    """
  )

  slot(:inner_block, required: true, doc: "Tab label — text, icon, or both")

  @doc """
  Renders an individual tab navigation item inside `tabs_nav/1`.

  Uses an `<a>` element (not `<button>`) so it is naturally keyboard-focusable
  and screen-reader-friendly as a navigation link. The `role="tab"` attribute
  overrides the link semantics to signal tablist membership.

  When `disabled` is `true`, `href` is set to `nil` which prevents the browser
  from navigating while keeping the element in the tab order.

  ## Example

      <.tabs_nav_item
        href="/reports/revenue"
        variant={:underline}
        active={@section == "revenue"}
      >
        Revenue
      </.tabs_nav_item>
  """
  def tabs_nav_item(assigns) do
    ~H"""
    <a
      href={if @disabled, do: nil, else: @href}
      role="tab"
      aria-selected={to_string(@active)}
      tabindex={if @active, do: "0", else: "-1"}
      class={cn([
        tabs_item_base_class(),
        tabs_item_variant_class(@variant, @active),
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Container layout classes for each variant.
  # :underline uses a full-width bottom border so the active indicator
  # (border-b-2) sits flush against the container's border.
  defp tabs_nav_class(:underline) do
    "inline-flex items-center border-b border-border w-full gap-4"
  end

  # :pills needs no outer border — items are self-contained pills
  defp tabs_nav_class(:pills) do
    "inline-flex items-center gap-1"
  end

  # :segment wraps everything in a muted background pill container.
  # tight gap-0.5 keeps segment items visually joined.
  defp tabs_nav_class(:segment) do
    "inline-flex items-center rounded-lg bg-muted p-1 gap-0.5"
  end

  # :scrollable is a full-width underline nav that scrolls horizontally.
  defp tabs_nav_class(:scrollable) do
    "flex items-center border-b border-border w-full gap-0 overflow-x-auto scroll-smooth"
  end

  # Base classes shared across all variants and active states.
  # Defines interaction and focus styles; variant-specific colors are
  # added separately by tabs_item_variant_class/2.
  defp tabs_item_base_class do
    "inline-flex items-center justify-center whitespace-nowrap text-sm font-medium " <>
      "transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 cursor-pointer"
  end

  # Variant + active state class combinations.
  # Defined as separate function heads (one per variant × active boolean) for
  # exhaustiveness-checking by the compiler and readability over a nested cond.

  # Underline active: -mb-px extends the border downward to overlap the
  # container's border-b, creating the illusion of a continuous underline.
  defp tabs_item_variant_class(:underline, true) do
    "border-b-2 border-primary text-foreground -mb-px pb-3 pt-1 px-1"
  end

  defp tabs_item_variant_class(:underline, false) do
    "border-b-2 border-transparent text-muted-foreground hover:text-foreground " <>
      "hover:border-border -mb-px pb-3 pt-1 px-1"
  end

  # Pills active: filled primary background with inverted text
  defp tabs_item_variant_class(:pills, true) do
    "rounded-md bg-primary text-primary-foreground px-3 py-1.5 shadow-sm"
  end

  defp tabs_item_variant_class(:pills, false) do
    "rounded-md text-muted-foreground hover:bg-accent hover:text-accent-foreground px-3 py-1.5"
  end

  # Segment active: white card elevated with shadow inside the muted container
  defp tabs_item_variant_class(:segment, true) do
    "rounded-md bg-background text-foreground shadow-sm px-3 py-1.5"
  end

  defp tabs_item_variant_class(:segment, false) do
    "rounded-md text-muted-foreground hover:text-foreground px-3 py-1.5"
  end

  # Scrollable: underline style, shrink-0 to prevent item compression
  defp tabs_item_variant_class(:scrollable, true) do
    "border-b-2 border-primary text-foreground -mb-px pb-3 pt-1 px-3 shrink-0"
  end

  defp tabs_item_variant_class(:scrollable, false) do
    "border-b-2 border-transparent text-muted-foreground hover:text-foreground " <>
      "hover:border-border -mb-px pb-3 pt-1 px-3 shrink-0"
  end
end
