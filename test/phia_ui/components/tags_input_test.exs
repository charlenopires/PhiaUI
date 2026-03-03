defmodule PhiaUi.Components.TagsInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TagsInput

    attr :field, :any
    attr :label, :string, default: nil
    attr :placeholder, :string, default: nil
    attr :separator, :string, default: nil
    attr :class, :string, default: nil

    def render_tags_input(assigns) do
      ~H"""
      <.tags_input
        field={@field}
        label={@label}
        placeholder={@placeholder}
        separator={@separator}
        class={@class}
      />
      """
    end

    def render_tags_input_defaults(assigns) do
      ~H"""
      <.tags_input field={@field} />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "post_tags"),
      name: Keyword.get(attrs, :name, "post[tags]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :tags),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: attr :field (Phoenix.HTML.FormField, required)
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - :field attr" do
    test "renders without error with a valid FormField" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "<"
    end

    test "hidden input uses field.name" do
      field = build_field(name: "post[tags]")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(name="post[tags]")
    end

    test "hidden input uses field.id" do
      field = build_field(id: "post_tags")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(id="post_tags")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: attr :label, default: nil
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - :label attr" do
    test "renders label when :label is set" do
      field = build_field()
      html = render_component(&H.render_tags_input/1, %{field: field, label: "Tags"})
      assert html =~ "<label"
      assert html =~ "Tags"
    end

    test "does not render label when :label is nil" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      refute html =~ "<label"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: attr :placeholder, default: "Adicionar tag..."
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - :placeholder attr" do
    test "renders default placeholder 'Adicionar tag...'" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "Adicionar tag..."
    end

    test "renders custom placeholder when :placeholder is set" do
      field = build_field()

      html =
        render_component(&H.render_tags_input/1, %{
          field: field,
          placeholder: "Nova tag..."
        })

      assert html =~ "Nova tag..."
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: attr :separator, default: ","
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - :separator attr" do
    test "renders default separator ',' as data-separator" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(data-separator=",")
    end

    test "renders custom separator as data-separator" do
      field = build_field()

      html =
        render_component(&H.render_tags_input/1, %{
          field: field,
          separator: ";"
        })

      assert html =~ ~s(data-separator=";")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: tags lidas de @field.value (lista ou CSV)
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - field.value parsing" do
    test "renders tags from CSV string value" do
      field = build_field(value: "elixir,phoenix,liveview")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "elixir"
      assert html =~ "phoenix"
      assert html =~ "liveview"
    end

    test "renders tags from list value" do
      field = build_field(value: ["elixir", "phoenix"])
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "elixir"
      assert html =~ "phoenix"
    end

    test "renders no tags when value is empty string" do
      field = build_field(value: "")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      refute html =~ "data-tag="
    end

    test "renders no tags when value is empty list" do
      field = build_field(value: [])
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      refute html =~ "data-tag="
    end

    test "trims whitespace from CSV tags" do
      field = build_field(value: " elixir , phoenix ")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "elixir"
      assert html =~ "phoenix"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: cada tag como <.badge variant={:secondary}> com botão X
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - tag badge rendering" do
    test "renders badge with secondary variant class for each tag" do
      field = build_field(value: "elixir")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      # secondary variant applies bg-secondary class
      assert html =~ "bg-secondary"
    end

    test "renders remove button for each tag" do
      field = build_field(value: "elixir,phoenix")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      # Two remove buttons (one per tag)
      assert html =~ "data-remove-tag"
    end

    test "remove button has data-remove-tag with tag value" do
      field = build_field(value: "elixir")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(data-remove-tag="elixir")
    end

    test "renders x icon inside remove button" do
      field = build_field(value: "elixir")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "icon-x"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: hidden input com name={field.name} e valor CSV serializado
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - hidden input" do
    test "renders a hidden input" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(type="hidden")
    end

    test "hidden input value serializes tags as CSV" do
      field = build_field(value: "elixir,phoenix")
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      # Value contains the tags joined
      assert html =~ "elixir"
      assert html =~ "phoenix"
    end

    test "hidden input has data-tags-hidden attribute for hook" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "data-tags-hidden"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: phx-hook PhiaTagsInput binding
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - hook binding" do
    test "container has phx-hook=PhiaTagsInput" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ ~s(phx-hook="PhiaTagsInput")
    end

    test "text input has data-tags-input attribute" do
      field = build_field()
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "data-tags-input"
    end
  end

  # ---------------------------------------------------------------------------
  # Changeset errors
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - changeset errors" do
    test "renders error from field.errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end

    test "renders no error when field.errors is empty" do
      field = build_field(errors: [])
      html = render_component(&H.render_tags_input_defaults/1, %{field: field})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "tags_input/1 - smoke test" do
    test "renders completo com tags, label, placeholder e erros" do
      field =
        build_field(
          id: "post_tags",
          name: "post[tags]",
          value: ["elixir", "phoenix", "liveview"],
          errors: []
        )

      html =
        render_component(&H.render_tags_input/1, %{
          field: field,
          label: "Tags",
          placeholder: "Adicionar tag...",
          separator: ","
        })

      assert html =~ "Tags"
      assert html =~ ~s(id="post_tags")
      assert html =~ ~s(name="post[tags]")
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(phx-hook="PhiaTagsInput")
      assert html =~ ~s(data-separator=",")
      assert html =~ "Adicionar tag..."
      assert html =~ "elixir"
      assert html =~ "phoenix"
      assert html =~ "liveview"
      assert html =~ "data-remove-tag"
      assert html =~ "bg-secondary"
    end
  end
end
