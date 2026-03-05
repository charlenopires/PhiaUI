defmodule PhiaUi.Components.DateRangePresetsTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateRangePresets

    def render_default(assigns) do
      ~H"""
      <.date_range_presets id="drp1" current_month={~D[2024-11-01]} />
      """
    end

    def render_with_preset(assigns) do
      ~H"""
      <.date_range_presets id="drp2" current_month={~D[2024-11-01]} active_preset="last_7_days" />
      """
    end

    def render_with_from(assigns) do
      ~H"""
      <.date_range_presets id="drp3" current_month={~D[2024-11-01]} from={~D[2024-11-10]} />
      """
    end

    def render_with_range(assigns) do
      ~H"""
      <.date_range_presets id="drp4" current_month={~D[2024-11-01]} from={~D[2024-11-10]} to={~D[2024-11-18]} />
      """
    end

    def render_no_actions(assigns) do
      ~H"""
      <.date_range_presets id="drp5" current_month={~D[2024-11-01]} show_actions={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.date_range_presets id="drp6" current_month={~D[2024-11-01]} class="my-presets-class" />
      """
    end

    def render_custom_events(assigns) do
      ~H"""
      <.date_range_presets id="drp7" current_month={~D[2024-11-01]} on_preset="pick-preset" on_cancel="my-cancel" on_confirm="my-confirm" />
      """
    end
  end

  describe "date_range_presets/1" do
    # Preset list tests
    test "renders Today preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Today"
    end

    test "renders Yesterday preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Yesterday"
    end

    test "renders Last week preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Last week"
    end

    test "renders Last 7 days preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Last 7 days"
    end

    test "renders This month preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "This month"
    end

    test "renders Last 30 days preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Last 30 days"
    end

    test "renders Custom range preset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Custom range"
    end

    test "active preset has highlighted styling" do
      html = render_component(&H.render_with_preset/1, %{})
      assert html =~ "bg-accent"
      assert html =~ "font-medium"
    end

    test "preset buttons have phx-click attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phx-click"
    end

    test "preset buttons have phx-value-preset attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phx-value-preset"
    end

    # Calendar tests
    test "renders the calendar element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "drp1-cal"
    end

    test "renders calendar grid (Su Mo headers)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Su"
      assert html =~ "Mo"
    end

    # Footer / range label tests
    test "shows empty range when no dates selected" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-range-label)
    end

    test "shows partial range when only from is set" do
      html = render_component(&H.render_with_from/1, %{})
      assert html =~ "Nov 10, 2024"
    end

    test "shows full range when both from and to are set" do
      html = render_component(&H.render_with_range/1, %{})
      assert html =~ "Nov 10, 2024"
      assert html =~ "Nov 18, 2024"
    end

    test "range separator is present when both dates set" do
      html = render_component(&H.render_with_range/1, %{})
      assert html =~ "–"
    end

    # Actions tests
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
      assert html =~ "my-presets-class"
    end

    test "custom on_preset event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "pick-preset"
    end

    test "custom on_cancel event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "my-cancel"
    end

    test "custom on_confirm event name" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ "my-confirm"
    end
  end
end
