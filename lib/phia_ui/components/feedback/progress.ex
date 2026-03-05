defmodule PhiaUi.Components.Progress do
  @moduledoc """
  Linear progress bar for displaying completion of a task or process.

  Renders a semantic `role="progressbar"` element with the appropriate ARIA
  attributes. The fill width is computed at render time from `:value` and
  `:max` and applied as an inline `width` style. Purely CSS — no JavaScript
  required.

  ## Examples

  ### Basic usage (50% of 100)

      <.progress value={50} />

  ### Custom maximum (file upload: 3 of 5 files)

      <.progress value={3} max={5} />

  ### Taller bar

      <.progress value={75} class="h-3" />

  ### Inside a dashboard stat card

      <.stat_card title="Storage used" value="4.2 GB / 10 GB">
        <.progress value={42} class="mt-2" />
      </.stat_card>

  ### Onboarding checklist completion

      <%!-- Shows how many setup tasks the user has completed --%>
      <div class="space-y-1">
        <div class="flex justify-between text-sm">
          <span>Setup progress</span>
          <span>{@completed}/{@total} steps</span>
        </div>
        <.progress value={@completed} max={@total} />
      </div>

  ### Animated skill bars

      <%= for {skill, level} <- @skills do %>
        <div class="space-y-1">
          <div class="flex justify-between text-sm">
            <span>{skill}</span>
            <span>{level}%</span>
          </div>
          <.progress value={level} class="h-2" />
        </div>
      <% end %>

  ## Accessibility

  The outer `<div>` carries:
  - `role="progressbar"` — announces the element as a progress indicator.
  - `aria-valuenow={value}` — the current numeric value.
  - `aria-valuemin="0"` — always zero.
  - `aria-valuemax={max}` — the configured maximum.

  Screen readers announce something like "50%" or "3 of 5". For labelled
  progress bars, add `aria-label` or `aria-labelledby` via `:rest`:

      <.progress value={42} aria-label="Storage used: 42%" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :integer,
    default: 0,
    doc: "Current progress value. Must be between `0` and `:max`. Default: `0`."
  )

  attr(:max, :integer,
    default: 100,
    doc:
      "Maximum value for the progress bar. Default: `100`. Set to a custom value when your scale differs (e.g. `max={5}` for a 5-step flow)."
  )

  attr(:class, :string,
    default: nil,
    doc:
      "Additional CSS classes applied to the track element. Use `h-N` to change bar height (default `h-2`)."
  )

  attr(:rest, :global,
    doc:
      "HTML attributes forwarded to the root element. Useful for `aria-label` or `aria-labelledby`."
  )

  @doc """
  Renders a horizontal progress bar.

  The fill width is computed as `floor(value / max * 100)%` and applied as
  an inline style on the inner fill `<div>`. A `transition-all duration-300`
  animation smoothly widens the bar when the value changes — this works
  naturally with LiveView's real-time assigns.

  Both the track (`bg-secondary`) and fill (`bg-primary`) use semantic color
  tokens so they adapt automatically to light and dark mode.

  ## Example

      <.progress value={@upload_progress} aria-label="Upload progress" />
  """
  def progress(assigns) do
    # Pre-compute percentage once so the template remains clean.
    # The result is an integer (truncated) to avoid sub-pixel float formatting.
    assigns = assign(assigns, :pct, progress_pct(assigns.value, assigns.max))

    ~H"""
    <div
      role="progressbar"
      aria-valuenow={@value}
      aria-valuemin="0"
      aria-valuemax={@max}
      class={cn(["relative h-2 w-full overflow-hidden rounded-full bg-secondary", @class])}
      {@rest}
    >
      <%!-- Fill div: width driven by inline style, animated on change --%>
      <div
        class="h-full rounded-full bg-primary transition-all duration-300 ease-in-out"
        style={"width: #{@pct}%"}
      >
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Guard against division by zero when max is 0 (misconfigured or loading)
  defp progress_pct(_value, 0), do: 0

  defp progress_pct(value, max) do
    value
    # Compute fractional percentage
    |> Kernel./(max)
    |> Kernel.*(100)
    # Truncate to an integer — avoids "33.333333%" style strings
    |> trunc()
  end
end
