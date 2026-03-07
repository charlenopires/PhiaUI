defmodule PhiaUi.Components.Layout.SplitLayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.SplitLayout

    def render_split_layout(assigns) do
      ~H"""
      <.split_layout
        pane_position={assigns[:pane_position] || :start}
        pane_width={assigns[:pane_width] || :sm}
        class={assigns[:class]}
      >
        <:pane>Sidebar</:pane>
        Main
      </.split_layout>
      """
    end
  end

  defp render_split_layout(attrs \\ %{}) do
    render_component(&H.render_split_layout/1, attrs)
  end

  describe "split_layout/1 default" do
    test "renders a div" do
      assert render_split_layout() =~ "<div"
    end

    test "applies flex" do
      assert render_split_layout() =~ "flex"
    end

    test "renders pane content" do
      assert render_split_layout() =~ "Sidebar"
    end

    test "renders main content" do
      assert render_split_layout() =~ "Main"
    end

    test "main is a main element" do
      assert render_split_layout() =~ "<main"
    end

    test "default pane width sm applies w-64" do
      assert render_split_layout() =~ "w-64"
    end
  end

  describe "split_layout/1 pane_position end" do
    test "applies flex-row-reverse" do
      assert render_split_layout(%{pane_position: :end}) =~ "flex-row-reverse"
    end
  end

  describe "split_layout/1 pane_width" do
    test "xs applies w-48" do
      assert render_split_layout(%{pane_width: :xs}) =~ "w-48"
    end

    test "lg applies w-96" do
      assert render_split_layout(%{pane_width: :lg}) =~ "w-96"
    end
  end

  describe "split_layout/1 class forwarding" do
    test "forwards custom class" do
      assert render_split_layout(%{class: "h-screen"}) =~ "h-screen"
    end
  end
end
