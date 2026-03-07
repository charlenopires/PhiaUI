defmodule PhiaUi.Components.NpsWidget do
  @moduledoc """
  Net Promoter Score widget — SVG half-circle arc gauge + breakdown bars.

  Shows an NPS score (0-100) as a semi-circular gauge, with the breakdown of
  promoters, passives, and detractors displayed below. Zero JavaScript —
  arc math is computed server-side using `stroke-dasharray`.

  ## Examples

      <.nps_widget
        score={62}
        promoters={450}
        passives={120}
        detractors={80}
        total_responses={650}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # SVG geometry — same as gauge_chart.ex
  @r 45
  @cx 60
  @cy 60
  @half_circ 141.37

  attr(:score, :integer, required: true, doc: "NPS score (0-100).")
  attr(:promoters, :integer, required: true, doc: "Number of promoters (score 9-10).")
  attr(:passives, :integer, required: true, doc: "Number of passives (score 7-8).")
  attr(:detractors, :integer, required: true, doc: "Number of detractors (score 0-6).")

  attr(:total_responses, :integer,
    required: true,
    doc: "Total survey responses (used for percentage bars)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def nps_widget(assigns) do
    arc_d = "M #{@cx - @r},#{@cy} A #{@r},#{@r} 0 0,1 #{@cx + @r},#{@cy}"
    filled_dash = Float.round(@half_circ * assigns.score / 100, 2)
    total = max(assigns.total_responses, 1)

    assigns =
      assigns
      |> assign(:arc_d, arc_d)
      |> assign(:filled_dash, filled_dash)
      |> assign(:half_circ, @half_circ)
      |> assign(:total, total)

    ~H"""
    <div class={cn(["w-full max-w-xs mx-auto", @class])} {@rest}>
      <%!-- Gauge arc --%>
      <div class="flex justify-center">
        <div class="h-36 w-64">
          <svg viewBox="0 0 120 70" aria-hidden="true" class="w-full h-full overflow-visible">
            <%!-- Track --%>
            <path
              d={@arc_d}
              fill="none"
              stroke="currentColor"
              stroke-width="10"
              stroke-linecap="round"
              class="text-muted-foreground opacity-20"
            />
            <%!-- Score arc --%>
            <path
              d={@arc_d}
              fill="none"
              stroke="currentColor"
              stroke-width="10"
              stroke-linecap="round"
              stroke-dasharray={"#{@filled_dash} #{@half_circ}"}
              stroke-dashoffset="0"
              class={score_color(@score)}
            />
            <%!-- Score label --%>
            <text
              x="60"
              y="46"
              text-anchor="middle"
              dominant-baseline="middle"
              font-size="22"
              font-weight="bold"
              class="fill-foreground"
            >
              {@score}
            </text>
            <text
              x="60"
              y="62"
              text-anchor="middle"
              dominant-baseline="middle"
              font-size="7"
              class="fill-muted-foreground"
            >
              NPS Score
            </text>
          </svg>
        </div>
      </div>

      <%!-- Breakdown --%>
      <div class="mt-4 space-y-2">
        <.breakdown_row
          label="Promoters"
          count={@promoters}
          total={@total}
          bar_class="bg-green-500"
          label_class="text-green-600 dark:text-green-400"
        />
        <.breakdown_row
          label="Passives"
          count={@passives}
          total={@total}
          bar_class="bg-gray-400"
          label_class="text-muted-foreground"
        />
        <.breakdown_row
          label="Detractors"
          count={@detractors}
          total={@total}
          bar_class="bg-red-500"
          label_class="text-red-600 dark:text-red-400"
        />
      </div>

      <%!-- Total --%>
      <p class="mt-3 text-center text-xs text-muted-foreground">
        {@total_responses} total responses
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private sub-component
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true)
  attr(:count, :integer, required: true)
  attr(:total, :integer, required: true)
  attr(:bar_class, :string, required: true)
  attr(:label_class, :string, required: true)

  defp breakdown_row(assigns) do
    pct = Float.round(assigns.count / assigns.total * 100, 1)
    assigns = assign(assigns, :pct, pct)

    ~H"""
    <div class="flex items-center gap-2 text-xs">
      <span class={cn(["w-20 font-medium", @label_class])}>{@label}</span>
      <div class="relative flex-1 h-2 rounded-full bg-muted overflow-hidden">
        <div class={cn([@bar_class, "absolute inset-y-0 left-0 rounded-full"])} style={"width: #{@pct}%"} />
      </div>
      <span class="w-10 text-right text-muted-foreground">{@count}</span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp score_color(s) when s >= 75, do: "text-green-500"
  defp score_color(s) when s >= 50, do: "text-amber-500"
  defp score_color(_s), do: "text-red-500"
end
