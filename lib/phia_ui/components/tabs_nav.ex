defmodule PhiaUi.Components.TabsNav do
  @moduledoc """
  Horizontal tab navigation component.

  Provides accessible tab-style navigation for page-level or section-level
  routing. Three visual variants: underline (default), pills, and segment.

  ## Sub-components

  - `tabs_nav/1` — outer container (`role="tablist"`)
  - `tabs_nav_item/1` — individual tab (`role="tab"`)

  ## Example

      <.tabs_nav>
        <.tabs_nav_item href="/home">Home</.tabs_nav_item>
        <.tabs_nav_item href="/finances" active>Finances</.tabs_nav_item>
        <.tabs_nav_item href="/workflows">Workflows</.tabs_nav_item>
      </.tabs_nav>

      <%!-- Pills variant --%>
      <.tabs_nav variant={:pills}>
        <.tabs_nav_item href="#overview" active>Overview</.tabs_nav_item>
        <.tabs_nav_item href="#analytics">Analytics</.tabs_nav_item>
      </.tabs_nav>

      <%!-- Segment variant --%>
      <.tabs_nav variant={:segment}>
        <.tabs_nav_item href="#day" active>Day</.tabs_nav_item>
        <.tabs_nav_item href="#week">Week</.tabs_nav_item>
        <.tabs_nav_item href="#month">Month</.tabs_nav_item>
      </.tabs_nav>

  ## Accessibility

  - `role="tablist"` on container
  - `role="tab"` on each item
  - `aria-selected` reflects active state
  - `tabindex` managed: active tab is `0`, others `-1`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tabs_nav/1
  # ---------------------------------------------------------------------------

  attr(:variant, :atom,
    values: [:underline, :pills, :segment],
    default: :underline,
    doc: "Visual style variant"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the nav element")

  slot(:inner_block, required: true, doc: "tabs_nav_item components")

  @doc """
  Renders a horizontal tab navigation container.

  ## Variants

  | Variant      | Description                                      |
  |--------------|--------------------------------------------------|
  | `:underline` | Bottom border on active tab (default)            |
  | `:pills`     | Filled background on active tab, rounded corners |
  | `:segment`   | Segmented control style, bg-muted container      |
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

  attr(:href, :string, default: "#", doc: "Navigation href")
  attr(:active, :boolean, default: false, doc: "Whether this tab is currently selected")
  attr(:disabled, :boolean, default: false, doc: "Whether this tab is disabled")

  attr(:variant, :atom,
    values: [:underline, :pills, :segment],
    default: :underline,
    doc: "Must match parent tabs_nav variant (set automatically when using tabs_nav slot)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the anchor element")

  slot(:inner_block, required: true, doc: "Tab label content")

  @doc "Renders an individual tab item inside `tabs_nav/1`."
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

  defp tabs_nav_class(:underline) do
    "inline-flex items-center border-b border-border w-full gap-4"
  end

  defp tabs_nav_class(:pills) do
    "inline-flex items-center gap-1"
  end

  defp tabs_nav_class(:segment) do
    "inline-flex items-center rounded-lg bg-muted p-1 gap-0.5"
  end

  defp tabs_item_base_class do
    "inline-flex items-center justify-center whitespace-nowrap text-sm font-medium " <>
      "transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 cursor-pointer"
  end

  defp tabs_item_variant_class(:underline, true) do
    "border-b-2 border-primary text-foreground -mb-px pb-3 pt-1 px-1"
  end

  defp tabs_item_variant_class(:underline, false) do
    "border-b-2 border-transparent text-muted-foreground hover:text-foreground " <>
      "hover:border-border -mb-px pb-3 pt-1 px-1"
  end

  defp tabs_item_variant_class(:pills, true) do
    "rounded-md bg-primary text-primary-foreground px-3 py-1.5 shadow-sm"
  end

  defp tabs_item_variant_class(:pills, false) do
    "rounded-md text-muted-foreground hover:bg-accent hover:text-accent-foreground px-3 py-1.5"
  end

  defp tabs_item_variant_class(:segment, true) do
    "rounded-md bg-background text-foreground shadow-sm px-3 py-1.5"
  end

  defp tabs_item_variant_class(:segment, false) do
    "rounded-md text-muted-foreground hover:text-foreground px-3 py-1.5"
  end
end
