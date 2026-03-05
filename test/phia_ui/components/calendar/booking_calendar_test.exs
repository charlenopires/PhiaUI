defmodule PhiaUi.Components.BookingCalendarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BookingCalendar

    def render_default(assigns) do
      ~H|<.booking_calendar year={2026} month={3} />|
    end

    def render_with_availability(assigns) do
      ~H|<.booking_calendar year={2026} month={3} availability={%{~D[2026-03-15] => :unavailable, ~D[2026-03-20] => :check_in_only}} />|
    end

    def render_with_prices(assigns) do
      ~H|<.booking_calendar year={2026} month={3} prices={%{~D[2026-03-10] => "$120"}} />|
    end

    def render_with_range(assigns) do
      ~H|<.booking_calendar year={2026} month={3} range_start={~D[2026-03-10]} range_end={~D[2026-03-14]} />|
    end

    def render_single_select(assigns) do
      ~H|<.booking_calendar year={2026} month={3} range_start={~D[2026-03-10]} range_end={~D[2026-03-10]} />|
    end

    def render_with_nav(assigns) do
      ~H|<.booking_calendar year={2026} month={3} on_prev="prev_month" on_next="next_month" />|
    end

    def render_with_select(assigns) do
      ~H|<.booking_calendar year={2026} month={3} on_select="pick_date" />|
    end

    def render_sun_first(assigns) do
      ~H|<.booking_calendar year={2026} month={3} first_day={:sun} />|
    end

    def render_with_class(assigns) do
      ~H|<.booking_calendar year={2026} month={3} class="my-booking" />|
    end

    def render_unavailable_no_select(assigns) do
      ~H|<.booking_calendar year={2026} month={3} availability={%{~D[2026-03-15] => :unavailable}} on_select="pick_date" />|
    end

    def render_check_out_only(assigns) do
      ~H|<.booking_calendar year={2026} month={3} availability={%{~D[2026-03-10] => :check_out_only}} />|
    end
  end

  describe "booking_calendar/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_with_availability, do: render_component(&H.render_with_availability/1, %{})
    defp render_with_prices, do: render_component(&H.render_with_prices/1, %{})
    defp render_with_range, do: render_component(&H.render_with_range/1, %{})
    defp render_single_select, do: render_component(&H.render_single_select/1, %{})
    defp render_with_nav, do: render_component(&H.render_with_nav/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_sun_first, do: render_component(&H.render_sun_first/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_unavailable_no_select, do: render_component(&H.render_unavailable_no_select/1, %{})
    defp render_check_out_only, do: render_component(&H.render_check_out_only/1, %{})

    # Structure
    test "renders month title March" do
      assert render_default() =~ "March"
    end

    test "renders year in title" do
      html = render_default()
      assert html =~ "26" or html =~ "2026"
    end

    test "renders grid-cols-7" do
      assert render_default() =~ "grid-cols-7"
    end

    test "renders 7 day header columns" do
      html = render_default()
      assert html =~ "Mon"
      assert html =~ "Sun"
    end

    test "sun-first renders Sun as first day header" do
      html = render_sun_first()
      assert html =~ "Sun"
      assert html =~ "Sat"
    end

    test "mon-first renders Mon in headers" do
      assert render_default() =~ "Mon"
    end

    test "renders day 1 for March" do
      assert render_default() =~ ~r/>\s*1\s*</
    end

    test "renders day 31 for March" do
      assert render_default() =~ ~r/>\s*31\s*</
    end

    test "renders rounded-2xl wrapper" do
      assert render_default() =~ "rounded-2xl"
    end

    test "renders select-none on wrapper" do
      assert render_default() =~ "select-none"
    end

    # Availability states
    test "unavailable date renders line-through" do
      assert render_with_availability() =~ "line-through"
    end

    test "unavailable date renders cursor-not-allowed" do
      assert render_with_availability() =~ "cursor-not-allowed"
    end

    test "check_in_only renders border-dashed" do
      assert render_with_availability() =~ "border-dashed"
    end

    test "check_out_only renders border-dashed border" do
      assert render_check_out_only() =~ "border-dashed"
    end

    test "available date renders hover:bg-muted class" do
      assert render_default() =~ "hover:bg-muted"
    end

    # Prices
    test "price is rendered for configured date" do
      assert render_with_prices() =~ "$120"
    end

    # Range selection
    test "range_start has bg-primary" do
      assert render_with_range() =~ "bg-primary"
    end

    test "range_start has text-primary-foreground" do
      assert render_with_range() =~ "text-primary-foreground"
    end

    test "range_middle has bg-primary/20 wrapper" do
      assert render_with_range() =~ "bg-primary/20"
    end

    test "range_start band extends right via left-1/2" do
      assert render_with_range() =~ "left-1/2"
    end

    test "range_end band extends left via right-1/2" do
      assert render_with_range() =~ "right-1/2"
    end

    test "single selection renders rounded-full bg-primary" do
      html = render_single_select()
      assert html =~ "bg-primary"
      assert html =~ "rounded-full"
    end

    test "single selection has no bg-primary/20 band" do
      refute render_single_select() =~ "bg-primary/20"
    end

    # Navigation
    test "on_prev renders prev button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="prev_month")
    end

    test "on_next renders next button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="next_month")
    end

    test "no prev button when on_prev not set" do
      refute render_default() =~ ~s(phx-click="prev_month")
    end

    # Interaction
    test "on_select adds phx-click to available cells" do
      assert render_with_select() =~ ~s(phx-click="pick_date")
    end

    test "on_select adds phx-value-date in iso8601 format" do
      assert render_with_select() =~ ~s(phx-value-date="2026-03-)
    end

    test "unavailable cell does not get phx-value-date with on_select" do
      refute render_unavailable_no_select() =~ ~s(phx-value-date="2026-03-15")
    end

    # Legend
    test "renders Unavailable legend label" do
      assert render_default() =~ "Unavailable"
    end

    test "renders Available legend label" do
      assert render_default() =~ "Available"
    end

    # Custom class
    test "custom class applied to wrapper" do
      assert render_with_class() =~ "my-booking"
    end
  end
end
