defmodule PhiaUi.Components.StepTracker do
  @moduledoc """
  Multi-step progress indicator (stepper / wizard) component.

  Shows users where they are in a multi-step process such as a checkout
  flow, onboarding wizard, or form wizard. Each step has one of three
  statuses: `complete`, `active`, or `upcoming`. CSS-only — no JavaScript
  hook is required.

  ## Sub-components

  | Component       | Element | Purpose                                              |
  |-----------------|---------|------------------------------------------------------|
  | `step_tracker/1`| `<ol>`  | Ordered list container with orientation support      |
  | `step/1`        | `<li>`  | Individual step with circle, label, and description  |

  ## Step statuses

  | Status     | Circle style                         | Label style             | ARIA                    |
  |------------|--------------------------------------|-------------------------|-------------------------|
  | `complete` | `bg-primary` + check icon            | `font-medium`           | —                       |
  | `active`   | `bg-primary` + `ring-2 ring-primary` | `font-semibold`         | `aria-current="step"`   |
  | `upcoming` | outlined `border-2 border-border`    | `text-muted-foreground` | —                       |

  ## Horizontal step tracker (default)

  The most common layout — shown at the top of multi-step forms:

      <.step_tracker>
        <.step status="complete" label="Cart"     step={1} />
        <.step status="complete" label="Shipping" step={2} />
        <.step status="active"   label="Payment"  step={3} description="Enter your card details" />
        <.step status="upcoming" label="Review"   step={4} />
        <.step status="upcoming" label="Confirm"  step={5} />
      </.step_tracker>

  ## Vertical step tracker

  Vertical orientation works well in sidebars or narrower panels. Add
  `orientation="vertical"` to the container:

      <.step_tracker orientation="vertical">
        <.step status="complete" label="Create account"   step={1} />
        <.step status="active"   label="Verify email"     step={2} description="Check your inbox" />
        <.step status="upcoming" label="Complete profile"  step={3} />
      </.step_tracker>

  ## Multi-step checkout example

  A typical e-commerce checkout integrating with LiveView state:

      defmodule MyAppWeb.CheckoutLive do
        use MyAppWeb, :live_view

        @steps ~w(cart shipping payment review)

        def mount(_params, _session, socket) do
          {:ok, assign(socket, current_step: "shipping")}
        end

        defp step_status(step, current) do
          steps = @steps
          current_idx  = Enum.find_index(steps, &(&1 == current))
          step_idx     = Enum.find_index(steps, &(&1 == step))
          cond do
            step_idx < current_idx  -> "complete"
            step_idx == current_idx -> "active"
            true                    -> "upcoming"
          end
        end
      end

  Template:

      <.step_tracker>
        <.step status={step_status("cart",     @current_step)} label="Cart"     step={1} />
        <.step status={step_status("shipping", @current_step)} label="Shipping" step={2} />
        <.step status={step_status("payment",  @current_step)} label="Payment"  step={3} />
        <.step status={step_status("review",   @current_step)} label="Review"   step={4} />
      </.step_tracker>

  ## Accessibility

  - The `<ol>` root has `aria-label="Progress steps"` to announce context.
  - The active step `<li>` carries `aria-current="step"` so screen readers
    announce "current step, [label]" giving users clear orientation.
  - Completed steps receive no special ARIA; their check icon is `aria-hidden`
    as the status is conveyed by the label context.
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
    doc: "Layout direction: `\"horizontal\"` (default, flex-row) or `\"vertical\"` (flex-col)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the root `<ol>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<ol>` element.")

  slot(:inner_block, required: true, doc: "Should contain `step/1` children.")

  @doc """
  Renders the step tracker container.

  Wraps `step/1` items in an `<ol>` (ordered list) with the appropriate
  flex layout for the chosen orientation.

  Choose `orientation="horizontal"` for a top-of-page progress bar and
  `orientation="vertical"` for a sidebar or panel layout.
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
    doc:
      "Step status. Controls visual styling and ARIA attribute. One of `\"complete\"`, `\"active\"`, or `\"upcoming\"`."
  )

  attr(:label, :string,
    required: true,
    doc: "Primary step label shown beside the circle (e.g. `\"Shipping\"`)."
  )

  attr(:step, :integer,
    default: nil,
    doc:
      "Step number displayed inside the circle for `upcoming` and `active` states. When `nil`, the circle is empty for non-complete steps."
  )

  attr(:description, :string,
    default: nil,
    doc:
      "Optional secondary text shown below the label. Useful for brief instructions on the active step."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<li>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")

  @doc """
  Renders an individual step.

  Displays:
  - A **circle** on the left: check icon for `complete`, step number for
    `active`/`upcoming`, or empty if `step` is `nil`.
  - A **label** beside the circle, weight varies by status.
  - An optional **description** in muted text below the label.

  The active step receives `aria-current="step"` so assistive technologies
  announce it as the current step in the sequence.

  ## Examples

      <%!-- Completed step --%>
      <.step status="complete" label="Account setup" step={1} />

      <%!-- Active step with description --%>
      <.step status="active" label="Payment details" step={2}
             description="Your card is charged only after review." />

      <%!-- Upcoming step --%>
      <.step status="upcoming" label="Confirm order" step={3} />
  """
  def step(assigns) do
    ~H"""
    <li
      aria-current={if @status == "active", do: "step", else: nil}
      class={cn(["flex items-center gap-3", @class])}
      {@rest}
    >
      <%!-- Step circle: check icon for complete, number for active/upcoming --%>
      <div class={cn(["flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-semibold", step_circle_class(@status)])}>
        <%= if @status == "complete" do %>
          <%!-- Check icon replaces the number once the step is done --%>
          <.icon name="check" size={:xs} />
        <% else %>
          <%!-- Show step number if provided; leave blank for unnumbered steps --%>
          {if @step, do: @step, else: ""}
        <% end %>
      </div>

      <%!-- Step label and optional description --%>
      <div class="flex flex-col">
        <span class={cn(["text-sm", step_label_class(@status)])}>{@label}</span>
        <%!-- Description only visible when provided — typically on the active step --%>
        <span :if={@description} class="text-xs text-muted-foreground">{@description}</span>
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Horizontal layout: steps flow left-to-right in a row
  defp tracker_class("vertical"), do: "flex flex-col gap-4"
  defp tracker_class(_horizontal), do: "flex flex-row items-center gap-4"

  # Complete: solid primary background (same as active but without ring)
  defp step_circle_class("complete"), do: "bg-primary text-primary-foreground"

  # Active: solid primary + ring offset to emphasize the current position
  defp step_circle_class("active"),
    do: "bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2"

  # Upcoming: outlined/ghost style to communicate "not yet reached"
  defp step_circle_class("upcoming"),
    do: "border-2 border-border bg-background text-muted-foreground"

  # Complete: medium weight — done but not the focus
  defp step_label_class("complete"), do: "font-medium text-foreground"

  # Active: semibold — draws attention to the current step
  defp step_label_class("active"), do: "font-semibold text-foreground"

  # Upcoming: normal weight, muted — de-emphasised future steps
  defp step_label_class("upcoming"), do: "font-normal text-muted-foreground"
end
