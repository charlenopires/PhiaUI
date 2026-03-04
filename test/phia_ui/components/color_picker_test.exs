defmodule PhiaUi.Components.ColorPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ColorPicker

    def render_default(assigns) do
      ~H"""
      <.color_picker id="theme-color" value="#000000" on_change="update_color" />
      """
    end

    def render_with_swatches(assigns) do
      ~H"""
      <.color_picker
        id="brand-color"
        value="#FF5733"
        format={:hex}
        swatches={["#FF5733", "#4CAF50", "#2196F3"]}
        on_change="pick_color"
      />
      """
    end

    def render_without_swatches(assigns) do
      ~H"""
      <.color_picker id="no-swatches" value="#123456" on_change="set_color" swatches={[]} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.color_picker id="styled-picker" value="#FFFFFF" on_change="change" class="my-custom-class" />
      """
    end

    def render_with_rgb_format(assigns) do
      ~H"""
      <.color_picker id="rgb-picker" value="#AABBCC" format={:rgb} on_change="change_rgb" />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_with_swatches, do: render_component(&H.render_with_swatches/1, %{})
  defp render_without_swatches, do: render_component(&H.render_without_swatches/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_with_rgb_format, do: render_component(&H.render_with_rgb_format/1, %{})

  # ---------------------------------------------------------------------------
  # color_picker/1
  # ---------------------------------------------------------------------------

  describe "color_picker/1" do
    test "renders container div with id" do
      assert render_default() =~ ~s(id="theme-color")
    end

    test "container has phx-hook=PhiaColorPicker" do
      assert render_default() =~ ~s(phx-hook="PhiaColorPicker")
    end

    test "container has data-on-change attribute" do
      assert render_default() =~ ~s(data-on-change="update_color")
    end

    test "renders color input of type color" do
      assert render_default() =~ ~s(type="color")
    end

    test "color input has data-color-input attr" do
      assert render_default() =~ "data-color-input"
    end

    test "color input has initial value" do
      assert render_default() =~ ~s(value="#000000")
    end

    test "color input has correct id format (id + -input)" do
      assert render_default() =~ ~s(id="theme-color-input")
    end

    test "color input has border-border class" do
      assert render_default() =~ "border-border"
    end

    test "renders value display span" do
      assert render_default() =~ "<span"
    end

    test "value display has data-color-value attr" do
      assert render_default() =~ "data-color-value"
    end

    test "value display shows current color value" do
      assert render_default() =~ "#000000"
    end

    test "no swatches div when swatches list is empty" do
      refute render_without_swatches() =~ "data-swatches"
    end

    test "renders swatches div when swatches provided" do
      assert render_with_swatches() =~ "data-swatches"
    end

    test "swatches div has data-swatches attr" do
      assert render_with_swatches() =~ ~s(data-swatches)
    end

    test "renders correct number of swatch buttons" do
      html = render_with_swatches()
      # 3 swatches => 3 swatch buttons
      assert html |> String.split("data-swatch-value") |> length() == 4
    end

    test "swatch button has data-swatch-value attr" do
      assert render_with_swatches() =~ ~s(data-swatch-value="#FF5733")
    end

    test "swatch button has style with background-color" do
      assert render_with_swatches() =~ "background-color: #FF5733"
    end

    test "swatch button has aria-label" do
      assert render_with_swatches() =~ ~s(aria-label="Select color #FF5733")
    end

    test "applies custom class" do
      assert render_with_class() =~ "my-custom-class"
    end

    test "renders inline-flex class on container" do
      assert render_default() =~ "inline-flex"
    end
  end
end
