defmodule PhiaUi.Components.FullscreenDropTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FullscreenDrop

    def render_basic(assigns) do
      ~H"""
      <.fullscreen_drop upload={%{ref: "drop-ref", entries: [], errors: []}} />
      """
    end

    def render_custom_label(assigns) do
      ~H"""
      <.fullscreen_drop
        upload={%{ref: "drop-ref", entries: [], errors: []}}
        label="Release to attach"
        description="PDF and images only"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.fullscreen_drop
        upload={%{ref: "drop-ref", entries: [], errors: []}}
        class="custom-overlay"
      />
      """
    end
  end

  describe "fullscreen_drop/1 rendering" do
    test "renders the overlay div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "has PhiaFullscreenDrop hook" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "PhiaFullscreenDrop"
    end

    test "has data-drop-ref attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(data-drop-ref="drop-ref")
    end

    test "has phx-drop-target" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "phx-drop-target"
    end

    test "is hidden by default (no data-active)" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ ~s(data-active="true")
    end

    test "has fixed positioning class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "fixed"
    end

    test "renders default label" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Drop files to upload"
    end

    test "renders custom label" do
      html = render_component(&H.render_custom_label/1, %{})
      assert html =~ "Release to attach"
    end

    test "renders description when given" do
      html = render_component(&H.render_custom_label/1, %{})
      assert html =~ "PDF and images only"
    end

    test "applies custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-overlay"
    end

    test "has aria-hidden attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "has high z-index class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "z-[9999]"
    end
  end
end
