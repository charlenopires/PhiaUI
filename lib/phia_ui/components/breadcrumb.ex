defmodule PhiaUi.Components.Breadcrumb do
  @moduledoc """
  Breadcrumb navigation component.

  Follows the shadcn/ui Breadcrumb anatomy with 7 composable sub-components.
  Pure HEEx — no JavaScript required. Fully accessible via WAI-ARIA.

  ## Sub-components

  - `breadcrumb/1` — `<nav aria-label="breadcrumb">` wrapper
  - `breadcrumb_list/1` — `<ol>` flex container
  - `breadcrumb_item/1` — `<li>` item wrapper
  - `breadcrumb_link/1` — `<a>` navigable link
  - `breadcrumb_page/1` — current page (non-link, `aria-current="page"`)
  - `breadcrumb_separator/1` — `/` separator (or custom slot)
  - `breadcrumb_ellipsis/1` — `…` collapsed path indicator

  ## Example

      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link href="/">Home</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_link href="/docs">Docs</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_page>Components</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to <nav>")
  slot(:inner_block, required: true)

  @doc "Renders the `<nav aria-label='breadcrumb'>` wrapper."
  def breadcrumb(assigns) do
    ~H"""
    <nav aria-label="breadcrumb" class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the `<ol>` flex container for breadcrumb items."
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a `<li>` breadcrumb item wrapper."
  def breadcrumb_item(assigns) do
    ~H"""
    <li class={cn(["inline-flex items-center gap-1.5", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr(:href, :string, default: nil, doc: "Link URL")
  attr(:navigate, :string, default: nil, doc: "LiveView navigate path")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a navigable `<a>` breadcrumb link with hover underline."
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders the current page label (non-link).

  Includes `aria-current='page'` and `role='link'` for screen readers.
  Styled with `text-foreground font-normal` to distinguish from links.
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  slot(:inner_block, doc: "Custom separator content (overrides default '/')")

  @doc """
  Renders a breadcrumb separator.

  Defaults to `/`. Provide inner content to use a custom separator (e.g. an Icon).
  Always has `aria-hidden='true'`.
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc "Renders a `…` ellipsis to indicate collapsed path segments."
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
