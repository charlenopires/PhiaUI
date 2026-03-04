defmodule PhiaUi.Components.StepTracker do
  @moduledoc """
  StepTracker component for PhiaUI.

  A multi-step progress indicator (stepper/wizard). Shows completed, active, and
  upcoming steps with connecting lines. CSS-only — no JS hook required.

  ## Sub-components

  - `step_tracker/1` — root `<ol>` wrapper with orientation support
  - `step/1` — individual step with status, label, optional step number and description

  ## Statuses

  | Status     | Circle          | Label            | ARIA                  |
  |------------|----------------|------------------|----------------------|
  | `complete` | `bg-primary` + check icon | normal weight | — |
  | `active`   | `bg-primary` + ring | bold | `aria-current="step"` |
  | `upcoming` | outlined border | `text-muted-foreground` | — |

  ## Example

      <.step_tracker>
        <.step status="complete" label="Account" step={1} />
        <.step status="active"   label="Profile" step={2} description="Fill in your details" />
        <.step status="upcoming" label="Confirm" step={3} />
      </.step_tracker>

  ## Orientation

      <.step_tracker orientation="vertical">
        ...
      </.step_tracker>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # step_tracker/1
  # ---------------------------------------------------------------------------

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Layout orientation: horizontal | vertical"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root ol element")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root ol element")

  slot(:inner_block, required: true, doc: "step/1 children")

  @doc """
  Renders the step tracker container.

  Wraps `step/1` items in an `<ol>` with appropriate layout classes.
  """
  def step_tracker(assigns) do
    ~H"""
    <ol
      aria-label="Progress steps"
      class={cn([tracker_class(@orientation), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # step/1
  # ---------------------------------------------------------------------------

  attr(:status, :string,
    required: true,
    values: ~w(complete active upcoming),
    doc: "Step status: complete | active | upcoming"
  )

  attr(:label, :string, required: true, doc: "Step label text")
  attr(:step, :integer, default: nil, doc: "Step number displayed inside the circle")
  attr(:description, :string, default: nil, doc: "Optional description shown below the label")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the step li element")
  attr(:rest, :global, doc: "HTML attributes forwarded to the li element")

  @doc """
  Renders an individual step.

  Displays a circle (with step number or check icon for complete), a label,
  and an optional description. The active step receives `aria-current="step"`.
  """
  def step(assigns) do
    ~H"""
    <li
      aria-current={if @status == "active", do: "step", else: nil}
      class={cn(["flex items-center gap-3", @class])}
      {@rest}
    >
      <%!-- Step circle --%>
      <div class={cn(["flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-semibold", step_circle_class(@status)])}>
        <%= if @status == "complete" do %>
          <.icon name="check" size={:xs} />
        <% else %>
          {if @step, do: @step, else: ""}
        <% end %>
      </div>

      <%!-- Step content --%>
      <div class="flex flex-col">
        <span class={cn(["text-sm", step_label_class(@status)])}>{@label}</span>
        <span :if={@description} class="text-xs text-muted-foreground">{@description}</span>
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp tracker_class("vertical"), do: "flex flex-col gap-4"
  defp tracker_class(_horizontal), do: "flex flex-row items-center gap-4"

  defp step_circle_class("complete"), do: "bg-primary text-primary-foreground"

  defp step_circle_class("active"),
    do: "bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2"

  defp step_circle_class("upcoming"),
    do: "border-2 border-border bg-background text-muted-foreground"

  defp step_label_class("complete"), do: "font-medium text-foreground"
  defp step_label_class("active"), do: "font-semibold text-foreground"
  defp step_label_class("upcoming"), do: "font-normal text-muted-foreground"
end
