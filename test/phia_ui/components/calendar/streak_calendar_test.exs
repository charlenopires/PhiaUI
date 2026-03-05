defmodule PhiaUi.Components.StreakCalendarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.StreakCalendar

    def render_default(assigns) do
      ~H|<.streak_calendar year={2026} month={3} />|
    end

    def render_with_streak(assigns) do
      ~H|<.streak_calendar year={2026} month={3} streak_count={7} />|
    end

    def render_with_entries(assigns) do
      ~H|<.streak_calendar year={2026} month={3} entries={%{~D[2026-03-01] => :completed, ~D[2026-03-02] => :missed, ~D[2026-03-03] => :rest}} />|
    end

    def render_with_nav(assigns) do
      ~H|<.streak_calendar year={2026} month={3} on_prev="prev_month" on_next="next_month" />|
    end

    def render_with_select(assigns) do
      ~H|<.streak_calendar year={2026} month={3} on_select="pick_day" />|
    end

    def render_with_class(assigns) do
      ~H|<.streak_calendar year={2026} month={3} class="my-streak" />|
    end

    def render_february(assigns) do
      ~H|<.streak_calendar year={2025} month={2} />|
    end
  end

  describe "streak_calendar/1" do
    defp render_default, do: render_component(&H.render_default/1, %{})
    defp render_with_streak, do: render_component(&H.render_with_streak/1, %{})
    defp render_with_entries, do: render_component(&H.render_with_entries/1, %{})
    defp render_with_nav, do: render_component(&H.render_with_nav/1, %{})
    defp render_with_select, do: render_component(&H.render_with_select/1, %{})
    defp render_with_class, do: render_component(&H.render_with_class/1, %{})
    defp render_february, do: render_component(&H.render_february/1, %{})

    # Structure
    test "renders month title March" do
      assert render_default() =~ "March"
    end

    test "renders year in title" do
      html = render_default()
      assert html =~ "26" or html =~ "2026"
    end

    test "renders grid-cols-7" do
      assert render_default() =~ "grid-cols-7"
    end

    test "renders Mon in day headers (MON-first)" do
      assert render_default() =~ "Mon"
    end

    test "renders Sun in day headers" do
      assert render_default() =~ "Sun"
    end

    test "renders all 7 day name headers" do
      html = render_default()
      for day <- ~w(Mon Tue Wed Thu Fri Sat Sun) do
        assert html =~ day
      end
    end

    test "renders day 1 for March" do
      assert render_default() =~ ~r/>\s*1\s*</
    end

    test "renders day 31 for March" do
      assert render_default() =~ ~r/>\s*31\s*</
    end

    test "renders rounded-2xl wrapper" do
      assert render_default() =~ "rounded-2xl"
    end

    test "renders select-none on wrapper" do
      assert render_default() =~ "select-none"
    end

    # Streak display
    test "streak count shown when > 0" do
      html = render_with_streak()
      assert html =~ "7"
      assert html =~ "day streak"
    end

    test "zero streak shows start message" do
      assert render_default() =~ "Start your streak"
    end

    # Entry states
    test "completed entry renders bg-green-500" do
      assert render_with_entries() =~ "bg-green-500"
    end

    test "completed entry renders text-white" do
      assert render_with_entries() =~ "text-white"
    end

    test "missed entry renders bg-red-200" do
      assert render_with_entries() =~ "bg-red-200"
    end

    test "missed entry renders text-red-700" do
      assert render_with_entries() =~ "text-red-700"
    end

    test "rest entry renders bg-muted" do
      assert render_with_entries() =~ "bg-muted"
    end

    # Navigation
    test "on_prev renders prev button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="prev_month")
    end

    test "on_next renders next button with phx-click" do
      assert render_with_nav() =~ ~s(phx-click="next_month")
    end

    test "no prev button when on_prev not set" do
      refute render_default() =~ ~s(phx-click="prev_month")
    end

    # Interaction
    test "on_select adds phx-click to day cells" do
      assert render_with_select() =~ ~s(phx-click="pick_day")
    end

    test "on_select adds phx-value-date in iso8601 format" do
      assert render_with_select() =~ ~s(phx-value-date="2026-03-)
    end

    test "no phx-value-date when on_select not set" do
      refute render_default() =~ "phx-value-date"
    end

    # Legend
    test "renders Done legend" do
      assert render_default() =~ "Done"
    end

    test "renders Missed legend" do
      assert render_default() =~ "Missed"
    end

    test "renders Rest legend" do
      assert render_default() =~ "Rest"
    end

    # Custom class
    test "custom class applied to wrapper" do
      assert render_with_class() =~ "my-streak"
    end

    # Edge cases
    test "February 2025 renders without errors" do
      html = render_february()
      assert html =~ "February" or html =~ "Feb"
    end

    test "February 2025 renders day 28" do
      assert render_february() =~ ~r/>\s*28\s*</
    end

    test "adjacent month days have opacity-30 class" do
      assert render_default() =~ "opacity-30"
    end
  end
end
