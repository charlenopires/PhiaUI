defmodule PhiaUi.Components.ScrollAreaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ScrollArea

    attr(:orientation, :string, default: "vertical")
    attr(:class, :string, default: nil)

    def render_scroll_area(assigns) do
      ~H"""
      <.scroll_area orientation={@orientation} class={@class}>
        <p>Scrollable content</p>
      </.scroll_area>
      """
    end
  end

  defp render_scroll_area(attrs \\ %{}) do
    render_component(&H.render_scroll_area/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # scroll_area/1 — orientation variants
  # ---------------------------------------------------------------------------

  describe "scroll_area/1 — default (vertical)" do
    test "renders inner slot content" do
      assert render_scroll_area() =~ "Scrollable content"
    end

    test "vertical orientation applies overflow-y-auto" do
      assert render_scroll_area(%{orientation: "vertical"}) =~ "overflow-y-auto"
    end

    test "vertical orientation applies h-full" do
      assert render_scroll_area(%{orientation: "vertical"}) =~ "h-full"
    end

    test "default orientation is vertical (overflow-y-auto)" do
      assert render_scroll_area() =~ "overflow-y-auto"
    end
  end

  describe "scroll_area/1 — horizontal orientation" do
    test "horizontal orientation applies overflow-x-auto" do
      assert render_scroll_area(%{orientation: "horizontal"}) =~ "overflow-x-auto"
    end

    test "horizontal orientation applies w-full" do
      assert render_scroll_area(%{orientation: "horizontal"}) =~ "w-full"
    end

    test "horizontal orientation does not apply overflow-y-auto" do
      refute render_scroll_area(%{orientation: "horizontal"}) =~ "overflow-y-auto"
    end
  end

  describe "scroll_area/1 — both orientation" do
    test "both orientation applies overflow-auto" do
      assert render_scroll_area(%{orientation: "both"}) =~ "overflow-auto"
    end

    test "both orientation does not use overflow-x-auto or overflow-y-auto" do
      html = render_scroll_area(%{orientation: "both"})
      refute html =~ "overflow-x-auto"
      refute html =~ "overflow-y-auto"
    end
  end

  describe "scroll_area/1 — scrollbar styling" do
    test "applies scrollbar-thin for thin scrollbar" do
      assert render_scroll_area() =~ "scrollbar-thin"
    end

    test "applies scrollbar-track-transparent" do
      assert render_scroll_area() =~ "scrollbar-track-transparent"
    end

    test "applies scrollbar-thumb-muted-foreground/30 (semantic token)" do
      assert render_scroll_area() =~ "scrollbar-thumb-muted-foreground/30"
    end
  end

  describe "scroll_area/1 — :class merge" do
    test "adds custom class" do
      assert render_scroll_area(%{class: "max-h-64"}) =~ "max-h-64"
    end

    test "preserves base classes alongside custom class" do
      html = render_scroll_area(%{class: "max-h-64"})
      assert html =~ "overflow-y-auto"
      assert html =~ "scrollbar-thin"
    end
  end
end
