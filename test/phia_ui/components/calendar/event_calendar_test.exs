defmodule PhiaUi.Components.EventCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.EventCalendar

    def render_default(assigns) do
      ~H"""
      <.event_calendar />
      """
    end

    def render_march2026(assigns) do
      ~H"""
      <.event_calendar year={2026} month={3} />
      """
    end

    def render_jan2026(assigns) do
      ~H"""
      <.event_calendar year={2026} month={1} />
      """
    end

    def render_dec2025(assigns) do
      ~H"""
      <.event_calendar year={2025} month={12} />
      """
    end

    def render_with_navigate(assigns) do
      ~H"""
      <.event_calendar year={2026} month={3} on_navigate="navigate_month" />
      """
    end

    def render_with_day_click(assigns) do
      ~H"""
      <.event_calendar year={2026} month={3} on_day_click="select_day" />
      """
    end

    def render_with_events(assigns) do
      ~H"""
      <.event_calendar
        year={2026}
        month={3}
        events={[
          %{date: ~D[2026-03-15], label: "Team Meeting", color: "blue"},
          %{date: ~D[2026-03-20], label: "Deploy", color: "green"}
        ]}
      />
      """
    end

    def render_with_event_click(assigns) do
      ~H"""
      <.event_calendar
        year={2026}
        month={3}
        on_event_click="show_event"
        events={[%{date: ~D[2026-03-15], label: "Team Meeting", color: "blue"}]}
      />
      """
    end

    def render_red_event(assigns) do
      ~H"""
      <.event_calendar
        year={2026}
        month={3}
        events={[%{date: ~D[2026-03-10], label: "Alert", color: "red"}]}
      />
      """
    end

    def render_default_color_event(assigns) do
      ~H"""
      <.event_calendar
        year={2026}
        month={3}
        events={[%{date: ~D[2026-03-10], label: "Other"}]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.event_calendar year={2026} month={3} class="my-calendar-class" />
      """
    end
  end

  describe "event_calendar/1" do
    test "renders month name in header" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ "March"
    end

    test "renders year in header" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ "2026"
    end

    test "renders Sun day header" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ "Sun"
    end

    test "renders Mon day header" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ "Mon"
    end

    test "renders Sat day header" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ "Sat"
    end

    test "renders role=grid" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(role="grid")
    end

    test "renders role=gridcell" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(role="gridcell")
    end

    test "renders role=columnheader for day names" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(role="columnheader")
    end

    test "month grid has at least 35 gridcells" do
      html = render_component(&H.render_march2026/1, %{})
      count = length(String.split(html, ~s(role="gridcell"))) - 1
      assert count >= 35
    end

    test "today has aria-current=date" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-current="date")
    end

    test "renders prev navigation button with aria-label" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(aria-label="Previous month")
    end

    test "renders next navigation button with aria-label" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(aria-label="Next month")
    end

    test "prev button has phx-value-month for February" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(phx-value-month="2")
    end

    test "prev button has phx-value-year" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(phx-value-year="2026")
    end

    test "next button has phx-value-month for April" do
      html = render_component(&H.render_march2026/1, %{})
      assert html =~ ~s(phx-value-month="4")
    end

    test "prev from January wraps to December of previous year" do
      html = render_component(&H.render_jan2026/1, %{})
      assert html =~ ~s(phx-value-month="12")
      assert html =~ ~s(phx-value-year="2025")
    end

    test "next from December wraps to January of next year" do
      html = render_component(&H.render_dec2025/1, %{})
      assert html =~ ~s(phx-value-month="1")
      assert html =~ ~s(phx-value-year="2026")
    end

    test "on_navigate fires phx-click on nav buttons" do
      html = render_component(&H.render_with_navigate/1, %{})
      assert html =~ ~s(phx-click="navigate_month")
    end

    test "without on_navigate nav buttons have no phx-click" do
      html = render_component(&H.render_march2026/1, %{})
      refute html =~ ~s(phx-click=)
    end

    test "on_day_click applies phx-click to day cells" do
      html = render_component(&H.render_with_day_click/1, %{})
      assert html =~ ~s(phx-click="select_day")
    end

    test "day cell has phx-value-date when on_day_click set" do
      html = render_component(&H.render_with_day_click/1, %{})
      assert html =~ ~s(phx-value-date="2026-03-01")
    end

    test "renders event label" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "Team Meeting"
    end

    test "event color blue renders bg-blue-500 dot" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-blue-500"
    end

    test "event color green renders bg-green-500 dot" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-green-500"
    end

    test "event color red renders bg-red-500 dot" do
      html = render_component(&H.render_red_event/1, %{})
      assert html =~ "bg-red-500"
    end

    test "multiple events rendered in same month" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "Team Meeting"
      assert html =~ "Deploy"
    end

    test "event with no color uses default dot class" do
      html = render_component(&H.render_default_color_event/1, %{})
      assert html =~ "bg-primary"
    end

    test "on_event_click applies phx-click to event badges" do
      html = render_component(&H.render_with_event_click/1, %{})
      assert html =~ ~s(phx-click="show_event")
    end

    test "event badge has phx-value-label" do
      html = render_component(&H.render_with_event_click/1, %{})
      assert html =~ ~s(phx-value-label="Team Meeting")
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-calendar-class"
    end

    test "December header shows December" do
      html = render_component(&H.render_dec2025/1, %{})
      assert html =~ "December"
      assert html =~ "2025"
    end
  end
end
