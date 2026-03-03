defmodule PhiaUi.Components.SelectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Select

    attr(:field, :any)
    attr(:options, :list, default: [])
    attr(:prompt, :string, default: nil)
    attr(:label, :string, default: nil)
    attr(:description, :string, default: nil)
    attr(:class, :string, default: nil)

    def render_phia_select(assigns) do
      ~H"""
      <.phia_select
        field={@field}
        options={@options}
        prompt={@prompt}
        label={@label}
        description={@description}
        class={@class}
      />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "post_category"),
      name: Keyword.get(attrs, :name, "post[category]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :category),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: :field attr (Phoenix.HTML.FormField, required)
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :field attr" do
    test "uses field.id as select id" do
      field = build_field(id: "post_category")
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ ~s(id="post_category")
    end

    test "uses field.name as select name" do
      field = build_field(name: "post[category]")
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ ~s(name="post[category]")
    end

    test "renders a <select> element" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "<select"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: :options attr — multiple list formats
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :options attr (keyword list format)" do
    test "renders options from [{label, value}] tuples" do
      field = build_field()
      options = [{"Technology", "tech"}, {"Sports", "sports"}]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      assert html =~ "Technology"
      assert html =~ ~s(value="tech")
      assert html =~ "Sports"
      assert html =~ ~s(value="sports")
    end

    test "renders options from plain string list" do
      field = build_field()
      options = ["tech", "sports"]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      assert html =~ ~s(value="tech")
      assert html =~ ~s(value="sports")
    end

    test "marks selected option when field.value matches" do
      field = build_field(value: "sports")
      options = [{"Technology", "tech"}, {"Sports", "sports"}]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      assert html =~ "selected"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: :prompt attr — empty option at top
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :prompt attr" do
    test "renders prompt as <option value=\"\"> at top when set" do
      field = build_field()

      html =
        render_component(&H.render_phia_select/1, %{
          field: field,
          options: [],
          prompt: "Choose a category"
        })

      assert html =~ ~s(value="")
      assert html =~ "Choose a category"
    end

    test "does not render empty option when :prompt is nil" do
      field = build_field()
      options = [{"Tech", "tech"}]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      refute html =~ ~s(value="")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: :label attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :label attr" do
    test "renders label element when :label is set" do
      field = build_field()

      html =
        render_component(&H.render_phia_select/1, %{field: field, options: [], label: "Category"})

      assert html =~ "<label"
      assert html =~ "Category"
    end

    test "does not render label when :label is nil" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      refute html =~ "<label"
    end

    test "label for attribute links to field.id" do
      field = build_field(id: "post_category")

      html =
        render_component(&H.render_phia_select/1, %{field: field, options: [], label: "Category"})

      assert html =~ ~s(for="post_category")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: :description attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :description attr" do
    test "renders description when :description is set" do
      field = build_field()

      html =
        render_component(&H.render_phia_select/1, %{
          field: field,
          options: [],
          description: "Choose the post category"
        })

      assert html =~ "Choose the post category"
    end

    test "does not render description when :description is nil" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      refute html =~ "Choose the post category"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: :class attr with default nil
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - :class attr" do
    test "applies additional class when :class is set" do
      field = build_field()

      html =
        render_component(&H.render_phia_select/1, %{
          field: field,
          options: [],
          class: "my-custom-class"
        })

      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: <select> HTML nativo com options_for_select/2
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - native <select> with options_for_select" do
    test "renders <option> elements for each option" do
      field = build_field()
      options = [{"Label A", "a"}, {"Label B", "b"}]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      assert html =~ "<option"
      assert html =~ "Label A"
      assert html =~ "Label B"
    end

    test "wraps options inside a <select> element" do
      field = build_field()
      options = [{"One", "1"}]
      html = render_component(&H.render_phia_select/1, %{field: field, options: options})
      assert html =~ "<select"
      assert html =~ "<option"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: errors via form_message/1
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - changeset errors" do
    test "renders error message from field.errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "can&#39;t be blank"
    end

    test "renders multiple errors" do
      field = build_field(errors: [{"is invalid", []}, {"can't be blank", []}])
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "is invalid"
      assert html =~ "can&#39;t be blank"
    end

    test "renders no error element when field.errors is empty" do
      field = build_field(errors: [])
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 9: styling consistent with phia_input/1
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - styling" do
    test "applies h-10 class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "h-10"
    end

    test "applies w-full class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "w-full"
    end

    test "applies rounded-md class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "rounded-md"
    end

    test "applies border class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "border"
    end

    test "applies bg-background class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "bg-background"
    end

    test "applies px-3 py-2 padding classes" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "px-3"
      assert html =~ "py-2"
    end

    test "applies text-sm class" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "text-sm"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 10: chevron-down icon positioned absolutely on right
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - chevron-down icon" do
    test "renders chevron-down icon" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "chevron-down"
    end

    test "icon wrapper has absolute positioning on right side" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "absolute"
      assert html =~ "right-"
    end

    test "select wrapper has relative positioning" do
      field = build_field()
      html = render_component(&H.render_phia_select/1, %{field: field, options: []})
      assert html =~ "relative"
    end
  end

  # ---------------------------------------------------------------------------
  # Smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "phia_select/1 - smoke test (uso esperado completo)" do
    test "renders complete select with all attrs" do
      field = build_field(id: "post_category", name: "post[category]", value: "sports")

      options = [{"Technology", "tech"}, {"Sports", "sports"}, {"Politics", "politics"}]

      html =
        render_component(&H.render_phia_select/1, %{
          field: field,
          options: options,
          prompt: "Choose...",
          label: "Category",
          description: "Select the post category"
        })

      assert html =~ "Category"
      assert html =~ "Select the post category"
      assert html =~ ~s(id="post_category")
      assert html =~ ~s(name="post[category]")
      assert html =~ "Choose..."
      assert html =~ "Technology"
      assert html =~ "Sports"
      assert html =~ "selected"
      assert html =~ "chevron-down"
    end
  end
end
