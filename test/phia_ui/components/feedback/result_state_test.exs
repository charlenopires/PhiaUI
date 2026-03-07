defmodule PhiaUi.Components.ResultStateTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ResultState

    def render_success(assigns) do
      ~H"""
      <.result_state status={:success} title="Payment Complete!" />
      """
    end

    def render_error(assigns) do
      ~H"""
      <.result_state status={:error} title="Something went wrong" description="Please try again." />
      """
    end

    def render_warning(assigns) do
      ~H"""
      <.result_state status={:warning} title="Warning!" />
      """
    end

    def render_info(assigns) do
      ~H"""
      <.result_state status={:info} title="Info" />
      """
    end

    def render_not_found(assigns) do
      ~H"""
      <.result_state status={:not_found} title="Page not found" />
      """
    end

    def render_forbidden(assigns) do
      ~H"""
      <.result_state status={:forbidden} title="Access denied" />
      """
    end

    def render_with_extra(assigns) do
      ~H"""
      <.result_state status={:error} title="Error">
        <:extra><span class="extra-content">Error code: 500</span></:extra>
      </.result_state>
      """
    end

    def render_with_actions(assigns) do
      ~H"""
      <.result_state status={:success} title="Done">
        <:actions><button class="action-btn">Go home</button></:actions>
      </.result_state>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.result_state status={:info} title="Title" class="my-result" />
      """
    end
  end

  describe "result_state/1" do
    test "renders a container div" do
      html = render_component(&H.render_success/1, %{})
      assert html =~ "<div"
    end

    test ":success uses circle-check icon" do
      html = render_component(&H.render_success/1, %{})
      assert html =~ "circle-check"
    end

    test ":error uses circle-x icon" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "circle-x"
    end

    test ":warning uses triangle-alert icon" do
      html = render_component(&H.render_warning/1, %{})
      assert html =~ "triangle-alert"
    end

    test ":info uses info icon" do
      html = render_component(&H.render_info/1, %{})
      assert html =~ "icon-info"
    end

    test ":not_found uses file-question icon" do
      html = render_component(&H.render_not_found/1, %{})
      assert html =~ "file-question"
    end

    test ":forbidden uses shield-off icon" do
      html = render_component(&H.render_forbidden/1, %{})
      assert html =~ "shield-off"
    end

    test ":success icon is green" do
      html = render_component(&H.render_success/1, %{})
      assert html =~ "text-green-500"
    end

    test ":error icon is red" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "text-red-500"
    end

    test ":warning icon is amber" do
      html = render_component(&H.render_warning/1, %{})
      assert html =~ "text-amber-500"
    end

    test "title is rendered" do
      html = render_component(&H.render_success/1, %{})
      assert html =~ "Payment Complete!"
    end

    test "description is rendered when provided" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "Please try again."
    end

    test "extra slot is rendered" do
      html = render_component(&H.render_with_extra/1, %{})
      assert html =~ "extra-content"
      assert html =~ "Error code: 500"
    end

    test "actions slot is rendered" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "action-btn"
      assert html =~ "Go home"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-result"
    end
  end
end
