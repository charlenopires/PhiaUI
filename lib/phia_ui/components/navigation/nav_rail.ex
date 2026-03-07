defmodule PhiaUi.Components.NavRail do
  @moduledoc """
  Material Design 3-style icon-strip sidebar navigation rail.

  Two components:

  - `nav_rail/1` — the rail container (fixed or inline, collapsible)
  - `nav_rail_item/1` — individual item with icon, label tooltip, and optional badge
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # nav_rail/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: "nav-rail")
  attr(:expanded, :boolean, default: false, doc: "When true, shows labels inline (w-36 vs w-14)")
  attr(:position, :atom, values: [:left, :right, :inline], default: :left)
  attr(:variant, :atom, values: [:default, :surface, :bordered], default: :default)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:header, doc: "Logo/brand area at top")
  slot(:inner_block, required: true, doc: "nav_rail_item children")
  slot(:footer, doc: "Settings/user area at bottom")

  @doc "Renders a Material Design 3-style navigation rail."
  def nav_rail(assigns) do
    ~H"""
    <nav
      id={@id}
      class={cn([
        nav_rail_position_class(@position),
        nav_rail_variant_class(@variant),
        "flex flex-col items-center py-4 transition-all duration-200",
        if(@expanded, do: "w-36", else: "w-14"),
        @class
      ])}
      {@rest}
    >
      <%= if @header != [] do %>
        <div class="mb-4 flex w-full items-center justify-center px-2">
          {render_slot(@header)}
        </div>
      <% end %>
      <div class="flex flex-1 flex-col items-center gap-1 w-full px-2">
        {render_slot(@inner_block)}
      </div>
      <%= if @footer != [] do %>
        <div class="mt-4 flex w-full items-center justify-center px-2">
          {render_slot(@footer)}
        </div>
      <% end %>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # nav_rail_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil, doc: "phx-click event when no href")
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:label, :string, required: true, doc: "Tooltip text (collapsed) or inline label (expanded)")
  attr(:badge, :any, default: nil, doc: "Badge count — integer or string")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, required: true, doc: "<.icon> element")
  slot(:indicator, doc: "Optional custom active indicator")

  @doc "Renders an individual navigation rail item."
  def nav_rail_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={if @disabled, do: nil, else: @href}
        class={cn([nav_rail_item_class(@active), @disabled && "pointer-events-none opacity-50", @class])}
        aria-label={@label}
        aria-current={if @active, do: "page"}
        title={@label}
        {@rest}
      >
        {render_rail_item_content(assigns)}
      </a>
    <% else %>
      <button
        type="button"
        phx-click={@on_click}
        disabled={@disabled}
        class={cn([nav_rail_item_class(@active), @disabled && "pointer-events-none opacity-50", @class])}
        aria-label={@label}
        aria-pressed={to_string(@active)}
        title={@label}
        {@rest}
      >
        {render_rail_item_content(assigns)}
      </button>
    <% end %>
    """
  end

  defp render_rail_item_content(assigns) do
    ~H"""
    <div class="relative flex flex-col items-center gap-1">
      <%!-- Icon with optional badge --%>
      <div class="relative">
        <div class={cn([
          "flex h-10 w-10 items-center justify-center rounded-full transition-colors",
          @active && "bg-primary/10 text-primary",
          !@active && "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
        ])}>
          {render_slot(@icon)}
        </div>
        <%!-- Badge --%>
        <%= if @badge do %>
          <span class="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-primary px-1 text-[10px] font-medium text-primary-foreground">
            {@badge}
          </span>
        <% end %>
      </div>
      <%!-- Active indicator dot --%>
      <%= if @indicator != [] do %>
        {render_slot(@indicator)}
      <% else %>
        <%= if @active do %>
          <div class="h-1 w-1 rounded-full bg-primary"></div>
        <% end %>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp nav_rail_position_class(:left), do: "fixed left-0 top-0 h-full z-40"
  defp nav_rail_position_class(:right), do: "fixed right-0 top-0 h-full z-40"
  defp nav_rail_position_class(:inline), do: "relative h-full"

  defp nav_rail_variant_class(:default), do: "border-r border-border bg-background"
  defp nav_rail_variant_class(:surface), do: "border-r border-border bg-muted/50"
  defp nav_rail_variant_class(:bordered), do: "border-r-2 border-primary/30 bg-background"

  defp nav_rail_item_class(active) do
    cn([
      "group flex w-full flex-col items-center gap-1 rounded-lg p-1 transition-all",
      active && "text-primary",
      !active && "text-muted-foreground hover:text-foreground"
    ])
  end
end
