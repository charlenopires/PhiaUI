defmodule PhiaUi.Components.AspectRatioTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AspectRatio

    def render_default(assigns) do
      ~H"""
      <.aspect_ratio>
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_16_9(assigns) do
      ~H"""
      <.aspect_ratio ratio={16 / 9}>
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_4_3(assigns) do
      ~H"""
      <.aspect_ratio ratio={4 / 3}>
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_21_9(assigns) do
      ~H"""
      <.aspect_ratio ratio={21 / 9}>
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_9_16(assigns) do
      ~H"""
      <.aspect_ratio ratio={9 / 16}>
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.aspect_ratio class="rounded-lg overflow-hidden">
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.aspect_ratio data-testid="my-aspect-ratio">
        <img src="test.jpg" alt="test" />
      </.aspect_ratio>
      """
    end

    def render_with_video(assigns) do
      ~H"""
      <.aspect_ratio ratio={16 / 9}>
        <video src="test.mp4" controls />
      </.aspect_ratio>
      """
    end

    def render_with_div(assigns) do
      ~H"""
      <.aspect_ratio ratio={1.0}>
        <div class="bg-primary">Content</div>
      </.aspect_ratio>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Default ratio (1:1)
  # ---------------------------------------------------------------------------

  describe "aspect_ratio/1 default ratio" do
    test "renders with default 1:1 ratio (100.0% padding-top)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "padding-top: 100.0%"
    end

    test "renders outer div with relative and w-full" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "relative"
      assert html =~ "w-full"
    end

    test "renders inner div with absolute inset-0" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "absolute"
      assert html =~ "inset-0"
    end

    test "renders inner content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(src="test.jpg")
      assert html =~ ~s(alt="test")
    end
  end

  # ---------------------------------------------------------------------------
  # Common ratios
  # ---------------------------------------------------------------------------

  describe "aspect_ratio/1 16:9 ratio" do
    test "renders with 16:9 ratio (~56.25% padding-top)" do
      html = render_component(&H.render_16_9/1, %{})
      assert html =~ "padding-top: 56.25%"
    end
  end

  describe "aspect_ratio/1 4:3 ratio" do
    test "renders with 4:3 ratio (~75% padding-top)" do
      html = render_component(&H.render_4_3/1, %{})
      assert html =~ "padding-top: 75.0%"
    end
  end

  describe "aspect_ratio/1 21:9 ratio" do
    test "renders with 21:9 ratio (~42.8571% padding-top)" do
      html = render_component(&H.render_21_9/1, %{})
      assert html =~ "padding-top: 42.8571%"
    end
  end

  describe "aspect_ratio/1 9:16 ratio (portrait)" do
    test "renders with 9:16 ratio (~177.7778% padding-top)" do
      html = render_component(&H.render_9_16/1, %{})
      assert html =~ "padding-top: 177.7778%"
    end
  end

  # ---------------------------------------------------------------------------
  # :class merge and @rest
  # ---------------------------------------------------------------------------

  describe "aspect_ratio/1 :class merge" do
    test "adds custom class to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "rounded-lg"
      assert html =~ "overflow-hidden"
    end

    test "preserves base classes alongside custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "relative"
      assert html =~ "w-full"
    end
  end

  describe "aspect_ratio/1 @rest passthrough" do
    test "passes data-testid to root element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-aspect-ratio")
    end
  end

  # ---------------------------------------------------------------------------
  # Content types
  # ---------------------------------------------------------------------------

  describe "aspect_ratio/1 with various content types" do
    test "works with video element" do
      html = render_component(&H.render_with_video/1, %{})
      assert html =~ "<video"
      assert html =~ "padding-top: 56.25%"
    end

    test "works with div element" do
      html = render_component(&H.render_with_div/1, %{})
      assert html =~ "<div"
      assert html =~ "Content"
      assert html =~ "padding-top: 100.0%"
    end
  end

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  describe "public API" do
    test "aspect_ratio/1 is exported" do
      assert function_exported?(PhiaUi.Components.AspectRatio, :aspect_ratio, 1)
    end
  end
end
