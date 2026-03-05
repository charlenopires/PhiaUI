defmodule PhiaUi.Components.WeekPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.WeekPicker

    def render_default(assigns) do
      ~H"""
      <.week_picker id="wp1" name="week" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.week_picker id="wp2" name="week" value="2026-W10" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.week_picker id="wp3" name="week" label="Reporting Week" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.week_picker id="wp4" name="week" label="Week" description="Select the ISO week for reporting" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.week_picker id="wp5" name="week" disabled={true} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.week_picker id="wp6" name="week" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.week_picker id="wp7" name="week" size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.week_picker id="wp8" name="week" class="my-week-class" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.week_picker id="wp9" name="week" errors={["can't be blank"]} />
      """
    end

    def render_empty_errors(assigns) do
      ~H"""
      <.week_picker id="wp10" name="week" errors={[]} />
      """
    end
  end

  describe "week_picker/1" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "input has type=week" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="week")
    end

    test "renders the id attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="wp1")
    end

    test "renders the name attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(name="week")
    end

    test "renders value attribute when provided" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="2026-W10")
    end

    test "renders label element with text" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Reporting Week"
    end

    test "label has for attribute matching id" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(for="wp3")
    end

    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Select the ISO week for reporting"
    end

    test "disabled attribute applied" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "size :sm applies h-8 class" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-8"
    end

    test "size :default applies h-10 class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-10"
    end

    test "size :lg applies h-12 class" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-12"
    end

    test "custom class applied to input" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-week-class"
    end

    test "has rounded-md styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-md"
    end

    test "has border styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border"
    end

    test "has focus ring styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "focus-visible:ring"
    end

    test "renders error message" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "can&#39;t be blank"
    end

    test "error state adds border-destructive class" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "border-destructive"
    end

    test "empty errors renders without error class" do
      html = render_component(&H.render_empty_errors/1, %{})
      refute html =~ "border-destructive"
    end
  end
end
