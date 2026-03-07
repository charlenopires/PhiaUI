defmodule PhiaUi.Components.UrlInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UrlInput

    def render_default(assigns) do
      ~H"""
      <.url_input name="website" value="example.com" />
      """
    end

    def render_http(assigns) do
      ~H"""
      <.url_input name="api" value="localhost:4000" protocol="http" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.url_input name="site" value="example.com" disabled={true} />
      """
    end

    def render_custom_placeholder(assigns) do
      ~H"""
      <.url_input name="url" value={nil} placeholder="api.example.com/v1" />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_form(assigns) do
      ~H"""
      <.form_url_input field={@field} label={@label} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"website" => value}, as: :profile)
    field = form[:website]
    %{field | errors: errors}
  end

  describe "url_input/1 rendering" do
    test "renders input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "renders protocol selector" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<select"
      assert html =~ "https://"
      assert html =~ "http://"
    end

    test "selects https by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(value="https" selected)
    end

    test "selects http when protocol is http" do
      html = render_component(&H.render_http/1, %{})
      assert html =~ ~s(value="http" selected)
    end

    test "renders the value in input" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "example.com"
    end

    test "renders custom placeholder" do
      html = render_component(&H.render_custom_placeholder/1, %{})
      assert html =~ "api.example.com/v1"
    end

    test "applies disabled classes when disabled" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end
  end

  describe "form_url_input/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Website"})
      assert html =~ "Website"
    end

    test "renders error message" do
      field = make_field("", [{"is invalid", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "is invalid"
      assert html =~ "text-destructive"
    end

    test "renders field value" do
      html = render_component(&H.render_form/1, %{field: make_field("my-site.com")})
      assert html =~ "my-site.com"
    end
  end
end
