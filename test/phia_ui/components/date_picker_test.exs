defmodule PhiaUi.Components.DatePickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DatePicker

    def render_no_value(assigns) do
      ~H"""
      <.date_picker id="dp1" open={false} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.date_picker id="dp2" value={~D[2024-03-15]} open={false} />
      """
    end

    def render_open(assigns) do
      ~H"""
      <.date_picker id="dp3" open={true} current_month={~D[2024-01-01]} />
      """
    end

    def render_custom_format(assigns) do
      ~H"""
      <.date_picker id="dp4" value={~D[2024-03-15]} format="%Y-%m-%d" open={false} />
      """
    end

    def render_custom_placeholder(assigns) do
      ~H"""
      <.date_picker id="dp5" placeholder="Select a date..." open={false} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.date_picker id="dp6" class="my-custom-class" open={false} />
      """
    end
  end

  describe "date_picker/1" do
    test "shows placeholder when no value" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ "Pick a date"
    end

    test "shows formatted date when value set" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "15/03/2024"
    end

    test "shows calendar icon svg" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ "<svg"
      assert html =~ "viewBox"
    end

    test "svg icon has aria-hidden=true" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "calendar dropdown hidden when open=false" do
      html = render_component(&H.render_no_value/1, %{})
      refute html =~ ~s(role="grid")
    end

    test "calendar dropdown visible when open=true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(role="grid")
    end

    test "trigger button has phx-click" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ "phx-click"
    end

    test "trigger has default on_toggle event" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ "date-picker-toggle"
    end

    test "trigger has muted text class when no value" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "custom format renders correctly" do
      html = render_component(&H.render_custom_format/1, %{})
      assert html =~ "2024-03-15"
    end

    test "custom placeholder is displayed" do
      html = render_component(&H.render_custom_placeholder/1, %{})
      assert html =~ "Select a date..."
    end

    test "additional css class is applied to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-custom-class"
    end

    test "root element has the provided id" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ ~s(id="dp1")
    end

    test "trigger button type is button" do
      html = render_component(&H.render_no_value/1, %{})
      assert html =~ ~s(type="button")
    end

    test "open calendar renders nested calendar with the picker id prefix" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "dp3-calendar"
    end
  end
end
