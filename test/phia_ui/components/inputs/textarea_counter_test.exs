defmodule PhiaUi.Components.TextareaCounterTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TextareaCounter

    def render_basic(assigns) do
      ~H"""
      <.textarea_counter name="body" value="" />
      """
    end

    def render_with_max(assigns) do
      ~H"""
      <.textarea_counter name="body" value="hello" max_length={280} />
      """
    end

    def render_warning(assigns) do
      ~H"""
      <.textarea_counter name="body" value={"x" |> String.duplicate(230)} max_length={280} />
      """
    end

    def render_exceeded(assigns) do
      ~H"""
      <.textarea_counter name="body" value={"x" |> String.duplicate(300)} max_length={280} />
      """
    end

    def render_no_count(assigns) do
      ~H"""
      <.textarea_counter name="body" value="hi" show_count={false} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:max_length, :integer, default: nil)

    def render_form(assigns) do
      ~H"""
      <.phia_textarea_counter field={@field} label={@label} max_length={@max_length} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"body" => value}, as: :post)
    field = form[:body]
    %{field | errors: errors}
  end

  describe "textarea_counter/1 rendering" do
    test "renders a textarea element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<textarea"
    end

    test "renders character count 0 when empty" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ">0<"
    end

    test "renders current count with max" do
      html = render_component(&H.render_with_max/1, %{})
      assert html =~ "5 / 280"
    end

    test "renders warning colour when >= 80% of max" do
      html = render_component(&H.render_warning/1, %{})
      assert html =~ "amber" || html =~ "text-amber"
    end

    test "renders destructive colour when exceeded" do
      html = render_component(&H.render_exceeded/1, %{})
      assert html =~ "text-destructive"
    end

    test "does not show counter when show_count is false" do
      html = render_component(&H.render_no_count/1, %{})
      refute html =~ "tabular-nums"
    end

    test "applies maxlength attr when max_length is set" do
      html = render_component(&H.render_with_max/1, %{})
      assert html =~ ~s(maxlength="280")
    end
  end

  describe "phia_textarea_counter/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Bio"})
      assert html =~ "Bio"
      assert html =~ "<label"
    end

    test "renders error messages" do
      field = make_field("", [{"can't be blank", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "text-destructive"
    end

    test "renders max count from field" do
      html = render_component(&H.render_form/1, %{field: make_field("abc"), max_length: 100})
      assert html =~ "3 / 100"
    end
  end
end
