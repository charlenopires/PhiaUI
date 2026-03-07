defmodule PhiaUi.Components.Layout.GridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Grid

    def render_grid(assigns) do
      ~H"""
      <.grid
        cols={assigns[:cols]}
        rows={assigns[:rows]}
        gap={assigns[:gap]}
        gap_x={assigns[:gap_x]}
        gap_y={assigns[:gap_y]}
        flow={assigns[:flow]}
        align={assigns[:align]}
        justify={assigns[:justify]}
        class={assigns[:class]}
      >
        child
      </.grid>
      """
    end
  end

  defp render_grid(attrs \\ %{}) do
    render_component(&H.render_grid/1, attrs)
  end

  describe "grid/1 defaults" do
    test "renders a div" do
      assert render_grid() =~ "<div"
    end

    test "applies grid class" do
      assert render_grid() =~ "grid"
    end

    test "renders children" do
      assert render_grid() =~ "child"
    end
  end

  describe "grid/1 cols" do
    test "cols 3" do
      assert render_grid(%{cols: 3}) =~ "grid-cols-3"
    end

    test "cols 12" do
      assert render_grid(%{cols: 12}) =~ "grid-cols-12"
    end

    test "nil cols does not add grid-cols" do
      refute render_grid(%{cols: nil}) =~ "grid-cols"
    end
  end

  describe "grid/1 rows" do
    test "rows 2" do
      assert render_grid(%{rows: 2}) =~ "grid-rows-2"
    end
  end

  describe "grid/1 gap" do
    test "gap 4" do
      assert render_grid(%{gap: 4}) =~ "gap-4"
    end

    test "gap_x 6" do
      assert render_grid(%{gap_x: 6}) =~ "gap-x-6"
    end

    test "gap_y 2" do
      assert render_grid(%{gap_y: 2}) =~ "gap-y-2"
    end
  end

  describe "grid/1 flow" do
    test "flow col" do
      assert render_grid(%{flow: :col}) =~ "grid-flow-col"
    end

    test "flow dense" do
      assert render_grid(%{flow: :dense}) =~ "grid-flow-dense"
    end
  end

  describe "grid/1 align" do
    test "align center" do
      assert render_grid(%{align: :center}) =~ "items-center"
    end
  end

  describe "grid/1 class forwarding" do
    test "forwards custom class" do
      assert render_grid(%{class: "bg-muted"}) =~ "bg-muted"
    end
  end
end
