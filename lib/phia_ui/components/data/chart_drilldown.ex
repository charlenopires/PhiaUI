defmodule PhiaUi.Components.Data.ChartDrilldown do
  @moduledoc """
  Drilldown component for click-to-explore-data pattern.

  Maps to Highcharts' drilldown API. Wraps chart content with
  drill state management and breadcrumb trail navigation.
  No JS hook needed — LiveView handles state transitions.

  ## Examples

      <.chart_drilldown
        levels={["Region", "Country", "City"]}
        current_level={0}
        breadcrumb_items={["All Regions"]}
        on_drill="drill_down"
        on_up="drill_up"
      >
        <.bar_chart data={@chart_data} />
      </.chart_drilldown>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Chart Drilldown
  # ---------------------------------------------------------------------------

  attr :levels, :list, default: [], doc: "List of drill level labels."
  attr :current_level, :integer, default: 0, doc: "Current drill depth (0 = root)."

  attr :breadcrumb_items, :list,
    default: [],
    doc: "List of breadcrumb label strings from root to current."

  attr :on_drill, :string, default: nil, doc: "Event name for drill-down action."
  attr :on_up, :string, default: nil, doc: "Event name for drill-up action."
  attr :animate, :boolean, default: true, doc: "Enable drill transition animation."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def chart_drilldown(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} {@rest}>
      <%!-- Breadcrumb trail --%>
      <.chart_drilldown_breadcrumb
        :if={@current_level > 0}
        items={@breadcrumb_items}
        on_up={@on_up}
      />

      <%!-- Chart content with drill animation --%>
      <div class={
        cn([
          if(@animate and @current_level > 0, do: "phia-drilldown-enter", else: "")
        ])
      }>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Chart Drilldown Breadcrumb
  # ---------------------------------------------------------------------------

  @doc """
  Breadcrumb trail for drill navigation.
  """
  attr :items, :list, required: true, doc: "Breadcrumb label list."
  attr :on_up, :string, default: nil, doc: "Event name for drill-up."
  attr :class, :string, default: nil

  def chart_drilldown_breadcrumb(assigns) do
    items_with_index =
      assigns.items
      |> Enum.with_index()

    assigns = assign(assigns, :items_with_index, items_with_index)

    ~H"""
    <nav
      class={cn(["flex items-center gap-1 text-xs text-muted-foreground mb-2", @class])}
      aria-label="Chart drill navigation"
    >
      <button
        :for={{label, idx} <- @items_with_index}
        class={cn([
          "hover:text-foreground transition-colors",
          if(idx == length(@items_with_index) - 1,
            do: "text-foreground font-medium",
            else: "hover:underline"
          )
        ])}
        phx-click={if(idx < length(@items_with_index) - 1 and @on_up, do: @on_up, else: nil)}
        phx-value-level={idx}
        disabled={idx == length(@items_with_index) - 1}
      >
        {label}
      </button>
      <span
        :if={idx < length(@items_with_index) - 1}
        :for={{_label, idx} <- @items_with_index}
        class="text-muted-foreground/50"
      >/</span>
    </nav>
    """
  end
end
