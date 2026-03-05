defmodule PhiaUi.Components.CarouselTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Carousel

    def render_basic(assigns) do
      ~H"""
      <.carousel id="test-carousel">
        <.carousel_content>
          <.carousel_item>Slide 1</.carousel_item>
          <.carousel_item>Slide 2</.carousel_item>
          <.carousel_item>Slide 3</.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>
      """
    end

    def render_loop(assigns) do
      ~H"""
      <.carousel id="loop-carousel" loop={true}>
        <.carousel_content>
          <.carousel_item>Slide A</.carousel_item>
          <.carousel_item>Slide B</.carousel_item>
        </.carousel_content>
      </.carousel>
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.carousel id="vert-carousel" orientation="vertical">
        <.carousel_content>
          <.carousel_item>Top</.carousel_item>
          <.carousel_item>Bottom</.carousel_item>
        </.carousel_content>
      </.carousel>
      """
    end

    def render_with_indicators(assigns) do
      ~H"""
      <.carousel id="ind-carousel">
        <.carousel_content>
          <.carousel_item>Slide 1</.carousel_item>
          <.carousel_item>Slide 2</.carousel_item>
        </.carousel_content>
        <:indicators>
          <button class="dot" aria-label="Go to slide 1"></button>
          <button class="dot" aria-label="Go to slide 2"></button>
        </:indicators>
      </.carousel>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.carousel id="cls-carousel" class="my-custom-carousel">
        <.carousel_content class="my-track">
          <.carousel_item class="my-slide">Slide</.carousel_item>
        </.carousel_content>
      </.carousel>
      """
    end

    def render_no_loop(assigns) do
      ~H"""
      <.carousel id="no-loop-carousel" loop={false}>
        <.carousel_content>
          <.carousel_item>Slide 1</.carousel_item>
          <.carousel_item>Slide 2</.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>
      """
    end

    def render_custom_nav(assigns) do
      ~H"""
      <.carousel id="custom-nav-carousel">
        <.carousel_content>
          <.carousel_item>Slide</.carousel_item>
        </.carousel_content>
        <.carousel_previous>Prev</.carousel_previous>
        <.carousel_next>Next</.carousel_next>
      </.carousel>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # carousel/1
  # ---------------------------------------------------------------------------

  describe "carousel/1" do
    test "has role=region" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="region")
    end

    test "has aria-label=carousel" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="carousel")
    end

    test "uses PhiaCarousel hook" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "PhiaCarousel"
    end

    test "sets id attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(id="test-carousel")
    end

    test "loop=true sets data-loop=true" do
      html = render_component(&H.render_loop/1, %{})
      assert html =~ ~s(data-loop="true")
    end

    test "loop=false sets data-loop=false" do
      html = render_component(&H.render_no_loop/1, %{})
      assert html =~ ~s(data-loop="false")
    end

    test "default loop is false" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(data-loop="false")
    end

    test "orientation=vertical sets data-orientation=vertical" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ ~s(data-orientation="vertical")
    end

    test "default orientation is horizontal" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(data-orientation="horizontal")
    end

    test "has tabindex=0 for keyboard focus" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(tabindex="0")
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-custom-carousel"
    end

    test "has overflow-hidden class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "overflow-hidden"
    end
  end

  # ---------------------------------------------------------------------------
  # carousel_content/1
  # ---------------------------------------------------------------------------

  describe "carousel_content/1" do
    test "has data-carousel-track attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-carousel-track"
    end

    test "has transition-transform class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "transition-transform"
    end

    test "has duration-300 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "duration-300"
    end

    test "has flex class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "flex"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-track"
    end
  end

  # ---------------------------------------------------------------------------
  # carousel_item/1
  # ---------------------------------------------------------------------------

  describe "carousel_item/1" do
    test "has role=group" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="group")
    end

    test "has aria-roledescription=slide" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-roledescription="slide")
    end

    test "renders slide content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Slide 1"
      assert html =~ "Slide 2"
      assert html =~ "Slide 3"
    end

    test "has min-w-full class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "min-w-full"
    end

    test "has shrink-0 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "shrink-0"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-slide"
    end
  end

  # ---------------------------------------------------------------------------
  # carousel_previous/1
  # ---------------------------------------------------------------------------

  describe "carousel_previous/1" do
    test "renders button with data-carousel-prev" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-carousel-prev"
    end

    test "has aria-label=Previous slide" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="Previous slide")
    end

    test "has type=button" do
      html = render_component(&H.render_basic/1, %{})
      # Both prev and next have type="button"
      assert html =~ ~s(type="button")
    end

    test "renders default arrow icon when no inner_block" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "‹"
    end

    test "renders custom content when inner_block provided" do
      html = render_component(&H.render_custom_nav/1, %{})
      assert html =~ "Prev"
    end

    test "has disabled:opacity-50 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "disabled:opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # carousel_next/1
  # ---------------------------------------------------------------------------

  describe "carousel_next/1" do
    test "renders button with data-carousel-next" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-carousel-next"
    end

    test "has aria-label=Next slide" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="Next slide")
    end

    test "renders default arrow icon when no inner_block" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "›"
    end

    test "renders custom content when inner_block provided" do
      html = render_component(&H.render_custom_nav/1, %{})
      assert html =~ "Next"
    end

    test "has disabled:pointer-events-none class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "disabled:pointer-events-none"
    end
  end

  # ---------------------------------------------------------------------------
  # indicators slot
  # ---------------------------------------------------------------------------

  describe "indicators slot" do
    test "renders indicators when slot is provided" do
      html = render_component(&H.render_with_indicators/1, %{})
      assert html =~ "dot"
      assert html =~ ~s(aria-label="Go to slide 1")
    end

    test "does not render indicators container when slot is empty" do
      html = render_component(&H.render_basic/1, %{})
      # No dot indicators in the basic render
      refute html =~ ~s(aria-label="Go to slide 1")
    end
  end

  # ---------------------------------------------------------------------------
  # composition
  # ---------------------------------------------------------------------------

  describe "full carousel composition" do
    test "renders all sub-components together without error" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
      assert html =~ "PhiaCarousel"
      assert html =~ "data-carousel-track"
      assert html =~ "data-carousel-prev"
      assert html =~ "data-carousel-next"
    end

    test "loop carousel renders without error" do
      html = render_component(&H.render_loop/1, %{})
      assert html =~ "Slide A"
      assert html =~ "Slide B"
    end

    test "vertical carousel renders without error" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "Top"
      assert html =~ "Bottom"
    end
  end
end
