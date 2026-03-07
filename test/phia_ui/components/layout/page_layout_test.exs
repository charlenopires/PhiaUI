defmodule PhiaUi.Components.Layout.PageLayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.PageLayout

    def render_page_layout(assigns) do
      ~H"""
      <.page_layout
        pane_position={assigns[:pane_position] || :start}
        pane_width={assigns[:pane_width] || :sm}
        padding={assigns[:padding] || :normal}
        class={assigns[:class]}
      >
        <:header>Header</:header>
        <:pane>Sidebar</:pane>
        <:footer>Footer</:footer>
        Main content
      </.page_layout>
      """
    end

    def render_page_layout_minimal(assigns) do
      ~H"""
      <.page_layout>Main</.page_layout>
      """
    end
  end

  defp render_page_layout(attrs \\ %{}) do
    render_component(&H.render_page_layout/1, attrs)
  end

  describe "page_layout/1 default" do
    test "renders outer div with flex flex-col min-h-screen" do
      html = render_page_layout()
      assert html =~ "flex"
      assert html =~ "flex-col"
      assert html =~ "min-h-screen"
    end

    test "renders header slot" do
      assert render_page_layout() =~ "Header"
    end

    test "renders pane slot" do
      assert render_page_layout() =~ "Sidebar"
    end

    test "renders footer slot" do
      assert render_page_layout() =~ "Footer"
    end

    test "renders main content" do
      assert render_page_layout() =~ "Main content"
    end

    test "main is a main element" do
      assert render_page_layout() =~ "<main"
    end
  end

  describe "page_layout/1 without optional slots" do
    test "renders without header footer pane" do
      html = render_component(&H.render_page_layout_minimal/1, %{})
      assert html =~ "Main"
      assert html =~ "<main"
    end
  end

  describe "page_layout/1 pane_width" do
    test "pane width xs applies w-48" do
      assert render_page_layout(%{pane_width: :xs}) =~ "w-48"
    end

    test "pane width md applies w-80" do
      assert render_page_layout(%{pane_width: :md}) =~ "w-80"
    end

    test "pane width lg applies w-96" do
      assert render_page_layout(%{pane_width: :lg}) =~ "w-96"
    end
  end

  describe "page_layout/1 pane_position end" do
    test "end position uses flex-row-reverse" do
      assert render_page_layout(%{pane_position: :end}) =~ "flex-row-reverse"
    end
  end

  describe "page_layout/1 padding" do
    test "padding none has no p-" do
      html = render_page_layout(%{padding: :none})
      refute html =~ ~r/class="[^"]*\bp-\d/
    end

    test "padding condensed applies p-4" do
      assert render_page_layout(%{padding: :condensed}) =~ "p-4"
    end

    test "padding normal applies p-6" do
      assert render_page_layout(%{padding: :normal}) =~ "p-6"
    end
  end

  describe "page_layout/1 class forwarding" do
    test "forwards custom class" do
      assert render_page_layout(%{class: "bg-muted"}) =~ "bg-muted"
    end
  end
end
