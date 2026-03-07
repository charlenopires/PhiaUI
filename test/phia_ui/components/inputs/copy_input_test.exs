defmodule PhiaUi.Components.CopyInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CopyInput

    def render_basic(assigns) do
      ~H"""
      <.copy_input value="sk-live-abc123" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.copy_input value="https://example.com/share/abc" label="Share link" description="Send this to your team" />
      """
    end

    def render_masked(assigns) do
      ~H"""
      <.copy_input value="super-secret-key" masked={true} label="API Key" />
      """
    end

    def render_small(assigns) do
      ~H"""
      <.copy_input value="token" size="sm" />
      """
    end

    def render_large(assigns) do
      ~H"""
      <.copy_input value="token" size="lg" />
      """
    end
  end

  describe "copy_input/1 rendering" do
    test "renders an input element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<input"
    end

    test "renders the value in input" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "sk-live-abc123"
    end

    test "renders copy button" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Copy"
    end

    test "input is readonly" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "readonly"
    end

    test "uses PhiaCopyButton hook" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "PhiaCopyButton"
    end

    test "renders label when given" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Share link"
      assert html =~ "<label"
    end

    test "renders description when given" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Send this to your team"
    end

    test "renders masked type as password" do
      html = render_component(&H.render_masked/1, %{})
      assert html =~ ~s(type="password")
    end

    test "renders reveal button when masked" do
      html = render_component(&H.render_masked/1, %{})
      assert html =~ "Reveal value"
    end

    test "does not render reveal button when not masked" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "Reveal value"
    end

    test "sm size applies h-8 class" do
      html = render_component(&H.render_small/1, %{})
      assert html =~ "h-8"
    end

    test "lg size applies h-12 class" do
      html = render_component(&H.render_large/1, %{})
      assert html =~ "h-12"
    end
  end
end
