defmodule PhiaUi.Components.HoverCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.HoverCard

    def render_default(assigns) do
      ~H"""
      <.hover_card id="hc1">
        <.hover_card_trigger hover_card_id="hc1">
          Hover me
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="hc1">
          <p>Card content</p>
        </.hover_card_content>
      </.hover_card>
      """
    end

    def render_with_delays(assigns) do
      ~H"""
      <.hover_card id="hc2" open_delay={500} close_delay={100}>
        <.hover_card_trigger hover_card_id="hc2">Trigger</.hover_card_trigger>
        <.hover_card_content hover_card_id="hc2">Content</.hover_card_content>
      </.hover_card>
      """
    end

    def render_with_side(assigns) do
      ~H"""
      <.hover_card id="hc3" side="top">
        <.hover_card_trigger hover_card_id="hc3">Trigger</.hover_card_trigger>
        <.hover_card_content hover_card_id="hc3" side="top">Top content</.hover_card_content>
      </.hover_card>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.hover_card id="hc4" class="card-wrapper">
        <.hover_card_trigger hover_card_id="hc4" class="trigger-class">
          Trigger
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="hc4" class="content-class">
          Content
        </.hover_card_content>
      </.hover_card>
      """
    end

    def render_all_sides(assigns) do
      ~H"""
      <div>
        <.hover_card id="s-top" side="top">
          <.hover_card_trigger hover_card_id="s-top">T</.hover_card_trigger>
          <.hover_card_content hover_card_id="s-top" side="top">Top</.hover_card_content>
        </.hover_card>
        <.hover_card id="s-bottom" side="bottom">
          <.hover_card_trigger hover_card_id="s-bottom">B</.hover_card_trigger>
          <.hover_card_content hover_card_id="s-bottom" side="bottom">Bottom</.hover_card_content>
        </.hover_card>
        <.hover_card id="s-left" side="left">
          <.hover_card_trigger hover_card_id="s-left">L</.hover_card_trigger>
          <.hover_card_content hover_card_id="s-left" side="left">Left</.hover_card_content>
        </.hover_card>
        <.hover_card id="s-right" side="right">
          <.hover_card_trigger hover_card_id="s-right">R</.hover_card_trigger>
          <.hover_card_content hover_card_id="s-right" side="right">Right</.hover_card_content>
        </.hover_card>
      </div>
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_with_delays, do: render_component(&H.render_with_delays/1, %{})
  defp render_with_side, do: render_component(&H.render_with_side/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_all_sides, do: render_component(&H.render_all_sides/1, %{})

  # ---------------------------------------------------------------------------
  # hover_card/1 — container
  # ---------------------------------------------------------------------------

  describe "hover_card/1 — container" do
    test "renders with id attribute" do
      assert render_default() =~ ~s(id="hc1")
    end

    test "has phx-hook='PhiaHoverCard'" do
      assert render_default() =~ ~s(phx-hook="PhiaHoverCard")
    end

    test "has data-trigger='hover' for hover activation" do
      assert render_default() =~ ~s(data-trigger="hover")
    end

    test "renders default open_delay as data attribute (300ms)" do
      assert render_default() =~ ~s(data-open-delay="300")
    end

    test "renders default close_delay as data attribute (200ms)" do
      assert render_default() =~ ~s(data-close-delay="200")
    end

    test "renders default side as data attribute (bottom)" do
      assert render_default() =~ ~s(data-side="bottom")
    end

    test "renders custom open_delay" do
      assert render_with_delays() =~ ~s(data-open-delay="500")
    end

    test "renders custom close_delay" do
      assert render_with_delays() =~ ~s(data-close-delay="100")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "card-wrapper"
    end

    test "renders inner content (trigger and panel)" do
      html = render_default()
      assert html =~ "Hover me"
      assert html =~ "Card content"
    end
  end

  # ---------------------------------------------------------------------------
  # hover_card_trigger/1
  # ---------------------------------------------------------------------------

  describe "hover_card_trigger/1" do
    test "renders trigger slot content" do
      assert render_default() =~ "Hover me"
    end

    test "has data-hover-card-trigger marker" do
      assert render_default() =~ "data-hover-card-trigger"
    end

    test "has aria-describedby pointing to content id" do
      assert render_default() =~ ~s(aria-describedby="hc1-content")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "trigger-class"
    end
  end

  # ---------------------------------------------------------------------------
  # hover_card_content/1
  # ---------------------------------------------------------------------------

  describe "hover_card_content/1 — structure" do
    test "renders content slot" do
      assert render_default() =~ "Card content"
    end

    test "has id matching hover_card_id-content" do
      assert render_default() =~ ~s(id="hc1-content")
    end

    test "has role='tooltip' for screen readers" do
      assert render_default() =~ ~s(role="tooltip")
    end

    test "hidden by default" do
      html = render_default()
      assert html =~ "hidden" or html =~ "opacity-0" or html =~ "invisible"
    end

    test "has data-hover-card-content marker" do
      assert render_default() =~ "data-hover-card-content"
    end

    test "uses semantic token bg-popover (no hardcoded color)" do
      html = render_default()
      assert html =~ "bg-popover"
      refute html =~ "bg-gray"
      refute html =~ "bg-[#"
    end

    test "uses semantic token text-popover-foreground" do
      assert render_default() =~ "text-popover-foreground"
    end

    test "has border, rounded-md, shadow-md, p-4" do
      html = render_default()
      assert html =~ "border"
      assert html =~ "rounded-md"
      assert html =~ "shadow-md"
      assert html =~ "p-4"
    end

    test "has data-side='bottom' by default" do
      assert render_default() =~ ~s(data-side="bottom")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "content-class"
    end
  end

  # ---------------------------------------------------------------------------
  # side attr on content
  # ---------------------------------------------------------------------------

  describe "hover_card_content/1 — side" do
    test ":side='top' sets data-side='top'" do
      assert render_with_side() =~ ~s(data-side="top")
    end

    test "all four sides are supported" do
      html = render_all_sides()
      assert html =~ ~s(data-side="top")
      assert html =~ ~s(data-side="bottom")
      assert html =~ ~s(data-side="left")
      assert html =~ ~s(data-side="right")
    end
  end
end
