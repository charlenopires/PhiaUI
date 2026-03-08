defmodule PhiaUi.Components.Data.ArcLinkLabelsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.ArcLinkLabels

    def render_default(assigns) do
      ~H"""
      <svg>
        <.arc_link_labels slices={[
          %{mid_angle: 0.0, outer_radius: 90, label: "Direct", color: "oklch(0.60 0.20 240)", cx: 110, cy: 110},
          %{mid_angle: :math.pi(), outer_radius: 90, label: "Organic", color: "oklch(0.70 0.18 145)", cx: 110, cy: 110}
        ]} />
      </svg>
      """
    end

    def render_empty(assigns) do
      ~H"""
      <svg>
        <.arc_link_labels slices={[]} />
      </svg>
      """
    end

    def render_custom_font(assigns) do
      ~H"""
      <svg>
        <.arc_link_labels
          slices={[%{mid_angle: 0.0, outer_radius: 90, label: "A", color: "red", cx: 100, cy: 100}]}
          font_size="12"
        />
      </svg>
      """
    end

    def render_single(assigns) do
      ~H"""
      <svg>
        <.arc_link_labels slices={[
          %{mid_angle: -1.5708, outer_radius: 90, label: "Top", color: "blue", cx: 110, cy: 110}
        ]} />
      </svg>
      """
    end
  end

  describe "arc_link_labels/1" do
    test "renders polylines and text for each slice" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Direct"
      assert html =~ "Organic"
      assert html =~ "<polyline"
      assert html =~ "<text"
    end

    test "renders nothing for empty slices" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<g"
      refute html =~ "<polyline"
    end

    test "uses custom font_size" do
      html = render_component(&H.render_custom_font/1, %{})
      assert html =~ ~s(font-size="12")
    end

    test "renders single slice label" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "Top"
      assert html =~ "points="
    end

    test "right-side slice has text-anchor start" do
      html = render_component(&H.render_default/1, %{})
      # mid_angle=0 → cos(0)=1 → right side → anchor=start
      assert html =~ ~s(text-anchor="start")
    end

    test "left-side slice has text-anchor end" do
      html = render_component(&H.render_default/1, %{})
      # mid_angle=pi → cos(pi)=-1 → left side → anchor=end
      assert html =~ ~s(text-anchor="end")
    end
  end
end
