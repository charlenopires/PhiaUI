defmodule PhiaUi.Components.ToggleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Toggle

    attr(:pressed, :boolean, default: false)
    attr(:variant, :string, default: "default")
    attr(:size, :string, default: "default")
    attr(:class, :string, default: nil)

    def render_toggle(assigns) do
      ~H"""
      <.toggle pressed={@pressed} variant={@variant} size={@size} class={@class}>
        B
      </.toggle>
      """
    end
  end

  defp render_toggle(attrs \\ %{}) do
    render_component(&H.render_toggle/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "toggle/1 ARIA" do
    test "renders aria-pressed=false when not pressed" do
      assert render_toggle(%{pressed: false}) =~ ~s(aria-pressed="false")
    end

    test "renders aria-pressed=true when pressed" do
      assert render_toggle(%{pressed: true}) =~ ~s(aria-pressed="true")
    end

    test "renders as a button element" do
      assert render_toggle() =~ "<button"
    end

    test "renders inner content" do
      assert render_toggle() =~ "B"
    end
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — pressed state classes
  # ---------------------------------------------------------------------------

  describe "toggle/1 pressed state" do
    test "applies active classes when pressed=true" do
      html = render_toggle(%{pressed: true})
      assert html =~ "bg-accent"
    end

    test "does not apply bg-accent when pressed=false" do
      refute render_toggle(%{pressed: false}) =~ "bg-accent"
    end

    test "applies text-accent-foreground when pressed" do
      assert render_toggle(%{pressed: true}) =~ "text-accent-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — variants
  # ---------------------------------------------------------------------------

  describe "toggle/1 :variant default" do
    test "renders hover:bg-muted for default unpressed" do
      assert render_toggle(%{variant: "default"}) =~ "hover:bg-muted"
    end
  end

  describe "toggle/1 :variant outline" do
    test "renders border class for outline variant" do
      assert render_toggle(%{variant: "outline"}) =~ "border"
    end

    test "renders border-input for outline variant" do
      assert render_toggle(%{variant: "outline"}) =~ "border-input"
    end
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — sizes
  # ---------------------------------------------------------------------------

  describe "toggle/1 :size default" do
    test "renders h-10 for default size" do
      assert render_toggle(%{size: "default"}) =~ "h-10"
    end

    test "renders px-3 for default size" do
      assert render_toggle(%{size: "default"}) =~ "px-3"
    end
  end

  describe "toggle/1 :size sm" do
    test "renders h-9 for sm size" do
      assert render_toggle(%{size: "sm"}) =~ "h-9"
    end
  end

  describe "toggle/1 :size lg" do
    test "renders h-11 for lg size" do
      assert render_toggle(%{size: "lg"}) =~ "h-11"
    end
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — class customization
  # ---------------------------------------------------------------------------

  describe "toggle/1 :class" do
    test "applies custom class" do
      assert render_toggle(%{class: "my-custom"}) =~ "my-custom"
    end

    test "nil class renders without issues" do
      html = render_toggle(%{class: nil})
      assert html =~ ~s(aria-pressed)
    end
  end

  # ---------------------------------------------------------------------------
  # toggle/1 — semantic tokens
  # ---------------------------------------------------------------------------

  describe "toggle/1 no hardcoded colors" do
    test "does not use hardcoded gray colors" do
      html = render_toggle(%{pressed: true})
      refute html =~ "bg-gray-"
      refute html =~ "text-gray-"
    end

    test "base classes include transition" do
      assert render_toggle() =~ "transition"
    end

    test "includes focus ring classes" do
      html = render_toggle()
      assert html =~ "focus-visible:ring"
    end
  end
end
