defmodule PhiaUi.Components.StepperNavTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.StepperNav

    def render_horizontal(assigns) do
      ~H"""
      <.stepper_nav current_step={2} orientation={:horizontal} variant={:default}>
        <.stepper_nav_item step={1} state={:complete}>Account</.stepper_nav_item>
        <.stepper_nav_item step={2} state={:active}>Profile</.stepper_nav_item>
        <.stepper_nav_item step={3} state={:pending}>Review</.stepper_nav_item>
      </.stepper_nav>
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.stepper_nav current_step={1} orientation={:vertical} variant={:default}>
        <.stepper_nav_item step={1} state={:active}>Step One</.stepper_nav_item>
        <.stepper_nav_item step={2} state={:pending}>Step Two</.stepper_nav_item>
      </.stepper_nav>
      """
    end

    def render_error(assigns) do
      ~H"""
      <.stepper_nav current_step={2} orientation={:horizontal} variant={:default}>
        <.stepper_nav_item step={1} state={:complete}>Step One</.stepper_nav_item>
        <.stepper_nav_item step={2} state={:error}>Step Two</.stepper_nav_item>
      </.stepper_nav>
      """
    end

    def render_clickable(assigns) do
      ~H"""
      <.stepper_nav current_step={3} orientation={:horizontal} variant={:default}>
        <.stepper_nav_item step={1} state={:complete} on_click="go-to-step" >Step One</.stepper_nav_item>
        <.stepper_nav_item step={2} state={:complete} on_click="go-to-step">Step Two</.stepper_nav_item>
        <.stepper_nav_item step={3} state={:active}>Step Three</.stepper_nav_item>
      </.stepper_nav>
      """
    end
  end

  defp render_horizontal, do: render_component(&H.render_horizontal/1, %{})
  defp render_vertical, do: render_component(&H.render_vertical/1, %{})
  defp render_error, do: render_component(&H.render_error/1, %{})
  defp render_clickable, do: render_component(&H.render_clickable/1, %{})

  describe "stepper_nav/1" do
    test "renders role=list" do
      assert render_horizontal() =~ ~s(role="list")
    end

    test "horizontal orientation uses flex" do
      assert render_horizontal() =~ "flex"
    end

    test "vertical orientation uses flex-col" do
      assert render_vertical() =~ "flex-col"
    end
  end

  describe "stepper_nav_item/1 — states" do
    test "active state has bg-primary" do
      assert render_horizontal() =~ "bg-primary"
    end

    test "active state has text-primary-foreground" do
      assert render_horizontal() =~ "text-primary-foreground"
    end

    test "pending state has text-muted-foreground" do
      assert render_horizontal() =~ "text-muted-foreground"
    end

    test "complete state renders checkmark SVG (polyline)" do
      assert render_horizontal() =~ "polyline"
    end

    test "error state has bg-destructive" do
      assert render_error() =~ "bg-destructive"
    end

    test "error state has text-destructive-foreground" do
      assert render_error() =~ "text-destructive-foreground"
    end

    test "error state renders X SVG (line elements)" do
      html = render_error()
      assert html =~ "<line"
    end

    test "active step has aria-current=step" do
      assert render_horizontal() =~ ~s(aria-current="step")
    end
  end

  describe "stepper_nav_item/1 — clickable" do
    test "on_click sets phx-click" do
      assert render_clickable() =~ ~s(phx-click="go-to-step")
    end
  end
end
