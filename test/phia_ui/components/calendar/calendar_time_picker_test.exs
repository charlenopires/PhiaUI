defmodule PhiaUi.Components.CalendarTimePickerTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CalendarTimePicker

    def render_default(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp1" current_month={~D[2024-11-01]} />
      """
    end

    def render_with_time(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp2" current_month={~D[2024-11-01]} time_value="11:30" />
      """
    end

    def render_with_date(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp3" current_month={~D[2024-11-01]} date_value={~D[2024-11-10]} />
      """
    end

    def render_custom_hours(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp4" current_month={~D[2024-11-01]} start_hour={8} end_hour={10} step={30} />
      """
    end

    def render_hourly(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp5" current_month={~D[2024-11-01]} start_hour={9} end_hour={12} step={60} />
      """
    end

    def render_no_actions(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp6" current_month={~D[2024-11-01]} show_actions={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp7" current_month={~D[2024-11-01]} class="my-ctp-class" />
      """
    end

    def render_custom_events(assigns) do
      ~H"""
      <.calendar_time_picker id="ctp8" current_month={~D[2024-11-01]} on_time_change="pick-time" on_cancel="my-cancel" on_confirm="my-confirm" />
      """
    end
  end

  describe "calendar_time_picker/1" do
    test "renders a container div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders time slot list aria-label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Time slots"
    end

    test "renders AM time slots (default 9am start)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "9:00 AM"
      assert html =~ "9:30 AM"
      assert html =~ "10:00 AM"
    end

    test "renders PM time slots" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "12:00 PM"
      assert html =~ "1:00 PM"
    end

    test "does not render slots past end_hour" do
      html = render_component(&H.render_default/1, %{})
      # default end_hour=21, so 9:00 PM slot should be last (20:30=8:30 PM)
      refute html =~ "9:00 PM"
    end

    test "custom start_hour renders earlier slots" do
      html = render_component(&H.render_custom_hours/1, %{})
      assert html =~ "8:00 AM"
      assert html =~ "8:30 AM"
      assert html =~ "9:00 AM"
      assert html =~ "9:30 AM"
    end

    test "custom end_hour stops at correct time" do
      html = render_component(&H.render_custom_hours/1, %{})
      # start=8, end=10, step=30 → 8:00, 8:30, 9:00, 9:30 (4 slots)
      refute html =~ "10:00 AM"
    end

    test "hourly step generates fewer slots" do
      html = render_component(&H.render_hourly/1, %{})
      # step=60, 9am to 12pm → 9:00, 10:00, 11:00 (3 slots)
      assert html =~ "9:00 AM"
      assert html =~ "10:00 AM"
      assert html =~ "11:00 AM"
      refute html =~ "9:30 AM"
    end

    test "selected time slot has primary styling" do
      html = render_component(&H.render_with_time/1, %{})
      assert html =~ "bg-primary"
    end

    test "selected time slot shows 11:30 AM" do
      html = render_component(&H.render_with_time/1, %{})
      assert html =~ "11:30 AM"
    end

    test "phx-value-time attribute on time buttons" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-value-time=)
    end

    test "renders Cancel button by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Cancel"
    end

    test "renders Done button by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Done"
    end

    test "show_actions=false hides Cancel and Done" do
      html = render_component(&H.render_no_actions/1, %{})
      refute html =~ "Cancel"
      refute html =~ "Done"
    end

    test "custom class is applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-ctp-class"
    end

    test "custom on_time_change event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "pick-time"
    end

    test "custom on_cancel event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "my-cancel"
    end

    test "custom on_confirm event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "my-confirm"
    end

    test "renders calendar element" do
      html = render_component(&H.render_default/1, %{})
      # The calendar renders a div with id containing the calendar id
      assert html =~ "ctp1-cal"
    end

    test "renders overflow-y-auto for scrollable time list" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "overflow-y-auto"
    end

    test "time slots use phx-click" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phx-click"
    end
  end
end
