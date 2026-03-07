defmodule PhiaUi.Components.Layout.PageHeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.PageHeader

    def render_page_header(assigns) do
      ~H"""
      <.page_header border={assigns[:border] || false} class={assigns[:class]}>
        <:breadcrumb>Breadcrumb</:breadcrumb>
        <:title>Page Title</:title>
        <:description>Subtitle text</:description>
        <:actions><button>Action</button></:actions>
      </.page_header>
      """
    end

    def render_page_header_minimal(assigns) do
      ~H"""
      <.page_header>
        <:title>Minimal</:title>
      </.page_header>
      """
    end
  end

  defp render_page_header(attrs \\ %{}) do
    render_component(&H.render_page_header/1, attrs)
  end

  describe "page_header/1 default" do
    test "renders outer div" do
      assert render_page_header() =~ "<div"
    end

    test "applies py-6" do
      assert render_page_header() =~ "py-6"
    end

    test "renders breadcrumb slot" do
      assert render_page_header() =~ "Breadcrumb"
    end

    test "renders title in h1" do
      html = render_page_header()
      assert html =~ "<h1"
      assert html =~ "Page Title"
    end

    test "renders description" do
      assert render_page_header() =~ "Subtitle text"
    end

    test "renders actions slot" do
      assert render_page_header() =~ "Action"
    end
  end

  describe "page_header/1 border" do
    test "border true adds border-b border-border" do
      html = render_page_header(%{border: true})
      assert html =~ "border-b"
      assert html =~ "border-border"
    end

    test "border false omits border-b" do
      refute render_page_header(%{border: false}) =~ "border-b"
    end
  end

  describe "page_header/1 minimal (no breadcrumb/description/actions)" do
    test "renders just the title" do
      html = render_component(&H.render_page_header_minimal/1, %{})
      assert html =~ "Minimal"
      assert html =~ "<h1"
    end
  end

  describe "page_header/1 class forwarding" do
    test "forwards custom class" do
      assert render_page_header(%{class: "px-6"}) =~ "px-6"
    end
  end
end
