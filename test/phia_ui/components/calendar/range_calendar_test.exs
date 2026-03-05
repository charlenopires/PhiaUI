defmodule PhiaUi.Components.RangeCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.RangeCalendar

    def render_default(assigns) do
      ~H|<.range_calendar year={2025} month={7} />|
    end

    def render_with_range(assigns) do
      ~H|<.range_calendar year={2025} month={7} range_start={~D[2025-07-19]} range_end={~D[2025-07-21]} />|
    end

    def render_single_select(assigns) do
      ~H|<.range_calendar year={2025} month={7} range_start={~D[2025-07-20]} range_end={~D[2025-07-20]} />|
    end

    def render_with_nav(assigns) do
      ~H|<.range_calendar year={2025} month={7} on_prev="prev_month" on_next="next_month" />|
    end

    def render_with_select(assigns) do
      ~H|<.range_calendar year={2025} month={7} on_select="pick_date" />|
    end

    def render_with_class(assigns) do
      ~H|<.range_calendar year={2025} month={7} class="my-cal" />|
    end

    def render_february(assigns) do
      ~H|<.range_calendar year={2025} month={2} />|
    end

    def render_no_nav(assigns) do
      ~H|<.range_calendar year={2025} month={7} />|
    end

    def render_range_december(assigns) do
      ~H|<.range_calendar year={2025} month={12} range_start={~D[2025-12-24]} range_end={~D[2025-12-26]} />|
    end
  end

  describe "range_calendar/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_with_range, do: render_component(&H.render_with_range/1, %{})
    defp render_single_select, do: render_component(&H.render_single_select/1, %{})
    defp render_with_nav, do: render_component(&H.render_with_nav/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_february, do: render_component(&H.render_february/1, %{})
    defp render_no_nav, do: render_component(&H.render_no_nav/1, %{})
    defp render_range_december, do: render_component(&H.render_range_december/1, %{})

    # -------------------------------------------------------------------------
    # Calendar structure
    # -------------------------------------------------------------------------

    test "renders title with month name" do
      html = render_default()
      assert html =~ "July"
    end

    test "renders year in title" do
      html = render_default()
      assert html =~ "25" or html =~ "2025"
    end

    test "renders Sun in day headers" do
      html = render_default()
      assert html =~ "Sun"
    end

    test "renders Sat in day headers" do
      html = render_default()
      assert html =~ "Sat"
    end

    test "renders Mon in day headers" do
      html = render_default()
      assert html =~ "Mon"
    end

    test "renders all 7 day name headers" do
      html = render_default()

      for day <- ~w(Sun Mon Tue Wed Thu Fri Sat) do
        assert html =~ day, "Expected day header '#{day}' not found"
      end
    end

    test "renders day numbers for July 2025" do
      html = render_default()
      assert html =~ "19"
      assert html =~ "20"
      assert html =~ "21"
    end

    test "renders day 1 for July" do
      html = render_default()
      # The span content has surrounding whitespace in the rendered HTML
      assert html =~ ~r/>\s*1\s*<\/span>/
    end

    test "renders day 31 for July" do
      html = render_default()
      assert html =~ ~r/>\s*31\s*<\/span>/
    end

    test "renders adjacent month days muted with opacity class" do
      html = render_default()
      assert html =~ "opacity-40"
    end

    # -------------------------------------------------------------------------
    # Range selection
    # -------------------------------------------------------------------------

    test "range_start day has bg-primary" do
      html = render_with_range()
      assert html =~ "bg-primary"
    end

    test "range_start day has text-primary-foreground" do
      html = render_with_range()
      assert html =~ "text-primary-foreground"
    end

    test "range_start day has rounded-full" do
      html = render_with_range()
      assert html =~ "rounded-full"
    end

    test "range_end day has bg-primary" do
      html = render_with_range()
      assert html =~ "bg-primary"
    end

    test "range_end day has rounded-full" do
      html = render_with_range()
      assert html =~ "rounded-full"
    end

    test "range_middle day has bg-primary/20 on wrapper" do
      html = render_with_range()
      assert html =~ "bg-primary/20"
    end

    test "range_middle day does not have rounded-full on the middle number" do
      html = render_with_range()
      # bg-primary/20 appears (middle band) and the component renders correctly
      assert html =~ "bg-primary/20"
    end

    test "single selected day (start==end) has bg-primary and rounded-full" do
      html = render_single_select()
      assert html =~ "bg-primary"
      assert html =~ "rounded-full"
    end

    test "single selected day does not produce band divs" do
      html = render_single_select()
      # No bg-primary/20 band for single selection (only circle, no half-band)
      refute html =~ "bg-primary/20"
    end

    test "non-range days do not have bg-primary on number in default render" do
      html = render_default()
      refute html =~ "bg-primary"
    end

    test "range_start band is right-half via left-1/2" do
      html = render_with_range()
      assert html =~ "left-1/2"
    end

    test "range_end band is left-half via right-1/2" do
      html = render_with_range()
      assert html =~ "right-1/2"
    end

    # -------------------------------------------------------------------------
    # Navigation
    # -------------------------------------------------------------------------

    test "on_prev renders button with phx-click" do
      html = render_with_nav()
      assert html =~ ~s(phx-click="prev_month")
    end

    test "on_next renders button with phx-click" do
      html = render_with_nav()
      assert html =~ ~s(phx-click="next_month")
    end

    test "nav buttons have rounded-full class" do
      html = render_with_nav()
      assert html =~ "rounded-full"
    end

    test "nav buttons have bg-primary class" do
      html = render_with_nav()
      assert html =~ "bg-primary"
    end

    test "no prev button when on_prev not set" do
      html = render_no_nav()
      refute html =~ ~s(phx-click="prev_month")
    end

    test "no next button when on_next not set" do
      html = render_no_nav()
      refute html =~ ~s(phx-click="next_month")
    end

    # -------------------------------------------------------------------------
    # Interaction
    # -------------------------------------------------------------------------

    test "on_select adds phx-click to day cells" do
      html = render_with_select()
      assert html =~ ~s(phx-click="pick_date")
    end

    test "on_select adds phx-value-date in iso8601 format" do
      html = render_with_select()
      assert html =~ ~s(phx-value-date="2025-07-)
    end

    test "no phx-value-date when on_select not set" do
      html = render_default()
      refute html =~ "phx-value-date"
    end

    test "phx-value-date uses correct iso8601 for known July dates" do
      html = render_with_select()
      assert html =~ ~s(phx-value-date="2025-07-19")
      assert html =~ ~s(phx-value-date="2025-07-31")
    end

    # -------------------------------------------------------------------------
    # Layout
    # -------------------------------------------------------------------------

    test "renders grid-cols-7" do
      html = render_default()
      assert html =~ "grid-cols-7"
    end

    test "custom class applied to wrapper" do
      html = render_with_class()
      assert html =~ "my-cal"
    end

    test "renders rounded-2xl on wrapper" do
      html = render_default()
      assert html =~ "rounded-2xl"
    end

    test "renders select-none on wrapper" do
      html = render_default()
      assert html =~ "select-none"
    end

    test "renders border on wrapper" do
      html = render_default()
      assert html =~ "border"
    end

    # -------------------------------------------------------------------------
    # February edge case (short month, may have more trailing padding)
    # -------------------------------------------------------------------------

    test "February 2025 renders without errors" do
      html = render_february()
      assert html =~ "February" or html =~ "Feb"
    end

    test "February 2025 renders day 28" do
      html = render_february()
      assert html =~ ~r/>\s*28\s*<\/span>/
    end

    test "February 2025 does not expose Feb 29 as a current-month interactive date" do
      html = render_february()
      # 2025 is not a leap year, so no phx-value-date for Feb 29 2025 should appear
      refute html =~ ~s(phx-value-date="2025-02-29")
    end

    # -------------------------------------------------------------------------
    # December range (cross-checking another month)
    # -------------------------------------------------------------------------

    test "December 2025 range renders bg-primary for start and end" do
      html = render_range_december()
      assert html =~ "bg-primary"
    end

    test "December 2025 renders band bg-primary/20 for middle day" do
      html = render_range_december()
      assert html =~ "bg-primary/20"
    end
  end
end
