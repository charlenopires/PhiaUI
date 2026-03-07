defmodule PhiaUi.Components.Layout.ContainerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Container

    def render_container(assigns) do
      ~H"""
      <.container
        size={assigns[:size] || :lg}
        centered={Map.get(assigns, :centered, true)}
        padding={Map.get(assigns, :padding, true)}
        class={assigns[:class]}
      >
        content
      </.container>
      """
    end
  end

  defp render_container(attrs \\ %{}) do
    render_component(&H.render_container/1, attrs)
  end

  describe "container/1 defaults" do
    test "renders a div" do
      assert render_container() =~ "<div"
    end

    test "applies w-full" do
      assert render_container() =~ "w-full"
    end

    test "applies max-w-screen-lg by default" do
      assert render_container() =~ "max-w-screen-lg"
    end

    test "applies mx-auto when centered" do
      assert render_container() =~ "mx-auto"
    end

    test "applies padding classes by default" do
      assert render_container() =~ "px-4"
    end

    test "renders content" do
      assert render_container() =~ "content"
    end
  end

  describe "container/1 size presets" do
    test "sm" do
      assert render_container(%{size: :sm}) =~ "max-w-screen-sm"
    end

    test "md" do
      assert render_container(%{size: :md}) =~ "max-w-screen-md"
    end

    test "xl" do
      assert render_container(%{size: :xl}) =~ "max-w-screen-xl"
    end

    test "2xl" do
      assert render_container(%{size: :"2xl"}) =~ "max-w-screen-2xl"
    end

    test "full" do
      assert render_container(%{size: :full}) =~ "max-w-full"
    end

    test "fluid has no max-w" do
      refute render_container(%{size: :fluid}) =~ "max-w-"
    end
  end

  describe "container/1 centered and padding" do
    test "centered false omits mx-auto" do
      refute render_container(%{centered: false}) =~ "mx-auto"
    end

    test "padding false omits px-4" do
      refute render_container(%{padding: false}) =~ "px-4"
    end
  end

  describe "container/1 class forwarding" do
    test "forwards custom class" do
      assert render_container(%{class: "py-8"}) =~ "py-8"
    end
  end
end
