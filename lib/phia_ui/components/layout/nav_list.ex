defmodule PhiaUi.Components.Layout.NavList do
  @moduledoc """
  Vertical navigation list with groups, icons, nested subnav, and active state.

  ## Sub-components

  - `nav_list/1` — root `<nav>` wrapper with `<ul>`
  - `nav_list_item/1` — individual link with optional icon, trailing badge, active/disabled state
  - `nav_list_group/1` — labeled group of items
  - `nav_list_divider/1` — thin horizontal separator between groups

  ## Examples

      <.nav_list aria_label="Main navigation">
        <.nav_list_group title="General">
          <.nav_list_item href="/dashboard" active>
            <:icon><.icon name="hero-home" /></:icon>
            Dashboard
          </.nav_list_item>
          <.nav_list_item href="/projects">
            <:icon><.icon name="hero-folder" /></:icon>
            Projects
            <:trailing><.badge>12</.badge></:trailing>
          </.nav_list_item>
        </.nav_list_group>

        <.nav_list_divider />

        <.nav_list_group title="Settings">
          <.nav_list_item href="/settings">
            <:icon><.icon name="hero-cog-6-tooth" /></:icon>
            Settings
          </.nav_list_item>
          <.nav_list_item disabled>
            <:icon><.icon name="hero-bell" /></:icon>
            Notifications
          </.nav_list_item>
        </.nav_list_group>
      </.nav_list>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # nav_list/1
  # ---------------------------------------------------------------------------

  attr(:aria_label, :string, default: "Navigation", doc: "Accessible label for the `<nav>`.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<nav>` element.")
  slot(:inner_block, required: true, doc: "Nav list content (items, groups, dividers).")

  @doc "Renders a vertical navigation list."
  def nav_list(assigns) do
    ~H"""
    <nav aria-label={@aria_label} class={cn([@class])} {@rest}>
      <ul class="space-y-1">
        <%= render_slot(@inner_block) %>
      </ul>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # nav_list_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: nil, doc: "Link URL. If nil, renders a `<button>` instead.")
  attr(:active, :boolean, default: false, doc: "Highlights as the current page.")
  attr(:disabled, :boolean, default: false, doc: "Dims and prevents interaction.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the link/button element.")

  slot(:icon, doc: "Optional leading icon.")
  slot(:trailing, doc: "Optional trailing element (badge, count, chevron).")
  slot(:inner_block, required: true, doc: "Item label text.")

  @doc "Renders a single navigation list item."
  def nav_list_item(%{href: nil} = assigns) do
    ~H"""
    <li>
      <button
        class={cn([item_base_class(), active_class(@active), disabled_class(@disabled), @class])}
        disabled={@disabled}
        {@rest}
      >
        <%= if @icon != [] do %>
          <span class="shrink-0 text-muted-foreground">
            <%= render_slot(@icon) %>
          </span>
        <% end %>
        <span class="flex-1 truncate"><%= render_slot(@inner_block) %></span>
        <%= if @trailing != [] do %>
          <span class="shrink-0 ml-auto"><%= render_slot(@trailing) %></span>
        <% end %>
      </button>
    </li>
    """
  end

  def nav_list_item(assigns) do
    ~H"""
    <li>
      <a
        href={@href}
        class={cn([item_base_class(), active_class(@active), disabled_class(@disabled), @class])}
        aria-current={@active && "page"}
        {@rest}
      >
        <%= if @icon != [] do %>
          <span class="shrink-0 text-muted-foreground">
            <%= render_slot(@icon) %>
          </span>
        <% end %>
        <span class="flex-1 truncate"><%= render_slot(@inner_block) %></span>
        <%= if @trailing != [] do %>
          <span class="shrink-0 ml-auto"><%= render_slot(@trailing) %></span>
        <% end %>
      </a>
    </li>
    """
  end

  defp item_base_class do
    "w-full flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium " <>
      "text-foreground transition-colors hover:bg-accent hover:text-accent-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end

  defp active_class(true), do: "bg-accent text-accent-foreground"
  defp active_class(false), do: nil

  defp disabled_class(true), do: "opacity-50 pointer-events-none"
  defp disabled_class(false), do: nil

  # ---------------------------------------------------------------------------
  # nav_list_group/1
  # ---------------------------------------------------------------------------

  attr(:title, :string, required: true, doc: "Group heading text.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper element.")
  slot(:inner_block, required: true, doc: "Group items.")

  @doc "Renders a labeled group of navigation items."
  def nav_list_group(assigns) do
    ~H"""
    <li class={cn([@class])} {@rest}>
      <p class="mb-1 px-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
        {@title}
      </p>
      <ul class="space-y-1">
        <%= render_slot(@inner_block) %>
      </ul>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # nav_list_divider/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")

  @doc "Renders a thin horizontal separator between nav groups."
  def nav_list_divider(assigns) do
    ~H"""
    <li class={cn(["my-2 h-px bg-border", @class])} role="none" aria-hidden="true" {@rest}></li>
    """
  end
end
