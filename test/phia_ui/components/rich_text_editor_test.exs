defmodule PhiaUi.Components.RichTextEditorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.RichTextEditor

    attr(:field, :any)
    attr(:label, :string, default: nil)
    attr(:placeholder, :string, default: nil)
    attr(:min_height, :string, default: "200px")
    attr(:class, :string, default: nil)

    def render_rich_text_editor(assigns) do
      ~H"""
      <.rich_text_editor
        field={@field}
        label={@label}
        placeholder={@placeholder}
        min_height={@min_height}
        class={@class}
      />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "post_body"),
      name: Keyword.get(attrs, :name, "post[body]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :body),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: :field attr — hidden input uses field.id and field.name
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - :field attr" do
    test "hidden input uses field.id" do
      field = build_field(id: "post_body")
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(id="post_body")
    end

    test "hidden input uses field.name" do
      field = build_field(name: "post[body]")
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(name="post[body]")
    end

    test "renders a hidden input element" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(type="hidden")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: :label attr with default nil
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - :label attr" do
    test "renders label when :label is set" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field, label: "Content"})
      assert html =~ "<label"
      assert html =~ "Content"
    end

    test "does not render label when :label is nil" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      refute html =~ "<label"
    end

    test "label for attribute links to field.id" do
      field = build_field(id: "post_body")
      html = render_component(&H.render_rich_text_editor/1, %{field: field, label: "Content"})
      assert html =~ ~s(for="post_body")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: :placeholder attr with default nil
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - :placeholder attr" do
    test "sets data-placeholder on editable area when :placeholder is set" do
      field = build_field()

      html =
        render_component(&H.render_rich_text_editor/1, %{
          field: field,
          placeholder: "Write something..."
        })

      assert html =~ ~s(data-placeholder="Write something...")
    end

    test "does not set data-placeholder attribute when :placeholder is nil" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      # Check for the HTML attribute (data-placeholder="..."), not the CSS class utility
      refute html =~ ~r/data-placeholder="/
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: :min_height attr with default "200px"
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - :min_height attr" do
    test "applies default min-height of 200px to editable area" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ "min-height: 200px"
    end

    test "applies custom min-height when :min_height is set" do
      field = build_field()

      html =
        render_component(&H.render_rich_text_editor/1, %{field: field, min_height: "400px"})

      assert html =~ "min-height: 400px"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: :class attr with default nil
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - :class attr" do
    test "applies additional class to wrapper when :class is set" do
      field = build_field()

      html =
        render_component(&H.render_rich_text_editor/1, %{
          field: field,
          class: "my-custom-class"
        })

      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: phx-hook binding on editable area
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - hook binding" do
    test "editable area has phx-hook PhiaRichTextEditor" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(phx-hook="PhiaRichTextEditor")
    end

    test "editable area has data-phia-editor attribute" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ "data-phia-editor"
    end

    test "editable area sets data-content from field.value" do
      field = build_field(value: "<p>Hello</p>")
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-content="&lt;p&gt;Hello&lt;/p&gt;")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: toolbar buttons with data-action
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - toolbar buttons" do
    test "renders bold button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="bold")
    end

    test "renders italic button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="italic")
    end

    test "renders underline button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="underline")
    end

    test "renders strikethrough button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="strike")
    end

    test "renders h1 button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="h1")
    end

    test "renders h2 button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="h2")
    end

    test "renders h3 button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="h3")
    end

    test "renders paragraph button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="paragraph")
    end

    test "renders bullet list button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="bulletList")
    end

    test "renders ordered list button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="orderedList")
    end

    test "renders blockquote button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="blockquote")
    end

    test "renders inline code button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="code")
    end

    test "renders code block button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="codeBlock")
    end

    test "renders link button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="link")
    end

    test "renders unlink button" do
      field = build_field()
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ ~s(data-action="unlink")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: changeset errors via form_message/1
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - changeset errors" do
    test "renders error message from field.errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end

    test "renders multiple errors" do
      field = build_field(errors: [{"is invalid", []}, {"can't be blank", []}])
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      assert html =~ "is invalid"
      assert html =~ "can&#39;t be blank"
    end

    test "renders no error element when field.errors is empty" do
      field = build_field(errors: [])
      html = render_component(&H.render_rich_text_editor/1, %{field: field})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "rich_text_editor/1 - smoke test (uso esperado completo)" do
    test "renders complete editor with all attrs" do
      field = build_field(id: "post_body", name: "post[body]", value: "<p>Hello</p>")

      html =
        render_component(&H.render_rich_text_editor/1, %{
          field: field,
          label: "Post Body",
          placeholder: "Write your post...",
          min_height: "300px"
        })

      assert html =~ "Post Body"
      assert html =~ ~s(for="post_body")
      assert html =~ ~s(id="post_body")
      assert html =~ ~s(name="post[body]")
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(phx-hook="PhiaRichTextEditor")
      assert html =~ "data-phia-editor"
      assert html =~ "data-placeholder"
      assert html =~ "min-height: 300px"
      assert html =~ ~s(data-action="bold")
      assert html =~ ~s(data-action="italic")
      assert html =~ ~s(data-action="h1")
      assert html =~ ~s(data-action="link")
    end
  end
end
