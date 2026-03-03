defmodule PhiaUi.Components.Progress do
  @moduledoc """
  Progress bar component for PhiaUI.

  Renders a linear progress indicator backed by semantic Tailwind tokens.
  Purely CSS — no JavaScript required. Width is set via an inline style
  calculated from `:value` and `:max`.

  Fully accessible: `role="progressbar"` with `aria-valuenow`,
  `aria-valuemin`, and `aria-valuemax` attributes.

  ## Examples

      <%!-- Basic usage (50%) --%>
      <.progress value={50} />

      <%!-- Custom max (e.g. 10 out of 20) --%>
      <.progress value={10} max={20} />

      <%!-- Custom height via class --%>
      <.progress value={75} class="h-3" />

      <%!-- In a StatCard --%>
      <.stat_card title="Tasks" value="8/10">
        <.progress value={8} max={10} class="mt-2" />
      </.stat_card>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :integer,
    default: 0,
    doc: "Current progress value (0 to :max). Default: 0."
  )

  attr(:max, :integer,
    default: 100,
    doc: "Maximum value for the progress bar. Default: 100."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the track element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  @doc """
  Renders a horizontal progress bar.

  The bar width is computed as `floor(value / max * 100)%` and applied as an
  inline style. Both the track and bar use semantic color tokens so they
  adapt automatically to light/dark mode without extra configuration.
  """
  def progress(assigns) do
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

  defp progress_pct(_value, 0), do: 0

  defp progress_pct(value, max) do
    value
    |> Kernel./(max)
    |> Kernel.*(100)
    |> trunc()
  end
end
