defmodule PhiaUi.Components.ScheduleEventCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ScheduleEventCard

    def render_meeting(assigns) do
      ~H"""
      <.schedule_event_card
        title="Team Standup"
        category={:meeting}
        date="2026 / JAN / 15"
        time_range="09:00 AM - 10:00 AM"
      />
      """
    end

    def render_event(assigns) do
      ~H"""
      <.schedule_event_card title="Product Launch" category={:event} />
      """
    end

    def render_leave(assigns) do
      ~H"""
      <.schedule_event_card title="Annual Leave" category={:leave} />
      """
    end

    def render_default(assigns) do
      ~H"""
      <.schedule_event_card title="Default Card" />
      """
    end

    def render_with_avatars(assigns) do
      ~H"""
      <.schedule_event_card
        title="Sprint Review"
        avatars={["Alice", "Bob", "Carol", "Dave"]}
        max_avatars={3}
      />
      """
    end

    def render_custom_label(assigns) do
      ~H"""
      <.schedule_event_card title="Custom" category={:meeting} category_label="1:1" />
      """
    end

    def render_no_date(assigns) do
      ~H"""
      <.schedule_event_card title="No Date" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.schedule_event_card title="Styled" class="my-card" />
      """
    end

    def render_few_avatars(assigns) do
      ~H"""
      <.schedule_event_card
        title="Small Team"
        avatars={["Alice", "Bob"]}
        max_avatars={3}
      />
      """
    end
  end

  describe "schedule_event_card/1" do
    test "renders title 'Team Standup'" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "Team Standup"
    end

    test "meeting category has border-l-blue-500" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "border-l-blue-500"
    end

    test "event category has border-l-teal-500" do
      html = render_component(&H.render_event/1, %{})
      assert html =~ "border-l-teal-500"
    end

    test "leave category has border-l-red-400" do
      html = render_component(&H.render_leave/1, %{})
      assert html =~ "border-l-red-400"
    end

    test "default category has border-l-primary" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border-l-primary"
    end

    test "meeting badge has bg-blue-100" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "bg-blue-100"
    end

    test "meeting badge has text-blue-700" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "text-blue-700"
    end

    test "event badge has bg-teal-100" do
      html = render_component(&H.render_event/1, %{})
      assert html =~ "bg-teal-100"
    end

    test "leave badge has bg-red-100" do
      html = render_component(&H.render_leave/1, %{})
      assert html =~ "bg-red-100"
    end

    test "default badge label is 'Meeting' for :meeting" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "Meeting"
    end

    test "default badge label is 'Event' for :event" do
      html = render_component(&H.render_event/1, %{})
      assert html =~ "Event"
    end

    test "default badge label is 'Leave' for :leave" do
      html = render_component(&H.render_leave/1, %{})
      assert html =~ "Leave"
    end

    test "custom category_label '1:1' overrides default" do
      html = render_component(&H.render_custom_label/1, %{})
      assert html =~ "1:1"
      refute html =~ ">Meeting<"
    end

    test "date rendered '2026 / JAN / 15'" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "2026 / JAN / 15"
    end

    test "time_range rendered '09:00 AM - 10:00 AM'" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "09:00 AM - 10:00 AM"
    end

    test "no date row when date is nil" do
      html = render_component(&H.render_no_date/1, %{})
      refute html =~ "📅"
    end

    test "avatars rendered up to max_avatars=3 when 4 given" do
      html = render_component(&H.render_with_avatars/1, %{})
      # 3 avatar circles should be present (each has the 👤 emoji)
      avatar_count =
        html
        |> String.split("👤")
        |> length()
        |> Kernel.-(1)

      assert avatar_count == 3
    end

    test "overflow count '+1' shown when avatars > max_avatars (4 avatars, max 3)" do
      html = render_component(&H.render_with_avatars/1, %{})
      assert html =~ "+1"
    end

    test "custom class applied to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-card"
    end

    test "wrapper has rounded-xl" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "rounded-xl"
    end

    test "wrapper has border-l-4" do
      html = render_component(&H.render_meeting/1, %{})
      assert html =~ "border-l-4"
    end

    test "no overflow count when avatars <= max_avatars" do
      html = render_component(&H.render_few_avatars/1, %{})
      refute html =~ ~r/>\+\d+</
    end

    test "no time row when time_range is nil" do
      html = render_component(&H.render_no_date/1, %{})
      refute html =~ "🕐"
    end
  end
end
