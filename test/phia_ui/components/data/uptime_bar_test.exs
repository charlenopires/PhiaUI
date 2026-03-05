defmodule PhiaUi.Components.UptimeBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UptimeBar

    def render_default(assigns) do
      ~H"""
      <.uptime_bar />
      """
    end

    def render_all_up(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up}, %{status: :up}, %{status: :up}]} />
      """
    end

    def render_with_down(assigns) do
      ~H"""
      <.uptime_bar segments={[
        %{status: :up}, %{status: :up}, %{status: :up},
        %{status: :up}, %{status: :up}, %{status: :up},
        %{status: :up}, %{status: :up}, %{status: :up},
        %{status: :down}
      ]} />
      """
    end

    def render_with_degraded(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up}, %{status: :degraded}]} />
      """
    end

    def render_two_segments(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up}, %{status: :down}]} />
      """
    end

    def render_single_segment(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up}]} />
      """
    end

    def render_custom_days(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up}]} days={30} />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :up, label: "2026-03-01"}, %{status: :down}]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.uptime_bar class="my-uptime-class" />
      """
    end

    def render_fully_down(assigns) do
      ~H"""
      <.uptime_bar segments={[%{status: :down}, %{status: :down}]} />
      """
    end
  end

  describe "uptime_bar/1" do
    test "renders a container div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders :up segment with bg-green-500" do
      html = render_component(&H.render_all_up/1, %{})
      assert html =~ "bg-green-500"
    end

    test "renders :down segment with bg-red-500" do
      html = render_component(&H.render_two_segments/1, %{})
      assert html =~ "bg-red-500"
    end

    test "renders :degraded segment with bg-yellow-500" do
      html = render_component(&H.render_with_degraded/1, %{})
      assert html =~ "bg-yellow-500"
    end

    test "shows 100.0% uptime when all segments are :up" do
      html = render_component(&H.render_all_up/1, %{})
      assert html =~ "100.0%"
    end

    test "shows 0.0% uptime when all segments are :down" do
      html = render_component(&H.render_fully_down/1, %{})
      assert html =~ "0.0%"
    end

    test "computes uptime percentage from mixed segments" do
      # 9 up out of 10 = 90.0%
      html = render_component(&H.render_with_down/1, %{})
      assert html =~ "90.0%"
    end

    test "empty segments shows 100.0% uptime" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "100.0%"
    end

    test "renders default 90 days label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "90 days ago"
    end

    test "custom days label" do
      html = render_component(&H.render_custom_days/1, %{})
      assert html =~ "30 days ago"
    end

    test "renders Today label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Today"
    end

    test "renders uptime % label" do
      html = render_component(&H.render_all_up/1, %{})
      assert html =~ "uptime"
    end

    test "first segment has rounded-l-full" do
      html = render_component(&H.render_two_segments/1, %{})
      assert html =~ "rounded-l-full"
    end

    test "last segment has rounded-r-full" do
      html = render_component(&H.render_two_segments/1, %{})
      assert html =~ "rounded-r-full"
    end

    test "single segment has rounded-full (both caps)" do
      html = render_component(&H.render_single_segment/1, %{})
      assert html =~ "rounded-full"
    end

    test "segment with label uses label as tooltip title" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(title="2026-03-01")
    end

    test "segment without label uses status as tooltip title" do
      html = render_component(&H.render_all_up/1, %{})
      assert html =~ ~s(title="up")
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-uptime-class"
    end
  end
end
