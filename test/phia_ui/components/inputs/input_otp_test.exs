defmodule PhiaUi.Components.InputOtpTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.InputOtp

    def render_simple(assigns) do
      ~H"""
      <.input_otp id="otp" name="otp" value="" />
      """
    end

    def render_with_length(assigns) do
      ~H"""
      <.input_otp id="otp-4" name="otp" value="" length={4} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.input_otp id="otp-val" name="otp" value="123456" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.input_otp id="otp-dis" name="otp" value="" disabled={true} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.input_otp id="otp-cls" name="otp" value="" class="custom-otp-class" />
      """
    end

    def render_group(assigns) do
      ~H"""
      <.input_otp_group id="otp-group">
        <.input_otp_slot index={0} name="otp[0]" value="1" />
        <.input_otp_slot index={1} name="otp[1]" value="2" />
      </.input_otp_group>
      """
    end

    def render_group_with_class(assigns) do
      ~H"""
      <.input_otp_group id="otp-group-cls" class="my-group-class">
        <.input_otp_slot index={0} name="otp[0]" value="" />
      </.input_otp_group>
      """
    end

    def render_slot_basic(assigns) do
      ~H"""
      <.input_otp_slot index={0} name="otp[0]" value="" />
      """
    end

    def render_slot_with_value(assigns) do
      ~H"""
      <.input_otp_slot index={2} name="otp[2]" value="7" />
      """
    end

    def render_slot_disabled(assigns) do
      ~H"""
      <.input_otp_slot index={0} name="otp[0]" value="" disabled={true} />
      """
    end

    def render_slot_with_class(assigns) do
      ~H"""
      <.input_otp_slot index={0} name="otp[0]" value="" class="custom-slot-class" />
      """
    end

    def render_slot_index_1(assigns) do
      ~H"""
      <.input_otp_slot index={1} name="otp[1]" value="" />
      """
    end

    def render_separator(assigns) do
      ~H"""
      <.input_otp_separator />
      """
    end

    def render_separator_with_class(assigns) do
      ~H"""
      <.input_otp_separator class="custom-sep-class" />
      """
    end

    def render_composable(assigns) do
      ~H"""
      <.input_otp_group id="composable-group">
        <.input_otp_slot index={0} name="otp[0]" value="A" />
        <.input_otp_slot index={1} name="otp[1]" value="B" />
        <.input_otp_separator />
        <.input_otp_slot index={2} name="otp[2]" value="C" />
      </.input_otp_group>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # input_otp/1
  # ---------------------------------------------------------------------------

  describe "input_otp/1" do
    test "renders correct default number of slots (6)" do
      html = render_component(&H.render_simple/1, %{})
      # 6 slots = 6 inputs with type="text"
      count = html |> String.split(~s(type="text")) |> length() |> Kernel.-(1)
      assert count == 6
    end

    test "renders with custom length" do
      html = render_component(&H.render_with_length/1, %{})
      count = html |> String.split(~s(type="text")) |> length() |> Kernel.-(1)
      assert count == 4
    end

    test "renders with value spread across slots" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="1")
      assert html =~ ~s(value="2")
      assert html =~ ~s(value="3")
    end

    test "disabled propagates to all slots" do
      html = render_component(&H.render_disabled/1, %{})
      # There should be disabled attributes on the inputs
      assert html =~ "disabled"
    end

    test "custom class is applied" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-otp-class"
    end

    test "renders group wrapper div" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(role="group")
    end

    test "group wrapper has aria role=group" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(role="group")
    end

    test "slot names follow the name[index] pattern" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(name="otp[0]")
      assert html =~ ~s(name="otp[1]")
    end
  end

  # ---------------------------------------------------------------------------
  # input_otp_group/1
  # ---------------------------------------------------------------------------

  describe "input_otp_group/1" do
    test "renders div with role=group" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ ~s(role="group")
    end

    test "renders inner_block content" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ ~s(name="otp[0]")
      assert html =~ ~s(name="otp[1]")
    end

    test "applies custom class" do
      html = render_component(&H.render_group_with_class/1, %{})
      assert html =~ "my-group-class"
    end

    test "has flex layout classes" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "flex"
      assert html =~ "items-center"
    end
  end

  # ---------------------------------------------------------------------------
  # input_otp_slot/1
  # ---------------------------------------------------------------------------

  describe "input_otp_slot/1" do
    test "renders input type=text" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ ~s(type="text")
    end

    test "renders maxlength=1" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ ~s(maxlength="1")
    end

    test "renders aria-label with digit number (1-based)" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ ~s(aria-label="Digit 1")
    end

    test "renders inputmode=numeric" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ ~s(inputmode="numeric")
    end

    test "has core styling classes" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ "h-10"
      assert html =~ "w-10"
      assert html =~ "text-center"
    end

    test "disabled attr is set when disabled=true" do
      html = render_component(&H.render_slot_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "autocomplete=one-time-code on first slot (index 0)" do
      html = render_component(&H.render_slot_basic/1, %{})
      assert html =~ ~s(autocomplete="one-time-code")
    end

    test "no autocomplete on other slots (index > 0)" do
      html = render_component(&H.render_slot_index_1/1, %{})
      refute html =~ ~s(autocomplete="one-time-code")
    end

    test "applies custom class" do
      html = render_component(&H.render_slot_with_class/1, %{})
      assert html =~ "custom-slot-class"
    end
  end

  # ---------------------------------------------------------------------------
  # input_otp_separator/1
  # ---------------------------------------------------------------------------

  describe "input_otp_separator/1" do
    test "renders a separator div" do
      html = render_component(&H.render_separator/1, %{})
      assert html =~ "<div"
    end

    test "has aria-hidden=true" do
      html = render_component(&H.render_separator/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "contains a separator character" do
      html = render_component(&H.render_separator/1, %{})
      assert html =~ "-"
    end

    test "applies custom class" do
      html = render_component(&H.render_separator_with_class/1, %{})
      assert html =~ "custom-sep-class"
    end
  end
end
