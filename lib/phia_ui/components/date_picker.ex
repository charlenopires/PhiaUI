defmodule PhiaUi.Components.DatePicker do
  @moduledoc """
  Date picker component that composes Calendar and Popover components.

  The date picker is fully server-rendered. The parent LiveView owns the state
  (`open`, `value`, `current_month`) and handles the events emitted by the
  trigger button and the embedded calendar.

  ## Sub-components

  - `date_picker/1` — standalone date picker with trigger + dropdown calendar
  - `form_date_picker/1` — form-integrated variant with hidden input and error display

  ## Example — standalone

      <.date_picker
        id="start-date"
        open={@picker_open}
        value={@selected_date}
        current_month={@current_month}
        on_toggle="toggle-picker"
        on_change="date-selected"
      />

  ## Example — form-integrated

      <.form_date_picker
        id="birth-date"
        field={@form[:birth_date]}
        open={@picker_open}
        value={@selected_date}
        current_month={@current_month}
        on_toggle="toggle-picker"
        on_change="date-selected"
      />

  ## LiveView handlers

      def handle_event("toggle-picker", _params, socket) do
        {:noreply, update(socket, :picker_open, &(!&1))}
      end

      def handle_event("date-selected", %{"date" => iso}, socket) do
        date = Date.from_iso8601!(iso)
        {:noreply, assign(socket, selected_date: date, picker_open: false)}
      end

      def handle_event("calendar-prev-month", %{"month" => iso}, socket) do
        {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
      end

      def handle_event("calendar-next-month", %{"month" => iso}, socket) do
        {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Calendar, only: [calendar: 1]

  attr(:id, :string, required: true, doc: "Unique date picker ID")
  attr(:value, :any, default: nil, doc: "Selected date (Date.t) or nil")

  attr(:current_month, :any,
    default: nil,
    doc: "Currently displayed month (Date.t). Defaults to today or the selected value."
  )

  attr(:open, :boolean, default: false, doc: "Whether the date picker popover is open")
  attr(:placeholder, :string, default: "Pick a date", doc: "Placeholder when no date selected")
  attr(:format, :string, default: "%d/%m/%Y", doc: "Date format string for Calendar.strftime")

  attr(:on_toggle, :string,
    default: "date-picker-toggle",
    doc: "phx-click event name for the trigger button"
  )

  attr(:on_change, :string,
    default: "calendar-change",
    doc: "phx-click event fired when a day is clicked in the calendar"
  )

  attr(:min, :any, default: nil, doc: "Minimum selectable date (Date.t)")
  attr(:max, :any, default: nil, doc: "Maximum selectable date (Date.t)")

  attr(:disabled_dates, :list,
    default: [],
    doc: "Explicit list of Date.t values that cannot be selected"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  @doc """
  Renders a date picker with a trigger button and calendar dropdown.

  The parent LiveView must handle:
  - `date-picker-toggle` (or `:on_toggle`) — toggle popover open/closed
  - `calendar-change` (or `:on_change`) — date selected (`%{"date" => "YYYY-MM-DD"}`)
  - `calendar-prev-month` / `calendar-next-month` — month navigation
  """
  def date_picker(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} {@rest}>
      <%!-- Trigger button --%>
      <button
        type="button"
        phx-click={@on_toggle}
        class={cn([
          "flex w-full items-center justify-start gap-2 rounded-md border border-input",
          "bg-background px-3 py-2 text-sm shadow-sm text-left",
          "focus:outline-none focus:ring-2 focus:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          is_nil(@value) && "text-muted-foreground"
        ])}
      >
        <%!-- Calendar icon --%>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <rect width="18" height="18" x="3" y="4" rx="2" ry="2" /><line
            x1="16"
            x2="16"
            y1="2"
            y2="6"
          /><line x1="8" x2="8" y1="2" y2="6" /><line x1="3" x2="21" y1="10" y2="10" />
        </svg>
        {format_date(@value, @format, @placeholder)}
      </button>
      <%!-- Calendar dropdown --%>
      <div
        :if={@open}
        class={cn([
          "absolute z-50 mt-1 rounded-md border bg-popover shadow-md",
          "text-popover-foreground"
        ])}
      >
        <.calendar
          id={"#{@id}-calendar"}
          value={@value}
          current_month={effective_month(@current_month, @value)}
          on_change={@on_change}
          min={@min}
          max={@max}
          disabled_dates={@disabled_dates}
        />
      </div>
    </div>
    """
  end

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "Phoenix.HTML.FormField struct for name, id, and error display"
  )

  attr(:id, :string, required: true, doc: "Unique date picker ID")
  attr(:value, :any, default: nil, doc: "Selected date (Date.t) or nil")

  attr(:current_month, :any,
    default: nil,
    doc: "Currently displayed month (Date.t). Defaults to today or the selected value."
  )

  attr(:open, :boolean, default: false, doc: "Whether the popover is open")
  attr(:placeholder, :string, default: "Pick a date", doc: "Placeholder text")
  attr(:format, :string, default: "%d/%m/%Y", doc: "Date format string")
  attr(:on_toggle, :string, default: "date-picker-toggle", doc: "Toggle event name")
  attr(:on_change, :string, default: "calendar-change", doc: "Calendar change event name")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders a date picker integrated with `Phoenix.HTML.FormField`.

  Renders a hidden input with the ISO 8601 value derived from `:field.name`,
  and displays form errors below the picker.
  """
  def form_date_picker(assigns) do
    ~H"""
    <div>
      <input
        type="hidden"
        id={@field.id}
        name={@field.name}
        value={if @value, do: Date.to_iso8601(@value), else: ""}
      />
      <.date_picker
        id={@id}
        value={@value}
        current_month={@current_month}
        open={@open}
        placeholder={@placeholder}
        format={@format}
        on_toggle={@on_toggle}
        on_change={@on_change}
        class={@class}
      />
      <div :if={@field.errors != []}>
        <p :for={error <- @field.errors} class="text-sm text-destructive mt-1">
          {elem(error, 0)}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp format_date(nil, _format, placeholder), do: placeholder

  defp format_date(%Date{} = date, format, _placeholder) do
    Calendar.strftime(date, format)
  end

  defp effective_month(%Date{} = month, _value), do: month
  defp effective_month(nil, %Date{} = value), do: Date.beginning_of_month(value)
  defp effective_month(nil, _value), do: Date.beginning_of_month(Date.utc_today())
end
