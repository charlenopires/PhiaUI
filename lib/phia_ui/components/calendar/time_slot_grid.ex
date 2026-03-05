defmodule PhiaUi.Components.TimeSlotGrid do
  @moduledoc """
  TimeSlotGrid component — a responsive grid of time-slot buttons for appointment booking.

  Displays time slots as pill buttons arranged in a configurable column grid (2, 3, or 4
  columns). Each slot may be in one of four states: default (available), selected,
  disabled (individual slot), or fully disabled (entire grid).

  Zero JavaScript — state is managed by the LiveView.

  ## States

  | State               | Description                                              |
  |---------------------|----------------------------------------------------------|
  | available (default) | White bg, border, hover highlight                        |
  | selected            | Blue border (2 px), blue text, semibold                  |
  | slot disabled       | Muted bg, opacity-50, cursor-not-allowed                 |
  | grid disabled       | All slots muted, opacity-50, cursor-not-allowed          |

  ## Slot formats accepted

  - Plain string: `"9:00 AM"` — value and label both equal the string
  - Map with value only: `%{value: "9:00 AM"}` — label defaults to value
  - Map with value + label: `%{value: "9:00AM", label: "9:00 AM"}`
  - Full map: `%{value: "9:00AM", label: "9:00 AM", disabled: true}`

  ## Examples

      <%!-- Basic usage --%>
      <.time_slot_grid slots={~w(9:00AM 9:30AM 10:00AM)} />

      <%!-- With selected slot and LiveView handler --%>
      <.time_slot_grid
        slots={@available_slots}
        selected={@selected_time}
        on_select="pick_slot"
      />

      <%!-- 4-column grid, grid-level disabled --%>
      <.time_slot_grid slots={@slots} cols={4} disabled={@loading} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :slots, :list, required: true,
    doc: "List of time slot strings or maps (%{value:, label:, disabled:})"

  attr :selected, :string, default: nil,
    doc: "Value of the currently selected slot"

  attr :on_select, :string, default: nil,
    doc: "phx-click event name fired when a slot is clicked"

  attr :cols, :integer, default: 3,
    doc: "Number of grid columns — 2, 3, or 4 (defaults to 3)"

  attr :disabled, :boolean, default: false,
    doc: "Disables the entire grid — all slots become non-interactive"

  attr :class, :string, default: nil,
    doc: "Additional CSS classes merged via cn/1"

  attr :rest, :global, doc: "HTML attributes forwarded to the root wrapper element"

  @doc """
  Renders a grid of time-slot pill buttons.

  ## Examples

      <.time_slot_grid slots={~w(3:00PM 3:30PM 4:00PM)} selected="3:30PM" on_select="pick" />
  """
  def time_slot_grid(assigns) do
    assigns = assign(assigns, :normalized_slots, Enum.map(assigns.slots, &normalize/1))

    ~H"""
    <div class={cn(["grid gap-3", cols_class(@cols), @class])} {@rest}>
      <button
        :for={slot <- @normalized_slots}
        type="button"
        class={slot_class(slot, @selected, @disabled)}
        phx-click={if !@disabled && !slot.disabled && @on_select, do: @on_select}
        phx-value-slot={if !@disabled && !slot.disabled && @on_select, do: slot.value}
        disabled={@disabled || slot.disabled}
      >
        {slot.label}
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp normalize(s) when is_binary(s), do: %{value: s, label: s, disabled: false}
  defp normalize(%{value: v, label: l, disabled: d}), do: %{value: v, label: l, disabled: d}
  defp normalize(%{value: v, label: l}), do: %{value: v, label: l, disabled: false}
  defp normalize(%{value: v}), do: %{value: v, label: v, disabled: false}

  defp cols_class(2), do: "grid-cols-2"
  defp cols_class(3), do: "grid-cols-3"
  defp cols_class(4), do: "grid-cols-4"
  defp cols_class(_), do: "grid-cols-3"

  defp slot_class(slot, selected, grid_disabled) do
    cond do
      grid_disabled or slot.disabled ->
        "rounded-xl border border-border bg-muted text-muted-foreground opacity-50 cursor-not-allowed px-3 py-2.5 text-sm text-center"

      slot.value == selected ->
        "rounded-xl border-2 border-primary bg-background text-primary font-semibold px-3 py-2.5 text-sm text-center cursor-pointer"

      true ->
        "rounded-xl border border-border bg-background text-foreground px-3 py-2.5 text-sm text-center cursor-pointer hover:bg-muted/50 transition-colors"
    end
  end
end
