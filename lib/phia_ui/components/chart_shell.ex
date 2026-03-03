defmodule PhiaUi.Components.ChartShell do
  @moduledoc """
  Container shell for charts and data visualisations in dashboards.

  Wraps any third-party chart library output in a semantic PhiaUI Card,
  adding a title, optional description, time-period label, and an actions
  slot for download/filter buttons — all without coupling to a specific
  charting library.

  ## Example

      <.chart_shell
        title="Revenue Over Time"
        description="Monthly recurring revenue"
        period="Last 12 months"
        min_height="350px"
      >
        <:actions>
          <.button variant={:outline} size={:sm}>Export CSV</.button>
        </:actions>
        <%!-- Drop any chart library output here --%>
        <canvas id="revenue-chart" phx-hook="RevenueChart" />
      </.chart_shell>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Chart heading — always visible")

  attr(:description, :string,
    default: nil,
    doc: "Supporting text below the title (omitted when nil)"
  )

  attr(:period, :string,
    default: nil,
    doc: "Time-range label displayed in the header (e.g. \"Last 30 days\")"
  )

  attr(:min_height, :string,
    default: "300px",
    doc: "Minimum height of the chart content area as a CSS value (e.g. \"300px\", \"20rem\")"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer card")

  attr(:rest, :global, doc: "HTML attributes forwarded to the card element")

  slot(:actions, doc: "Optional header actions (download, filter buttons, etc.)")

  slot(:inner_block, required: true, doc: "Chart content — any library output")

  @doc "Renders a titled card shell around chart or visualisation content."
  def chart_shell(assigns) do
    ~H"""
    <.card class={cn([@class])} {@rest}>
      <.card_header>
        <div class="flex items-start justify-between gap-2">
          <div class="min-w-0">
            <.card_title><%= @title %></.card_title>
            <.card_description :if={@description}>
              <%= @description %>
            </.card_description>
          </div>
          <div class="flex shrink-0 items-center gap-2">
            <span :if={@period} class="text-sm text-muted-foreground whitespace-nowrap">
              <%= @period %>
            </span>
            <%= if @actions != [] do %>
              <div class="flex items-center gap-1">
                <%= render_slot(@actions) %>
              </div>
            <% end %>
          </div>
        </div>
      </.card_header>
      <.card_content>
        <div style={"min-height: #{@min_height}"}>
          <%= render_slot(@inner_block) %>
        </div>
      </.card_content>
    </.card>
    """
  end
end
