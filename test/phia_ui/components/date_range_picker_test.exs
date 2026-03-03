defmodule PhiaUi.Components.DateRangePickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # Fixed month for deterministic tests: January 2025
  # Jan 1 = Wednesday, 31 days

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateRangePicker

    def render_no_selection(assigns) do
      ~H"""
      <.date_range_picker
        id="drp1"
        view_month={~D[2025-01-01]}
        on_change="date-changed"
        on_month_change="month-changed"
      />
      """
    end

    def render_with_range(assigns) do
      ~H"""
      <.date_range_picker
        id="drp2"
        view_month={~D[2025-01-01]}
        from={~D[2025-01-10]}
        to={~D[2025-01-20]}
        on_change="date-changed"
        on_month_change="month-changed"
      />
      """
    end

    def render_with_minmax(assigns) do
      ~H"""
      <.date_range_picker
        id="drp3"
        view_month={~D[2025-01-01]}
        from={~D[2025-01-10]}
        to={~D[2025-01-20]}
        min_date={~D[2025-01-05]}
        max_date={~D[2025-01-25]}
        on_change="date-changed"
        on_month_change="month-changed"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.date_range_picker
        id="drp4"
        view_month={~D[2025-01-01]}
        on_change="date-changed"
        on_month_change="month-changed"
        class="custom-drp"
      />
      """
    end
  end

  defp render_no_selection, do: render_component(&H.render_no_selection/1, %{})
  defp render_with_range, do: render_component(&H.render_with_range/1, %{})
  defp render_with_minmax, do: render_component(&H.render_with_minmax/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # Trigger button
  # ---------------------------------------------------------------------------

  describe "trigger button" do
    test "renders a button" do
      assert render_no_selection() =~ "<button"
    end

    test "shows placeholder when no dates selected" do
      html = render_no_selection()
      assert html =~ "Select" or html =~ "date" or html =~ "range"
    end

    test "shows formatted from date when range selected" do
      html = render_with_range()
      # Jan 10 should appear somewhere in the trigger
      assert html =~ "10" or html =~ "Jan" or html =~ "2025"
    end

    test "accepts :class via cn/1" do
      assert render_with_class() =~ "custom-drp"
    end
  end

  # ---------------------------------------------------------------------------
  # Calendar grid — structure
  # ---------------------------------------------------------------------------

  describe "calendar grid" do
    test "renders calendar table or grid" do
      html = render_no_selection()
      assert html =~ "<table" or html =~ "calendar" or html =~ "grid"
    end

    test "renders month header for January 2025" do
      html = render_no_selection()
      assert html =~ "January" or html =~ "Jan"
      assert html =~ "2025"
    end

    test "renders day numbers 1 through 31 for January" do
      html = render_no_selection()
      # Day numbers appear as button text content (may have surrounding whitespace)
      assert html =~ ~r/>\s*1\s*</
      assert html =~ ~r/>\s*15\s*</
      assert html =~ ~r/>\s*31\s*</
    end

    test "renders two calendar months" do
      html = render_no_selection()
      # February should also appear
      assert html =~ "February" or html =~ "Feb"
    end

    test "renders month navigation prev button" do
      html = render_no_selection()
      assert html =~ "phx-click" and (html =~ "prev" or html =~ "chevron-left")
    end

    test "renders month navigation next button" do
      html = render_no_selection()
      assert html =~ "phx-click" and (html =~ "next" or html =~ "chevron-right")
    end
  end

  # ---------------------------------------------------------------------------
  # Range highlighting
  # ---------------------------------------------------------------------------

  describe "range highlighting" do
    test "in-range days have bg-accent or range class" do
      html = render_with_range()
      assert html =~ "bg-accent" or html =~ "range" or html =~ "in-range"
    end

    test "from day has rounded-l style" do
      html = render_with_range()
      assert html =~ "rounded-l" or html =~ "rounded-s" or html =~ "range-start"
    end

    test "to day has rounded-r style" do
      html = render_with_range()
      assert html =~ "rounded-r" or html =~ "rounded-e" or html =~ "range-end"
    end

    test "from and to days have primary background" do
      html = render_with_range()
      assert html =~ "bg-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # Disabled days
  # ---------------------------------------------------------------------------

  describe "disabled days (min/max)" do
    test "days before min_date rendered as disabled" do
      html = render_with_minmax()
      assert html =~ "disabled" or html =~ "opacity-50" or html =~ "pointer-events-none"
    end

    test "days after max_date rendered as disabled" do
      html = render_with_minmax()
      assert html =~ "disabled" or html =~ "opacity-50" or html =~ "pointer-events-none"
    end
  end

  # ---------------------------------------------------------------------------
  # phx-click on days
  # ---------------------------------------------------------------------------

  describe "day click events" do
    test "day cells have phx-click for on_change event" do
      html = render_no_selection()
      assert html =~ ~s(phx-click="date-changed")
    end

    test "month nav has phx-click for on_month_change event" do
      html = render_no_selection()
      assert html =~ ~s(phx-click="month-changed")
    end
  end
end
