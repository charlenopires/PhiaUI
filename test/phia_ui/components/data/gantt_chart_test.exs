defmodule PhiaUi.Components.GanttChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.GanttChart

    def render_empty(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]} />
      """
    end

    def render_with_event(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]}>
        <:event
          day={~D[2026-03-09]}
          start_time="10:00"
          end_time="11:00"
          label="Team Meeting"
        />
      </.gantt_chart>
      """
    end

    def render_with_colored_event(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]}>
        <:event
          day={~D[2026-03-10]}
          start_time="14:00"
          end_time="15:30"
          label="Design Review"
          color="bg-purple-500"
        />
      </.gantt_chart>
      """
    end

    def render_multiple_events(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]}>
        <:event day={~D[2026-03-09]} start_time="09:00" end_time="10:00" label="Standup" />
        <:event day={~D[2026-03-09]} start_time="14:00" end_time="15:00" label="Retro" />
        <:event day={~D[2026-03-11]} start_time="11:00" end_time="12:00" label="Sprint Planning" />
      </.gantt_chart>
      """
    end

    def render_custom_hours(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]} start_hour={6} end_hour={18} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.gantt_chart week_start={~D[2026-03-09]} class="my-gantt-class" />
      """
    end
  end

  describe "gantt_chart/1" do
    test "renders a container div" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<div"
    end

    test "renders 7 day columns" do
      html = render_component(&H.render_empty/1, %{})
      # 7 day names Mon-Sun
      assert html =~ "Mon"
      assert html =~ "Tue"
      assert html =~ "Wed"
      assert html =~ "Thu"
      assert html =~ "Fri"
      assert html =~ "Sat"
      assert html =~ "Sun"
    end

    test "renders day numbers in headers" do
      html = render_component(&H.render_empty/1, %{})
      # March 9 = Mon, March 15 = Sun
      assert html =~ "9"
      assert html =~ "15"
    end

    test "renders time labels for default range (8am-8pm)" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "8am"
      assert html =~ "12pm"
    end

    test "renders event label" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ "Team Meeting"
    end

    test "renders event time range" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ "10:00"
      assert html =~ "11:00"
    end

    test "event uses absolute positioning style" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ "position" or html =~ "top:"
    end

    test "renders event with custom color class" do
      html = render_component(&H.render_with_colored_event/1, %{})
      assert html =~ "bg-purple-500"
    end

    test "renders multiple events" do
      html = render_component(&H.render_multiple_events/1, %{})
      assert html =~ "Standup"
      assert html =~ "Retro"
      assert html =~ "Sprint Planning"
    end

    test "events on different days all render" do
      html = render_component(&H.render_multiple_events/1, %{})
      # Standup and Retro on Monday, Sprint Planning on Wednesday
      assert html =~ "Standup"
      assert html =~ "Sprint Planning"
    end

    test "custom start_hour affects time labels" do
      html = render_component(&H.render_custom_hours/1, %{})
      assert html =~ "6am"
    end

    test "renders hour grid lines (border-dashed)" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "border-dashed"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-gantt-class"
    end

    test "empty week renders without error" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<div"
    end

    test "overflow-x-auto applied for horizontal scroll" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "week_start determines Monday date shown" do
      html = render_component(&H.render_empty/1, %{})
      # March 9, 2026 is in the rendered HTML
      assert html =~ "9"
    end

    test "renders 7pm label for default range" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "7pm"
    end

    test "event block has top style attribute" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ "top:"
    end

    test "event block has height style attribute" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ "height:"
    end
  end
end
