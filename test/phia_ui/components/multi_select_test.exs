defmodule PhiaUi.Components.MultiSelectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MultiSelect

    @options [{"Elixir", "elixir"}, {"Phoenix", "phoenix"}, {"LiveView", "liveview"}]

    def render_basic(assigns) do
      ~H"""
      <.multi_select
        id="framework-select"
        name="frameworks"
        options={[{"Elixir", "elixir"}, {"Phoenix", "phoenix"}, {"LiveView", "liveview"}]}
        selected={[]}
        placeholder="Select frameworks..."
        on_change="update_frameworks"
      />
      """
    end

    def render_with_selected(assigns) do
      ~H"""
      <.multi_select
        id="framework-select"
        name="frameworks"
        options={[{"Elixir", "elixir"}, {"Phoenix", "phoenix"}, {"LiveView", "liveview"}]}
        selected={["elixir", "phoenix"]}
        placeholder="Select frameworks..."
        on_change="update_frameworks"
      />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.multi_select
        id="lang-select"
        name="languages"
        options={[{"Elixir", "elixir"}, {"Rust", "rust"}]}
        selected={[]}
        disabled={true}
        on_change="update"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.multi_select
        id="class-select"
        name="items"
        options={[{"A", "a"}]}
        selected={[]}
        class="custom-class"
        on_change="update"
      />
      """
    end

    def render_form_multi_select(assigns) do
      field = %Phoenix.HTML.FormField{
        id: "user_categories",
        name: "user[categories]",
        errors: [],
        field: :categories,
        form: nil,
        value: ["elixir"]
      }

      ~H"""
      <.form_multi_select
        field={field}
        label="Categories"
        options={[{"Elixir", "elixir"}, {"Phoenix", "phoenix"}]}
        on_change="update_categories"
      />
      """
    end

    def render_form_multi_select_no_label(assigns) do
      field = %Phoenix.HTML.FormField{
        id: "user_tags",
        name: "user[tags]",
        errors: [],
        field: :tags,
        form: nil,
        value: []
      }

      ~H"""
      <.form_multi_select
        field={field}
        options={[{"Tag A", "a"}, {"Tag B", "b"}]}
        on_change="update_tags"
      />
      """
    end

    def render_form_multi_select_with_errors(assigns) do
      field = %Phoenix.HTML.FormField{
        id: "user_categories",
        name: "user[categories]",
        errors: [{"can't be blank", []}],
        field: :categories,
        form: nil,
        value: []
      }

      ~H"""
      <.form_multi_select
        field={field}
        label="Categories"
        options={[{"Elixir", "elixir"}]}
        on_change="update"
      />
      """
    end

    def render_form_multi_select_with_class(assigns) do
      field = %Phoenix.HTML.FormField{
        id: "user_items",
        name: "user[items]",
        errors: [],
        field: :items,
        form: nil,
        value: []
      }

      ~H"""
      <.form_multi_select
        field={field}
        options={[{"Item A", "a"}]}
        class="form-custom-class"
        on_change="update"
      />
      """
    end

    def render_form_multi_select_disabled(assigns) do
      field = %Phoenix.HTML.FormField{
        id: "user_items",
        name: "user[items]",
        errors: [],
        field: :items,
        form: nil,
        value: []
      }

      ~H"""
      <.form_multi_select
        field={field}
        options={[{"Item A", "a"}]}
        disabled={true}
        on_change="update"
      />
      """
    end
  end

  defp render_basic, do: render_component(&H.render_basic/1, %{})
  defp render_with_selected, do: render_component(&H.render_with_selected/1, %{})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_form_multi_select, do: render_component(&H.render_form_multi_select/1, %{})

  defp render_form_multi_select_no_label,
    do: render_component(&H.render_form_multi_select_no_label/1, %{})

  defp render_form_multi_select_with_errors,
    do: render_component(&H.render_form_multi_select_with_errors/1, %{})

  defp render_form_multi_select_with_class,
    do: render_component(&H.render_form_multi_select_with_class/1, %{})

  defp render_form_multi_select_disabled,
    do: render_component(&H.render_form_multi_select_disabled/1, %{})

  # ---------------------------------------------------------------------------
  # multi_select/1
  # ---------------------------------------------------------------------------

  describe "multi_select/1" do
    test "renders select element" do
      assert render_basic() =~ "<select"
    end

    test "select has multiple attribute" do
      assert render_basic() =~ "multiple"
    end

    test "select has correct name with [] suffix" do
      assert render_basic() =~ ~s(name="frameworks[]")
    end

    test "select has id attr" do
      assert render_basic() =~ ~s(id="framework-select")
    end

    test "renders all options" do
      html = render_basic()
      assert html =~ "Elixir"
      assert html =~ "Phoenix"
      assert html =~ "LiveView"
    end

    test "option has value attr" do
      html = render_basic()
      assert html =~ ~s(value="elixir")
      assert html =~ ~s(value="phoenix")
      assert html =~ ~s(value="liveview")
    end

    test "option label text rendered" do
      html = render_basic()
      assert html =~ "Elixir"
      assert html =~ "Phoenix"
    end

    test "selected option has selected attr" do
      html = render_with_selected()
      # Selected options should have the selected attribute
      assert html =~ "selected"
    end

    test "unselected option does not have selected attr for unselected value" do
      html = render_with_selected()
      # "liveview" is NOT in the selected list — verify it appears in the options
      assert html =~ "LiveView"
      # The liveview option should NOT have the selected attribute next to it.
      # We verify by checking value="liveview" does not appear adjacent to selected.
      refute html =~ ~s(value="liveview" selected)
    end

    test "disabled attr on select when disabled=true" do
      assert render_disabled() =~ "disabled"
    end

    test "renders selected chips when selection not empty" do
      html = render_with_selected()
      assert html =~ "data-selected-chips"
    end

    test "selected chip shows label text" do
      html = render_with_selected()
      # Should show labels (not values) in chips
      assert html =~ "Elixir"
      assert html =~ "Phoenix"
    end

    test "chip has remove button with aria-label" do
      html = render_with_selected()
      assert html =~ ~s(aria-label="Remove elixir")
      assert html =~ ~s(aria-label="Remove phoenix")
    end

    test "no chips when selected is empty list" do
      html = render_basic()
      refute html =~ "data-selected-chips"
    end

    test "aria-label on select with placeholder" do
      html = render_basic()
      assert html =~ ~s(aria-label="Select frameworks...")
    end

    test "custom class applied" do
      assert render_with_class() =~ "custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # form_multi_select/1
  # ---------------------------------------------------------------------------

  describe "form_multi_select/1" do
    test "renders label" do
      assert render_form_multi_select() =~ "Categories"
    end

    test "uses field.id for select id" do
      assert render_form_multi_select() =~ ~s(id="user_categories")
    end

    test "uses field.name for select name (with [] suffix)" do
      assert render_form_multi_select() =~ ~s(name="user[categories][]")
    end

    test "renders options" do
      html = render_form_multi_select()
      assert html =~ "Elixir"
      assert html =~ "Phoenix"
    end

    test "renders errors from field" do
      assert render_form_multi_select_with_errors() =~ "can&#39;t be blank"
    end

    test "no label when not given" do
      html = render_form_multi_select_no_label()
      refute html =~ "<label"
    end

    test "custom class applied in form_multi_select" do
      assert render_form_multi_select_with_class() =~ "form-custom-class"
    end

    test "disabled propagates to select element" do
      assert render_form_multi_select_disabled() =~ "disabled"
    end

    test "selected values from field.value" do
      html = render_form_multi_select()
      # field.value is ["elixir"], so elixir option should be selected
      assert html =~ "selected"
    end
  end
end
