defmodule PhiaUi.Components.DateFieldTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateField

    def render_default(assigns) do
      ~H"""
      <.date_field id="df1" name="date" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.date_field id="df1" name="date" value="2026-03-04" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.date_field id="df1" name="date" label="Start date" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.date_field id="df1" name="date" description="Select a date in 2026" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.date_field id="df1" name="date" disabled />
      """
    end

    def render_with_min_max(assigns) do
      ~H"""
      <.date_field id="df1" name="date" min="2026-01-01" max="2026-12-31" />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.date_field id="df1" name="date" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.date_field id="df1" name="date" size={:lg} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.date_field id="df1" name="date" class="my-date-field" />
      """
    end

    def render_with_errors(assigns) do
      ~H"""
      <.date_field id="df1" name="date" errors={["is required", "must be in the future"]} />
      """
    end

    def render_no_errors(assigns) do
      ~H"""
      <.date_field id="df1" name="date" errors={[]} />
      """
    end
  end

  describe "date_field/1" do
    test "renders input type=date" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="date")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="df1")
    end

    test "renders with name attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(name="date")
    end

    test "renders with value" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="2026-03-04")
    end

    test "renders label text" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Start date"
    end

    test "label has for= attribute matching id" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(for="df1")
    end

    test "renders description" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Select a date in 2026"
    end

    test "renders disabled input" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "renders min attribute" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(min="2026-01-01")
    end

    test "renders max attribute" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(max="2026-12-31")
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
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-date-field"
    end

    test "renders rounded-md" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-md"
    end

    test "renders border class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border"
    end

    test "renders focus-visible ring" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "focus-visible"
    end

    test "renders error messages" do
      html = render_component(&H.render_with_errors/1, %{})
      assert html =~ "is required"
      assert html =~ "must be in the future"
    end

    test "error state adds border-destructive" do
      html = render_component(&H.render_with_errors/1, %{})
      assert html =~ "border-destructive"
    end

    test "empty errors renders without error class" do
      html = render_component(&H.render_no_errors/1, %{})
      refute html =~ "border-destructive"
    end
  end
end
