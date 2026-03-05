defmodule PhiaUi.Components.TooltipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Tooltip

    def render_default(assigns) do
      ~H"""
      <.tooltip id="tip1">
        <.tooltip_trigger tooltip_id="tip1">
          <button>Hover me</button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="tip1">
          Helpful text
        </.tooltip_content>
      </.tooltip>
      """
    end

    def render_positioned(assigns) do
      ~H"""
      <.tooltip id="tip2">
        <.tooltip_trigger tooltip_id="tip2">
          <button>Trigger</button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="tip2" position={:bottom}>
          Bottom tooltip
        </.tooltip_content>
      </.tooltip>
      """
    end

    def render_with_delay(assigns) do
      ~H"""
      <.tooltip id="tip3" delay_ms={500}>
        <.tooltip_trigger tooltip_id="tip3">
          <button>Slow hover</button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="tip3">
          Delayed tooltip
        </.tooltip_content>
      </.tooltip>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.tooltip id="tip4" class="custom-wrapper">
        <.tooltip_trigger tooltip_id="tip4">
          <button>Trigger</button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="tip4" class="custom-content">
          Content
        </.tooltip_content>
      </.tooltip>
      """
    end

    def render_positions(assigns) do
      ~H"""
      <div>
        <.tooltip id="pos-top">
          <.tooltip_trigger tooltip_id="pos-top"><span>T</span></.tooltip_trigger>
          <.tooltip_content tooltip_id="pos-top" position={:top}>Top</.tooltip_content>
        </.tooltip>
        <.tooltip id="pos-bottom">
          <.tooltip_trigger tooltip_id="pos-bottom"><span>B</span></.tooltip_trigger>
          <.tooltip_content tooltip_id="pos-bottom" position={:bottom}>Bottom</.tooltip_content>
        </.tooltip>
        <.tooltip id="pos-left">
          <.tooltip_trigger tooltip_id="pos-left"><span>L</span></.tooltip_trigger>
          <.tooltip_content tooltip_id="pos-left" position={:left}>Left</.tooltip_content>
        </.tooltip>
        <.tooltip id="pos-right">
          <.tooltip_trigger tooltip_id="pos-right"><span>R</span></.tooltip_trigger>
          <.tooltip_content tooltip_id="pos-right" position={:right}>Right</.tooltip_content>
        </.tooltip>
      </div>
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_positioned, do: render_component(&H.render_positioned/1, %{})
  defp render_with_delay, do: render_component(&H.render_with_delay/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_positions, do: render_component(&H.render_positions/1, %{})

  # ---------------------------------------------------------------------------
  # tooltip/1
  # ---------------------------------------------------------------------------

  describe "tooltip/1 — wrapper" do
    test "renders wrapper element" do
      assert render_default() =~ "tip1"
    end

    test "has phx-hook='PhiaTooltip'" do
      assert render_default() =~ ~s(phx-hook="PhiaTooltip")
    end

    test "has id attribute" do
      assert render_default() =~ ~s(id="tip1")
    end

    test "has data-delay attribute with default 200" do
      assert render_default() =~ ~s(data-delay="200")
    end

    test "custom delay_ms sets data-delay" do
      assert render_with_delay() =~ ~s(data-delay="500")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "custom-wrapper"
    end
  end

  # ---------------------------------------------------------------------------
  # tooltip_trigger/1
  # ---------------------------------------------------------------------------

  describe "tooltip_trigger/1" do
    test "renders trigger inner content" do
      assert render_default() =~ "Hover me"
    end

    test "has data-tooltip-trigger marker" do
      assert render_default() =~ "data-tooltip-trigger"
    end

    test "has aria-describedby pointing to content id" do
      assert render_default() =~ ~s(aria-describedby="tip1-content")
    end
  end

  # ---------------------------------------------------------------------------
  # tooltip_content/1
  # ---------------------------------------------------------------------------

  describe "tooltip_content/1 — structure" do
    test "renders content text" do
      assert render_default() =~ "Helpful text"
    end

    test "has id matching tooltip_id-content" do
      assert render_default() =~ ~s(id="tip1-content")
    end

    test "has role='tooltip'" do
      assert render_default() =~ ~s(role="tooltip")
    end

    test "has data-tooltip-content marker" do
      assert render_default() =~ "data-tooltip-content"
    end

    test "hidden by default (opacity-0 or invisible class)" do
      html = render_default()
      assert html =~ "opacity-0" or html =~ "invisible" or html =~ "hidden"
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "custom-content"
    end
  end

  # ---------------------------------------------------------------------------
  # position attr
  # ---------------------------------------------------------------------------

  describe "tooltip_content/1 — position" do
    test "default position is :top" do
      assert render_default() =~ ~s(data-position="top")
    end

    test ":bottom sets data-position='bottom'" do
      assert render_positioned() =~ ~s(data-position="bottom")
    end

    test "all four positions are supported" do
      html = render_positions()
      assert html =~ ~s(data-position="top")
      assert html =~ ~s(data-position="bottom")
      assert html =~ ~s(data-position="left")
      assert html =~ ~s(data-position="right")
    end
  end

  # ---------------------------------------------------------------------------
  # aria coordination
  # ---------------------------------------------------------------------------

  describe "aria coordination between trigger and content" do
    test "aria-describedby matches tooltip_content id" do
      html = render_default()
      assert html =~ ~s(aria-describedby="tip1-content")
      assert html =~ ~s(id="tip1-content")
    end
  end
end
