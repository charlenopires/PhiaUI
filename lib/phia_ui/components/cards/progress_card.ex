defmodule PhiaUi.Components.ProgressCard do
  @moduledoc """
  Card component that displays a titled progress bar with optional description,
  value label, variant coloring, size, icon slot, and footer slot.

  ## Variant × size color matrix

  The `variant` controls the progress bar fill and the `size` controls height:

  | `:variant`      | Bar color                  |
  |-----------------|----------------------------|
  | `:default`      | `bg-primary` (theme color) |
  | `:success`      | `bg-emerald-500`           |
  | `:warning`      | `bg-amber-500`             |
  | `:destructive`  | `bg-destructive`           |

  | `:size` | Bar height |
  |---------|------------|
  | `:sm`   | `h-1`      |
  | `:md`   | `h-2`      |
  | `:lg`   | `h-3`      |

  ## Examples

      <%!-- Default progress for an upload --%>
      <.progress_card title="Upload Progress" value={72} />

      <%!-- Disk usage warning with footer --%>
      <.progress_card
        title="Disk Usage"
        value={90}
        variant={:destructive}
        size={:lg}
        description="Storage is almost full"
      >
        <:footer>10 GB of 12 GB used</:footer>
      </.progress_card>

      <%!-- Goal completion with custom label --%>
      <.progress_card
        title="Annual Goal"
        value={65}
        variant={:success}
        label="$65,000 / $100,000"
      >
        <:icon><.icon name="target" class="text-emerald-500" /></:icon>
      </.progress_card>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Progress, only: [progress: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Card title text")

  attr(:value, :integer,
    required: true,
    doc: "Progress value from 0 to 100"
  )

  attr(:description, :string, default: nil, doc: "Optional description text below the title")

  attr(:label, :string,
    default: nil,
    doc: "Override label for the progress value. Defaults to \"N%\"."
  )

  attr(:variant, :atom,
    default: :default,
    values: [:default, :success, :warning, :destructive],
    doc: "Progress bar color variant"
  )

  attr(:size, :atom,
    default: :md,
    values: [:sm, :md, :lg],
    doc: "Progress bar height size"
  )

  attr(:show_value, :boolean, default: true, doc: "Whether to show the value label")

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer card")

  attr(:rest, :global, doc: "HTML attributes forwarded to the outer card element")

  slot(:icon, doc: "Optional icon displayed in the card header beside the title")
  slot(:footer, doc: "Optional footer content rendered at the bottom of the card")

  @doc """
  Renders a titled progress card.

  Card regions (top to bottom):
  - **Header** — optional `:icon` slot (left) + `title` text
  - **Content** — optional `description`, optional value label, progress bar
  - **Footer** — optional `:footer` slot (timestamps, legends, etc.)

  The `label` attribute overrides the default percentage display
  (`"\#{value}%"`). Set `show_value={false}` to hide the label entirely.

  ## Examples

      <%!-- Upload progress --%>
      <.progress_card title="Upload Progress" value={72} />

      <%!-- Disk usage with destructive WARNING and footer --%>
      <.progress_card
        title="Disk Usage"
        value={90}
        variant={:destructive}
        size={:lg}
        description="Storage is almost full"
      >
        <:footer>10 GB of 12 GB used</:footer>
      </.progress_card>

      <%!-- Revenue goal with custom label and icon --%>
      <.progress_card
        title="Annual Sales Goal"
        value={65}
        variant={:success}
        label="$65,000 of $100,000"
      >
        <:icon><.icon name="trending-up" class="text-emerald-500" /></:icon>
      </.progress_card>
  """
  def progress_card(assigns) do
    ~H"""
    <.card class={cn(["shadow-sm", @class])} {@rest}>
      <.card_header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <div class="flex items-center gap-2">
          <span :if={@icon != []} class="text-muted-foreground">
            {render_slot(@icon)}
          </span>
          <.card_title class="text-base font-semibold">{@title}</.card_title>
        </div>
      </.card_header>
      <.card_content>
        <p :if={@description} class="text-sm text-muted-foreground mb-2">{@description}</p>
        <div :if={@show_value} class="flex justify-end mb-1">
          <span class="text-sm text-muted-foreground">{@label || "#{@value}%"}</span>
        </div>
        <.progress value={@value} class={progress_class(@variant, @size)} />
      </.card_content>
      <.card_footer :if={@footer != []} class="pt-0">
        {render_slot(@footer)}
      </.card_footer>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp progress_class(:default, :sm), do: "h-1"
  defp progress_class(:default, :md), do: "h-2"
  defp progress_class(:default, :lg), do: "h-3"
  defp progress_class(:success, :sm), do: "h-1 [&>div]:bg-emerald-500"
  defp progress_class(:success, :md), do: "h-2 [&>div]:bg-emerald-500"
  defp progress_class(:success, :lg), do: "h-3 [&>div]:bg-emerald-500"
  defp progress_class(:warning, :sm), do: "h-1 [&>div]:bg-amber-500"
  defp progress_class(:warning, :md), do: "h-2 [&>div]:bg-amber-500"
  defp progress_class(:warning, :lg), do: "h-3 [&>div]:bg-amber-500"
  defp progress_class(:destructive, :sm), do: "h-1 [&>div]:bg-destructive"
  defp progress_class(:destructive, :md), do: "h-2 [&>div]:bg-destructive"
  defp progress_class(:destructive, :lg), do: "h-3 [&>div]:bg-destructive"
end
