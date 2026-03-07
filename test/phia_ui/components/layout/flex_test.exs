defmodule PhiaUi.Components.Layout.FlexTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Flex

    def render_flex(assigns) do
      ~H"""
      <.flex
        direction={assigns[:direction] || :row}
        wrap={assigns[:wrap] || :nowrap}
        gap={assigns[:gap]}
        gap_x={assigns[:gap_x]}
        gap_y={assigns[:gap_y]}
        align={assigns[:align]}
        justify={assigns[:justify]}
        grow={assigns[:grow] || false}
        inline={assigns[:inline] || false}
        class={assigns[:class]}
      >
        child
      </.flex>
      """
    end
  end

  defp render_flex(attrs \\ %{}) do
    render_component(&H.render_flex/1, attrs)
  end

  describe "flex/1 defaults" do
    test "renders a div" do
      assert render_flex() =~ "<div"
    end

    test "applies flex class" do
      assert render_flex() =~ "flex"
    end

    test "applies flex-row by default" do
      assert render_flex() =~ "flex-row"
    end

    test "renders child content" do
      assert render_flex() =~ "child"
    end
  end

  describe "flex/1 direction" do
    test "col direction" do
      assert render_flex(%{direction: :col}) =~ "flex-col"
    end

    test "row_reverse direction" do
      assert render_flex(%{direction: :row_reverse}) =~ "flex-row-reverse"
    end

    test "col_reverse direction" do
      assert render_flex(%{direction: :col_reverse}) =~ "flex-col-reverse"
    end
  end

  describe "flex/1 wrap" do
    test "wrap applies flex-wrap" do
      assert render_flex(%{wrap: :wrap}) =~ "flex-wrap"
    end

    test "wrap_reverse applies flex-wrap-reverse" do
      assert render_flex(%{wrap: :wrap_reverse}) =~ "flex-wrap-reverse"
    end

    test "nowrap does not add flex-wrap" do
      refute render_flex(%{wrap: :nowrap}) =~ "flex-wrap"
    end
  end

  describe "flex/1 gap" do
    test "gap renders gap-N" do
      assert render_flex(%{gap: 4}) =~ "gap-4"
    end

    test "gap_x renders gap-x-N" do
      assert render_flex(%{gap_x: 6}) =~ "gap-x-6"
    end

    test "gap_y renders gap-y-N" do
      assert render_flex(%{gap_y: 2}) =~ "gap-y-2"
    end
  end

  describe "flex/1 align and justify" do
    test "align center" do
      assert render_flex(%{align: :center}) =~ "items-center"
    end

    test "justify between" do
      assert render_flex(%{justify: :between}) =~ "justify-between"
    end

    test "justify evenly" do
      assert render_flex(%{justify: :evenly}) =~ "justify-evenly"
    end
  end

  describe "flex/1 grow and inline" do
    test "grow adds flex-1" do
      assert render_flex(%{grow: true}) =~ "flex-1"
    end

    test "inline uses inline-flex" do
      assert render_flex(%{inline: true}) =~ "inline-flex"
    end
  end

  describe "flex/1 class forwarding" do
    test "forwards custom class" do
      assert render_flex(%{class: "bg-red-100"}) =~ "bg-red-100"
    end
  end
end
