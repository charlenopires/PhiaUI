defmodule PhiaUi.Components.ImageComparisonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ImageComparison

    def render_basic(assigns) do
      ~H"""
      <.image_comparison
        id="compare-1"
        before_src="/before.jpg"
        after_src="/after.jpg"
      />
      """
    end

    def render_custom_labels(assigns) do
      ~H"""
      <.image_comparison
        id="compare-2"
        before_src="/before.jpg"
        after_src="/after.jpg"
        before_label="Original"
        after_label="Edited"
      />
      """
    end

    def render_initial_position(assigns) do
      ~H"""
      <.image_comparison
        id="compare-3"
        before_src="/b.jpg"
        after_src="/a.jpg"
        initial_position={30}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.image_comparison
        id="compare-4"
        before_src="/b.jpg"
        after_src="/a.jpg"
        class="my-compare"
      />
      """
    end
  end

  describe "image_comparison/1" do
    test "renders root div with phx-hook" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(phx-hook="PhiaImageComparison")
    end

    test "renders id attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(id="compare-1")
    end

    test "renders data-initial-position attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-initial-position"
    end

    test "renders before image" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "/before.jpg"
    end

    test "renders after image" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "/after.jpg"
    end

    test "before container has clip-path style" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "clip-path"
    end

    test "divider has data-divider attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-divider"
    end

    test "before-container has data-before-container attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-before-container"
    end

    test "default labels are rendered" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Before"
      assert html =~ "After"
    end

    test "custom labels are rendered" do
      html = render_component(&H.render_custom_labels/1, %{})
      assert html =~ "Original"
      assert html =~ "Edited"
    end

    test "custom initial_position sets clip-path inset" do
      html = render_component(&H.render_initial_position/1, %{})
      assert html =~ "inset(0 70%"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-compare"
    end
  end
end
