defmodule PhiaUi.Components.Data.ChartSync do
  @moduledoc """
  Multi-chart synchronization wrapper.

  Inspired by Recharts' `syncId` — coordinates crosshair, brush, and tooltip
  state across multiple charts. Charts within the same `sync_id` group share
  pointer position and zoom state.

  ## Examples

      <.chart_sync id="sync-1" sync_id="group-a">
        <.xy_chart ... />
      </.chart_sync>

      <.chart_sync id="sync-2" sync_id="group-a">
        <.xy_chart ... />
      </.chart_sync>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique element ID (required for phx-hook)."
  attr :sync_id, :string, required: true, doc: "Group ID — charts with same sync_id share state."

  attr :sync_mode, :atom,
    default: :crosshair,
    values: [:crosshair, :brush, :both],
    doc: "What to synchronize: crosshair position, brush range, or both."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def chart_sync(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaChartSync"
      data-sync-id={@sync_id}
      data-sync-mode={@sync_mode}
      class={cn(["relative", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
