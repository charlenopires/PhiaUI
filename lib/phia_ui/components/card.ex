defmodule PhiaUi.Components.Card do
  @moduledoc """
  Composable Card component with 6 independent sub-components.

  Follows the shadcn/ui Card anatomy adapted for Phoenix LiveView.
  Each sub-component is independently usable and accepts `:class` for
  Tailwind overrides merged via `cn/1`.

  ## Sub-components

  | Function            | Element | Purpose                              |
  |---------------------|---------|--------------------------------------|
  | `card/1`            | `<div>` | Outer container with surface         |
  | `card_header/1`     | `<div>` | Header layout (title + desc)         |
  | `card_title/1`      | `<h3>`  | Card heading                         |
  | `card_description/1`| `<p>`   | Subtitle / supporting text           |
  | `card_action/1`     | `<div>` | Action anchored top-right of header  |
  | `card_content/1`    | `<div>` | Primary content area                 |
  | `card_footer/1`     | `<div>` | Footer row (actions, meta)           |

  ## Example — full composition

      <.card>
        <.card_header>
          <.card_title>Account Balance</.card_title>
          <.card_description>Your current balance</.card_description>
        </.card_header>
        <.card_content>
          <p class="text-2xl font-bold">$12,340.00</p>
        </.card_content>
        <.card_footer>
          <span class="text-sm text-muted-foreground">Last updated: today</span>
        </.card_footer>
      </.card>

  ## Example — class override

      <.card class="w-full max-w-sm">
        <.card_content>Compact card</.card_content>
      </.card>

  ## Example — @rest passthrough

      <.card data-testid="balance-card" aria-label="Account balance">
        …
      </.card>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # card/1
  # ---------------------------------------------------------------------------

  attr(:size, :string,
    values: ~w(default sm),
    default: "default",
    doc: "Size variant: 'sm' constrains to max-w-sm"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the div element")
  slot(:inner_block, required: true, doc: "Card content")

  @doc """
  Renders the outer Card container.

  Produces a `<div>` with a `rounded-lg border shadow` outline and the
  `bg-card` / `text-card-foreground` semantic colour tokens, which adapt
  automatically to light and dark mode without any extra CSS.

  The `:size` variant restricts the maximum width:
  - `"default"` — no width constraint (fills the parent)
  - `"sm"` — `max-w-sm` (384px), suitable for narrow UI cards such as stat
    summaries, profile previews, or simple settings panels

  ## Examples

      <%!-- Full-width card in a grid column --%>
      <.card>
        <.card_header>
          <.card_title>Revenue</.card_title>
        </.card_header>
        <.card_content>
          <p class="text-3xl font-bold">$48,200</p>
        </.card_content>
      </.card>

      <%!-- Narrow card constrained to 384px --%>
      <.card size="sm">
        <.card_content>Compact side panel card.</.card_content>
      </.card>

      <%!-- Custom width and data attribute --%>
      <.card class="max-w-md" data-testid="profile-card">
        <.card_content>…</.card_content>
      </.card>
  """
  def card(assigns) do
    ~H"""
    <div
      class={cn(["rounded-lg border bg-card text-card-foreground shadow", card_size(@size), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_header/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the div element")
  slot(:inner_block, required: true, doc: "Header content (title + description)")

  @doc """
  Renders the Card header layout area.

  Produces a `<div>` with `flex flex-col space-y-1.5 p-6`. The `relative`
  positioning is intentional — it makes this element the offset parent for
  `card_action/1`, which uses `absolute right-6 top-6` to anchor an action
  button or menu to the top-right corner of the header.

  Typically wraps `card_title/1` and `card_description/1`. May also contain
  a `card_action/1` for contextual actions.

  ## Examples

      <%!-- Standard title + description header --%>
      <.card_header>
        <.card_title>Account Settings</.card_title>
        <.card_description>Manage your account preferences.</.card_description>
      </.card_header>

      <%!-- Header with an anchored action button --%>
      <.card_header>
        <.card_title>Notifications</.card_title>
        <.card_action>
          <.button variant={:ghost} size={:icon_sm} aria-label="Settings">
            <.icon name="settings" />
          </.button>
        </.card_action>
      </.card_header>

      <%!-- Custom padding via class override --%>
      <.card_header class="p-4">
        <.card_title>Compact header</.card_title>
      </.card_header>
  """
  def card_header(assigns) do
    ~H"""
    <div class={cn(["relative flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_title/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the h3 element")
  slot(:inner_block, required: true, doc: "Title text")

  @doc """
  Renders the Card title as an `<h3>` heading.

  Applies `font-semibold leading-none tracking-tight` for a compact,
  high-contrast heading that reads clearly at any card width. The `<h3>`
  element provides semantic heading structure — screen readers include it
  in the page's heading hierarchy.

  Keep card titles short and descriptive (3–6 words). For a subtitle or
  supporting sentence, pair with `card_description/1`.

  ## Examples

      <.card_title>Account Balance</.card_title>

      <.card_title>Recent Orders</.card_title>

      <%!-- Custom size via class --%>
      <.card_title class="text-base">Compact title</.card_title>

      <%!-- Linked title — useful for navigable resource cards --%>
      <.card_title>
        <a href="/projects/42" class="hover:underline">Project Alpha</a>
      </.card_title>
  """
  def card_title(assigns) do
    ~H"""
    <h3 class={cn(["font-semibold leading-none tracking-tight", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  # ---------------------------------------------------------------------------
  # card_description/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the p element")
  slot(:inner_block, required: true, doc: "Description text")

  @doc """
  Renders the Card description as a `<p>` element.

  Applies `text-sm text-muted-foreground` — smaller, less prominent text
  that acts as a subtitle or supporting sentence beneath `card_title/1`.
  The muted colour ensures visual hierarchy: the title draws the eye first,
  and the description provides context without competing.

  ## Examples

      <.card_description>Your current monthly usage.</.card_description>

      <.card_description>
        Configure how notifications are delivered to your team.
      </.card_description>

      <%!-- Emphasising a key detail in the description --%>
      <.card_description>
        Last updated <strong>2 minutes ago</strong>.
      </.card_description>
  """
  def card_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # card_action/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the div element")
  slot(:inner_block, required: true, doc: "Action content (icon button, menu trigger, etc.)")

  @doc """
  Renders an action area anchored to the top-right corner of `card_header/1`.

  Requires `card_header/1` to be the parent (which provides `relative` positioning).

      <.card>
        <.card_header>
          <.card_title>Settings</.card_title>
          <.card_action>
            <.button variant={:ghost} size={:icon_sm} aria-label="More options">
              <.icon name="hero-ellipsis-horizontal" />
            </.button>
          </.card_action>
        </.card_header>
      </.card>
  """
  def card_action(assigns) do
    ~H"""
    <div class={cn(["absolute right-6 top-6", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the div element")
  slot(:inner_block, required: true, doc: "Primary content")

  @doc """
  Renders the Card content area.

  Applies `p-6 pt-0`. The `pt-0` removes the top padding so the content
  sits flush beneath `card_header/1` without double-padding. When used
  without a header, add `pt-6` via `:class` to restore the full padding.

  This is the primary slot for the card's main payload — metrics, lists,
  forms, charts, or any structured content.

  ## Examples

      <%!-- After a card_header --%>
      <.card_content>
        <p class="text-3xl font-bold">$48,200</p>
        <p class="text-xs text-muted-foreground">+12% from last month</p>
      </.card_content>

      <%!-- Without a header — restore top padding --%>
      <.card_content class="pt-6">
        <p>Standalone content card with full padding.</p>
      </.card_content>

      <%!-- Form inside a card --%>
      <.card_content>
        <.form for={@form} phx-submit="save">
          <.phia_input field={@form[:email]} label="Email" />
          <.button type="submit">Subscribe</.button>
        </.form>
      </.card_content>
  """
  def card_content(assigns) do
    ~H"""
    <div class={cn(["p-6 pt-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_footer/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the div element")
  slot(:inner_block, required: true, doc: "Footer content (actions, metadata)")

  @doc """
  Renders the Card footer row.

  Applies `flex items-center p-6 pt-0`. Like `card_content/1`, `pt-0`
  removes the top padding to avoid double-padding after the header or
  content section. The `flex items-center` layout aligns footer items
  vertically and places them in a horizontal row.

  Typically used for action buttons, metadata summaries, or navigational
  links at the bottom of the card. For right-aligned buttons, add
  `class="justify-end"` or `class="justify-between"` for spread layouts.

  ## Examples

      <%!-- Action buttons — right-aligned --%>
      <.card_footer class="justify-end gap-2">
        <.button variant={:outline}>Cancel</.button>
        <.button>Save changes</.button>
      </.card_footer>

      <%!-- Metadata row — spread layout --%>
      <.card_footer class="justify-between">
        <span class="text-sm text-muted-foreground">Updated 3 min ago</span>
        <.button variant={:link} size={:sm}>View all</.button>
      </.card_footer>

      <%!-- Single centred link --%>
      <.card_footer class="justify-center">
        <.button variant={:ghost}>Load more</.button>
      </.card_footer>
  """
  def card_footer(assigns) do
    ~H"""
    <div class={cn(["flex items-center p-6 pt-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp card_size("sm"), do: "max-w-sm"
  defp card_size("default"), do: nil
end
