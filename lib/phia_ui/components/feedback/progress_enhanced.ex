defmodule PhiaUi.Components.ProgressEnhanced do
  @moduledoc """
  Enhanced progress components extending the basic `Progress` component with
  labeled, multi-segment, quota, and step-based variants.

  Inspired by Mantine Progress with sections, Ant Design Progress variants,
  GitHub's storage quota bar, and Linear's sprint progress.

  Pure HEEx — no JavaScript required.

  ## Sub-components

  | Component              | Purpose                                                     |
  |------------------------|-------------------------------------------------------------|
  | `labeled_progress/1`   | Progress bar with title, value label, and percentage text   |
  | `segmented_progress/1` | Multi-color segments (storage breakdown, team allocation)    |
  | `quota_bar/1`          | Usage/limit bar with warning color zones (80% → amber, 95% → red) |
  | `step_progress_bar/1`  | Step-based progress shown as N equal segments               |

  ## Labeled progress (with title and percentage)

      <.labeled_progress label="Upload progress" value={72} />
      <.labeled_progress label="Tasks completed" value={18} max={24} show_count />

  ## Segmented (storage breakdown)

      <.segmented_progress
        segments={[
          %{label: "Documents", value: 30, color: "bg-primary"},
          %{label: "Images", value: 45, color: "bg-blue-500"},
          %{label: "Videos", value: 15, color: "bg-violet-500"}
        ]}
        max={100}
      />

  ## Quota bar (GitHub-style)

      <.quota_bar used={8_200} limit={10_000} unit="MB" label="Storage" />

  ## Step progress bar

      <.step_progress_bar current={3} total={5} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # labeled_progress/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Accessible label and visible title.")

  attr(:value, :integer,
    default: 0,
    doc: "Current progress value (between 0 and `:max`)."
  )

  attr(:max, :integer,
    default: 100,
    doc: "Maximum value. Default: `100`."
  )

  attr(:show_count, :boolean,
    default: false,
    doc: "When `true`, shows `value/max` instead of just percentage."
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Bar height."
  )

  attr(:variant, :atom,
    values: [:default, :success, :warning, :destructive],
    default: :default,
    doc: "Fill color variant."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a labeled progress bar with title and percentage display.

  ## Example

      <.labeled_progress label="Storage" value={42} />
      <.labeled_progress label="Tasks" value={18} max={24} show_count />
  """
  def labeled_progress(assigns) do
    pct = progress_pct(assigns.value, assigns.max)
    assigns = assign(assigns, :pct, pct)

    ~H"""
    <div class={cn(["w-full space-y-1.5", @class])} {@rest}>
      <div class="flex items-center justify-between gap-2">
        <span class="text-sm font-medium text-foreground">{@label}</span>
        <span class="text-sm text-muted-foreground tabular-nums">
          {if @show_count, do: "#{@value}/#{@max}", else: "#{@pct}%"}
        </span>
      </div>
      <div
        role="progressbar"
        aria-label={@label}
        aria-valuenow={@value}
        aria-valuemin="0"
        aria-valuemax={@max}
        class={cn(["relative w-full overflow-hidden rounded-full bg-secondary", bar_height_class(@size)])}
      >
        <div
          class={cn(["h-full rounded-full transition-all duration-500 ease-out", labeled_fill_class(@variant)])}
          style={"width: #{@pct}%"}
        ></div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # segmented_progress/1
  # ---------------------------------------------------------------------------

  attr(:segments, :list,
    required: true,
    doc: """
    List of segment maps. Each map must have:
    - `:label` (string) — accessible label for this segment
    - `:value` (integer) — segment value
    - `:color` (string) — Tailwind `bg-*` class for the segment color

    Example: `[%{label: \"Docs\", value: 30, color: \"bg-primary\"}]`
    """
  )

  attr(:max, :integer,
    default: 100,
    doc: "Total maximum value (sum of all segments should not exceed this)."
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Bar height."
  )

  attr(:show_legend, :boolean,
    default: true,
    doc: "When `true`, renders a color legend below the bar."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a multi-color segmented progress bar.

  Each segment occupies a proportional width based on its value relative to `:max`.
  Useful for storage breakdowns, budget allocation, team capacity visualizations.

  ## Example

      <.segmented_progress
        segments={[
          %{label: "Documents", value: 30, color: "bg-primary"},
          %{label: "Images", value: 45, color: "bg-blue-400"},
          %{label: "Videos", value: 15, color: "bg-violet-400"}
        ]}
        max={100}
      />
  """
  def segmented_progress(assigns) do
    assigns =
      assign(assigns, :processed_segments,
        Enum.map(assigns.segments, fn seg ->
          pct = progress_pct(seg.value, assigns.max)
          Map.put(seg, :pct, pct)
        end)
      )

    ~H"""
    <div class={cn(["w-full space-y-2", @class])} {@rest}>
      <%!-- Bar --%>
      <div
        class={cn(["flex w-full overflow-hidden rounded-full bg-secondary gap-px", bar_height_class(@size)])}
        role="meter"
        aria-label="Segmented usage"
      >
        <div
          :for={seg <- @processed_segments}
          class={cn(["h-full transition-all duration-500 ease-out", seg.color])}
          style={"width: #{seg.pct}%"}
          aria-label={"#{seg.label}: #{seg.value}"}
          role="presentation"
        ></div>
      </div>

      <%!-- Legend --%>
      <div :if={@show_legend} class="flex flex-wrap items-center gap-x-4 gap-y-1">
        <div :for={seg <- @processed_segments} class="flex items-center gap-1.5">
          <span class={cn(["h-2.5 w-2.5 rounded-full shrink-0", seg.color])}></span>
          <span class="text-xs text-muted-foreground">{seg.label}</span>
          <span class="text-xs font-medium text-foreground tabular-nums">{seg.pct}%</span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # quota_bar/1
  # ---------------------------------------------------------------------------

  attr(:used, :integer, required: true, doc: "Amount currently used.")

  attr(:limit, :integer, required: true, doc: "Maximum allowed amount.")

  attr(:label, :string,
    default: "Usage",
    doc: "Label shown above the bar."
  )

  attr(:unit, :string,
    default: nil,
    doc: "Unit suffix (e.g. `\"MB\"`, `\"GB\"`, `\"requests\"`)."
  )

  attr(:warn_at, :integer,
    default: 80,
    doc: "Percentage at which the bar turns amber (warning zone)."
  )

  attr(:danger_at, :integer,
    default: 95,
    doc: "Percentage at which the bar turns red (danger zone)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a usage/limit progress bar with automatic color zones.

  The bar fills `bg-primary` below `:warn_at` percent, amber (warning) between
  `:warn_at` and `:danger_at`, and red (destructive) above `:danger_at`.
  This follows GitHub's storage quota and Heroku's dyno usage patterns.

  ## Example

      <.quota_bar used={8_500} limit={10_000} unit="MB" label="Storage" />
      <.quota_bar used={950} limit={1_000} unit="req/hr" label="API requests" warn_at={70} />
  """
  def quota_bar(assigns) do
    pct = progress_pct(assigns.used, assigns.limit)
    assigns = assign(assigns, :pct, pct)

    ~H"""
    <div class={cn(["w-full space-y-1.5", @class])} {@rest}>
      <div class="flex items-center justify-between gap-2">
        <span class="text-sm font-medium text-foreground">{@label}</span>
        <span class={cn(["text-sm tabular-nums font-medium", quota_text_class(@pct, @warn_at, @danger_at)])}>
          {format_quota(@used, @limit, @unit)}
        </span>
      </div>
      <div
        role="meter"
        aria-label={@label}
        aria-valuenow={@used}
        aria-valuemin="0"
        aria-valuemax={@limit}
        class="relative w-full h-2 overflow-hidden rounded-full bg-secondary"
      >
        <div
          class={cn(["h-full rounded-full transition-all duration-500 ease-out", quota_fill_class(@pct, @warn_at, @danger_at)])}
          style={"width: #{@pct}%"}
        ></div>
      </div>
      <p :if={@pct >= @danger_at} class="text-xs text-destructive">
        You've used {@pct}% of your quota. Consider upgrading.
      </p>
      <p :if={@pct >= @warn_at && @pct < @danger_at} class="text-xs text-warning">
        Approaching limit. {@limit - @used}{if @unit, do: " #{@unit}", else: ""} remaining.
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # step_progress_bar/1
  # ---------------------------------------------------------------------------

  attr(:current, :integer,
    required: true,
    doc: "Current step number (1-indexed)."
  )

  attr(:total, :integer,
    required: true,
    doc: "Total number of steps."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a step-based progress bar as N equal segments.

  Completed steps are filled with `bg-primary`; the current step is a
  lighter fill; upcoming steps are `bg-secondary`. Useful for multi-step
  forms, onboarding flows, and checkout wizards as a compact alternative
  to the `step_tracker/1` component.

  ## Example

      <%!-- Step 2 of 4 --%>
      <.step_progress_bar current={2} total={4} />
  """
  def step_progress_bar(assigns) do
    ~H"""
    <div
      role="progressbar"
      aria-valuenow={@current}
      aria-valuemin="1"
      aria-valuemax={@total}
      aria-label={"Step #{@current} of #{@total}"}
      class={cn(["flex w-full gap-1", @class])}
      {@rest}
    >
      <div
        :for={i <- 1..@total}
        class={cn(["h-1.5 flex-1 rounded-full transition-colors duration-300", step_segment_class(i, @current)])}
      ></div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp progress_pct(_value, 0), do: 0

  defp progress_pct(value, max) do
    value |> Kernel./(max) |> Kernel.*(100) |> trunc() |> min(100)
  end

  defp bar_height_class(:sm), do: "h-1.5"
  defp bar_height_class(:default), do: "h-2"
  defp bar_height_class(:lg), do: "h-3"

  defp labeled_fill_class(:default), do: "bg-primary"
  defp labeled_fill_class(:success), do: "bg-success"
  defp labeled_fill_class(:warning), do: "bg-warning"
  defp labeled_fill_class(:destructive), do: "bg-destructive"

  defp quota_fill_class(pct, _warn, danger) when pct >= danger, do: "bg-destructive"
  defp quota_fill_class(pct, warn, _danger) when pct >= warn, do: "bg-warning"
  defp quota_fill_class(_pct, _warn, _danger), do: "bg-primary"

  defp quota_text_class(pct, _warn, danger) when pct >= danger, do: "text-destructive"
  defp quota_text_class(pct, warn, _danger) when pct >= warn, do: "text-warning"
  defp quota_text_class(_pct, _warn, _danger), do: "text-muted-foreground"

  defp format_quota(used, limit, nil), do: "#{used} / #{limit}"
  defp format_quota(used, limit, unit), do: "#{used} / #{limit} #{unit}"

  defp step_segment_class(i, current) when i < current, do: "bg-primary"
  defp step_segment_class(i, i), do: "bg-primary/50"
  defp step_segment_class(_i, _current), do: "bg-secondary"
end
