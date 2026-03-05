defmodule PhiaUi.Components.ToggleGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ToggleGroup

    attr(:type, :string, default: "single")
    attr(:value, :any, default: nil)
    attr(:variant, :string, default: "default")
    attr(:size, :string, default: "default")
    attr(:class, :string, default: nil)

    def render_toggle_group(assigns) do
      ~H"""
      <.toggle_group :let={group} type={@type} value={@value} variant={@variant} size={@size} class={@class}>
        <.toggle_group_item value="left" {group}>Left</.toggle_group_item>
        <.toggle_group_item value="center" {group}>Center</.toggle_group_item>
        <.toggle_group_item value="right" {group}>Right</.toggle_group_item>
      </.toggle_group>
      """
    end

    attr(:value, :string, required: true)
    attr(:group_value, :any, default: nil)
    attr(:group_type, :string, default: "single")
    attr(:disabled, :boolean, default: false)
    attr(:class, :string, default: nil)

    def render_item(assigns) do
      ~H"""
      <.toggle_group_item
        value={@value}
        group_value={@group_value}
        group_type={@group_type}
        disabled={@disabled}
        class={@class}
      >
        {@value}
      </.toggle_group_item>
      """
    end
  end

  defp render_group(attrs \\ %{}) do
    render_component(&H.render_toggle_group/1, attrs)
  end

  defp render_item(attrs) do
    render_component(&H.render_item/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # toggle_group/1 — container
  # ---------------------------------------------------------------------------

  describe "toggle_group/1 container" do
    test "renders role=group" do
      assert render_group() =~ ~s(role="group")
    end

    test "renders all items" do
      html = render_group()
      assert html =~ "Left"
      assert html =~ "Center"
      assert html =~ "Right"
    end

    test "applies custom class to container" do
      assert render_group(%{class: "gap-2"}) =~ "gap-2"
    end

    test "renders flex container" do
      assert render_group() =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # toggle_group/1 — single mode
  # ---------------------------------------------------------------------------

  describe "toggle_group/1 single mode" do
    test "item matching value is pressed" do
      html = render_group(%{type: "single", value: "center"})
      # The center item should have aria-pressed=true
      assert html =~ ~s(aria-pressed="true")
    end

    test "non-matching items are not pressed" do
      html = render_group(%{type: "single", value: "center"})
      # Two items should be unpressed (left and right)
      count = html |> String.split(~s(aria-pressed="false")) |> length() |> Kernel.-(1)
      assert count == 2
    end

    test "no item pressed when value is nil" do
      html = render_group(%{type: "single", value: nil})
      refute html =~ ~s(aria-pressed="true")
    end
  end

  # ---------------------------------------------------------------------------
  # toggle_group/1 — multiple mode
  # ---------------------------------------------------------------------------

  describe "toggle_group/1 multiple mode" do
    test "items in value list are pressed" do
      html = render_group(%{type: "multiple", value: ["left", "right"]})
      count = html |> String.split(~s(aria-pressed="true")) |> length() |> Kernel.-(1)
      assert count == 2
    end

    test "item not in value list is not pressed" do
      html = render_group(%{type: "multiple", value: ["left"]})
      # center and right should be unpressed
      count = html |> String.split(~s(aria-pressed="false")) |> length() |> Kernel.-(1)
      assert count == 2
    end

    test "empty list means no items pressed" do
      html = render_group(%{type: "multiple", value: []})
      refute html =~ ~s(aria-pressed="true")
    end
  end

  # ---------------------------------------------------------------------------
  # toggle_group_item/1
  # ---------------------------------------------------------------------------

  describe "toggle_group_item/1 pressed state" do
    test "pressed=true when item value matches single group value" do
      html = render_item(%{value: "bold", group_value: "bold", group_type: "single"})
      assert html =~ ~s(aria-pressed="true")
    end

    test "pressed=false when item value does not match single group value" do
      html = render_item(%{value: "bold", group_value: "italic", group_type: "single"})
      assert html =~ ~s(aria-pressed="false")
    end

    test "pressed=true when item value in multiple group list" do
      html =
        render_item(%{value: "bold", group_value: ["bold", "italic"], group_type: "multiple"})

      assert html =~ ~s(aria-pressed="true")
    end

    test "pressed=false when item value not in multiple group list" do
      html = render_item(%{value: "strike", group_value: ["bold"], group_type: "multiple"})
      assert html =~ ~s(aria-pressed="false")
    end
  end

  describe "toggle_group_item/1 disabled" do
    test "disabled item renders disabled attr" do
      html = render_item(%{value: "x", group_value: nil, disabled: true})
      assert html =~ "disabled"
    end

    test "disabled item renders opacity class" do
      html = render_item(%{value: "x", group_value: nil, disabled: true})
      assert html =~ "opacity-50"
    end
  end

  describe "toggle_group_item/1 class" do
    test "applies custom class to item" do
      html = render_item(%{value: "x", group_value: nil, class: "custom-class"})
      assert html =~ "custom-class"
    end
  end
end
