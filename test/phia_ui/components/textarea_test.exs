defmodule PhiaUi.Components.TextareaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Textarea

    attr :field, :any
    attr :label, :string, default: nil
    attr :description, :string, default: nil
    attr :rows, :integer, default: 4
    attr :placeholder, :string, default: nil
    attr :class, :string, default: nil

    def render_phia_textarea(assigns) do
      ~H"""
      <.phia_textarea
        field={@field}
        label={@label}
        description={@description}
        rows={@rows}
        placeholder={@placeholder}
        class={@class}
      />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "user_bio"),
      name: Keyword.get(attrs, :name, "user[bio]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :bio),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: :field attr (Phoenix.HTML.FormField, required)
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :field attr" do
    test "uses field.id as textarea id" do
      field = build_field(id: "user_bio")
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ ~s(id="user_bio")
    end

    test "uses field.name as textarea name" do
      field = build_field(name: "user[bio]")
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ ~s(name="user[bio]")
    end

    test "renders field.value as textarea content" do
      field = build_field(value: "Hello world")
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "Hello world"
    end

    test "renders a <textarea> element" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "<textarea"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: :label attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :label attr" do
    test "renders label element when :label is set" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field, label: "Bio"})
      assert html =~ "<label"
      assert html =~ "Bio"
    end

    test "does not render label when :label is nil" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      refute html =~ "<label"
    end

    test "label for attribute links to field.id" do
      field = build_field(id: "user_bio")
      html = render_component(&H.render_phia_textarea/1, %{field: field, label: "Bio"})
      assert html =~ ~s(for="user_bio")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: :description attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :description attr" do
    test "renders description text when :description is set" do
      field = build_field()

      html =
        render_component(&H.render_phia_textarea/1, %{
          field: field,
          description: "Tell us about yourself"
        })

      assert html =~ "Tell us about yourself"
    end

    test "does not render description when :description is nil" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      refute html =~ "Tell us about yourself"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: :rows attr with default 4
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :rows attr" do
    test "defaults to rows=4" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ ~s(rows="4")
    end

    test "accepts custom rows value" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field, rows: 8})
      assert html =~ ~s(rows="8")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: :placeholder attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :placeholder attr" do
    test "renders placeholder attribute when :placeholder is set" do
      field = build_field()

      html =
        render_component(&H.render_phia_textarea/1, %{
          field: field,
          placeholder: "Write something..."
        })

      assert html =~ ~s(placeholder="Write something...")
    end

    test "does not render placeholder attribute when :placeholder is nil" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      refute html =~ "placeholder="
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: :class attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - :class attr" do
    test "applies additional class when :class is set" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field, class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: errors via form_message/1 de PhiaUi.Components.Form
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - changeset errors" do
    test "renders error message from field.errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end

    test "renders multiple errors" do
      field = build_field(errors: [{"is too short", []}, {"is invalid", []}])
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "is too short"
      assert html =~ "is invalid"
    end

    test "renders no error element when field.errors is empty" do
      field = build_field(errors: [])
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: phx-debounce="blur" por padrão
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - phx-debounce" do
    test "applies phx-debounce=blur by default on the textarea element" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ ~s(phx-debounce="blur")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 9: usa <.form_field> e <.form_label> de PhiaUi.Components.Form
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - form_field/form_label integration" do
    test "wraps content in space-y-2 container from form_field" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "space-y-2"
    end

    test "label is rendered via form_label with for linking to field.id" do
      field = build_field(id: "post_body")

      html =
        render_component(&H.render_phia_textarea/1, %{field: field, label: "Body"})

      assert html =~ ~s(for="post_body")
    end

    test "errors are rendered via form_message with text-destructive class" do
      field = build_field(errors: [{"is required", []}])
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "text-destructive"
      assert html =~ "is required"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 10: estilo consistente com phia_input/1
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - styling" do
    test "applies border class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "border"
    end

    test "applies rounded-md class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "rounded-md"
    end

    test "applies bg-background class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "bg-background"
    end

    test "applies px-3 py-2 padding classes" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "px-3"
      assert html =~ "py-2"
    end

    test "applies text-sm class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "text-sm"
    end

    test "applies w-full class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "w-full"
    end

    test "applies resize-y class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "resize-y"
    end

    test "applies min-h-[80px] class" do
      field = build_field()
      html = render_component(&H.render_phia_textarea/1, %{field: field})
      assert html =~ "min-h-"
    end
  end

  # ---------------------------------------------------------------------------
  # Smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "phia_textarea/1 - smoke test (uso esperado completo)" do
    test "renderiza textarea completo com todos os attrs" do
      field = build_field(id: "user_bio", name: "user[bio]", value: "Hello")

      html =
        render_component(&H.render_phia_textarea/1, %{
          field: field,
          label: "Bio",
          description: "Tell us about yourself",
          rows: 6,
          placeholder: "Write something..."
        })

      assert html =~ "Bio"
      assert html =~ "Tell us about yourself"
      assert html =~ ~s(id="user_bio")
      assert html =~ ~s(name="user[bio]")
      assert html =~ ~s(rows="6")
      assert html =~ ~s(placeholder="Write something...")
      assert html =~ ~s(phx-debounce="blur")
      assert html =~ "Hello"
    end
  end
end
