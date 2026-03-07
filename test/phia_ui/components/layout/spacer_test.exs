defmodule PhiaUi.Components.Layout.SpacerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Spacer

    def render_spacer(assigns) do
      ~H"<.spacer size={assigns[:size] || :auto} class={assigns[:class]} />"
    end
  end

  defp render_spacer(attrs \\ %{}) do
    render_component(&H.render_spacer/1, attrs)
  end

  describe "spacer/1 default (auto)" do
    test "renders a div" do
      assert render_spacer() =~ "<div"
    end

    test "applies flex-1 for auto size" do
      assert render_spacer() =~ "flex-1"
    end

    test "is aria-hidden" do
      assert render_spacer() =~ ~s(aria-hidden="true")
    end
  end

  describe "spacer/1 size variants" do
    test "xs applies w-2 h-2" do
      html = render_spacer(%{size: :xs})
      assert html =~ "w-2"
      assert html =~ "h-2"
    end

    test "sm applies w-4 h-4" do
      html = render_spacer(%{size: :sm})
      assert html =~ "w-4"
      assert html =~ "h-4"
    end

    test "md applies w-6 h-6" do
      html = render_spacer(%{size: :md})
      assert html =~ "w-6"
      assert html =~ "h-6"
    end

    test "lg applies w-8 h-8" do
      html = render_spacer(%{size: :lg})
      assert html =~ "w-8"
      assert html =~ "h-8"
    end

    test "xl applies w-12 h-12" do
      html = render_spacer(%{size: :xl})
      assert html =~ "w-12"
      assert html =~ "h-12"
    end
  end

  describe "spacer/1 class forwarding" do
    test "forwards custom class" do
      assert render_spacer(%{class: "my-class"}) =~ "my-class"
    end
  end
end
