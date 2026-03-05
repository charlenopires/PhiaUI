defmodule PhiaUi.Components.TimePickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimePicker

    def render_default(assigns) do
      ~H"""
      <.time_picker id="t1" name="time" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.time_picker id="t2" name="time" value="14:30" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.time_picker id="t3" name="time" label="Start Time" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.time_picker id="t4" name="time" label="Hour" description="Select the hour for your event" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.time_picker id="t5" name="time" disabled={true} />
      """
    end

    def render_with_seconds(assigns) do
      ~H"""
      <.time_picker id="t6" name="time" with_seconds={true} />
      """
    end

    def render_without_seconds(assigns) do
      ~H"""
      <.time_picker id="t7" name="time" with_seconds={false} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.time_picker id="t8" name="time" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.time_picker id="t9" name="time" size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.time_picker id="t10" name="time" class="my-time-class" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.time_picker id="t11" name="time" errors={["can't be blank"]} />
      """
    end
  end

  describe "time_picker/1" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "input has type=time" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="time")
    end

    test "renders the id attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="t1")
    end

    test "renders the name attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(name="time")
    end

    test "renders value attribute when provided" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="14:30")
    end

    test "renders label element with for attribute" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Start Time"
      assert html =~ ~s(for="t3")
    end

    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Select the hour for your event"
    end

    test "no label rendered when not provided" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "<label"
    end

    test "disabled attribute applied" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "with_seconds=true adds step=1" do
      html = render_component(&H.render_with_seconds/1, %{})
      assert html =~ ~s(step="1")
    end

    test "with_seconds=false does not add step attribute" do
      html = render_component(&H.render_without_seconds/1, %{})
      refute html =~ ~s(step="1")
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
      assert html =~ "my-time-class"
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

    test "error styling applied to input when errors present" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "destructive"
    end
  end
end
