defmodule PhiaUi.Components.DirectionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Direction

    def render_ltr(assigns) do
      ~H"""
      <.direction dir="ltr">Hello</.direction>
      """
    end

    def render_rtl(assigns) do
      ~H"""
      <.direction dir="rtl">مرحبا</.direction>
      """
    end

    def render_default(assigns) do
      ~H"""
      <.direction>Default</.direction>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.direction class="my-class">Content</.direction>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.direction data-testid="direction-wrapper">Extra</.direction>
      """
    end
  end

  describe "direction/1" do
    test "renders with dir=ltr" do
      html = render_component(&H.render_ltr/1, %{})
      assert html =~ ~s(dir="ltr")
    end

    test "renders with dir=rtl" do
      html = render_component(&H.render_rtl/1, %{})
      assert html =~ ~s(dir="rtl")
    end

    test "defaults to dir=ltr when not specified" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(dir="ltr")
    end

    test "renders inner content for ltr" do
      html = render_component(&H.render_ltr/1, %{})
      assert html =~ "Hello"
    end

    test "renders inner content for rtl" do
      html = render_component(&H.render_rtl/1, %{})
      assert html =~ "مرحبا"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-class"
    end

    test "passes extra HTML attributes via rest" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="direction-wrapper")
    end

    test "renders a div wrapper" do
      html = render_component(&H.render_ltr/1, %{})
      assert html =~ "<div"
    end
  end
end
