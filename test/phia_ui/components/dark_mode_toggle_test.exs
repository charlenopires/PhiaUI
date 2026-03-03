defmodule PhiaUi.Components.DarkModeToggleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DarkModeToggle

    def render_default(assigns) do
      ~H"""
      <.dark_mode_toggle id="theme-toggle" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.dark_mode_toggle id="theme-toggle-2" class="custom-toggle" />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # dark_mode_toggle/1
  # ---------------------------------------------------------------------------

  describe "dark_mode_toggle/1 — structure" do
    test "renders a button element" do
      assert render_default() =~ "<button"
    end

    test "has phx-hook='PhiaDarkMode'" do
      assert render_default() =~ ~s(phx-hook="PhiaDarkMode")
    end

    test "has id attribute" do
      assert render_default() =~ ~s(id="theme-toggle")
    end

    test "has type='button'" do
      assert render_default() =~ ~s(type="button")
    end

    test "accepts :class and merges via cn/1" do
      assert render_with_class() =~ "custom-toggle"
    end
  end

  describe "dark_mode_toggle/1 — accessibility" do
    test "has aria-label attribute" do
      assert render_default() =~ "aria-label"
    end

    test "aria-label mentions dark mode or light mode" do
      html = render_default()
      assert html =~ "dark mode" or html =~ "light mode"
    end
  end

  describe "dark_mode_toggle/1 — icons" do
    test "renders sun icon for light mode" do
      assert render_default() =~ "sun"
    end

    test "renders moon icon for dark mode" do
      assert render_default() =~ "moon"
    end
  end
end
