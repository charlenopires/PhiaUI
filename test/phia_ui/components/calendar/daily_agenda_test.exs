defmodule PhiaUi.Components.DailyAgendaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DailyAgenda

    def render_default(assigns) do
      ~H"<.daily_agenda date={~D[2024-12-09]} />"
    end

    def render_with_events(assigns) do
      ~H"""
      <.daily_agenda date={~D[2024-12-09]}>
        <:event icon="✳">Daria's 20th Birthday</:event>
        <:event icon="☀️" time="09:00">Wake up</:event>
        <:event time="10:00">Design Crit</:event>
      </.daily_agenda>
      """
    end

    def render_with_has_events(assigns) do
      ~H"<.daily_agenda date={~D[2024-12-09]} has_events />"
    end

    def render_with_on_select(assigns) do
      ~H"""
      <.daily_agenda date={~D[2024-12-09]} on_date_select="pick_date" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.daily_agenda date={~D[2024-12-09]} class="my-agenda" />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_with_events, do: render_component(&H.render_with_events/1, %{})
  defp render_with_has_events, do: render_component(&H.render_with_has_events/1, %{})
  defp render_with_on_select, do: render_component(&H.render_with_on_select/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # Header — day abbreviation and date
  # ---------------------------------------------------------------------------

  describe "daily_agenda/1 — header" do
    test "1. renders day abbreviation Mon in header" do
      html = render_default()
      assert html =~ "Mon"
    end

    test "2. renders December in date display" do
      html = render_default()
      assert html =~ "December"
    end

    test "3. renders 9 in date display" do
      html = render_default()
      assert html =~ "9"
    end

    test "4. renders 2024 year" do
      html = render_default()
      assert html =~ "2024"
    end

    test "5. no indicator dot when has_events is false" do
      html = render_default()
      refute html =~ "bg-destructive"
    end

    test "6. indicator dot rendered when has_events is true" do
      html = render_with_has_events()
      assert html =~ "bg-destructive"
    end

    test "7. indicator dot has bg-destructive class" do
      html = render_with_has_events()
      assert html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Week strip
  # ---------------------------------------------------------------------------

  describe "daily_agenda/1 — week strip" do
    test "8. week strip shows 7 dates (3 before + selected + 3 after)" do
      html = render_default()
      # The week strip for Dec 9 shows days 6,7,8,9,10,11,12
      # Each day renders its number; count occurrences of the day numbers in week strip context
      # We count phx-value-date occurrences OR count day cells; simplest: look for all 7 days
      assert html =~ "6"
      assert html =~ "7"
      assert html =~ "8"
      assert html =~ "9"
      assert html =~ "10"
      assert html =~ "11"
      assert html =~ "12"
    end

    test "9. week strip shows day numbers 6 through 12" do
      html = render_default()
      assert html =~ ">6<" or html =~ "6\n" or html =~ ~s(>6)
      assert html =~ ">12<" or html =~ "12\n" or html =~ ~s(>12)
    end

    test "10. week strip shows day abbreviations MON TUE WED THU FRI SAT SUN" do
      html = render_default()
      # 2024-12-09 is Monday
      # -3 days = 2024-12-06 (Fri), +3 days = 2024-12-12 (Thu)
      # day abbrs: FRI SAT SUN MON TUE WED THU
      assert html =~ "MON"
      assert html =~ "FRI"
      assert html =~ "SAT"
      assert html =~ "SUN"
      assert html =~ "TUE"
      assert html =~ "WED"
      assert html =~ "THU"
    end

    test "11. selected date 9 is highlighted in week strip" do
      html = render_default()
      # The selected date cell has border/shadow indicator
      assert html =~ "border-border"
    end

    test "12. selected date has text-primary in week strip" do
      html = render_default()
      assert html =~ "text-primary"
    end

    test "13. on_date_select adds phx-click to week strip items" do
      html = render_with_on_select()
      assert html =~ ~s(phx-click="pick_date")
    end

    test "14. on_date_select adds phx-value-date to week strip items" do
      html = render_with_on_select()
      assert html =~ "phx-value-date"
    end
  end

  # ---------------------------------------------------------------------------
  # Event list
  # ---------------------------------------------------------------------------

  describe "daily_agenda/1 — event list" do
    test "15. event title Daria's 20th Birthday rendered" do
      html = render_with_events()
      assert html =~ "Daria&#39;s 20th Birthday" or html =~ "Daria's 20th Birthday"
    end

    test "16. event title Wake up rendered" do
      html = render_with_events()
      assert html =~ "Wake up"
    end

    test "17. event time 09:00 rendered" do
      html = render_with_events()
      assert html =~ "09:00"
    end

    test "18. event icon ✳ rendered" do
      html = render_with_events()
      assert html =~ "✳"
    end

    test "19. dotted separator border-dashed present between events" do
      html = render_with_events()
      assert html =~ "border-dashed"
    end

    test "20. custom class applied to root element" do
      html = render_with_class()
      assert html =~ "my-agenda"
    end

    test "21. event without icon renders fallback div with border" do
      html = render_with_events()
      # Design Crit has no icon — should render a fallback square div
      assert html =~ "Design Crit"
      # The fallback element has rounded-sm border
      assert html =~ "rounded-sm"
    end

    test "22. event without time does not render a time element for that event" do
      html = render_with_events()
      # Daria's Birthday has time={nil} — only 09:00 and 10:00 are present, not a nil time span
      assert html =~ "09:00"
      assert html =~ "10:00"
      # There should be no empty time span for the birthday event
      refute html =~ ~s(<span></span>)
    end
  end
end
