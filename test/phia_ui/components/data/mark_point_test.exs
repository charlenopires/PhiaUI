defmodule PhiaUi.Components.Data.MarkPointTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.MarkPoint

    def render_default(assigns) do
      data = [
        %{label: "Q1", value: 100},
        %{label: "Q2", value: 200},
        %{label: "Q3", value: 150},
        %{label: "Q4", value: 300}
      ]

      categories = Enum.map(data, & &1.label)
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(categories, 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 350, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max, :min]}
          x_scale={@x_scale}
          y_scale={@y_scale}
        />
      </svg>
      """
    end

    def render_average(assigns) do
      data = [
        %{label: "A", value: 10},
        %{label: "B", value: 20},
        %{label: "C", value: 30}
      ]

      categories = Enum.map(data, & &1.label)
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(categories, 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 40, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:average]}
          x_scale={@x_scale}
          y_scale={@y_scale}
        />
      </svg>
      """
    end

    def render_diamond(assigns) do
      data = [%{label: "A", value: 50}]
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(["A"], 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 100, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max]}
          x_scale={@x_scale}
          y_scale={@y_scale}
          symbol={:diamond}
        />
      </svg>
      """
    end

    def render_triangle(assigns) do
      data = [%{label: "A", value: 50}]
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(["A"], 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 100, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max]}
          x_scale={@x_scale}
          y_scale={@y_scale}
          symbol={:triangle}
        />
      </svg>
      """
    end

    def render_no_label(assigns) do
      data = [%{label: "A", value: 50}]
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(["A"], 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 100, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max]}
          x_scale={@x_scale}
          y_scale={@y_scale}
          show_label={false}
        />
      </svg>
      """
    end

    def render_no_animate(assigns) do
      data = [%{label: "A", value: 50}]
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(["A"], 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 100, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max]}
          x_scale={@x_scale}
          y_scale={@y_scale}
          animate={false}
        />
      </svg>
      """
    end

    def render_empty(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point data={[]} types={[:max]} />
      </svg>
      """
    end

    def render_custom_class(assigns) do
      data = [%{label: "A", value: 50}]
      x_result = PhiaUi.Components.Data.ChartScales.band_scale(["A"], 44, 384)
      y_scale = PhiaUi.Components.Data.ChartScales.linear_scale(0, 100, 260, 16)

      assigns =
        assigns
        |> Phoenix.Component.assign(:data, data)
        |> Phoenix.Component.assign(:x_scale, x_result.scale)
        |> Phoenix.Component.assign(:y_scale, y_scale)

      ~H"""
      <svg viewBox="0 0 400 300">
        <.mark_point
          data={@data}
          types={[:max]}
          x_scale={@x_scale}
          y_scale={@y_scale}
          class="my-marks"
        />
      </svg>
      """
    end
  end

  describe "mark_point/1" do
    test "renders circle markers for max and min" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders two markers for max and min" do
      html = render_component(&H.render_default/1, %{})
      circle_count = html |> String.split("<circle") |> length() |> Kernel.-(1)
      assert circle_count == 2
    end

    test "renders value labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "300"
      assert html =~ "100"
    end

    test "renders average marker" do
      html = render_component(&H.render_average/1, %{})
      assert html =~ "<circle"
      assert html =~ "20.0"
    end

    test "renders diamond symbol" do
      html = render_component(&H.render_diamond/1, %{})
      assert html =~ "<rect"
      assert html =~ "rotate(45"
    end

    test "renders triangle symbol" do
      html = render_component(&H.render_triangle/1, %{})
      assert html =~ "<polygon"
    end

    test "hides label when show_label is false" do
      html = render_component(&H.render_no_label/1, %{})
      assert html =~ "<circle"
      refute html =~ "<text"
    end

    test "no animation when animate is false" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-mark-bounce"
    end

    test "has animation by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-mark-bounce"
    end

    test "empty data renders nothing" do
      html = render_component(&H.render_empty/1, %{})
      refute html =~ "<circle"
    end

    test "renders custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-marks"
    end

    test "markers have white stroke" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(stroke="white")
    end
  end
end
