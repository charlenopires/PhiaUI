defmodule PhiaUi.Components.BigCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BigCalendar

    def render_default(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} />
      """
    end

    def render_with_events(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[
          %{date: ~D[2024-09-08], time: "9:00", label: "2 hours", color: "green"},
          %{date: ~D[2024-09-11], time: "13:00", label: "info here", color: "orange"}
        ]}
      />
      """
    end

    def render_week_view(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} view="week" />
      """
    end

    def render_day_view(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} view="day" />
      """
    end

    def render_list_view(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} view="list" />
      """
    end

    def render_with_nav(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} on_navigate="nav-event" />
      """
    end

    def render_with_view_change(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} on_view_change="view-change-event" />
      """
    end

    def render_with_day_click(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} on_day_click="day-click-event" />
      """
    end

    def render_with_event_click(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        on_event_click="event-click-event"
        events={[%{date: ~D[2024-09-08], time: "9:00", label: "2 hours", color: "green"}]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.big_calendar year={2024} month={9} class="my-big-cal" />
      """
    end

    def render_october(assigns) do
      ~H"""
      <.big_calendar year={2024} month={10} />
      """
    end

    def render_no_label_event(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-05], time: "10:00", color: "blue"}]}
      />
      """
    end

    def render_gray_event(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-05], time: "8:00", label: "standup", color: "gray"}]}
      />
      """
    end

    def render_red_event(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-05], time: "15:00", label: "deadline", color: "red"}]}
      />
      """
    end

    def render_purple_event(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-05], time: "11:00", label: "review", color: "purple"}]}
      />
      """
    end

    def render_blue_event(assigns) do
      ~H"""
      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-05], time: "14:00", label: "sync", color: "blue"}]}
      />
      """
    end

    def render_january(assigns) do
      ~H"""
      <.big_calendar year={2025} month={1} />
      """
    end

    def render_december(assigns) do
      ~H"""
      <.big_calendar year={2024} month={12} />
      """
    end
  end

  describe "big_calendar/1" do
    # --- Header ---

    test "renders month and year in header" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "September"
      assert html =~ "2024"
    end

    test "renders October month correctly" do
      html = render_component(&H.render_october/1, %{})
      assert html =~ "October"
      assert html =~ "2024"
    end

    test "renders January month correctly" do
      html = render_component(&H.render_january/1, %{})
      assert html =~ "January"
      assert html =~ "2025"
    end

    test "renders December month correctly" do
      html = render_component(&H.render_december/1, %{})
      assert html =~ "December"
      assert html =~ "2024"
    end

    # --- Column headers (MON-first) ---

    test "renders all 7 MON-first column headers" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "MON"
      assert html =~ "TUE"
      assert html =~ "WED"
      assert html =~ "THU"
      assert html =~ "FRI"
      assert html =~ "SAT"
      assert html =~ "SUN"
    end

    test "MON appears before SUN in column headers" do
      html = render_component(&H.render_default/1, %{})
      mon_pos = :binary.match(html, "MON") |> elem(0)
      sun_pos = :binary.match(html, "SUN") |> elem(0)
      assert mon_pos < sun_pos
    end

    # --- View switcher ---

    test "renders Month view button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Month"
    end

    test "renders Week view button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Week"
    end

    test "renders Day view button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Day"
    end

    test "renders List view button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "List"
    end

    test "active Month view button has bg-background class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-background"
    end

    # --- Stub views ---

    test "week view shows Week stub content" do
      html = render_component(&H.render_week_view/1, %{})
      assert html =~ "Week view"
    end

    test "week view does not render the grid" do
      html = render_component(&H.render_week_view/1, %{})
      refute html =~ ~s(role="grid")
    end

    test "day view shows Day stub content" do
      html = render_component(&H.render_day_view/1, %{})
      assert html =~ "Day view"
    end

    test "list view shows List stub content" do
      html = render_component(&H.render_list_view/1, %{})
      assert html =~ "List view"
    end

    # --- Day cells ---

    test "renders day number 1" do
      html = render_component(&H.render_default/1, %{})
      # The span contains the day number with surrounding whitespace from HEEx
      assert html =~ ~r/>[\s]*1[\s]*</
    end

    test "renders min-h class on day cells" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "min-h-"
    end

    test "calendar grid has role=grid" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="grid")
    end

    test "calendar grid has role=gridcell for day cells" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="gridcell")
    end

    # --- Events ---

    test "renders event pill with time and label" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "9:00 (2 hours)"
    end

    test "renders orange event pill" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-orange-500"
    end

    test "renders green event pill" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "bg-green-500"
    end

    test "renders blue event pill" do
      html = render_component(&H.render_blue_event/1, %{})
      assert html =~ "bg-blue-500"
    end

    test "renders red event pill" do
      html = render_component(&H.render_red_event/1, %{})
      assert html =~ "bg-red-500"
    end

    test "renders purple event pill" do
      html = render_component(&H.render_purple_event/1, %{})
      assert html =~ "bg-purple-500"
    end

    test "renders gray event pill" do
      html = render_component(&H.render_gray_event/1, %{})
      assert html =~ "bg-gray-300"
    end

    test "event pill without label shows only time" do
      html = render_component(&H.render_no_label_event/1, %{})
      assert html =~ "10:00"
      refute html =~ "10:00 ("
    end

    test "event pill has phx-value-date" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "phx-value-date"
    end

    test "event pill has phx-value-time" do
      html = render_component(&H.render_with_events/1, %{})
      assert html =~ "phx-value-time"
    end

    # --- Navigation ---

    test "prev/next buttons rendered when on_navigate is set" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ "nav-event"
    end

    test "prev button has direction=prev value" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-value-direction="prev")
    end

    test "next button has direction=next value" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-value-direction="next")
    end

    test "nav buttons not rendered when on_navigate is nil" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "Previous month"
    end

    # --- Event bindings ---

    test "on_view_change event fires on view buttons" do
      html = render_component(&H.render_with_view_change/1, %{})
      assert html =~ "view-change-event"
    end

    test "on_day_click event on day cells" do
      html = render_component(&H.render_with_day_click/1, %{})
      assert html =~ "day-click-event"
    end

    test "on_event_click event on event pills" do
      html = render_component(&H.render_with_event_click/1, %{})
      assert html =~ "event-click-event"
    end

    # --- Misc ---

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-big-cal"
    end
  end
end
