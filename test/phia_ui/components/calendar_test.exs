defmodule PhiaUi.Components.CalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # Fixed month for deterministic tests: January 2024
  # Jan 1, 2024 = Monday, 31 days total

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Calendar

    def render_default(assigns) do
      ~H"""
      <.calendar id="cal" current_month={~D[2024-01-01]} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.calendar id="cal" current_month={~D[2024-01-01]} value={~D[2024-01-15]} />
      """
    end

    def render_with_disabled_dates(assigns) do
      ~H"""
      <.calendar id="cal" current_month={~D[2024-01-01]} disabled_dates={[~D[2024-01-10]]} />
      """
    end

    def render_with_min_max(assigns) do
      ~H"""
      <.calendar
        id="cal"
        current_month={~D[2024-01-01]}
        min={~D[2024-01-05]}
        max={~D[2024-01-25]}
      />
      """
    end

    def render_range_mode(assigns) do
      ~H"""
      <.calendar
        id="cal"
        current_month={~D[2024-01-01]}
        mode="range"
        range_start={~D[2024-01-10]}
        range_end={~D[2024-01-20]}
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.calendar id="cal" current_month={~D[2024-01-01]} class="custom-class" />
      """
    end

    def render_with_on_change(assigns) do
      ~H"""
      <.calendar id="cal" current_month={~D[2024-01-01]} on_change="date-selected" />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Grid structure
  # ---------------------------------------------------------------------------

  describe "grid structure" do
    test "renders role=grid" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="grid")
    end

    test "renders role=gridcell on date cells" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="gridcell")
    end

    test "renders 7 day headers" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Su"
      assert html =~ "Mo"
      assert html =~ "Tu"
      assert html =~ "We"
      assert html =~ "Th"
      assert html =~ "Fr"
      assert html =~ "Sa"
    end

    test "renders all days of January 2024" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~r/>\s*1\s*</
      assert html =~ ~r/>\s*15\s*</
      assert html =~ ~r/>\s*31\s*</
    end
  end

  # ---------------------------------------------------------------------------
  # Month/year header
  # ---------------------------------------------------------------------------

  describe "month header" do
    test "renders month and year label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "January 2024"
    end

    test "renders previous month navigation button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "calendar-prev-month"
    end

    test "renders next month navigation button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "calendar-next-month"
    end

    test "prev button carries phx-value-month with previous month ISO date" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-value-month="2023-12-01")
    end

    test "next button carries phx-value-month with next month ISO date" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-value-month="2024-02-01")
    end
  end

  # ---------------------------------------------------------------------------
  # Hook
  # ---------------------------------------------------------------------------

  describe "PhiaCalendar hook" do
    test "root element uses PhiaCalendar hook" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "PhiaCalendar"
    end

    test "root element has the given id" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="cal")
    end
  end

  # ---------------------------------------------------------------------------
  # Single mode — value selection
  # ---------------------------------------------------------------------------

  describe "single mode selection" do
    test "selected date has aria-selected=true" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(aria-selected="true")
    end

    test "selected date cell has bg-primary class" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "bg-primary"
    end

    test "non-selected dates do not have aria-selected=true" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ ~s(aria-selected="true")
    end

    test "day buttons fire the on_change event with phx-value-date" do
      html = render_component(&H.render_with_on_change/1, %{})
      assert html =~ ~s(phx-click="date-selected")
      assert html =~ "phx-value-date"
    end

    test "phx-value-date contains ISO 8601 date string" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-value-date="2024-01-01")
    end
  end

  # ---------------------------------------------------------------------------
  # Disabled dates
  # ---------------------------------------------------------------------------

  describe "disabled dates" do
    test "disabled_dates list marks cell with pointer-events-none" do
      html = render_component(&H.render_with_disabled_dates/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "disabled_dates list marks cell with opacity class" do
      html = render_component(&H.render_with_disabled_dates/1, %{})
      assert html =~ "opacity-"
    end

    test "days before min have aria-disabled=true" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(aria-disabled="true")
    end

    test "days after max have aria-disabled=true" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(aria-disabled="true")
    end

    test "day button within min/max range is not disabled" do
      html = render_component(&H.render_with_min_max/1, %{})
      # Jan 15 is within [Jan 5, Jan 25] — should not be disabled
      # The button for Jan 15 should NOT carry the disabled attr right before its day number
      # We check that aria-disabled=false appears (for in-range days)
      assert html =~ ~s(aria-disabled="false")
    end
  end

  # ---------------------------------------------------------------------------
  # Range mode
  # ---------------------------------------------------------------------------

  describe "range mode" do
    test "in-range days have bg-accent highlight" do
      html = render_component(&H.render_range_mode/1, %{})
      assert html =~ "bg-accent"
    end

    test "range start has aria-selected=true" do
      html = render_component(&H.render_range_mode/1, %{})
      assert html =~ ~s(aria-selected="true")
    end

    test "range end has aria-selected=true" do
      html = render_component(&H.render_range_mode/1, %{})
      assert html =~ ~s(aria-selected="true")
    end
  end

  # ---------------------------------------------------------------------------
  # Outside-month days
  # ---------------------------------------------------------------------------

  describe "outside month days" do
    test "cells outside the displayed month have muted-foreground opacity" do
      html = render_component(&H.render_default/1, %{})
      # Outside month days rendered with opacity-50 + text-muted-foreground
      assert html =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # CSS class override
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "accepts additional class via :class attr" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-class"
    end
  end
end
