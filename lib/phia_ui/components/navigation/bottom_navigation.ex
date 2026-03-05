defmodule PhiaUi.Components.BottomNavigation do
  @moduledoc """
  BottomNavigation component — a fixed bottom tab bar for mobile/PWA apps.

  Equivalent to the iOS tab bar or Android bottom navigation bar. Renders
  a fixed `<nav>` at the bottom of the viewport with icon + label items.
  Zero JavaScript — all state is managed server-side via LiveView.

  ## Examples

      <%!-- With items attr --%>
      <.bottom_navigation
        active={@current_tab}
        items={[
          %{label: "Home",     icon: "home",    href: "/",        value: "home"},
          %{label: "Search",   icon: "search",  href: "/search",  value: "search"},
          %{label: "Messages", icon: "message", href: "/messages", value: "messages", badge_count: @unread},
          %{label: "Profile",  icon: "user",    href: "/profile", value: "profile"}
        ]}
      />

      <%!-- With phx-click (SPA navigation) --%>
      <.bottom_navigation
        active={@tab}
        on_click="switch_tab"
        items={[
          %{label: "Feed",   icon: "home",   value: "feed"},
          %{label: "Search", icon: "search", value: "search"}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:items, :list,
    default: [],
    doc: """
    List of navigation item maps. Each map supports:
    - `:label` (string, required) — visible text label
    - `:icon` (string) — icon name (rendered as text; integrate your icon system)
    - `:href` (string) — link target; renders `<a>` when set
    - `:value` (string) — identifier for active comparison and phx-value-value
    - `:badge_count` (integer) — notification badge; omit or 0 to hide
    - `:disabled` (boolean) — disables the item
    """
  )

  attr(:active, :string,
    default: nil,
    doc: "Value of the currently active item. Matching item receives active styling."
  )

  attr(:on_click, :string,
    default: nil,
    doc: "LiveView event dispatched via phx-click. The item value is sent as phx-value-value."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the <nav> element")

  slot(:item,
    doc: "Alternative slot-based API for navigation items",
    validate_attrs: false
  )

  @doc """
  Renders a fixed bottom navigation bar.

  Supports both `:items` list and `<:item>` slot APIs. When both are provided,
  `:items` takes precedence.

  ## Examples

      <.bottom_navigation
        active={@tab}
        on_click="set_tab"
        items={[
          %{label: "Home", icon: "home", value: "home"},
          %{label: "Profile", icon: "user", value: "profile"}
        ]}
      />
  """
  def bottom_navigation(assigns) do
    ~H"""
    <nav
      class={cn([
        "fixed bottom-0 left-0 right-0 z-50",
        "w-full flex items-stretch",
        "border-t border-border bg-background",
        "safe-area-inset-bottom",
        @class
      ])}
      {@rest}
    >
      <%= if @items != [] do %>
        <%= for item <- @items do %>
          <% item_value = Map.get(item, :value)
             item_label = Map.get(item, :label, "")
             item_href  = Map.get(item, :href)
             item_badge = Map.get(item, :badge_count, 0)
             item_disabled = Map.get(item, :disabled, false)
             is_active = item_value == @active %>
          <%= if item_href && is_nil(@on_click) do %>
            <a
              href={item_href}
              class={cn([
                "flex-1 flex flex-col items-center justify-center gap-1 py-2 px-1",
                "text-xs font-medium transition-colors min-w-0",
                is_active && "text-primary",
                !is_active && "text-muted-foreground hover:text-foreground",
                item_disabled && "pointer-events-none opacity-50"
              ])}
              aria-current={is_active && "page"}
            >
              <.nav_item_content item={item} badge={item_badge} label={item_label} />
            </a>
          <% else %>
            <button
              type="button"
              phx-click={@on_click}
              phx-value-value={item_value}
              disabled={item_disabled}
              class={cn([
                "flex-1 flex flex-col items-center justify-center gap-1 py-2 px-1",
                "text-xs font-medium transition-colors min-w-0",
                is_active && "text-primary",
                !is_active && "text-muted-foreground hover:text-foreground",
                item_disabled && "pointer-events-none opacity-50"
              ])}
              aria-current={is_active && "page"}
            >
              <.nav_item_content item={item} badge={item_badge} label={item_label} />
            </button>
          <% end %>
        <% end %>
      <% else %>
        <%= for item <- @item do %>
          <a
            href={Map.get(item, :href, "#")}
            class={cn([
              "flex-1 flex flex-col items-center justify-center gap-1 py-2 px-1",
              "text-xs font-medium transition-colors min-w-0",
              "text-muted-foreground hover:text-foreground"
            ])}
          >
            <span class="text-sm">{Map.get(item, :label, "")}</span>
          </a>
        <% end %>
      <% end %>
    </nav>
    """
  end

  # Internal component for item content (icon + badge + label)
  attr(:item, :map, required: true)
  attr(:badge, :integer, required: true)
  attr(:label, :string, required: true)

  defp nav_item_content(assigns) do
    ~H"""
    <span class="relative inline-flex">
      <span class="text-base leading-none" aria-hidden="true">
        {Map.get(@item, :icon, "")}
      </span>
      <%= if @badge > 0 do %>
        <span class={cn([
          "absolute -top-1 -right-1",
          "inline-flex items-center justify-center",
          "h-4 min-w-[1rem] rounded-full px-1",
          "bg-destructive text-destructive-foreground text-[10px] font-bold leading-none"
        ])}>
          {@badge}
        </span>
      <% end %>
    </span>
    <span class="truncate">{@label}</span>
    """
  end
end
