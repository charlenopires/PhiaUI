defmodule PhiaUi.Components.PopoverTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Popover

    def render_default(assigns) do
      ~H"""
      <.popover id="pop1">
        <.popover_trigger popover_id="pop1">
          Open
        </.popover_trigger>
        <.popover_content popover_id="pop1">
          <p>Some content</p>
        </.popover_content>
      </.popover>
      """
    end

    def render_positioned(assigns) do
      ~H"""
      <.popover id="pop2">
        <.popover_trigger popover_id="pop2">Trigger</.popover_trigger>
        <.popover_content popover_id="pop2" position={:top}>
          Top popover
        </.popover_content>
      </.popover>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.popover id="pop3" class="wrapper-class">
        <.popover_trigger popover_id="pop3" class="trigger-class">Trigger</.popover_trigger>
        <.popover_content popover_id="pop3" class="content-class">Content</.popover_content>
      </.popover>
      """
    end

    def render_with_form(assigns) do
      ~H"""
      <.popover id="pop4">
        <.popover_trigger popover_id="pop4">Settings</.popover_trigger>
        <.popover_content popover_id="pop4">
          <input type="text" name="name" />
          <button type="submit">Save</button>
        </.popover_content>
      </.popover>
      """
    end

    def render_positions(assigns) do
      ~H"""
      <div>
        <.popover id="p-top">
          <.popover_trigger popover_id="p-top">T</.popover_trigger>
          <.popover_content popover_id="p-top" position={:top}>Top</.popover_content>
        </.popover>
        <.popover id="p-bottom">
          <.popover_trigger popover_id="p-bottom">B</.popover_trigger>
          <.popover_content popover_id="p-bottom" position={:bottom}>Bottom</.popover_content>
        </.popover>
        <.popover id="p-left">
          <.popover_trigger popover_id="p-left">L</.popover_trigger>
          <.popover_content popover_id="p-left" position={:left}>Left</.popover_content>
        </.popover>
        <.popover id="p-right">
          <.popover_trigger popover_id="p-right">R</.popover_trigger>
          <.popover_content popover_id="p-right" position={:right}>Right</.popover_content>
        </.popover>
      </div>
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_positioned, do: render_component(&H.render_positioned/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_with_form, do: render_component(&H.render_with_form/1, %{})
  defp render_positions, do: render_component(&H.render_positions/1, %{})

  # ---------------------------------------------------------------------------
  # popover/1
  # ---------------------------------------------------------------------------

  describe "popover/1 — wrapper" do
    test "renders wrapper element with id" do
      assert render_default() =~ ~s(id="pop1")
    end

    test "has phx-hook='PhiaPopover'" do
      assert render_default() =~ ~s(phx-hook="PhiaPopover")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "wrapper-class"
    end
  end

  # ---------------------------------------------------------------------------
  # popover_trigger/1
  # ---------------------------------------------------------------------------

  describe "popover_trigger/1" do
    test "renders trigger content" do
      assert render_default() =~ "Open"
    end

    test "has aria-controls pointing to content id" do
      assert render_default() =~ ~s(aria-controls="pop1-content")
    end

    test "has aria-expanded='false' by default (closed)" do
      assert render_default() =~ ~s(aria-expanded="false")
    end

    test "has data-popover-trigger marker" do
      assert render_default() =~ "data-popover-trigger"
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "trigger-class"
    end
  end

  # ---------------------------------------------------------------------------
  # popover_content/1
  # ---------------------------------------------------------------------------

  describe "popover_content/1 — structure" do
    test "renders content" do
      assert render_default() =~ "Some content"
    end

    test "has id matching popover_id-content" do
      assert render_default() =~ ~s(id="pop1-content")
    end

    test "has role='dialog'" do
      assert render_default() =~ ~s(role="dialog")
    end

    test "has aria-modal='true'" do
      assert render_default() =~ ~s(aria-modal="true")
    end

    test "hidden by default" do
      html = render_default()
      assert html =~ "hidden" or html =~ "opacity-0" or html =~ "invisible"
    end

    test "has data-popover-content marker" do
      assert render_default() =~ "data-popover-content"
    end

    test "has data-position with default :bottom" do
      assert render_default() =~ ~s(data-position="bottom")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "content-class"
    end
  end

  # ---------------------------------------------------------------------------
  # position attr
  # ---------------------------------------------------------------------------

  describe "popover_content/1 — position" do
    test ":top sets data-position='top'" do
      assert render_positioned() =~ ~s(data-position="top")
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
  # arbitrary content
  # ---------------------------------------------------------------------------

  describe "popover_content/1 — arbitrary content" do
    test "renders form fields inside popover" do
      html = render_with_form()
      assert html =~ ~s(type="text")
      assert html =~ "Save"
    end
  end

  # ---------------------------------------------------------------------------
  # aria coordination
  # ---------------------------------------------------------------------------

  describe "aria coordination" do
    test "aria-controls matches popover_content id" do
      html = render_default()
      assert html =~ ~s(aria-controls="pop1-content")
      assert html =~ ~s(id="pop1-content")
    end
  end
end
