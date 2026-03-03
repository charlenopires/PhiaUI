defmodule PhiaUi.ComponentHelpersTest do
  use PhiaUi.ComponentHelpers

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Button

    def render_button(assigns) do
      ~H"""
      <.button>Test</.button>
      """
    end
  end

  describe "render_component/2" do
    test "renders a component to an HTML string" do
      html = render_component(&H.render_button/1, %{})
      assert is_binary(html)
      assert html =~ "<button"
    end
  end

  describe "assert_has_class/2" do
    test "passes when HTML contains the class" do
      html = ~s(<div class="bg-primary text-white">content</div>)
      assert_has_class(html, "bg-primary")
    end

    test "fails with useful message when class is absent" do
      html = ~s(<div class="bg-secondary">content</div>)

      assert_raise ExUnit.AssertionError, fn ->
        assert_has_class(html, "bg-primary")
      end
    end
  end

  describe "refute_has_class/2" do
    test "passes when HTML does NOT contain the class" do
      html = ~s(<div class="bg-primary">content</div>)
      refute_has_class(html, "bg-destructive")
    end

    test "fails when the class IS present" do
      html = ~s(<div class="bg-primary bg-destructive">content</div>)

      assert_raise ExUnit.AssertionError, fn ->
        refute_has_class(html, "bg-destructive")
      end
    end
  end
end
