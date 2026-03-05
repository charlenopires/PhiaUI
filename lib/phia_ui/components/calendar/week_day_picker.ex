defmodule PhiaUi.Components.WeekDayPicker do
  @moduledoc """
  WeekDayPicker — a compact horizontal day-of-week selector.

  Renders 7 day buttons in a single row. Supports single or multiple selection,
  locale-aware labels (`:en` and `:"pt-BR"`), and disabled days. Integrates
  with Phoenix forms via hidden inputs. Zero JavaScript.

  ## Locales

  | Locale  | Labels                              |
  |---------|-------------------------------------|
  | `"en"`  | Sun Mon Tue Wed Thu Fri Sat         |
  | `"pt-BR"` | Dom Seg Ter Qua Qui Sex Sáb       |

  ## Modes

  | Mode        | Behaviour                               |
  |-------------|-----------------------------------------|
  | `:single`   | One day selected; `name` without `[]`   |
  | `:multiple` | Multiple days; `name[]` for form array  |

  ## Examples

      <%!-- Single selection --%>
      <.week_day_picker id="weekly-day" name="recurring_day" value={[@day]} on_change="set_day" />

      <%!-- Multiple selection --%>
      <.week_day_picker
        id="working-days"
        name="working_days"
        mode={:multiple}
        value={@working_days}
        on_change="toggle_day"
      />

      <%!-- Portuguese labels --%>
      <.week_day_picker id="dias" name="dias" locale="pt-BR" />

      <%!-- With disabled days --%>
      <.week_day_picker id="wdp" name="day" disabled_days={["sat", "sun"]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique HTML id for the container")

  attr(:name, :string, required: true, doc: "Form field name for the hidden inputs")

  attr(:value, :list,
    default: [],
    doc: "List of selected day values (e.g. `[\"mon\", \"wed\"]`)"
  )

  attr(:mode, :atom,
    values: [:single, :multiple],
    default: :multiple,
    doc: "Selection mode — :single allows one day, :multiple allows many"
  )

  attr(:locale, :string,
    default: "en",
    doc: "Locale for day label display. Supports \"en\" and \"pt-BR\"."
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event fired on day click. Receives phx-value-day with the day value."
  )

  attr(:disabled_days, :list,
    default: [],
    doc: "List of day values to disable (e.g. `[\"sat\", \"sun\"]`)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the container div")

  @doc """
  Renders a horizontal week-day picker.

  ## Examples

      <.week_day_picker id="wdp" name="days" mode={:multiple} value={@selected_days} on_change="toggle_day" />
  """
  def week_day_picker(assigns) do
    assigns = assign(assigns, :days, days_for_locale(assigns.locale))

    ~H"""
    <div
      id={@id}
      role="group"
      aria-label="Select days of the week"
      class={cn(["flex items-center gap-1", @class])}
      {@rest}
    >
      <%= for {day_value, day_label} <- @days do %>
        <% selected = day_value in @value
           disabled = day_value in @disabled_days %>
        <button
          type="button"
          phx-click={@on_change}
          phx-value-day={day_value}
          disabled={disabled}
          aria-pressed={to_string(selected)}
          aria-label={day_label}
          class={cn([
            "flex h-9 w-9 items-center justify-center rounded-full",
            "text-sm font-medium transition-colors",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            selected && "bg-primary text-primary-foreground",
            !selected && "bg-secondary text-secondary-foreground hover:bg-secondary/80",
            disabled && "pointer-events-none opacity-50"
          ])}
        >
          {day_label}
        </button>
      <% end %>

      <%!-- Hidden inputs for form submission --%>
      <%= for day_value <- @value do %>
        <input
          type="hidden"
          name={hidden_input_name(@name, @mode)}
          value={day_value}
        />
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp days_for_locale("pt-BR") do
    [
      {"sun", "Dom"},
      {"mon", "Seg"},
      {"tue", "Ter"},
      {"wed", "Qua"},
      {"thu", "Qui"},
      {"fri", "Sex"},
      {"sat", "Sáb"}
    ]
  end

  defp days_for_locale(_) do
    [
      {"sun", "Sun"},
      {"mon", "Mon"},
      {"tue", "Tue"},
      {"wed", "Wed"},
      {"thu", "Thu"},
      {"fri", "Fri"},
      {"sat", "Sat"}
    ]
  end

  defp hidden_input_name(name, :single), do: name
  defp hidden_input_name(name, :multiple), do: "#{name}[]"
end
