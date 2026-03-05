defmodule PhiaUi.Components.BackTopTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BackTop

    def render_default(assigns) do
      ~H"""
      <.back_top />
      """
    end

    def render_with_threshold(assigns) do
      ~H"""
      <.back_top threshold={300} />
      """
    end

    def render_smooth_false(assigns) do
      ~H"""
      <.back_top smooth={false} />
      """
    end

    def render_with_aria_label(assigns) do
      ~H"""
      <.back_top aria_label="Go to top" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.back_top class="my-custom-class" />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Renders button element
  # ---------------------------------------------------------------------------

  describe "renders button element" do
    test "renders a button tag" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<button"
    end

    test "button has type=button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="button")
    end

    test "button has phx-hook PhiaBackTop" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-hook="PhiaBackTop")
    end
  end

  # ---------------------------------------------------------------------------
  # data-threshold attribute
  # ---------------------------------------------------------------------------

  describe "data-threshold attribute" do
    test "button has data-threshold attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "data-threshold"
    end

    test "default threshold is 200" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-threshold="200")
    end

    test "custom threshold value is rendered" do
      html = render_component(&H.render_with_threshold/1, %{})
      assert html =~ ~s(data-threshold="300")
    end
  end

  # ---------------------------------------------------------------------------
  # data-smooth attribute
  # ---------------------------------------------------------------------------

  describe "data-smooth attribute" do
    test "button has data-smooth attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "data-smooth"
    end

    test "default smooth is true" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-smooth="true")
    end

    test "smooth=false sets data-smooth to false" do
      html = render_component(&H.render_smooth_false/1, %{})
      assert html =~ ~s(data-smooth="false")
    end
  end

  # ---------------------------------------------------------------------------
  # aria-label attribute
  # ---------------------------------------------------------------------------

  describe "aria-label attribute" do
    test "button has aria-label attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "aria-label"
    end

    test "default aria-label is Scroll to top" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-label="Scroll to top")
    end

    test "custom aria-label is rendered" do
      html = render_component(&H.render_with_aria_label/1, %{})
      assert html =~ ~s(aria-label="Go to top")
    end
  end

  # ---------------------------------------------------------------------------
  # CSS classes
  # ---------------------------------------------------------------------------

  describe "CSS classes" do
    test "button has opacity-0 class by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "opacity-0"
    end

    test "button has fixed positioning class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "fixed"
    end

    test "applies custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-custom-class"
    end
  end
end
