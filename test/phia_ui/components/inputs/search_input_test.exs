defmodule PhiaUi.Components.SearchInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SearchInput

    def render_default(assigns) do
      ~H"""
      <.search_input name="q" value={nil} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.search_input name="q" value="hello" on_clear="clear_q" />
      """
    end

    def render_minimal(assigns) do
      ~H"""
      <.search_input name="q" value={nil} variant="minimal" placeholder="Filter..." />
      """
    end

    def render_ghost(assigns) do
      ~H"""
      <.search_input name="q" value={nil} variant="ghost" />
      """
    end

    def render_with_shortcut(assigns) do
      ~H"""
      <.search_input name="q" value={nil} shortcut="⌘K" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.search_input name="q" value="test" disabled={true} on_clear="clear" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.search_input name="q" value={nil} class="my-wrapper" />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_form(assigns) do
      ~H"""
      <.form_search_input field={@field} label={@label} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"q" => value}, as: :search)
    field = form[:q]
    %{field | errors: errors}
  end

  describe "search_input/1 rendering" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "renders input type search" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="search")
    end

    test "renders magnifier icon" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "circle"
      assert html =~ "m21 21"
    end

    test "renders default placeholder" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Search..."
    end

    test "renders custom placeholder" do
      html = render_component(&H.render_minimal/1, %{})
      assert html =~ "Filter..."
    end

    test "renders clear button when value is present and on_clear is set" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "Clear search"
    end

    test "does not render clear button when value is nil" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "Clear search"
    end

    test "does not render clear button when disabled even if value present" do
      html = render_component(&H.render_disabled/1, %{})
      refute html =~ "Clear search"
    end

    test "renders shortcut badge when shortcut is set" do
      html = render_component(&H.render_with_shortcut/1, %{})
      assert html =~ "⌘K"
      assert html =~ "<kbd"
    end

    test "does not render shortcut badge by default" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "<kbd"
    end

    test "applies custom class to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-wrapper"
    end
  end

  describe "search_input/1 variants" do
    test "default variant has border-input class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border-input"
    end

    test "minimal variant has bg-muted" do
      html = render_component(&H.render_minimal/1, %{})
      assert html =~ "bg-muted"
    end

    test "ghost variant has bg-transparent" do
      html = render_component(&H.render_ghost/1, %{})
      assert html =~ "bg-transparent"
    end
  end

  describe "form_search_input/1" do
    test "renders label when given" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Search"})
      assert html =~ "Search"
      assert html =~ "<label"
    end

    test "renders error messages" do
      field = make_field("", [{"can't be blank", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "text-destructive"
    end
  end
end
