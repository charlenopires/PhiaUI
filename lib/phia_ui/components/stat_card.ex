defmodule PhiaUi.Components.StatCard do
  @moduledoc """
  Dashboard KPI widget composed from Card and Badge primitives.

  Displays a key metric with title, value, optional trend indicator,
  description, and customisable icon/footer slots. Designed for enterprise
  analytical dashboards — financial terminals, BI panels, KPI monitors.

  ## Example

      <.stat_card
        title="Total Revenue"
        value="$12,345"
        trend={:up}
        trend_value="+12%"
        description="vs. last month"
      />

      <.stat_card title="Active Users" value="1,024" trend={:down} trend_value="-3%">
        <:icon><.icon name="hero-users" /></:icon>
        <:footer>Updated 2 min ago</:footer>
      </.stat_card>

  ## Trend variants

  | `:trend` | Badge variant | Icon |
  |----------|--------------|------|
  | `:up`    | `:default`   | ↑    |
  | `:down`  | `:destructive` | ↓  |
  | `:neutral` | `:secondary` | → |
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Badge
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Metric label displayed above the value"

  attr :value, :string, required: true, doc: "Main metric value (e.g., \"$12,345\" or \"1,024\")"

  attr :trend, :atom,
    values: [:up, :down, :neutral],
    default: :neutral,
    doc: "Trend direction — controls badge colour and icon"

  attr :trend_value, :string,
    default: nil,
    doc: "Trend text displayed in the badge (e.g., \"+12%\"). Omit to hide the badge."

  attr :description, :string,
    default: nil,
    doc: "Secondary text below the value (e.g., \"vs. last month\")"

  attr :class, :string, default: nil, doc: "Additional CSS classes for the outer card"

  attr :rest, :global, doc: "HTML attributes forwarded to the outer card element"

  slot :icon, doc: "Optional icon displayed in the card header (top-right)"
  slot :footer, doc: "Optional footer content (e.g., timestamps, sparklines)"

  def stat_card(assigns) do
    ~H"""
    <.card class={cn([@class])} {@rest}>
      <.card_header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <.card_title class="text-sm font-medium tracking-tight">
          <%= @title %>
        </.card_title>
        <div class="flex items-center gap-2">
          <span :if={@icon != []} class="text-muted-foreground">
            <%= render_slot(@icon) %>
          </span>
          <.badge :if={@trend_value} variant={trend_badge_variant(@trend)}>
            <%= trend_icon(@trend) %> <%= @trend_value %>
          </.badge>
        </div>
      </.card_header>
      <.card_content>
        <div class="text-2xl font-bold"><%= @value %></div>
        <p :if={@description} class="mt-1 text-xs text-muted-foreground">
          <%= @description %>
        </p>
      </.card_content>
      <.card_footer :if={@footer != []} class="pt-0 text-xs text-muted-foreground">
        <%= render_slot(@footer) %>
      </.card_footer>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp trend_badge_variant(:up), do: :default
  defp trend_badge_variant(:down), do: :destructive
  defp trend_badge_variant(:neutral), do: :secondary

  defp trend_icon(:up), do: "↑"
  defp trend_icon(:down), do: "↓"
  defp trend_icon(:neutral), do: "→"
end
