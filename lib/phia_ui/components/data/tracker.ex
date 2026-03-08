defmodule PhiaUi.Components.Data.Tracker do
  @moduledoc """
  Status tracker visualization — a row of colored blocks representing status over time.

  Inspired by Tremor's Tracker component. Each block represents a unit of time
  or an event, colored according to its status.

  ## Examples

      <.tracker data={[
        %{color: "oklch(0.70 0.18 145)", tooltip: "Operational"},
        %{color: "oklch(0.65 0.22 30)", tooltip: "Degraded"},
        %{color: "oklch(0.60 0.20 240)", tooltip: "Operational"}
      ]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Tracker
  # ---------------------------------------------------------------------------

  @doc """
  Renders a row of colored status blocks.

  ## Attrs
  - `data` — list of `%{color: string}` maps, optionally with `:tooltip` and `:key`
  """
  attr :data, :list, required: true, doc: "List of `%{color, tooltip}` maps."
  attr :class, :string, default: nil
  attr :rest, :global

  def tracker(assigns) do
    ~H"""
    <div
      class={cn(["h-10 flex items-center gap-0.5", @class])}
      role="list"
      aria-label="Status tracker"
      {@rest}
    >
      <.tracker_block
        :for={{item, idx} <- Enum.with_index(@data)}
        color={Map.get(item, :color, "oklch(0.55 0.00 0)")}
        tooltip={Map.get(item, :tooltip)}
        key={Map.get(item, :key, idx)}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Tracker Block
  # ---------------------------------------------------------------------------

  attr :color, :string, required: true
  attr :tooltip, :string, default: nil
  attr :key, :any, default: nil

  defp tracker_block(assigns) do
    ~H"""
    <div
      class={cn([
        "w-full h-full rounded-[1px]",
        "first:rounded-l-[4px] last:rounded-r-[4px]"
      ])}
      style={"background-color: #{@color}"}
      title={@tooltip}
      role="listitem"
    />
    """
  end
end
