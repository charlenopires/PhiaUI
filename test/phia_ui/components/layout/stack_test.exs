defmodule PhiaUi.Components.Layout.StackTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Stack

    def render_stack(assigns) do
      ~H"""
      <.stack
        direction={assigns[:direction] || :vertical}
        gap={assigns[:gap] || 4}
        align={assigns[:align]}
        justify={assigns[:justify]}
        wrap={assigns[:wrap] || false}
        class={assigns[:class]}
      >
        child
      </.stack>
      """
    end
  end

  defp render_stack(attrs \\ %{}) do
    render_component(&H.render_stack/1, attrs)
  end

  describe "stack/1 defaults" do
    test "renders a div" do
      assert render_stack() =~ "<div"
    end

    test "applies flex" do
      assert render_stack() =~ "flex"
    end

    test "defaults to flex-col" do
      assert render_stack() =~ "flex-col"
    end

    test "defaults to gap-4" do
      assert render_stack() =~ "gap-4"
    end

    test "renders inner content" do
      assert render_stack() =~ "child"
    end
  end

  describe "stack/1 direction" do
    test "vertical uses flex-col" do
      assert render_stack(%{direction: :vertical}) =~ "flex-col"
    end

    test "horizontal uses flex-row" do
      assert render_stack(%{direction: :horizontal}) =~ "flex-row"
    end
  end

  describe "stack/1 gap" do
    test "gap-0" do
      assert render_stack(%{gap: 0}) =~ "gap-0"
    end

    test "gap-8" do
      assert render_stack(%{gap: 8}) =~ "gap-8"
    end
  end

  describe "stack/1 align and justify" do
    test "align center" do
      assert render_stack(%{align: :center}) =~ "items-center"
    end

    test "justify end" do
      assert render_stack(%{justify: :end}) =~ "justify-end"
    end
  end

  describe "stack/1 wrap" do
    test "wrap adds flex-wrap" do
      assert render_stack(%{wrap: true}) =~ "flex-wrap"
    end

    test "no wrap by default" do
      refute render_stack() =~ "flex-wrap"
    end
  end

  describe "stack/1 class forwarding" do
    test "forwards custom class" do
      assert render_stack(%{class: "p-6"}) =~ "p-6"
    end
  end
end
