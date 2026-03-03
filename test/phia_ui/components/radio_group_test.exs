defmodule PhiaUi.Components.RadioGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.RadioGroup

    attr(:value, :string, default: nil)
    attr(:name, :string, default: "choice")
    attr(:orientation, :string, default: "vertical")
    attr(:class, :string, default: nil)

    def render_radio_group(assigns) do
      ~H"""
      <.radio_group :let={group} value={@value} name={@name} orientation={@orientation} class={@class}>
        <.radio_group_item value="apple" label="Apple" {group} />
        <.radio_group_item value="banana" label="Banana" {group} />
        <.radio_group_item value="cherry" label="Cherry" {group} />
      </.radio_group>
      """
    end

    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:name, :string, default: "item")
    attr(:group_value, :string, default: nil)
    attr(:disabled, :boolean, default: false)

    def render_item(assigns) do
      ~H"""
      <.radio_group_item value={@value} label={@label} name={@name} group_value={@group_value} disabled={@disabled} />
      """
    end

    attr(:field, Phoenix.HTML.FormField, required: true)
    attr(:options, :list, default: [])
    attr(:label, :string, default: nil)

    def render_form_radio(assigns) do
      ~H"""
      <.form_radio_group field={@field} options={@options} label={@label} />
      """
    end
  end

  defp render_radio_group(attrs \\ %{}) do
    render_component(&H.render_radio_group/1, attrs)
  end

  defp render_item(attrs) do
    render_component(&H.render_item/1, attrs)
  end

  defp build_field(value \\ nil) do
    form = Phoenix.HTML.FormData.to_form(%{}, as: :test, skip_hidden: true)

    %Phoenix.HTML.FormField{
      id: "test_color",
      name: "test[color]",
      errors: [],
      field: :color,
      form: form,
      value: value
    }
  end

  defp render_form_radio(attrs) do
    render_component(&H.render_form_radio/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # radio_group/1 — container
  # ---------------------------------------------------------------------------

  describe "radio_group/1 container" do
    test "renders role=radiogroup" do
      assert render_radio_group() =~ ~s(role="radiogroup")
    end

    test "renders all items" do
      html = render_radio_group()
      assert html =~ "Apple"
      assert html =~ "Banana"
      assert html =~ "Cherry"
    end

    test "applies custom class" do
      assert render_radio_group(%{class: "gap-4"}) =~ "gap-4"
    end
  end

  describe "radio_group/1 orientation" do
    test "vertical orientation applies flex-col" do
      assert render_radio_group(%{orientation: "vertical"}) =~ "flex-col"
    end

    test "horizontal orientation applies flex-row" do
      assert render_radio_group(%{orientation: "horizontal"}) =~ "flex-row"
    end
  end

  # ---------------------------------------------------------------------------
  # radio_group/1 — checked state
  # ---------------------------------------------------------------------------

  describe "radio_group/1 checked state" do
    test "item matching group value is checked" do
      html = render_radio_group(%{value: "banana"})
      assert html =~ ~s(value="banana" checked)
    end

    test "non-matching items are not checked" do
      html = render_radio_group(%{value: "banana"})
      refute html =~ ~s(value="apple" checked)
    end

    test "no item checked when value is nil" do
      html = render_radio_group(%{value: nil})
      refute html =~ "checked"
    end
  end

  # ---------------------------------------------------------------------------
  # radio_group_item/1
  # ---------------------------------------------------------------------------

  describe "radio_group_item/1 structure" do
    test "renders an input[type=radio]" do
      html = render_item(%{value: "red", label: "Red", group_value: nil})
      assert html =~ ~s(type="radio")
    end

    test "renders label text" do
      html = render_item(%{value: "red", label: "Red", group_value: nil})
      assert html =~ "Red"
    end

    test "input has correct value attribute" do
      html = render_item(%{value: "red", label: "Red", group_value: nil})
      assert html =~ ~s(value="red")
    end

    test "input has name attribute" do
      html = render_item(%{value: "x", label: "X", name: "color", group_value: nil})
      assert html =~ ~s(name="color")
    end
  end

  describe "radio_group_item/1 checked" do
    test "checked when group_value matches" do
      html = render_item(%{value: "red", label: "Red", group_value: "red"})
      assert html =~ "checked"
    end

    test "not checked when group_value does not match" do
      html = render_item(%{value: "red", label: "Red", group_value: "blue"})
      refute html =~ "checked"
    end

    test "not checked when group_value is nil" do
      html = render_item(%{value: "red", label: "Red", group_value: nil})
      refute html =~ "checked"
    end
  end

  describe "radio_group_item/1 disabled" do
    test "renders disabled attribute when disabled" do
      html = render_item(%{value: "x", label: "X", group_value: nil, disabled: true})
      assert html =~ "disabled"
    end

    test "not disabled by default" do
      html = render_item(%{value: "x", label: "X", group_value: nil})
      refute html =~ "disabled"
    end
  end

  describe "radio_group_item/1 visual indicator" do
    test "renders custom radio indicator circle" do
      html = render_item(%{value: "x", label: "X", group_value: nil})
      assert html =~ "rounded-full"
    end

    test "uses border-primary token" do
      html = render_item(%{value: "x", label: "X", group_value: nil})
      assert html =~ "border-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # form_radio_group/1
  # ---------------------------------------------------------------------------

  describe "form_radio_group/1" do
    test "renders label when provided" do
      html =
        render_form_radio(%{
          field: build_field(nil),
          options: [{"Red", "red"}],
          label: "Pick a color"
        })

      assert html =~ "Pick a color"
    end

    test "renders radio inputs for each option" do
      html =
        render_form_radio(%{
          field: build_field(nil),
          options: [{"Red", "red"}, {"Blue", "blue"}]
        })

      assert html =~ ~s(type="radio")
      assert html =~ "Red"
      assert html =~ "Blue"
    end

    test "reflects checked state from field value" do
      html =
        render_form_radio(%{
          field: build_field("blue"),
          options: [{"Red", "red"}, {"Blue", "blue"}]
        })

      assert html =~ ~s(value="blue" checked)
    end

    test "uses field name for radio inputs" do
      html =
        render_form_radio(%{
          field: build_field(nil),
          options: [{"X", "x"}]
        })

      assert html =~ ~s(name="test[color]")
    end
  end
end
