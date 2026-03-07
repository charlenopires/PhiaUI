defmodule PhiaUi.Components.MeterGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MeterGroup

    def render_basic(assigns) do
      ~H"""
      <.meter_group meters={[
        %{label: "Photos", value: 30, max: 100, color: :blue},
        %{label: "Videos", value: 45, max: 100, color: :purple}
      ]} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.meter_group meters={[%{label: "A", value: 10, max: 100, color: :blue}]} size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.meter_group meters={[%{label: "A", value: 10, max: 100, color: :blue}]} size={:lg} />
      """
    end

    def render_with_total_label(assigns) do
      ~H"""
      <.meter_group
        meters={[%{label: "Used", value: 70, max: 100, color: :green}]}
        total_label="Total used: 70 GB"
      />
      """
    end

    def render_zero_max(assigns) do
      ~H"""
      <.meter_group meters={[%{label: "Empty", value: 0, max: 0, color: :red}]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.meter_group meters={[%{label: "X", value: 5, max: 10, color: :teal}]} class="my-meter" />
      """
    end
  end

  describe "meter_group/1" do
    test "renders a dl element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<dl"
    end

    test "renders labels" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Photos"
      assert html =~ "Videos"
    end

    test "renders values" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "30/100"
      assert html =~ "45/100"
    end

    test "renders percentage as width" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "width: 30.0%"
      assert html =~ "width: 45.0%"
    end

    test ":sm size has h-1.5 class" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-1.5"
    end

    test ":lg size has h-4 class" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-4"
    end

    test ":default size has h-2.5 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "h-2.5"
    end

    test "total_label is rendered when provided" do
      html = render_component(&H.render_with_total_label/1, %{})
      assert html =~ "Total used: 70 GB"
    end

    test "zero max returns 0.0% width without crash" do
      html = render_component(&H.render_zero_max/1, %{})
      assert html =~ "width: 0.0%"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-meter"
    end
  end
end
