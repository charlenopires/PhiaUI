defmodule PhiaUi.Components.DateStrip do
  @moduledoc """
  DateStrip — a horizontal scrollable strip of day cards (week selector).

  Renders a row of date cards, each displaying the day number and abbreviated
  day name. Supports selected state, today highlight, click events, size
  variants, and optional horizontal scrolling. Zero JavaScript.

  ## Examples

      <%!-- Basic week strip --%>
      <.date_strip dates={@week_dates} />

      <%!-- With selected date --%>
      <.date_strip dates={@week_dates} selected_date={@selected} on_select="pick_date" />

      <%!-- With today highlight --%>
      <.date_strip dates={@week_dates} today={Date.utc_today()} selected_date={@selected} />

      <%!-- Small variant --%>
      <.date_strip dates={@week_dates} size={:sm} />

      <%!-- Non-scrollable (wraps) --%>
      <.date_strip dates={@week_dates} scrollable={false} />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :dates, :list, required: true, doc: "List of Date.t() values to render as cards"

  attr :selected_date, :any,
    default: nil,
    doc: "Currently selected Date.t(), or nil for no selection"

  attr :today, :any,
    default: nil,
    doc: "Date.t() to highlight as today. Caller is responsible for supplying this."

  attr :on_select, :string,
    default: nil,
    doc: "phx-click event name fired when a card is clicked. Receives phx-value-date (ISO 8601)."

  attr :size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Card size variant"

  attr :scrollable, :boolean,
    default: true,
    doc: "When true (default) the strip scrolls horizontally. When false, cards wrap."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged onto the wrapper"

  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper div"

  @doc """
  Renders a horizontal strip of date cards.

  ## Examples

      <.date_strip dates={@dates} selected_date={@selected} on_select="pick_date" today={Date.utc_today()} />
  """
  def date_strip(assigns) do
    ~H"""
    <div
      class={cn([
        "flex gap-2 py-1",
        @scrollable && "overflow-x-auto scrollbar-none",
        !@scrollable && "flex-wrap",
        @class
      ])}
      {@rest}
    >
      <%= for date <- @dates do %>
        <% selected = date == @selected_date
           is_today  = @today != nil && date == @today %>
        <div
          class={cn([
            "flex-shrink-0 flex flex-col items-center justify-center cursor-default",
            card_size_class(@size),
            card_class(selected, is_today)
          ])}
          phx-click={@on_select}
          phx-value-date={@on_select && Date.to_iso8601(date)}
        >
          <span class={cn(["font-bold leading-none", num_size_class(@size)])}>
            {date.day}
          </span>
          <span class={cn(["font-medium mt-1", day_size_class(@size)])}>
            {day_abbr(date)}
          </span>
        </div>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp day_abbr(date), do: Calendar.strftime(date, "%a")

  defp card_class(true, _is_today),
    do: "bg-primary text-primary-foreground border-transparent shadow-md"

  defp card_class(false, true),
    do: "bg-primary/10 text-primary border border-primary/20"

  defp card_class(false, false),
    do: "bg-background border border-border shadow-sm hover:bg-muted/50"

  defp card_size_class(:sm), do: "w-12 h-16 rounded-xl"
  defp card_size_class(:default), do: "w-16 h-20 rounded-2xl"
  defp card_size_class(:lg), do: "w-20 h-24 rounded-2xl"

  defp num_size_class(:sm), do: "text-xl"
  defp num_size_class(:default), do: "text-2xl"
  defp num_size_class(:lg), do: "text-3xl"

  defp day_size_class(:sm), do: "text-[10px]"
  defp day_size_class(:default), do: "text-xs"
  defp day_size_class(:lg), do: "text-sm"
end
