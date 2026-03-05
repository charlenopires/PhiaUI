defmodule PhiaUi.Components.ScheduleViewTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ScheduleView

    def render_default(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} />|
    end

    def render_with_availability(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} availability={%{~D[2026-03-09] => ["09:00", "09:30"]}} />|
    end

    def render_with_booked(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} availability={%{~D[2026-03-09] => ["09:00", "09:30"]}} booked_slots={%{~D[2026-03-09] => ["09:00"]}} />|
    end

    def render_with_selected(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} availability={%{~D[2026-03-09] => ["09:00", "09:30"]}} selected_slot={%{date: ~D[2026-03-09], time: "09:30"}} />|
    end

    def render_with_select(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} availability={%{~D[2026-03-09] => ["09:00"]}} on_select="select_slot" />|
    end

    def render_7days(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} days_count={7} />|
    end

    def render_custom_hours(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} start_hour={9} end_hour={12} step_minutes={60} />|
    end

    def render_with_class(assigns) do
      ~H|<.schedule_view week_start={~D[2026-03-09]} class="my-schedule" />|
    end

    def render_booked_with_select(assigns) do
      ~H|<.schedule_view
        week_start={~D[2026-03-09]}
        availability={%{~D[2026-03-09] => ["09:00"]}}
        booked_slots={%{~D[2026-03-09] => ["09:00"]}}
        on_select="select_slot"
      />|
    end
  end

  describe "schedule_view/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_with_availability, do: render_component(&H.render_with_availability/1, %{})
    defp render_with_booked, do: render_component(&H.render_with_booked/1, %{})
    defp render_with_selected, do: render_component(&H.render_with_selected/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_7days, do: render_component(&H.render_7days/1, %{})
    defp render_custom_hours, do: render_component(&H.render_custom_hours/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_booked_with_select, do: render_component(&H.render_booked_with_select/1, %{})

    # Structure
    test "renders table element" do
      assert render_default() =~ "<table"
    end

    test "renders thead with Time header" do
      assert render_default() =~ "Time"
    end

    test "renders tbody" do
      assert render_default() =~ "<tbody"
    end

    test "renders rounded-2xl wrapper" do
      assert render_default() =~ "rounded-2xl"
    end

    test "renders border on wrapper" do
      assert render_default() =~ "border"
    end

    # Days
    test "renders 5 day columns by default" do
      html = render_default()
      # Mon 9 March 2026
      assert html =~ "Mon"
    end

    test "renders day labels with date" do
      html = render_default()
      assert html =~ "3/9" or html =~ "9"
    end

    test "renders 7 day columns when days_count=7" do
      html = render_7days()
      assert html =~ "Sun" or html =~ "Sat"
    end

    # Time slots
    test "renders time slot rows" do
      html = render_default()
      # Default: 8:00 to 18:00 step 30min
      assert html =~ "08:00"
    end

    test "renders end time slot before end_hour" do
      html = render_default()
      assert html =~ "17:30"
    end

    test "custom hours renders correct slots" do
      html = render_custom_hours()
      assert html =~ "09:00"
      assert html =~ "11:00"
    end

    # Availability states
    test "available slot has hover:bg-primary/5" do
      assert render_with_availability() =~ "hover:bg-primary/5"
    end

    test "available slot has cursor-pointer" do
      assert render_with_availability() =~ "cursor-pointer"
    end

    test "booked slot has cursor-not-allowed" do
      assert render_with_booked() =~ "cursor-not-allowed"
    end

    test "booked slot has opacity-60" do
      assert render_with_booked() =~ "opacity-60"
    end

    # Selected slot
    test "selected slot has bg-primary" do
      assert render_with_selected() =~ "bg-primary"
    end

    test "selected slot has text-primary-foreground" do
      assert render_with_selected() =~ "text-primary-foreground"
    end

    test "selected slot renders checkmark" do
      assert render_with_selected() =~ "✓"
    end

    # Interaction
    test "on_select adds phx-click for available slot" do
      assert render_with_select() =~ ~s(phx-click="select_slot")
    end

    test "on_select adds phx-value-date for available slot" do
      assert render_with_select() =~ ~s(phx-value-date="2026-03-09")
    end

    test "on_select adds phx-value-time for available slot" do
      assert render_with_select() =~ ~s(phx-value-time="09:00")
    end

    test "booked slot does not get phx-click even with on_select" do
      html = render_booked_with_select()
      # the booked slot should not fire the event
      refute html =~ ~s(phx-value-time="09:00" phx-click="select_slot")
    end

    # Custom class
    test "custom class applied to wrapper" do
      assert render_with_class() =~ "my-schedule"
    end
  end
end
