defmodule PhiaUi.Components.SeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Separator

    attr(:orientation, :string, default: "horizontal")
    attr(:decorative, :boolean, default: true)
    attr(:class, :string, default: nil)

    def render_separator(assigns) do
      ~H"""
      <.separator orientation={@orientation} decorative={@decorative} class={@class} />
      """
    end
  end

  defp render_separator(attrs \\ %{}) do
    render_component(&H.render_separator/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # separator/1 — default (horizontal)
  # ---------------------------------------------------------------------------

  describe "separator/1 horizontal (default)" do
    test "renders a div element" do
      assert render_separator() =~ "<div"
    end

    test "applies w-full for horizontal" do
      assert render_separator() =~ "w-full"
    end

    test "applies h-px for horizontal" do
      assert render_separator() =~ "h-px"
    end

    test "uses semantic border-border token" do
      html = render_separator()
      assert html =~ "bg-border"
      refute html =~ "bg-gray-"
      refute html =~ "border-gray-"
    end
  end

  # ---------------------------------------------------------------------------
  # separator/1 — vertical
  # ---------------------------------------------------------------------------

  describe "separator/1 vertical" do
    test "applies h-full for vertical" do
      assert render_separator(%{orientation: "vertical"}) =~ "h-full"
    end

    test "applies w-px for vertical" do
      assert render_separator(%{orientation: "vertical"}) =~ "w-px"
    end

    test "does not apply w-full for vertical" do
      refute render_separator(%{orientation: "vertical"}) =~ "w-full"
    end
  end

  # ---------------------------------------------------------------------------
  # separator/1 — ARIA (decorative)
  # ---------------------------------------------------------------------------

  describe "separator/1 decorative=true (default)" do
    test "renders role=none when decorative" do
      assert render_separator(%{decorative: true}) =~ ~s(role="none")
    end

    test "does not render aria-orientation when decorative" do
      refute render_separator(%{decorative: true}) =~ "aria-orientation"
    end
  end

  describe "separator/1 decorative=false" do
    test "renders role=separator when not decorative" do
      assert render_separator(%{decorative: false}) =~ ~s(role="separator")
    end

    test "renders aria-orientation=horizontal by default" do
      html = render_separator(%{decorative: false})
      assert html =~ ~s(aria-orientation="horizontal")
    end

    test "renders aria-orientation=vertical for vertical" do
      html = render_separator(%{orientation: "vertical", decorative: false})
      assert html =~ ~s(aria-orientation="vertical")
    end
  end

  # ---------------------------------------------------------------------------
  # separator/1 — :class customization
  # ---------------------------------------------------------------------------

  describe "separator/1 :class customization" do
    test "applies custom class" do
      assert render_separator(%{class: "my-4"}) =~ "my-4"
    end

    test "nil class renders without issues" do
      html = render_separator(%{class: nil})
      assert html =~ "h-px"
    end
  end

  # ---------------------------------------------------------------------------
  # separator/1 — no hardcoded colors
  # ---------------------------------------------------------------------------

  describe "separator/1 semantic tokens only" do
    test "does not use hardcoded gray colors" do
      html = render_separator()
      refute html =~ "bg-gray-"
      refute html =~ "bg-zinc-"
      refute html =~ "bg-slate-"
    end

    test "does not use arbitrary color values" do
      html = render_separator()
      refute html =~ ~r/bg-\[#[0-9a-fA-F]/
    end
  end
end
