defmodule PhiaUi.Components.FunnelChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FunnelChart

    def render_basic(assigns) do
      ~H"""
      <.funnel_chart stages={[
        %{label: "Visitors", value: 10_000},
        %{label: "Leads",    value: 4_000},
        %{label: "Signups",  value: 1_000}
      ]} />
      """
    end

    def render_no_dropoff(assigns) do
      ~H"""
      <.funnel_chart
        stages={[%{label: "A", value: 100}, %{label: "B", value: 50}]}
        show_dropoff={false}
      />
      """
    end

    def render_blue(assigns) do
      ~H"""
      <.funnel_chart stages={[%{label: "Step", value: 100}]} color={:blue} />
      """
    end

    def render_green(assigns) do
      ~H"""
      <.funnel_chart stages={[%{label: "Step", value: 100}]} color={:green} />
      """
    end

    def render_purple(assigns) do
      ~H"""
      <.funnel_chart stages={[%{label: "Step", value: 100}]} color={:purple} />
      """
    end

    def render_single_stage(assigns) do
      ~H"""
      <.funnel_chart stages={[%{label: "Only", value: 500}]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.funnel_chart stages={[%{label: "A", value: 10}]} class="my-funnel" />
      """
    end
  end

  describe "funnel_chart/1" do
    test "renders container div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders stage labels" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Visitors"
      assert html =~ "Leads"
      assert html =~ "Signups"
    end

    test "first stage has 100.0% width" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "width: 100.0%"
    end

    test "subsequent stages have proportional widths" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "width: 40.0%"
      assert html =~ "width: 10.0%"
    end

    test "shows drop-off annotation by default" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "drop-off"
    end

    test "hides drop-off when show_dropoff is false" do
      html = render_component(&H.render_no_dropoff/1, %{})
      refute html =~ "drop-off"
    end

    test ":blue color renders bg-blue-500" do
      html = render_component(&H.render_blue/1, %{})
      assert html =~ "bg-blue-500"
    end

    test ":green color renders bg-green-500" do
      html = render_component(&H.render_green/1, %{})
      assert html =~ "bg-green-500"
    end

    test ":purple color renders bg-purple-500" do
      html = render_component(&H.render_purple/1, %{})
      assert html =~ "bg-purple-500"
    end

    test "single stage renders without crash" do
      html = render_component(&H.render_single_stage/1, %{})
      assert html =~ "Only"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-funnel"
    end
  end
end
