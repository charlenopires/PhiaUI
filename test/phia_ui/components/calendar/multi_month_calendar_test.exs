defmodule PhiaUi.Components.MultiMonthCalendarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MultiMonthCalendar

    def render_default(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} />|
    end

    def render_3months(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} months_count={3} />|
    end

    def render_with_range(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} range_start={~D[2026-03-20]} range_end={~D[2026-04-10]} />|
    end

    def render_single_select(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} range_start={~D[2026-03-15]} range_end={~D[2026-03-15]} />|
    end

    def render_with_nav(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} on_prev="prev" on_next="next" />|
    end

    def render_with_select(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} on_select="pick_date" />|
    end

    def render_mon_first(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} first_day={:mon} />|
    end

    def render_with_class(assigns) do
      ~H|<.multi_month_calendar year={2026} month={3} class="my-multi" />|
    end

    def render_year_boundary(assigns) do
      ~H|<.multi_month_calendar year={2025} month={12} months_count={2} />|
    end
  end

  describe "multi_month_calendar/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_3months, do: render_component(&H.render_3months/1, %{})
    defp render_with_range, do: render_component(&H.render_with_range/1, %{})
    defp render_single_select, do: render_component(&H.render_single_select/1, %{})
    defp render_with_nav, do: render_component(&H.render_with_nav/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_mon_first, do: render_component(&H.render_mon_first/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_year_boundary, do: render_component(&H.render_year_boundary/1, %{})

    # Structure
    test "renders first month title March" do
      assert render_default() =~ "March"
    end

    test "renders second month title April for 2-month view" do
      assert render_default() =~ "April"
    end

    test "renders 3 months with months_count=3" do
      html = render_3months()
      assert html =~ "March"
      assert html =~ "April"
      assert html =~ "May"
    end

    test "renders grid-cols-7 for day cells" do
      assert render_default() =~ "grid-cols-7"
    end

    test "renders select-none on wrapper" do
      assert render_default() =~ "select-none"
    end

    test "renders rounded-2xl wrapper" do
      assert render_default() =~ "rounded-2xl"
    end

    # Day headers
    test "sun-first renders Sun in headers" do
      assert render_default() =~ "Sun"
    end

    test "mon-first renders Mon as first header" do
      assert render_mon_first() =~ "Mon"
    end

    test "renders all 7 day name headers for first month" do
      html = render_default()
      for day <- ~w(Sun Mon Tue Wed Thu Fri Sat) do
        assert html =~ day
      end
    end

    # Day numbers
    test "renders day 31 for March" do
      assert render_default() =~ ~r/>\s*31\s*</
    end

    test "renders day 1 for March" do
      assert render_default() =~ ~r/>\s*1\s*</
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

    test "range_start band has left-1/2" do
      assert render_with_range() =~ "left-1/2"
    end

    test "range_end band has right-1/2" do
      assert render_with_range() =~ "right-1/2"
    end

    test "cross-month range: start in March, end in April" do
      html = render_with_range()
      # Both months render — March has range_start, April has range_end
      assert html =~ "bg-primary"
      assert html =~ "bg-primary/20"
    end

    test "single selection has bg-primary and rounded-full" do
      html = render_single_select()
      assert html =~ "bg-primary"
      assert html =~ "rounded-full"
    end

    test "single selection has no bg-primary/20 band" do
      refute render_single_select() =~ "bg-primary/20"
    end

    # Navigation
    test "on_prev renders prev button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="prev")
    end

    test "on_next renders next button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="next")
    end

    test "no prev button when on_prev not set" do
      refute render_default() =~ ~s(phx-click="prev")
    end

    # Interaction
    test "on_select adds phx-click to day cells" do
      assert render_with_select() =~ ~s(phx-click="pick_date")
    end

    test "on_select adds phx-value-date in iso8601 format" do
      assert render_with_select() =~ ~s(phx-value-date="2026-03-)
    end

    # Custom class
    test "custom class applied to wrapper" do
      assert render_with_class() =~ "my-multi"
    end

    # Year boundary
    test "December 2025 + 2 months crosses year boundary" do
      html = render_year_boundary()
      assert html =~ "December" or html =~ "Dec"
      assert html =~ "January" or html =~ "Jan"
    end
  end
end
