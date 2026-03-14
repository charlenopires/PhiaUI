defmodule PhiaUi.Components.FunnelChart do
  @moduledoc """
  Funnel chart — visualizes stage-by-stage drop-off in a conversion pipeline.

  Inspired by Tremor `FunnelChart`, Ant Design funnel, PrimeReact charts.
  Uses centered divs (no SVG trapezoids) — simpler and maintainable.

  Each stage is a horizontally centered bar whose width is proportional to
  its value relative to the first stage. Drop-off percentages are computed
  server-side and shown between stages when `show_dropoff: true`.

  ## Examples

      <.funnel_chart stages={[
        %{label: "Visitors",    value: 10_000},
        %{label: "Leads",       value: 4_200},
        %{label: "Prospects",   value: 1_800},
        %{label: "Conversions", value: 320}
      ]} />

      <.funnel_chart stages={@pipeline} color={:purple} show_dropoff={false} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:stages, :list,
    required: true,
    doc: "List of maps with `:label` (string) and `:value` (number)."
  )

  attr(:color, :atom,
    default: :blue,
    values: [:blue, :green, :purple, :orange, :rose],
    doc: "Color palette for the funnel bars."
  )

  attr(:show_dropoff, :boolean, default: true, doc: "When `true`, shows drop-off % annotations.")

  attr(:id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided).")
  attr(:title, :string, default: nil, doc: "Chart title rendered above the visualization.")
  attr(:description, :string, default: nil, doc: "Chart description for context (rendered below title).")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def funnel_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    max_val = assigns.stages |> Enum.map(& &1.value) |> Enum.max(fn -> 1 end)
    first_val = List.first(assigns.stages, %{value: 1}).value |> max(1)

    stages_meta =
      assigns.stages
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        width_pct = Float.round(s.value / max_val * 100, 1)

        dropoff_pct =
          if i == 0,
            do: nil,
            else: Float.round((1 - s.value / first_val) * 100, 1)

        Map.merge(s, %{width_pct: width_pct, dropoff_pct: dropoff_pct, index: i})
      end)

    assigns =
      assigns
      |> assign(:stages_meta, stages_meta)
      |> assign(:chart_id, chart_id)

    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <div :if={@title} class="mb-2">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
        <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      </div>
      <%= for stage <- @stages_meta do %>
        <%!-- Drop-off annotation between stages --%>
        <div
          :if={@show_dropoff && stage.dropoff_pct}
          class="flex justify-center items-center py-1 text-xs text-muted-foreground gap-1"
        >
          <span>↓</span>
          <span>-{stage.dropoff_pct}% drop-off</span>
        </div>
        <%!-- Stage bar --%>
        <div class="flex flex-col items-center">
          <div
            class={cn(["h-10 rounded-md flex items-center justify-center", funnel_bg(@color)])}
            style={"width: #{stage.width_pct}%"}
          >
            <span class={cn(["text-sm font-medium truncate px-2", funnel_text(@color)])}>
              {stage.label}
            </span>
          </div>
          <span class="mt-0.5 text-xs text-muted-foreground">
            {stage.value}
          </span>
        </div>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — static Tailwind classes (JIT-safe)
  # ---------------------------------------------------------------------------

  defp funnel_bg(:blue), do: "bg-blue-500"
  defp funnel_bg(:green), do: "bg-green-500"
  defp funnel_bg(:purple), do: "bg-purple-500"
  defp funnel_bg(:orange), do: "bg-orange-500"
  defp funnel_bg(:rose), do: "bg-rose-500"

  defp funnel_text(:blue), do: "text-white"
  defp funnel_text(:green), do: "text-white"
  defp funnel_text(:purple), do: "text-white"
  defp funnel_text(:orange), do: "text-white"
  defp funnel_text(:rose), do: "text-white"
end
