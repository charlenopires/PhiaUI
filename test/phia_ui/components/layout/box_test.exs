defmodule PhiaUi.Components.Layout.BoxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Box

    def render_box(assigns) do
      ~H"<.box class={assigns[:class]}>content</.box>"
    end

    def render_box_as(assigns) do
      ~H"<.box as={assigns.as}>text</.box>"
    end
  end

  defp render_box(attrs \\ %{}) do
    render_component(&H.render_box/1, attrs)
  end

  describe "box/1 default" do
    test "renders a div by default" do
      assert render_box() =~ "<div"
    end

    test "renders inner content" do
      assert render_box() =~ "content"
    end

    test "nil class renders without error" do
      html = render_box(%{class: nil})
      assert html =~ "<div"
    end

    test "forwards custom class" do
      assert render_box(%{class: "my-custom-class"}) =~ "my-custom-class"
    end
  end

  describe "box/1 as attribute" do
    test "renders as section" do
      html = render_component(&H.render_box_as/1, %{as: "section"})
      assert html =~ "<section"
    end

    test "renders as article" do
      html = render_component(&H.render_box_as/1, %{as: "article"})
      assert html =~ "<article"
    end

    test "renders as main" do
      html = render_component(&H.render_box_as/1, %{as: "main"})
      assert html =~ "<main"
    end

    test "renders as aside" do
      html = render_component(&H.render_box_as/1, %{as: "aside"})
      assert html =~ "<aside"
    end

    test "renders as header" do
      html = render_component(&H.render_box_as/1, %{as: "header"})
      assert html =~ "<header"
    end

    test "renders as footer" do
      html = render_component(&H.render_box_as/1, %{as: "footer"})
      assert html =~ "<footer"
    end

    test "renders as nav" do
      html = render_component(&H.render_box_as/1, %{as: "nav"})
      assert html =~ "<nav"
    end
  end
end
