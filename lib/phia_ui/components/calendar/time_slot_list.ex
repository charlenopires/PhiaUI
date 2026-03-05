defmodule PhiaUi.Components.TimeSlotList do
  @moduledoc """
  TimeSlotList component — a vertical scrollable list of time slots with an optional AM/PM toggle.

  Displays time slots as full-width buttons in a single-column layout, ideal for appointment
  booking forms where a compact list is preferred over a grid. Supports an AM/PM toggle header
  to filter displayed periods.

  Zero JavaScript — state is managed by the LiveView.

  ## States

  | State               | Description                                              |
  |---------------------|----------------------------------------------------------|
  | available (default) | Full-width button, foreground text, hover highlight      |
  | selected            | Blue border, blue text, semibold, light blue background  |
  | slot disabled       | Muted text, opacity-50, cursor-not-allowed               |

  ## Slot formats accepted

  - Plain string: `"09:00"` — value and label both equal the string
  - Map with value only: `%{value: "09:00"}` — label defaults to value
  - Map with value + label: `%{value: "09:00", label: "9:00 AM"}`
  - Full map: `%{value: "09:00", label: "9:00 AM", disabled: true}`

  ## Examples

      <%!-- Basic usage --%>
      <.time_slot_list slots={~w(09:00 09:30 10:00)} />

      <%!-- With selected slot and LiveView handler --%>
      <.time_slot_list
        slots={@available_slots}
        selected={@selected_time}
        on_select="pick_time"
      />

      <%!-- With AM/PM toggle --%>
      <.time_slot_list
        slots={@filtered_slots}
        show_ampm={true}
        ampm={@ampm}
        on_ampm_change="toggle_ampm"
        selected={@selected_time}
        on_select="pick_time"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :slots, :list, required: true,
    doc: "List of time slot strings or maps (%{value:, label:, disabled:})"

  attr :selected, :string, default: nil,
    doc: "Value of the currently selected slot"

  attr :on_select, :string, default: nil,
    doc: "phx-click event name fired when a slot is clicked"

  attr :show_ampm, :boolean, default: false,
    doc: "Whether to display the AM/PM toggle header"

  attr :ampm, :string, default: "AM", values: ["AM", "PM"],
    doc: "Currently active AM/PM period"

  attr :on_ampm_change, :string, default: nil,
    doc: "phx-click event name fired when the AM/PM toggle is clicked"

  attr :max_height, :string, default: "240px",
    doc: "CSS max-height value for the scrollable slot area"

  attr :class, :string, default: nil,
    doc: "Additional CSS classes merged via cn/1"

  attr :rest, :global, doc: "HTML attributes forwarded to the root wrapper element"

  @doc """
  Renders a scrollable vertical list of time-slot buttons with an optional AM/PM toggle.

  ## Examples

      <.time_slot_list slots={~w(09:00 09:30 10:00)} selected="09:30" on_select="pick_time" />
  """
  def time_slot_list(assigns) do
    assigns = assign(assigns, :normalized_slots, Enum.map(assigns.slots, &normalize/1))

    ~H"""
    <div class={cn(["flex flex-col gap-1", @class])} {@rest}>
      <%!-- AM/PM Toggle --%>
      <div :if={@show_ampm} class="flex rounded-lg border border-border overflow-hidden mb-2">
        <button
          type="button"
          class={cn(["flex-1 py-1.5 text-sm font-medium transition-colors",
            @ampm == "AM" && "bg-primary text-primary-foreground",
            @ampm != "AM" && "bg-background text-muted-foreground hover:bg-muted/50"])}
          phx-click={@on_ampm_change}
          phx-value-ampm="AM"
        >
          AM
        </button>
        <button
          type="button"
          class={cn(["flex-1 py-1.5 text-sm font-medium transition-colors",
            @ampm == "PM" && "bg-primary text-primary-foreground",
            @ampm != "PM" && "bg-background text-muted-foreground hover:bg-muted/50"])}
          phx-click={@on_ampm_change}
          phx-value-ampm="PM"
        >
          PM
        </button>
      </div>

      <%!-- Scrollable slot list --%>
      <div class="overflow-y-auto" style={"max-height: #{@max_height};"}>
        <div class="flex flex-col gap-0.5 pr-1">
          <button
            :for={slot <- @normalized_slots}
            type="button"
            class={slot_class(slot, @selected)}
            phx-click={if !slot.disabled && @on_select, do: @on_select}
            phx-value-slot={if !slot.disabled && @on_select, do: slot.value}
            disabled={slot.disabled}
          >
            {slot.label}
          </button>
        </div>
      </div>
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

  defp slot_class(slot, selected) do
    cond do
      slot.disabled ->
        "w-full text-left px-3 py-2 text-sm rounded-lg text-muted-foreground opacity-50 cursor-not-allowed"

      slot.value == selected ->
        "w-full text-left px-3 py-2 text-sm rounded-lg font-semibold text-primary border border-primary bg-primary/5 cursor-pointer"

      true ->
        "w-full text-left px-3 py-2 text-sm rounded-lg text-foreground hover:bg-muted/50 cursor-pointer"
    end
  end
end
