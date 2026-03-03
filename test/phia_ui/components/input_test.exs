defmodule PhiaUi.Components.InputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Input

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:description, :string, default: nil)
    attr(:class, :string, default: nil)
    attr(:type, :string, default: "text")

    def render_input(assigns) do
      ~H"""
      <.phia_input field={@field} label={@label} description={@description} class={@class} type={@type} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_debounce(assigns) do
      ~H"""
      <.phia_input field={@field} label={@label} phx-debounce="blur" />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"email" => value}, as: :user)
    field = form[:email]
    # Inject test errors as {msg, opts} tuples
    %{field | errors: errors}
  end

  defp render_input(attrs) do
    render_component(&H.render_input/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # phia_input/1 — basic rendering
  # ---------------------------------------------------------------------------

  describe "phia_input/1 basic rendering" do
    test "renders an input element" do
      html = render_input(%{field: make_field()})
      assert html =~ "<input"
    end

    test "renders a wrapping div" do
      html = render_input(%{field: make_field()})
      assert html =~ "<div"
    end

    test "input has the correct id from FormField" do
      html = render_input(%{field: make_field()})
      assert html =~ ~s(id="user_email")
    end

    test "input has the correct name from FormField" do
      html = render_input(%{field: make_field()})
      assert html =~ ~s(name="user[email]")
    end

    test "input has the correct value from FormField" do
      html = render_input(%{field: make_field("hello@example.com")})
      assert html =~ "hello@example.com"
    end

    test "input type defaults to text" do
      html = render_input(%{field: make_field()})
      assert html =~ ~s(type="text")
    end

    test "accepts custom type" do
      html = render_input(%{field: make_field(), type: "email"})
      assert html =~ ~s(type="email")
    end

    test "input has base Tailwind classes" do
      html = render_input(%{field: make_field()})
      assert html =~ "rounded-md"
      assert html =~ "border"
      assert html =~ "border-input"
    end

    test "accepts custom class" do
      html = render_input(%{field: make_field(), class: "my-custom"})
      assert html =~ "my-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # Label
  # ---------------------------------------------------------------------------

  describe "phia_input/1 label" do
    test "renders label element when label attr given" do
      html = render_input(%{field: make_field(), label: "Email"})
      assert html =~ "<label"
      assert html =~ "Email"
    end

    test "label has for attribute matching input id" do
      html = render_input(%{field: make_field(), label: "Email"})
      assert html =~ ~s(for="user_email")
    end

    test "does not render label when label is nil" do
      html = render_input(%{field: make_field()})
      refute html =~ "<label"
    end

    test "label has text-sm font-medium class" do
      html = render_input(%{field: make_field(), label: "Email"})
      assert html =~ "text-sm"
      assert html =~ "font-medium"
    end
  end

  # ---------------------------------------------------------------------------
  # Description
  # ---------------------------------------------------------------------------

  describe "phia_input/1 description" do
    test "renders description paragraph when given" do
      html = render_input(%{field: make_field(), description: "Your email address"})
      assert html =~ "Your email address"
    end

    test "description has muted-foreground class" do
      html = render_input(%{field: make_field(), description: "hint"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render description element when nil" do
      html = render_input(%{field: make_field()})
      # No description paragraph — placeholder:text-muted-foreground from the
      # input base class is expected, but not the standalone description <p>
      refute html =~ ~s(<p class="text-sm text-muted-foreground">)
    end
  end

  # ---------------------------------------------------------------------------
  # Errors
  # ---------------------------------------------------------------------------

  describe "phia_input/1 errors" do
    test "renders error messages from field.errors" do
      field = make_field("", [{"can't be blank", [validation: :required]}])
      html = render_input(%{field: field})
      # Phoenix HTML-escapes ' to &#39; in text content
      assert html =~ "can&#39;t be blank"
    end

    test "renders error paragraph with destructive class" do
      field = make_field("", [{"is invalid", []}])
      html = render_input(%{field: field})
      assert html =~ "text-destructive"
    end

    test "adds border-destructive to input when there are errors" do
      field = make_field("", [{"can't be blank", [validation: :required]}])
      html = render_input(%{field: field})
      assert html =~ "border-destructive"
    end

    test "no destructive classes when no errors" do
      html = render_input(%{field: make_field()})
      refute html =~ "text-destructive"
      refute html =~ "border-destructive"
    end

    test "interpolates %{count} in error message" do
      field = make_field("", [{"should be at least %{count} characters", [count: 3]}])
      html = render_input(%{field: field})
      assert html =~ "should be at least 3 characters"
    end

    test "renders multiple errors" do
      field = make_field("", [{"can't be blank", []}, {"is too short", []}])
      html = render_input(%{field: field})
      # Phoenix HTML-escapes ' to &#39;
      assert html =~ "can&#39;t be blank"
      assert html =~ "is too short"
    end
  end

  # ---------------------------------------------------------------------------
  # phx-debounce passthrough
  # ---------------------------------------------------------------------------

  describe "phia_input/1 phx-debounce" do
    test "passes phx-debounce to the input element" do
      html = render_component(&H.render_debounce/1, %{field: make_field(), label: "Email"})
      assert html =~ "phx-debounce"
    end
  end
end
