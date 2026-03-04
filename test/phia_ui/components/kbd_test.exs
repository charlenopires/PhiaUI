defmodule PhiaUi.Components.KbdTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Kbd

    def render_kbd(assigns) do
      ~H"""
      <.kbd class={assigns[:class]}>Enter</.kbd>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.kbd data-testid="my-kbd">⌘</.kbd>
      """
    end
  end

  defp render_kbd(attrs \\ %{}), do: render_component(&H.render_kbd/1, attrs)

  describe "element" do
    test "renders kbd element" do
      assert render_kbd() =~ "<kbd"
    end

    test "renders content" do
      assert render_kbd() =~ "Enter"
    end
  end

  describe "base classes" do
    test "inline-flex" do
      assert render_kbd() =~ "inline-flex"
    end

    test "rounded" do
      assert render_kbd() =~ "rounded"
    end

    test "border" do
      assert render_kbd() =~ "border"
    end

    test "bg-muted" do
      assert render_kbd() =~ "bg-muted"
    end

    test "font-mono" do
      assert render_kbd() =~ "font-mono"
    end
  end

  describe "class override" do
    test "applies custom class" do
      assert render_kbd(%{class: "text-xs"}) =~ "text-xs"
    end
  end

  describe "rest passthrough" do
    test "passes data-testid" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-kbd")
    end
  end
end
