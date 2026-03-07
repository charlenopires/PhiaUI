defmodule PhiaUi.Components.StepperNav do
  @moduledoc """
  Visual step progress indicator for onboarding, checkout, and wizard flows.

  Two components:

  - `stepper_nav/1` — horizontal or vertical step container
  - `stepper_nav_item/1` — individual step with state-based styling
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # stepper_nav/1
  # ---------------------------------------------------------------------------

  attr(:orientation, :atom, values: [:horizontal, :vertical], default: :horizontal)
  attr(:variant, :atom, values: [:default, :dots, :progress], default: :default)
  attr(:current_step, :integer, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "stepper_nav_item/1 children")

  @doc "Renders a step progress indicator container."
  def stepper_nav(assigns) do
    ~H"""
    <div
      role="list"
      aria-label="Progress steps"
      class={cn([
        stepper_nav_orientation_class(@orientation),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # stepper_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:step, :integer, required: true)
  attr(:state, :atom, values: [:pending, :active, :complete, :error], default: :pending)
  attr(:on_click, :string, default: nil, doc: "phx-click event for non-linear navigation")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "Step label text")
  slot(:description, doc: "Optional subtitle")

  @doc "Renders an individual step inside stepper_nav."
  def stepper_nav_item(assigns) do
    ~H"""
    <div
      role="listitem"
      class={cn([
        "flex items-center gap-3",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%!-- Step circle with inline SVG for complete/error to avoid <.icon> :rest collision --%>
      <button
        type="button"
        phx-click={@on_click}
        disabled={is_nil(@on_click) || @disabled}
        aria-current={if @state == :active, do: "step"}
        class={cn([
          "flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-sm font-semibold transition-colors",
          step_state_class(@state),
          is_nil(@on_click) && "cursor-default"
        ])}
      >
        <%= if @state == :complete do %>
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        <% else %>
          <%= if @state == :error do %>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          <% else %>
            {@step}
          <% end %>
        <% end %>
      </button>
      <%!-- Label and description --%>
      <div class="flex flex-col">
        <span class={cn([
          "text-sm font-medium",
          @state == :active && "text-foreground",
          @state == :pending && "text-muted-foreground",
          @state == :complete && "text-foreground",
          @state == :error && "text-destructive"
        ])}>
          {render_slot(@inner_block)}
        </span>
        <%= if @description != [] do %>
          <span class="text-xs text-muted-foreground">{render_slot(@description)}</span>
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp stepper_nav_orientation_class(:horizontal), do: "flex items-center gap-4"
  defp stepper_nav_orientation_class(:vertical), do: "flex flex-col gap-4"

  defp step_state_class(:pending), do: "border-2 border-border bg-background text-muted-foreground"
  defp step_state_class(:active), do: "border-2 border-primary bg-primary text-primary-foreground"
  defp step_state_class(:complete), do: "border-2 border-primary bg-primary text-primary-foreground"
  defp step_state_class(:error), do: "border-2 border-destructive bg-destructive text-destructive-foreground"
end
