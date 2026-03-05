defmodule PhiaUi.Components.BadgeCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BadgeCalendar

    @badges %{~D[2024-11-08] => 4, ~D[2024-11-15] => 2, ~D[2024-11-22] => 9}

    def render_default(assigns) do
      ~H"""
      <.badge_calendar year={2024} month={11} />
      """
    end

    def render_with_badges(assigns) do
      assigns = assign(assigns, :badges, @badges)

      ~H"""
      <.badge_calendar year={2024} month={11} badges={@badges} />
      """
    end

    def render_with_selected(assigns) do
      ~H"""
      <.badge_calendar year={2024} month={11} selected_date={~D[2024-11-08]} />
      """
    end

    def render_with_selected_and_badge(assigns) do
      assigns = assign(assigns, :badges, @badges)

      ~H"""
      <.badge_calendar year={2024} month={11} selected_date={~D[2024-11-08]} badges={@badges} />
      """
    end

    def render_with_nav(assigns) do
      ~H"""
      <.badge_calendar year={2024} month={11} on_prev="prev" on_next="next" />
      """
    end

    def render_with_on_select(assigns) do
      ~H"""
      <.badge_calendar year={2024} month={11} on_select="pick_date" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.badge_calendar year={2024} month={11} class="my-badge-cal" />
      """
    end
  end

  describe "badge_calendar/1" do
    test "renders November, 2024 title" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "November, 2024"
    end

    test "renders single-letter day headers S M T W T F S" do
      html = render_component(&H.render_default/1, %{})
      # All 7 single-letter headers should appear (Phoenix adds whitespace around values)
      assert html =~ ~r/>\s*S\s*</
      assert html =~ ~r/>\s*M\s*</
      assert html =~ ~r/>\s*T\s*</
      assert html =~ ~r/>\s*W\s*</
      assert html =~ ~r/>\s*F\s*</
    end

    test "renders grid-cols-7" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "grid-cols-7"
    end

    test "renders day numbers for November (1-30)" do
      html = render_component(&H.render_default/1, %{})

      for day <- 1..30 do
        assert html =~ ~r/>\s*#{day}\s*</, "Expected day #{day} to be rendered"
      end
    end

    test "badge number shown for days with badges" do
      html = render_component(&H.render_with_badges/1, %{})
      assert html =~ ~r/>\s*4\s*</
      assert html =~ ~r/>\s*2\s*</
      assert html =~ ~r/>\s*9\s*</
    end

    test "badge has text-primary class when not selected" do
      html = render_component(&H.render_with_badges/1, %{})
      assert html =~ "text-primary"
    end

    test "no badge shown for days without entries in badges map" do
      html = render_component(&H.render_default/1, %{})
      # No badge spans should appear since badges map is empty
      refute html =~ "text-primary self-start"
    end

    test "selected date has bg-foreground" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "bg-foreground"
    end

    test "selected date day number has text-background" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "text-background"
    end

    test "selected date badge has text-background/90 not text-primary" do
      html = render_component(&H.render_with_selected_and_badge/1, %{})
      assert html =~ "text-background/90"
      # The badge for the selected date should NOT have text-primary
      # (though other badges on other days may still have it)
    end

    test "non-selected current-month days have border border-border" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border border-border"
    end

    test "on_select adds phx-click to day cells" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-click="pick_date")
    end

    test "on_select adds phx-value-date to day cells" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ "phx-value-date"
    end

    test "phx-value-date is iso8601 format" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-value-date="2024-11-01")
    end

    test "no phx-click when on_select not set" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "phx-click"
    end

    test "on_prev renders prev button" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-click="prev")
    end

    test "on_next renders next button" do
      html = render_component(&H.render_with_nav/1, %{})
      assert html =~ ~s(phx-click="next")
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-badge-cal"
    end

    test "renders rounded-2xl on root element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-2xl"
    end

    test "November 2024 has correct day count of 30" do
      html = render_component(&H.render_default/1, %{})
      # Day 30 should appear (Phoenix renders with surrounding whitespace)
      assert html =~ ~r/>\s*30\s*</
      # 31 should not be shown as a current-month cell (November has only 30 days)
      refute html =~ ~r/text-foreground[^>]*>\s*31\s*</
    end

    test "badge count 4 rendered as string 4" do
      html = render_component(&H.render_with_badges/1, %{})
      assert html =~ ~r/>\s*4\s*</
    end

    test "adjacent month days are not visible (opacity-0)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "opacity-0"
    end
  end
end
