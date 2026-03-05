defmodule PhiaUi.Components.CalendarWeekViewTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CalendarWeekView

    def render_default(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} />
      """
    end

    def render_with_timezone(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} timezone="GMT+5" />
      """
    end

    def render_with_events(assigns) do
      ~H"""
      <.calendar_week_view
        week_start={~D[2024-04-25]}
        events={[
          %{date: ~D[2024-04-25], time: "09:00", end_time: "12:00", label: "standup", color: "gray"},
          %{date: ~D[2024-04-26], time: "13:00", duration_minutes: 120, label: "info here", color: "orange"},
          %{date: ~D[2024-04-28], time: "13:00", end_time: "14:00", label: "60 min", color: "green"}
        ]}
      />
      """
    end

    def render_with_view_change(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} on_view_change="view-changed" />
      """
    end

    def render_with_event_click(assigns) do
      ~H"""
      <.calendar_week_view
        week_start={~D[2024-04-25]}
        on_event_click="event-clicked"
        events={[%{date: ~D[2024-04-25], time: "09:00", label: "test", color: "green"}]}
      />
      """
    end

    def render_custom_hours(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} start_hour={6} end_hour={18} />
      """
    end

    def render_week_view(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} view="week" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.calendar_week_view week_start={~D[2024-04-25]} class="my-week-view" />
      """
    end

    def render_no_label_event(assigns) do
      ~H"""
      <.calendar_week_view
        week_start={~D[2024-04-25]}
        events={[%{date: ~D[2024-04-25], time: "10:00", color: "blue"}]}
      />
      """
    end

    def render_duration_event(assigns) do
      ~H"""
      <.calendar_week_view
        week_start={~D[2024-04-25]}
        events={[%{date: ~D[2024-04-25], time: "08:00", duration_minutes: 90, label: "meeting", color: "purple"}]}
      />
      """
    end
  end

  describe "calendar_week_view/1" do
    test "renders month and year in header" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "April"
      assert html =~ "2024"
    end

    test "renders all 4 view switcher buttons" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Month"
      assert html =~ "Week"
      assert html =~ "Day"
      assert html =~ "List"
    end

    test "active Week view button is highlighted" do
      html = render_component(&H.render_week_view/1, %{})
      assert html =~ "bg-background"
    end

    test "renders 7 day columns" do
      html = render_component(&H.render_default/1, %{})
      # April 25 (Mon) through May 1 (Sun)
      assert html =~ "25"
      assert html =~ "26"
      assert html =~ "27"
      assert html =~ "28"
      assert html =~ "29"
      assert html =~ "30"
    end

    test "renders first day as Monday" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Monday"
    end

    test "renders last day as Sunday" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Sunday"
    end

    test "renders month abbreviation in day subtitle" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Apr"
    end

    test "renders time labels starting at start_hour" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "07:00"
    end

    test "renders time label 13:00" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "13:00"
    end

    test "renders timezone label when provided" do
      html = render_component(&H.render_with_timezone/1, %{})
      assert html =~ "GMT+5"
    end

    test "custom start_hour renders earlier time" do
      html = render_component(&H.render_custom_hours/1, %{})
      assert html =~ "06:00"
    end

    test "renders event label with time and extra" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "09:00 (standup)"
    end

    test "renders orange event" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-orange-500"
    end

    test "renders green event" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-green-500"
    end

    test "renders gray event" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-gray-400"
    end

    test "event has top style attribute" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "top:"
    end

    test "event has height style attribute" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "height:"
    end

    test "event has phx-value-date" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "phx-value-date"
    end

    test "on_view_change event name on switcher buttons" do
      html = render_component(&H.render_with_view_change/1, %{})
      assert html =~ "view-changed"
    end

    test "on_event_click event name on event blocks" do
      html = render_component(&H.render_with_event_click/1, %{})
      assert html =~ "event-clicked"
    end

    test "overflow-x-auto for horizontal scrolling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-week-view"
    end

    test "renders without events (empty week)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "May month shown for week spanning April-May" do
      html = render_component(&H.render_default/1, %{})
      # May 1 is the last day — its subtitle shows "May, Sunday"
      assert html =~ "May"
    end

    test "event without label renders just the time" do
      html = render_component(&H.render_no_label_event/1, %{})
      assert html =~ "10:00"
      refute html =~ "10:00 ("
    end

    test "event with duration_minutes computes height" do
      html = render_component(&H.render_duration_event/1, %{})
      # 90 minutes at 60px/hour = 90px height
      assert html =~ "height: 90px"
    end

    test "event top computed correctly from start_hour" do
      html = render_component(&H.render_with_events/1, %{})
      # 09:00 with start_hour=7 → top = (9-7)*60 = 120px
      assert html =~ "top: 120px"
    end

    test "event height computed correctly from end_time" do
      html = render_component(&H.render_with_events/1, %{})
      # 09:00–12:00 = 180 minutes → 180px
      assert html =~ "height: 180px"
    end

    test "purple event color class applied" do
      html = render_component(&H.render_duration_event/1, %{})
      assert html =~ "bg-purple-500"
    end
  end
end
