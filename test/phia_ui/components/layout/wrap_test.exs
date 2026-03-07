defmodule PhiaUi.Components.Layout.WrapTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Wrap

    def render_wrap(assigns) do
      ~H"""
      <.wrap
        gap={assigns[:gap] || 2}
        gap_x={assigns[:gap_x]}
        gap_y={assigns[:gap_y]}
        align={assigns[:align] || :start}
        justify={assigns[:justify] || :start}
        class={assigns[:class]}
      >
        chip1 chip2
      </.wrap>
      """
    end
  end

  defp render_wrap(attrs \\ %{}) do
    render_component(&H.render_wrap/1, attrs)
  end

  describe "wrap/1 defaults" do
    test "renders a div" do
      assert render_wrap() =~ "<div"
    end

    test "applies flex flex-wrap" do
      html = render_wrap()
      assert html =~ "flex"
      assert html =~ "flex-wrap"
    end

    test "applies default gap-2" do
      assert render_wrap() =~ "gap-2"
    end

    test "renders content" do
      assert render_wrap() =~ "chip1"
    end
  end

  describe "wrap/1 gap variants" do
    test "custom gap" do
      assert render_wrap(%{gap: 4}) =~ "gap-4"
    end

    test "gap_x takes priority" do
      html = render_wrap(%{gap_x: 3, gap_y: 2})
      assert html =~ "gap-x-3"
      assert html =~ "gap-y-2"
    end
  end

  describe "wrap/1 align" do
    test "center alignment" do
      assert render_wrap(%{align: :center}) =~ "items-center"
    end

    test "end alignment" do
      assert render_wrap(%{align: :end}) =~ "items-end"
    end
  end

  describe "wrap/1 justify" do
    test "center justify" do
      assert render_wrap(%{justify: :center}) =~ "justify-center"
    end

    test "between justify" do
      assert render_wrap(%{justify: :between}) =~ "justify-between"
    end
  end

  describe "wrap/1 class forwarding" do
    test "forwards custom class" do
      assert render_wrap(%{class: "my-class"}) =~ "my-class"
    end
  end
end
