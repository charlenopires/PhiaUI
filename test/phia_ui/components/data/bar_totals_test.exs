defmodule PhiaUi.Components.Data.BarTotalsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.BarTotals

    def render_default(assigns) do
      ~H"""
      <svg>
        <.bar_totals totals={[
          %{x: 72.0, y: 20.0, label: "350"},
          %{x: 152.0, y: 30.0, label: "280"}
        ]} />
      </svg>
      """
    end

    def render_empty(assigns) do
      ~H"""
      <svg>
        <.bar_totals totals={[]} />
      </svg>
      """
    end

    def render_custom_font(assigns) do
      ~H"""
      <svg>
        <.bar_totals
          totals={[%{x: 100.0, y: 50.0, label: "100"}]}
          font_size="12"
        />
      </svg>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <svg>
        <.bar_totals
          totals={[%{x: 100.0, y: 50.0, label: "100"}]}
          class="custom-class"
        />
      </svg>
      """
    end

    def render_with_theme(assigns) do
      ~H"""
      <svg>
        <.bar_totals
          totals={[%{x: 100.0, y: 50.0, label: "100"}]}
          theme={%{axis: %{font_size: "14", label_class: "fill-primary"}}}
        />
      </svg>
      """
    end
  end

  describe "bar_totals/1" do
    test "renders text elements for each total" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "350"
      assert html =~ "280"
      assert html =~ "<text"
    end

    test "renders empty group for empty totals" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<g"
      refute html =~ "<text"
    end

    test "positions text using x and y with offset" do
      html = render_component(&H.render_default/1, %{})
      # y=20.0 - offset(6) = 14.0
      assert html =~ ~s(x="72.0")
      assert html =~ ~s(y="14.0")
    end

    test "uses custom font_size when provided" do
      html = render_component(&H.render_custom_font/1, %{})
      assert html =~ ~s(font-size="12")
    end

    test "uses custom class when provided" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "custom-class"
    end

    test "applies theme font_size" do
      html = render_component(&H.render_with_theme/1, %{})
      assert html =~ ~s(font-size="14")
    end

    test "uses text-anchor middle" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(text-anchor="middle")
    end
  end
end
