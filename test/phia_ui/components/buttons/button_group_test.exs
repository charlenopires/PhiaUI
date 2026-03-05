defmodule PhiaUi.Components.ButtonGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ButtonGroup

    def render_horizontal(assigns) do
      ~H"""
      <.button_group>
        <button>First</button>
        <button>Second</button>
        <button>Third</button>
      </.button_group>
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.button_group orientation="vertical">
        <button>Top</button>
        <button>Bottom</button>
      </.button_group>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.button_group class="my-custom-class">
        <button>One</button>
        <button>Two</button>
      </.button_group>
      """
    end

    def render_with_data_attr(assigns) do
      ~H"""
      <.button_group data-testid="btn-group">
        <button>One</button>
        <button>Two</button>
      </.button_group>
      """
    end
  end

  describe "button_group/1" do
    test "renders horizontal group by default" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "inline-flex"
      assert html =~ "First"
      assert html =~ "Second"
      assert html =~ "Third"
    end

    test "renders vertical group" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "flex-col"
      assert html =~ "Top"
      assert html =~ "Bottom"
    end

    test "horizontal uses -ml-px for shared borders" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "-ml-px"
    end

    test "vertical uses -mt-px for shared borders" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "-mt-px"
    end

    test "horizontal applies rounded-r-none to first child" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "rounded-r-none"
    end

    test "horizontal applies rounded-l-none to last child" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "rounded-l-none"
    end

    test "horizontal applies rounded-none to middle children" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "rounded-none"
    end

    test "vertical applies rounded-b-none to first child" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "rounded-b-none"
    end

    test "vertical applies rounded-t-none to last child" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "rounded-t-none"
    end

    test "renders a div wrapper" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "<div"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-custom-class"
    end

    test "passes rest attrs to root element" do
      html = render_component(&H.render_with_data_attr/1, %{})
      assert html =~ ~s(data-testid="btn-group")
    end
  end
end
