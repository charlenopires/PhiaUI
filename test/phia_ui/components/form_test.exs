defmodule PhiaUi.Components.FormTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Form

    attr :field, :any
    attr :type, :string, default: "text"
    attr :label, :string, default: nil
    attr :description, :string, default: nil

    def render_phia_input(assigns) do
      ~H"""
      <.phia_input field={@field} type={@type} label={@label} description={@description} />
      """
    end

    attr :field, :any

    def render_form_label(assigns) do
      ~H"""
      <.form_label field={@field}>Label text</.form_label>
      """
    end

    attr :field, :any

    def render_form_message(assigns) do
      ~H"""
      <.form_message field={@field} />
      """
    end

    attr :field, :any
    attr :label, :string, default: nil
    attr :description, :string, default: nil

    def render_form_field(assigns) do
      ~H"""
      <.form_field field={@field} label={@label} description={@description}>
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "user_email"),
      name: Keyword.get(attrs, :name, "user[email]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :email),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: :field attr (Phoenix.HTML.FormField, required)
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - :field attr" do
    test "uses field.id as input id" do
      field = build_field(id: "user_email")
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ ~s(id="user_email")
    end

    test "uses field.name as input name" do
      field = build_field(name: "user[email]")
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ ~s(name="user[email]")
    end

    test "uses field.value as input value" do
      field = build_field(value: "test@example.com")
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ ~s(value="test@example.com")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: :type attr with default "text"
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - :type attr" do
    test "defaults to type=text" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ ~s(type="text")
    end

    test "accepts type=email" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field, type: "email"})
      assert html =~ ~s(type="email")
    end

    test "accepts type=password" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field, type: "password"})
      assert html =~ ~s(type="password")
    end

    test "accepts type=number" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field, type: "number"})
      assert html =~ ~s(type="number")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: :label and :description attrs
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - :label attr" do
    test "renders label element when :label is set" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field, label: "Email"})
      assert html =~ "<label"
      assert html =~ "Email"
    end

    test "does not render label when :label is nil" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field})
      refute html =~ "<label"
    end
  end

  describe "phia_input/1 - :description attr" do
    test "renders description text when :description is set" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field, description: "Helper text"})
      assert html =~ "Helper text"
    end

    test "does not render description when :description is nil" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field})
      refute html =~ "Helper text"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: errors from changeset via FormField.errors
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - changeset errors" do
    test "renders error message from field.errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end

    test "renders multiple errors" do
      field = build_field(errors: [{"is too short", []}, {"is invalid", []}])
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ "is too short"
      assert html =~ "is invalid"
    end

    test "renders no error element when field.errors is empty" do
      field = build_field(errors: [])
      html = render_component(&H.render_phia_input/1, %{field: field})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: configurable error translator via Application.get_env
  # ---------------------------------------------------------------------------

  describe "translate_error/1 - configurable via Application.get_env" do
    setup do
      original = Application.get_env(:phia_ui, :error_translator_function)

      on_exit(fn ->
        if original do
          Application.put_env(:phia_ui, :error_translator_function, original)
        else
          Application.delete_env(:phia_ui, :error_translator_function)
        end
      end)

      :ok
    end

    test "delegates to custom translator when configured" do
      Application.put_env(:phia_ui, :error_translator_function, {__MODULE__, :custom_translator})
      result = PhiaUi.Components.Form.translate_error({"custom error", []})
      assert result == "CUSTOM: custom error"
    end

    def custom_translator({msg, _opts}), do: "CUSTOM: #{msg}"
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: fallback translation via Enum.reduce
  # ---------------------------------------------------------------------------

  describe "translate_error/1 - fallback Enum.reduce" do
    setup do
      original = Application.get_env(:phia_ui, :error_translator_function)

      on_exit(fn ->
        if original do
          Application.put_env(:phia_ui, :error_translator_function, original)
        else
          Application.delete_env(:phia_ui, :error_translator_function)
        end
      end)

      Application.delete_env(:phia_ui, :error_translator_function)
      :ok
    end

    test "interpolates %{key} placeholders" do
      result =
        PhiaUi.Components.Form.translate_error({"must be at least %{count} characters", [count: 8]})

      assert result == "must be at least 8 characters"
    end

    test "returns message unchanged when opts is empty" do
      result = PhiaUi.Components.Form.translate_error({"can't be blank", []})
      assert result == "can't be blank"
    end

    test "interpolates multiple placeholders" do
      result =
        PhiaUi.Components.Form.translate_error(
          {"must be between %{min} and %{max}", [min: 2, max: 10]}
        )

      assert result == "must be between 2 and 10"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: phx-debounce="blur" por padrão
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - phx-debounce" do
    test "applies phx-debounce=blur by default" do
      field = build_field()
      html = render_component(&H.render_phia_input/1, %{field: field})
      assert html =~ ~s(phx-debounce="blur")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: form_field/1 estrutura label + input + description + error
  # ---------------------------------------------------------------------------

  describe "form_field/1 - structure" do
    test "renders label when provided" do
      field = build_field()
      html = render_component(&H.render_form_field/1, %{field: field, label: "Name"})
      assert html =~ "<label"
      assert html =~ "Name"
    end

    test "renders inner_block (input slot)" do
      field = build_field()
      html = render_component(&H.render_form_field/1, %{field: field})
      assert html =~ "<input"
    end

    test "renders description when provided" do
      field = build_field()
      html = render_component(&H.render_form_field/1, %{field: field, description: "Helpful hint"})
      assert html =~ "Helpful hint"
    end

    test "renders errors from field" do
      field = build_field(errors: [{"is invalid", []}])
      html = render_component(&H.render_form_field/1, %{field: field})
      assert html =~ "is invalid"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 9: form_label/1 for= via field.id
  # ---------------------------------------------------------------------------

  describe "form_label/1" do
    test "sets for attribute to field.id" do
      field = build_field(id: "user_email")
      html = render_component(&H.render_form_label/1, %{field: field})
      assert html =~ ~s(for="user_email")
    end

    test "renders inner content" do
      field = build_field()
      html = render_component(&H.render_form_label/1, %{field: field})
      assert html =~ "Label text"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 10: form_message/1 renderização condicional
  # ---------------------------------------------------------------------------

  describe "form_message/1" do
    test "renders nothing when field has no errors" do
      field = build_field(errors: [])
      html = render_component(&H.render_form_message/1, %{field: field})
      refute html =~ "<p"
    end

    test "renders error paragraph when field has errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_form_message/1, %{field: field})
      assert html =~ "<p"
      assert html =~ "can&#39;t be blank"
    end

    test "renders one paragraph per error" do
      field = build_field(errors: [{"too short", []}, {"invalid", []}])
      html = render_component(&H.render_form_message/1, %{field: field})
      assert html =~ "too short"
      assert html =~ "invalid"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 11: smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "phia_input/1 - smoke test (uso esperado completo)" do
    test "renderiza input completo com label, type, id, name e phx-debounce" do
      field = build_field(id: "user_email", name: "user[email]", value: "")

      html =
        render_component(&H.render_phia_input/1, %{
          field: field,
          type: "email",
          label: "Email"
        })

      assert html =~ "Email"
      assert html =~ ~s(type="email")
      assert html =~ ~s(id="user_email")
      assert html =~ ~s(name="user[email]")
      assert html =~ ~s(phx-debounce="blur")
    end
  end
end
