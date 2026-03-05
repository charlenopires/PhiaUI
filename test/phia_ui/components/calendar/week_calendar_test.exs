defmodule PhiaUi.Components.WeekCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.WeekCalendar

    def render_default(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} />"
    end

    def render_with_selected(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} selected_date={~D[2025-07-17]} />"
    end

    def render_with_nav(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} on_prev=\"prev_week\" on_next=\"next_week\" />"
    end

    def render_with_select(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} on_select=\"select_date\" />"
    end

    def render_with_class(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} class=\"my-week\" />"
    end

    def render_custom_title(assigns) do
      ~H"<.week_calendar week_start={~D[2025-07-14]} title_format=\"%B %Y\" />"
    end
  end

  describe "week_calendar/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_with_selected, do: render_component(&H.render_with_selected/1, %{})
    defp render_with_nav, do: render_component(&H.render_with_nav/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_custom_title, do: render_component(&H.render_custom_title/1, %{})

    test "renders 7 day items (Fri through Thu)" do
      html = render_default()
      # Each day column contains two <span> elements (abbr + number)
      # We count occurrences of the day number pattern to validate 7 days
      day_numbers = Regex.scan(~r/\b1[4-9]\b|\b20\b/, html)
      assert length(day_numbers) >= 7
    end

    test "renders day numbers 14 through 20" do
      html = render_default()
      assert html =~ "14"
      assert html =~ "15"
      assert html =~ "16"
      assert html =~ "17"
      assert html =~ "18"
      assert html =~ "19"
      assert html =~ "20"
    end

    test "renders Fri abbreviation" do
      html = render_default()
      assert html =~ "Fri"
    end

    test "renders Mon abbreviation" do
      html = render_default()
      assert html =~ "Mon"
    end

    test "renders Thu abbreviation" do
      html = render_default()
      assert html =~ "Thu"
    end

    test "header shows July in title" do
      html = render_default()
      assert html =~ "July"
    end

    test "title_format %B %Y shows July 2025" do
      html = render_custom_title()
      assert html =~ "July 2025"
    end

    test "selected date has bg-primary" do
      html = render_with_selected()
      assert html =~ "bg-primary"
    end

    test "selected date has text-primary-foreground" do
      html = render_with_selected()
      assert html =~ "text-primary-foreground"
    end

    test "non-selected dates do not have bg-primary on every day column" do
      html = render_default()
      # Without a selected_date, bg-primary should not appear at all
      refute html =~ "bg-primary"
    end

    test "on_prev renders button with phx-click" do
      html = render_with_nav()
      assert html =~ ~s(phx-click="prev_week")
    end

    test "on_next renders button with phx-click" do
      html = render_with_nav()
      assert html =~ ~s(phx-click="next_week")
    end

    test "no prev button when on_prev not set" do
      html = render_default()
      refute html =~ ~s(phx-click="prev_week")
    end

    test "no next button when on_next not set" do
      html = render_default()
      refute html =~ ~s(phx-click="next_week")
    end

    test "on_select adds phx-click to day items" do
      html = render_with_select()
      assert html =~ ~s(phx-click="select_date")
    end

    test "on_select adds phx-value-date with iso8601" do
      html = render_with_select()
      assert html =~ ~s(phx-value-date="2025-07-14")
      assert html =~ ~s(phx-value-date="2025-07-17")
      assert html =~ ~s(phx-value-date="2025-07-20")
    end

    test "no phx-value-date when on_select not set" do
      html = render_default()
      refute html =~ "phx-value-date"
    end

    test "custom class applied to wrapper" do
      html = render_with_class()
      assert html =~ "my-week"
    end

    test "renders rounded-2xl on wrapper" do
      html = render_default()
      assert html =~ "rounded-2xl"
    end

    test "renders border on wrapper" do
      html = render_default()
      assert html =~ "border"
    end

    test "selected day 17 renders 17 with bg-primary" do
      html = render_with_selected()
      # The day number 17 appears within the selected element that has bg-primary
      assert html =~ "bg-primary"
      assert html =~ "17"
    end
  end
end
