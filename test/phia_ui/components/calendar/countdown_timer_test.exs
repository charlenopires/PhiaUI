defmodule PhiaUi.Components.CountdownTimerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CountdownTimer

    def render_circular(assigns) do
      ~H"""
      <.countdown_timer minutes={31} seconds={47} total_seconds={3600} variant={:circular} label="60 min" />
      """
    end

    def render_flat(assigns) do
      ~H"""
      <.countdown_timer minutes={31} seconds={47} total_seconds={3600} variant={:flat} label="60 min" />
      """
    end

    def render_flat_with_buttons(assigns) do
      ~H"""
      <.countdown_timer minutes={31} seconds={47} total_seconds={3600}
        variant={:flat} on_pause="pause" on_stop="stop" />
      """
    end

    def render_zero_seconds(assigns) do
      ~H"""
      <.countdown_timer minutes={5} seconds={0} total_seconds={300} />
      """
    end

    def render_single_digit_seconds(assigns) do
      ~H"""
      <.countdown_timer minutes={5} seconds={7} total_seconds={300} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.countdown_timer minutes={10} seconds={0} total_seconds={600} class="my-timer" />
      """
    end

    def render_no_label(assigns) do
      ~H"""
      <.countdown_timer minutes={10} seconds={30} total_seconds={600} />
      """
    end

    def render_flat_no_buttons(assigns) do
      ~H"""
      <.countdown_timer minutes={10} seconds={0} total_seconds={600} variant={:flat} />
      """
    end
  end

  describe "countdown_timer/1 — circular variant" do
    test "renders SVG element" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "<svg"
    end

    test "renders time 31:47" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "31:47"
    end

    test "renders label 60 min" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "60 min"
    end

    test "arc circle has stroke-primary class" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "stroke-primary"
    end

    test "track circle has stroke-muted class" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "stroke-muted"
    end

    test "SVG has -rotate-90 transform class" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "-rotate-90"
    end

    test "arc circle has stroke-dasharray attribute" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "stroke-dasharray"
    end

    test "has rounded-2xl on wrapper" do
      html = render_component(&H.render_circular/1, %{})
      assert html =~ "rounded-2xl"
    end
  end

  describe "countdown_timer/1 — flat variant" do
    test "renders time 31:47" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "31:47"
    end

    test "renders label 60 min" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "60 min"
    end

    test "has bg-muted pill" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "bg-muted"
    end

    test "has progress bar with bg-primary class" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "bg-primary"
    end

    test "progress bar has width style attribute" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "width:"
    end

    test "on_pause renders button with phx-click=pause" do
      html = render_component(&H.render_flat_with_buttons/1, %{})
      assert html =~ ~s(phx-click="pause")
    end

    test "on_stop renders button with phx-click=stop" do
      html = render_component(&H.render_flat_with_buttons/1, %{})
      assert html =~ ~s(phx-click="stop")
    end

    test "no buttons rendered when on_pause and on_stop not set" do
      html = render_component(&H.render_flat_no_buttons/1, %{})
      refute html =~ "phx-click"
    end

    test "has rounded-2xl on wrapper" do
      html = render_component(&H.render_flat/1, %{})
      assert html =~ "rounded-2xl"
    end
  end

  describe "countdown_timer/1 — time formatting" do
    test "zero seconds formats as 5:00 not 5:0" do
      html = render_component(&H.render_zero_seconds/1, %{})
      assert html =~ "5:00"
      refute html =~ "5:0\""
    end

    test "single digit seconds formats as 5:07" do
      html = render_component(&H.render_single_digit_seconds/1, %{})
      assert html =~ "5:07"
    end
  end

  describe "countdown_timer/1 — general" do
    test "custom class applied to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-timer"
    end

    test "no label element when label is nil" do
      html = render_component(&H.render_no_label/1, %{})
      refute html =~ "60 min"
    end
  end
end
