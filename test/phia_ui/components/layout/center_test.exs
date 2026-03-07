defmodule PhiaUi.Components.Layout.CenterTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Center

    def render_center(assigns) do
      ~H"<.center variant={assigns[:variant] || :default} class={assigns[:class]}>body</.center>"
    end
  end

  defp render_center(attrs \\ %{}) do
    render_component(&H.render_center/1, attrs)
  end

  describe "center/1 default variant" do
    test "renders a div" do
      assert render_center() =~ "<div"
    end

    test "applies flex items-center justify-center" do
      html = render_center()
      assert html =~ "flex"
      assert html =~ "items-center"
      assert html =~ "justify-center"
    end

    test "renders inner content" do
      assert render_center() =~ "body"
    end
  end

  describe "center/1 inline variant" do
    test "applies inline-flex" do
      assert render_center(%{variant: :inline}) =~ "inline-flex"
    end

    test "applies items-center and justify-center" do
      html = render_center(%{variant: :inline})
      assert html =~ "items-center"
      assert html =~ "justify-center"
    end
  end

  describe "center/1 absolute variant" do
    test "applies absolute inset-0" do
      html = render_center(%{variant: :absolute})
      assert html =~ "absolute"
      assert html =~ "inset-0"
    end

    test "applies flex items-center justify-center" do
      html = render_center(%{variant: :absolute})
      assert html =~ "flex"
      assert html =~ "items-center"
      assert html =~ "justify-center"
    end
  end

  describe "center/1 class forwarding" do
    test "forwards custom class" do
      assert render_center(%{class: "h-64"}) =~ "h-64"
    end
  end
end
