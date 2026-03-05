defmodule PhiaUi.Components.MonthPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MonthPicker

    def render_default(assigns) do
      ~H"""
      <.month_picker id="mp1" name="month" />
      """
    end

    def render_with_id(assigns) do
      ~H"""
      <.month_picker id="mp2" name="month" />
      """
    end

    def render_with_name(assigns) do
      ~H"""
      <.month_picker id="mp3" name="billing_month" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.month_picker id="mp4" name="month" value="2026-03" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.month_picker id="mp5" name="month" label="Billing Month" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.month_picker id="mp6" name="month" label="Period" description="Select the billing period" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.month_picker id="mp7" name="month" disabled={true} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.month_picker id="mp8" name="month" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.month_picker id="mp9" name="month" size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.month_picker id="mp10" name="month" class="my-month-class" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.month_picker id="mp11" name="month" errors={["can't be blank"]} />
      """
    end

    def render_no_errors(assigns) do
      ~H"""
      <.month_picker id="mp12" name="month" errors={[]} />
      """
    end
  end

  describe "month_picker/1" do
    test "renders input type=month" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="month")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_with_id/1, %{})
      assert html =~ ~s(id="mp2")
    end

    test "renders with name attribute" do
      html = render_component(&H.render_with_name/1, %{})
      assert html =~ ~s(name="billing_month")
    end

    test "renders value 2026-03" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="2026-03")
    end

    test "renders label text" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Billing Month"
    end

    test "label has for attribute matching id" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(<label)
      assert html =~ ~s(for="mp5")
    end

    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Select the billing period"
    end

    test "renders disabled input" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "size :sm renders h-8" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-8"
    end

    test "size :default renders h-10" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-10"
    end

    test "size :lg renders h-12" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-12"
    end

    test "custom class is applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-month-class"
    end

    test "renders rounded-md" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-md"
    end

    test "renders border" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border"
    end

    test "renders focus-visible ring styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "focus-visible:ring"
    end

    test "renders error message text" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "can&#39;t be blank"
    end

    test "error state adds border-destructive class" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "border-destructive"
    end

    test "empty errors renders without border-destructive class" do
      html = render_component(&H.render_no_errors/1, %{})
      refute html =~ "border-destructive"
    end
  end
end
