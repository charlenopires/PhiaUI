defmodule PhiaUi.Components.TimelineChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimelineChart

    def render_default(assigns) do
      ~H"""
      <.timeline_chart events={[
        %{label: "Kickoff",  date: "Jan 2024", description: "Project started"},
        %{label: "Beta",     date: "Mar 2024", description: "First beta release"},
        %{label: "Launch",   date: "Jun 2024", description: "Public launch"}
      ]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.timeline_chart events={[%{label: "Start", date: "Q1"}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.timeline_chart events={[]} />
      """
    end

    def render_with_colors(assigns) do
      ~H"""
      <.timeline_chart events={[
        %{label: "v1", date: "Q1", color: "oklch(0.60 0.20 240)"},
        %{label: "v2", date: "Q3", color: "oklch(0.65 0.22 30)"}
      ]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.timeline_chart events={[%{label: "A", date: "Jan"}, %{label: "B", date: "Feb"}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.timeline_chart events={[%{label: "E", date: "Q1"}]} class="my-timeline" />
      """
    end

    def render_no_description(assigns) do
      ~H"""
      <.timeline_chart events={[%{label: "A", date: "Jan"}, %{label: "B", date: "Feb"}]} />
      """
    end
  end

  describe "timeline_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders horizontal axis line" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<line"
    end

    test "renders circle markers on axis" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders event labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Kickoff"
      assert html =~ "Beta"
      assert html =~ "Launch"
    end

    test "renders date labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Jan 2024"
      assert html =~ "Mar 2024"
    end

    test "renders descriptions when provided" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Project started"
    end

    test "no description element when not provided" do
      html = render_component(&H.render_no_description/1, %{})
      # No description in data, so no description text rendered
      assert html =~ "<svg"
    end

    test "single event renders" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "Start"
    end

    test "empty events renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "custom colors applied to markers" do
      html = render_component(&H.render_with_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-dot-pop"
    end

    test "animate true adds pop animation to markers" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-dot-pop"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-timeline"
    end

    test "viewBox present" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end
  end
end
