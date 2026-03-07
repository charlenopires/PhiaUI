defmodule PhiaUi.Components.LoadingOverlayTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.LoadingOverlay

    def render_overlay(assigns) do
      ~H"""
      <div class="relative">
        <.loading_overlay visible={true} />
      </div>
      """
    end

    def render_hidden(assigns) do
      ~H"""
      <div class="relative">
        <.loading_overlay visible={false} />
      </div>
      """
    end

    def render_fullscreen(assigns) do
      ~H"""
      <.loading_overlay visible={true} fullscreen />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <div class="relative">
        <.loading_overlay visible={true} label="Saving changes..." show_label />
      </div>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <div class="relative">
        <.loading_overlay visible={true} class="my-overlay" />
      </div>
      """
    end

    def render_dots(assigns) do
      ~H"""
      <.loading_dots />
      """
    end

    def render_dots_sm(assigns) do
      ~H"""
      <.loading_dots size={:sm} />
      """
    end

    def render_dots_lg(assigns) do
      ~H"""
      <.loading_dots size={:lg} label="Please wait" />
      """
    end

    def render_bar(assigns) do
      ~H"""
      <.loading_bar />
      """
    end

    def render_bar_with_class(assigns) do
      ~H"""
      <.loading_bar class="custom-bar" />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # loading_overlay/1
  # ---------------------------------------------------------------------------

  describe "loading_overlay/1" do
    test "renders when visible=true" do
      html = render_component(&H.render_overlay/1, %{})
      assert html =~ ~s(role="status")
    end

    test "does not render when visible=false" do
      html = render_component(&H.render_hidden/1, %{})
      refute html =~ ~s(role="status")
    end

    test "renders default label as aria-label" do
      html = render_component(&H.render_overlay/1, %{})
      assert html =~ "Loading..."
    end

    test "shows label text when show_label=true" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Saving changes..."
    end

    test "fullscreen uses fixed inset-0" do
      html = render_component(&H.render_fullscreen/1, %{})
      assert html =~ "fixed inset-0"
    end

    test "scoped uses absolute inset-0" do
      html = render_component(&H.render_overlay/1, %{})
      assert html =~ "absolute inset-0"
    end

    test "accepts :class override" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-overlay"
    end
  end

  # ---------------------------------------------------------------------------
  # loading_dots/1
  # ---------------------------------------------------------------------------

  describe "loading_dots/1" do
    test "renders three dots" do
      html = render_component(&H.render_dots/1, %{})
      assert html =~ "animate-bounce"
    end

    test "renders role=status" do
      html = render_component(&H.render_dots/1, %{})
      assert html =~ ~s(role="status")
    end

    test "renders sr-only label" do
      html = render_component(&H.render_dots/1, %{})
      assert html =~ "sr-only"
      assert html =~ "Loading"
    end

    test "sm size renders h-1.5 w-1.5" do
      html = render_component(&H.render_dots_sm/1, %{})
      assert html =~ "h-1.5 w-1.5"
    end

    test "lg size renders h-2.5 w-2.5" do
      html = render_component(&H.render_dots_lg/1, %{})
      assert html =~ "h-2.5 w-2.5"
    end

    test "custom label appears in sr-only span" do
      html = render_component(&H.render_dots_lg/1, %{})
      assert html =~ "Please wait"
    end
  end

  # ---------------------------------------------------------------------------
  # loading_bar/1
  # ---------------------------------------------------------------------------

  describe "loading_bar/1" do
    test "renders progressbar role" do
      html = render_component(&H.render_bar/1, %{})
      assert html =~ ~s(role="progressbar")
    end

    test "renders fixed top-0" do
      html = render_component(&H.render_bar/1, %{})
      assert html =~ "fixed top-0"
    end

    test "renders primary color fill" do
      html = render_component(&H.render_bar/1, %{})
      assert html =~ "bg-primary"
    end

    test "accepts :class override" do
      html = render_component(&H.render_bar_with_class/1, %{})
      assert html =~ "custom-bar"
    end
  end
end
