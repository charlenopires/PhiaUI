defmodule PhiaUi.Components.YearPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.YearPicker

    def render_default(assigns) do
      ~H"""
      <.year_picker id="yp1" name="year" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.year_picker id="yp2" name="year" value={2026} />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.year_picker id="yp3" name="year" label="Select Year" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.year_picker id="yp4" name="year" label="Year" description="Choose the target year" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.year_picker id="yp5" name="year" disabled={true} />
      """
    end

    def render_custom_min(assigns) do
      ~H"""
      <.year_picker id="yp6" name="year" min_year={2000} />
      """
    end

    def render_custom_max(assigns) do
      ~H"""
      <.year_picker id="yp7" name="year" max_year={2050} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.year_picker id="yp8" name="year" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.year_picker id="yp9" name="year" size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.year_picker id="yp10" name="year" class="my-year-class" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.year_picker id="yp11" name="year" errors={["can't be blank"]} />
      """
    end
  end

  describe "year_picker/1" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "input has type=number" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="number")
    end

    test "renders the id attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="yp1")
    end

    test "renders the name attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(name="year")
    end

    test "renders value attribute when provided" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="2026")
    end

    test "renders label element" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Select Year"
    end

    test "label has for attribute matching id" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(for="yp3")
    end

    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Choose the target year"
    end

    test "disabled attribute applied" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "renders default min attribute of 1900" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(min="1900")
    end

    test "renders default max attribute of 2100" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(max="2100")
    end

    test "custom min_year is applied" do
      html = render_component(&H.render_custom_min/1, %{})
      assert html =~ ~s(min="2000")
    end

    test "custom max_year is applied" do
      html = render_component(&H.render_custom_max/1, %{})
      assert html =~ ~s(max="2050")
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
      assert html =~ "my-year-class"
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
