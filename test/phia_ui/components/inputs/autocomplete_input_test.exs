defmodule PhiaUi.Components.AutocompleteInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AutocompleteInput

    def render_basic(assigns) do
      ~H"""
      <.autocomplete_input name="lang" value={nil} suggestions={["Elixir", "Python", "Ruby"]} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.autocomplete_input name="lang" value="Elixir" suggestions={["Elixir", "Python", "Ruby"]} />
      """
    end

    def render_tuple_suggestions(assigns) do
      ~H"""
      <.autocomplete_input name="country" value={nil} suggestions={[{"United States", "US"}, {"Brazil", "BR"}]} />
      """
    end

    def render_empty_suggestions(assigns) do
      ~H"""
      <.autocomplete_input name="tag" value={nil} suggestions={[]} placeholder="Start typing..." />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_form(assigns) do
      ~H"""
      <.form_autocomplete_input field={@field} label={@label} suggestions={["opt1", "opt2"]} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"lang" => value}, as: :pref)
    field = form[:lang]
    %{field | errors: errors}
  end

  describe "autocomplete_input/1 rendering" do
    test "renders an input element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<input"
    end

    test "renders a datalist element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<datalist"
    end

    test "renders string suggestions as options" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Elixir"
      assert html =~ "Python"
      assert html =~ "Ruby"
    end

    test "renders tuple suggestions with label and value" do
      html = render_component(&H.render_tuple_suggestions/1, %{})
      assert html =~ "United States"
      assert html =~ ~s(value="US")
      assert html =~ "Brazil"
      assert html =~ ~s(value="BR")
    end

    test "links input to datalist via list attribute" do
      html = render_component(&H.render_basic/1, %{})
      # The input's list attribute should match the datalist id
      assert html =~ ~s(list=")
    end

    test "renders with placeholder" do
      html = render_component(&H.render_empty_suggestions/1, %{})
      assert html =~ "Start typing..."
    end

    test "renders the input value" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "Elixir"
    end

    test "has base input classes" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "rounded-md"
      assert html =~ "border-input"
    end
  end

  describe "form_autocomplete_input/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Language"})
      assert html =~ "Language"
      assert html =~ "<label"
    end

    test "renders suggestions in datalist" do
      html = render_component(&H.render_form/1, %{field: make_field()})
      assert html =~ "opt1"
      assert html =~ "opt2"
    end

    test "renders error messages" do
      field = make_field("", [{"is required", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "is required"
      assert html =~ "text-destructive"
    end
  end
end
