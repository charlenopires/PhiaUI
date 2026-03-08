defmodule PhiaUi.Components.PolarAreaChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PolarAreaChart

    def render_default(assigns) do
      ~H"""
      <.polar_area_chart data={[
        %{label: "Speed", value: 80},
        %{label: "Power", value: 65},
        %{label: "Endurance", value: 90}
      ]} />
      """
    end

    def render_five_items(assigns) do
      ~H"""
      <.polar_area_chart data={[
        %{label: "A", value: 80},
        %{label: "B", value: 60},
        %{label: "C", value: 40},
        %{label: "D", value: 70},
        %{label: "E", value: 55}
      ]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.polar_area_chart data={[]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "Only", value: 50}]} />
      """
    end

    def render_custom_max(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 30}, %{label: "B", value: 60}]} max={100} />
      """
    end

    def render_no_grid(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 50}]} show_grid={false} />
      """
    end

    def render_no_labels(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 50}]} show_labels={false} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 50}, %{label: "B", value: 70}]} animate={false} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.polar_area_chart
        data={[%{label: "A", value: 50}, %{label: "B", value: 70}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
      """
    end

    def render_item_colors(assigns) do
      ~H"""
      <.polar_area_chart data={[
        %{label: "A", value: 50, color: "red"},
        %{label: "B", value: 70, color: "blue"}
      ]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "X", value: 100}]} class="my-polar" />
      """
    end

    def render_spacing_zero(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 50}, %{label: "B", value: 70}]} spacing={0} />
      """
    end

    def render_custom_duration(assigns) do
      ~H"""
      <.polar_area_chart
        data={[%{label: "A", value: 50}]}
        animation_duration={1000}
      />
      """
    end

    def render_zero_values(assigns) do
      ~H"""
      <.polar_area_chart data={[%{label: "A", value: 0}, %{label: "B", value: 0}]} />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Rendering basics
  # ---------------------------------------------------------------------------

  describe "polar_area_chart/1 rendering" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "SVG has viewBox attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end

    test "SVG has aria-hidden for accessibility" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "renders path elements for each data point" do
      html = render_component(&H.render_default/1, %{})
      path_count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert path_count >= 3
    end

    test "five data items render five slices" do
      html = render_component(&H.render_five_items/1, %{})
      path_count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert path_count >= 5
    end

    test "slice paths contain arc command" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ " A "
    end

    test "slice paths contain Z closure" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ " Z"
    end
  end

  # ---------------------------------------------------------------------------
  # Empty and single data
  # ---------------------------------------------------------------------------

  describe "edge cases" do
    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "single data point renders without crash" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<path"
    end

    test "zero values render without crash" do
      html = render_component(&H.render_zero_values/1, %{})
      assert html =~ "<svg"
    end
  end

  # ---------------------------------------------------------------------------
  # Grid
  # ---------------------------------------------------------------------------

  describe "grid" do
    test "show_grid true renders concentric circle elements" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "show_grid true renders four grid circles (25%, 50%, 75%, 100%)" do
      html = render_component(&H.render_default/1, %{})
      # Grid circles have stroke-width="0.5"
      circle_count =
        html
        |> String.split(~s(stroke-width="0.5"))
        |> length()
        |> Kernel.-(1)

      assert circle_count == 4
    end

    test "show_grid false hides grid circles" do
      html = render_component(&H.render_no_grid/1, %{})
      # Should not have the thin grid circle strokes
      refute html =~ ~s(stroke-width="0.5")
    end

    test "grid labels show numeric values when grid and labels enabled" do
      html = render_component(&H.render_default/1, %{})
      # Max value in default data is 90
      # Grid labels: 25%, 50%, 75%, 100% of 90 = 23, 45, 68, 90
      assert html =~ "90"
    end
  end

  # ---------------------------------------------------------------------------
  # Labels
  # ---------------------------------------------------------------------------

  describe "labels" do
    test "show_labels true renders axis label text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Speed"
      assert html =~ "Power"
      assert html =~ "Endurance"
    end

    test "show_labels false hides axis labels" do
      html = render_component(&H.render_no_labels/1, %{})
      refute html =~ ">A<"
    end

    test "labels use text-anchor for positioning" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-anchor"
    end

    test "labels have font-size attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(font-size="9")
    end
  end

  # ---------------------------------------------------------------------------
  # Animation
  # ---------------------------------------------------------------------------

  describe "animation" do
    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes phia-chart-animate class" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-chart-animate"
    end

    test "animate true adds animation style to slices" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-dot-pop"
    end

    test "animate false does not add animation style" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-dot-pop"
    end

    test "custom animation_duration is reflected in style" do
      html = render_component(&H.render_custom_duration/1, %{})
      assert html =~ "1000ms"
    end

    test "slices have staggered animation delay" do
      html = render_component(&H.render_default/1, %{})
      # First slice 0ms, second 60ms, third 120ms
      assert html =~ "0ms"
      assert html =~ "60ms"
      assert html =~ "120ms"
    end
  end

  # ---------------------------------------------------------------------------
  # Colors
  # ---------------------------------------------------------------------------

  describe "colors" do
    test "slices have fill attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "fill="
    end

    test "slices have stroke attribute matching fill" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke="
    end

    test "slices have fill-opacity" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(fill-opacity="0.75")
    end

    test "custom colors palette applied to slices" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "per-item color override is used" do
      html = render_component(&H.render_item_colors/1, %{})
      assert html =~ ~s(fill="red")
      assert html =~ ~s(fill="blue")
    end
  end

  # ---------------------------------------------------------------------------
  # Max and spacing
  # ---------------------------------------------------------------------------

  describe "max attribute" do
    test "custom max scales radii relative to specified maximum" do
      html = render_component(&H.render_custom_max/1, %{})
      assert html =~ "<path"
    end
  end

  describe "spacing" do
    test "spacing 0 renders without gap" do
      html = render_component(&H.render_spacing_zero/1, %{})
      assert html =~ "<path"
    end
  end

  # ---------------------------------------------------------------------------
  # Custom class
  # ---------------------------------------------------------------------------

  describe "class attribute" do
    test "custom class applied to root div" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-polar"
    end
  end
end
