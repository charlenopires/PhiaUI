defmodule PhiaUi.Components.DateRangePresets do
  @moduledoc """
  Preset date range picker with sidebar shortcuts and a calendar grid.

  Renders a two-column panel:
  - **Left**: a list of preset shortcuts (Today, Yesterday, Last week, etc.)
  - **Right**: a single-month calendar in range mode for custom selection

  The bottom footer shows the formatted date range and optional Cancel/Done
  action buttons. Zero JavaScript — state lives entirely in the parent LiveView.

  ## State management

  The parent LiveView owns all state. It must handle:

  - `on_preset` event — fired when a preset button is clicked, sends
    `%{"preset" => "today" | "yesterday" | "last_week" | ...}`
  - `on_change` event — fired when a calendar day is clicked (for custom range),
    sends `%{"date" => "YYYY-MM-DD"}`
  - `calendar-prev-month` / `calendar-next-month` — navigation events from the
    inner calendar (hardcoded in `calendar/1`)
  - `on_cancel` / `on_confirm` — Cancel/Done button events

  When the LiveView receives `on_preset`, it computes the `from` and `to`
  dates for the selected preset and updates assigns accordingly.

  ## Example

      <.date_range_presets
        id="analytics-range"
        active_preset={@active_preset}
        from={@date_from}
        to={@date_to}
        current_month={@current_month}
        on_preset="preset-selected"
        on_change="date-range-day-clicked"
        on_cancel="cancel-range"
        on_confirm="apply-range"
      />

  ## Preset IDs

  The built-in presets fire these `preset` values:
  `"today"`, `"yesterday"`, `"last_week"`, `"last_7_days"`, `"this_month"`,
  `"last_30_days"`, `"custom"`.

  ## Custom presets

  Pass a custom list via the `:presets` attr. When omitted, the seven default
  presets are shown.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Calendar, only: [calendar: 1]

  @default_presets [
    %{id: "today", label: "Today"},
    %{id: "yesterday", label: "Yesterday"},
    %{id: "last_week", label: "Last week"},
    %{id: "last_7_days", label: "Last 7 days"},
    %{id: "this_month", label: "This month"},
    %{id: "last_30_days", label: "Last 30 days"},
    %{id: "custom", label: "Custom range"}
  ]

  attr(:id, :string, required: true, doc: "Unique DOM id prefix")
  attr(:current_month, :any, required: true, doc: "Currently displayed month (`Date.t()`)")
  attr(:active_preset, :string, default: "custom", doc: "ID of the currently active preset")
  attr(:from, :any, default: nil, doc: "Range start date (`Date.t()`) or nil")
  attr(:to, :any, default: nil, doc: "Range end date (`Date.t()`) or nil")
  attr(:presets, :list, default: nil, doc: "Override preset list (list of `%{id: string, label: string}`)")
  attr(:on_preset, :string, default: "date-preset-change", doc: "Event fired on preset click")
  attr(:on_change, :string, default: "date-range-changed", doc: "Event fired on calendar day click")
  attr(:on_cancel, :string, default: "date-presets-cancel", doc: "Cancel button event")
  attr(:on_confirm, :string, default: "date-presets-confirm", doc: "Done button event")
  attr(:show_actions, :boolean, default: true, doc: "Show Cancel / Done buttons in footer")
  attr(:class, :string, default: nil)

  def date_range_presets(assigns) do
    assigns = assign_new(assigns, :presets, fn -> @default_presets end)
    # Nil override: if caller explicitly passed nil, fall back to defaults
    assigns =
      if is_nil(assigns.presets) do
        assign(assigns, :presets, @default_presets)
      else
        assigns
      end

    ~H"""
    <div class={cn(["w-fit rounded-lg border border-border bg-card shadow-sm", @class])}>
      <div class="flex divide-x divide-border">
        <%!-- Left: preset shortcut list --%>
        <div class="flex w-44 flex-col py-2" role="listbox" aria-label="Date range presets">
          <button
            :for={preset <- @presets}
            type="button"
            role="option"
            aria-selected={to_string(preset.id == @active_preset)}
            phx-click={@on_preset}
            phx-value-preset={preset.id}
            class={cn([
              "px-4 py-2 text-left text-sm transition-colors hover:bg-accent hover:text-accent-foreground",
              preset.id == @active_preset && "bg-accent font-medium"
            ])}
          >
            {preset.label}
          </button>
        </div>

        <%!-- Right: single-month calendar in range mode --%>
        <div>
          <.calendar
            id={"#{@id}-cal"}
            current_month={@current_month}
            mode="range"
            range_start={@from}
            range_end={@to}
            on_change={@on_change}
          />
        </div>
      </div>

      <%!-- Footer: range summary + optional actions --%>
      <div class="flex items-center justify-between border-t border-border px-4 py-3">
        <span class="text-sm text-muted-foreground" data-range-label>
          {format_range(@from, @to)}
        </span>

        <div :if={@show_actions} class="flex gap-2">
          <button
            type="button"
            phx-click={@on_cancel}
            class="inline-flex h-9 items-center rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            phx-click={@on_confirm}
            class="inline-flex h-9 items-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Done
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp format_range(nil, _), do: ""
  defp format_range(%Date{} = from, nil), do: Calendar.strftime(from, "%b %d, %Y") <> " –"

  defp format_range(%Date{} = from, %Date{} = to) do
    Calendar.strftime(from, "%b %d, %Y") <> " – " <> Calendar.strftime(to, "%b %d, %Y")
  end
end
