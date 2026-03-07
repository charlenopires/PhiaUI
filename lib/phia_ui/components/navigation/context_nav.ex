defmodule PhiaUi.Components.ContextNav do
  @moduledoc """
  Secondary in-page horizontal navigation strip (sub-navigation).

  Two components:

  - `context_nav/1` — horizontal nav bar with three visual variants
  - `context_nav_item/1` — individual nav item with active/inactive states
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # context_nav/1
  # ---------------------------------------------------------------------------

  attr(:sticky, :boolean, default: false, doc: "Pins the nav to the top of the viewport")
  attr(:variant, :atom, values: [:default, :minimal, :bordered], default: :default)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a secondary in-page horizontal navigation strip."
  def context_nav(assigns) do
    ~H"""
    <nav
      class={cn([
        context_nav_class(@variant),
        @sticky && "sticky top-0 z-10 bg-background",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # context_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: "#")
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :atom, values: [:default, :minimal, :bordered], default: :default)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:badge, doc: "Optional badge count slot")

  @doc "Renders an individual item inside a context_nav."
  def context_nav_item(assigns) do
    ~H"""
    <a
      href={if @disabled, do: nil, else: @href}
      class={cn([
        context_item_class(@variant, @active),
        "inline-flex items-center gap-1.5 text-sm font-medium transition-colors",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      aria-current={if @active, do: "page"}
      {@rest}
    >
      {render_slot(@inner_block)}
      <%= if @badge != [] do %>
        <span class="ml-1 rounded-full bg-muted px-1.5 py-0.5 text-xs text-muted-foreground">
          {render_slot(@badge)}
        </span>
      <% end %>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp context_nav_class(:default), do: "flex items-center gap-6 border-b border-border"
  defp context_nav_class(:minimal), do: "flex items-center gap-4"
  defp context_nav_class(:bordered), do: "flex items-center gap-4 rounded-lg border border-border p-1 bg-muted/50"

  defp context_item_class(:default, true),
    do: "border-b-2 border-primary text-foreground -mb-px pb-3 pt-1"

  defp context_item_class(:default, false),
    do: "border-b-2 border-transparent text-muted-foreground hover:text-foreground -mb-px pb-3 pt-1"

  defp context_item_class(:minimal, true), do: "text-foreground font-semibold"
  defp context_item_class(:minimal, false), do: "text-muted-foreground hover:text-foreground"

  defp context_item_class(:bordered, true),
    do: "rounded-md bg-background shadow-sm px-3 py-1.5 text-foreground"

  defp context_item_class(:bordered, false),
    do: "rounded-md text-muted-foreground hover:text-foreground px-3 py-1.5"
end
