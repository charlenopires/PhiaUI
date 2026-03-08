defmodule PhiaUi.Components.Data.DeltaBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.DeltaBar

    def render_positive(assigns) do
      ~H"""
      <.delta_bar value={25} />
      """
    end

    def render_negative(assigns) do
      ~H"""
      <.delta_bar value={-40} />
      """
    end

    def render_inverse(assigns) do
      ~H"""
      <.delta_bar value={30} is_increase_positive={false} />
      """
    end

    def render_animated(assigns) do
      ~H"""
      <.delta_bar value={50} show_animation />
      """
    end

    def render_with_tooltip(assigns) do
      ~H"""
      <.delta_bar value={25} tooltip="25% increase" />
      """
    end

    def render_zero(assigns) do
      ~H"""
      <.delta_bar value={0} />
      """
    end
  end

  describe "delta_bar/1" do
    test "renders positive delta with green bar on right" do
      html = render_component(&H.render_positive/1, %{})
      assert html =~ "bg-emerald-500"
      assert html =~ "width: 25%"
    end

    test "renders negative delta with red bar on left" do
      html = render_component(&H.render_negative/1, %{})
      assert html =~ "bg-rose-500"
      assert html =~ "width: 40%"
    end

    test "renders inverse coloring when increase is not positive" do
      html = render_component(&H.render_inverse/1, %{})
      assert html =~ "bg-rose-500"
    end

    test "renders center divider" do
      html = render_component(&H.render_positive/1, %{})
      assert html =~ "ring-2"
      assert html =~ "bg-foreground"
    end

    test "renders with animation class" do
      html = render_component(&H.render_animated/1, %{})
      assert html =~ "transition-all"
      assert html =~ "duration-500"
    end

    test "renders tooltip title" do
      html = render_component(&H.render_with_tooltip/1, %{})
      assert html =~ "25% increase"
    end

    test "renders zero value without bar" do
      html = render_component(&H.render_zero/1, %{})
      assert html =~ "bg-muted"
    end
  end
end
