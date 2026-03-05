defmodule PhiaUi.Components.Breadcrumb do
  @moduledoc """
  Breadcrumb navigation component following the shadcn/ui Breadcrumb anatomy.

  Breadcrumbs communicate the current page's location within the site hierarchy
  and allow users to navigate upward. This implementation is purely HEEx with
  no JavaScript required. Full WAI-ARIA support is included out of the box.

  ## Sub-components

  | Component               | Element  | Purpose                                         |
  |-------------------------|----------|-------------------------------------------------|
  | `breadcrumb/1`          | `<nav>`  | Landmark wrapper with `aria-label="breadcrumb"` |
  | `breadcrumb_list/1`     | `<ol>`   | Ordered flex container for items                |
  | `breadcrumb_item/1`     | `<li>`   | Individual item wrapper                         |
  | `breadcrumb_link/1`     | `<a>`    | Navigable ancestor link                         |
  | `breadcrumb_page/1`     | `<span>` | Current page label (`aria-current="page"`)      |
  | `breadcrumb_separator/1`| `<li>`   | Visual separator (default: `/`)                 |
  | `breadcrumb_ellipsis/1` | `<span>` | Collapsed path indicator (`…`)                  |

  ## Basic usage

      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link href="/">Home</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_link href="/settings">Settings</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_page>Profile</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>

  ## Nested resource navigation

  Useful when displaying a deeply-nested record in an admin panel, e.g.
  `Organizations > Acme Corp > Teams > Engineering > Members > Jane`:

      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link navigate={~p"/organizations"}>Organizations</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_link navigate="/organizations/acme">
              Acme Corp
            </.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <%!-- Collapse intermediate levels on small viewports --%>
          <.breadcrumb_item>
            <.breadcrumb_ellipsis />
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_page>{@member.name}</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>

  ## Custom separator

  Replace the default `/` with any icon or character:

      <.breadcrumb_separator>
        <.icon name="chevron-right" size={:xs} />
      </.breadcrumb_separator>

  ## Accessibility

  - The `<nav>` root carries `aria-label="breadcrumb"` so screen readers
    announce it as a distinct landmark.
  - The current page `<span>` carries `aria-current="page"` so screen readers
    convey that the user is viewing this item.
  - Separators carry `aria-hidden="true"` to avoid cluttering screen reader
    output with decorative punctuation.
  - The `<ol>` element communicates order semantics to assistive technologies.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # breadcrumb/1 — <nav> landmark wrapper
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<nav>` element."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<nav>` element (e.g. `data-testid`)."
  )

  slot(:inner_block, required: true, doc: "Should contain a single `breadcrumb_list/1`.")

  @doc """
  Renders the `<nav aria-label="breadcrumb">` landmark wrapper.

  This is the outermost container. Screen readers expose it as a named
  navigation region distinct from the main navigation. Always place a
  `breadcrumb_list/1` inside.

  ## Example

      <.breadcrumb>
        <.breadcrumb_list>
          ...
        </.breadcrumb_list>
      </.breadcrumb>
  """
  def breadcrumb(assigns) do
    ~H"""
    <nav aria-label="breadcrumb" class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_list/1 — <ol> flex container
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<ol>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<ol>` element.")

  slot(:inner_block,
    required: true,
    doc: "Should contain `breadcrumb_item/1` and `breadcrumb_separator/1` children."
  )

  @doc """
  Renders the `<ol>` flex container that holds all breadcrumb items.

  Uses `flex-wrap` so a long trail wraps gracefully on small screens.
  The `sm:gap-2.5` gap widens on larger viewports.

  ## Example

      <.breadcrumb_list>
        <.breadcrumb_item>...</.breadcrumb_item>
        <.breadcrumb_separator />
        <.breadcrumb_item>...</.breadcrumb_item>
      </.breadcrumb_list>
  """
  def breadcrumb_list(assigns) do
    ~H"""
    <ol
      class={cn(["flex flex-wrap items-center gap-1.5 break-words text-sm text-muted-foreground sm:gap-2.5", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_item/1 — <li> item wrapper
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<li>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")

  slot(:inner_block,
    required: true,
    doc: "A `breadcrumb_link/1`, `breadcrumb_page/1`, or `breadcrumb_ellipsis/1`."
  )

  @doc """
  Renders a `<li>` wrapper for a single breadcrumb entry.

  Each visible step in the trail should be wrapped in a `breadcrumb_item/1`.
  Place `breadcrumb_separator/1` directly inside `breadcrumb_list/1` between
  items — it renders as its own `<li>` and does not need to be inside an item.

  ## Example

      <.breadcrumb_item>
        <.breadcrumb_link href="/products">Products</.breadcrumb_link>
      </.breadcrumb_item>
  """
  def breadcrumb_item(assigns) do
    ~H"""
    <li class={cn(["inline-flex items-center gap-1.5", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_link/1 — <a> ancestor link
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: nil, doc: "Standard HTML href for the link URL.")

  attr(:navigate, :string,
    default: nil,
    doc: "Phoenix LiveView `phx-navigate` path (client-side navigation without full page reload)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the `<a>` element.")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<a>` element (e.g. `target`, `rel`)."
  )

  slot(:inner_block, required: true, doc: "Link text or content.")

  @doc """
  Renders a navigable ancestor link in the breadcrumb trail.

  Provide either `href` for standard page navigation or `navigate` for
  LiveView client-side navigation (avoids a full page reload). When both
  are provided, `href` takes precedence.

  The link shows a hover underline via `hover:text-foreground hover:underline`
  to reinforce its interactive nature.

  ## Example

      <%!-- Standard href --%>
      <.breadcrumb_link href="/dashboard">Dashboard</.breadcrumb_link>

      <%!-- LiveView patch (pushes to browser history without reload) --%>
      <.breadcrumb_link navigate="/projects/42">
        My Project
      </.breadcrumb_link>
  """
  def breadcrumb_link(assigns) do
    ~H"""
    <a
      href={@href || @navigate}
      class={cn(["transition-colors hover:text-foreground hover:underline", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_page/1 — current page (non-link)
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<span>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<span>` element.")
  slot(:inner_block, required: true, doc: "The current page name or label.")

  @doc """
  Renders the current page label — the last and non-interactive crumb.

  Unlike `breadcrumb_link/1`, this is a `<span>` (not a link) because the
  user is already on this page. It carries `aria-current="page"` so screen
  readers announce "Page, [label]" providing clear spatial context.

  Styled `text-foreground font-normal` to visually distinguish it from
  the muted-foreground ancestor links.

  ## Example

      <.breadcrumb_item>
        <.breadcrumb_page>Billing</.breadcrumb_page>
      </.breadcrumb_item>
  """
  def breadcrumb_page(assigns) do
    ~H"""
    <span
      aria-current="page"
      class={cn(["font-normal text-foreground", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_separator/1 — visual separator
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the separator `<li>`."
  )

  slot(:inner_block,
    doc:
      "Custom separator content. When provided, overrides the default `/` character. Ideal for an icon component."
  )

  @doc """
  Renders a breadcrumb separator between two items.

  Defaults to the `/` character. Supply a custom inner block to use a
  different separator — for example a `chevron-right` icon:

      <.breadcrumb_separator>
        <.icon name="chevron-right" size={:xs} />
      </.breadcrumb_separator>

  The separator is always `aria-hidden="true"` so screen readers do not
  read decorative punctuation between each crumb.

  ## Placement

  Place `breadcrumb_separator/1` directly inside `breadcrumb_list/1`,
  between two `breadcrumb_item/1` elements:

      <.breadcrumb_list>
        <.breadcrumb_item>...</.breadcrumb_item>
        <.breadcrumb_separator />          <%!-- between items --%>
        <.breadcrumb_item>...</.breadcrumb_item>
      </.breadcrumb_list>
  """
  def breadcrumb_separator(assigns) do
    ~H"""
    <li aria-hidden="true" class={cn(["[&>svg]:size-3.5", @class])}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        /
      <% end %>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_ellipsis/1 — collapsed path indicator
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the ellipsis `<span>`."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<span>` element.")

  @doc """
  Renders a `…` ellipsis to indicate that intermediate path segments have
  been collapsed.

  Use this when the trail is too long to display in full (e.g. on mobile).
  Typically wrapped in a `breadcrumb_item/1`:

      <.breadcrumb_item>
        <.breadcrumb_ellipsis />
      </.breadcrumb_item>

  The ellipsis is `aria-hidden="true"` because it is purely decorative;
  the hidden segments do not provide navigation value to screen reader users
  in this collapsed state.

  For accessible collapsible breadcrumbs, consider a `<details>` or a
  `phx-click` toggle that expands hidden items on demand.
  """
  def breadcrumb_ellipsis(assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={cn(["flex h-9 w-9 items-center justify-center", @class])}
      {@rest}
    >
      …
    </span>
    """
  end
end
