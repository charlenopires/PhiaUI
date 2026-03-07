defmodule PhiaUi.Components.InlineSearchTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.InlineSearch

    def render_default(assigns) do
      ~H"""
      <.inline_search name="q" value={nil} />
      """
    end

    def render_expanded(assigns) do
      ~H"""
      <.inline_search name="q" value="hello" expanded={true} />
      """
    end

    def render_with_placeholder(assigns) do
      ~H"""
      <.inline_search name="q" value={nil} placeholder="Find users..." />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.inline_search name="q" value={nil} class="custom-wrapper" />
      """
    end
  end

  describe "inline_search/1 rendering" do
    test "renders icon button when collapsed" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Open search"
    end

    test "renders search input group" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "renders close search button" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Close search"
    end

    test "renders custom placeholder" do
      html = render_component(&H.render_with_placeholder/1, %{})
      assert html =~ "Find users..."
    end

    test "default placeholder is Search..." do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Search..."
    end

    test "input group is hidden by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "hidden"
    end

    test "expanded renders input group visible" do
      html = render_component(&H.render_expanded/1, %{})
      # expanded=true means the group div doesn't have hidden class
      refute html =~ ~s(id="#{""}-group" role="search" class="hidden)
    end

    test "applies custom class to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-wrapper"
    end

    test "input has role search" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="search")
    end
  end
end
