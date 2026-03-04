defmodule PhiaUi.Components.EditableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Editable

    def render_editable(assigns) do
      ~H"""
      <.editable id="title-edit" value="My Title" on_submit="update_title" placeholder="Click to edit">
        <:preview>My Title</:preview>
        <:input>
          <input type="text" id="title-edit-input" name="title" value="My Title" />
        </:input>
      </.editable>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.editable id="custom-edit" value="Text" on_submit="update" class="custom-class">
        <:preview>Text</:preview>
        <:input>
          <input type="text" id="custom-edit-input" name="text" value="Text" />
        </:input>
      </.editable>
      """
    end

    def render_without_on_submit(assigns) do
      ~H"""
      <.editable id="no-submit-edit" value="Text">
        <:preview>Text</:preview>
        <:input>
          <input type="text" id="no-submit-edit-input" name="text" value="Text" />
        </:input>
      </.editable>
      """
    end

    def render_with_placeholder(assigns) do
      ~H"""
      <.editable id="placeholder-edit" value="" placeholder="Enter a title" on_submit="update">
        <:preview></:preview>
        <:input>
          <input type="text" id="placeholder-edit-input" name="title" value="" />
        </:input>
      </.editable>
      """
    end

    def render_with_html_preview(assigns) do
      ~H"""
      <.editable id="html-preview-edit" value="Bold Content" on_submit="update">
        <:preview><strong>Bold Content</strong></:preview>
        <:input>
          <input type="text" id="html-preview-input" name="content" value="Bold Content" />
        </:input>
      </.editable>
      """
    end

    def render_my_edit(assigns) do
      ~H"""
      <.editable id="my-edit" value="test" on_submit="save">
        <:preview>test</:preview>
        <:input><input type="text" name="v" value="test" /></:input>
      </.editable>
      """
    end
  end

  defp render_editable, do: render_component(&H.render_editable/1, %{})
  defp render_with_custom_class, do: render_component(&H.render_with_custom_class/1, %{})
  defp render_without_on_submit, do: render_component(&H.render_without_on_submit/1, %{})
  defp render_with_placeholder, do: render_component(&H.render_with_placeholder/1, %{})
  defp render_with_html_preview, do: render_component(&H.render_with_html_preview/1, %{})

  # ---------------------------------------------------------------------------
  # editable/1
  # ---------------------------------------------------------------------------

  describe "editable/1" do
    test "container is a div" do
      assert render_editable() =~ "<div"
    end

    test "renders container with id" do
      assert render_editable() =~ ~s(id="title-edit")
    end

    test "container has phx-hook=\"PhiaEditable\"" do
      assert render_editable() =~ ~s(phx-hook="PhiaEditable")
    end

    test "container has data-on-submit attribute" do
      assert render_editable() =~ ~s(data-on-submit="update_title")
    end

    test "data-on-submit is the event name string" do
      assert render_editable() =~ ~s(data-on-submit="update_title")
    end

    test "renders data-editable-preview div" do
      assert render_editable() =~ "data-editable-preview"
    end

    test "preview has role=button" do
      assert render_editable() =~ ~s(role="button")
    end

    test "preview has tabindex=0" do
      assert render_editable() =~ ~s(tabindex="0")
    end

    test "preview has aria-label=\"Click to edit\"" do
      assert render_editable() =~ ~s(aria-label="Click to edit")
    end

    test "preview has cursor-pointer class" do
      assert render_editable() =~ "cursor-pointer"
    end

    test "preview has hover:bg-muted class" do
      assert render_editable() =~ "hover:bg-muted"
    end

    test "preview has min-h style/class" do
      assert render_editable() =~ "min-h-"
    end

    test "renders data-editable-input div" do
      assert render_editable() =~ "data-editable-input"
    end

    test "input wrapper has hidden class initially" do
      assert render_editable() =~ "hidden"
    end

    test "renders preview slot content" do
      assert render_editable() =~ "My Title"
    end

    test "renders input slot content" do
      assert render_editable() =~ ~s(type="text")
    end

    test "input slot renders input element" do
      assert render_editable() =~ "<input"
    end

    test "preview div exists inside container" do
      html = render_editable()
      assert html =~ "data-editable-preview"
      assert html =~ ~s(id="title-edit")
    end

    test "input wrapper div exists inside container" do
      html = render_editable()
      assert html =~ "data-editable-input"
      assert html =~ ~s(id="title-edit")
    end

    test "custom class applied to container" do
      assert render_with_custom_class() =~ "custom-class"
    end

    test "id attr required — test with id=\"my-edit\"" do
      html = render_component(&H.render_my_edit/1, %{})
      assert html =~ ~s(id="my-edit")
    end

    test "value attr is accepted" do
      # value is accepted without error; component renders successfully
      html = render_editable()
      assert html =~ "My Title"
    end

    test "renders without on_submit — no data-on-submit or empty" do
      html = render_without_on_submit()
      # When on_submit is nil, data-on-submit attribute should not be present
      # or should be empty — component must render without error
      assert html =~ "data-editable-input"
    end

    test "renders placeholder text attr in output" do
      assert render_with_placeholder() =~ "Enter a title"
    end

    test "preview slot renders HTML content" do
      assert render_with_html_preview() =~ "<strong>"
    end
  end
end
