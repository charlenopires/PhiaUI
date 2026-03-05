defmodule PhiaUi.Components.MultiSelectCalendarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MultiSelectCalendar

    def render_default(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1} />
      """
    end

    def render_with_selected(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1}
        selected_dates={[~D[2026-01-12], ~D[2026-01-19], ~D[2026-01-26]]}
      />
      """
    end

    def render_with_on_select(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1} on_select="toggle_date" />
      """
    end

    def render_with_nav(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1}
        on_prev="prev_month" on_next="next_month"
      />
      """
    end

    def render_with_selects(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1}
        on_month_change="month_changed" on_year_change="year_changed"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.multi_select_calendar year={2026} month={1} class="my-cal" />
      """
    end
  end

  describe "multi_select_calendar/1 — column headers" do
    test "renders Sun in column headers (SUN-first)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Sun"
    end

    test "renders Sat in column headers" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Sat"
    end

    test "renders all 7 day name headers" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Sun"
      assert html =~ "Mon"
      assert html =~ "Tue"
      assert html =~ "Wed"
      assert html =~ "Thu"
      assert html =~ "Fri"
      assert html =~ "Sat"
    end
  end

  describe "multi_select_calendar/1 — day numbers" do
    test "renders January day numbers 1 through 31" do
      html = render_component(&H.render_default/1, %{})
      # All 31 days of January must appear as day numbers (allow surrounding whitespace)
      for day <- 1..31 do
        assert html =~ ~r/>\s*#{day}\s*</, "Expected day #{day} to appear in rendered output"
      end
    end
  end

  describe "multi_select_calendar/1 — title" do
    test "renders title with month name January" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "January"
    end

    test "renders year 2026 in title" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "2026"
    end
  end

  describe "multi_select_calendar/1 — selected dates" do
    test "selected dates have bg-primary/20 class" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "bg-primary/20"
    end

    test "selected dates have text-primary class" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "text-primary"
    end

    test "selected dates have font-semibold class" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "font-semibold"
    end

    test "non-selected current dates do not have bg-primary/20" do
      # With no selected dates the class should not appear
      html = render_component(&H.render_default/1, %{})
      refute html =~ "bg-primary/20"
    end

    test "multiple selected dates all render — day 12, 19, 26 present" do
      html = render_component(&H.render_with_selected/1, %{})
      # bg-primary/20 appears once per selected date — verify at least 3 occurrences
      count = html |> String.split("bg-primary/20") |> length() |> Kernel.-(1)
      assert count >= 3, "Expected at least 3 occurrences of bg-primary/20, got #{count}"
    end
  end

  describe "multi_select_calendar/1 — on_select" do
    test "on_select adds phx-click to day cells" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-click="toggle_date")
    end

    test "on_select adds phx-value-date in ISO 8601 format" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-value-date="2026-01-01")
    end

    test "no phx-value-date when on_select not set" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "phx-value-date"
    end
  end

  describe "multi_select_calendar/1 — navigation" do
    test "on_prev renders button with phx-click" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-click="prev_month")
    end

    test "on_next renders button with phx-click" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-click="next_month")
    end
  end

  describe "multi_select_calendar/1 — month/year selects" do
    test "on_month_change renders select element with phx-change" do
      html = render_component(&H.render_with_selects/1, %{})
      assert html =~ ~s(phx-change="month_changed")
    end

    test "on_year_change renders select element with phx-change" do
      html = render_component(&H.render_with_selects/1, %{})
      assert html =~ ~s(phx-change="year_changed")
    end

    test "month select has option selected for current month (January = 1)" do
      html = render_component(&H.render_with_selects/1, %{})
      # The option for month 1 should have selected attribute
      assert html =~ ~s(selected)
      assert html =~ "January"
    end
  end

  describe "multi_select_calendar/1 — adjacent month days" do
    test "adjacent month days have opacity-40 class" do
      html = render_component(&H.render_default/1, %{})
      # January 2026 starts on Thursday, so there are leading days from December
      assert html =~ "opacity-40"
    end
  end

  describe "multi_select_calendar/1 — custom class" do
    test "custom class is applied to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-cal"
    end
  end

  describe "multi_select_calendar/1 — grid layout" do
    test "renders grid-cols-7 for the day grid" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "grid-cols-7"
    end
  end
end
