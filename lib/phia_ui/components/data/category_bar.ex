defmodule PhiaUi.Components.CategoryBar do
  @moduledoc """
  Stacked category bar — normalizes values to 100% and renders colored segments.

  Inspired by Tremor `CategoryBar`, MUI LinearProgress stacked, PrimeReact MeterGroup.
  Use it to show composition breakdowns like traffic sources, budget allocation,
  or survey responses.

  Colors are atoms mapped to static Tailwind class strings to preserve JIT purging.

  ## Examples

      <.category_bar
        values={[40, 30, 20, 10]}
        colors={[:blue, :green, :orange, :red]}
        labels={["Direct", "Referral", "Organic", "Other"]}
        show_labels={true}
      />

      <.category_bar values={[60, 40]} colors={[:purple, :pink]} marker_value={55} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:values, :list,
    required: true,
    doc: "List of numbers — auto-normalized to 100%."
  )

  attr(:colors, :list,
    required: true,
    doc:
      "List of color atoms matching `:values`. Atoms: `:blue :green :red :orange :purple :pink :yellow :teal :indigo :cyan`."
  )

  attr(:labels, :list, default: [], doc: "Optional labels for each segment.")

  attr(:show_labels, :boolean,
    default: false,
    doc: "When `true`, renders labels below the bar."
  )

  attr(:marker_value, :any,
    default: nil,
    doc: "Optional numeric marker position (in the same scale as `:values` sum)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def category_bar(assigns) do
    total = assigns.values |> Enum.sum() |> max(1)

    segments =
      Enum.zip_with(assigns.values, assigns.colors, fn v, c ->
        %{pct: Float.round(v / total * 100, 1), color: c}
      end)

    marker_pct =
      if assigns.marker_value,
        do: Float.round(assigns.marker_value / total * 100, 1),
        else: nil

    assigns =
      assigns
      |> assign(:segments, segments)
      |> assign(:marker_pct, marker_pct)

    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <%!-- Bar --%>
      <div class="relative flex h-3 w-full overflow-hidden rounded-full">
        <div
          :for={segment <- @segments}
          class={segment_color(segment.color)}
          style={"width: #{segment.pct}%"}
        />
        <%!-- Marker --%>
        <div
          :if={@marker_pct}
          class="absolute w-0.5 h-full bg-foreground z-10"
          style={"left: #{@marker_pct}%"}
          aria-hidden="true"
        />
      </div>

      <%!-- Labels --%>
      <div :if={@show_labels && @labels != []} class="mt-2 flex gap-4 flex-wrap">
        <div
          :for={{label, segment} <- Enum.zip(@labels, @segments)}
          class="flex items-center gap-1.5 text-xs text-muted-foreground"
        >
          <span class={cn(["inline-block h-2.5 w-2.5 rounded-sm", segment_color(segment.color)])} />
          <span>{label}</span>
          <span class="text-foreground font-medium">{segment.pct}%</span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — atom → full static class (JIT-safe)
  # ---------------------------------------------------------------------------

  defp segment_color(:blue), do: "bg-blue-500"
  defp segment_color(:green), do: "bg-green-500"
  defp segment_color(:red), do: "bg-red-500"
  defp segment_color(:orange), do: "bg-orange-500"
  defp segment_color(:purple), do: "bg-purple-500"
  defp segment_color(:pink), do: "bg-pink-500"
  defp segment_color(:yellow), do: "bg-yellow-500"
  defp segment_color(:teal), do: "bg-teal-500"
  defp segment_color(:indigo), do: "bg-indigo-500"
  defp segment_color(:cyan), do: "bg-cyan-500"
  defp segment_color(_), do: "bg-gray-400"
end
