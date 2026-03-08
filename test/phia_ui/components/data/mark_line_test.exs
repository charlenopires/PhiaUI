defmodule PhiaUi.Components.Data.MarkLineTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.MarkLine

    def render_average(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[100, 200, 150, 300, 250]}
          type={:average}
          y_pos={120.0}
          width={340}
          label="Avg"
        />
      </svg>
      """
    end

    def render_median(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[100, 200, 150, 300, 250]}
          type={:median}
          y_pos={130.0}
          width={340}
          label="Median"
        />
      </svg>
      """
    end

    def render_custom(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          type={:custom}
          value={200}
          y_pos={80.0}
          width={340}
          label="Target"
          color="oklch(0.60 0.22 30)"
        />
      </svg>
      """
    end

    def render_no_label(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[10, 20, 30]}
          type={:average}
          y_pos={100.0}
          width={340}
          label={nil}
          show_value={false}
        />
      </svg>
      """
    end

    def render_custom_dash(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[10, 20, 30]}
          type={:min}
          y_pos={150.0}
          width={340}
          dash_array="6 2"
        />
      </svg>
      """
    end

    def render_empty_data(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line data={[]} type={:average} width={340} />
      </svg>
      """
    end

    def render_value_only(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[10, 20, 30]}
          type={:max}
          y_pos={90.0}
          width={340}
        />
      </svg>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_line
          data={[10, 20]}
          type={:average}
          y_pos={100.0}
          width={340}
          class="my-mark"
        />
      </svg>
      """
    end
  end

  describe "mark_line/1" do
    test "renders horizontal line element" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ "<line"
    end

    test "renders dashed line" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ "stroke-dasharray"
    end

    test "renders label text" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ "Avg"
    end

    test "renders median label" do
      html = render_component(&H.render_median/1, %{})
      assert html =~ "Median"
    end

    test "renders custom value line" do
      html = render_component(&H.render_custom/1, %{})
      assert html =~ "Target"
      assert html =~ "oklch(0.60 0.22 30)"
    end

    test "hides label when nil and show_value false" do
      html = render_component(&H.render_no_label/1, %{})
      assert html =~ "<line"
      refute html =~ "<text"
    end

    test "renders custom dash array" do
      html = render_component(&H.render_custom_dash/1, %{})
      assert html =~ ~s(stroke-dasharray="6 2")
    end

    test "empty data renders nothing" do
      html = render_component(&H.render_empty_data/1, %{})
      refute html =~ "<line"
    end

    test "renders value in label when show_value true" do
      html = render_component(&H.render_value_only/1, %{})
      assert html =~ "30"
    end

    test "renders custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-mark"
    end

    test "renders default color" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ "oklch(0.60 0.25 0)"
    end

    test "line has opacity" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ ~s(opacity="0.8")
    end
  end
end
