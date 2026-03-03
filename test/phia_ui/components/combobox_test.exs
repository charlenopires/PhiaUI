defmodule PhiaUi.Components.ComboboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Combobox

    def render_closed(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        open={false}
      />
      """
    end

    def render_open(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        open={true}
      />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        value="apple"
        open={true}
      />
      """
    end

    def render_filtered(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        open={true}
        search="ban"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "a", label: "A"}]}
        open={false}
        class="custom-combobox"
      />
      """
    end

    def render_custom_events(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}]}
        open={true}
        on_change="my-change"
        on_search="my-search"
        on_toggle="my-toggle"
      />
      """
    end

    def render_keyword_options(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[{"Apple", "apple"}, {"Banana", "banana"}]}
        open={true}
      />
      """
    end

    def render_empty_search(assigns) do
      ~H"""
      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}]}
        open={true}
        search="zzz"
      />
      """
    end

    def render_form_combobox(assigns) do
      form = %Phoenix.HTML.Form{
        source: %{},
        impl: Phoenix.HTML.FormData.Map,
        id: "user",
        name: "user",
        params: %{},
        hidden: [],
        options: [],
        errors: [],
        data: %{},
        action: nil,
        index: nil
      }

      field = %Phoenix.HTML.FormField{
        id: "user_fruit",
        name: "user[fruit]",
        errors: [],
        field: :fruit,
        form: form,
        value: nil
      }

      assigns = Map.put(assigns, :field, field)

      ~H"""
      <.form_combobox
        id="form-fruit-picker"
        field={@field}
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        value="apple"
        open={false}
      />
      """
    end

    def render_form_combobox_with_errors(assigns) do
      form = %Phoenix.HTML.Form{
        source: %{},
        impl: Phoenix.HTML.FormData.Map,
        id: "user",
        name: "user",
        params: %{},
        hidden: [],
        options: [],
        errors: [],
        data: %{},
        action: nil,
        index: nil
      }

      field = %Phoenix.HTML.FormField{
        id: "user_fruit",
        name: "user[fruit]",
        errors: [{"can't be blank", [validation: :required]}],
        field: :fruit,
        form: form,
        value: nil
      }

      assigns = Map.put(assigns, :field, field)

      ~H"""
      <.form_combobox
        id="form-fruit-picker"
        field={@field}
        options={[%{value: "apple", label: "Apple"}]}
        value={nil}
        open={false}
      />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # combobox/1 — trigger state
  # ---------------------------------------------------------------------------

  describe "combobox/1 — trigger" do
    test "shows placeholder when no value" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "Select an option..."
    end

    test "trigger has aria-haspopup=listbox" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-haspopup="listbox")
    end

    test "trigger has aria-expanded=false when closed" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-expanded="false")
    end

    test "trigger has aria-expanded=true when open" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-expanded="true")
    end

    test "trigger has aria-controls pointing to listbox" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-controls="fruit-picker-listbox")
    end

    test "trigger fires phx-click with default toggle event" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(phx-click="combobox-toggle")
    end

    test "trigger fires phx-click with custom toggle event" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ ~s(phx-click="my-toggle")
    end

    test "shows selected label in trigger when value is set" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "Apple"
    end

    test "accepts :class via cn/1" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-combobox"
    end
  end

  # ---------------------------------------------------------------------------
  # combobox/1 — dropdown visibility
  # ---------------------------------------------------------------------------

  describe "combobox/1 — dropdown visibility" do
    test "dropdown hidden when open=false" do
      html = render_component(&H.render_closed/1, %{})
      refute html =~ ~s(role="listbox")
    end

    test "dropdown visible when open=true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(role="listbox")
    end

    test "dropdown has correct id" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(id="fruit-picker-listbox")
    end
  end

  # ---------------------------------------------------------------------------
  # combobox/1 — options rendering
  # ---------------------------------------------------------------------------

  describe "combobox/1 — options" do
    test "renders all options when open" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Apple"
      assert html =~ "Banana"
    end

    test "options have role=option" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(role="option")
    end

    test "options have phx-value-value" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(phx-value-value="apple")
      assert html =~ ~s(phx-value-value="banana")
    end

    test "options have phx-click with default on_change event" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(phx-click="combobox-change")
    end

    test "options have phx-click with custom on_change event" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ ~s(phx-click="my-change")
    end

    test "accepts keyword list options" do
      html = render_component(&H.render_keyword_options/1, %{})
      assert html =~ "Apple"
      assert html =~ "Banana"
    end

    test "shows empty state when no options match search" do
      html = render_component(&H.render_empty_search/1, %{})
      assert html =~ "No options found."
    end
  end

  # ---------------------------------------------------------------------------
  # combobox/1 — selected state
  # ---------------------------------------------------------------------------

  describe "combobox/1 — selected state" do
    test "selected option shows check icon" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "&#10003;"
    end

    test "selected option has aria-selected=true" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(aria-selected="true")
    end

    test "unselected option has aria-selected=false" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(aria-selected="false")
    end
  end

  # ---------------------------------------------------------------------------
  # combobox/1 — search / filter
  # ---------------------------------------------------------------------------

  describe "combobox/1 — search" do
    test "filters options by search query (case-insensitive)" do
      html = render_component(&H.render_filtered/1, %{})
      assert html =~ "Banana"
      refute html =~ "Apple"
    end

    test "search input has phx-change with default on_search event" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(phx-change="combobox-search")
    end

    test "search input has phx-change with custom on_search event" do
      html = render_component(&H.render_custom_events/1, %{})
      assert html =~ ~s(phx-change="my-search")
    end

    test "search input renders with placeholder" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Search..."
    end
  end

  # ---------------------------------------------------------------------------
  # form_combobox/1 — FormField integration
  # ---------------------------------------------------------------------------

  describe "form_combobox/1 — FormField integration" do
    test "renders hidden input with field name" do
      html = render_component(&H.render_form_combobox/1, %{})
      assert html =~ ~s(name="user[fruit]")
      assert html =~ ~s(type="hidden")
    end

    test "hidden input has selected value" do
      html = render_component(&H.render_form_combobox/1, %{})
      assert html =~ ~s(value="apple")
    end

    test "renders combobox trigger" do
      html = render_component(&H.render_form_combobox/1, %{})
      assert html =~ ~s(aria-haspopup="listbox")
    end

    test "renders errors when field has errors" do
      html = render_component(&H.render_form_combobox_with_errors/1, %{})
      assert html =~ "can&#39;t be blank"
    end

    test "renders no errors when field has no errors" do
      html = render_component(&H.render_form_combobox/1, %{})
      refute html =~ "text-destructive"
    end
  end
end
