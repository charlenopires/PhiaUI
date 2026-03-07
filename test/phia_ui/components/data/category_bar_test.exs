defmodule PhiaUi.Components.CategoryBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CategoryBar

    def render_basic(assigns) do
      ~H"""
      <.category_bar values={[60, 40]} colors={[:blue, :green]} />
      """
    end

    def render_with_labels(assigns) do
      ~H"""
      <.category_bar
        values={[50, 30, 20]}
        colors={[:blue, :orange, :red]}
        labels={["Direct", "Referral", "Other"]}
        show_labels={true}
      />
      """
    end

    def render_with_marker(assigns) do
      ~H"""
      <.category_bar values={[50, 50]} colors={[:purple, :pink]} marker_value={30} />
      """
    end

    def render_all_colors(assigns) do
      ~H"""
      <.category_bar
        values={[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]}
        colors={[:blue, :green, :red, :orange, :purple, :pink, :yellow, :teal, :indigo, :cyan]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.category_bar values={[100]} colors={[:blue]} class="my-class" />
      """
    end
  end

  describe "category_bar/1" do
    test "renders a container div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "blue segment has bg-blue-500" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-blue-500"
    end

    test "green segment has bg-green-500" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-green-500"
    end

    test "normalizes values to 100% proportions" do
      html = render_component(&H.render_basic/1, %{})
      # 60/(60+40)*100 = 60.0%
      assert html =~ "60.0%"
      # 40/(60+40)*100 = 40.0%
      assert html =~ "40.0%"
    end

    test "shows labels when show_labels is true" do
      html = render_component(&H.render_with_labels/1, %{})
      assert html =~ "Direct"
      assert html =~ "Referral"
      assert html =~ "Other"
    end

    test "does not show labels by default" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "Direct"
    end

    test "renders marker when marker_value is set" do
      html = render_component(&H.render_with_marker/1, %{})
      assert html =~ "left: 30.0%"
    end

    test "all color atoms render static bg classes" do
      html = render_component(&H.render_all_colors/1, %{})
      assert html =~ "bg-blue-500"
      assert html =~ "bg-green-500"
      assert html =~ "bg-red-500"
      assert html =~ "bg-orange-500"
      assert html =~ "bg-purple-500"
      assert html =~ "bg-pink-500"
      assert html =~ "bg-yellow-500"
      assert html =~ "bg-teal-500"
      assert html =~ "bg-indigo-500"
      assert html =~ "bg-cyan-500"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-class"
    end
  end
end
