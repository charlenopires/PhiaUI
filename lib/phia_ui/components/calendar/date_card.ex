defmodule PhiaUi.Components.DateCard do
  @moduledoc """
  DateCard component — a single selectable day card showing the day number and
  short weekday abbreviation.

  ## Visual states

  | State      | Appearance                                                      |
  |------------|-----------------------------------------------------------------|
  | `:default` | White/bg background, border, shadow-sm                          |
  | `:today`   | Soft primary tint (`bg-primary/10 text-primary border-primary/20`) |
  | `:selected`| Solid primary fill (`bg-primary text-primary-foreground`)       |
  | `:disabled`| Muted, `opacity-50 pointer-events-none cursor-not-allowed`      |

  ## Sizes

  | Size       | Width  | Height | Number text | Day text   |
  |------------|--------|--------|-------------|------------|
  | `:sm`      | w-12   | h-16   | text-xl     | text-[10px]|
  | `:default` | w-16   | h-20   | text-2xl    | text-xs    |
  | `:lg`      | w-20   | h-24   | text-3xl    | text-sm    |

  ## Examples

      <%!-- Basic --%>
      <.date_card date={~D[2026-03-23]} />

      <%!-- Selected today --%>
      <.date_card date={Date.utc_today()} selected today />

      <%!-- Clickable --%>
      <.date_card date={~D[2026-03-23]} on_click="select_date" />

      <%!-- Disabled --%>
      <.date_card date={~D[2026-03-23]} disabled />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :date, :any, required: true, doc: "Date.t() to display"
  attr :selected, :boolean, default: false, doc: "Whether this card is selected"
  attr :today, :boolean, default: false, doc: "Whether this date is today"
  attr :disabled, :boolean, default: false, doc: "Whether this card is disabled"
  attr :on_click, :string, default: nil, doc: "phx-click event name (ignored when disabled)"

  attr :size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Card size variant"

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1"
  attr :rest, :global, doc: "HTML attributes forwarded to the root div"

  @doc """
  Renders a selectable day card with day number and short weekday abbreviation.

  ## Examples

      <.date_card date={~D[2026-03-23]} />
      <.date_card date={~D[2026-03-23]} selected />
      <.date_card date={~D[2026-03-23]} today />
      <.date_card date={~D[2026-03-23]} disabled />
      <.date_card date={~D[2026-03-23]} on_click="select_date" />
  """
  def date_card(assigns) do
    assigns =
      assigns
      |> assign(:day_num, assigns.date.day)
      |> assign(:day_name, day_abbr(assigns.date))

    ~H"""
    <div
      class={cn([
        "flex flex-col items-center justify-center",
        "cursor-pointer select-none",
        size_class(@size),
        card_class(@selected, @today, @disabled),
        @class
      ])}
      phx-click={if @on_click && !@disabled, do: @on_click}
      phx-value-date={if @on_click && !@disabled, do: Date.to_iso8601(@date)}
      {@rest}
    >
      <span class={cn(["font-bold leading-none", number_size_class(@size)])}>{@day_num}</span>
      <span class={cn(["font-medium mt-1", day_size_class(@size)])}>{@day_name}</span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp day_abbr(date), do: Calendar.strftime(date, "%a")

  defp card_class(_selected, _today, true = _disabled) do
    "bg-background border border-border opacity-50 pointer-events-none cursor-not-allowed"
  end

  defp card_class(true = _selected, _today, _disabled) do
    "bg-primary text-primary-foreground border-transparent shadow-md"
  end

  defp card_class(_selected, true = _today, _disabled) do
    "bg-primary/10 text-primary border border-primary/20"
  end

  defp card_class(_selected, _today, _disabled) do
    "bg-background border border-border shadow-sm hover:bg-muted/50"
  end

  defp size_class(:sm), do: "w-12 h-16 rounded-xl px-3 py-2"
  defp size_class(:default), do: "w-16 h-20 rounded-2xl px-4 py-3"
  defp size_class(:lg), do: "w-20 h-24 rounded-2xl px-4 py-3"

  defp number_size_class(:sm), do: "text-xl"
  defp number_size_class(:default), do: "text-2xl"
  defp number_size_class(:lg), do: "text-3xl"

  defp day_size_class(:sm), do: "text-[10px]"
  defp day_size_class(:default), do: "text-xs"
  defp day_size_class(:lg), do: "text-sm"
end
