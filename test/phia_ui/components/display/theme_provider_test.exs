defmodule PhiaUi.Components.ThemeProviderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ThemeProvider, only: [theme_provider: 1]

    def render_provider(assigns) do
      ~H"""
      <.theme_provider {assigns}>
        <span>content</span>
      </.theme_provider>
      """
    end
  end

  defp render_provider(attrs) do
    render_component(&H.render_provider/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # data-phia-theme attribute
  # ---------------------------------------------------------------------------

  describe "theme_provider/1 — data-phia-theme attribute" do
    test "atom theme sets data-phia-theme attribute" do
      html = render_provider(%{theme: :blue})
      assert html =~ ~s(data-phia-theme="blue")
    end

    test "zinc atom sets data-phia-theme=zinc" do
      html = render_provider(%{theme: :zinc})
      assert html =~ ~s(data-phia-theme="zinc")
    end

    test "rose atom sets data-phia-theme=rose" do
      html = render_provider(%{theme: :rose})
      assert html =~ ~s(data-phia-theme="rose")
    end

    test "struct theme uses theme.name" do
      theme = PhiaUi.Theme.get!(:violet)
      html = render_provider(%{theme: theme})
      assert html =~ ~s(data-phia-theme="violet")
    end

    test "nil theme does NOT render data-phia-theme attribute" do
      html = render_provider(%{theme: nil})
      refute html =~ "data-phia-theme"
    end

    test "unknown atom does NOT render data-phia-theme attribute" do
      html = render_provider(%{theme: :nonexistent_theme_xyz})
      refute html =~ "data-phia-theme"
    end
  end

  # ---------------------------------------------------------------------------
  # No <style> injection
  # ---------------------------------------------------------------------------

  describe "theme_provider/1 — no <style> injection" do
    test "does NOT inject a <style> tag for atom theme" do
      html = render_provider(%{theme: :blue})
      refute html =~ "<style"
    end

    test "does NOT inject a <style> tag for nil theme" do
      html = render_provider(%{theme: nil})
      refute html =~ "<style"
    end
  end

  # ---------------------------------------------------------------------------
  # Wrapper div and inner content
  # ---------------------------------------------------------------------------

  describe "theme_provider/1 — wrapper div" do
    test "renders a div wrapper" do
      html = render_provider(%{theme: :zinc})
      assert html =~ "<div"
    end

    test "renders inner content" do
      html = render_provider(%{theme: :zinc})
      assert html =~ "content"
    end

    test "class attr is applied" do
      html = render_provider(%{theme: :zinc, class: "my-class"})
      assert html =~ "my-class"
    end

    test "nil theme still renders inner content" do
      html = render_provider(%{theme: nil})
      assert html =~ "content"
    end
  end
end
