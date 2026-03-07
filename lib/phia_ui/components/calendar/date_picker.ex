defmodule PhiaUi.Components.DatePicker do
  @moduledoc """
  Date picker component that composes `Calendar` and a popover-style dropdown.

  The date picker is fully server-rendered. The parent LiveView owns all state
  (`open`, `value`, `current_month`) and handles the events emitted by the
  trigger button and the embedded calendar. There is no client-side JS hook.

  ## Sub-components

  - `date_picker/1` — standalone date picker with trigger button + calendar dropdown
  - `form_date_picker/1` — `Phoenix.HTML.FormField`-integrated variant with hidden
    input and changeset error display

  ## When to use

  Use `date_picker/1` for any date-selection field in a form or settings panel —
  booking dates, birth dates, expiry dates, due dates, etc.

  Use `form_date_picker/1` when the field is part of a Phoenix form backed by an
  Ecto changeset, so validation errors are automatically displayed.

  For selecting a date range (check-in / check-out, report period), use
  `date_range_picker/1` instead.

  ## Standalone example

      defmodule MyAppWeb.EventLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket) do
          {:ok, assign(socket,
            picker_open: false,
            selected_date: nil,
            current_month: Date.beginning_of_month(Date.utc_today())
          )}
        end

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
      end

      <%!-- Template --%>
      <.date_picker
        id="event-date"
        open={@picker_open}
        value={@selected_date}
        current_month={@current_month}
        on_toggle="toggle-picker"
        on_change="date-selected"
        min={Date.utc_today()}
        placeholder="Select event date"
      />

  ## Form-integrated example

      <.form for={@form} phx-submit="save_event">
        <.form_date_picker
          id="start-date-picker"
          field={@form[:start_date]}
          open={@picker_open}
          value={@selected_date}
          current_month={@current_month}
          on_toggle="toggle-picker"
          on_change="date-selected"
          placeholder="Pick a start date"
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Date format

  The `:format` attribute uses `Calendar.strftime/2` directives:

  | Format string | Output example   |
  |---------------|-----------------|
  | `"%d/%m/%Y"`  | `"25/12/2026"`  |
  | `"%B %d, %Y"` | `"December 25, 2026"` |
  | `"%Y-%m-%d"`  | `"2026-12-25"`  |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Calendar, only: [calendar: 1]

  attr(:id, :string,
    required: true,
    doc: "Unique date picker ID — also used as the calendar's `id` prefix"
  )

  attr(:value, :any,
    default: nil,
    doc: "Selected date (`Date.t()`) or `nil` when no date has been chosen"
  )

  attr(:current_month, :any,
    default: nil,
    doc: """
    Currently displayed month (`Date.t()`). When `nil`, defaults to the month
    of `:value`, or the current month if `:value` is also nil.
    Update this in response to `calendar-prev-month` / `calendar-next-month` events.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: "Whether the calendar dropdown is currently visible. Controlled by the LiveView."
  )

  attr(:placeholder, :string,
    default: "Pick a date",
    doc: "Trigger button text displayed when no date is selected"
  )

  attr(:format, :string,
    default: "%d/%m/%Y",
    doc: """
    `Calendar.strftime/2` format string used to display the selected date in the trigger.
    Defaults to `\"%d/%m/%Y\"` (e.g. `"25/12/2026"`).
    """
  )

  attr(:on_toggle, :string,
    default: "date-picker-toggle",
    doc: "`phx-click` event name for the trigger button to toggle the dropdown open/closed"
  )

  attr(:on_change, :string,
    default: "calendar-change",
    doc:
      "`phx-click` event fired when a day is clicked. Receives `%{\"date\" => \"YYYY-MM-DD\"}`."
  )

  attr(:min, :any,
    default: nil,
    doc: "Minimum selectable date (`Date.t()`). Passed through to the embedded `calendar/1`."
  )

  attr(:max, :any,
    default: nil,
    doc: "Maximum selectable date (`Date.t()`). Passed through to the embedded `calendar/1`."
  )

  attr(:disabled_dates, :list,
    default: [],
    doc: "List of `Date.t()` values that cannot be selected. Passed through to `calendar/1`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged onto the root element")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div element")

  @doc """
  Renders a date picker with a trigger button and a calendar dropdown.

  The parent LiveView must handle four events:

  - `on_toggle` — toggle the popover open/closed
  - `on_change` — a day was clicked (close the picker and update `value`)
  - `"calendar-prev-month"` — navigate to the previous month
  - `"calendar-next-month"` — navigate to the next month

  The calendar dropdown is conditionally rendered with `:if={@open}`, so it
  is completely absent from the DOM when closed (no CSS visibility tricks).
  """
  def date_picker(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} {@rest}>
      <%!-- Trigger button — displays the selected date or the placeholder --%>
      <button
        type="button"
        phx-click={@on_toggle}
        class={cn([
          "flex h-10 w-full items-center justify-start gap-2 rounded-md border border-input",
          "bg-background px-3 text-sm shadow-sm text-left",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          # Muted text when no date is selected
          is_nil(@value) && "text-muted-foreground"
        ])}
      >
        <%!-- Inline calendar icon (no extra component import needed) --%>
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
          class="shrink-0"
        >
          <rect width="18" height="18" x="3" y="4" rx="2" ry="2" /><line
            x1="16"
            x2="16"
            y1="2"
            y2="6"
          /><line x1="8" x2="8" y1="2" y2="6" /><line x1="3" x2="21" y1="10" y2="10" />
        </svg>
        <span class="flex-1 truncate">{format_date(@value, @format, @placeholder)}</span>
        <%!-- Checkmark indicator — only visible when a date is selected --%>
        <svg
          :if={not is_nil(@value)}
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="shrink-0 text-primary"
        >
          <polyline points="20 6 9 17 4 12" />
        </svg>
      </button>

      <%!-- Calendar dropdown — only rendered when open (no hidden DOM element) --%>
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
    doc: """
    `Phoenix.HTML.FormField` struct from `@form[:field_name]`.
    Provides the `id`, `name`, and `errors` for form integration.
    """
  )

  attr(:id, :string,
    required: true,
    doc: "Unique date picker ID (separate from `field.id` which is used for the hidden input)"
  )

  attr(:value, :any,
    default: nil,
    doc: "Selected date (`Date.t()`) or `nil`"
  )

  attr(:current_month, :any,
    default: nil,
    doc: "Currently displayed month (`Date.t()`)"
  )

  attr(:open, :boolean, default: false, doc: "Whether the popover is open")
  attr(:placeholder, :string, default: "Pick a date", doc: "Placeholder text")

  attr(:format, :string,
    default: "%d/%m/%Y",
    doc: "`Calendar.strftime/2` format string for displaying the selected date"
  )

  attr(:on_toggle, :string,
    default: "date-picker-toggle",
    doc: "`phx-click` event name for the trigger button"
  )

  attr(:on_change, :string,
    default: "calendar-change",
    doc: "`phx-click` event name for day clicks in the embedded calendar"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper div")

  @doc """
  Renders a date picker integrated with `Phoenix.HTML.FormField`.

  Renders a `<input type="hidden">` bound to `field.name` with the ISO 8601
  date value. This hidden input is what gets submitted with the form so Phoenix
  changesets receive a string they can cast with `cast/3`.

  Changeset validation errors from `field.errors` are rendered as destructive
  text below the picker.

  ## Changeset integration

  Cast the hidden input value in your changeset:

      def changeset(event, attrs) do
        event
        |> cast(attrs, [:start_date])
        |> validate_required([:start_date])
      end

  The hidden input sends an ISO 8601 string (`"2026-03-15"`), which Ecto's
  `Date` type will automatically parse during `cast/3`.
  """
  def form_date_picker(assigns) do
    ~H"""
    <div>
      <%!-- Hidden input carries the ISO 8601 string for changeset submission --%>
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
      <%!-- Changeset validation errors --%>
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

  # When no date is selected, show the placeholder text.
  defp format_date(nil, _format, placeholder), do: placeholder

  # When a date is selected, format it using the caller-supplied strftime string.
  defp format_date(%Date{} = date, format, _placeholder) do
    Calendar.strftime(date, format)
  end

  # Determine which month to display in the embedded calendar.
  # Priority: explicit current_month > month of selected value > today.
  defp effective_month(%Date{} = month, _value), do: month
  defp effective_month(nil, %Date{} = value), do: Date.beginning_of_month(value)
  defp effective_month(nil, _value), do: Date.beginning_of_month(Date.utc_today())
end
