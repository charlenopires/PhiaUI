defmodule PhiaUiDesign.Canvas.LayoutTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Layout

  # ---------------------------------------------------------------------------
  # Layout direction
  # ---------------------------------------------------------------------------

  describe "layout direction" do
    test "vertical layout" do
      assert Layout.to_classes(%{layout: :vertical}) =~ "flex flex-col"
    end

    test "horizontal layout" do
      assert Layout.to_classes(%{layout: :horizontal}) =~ "flex flex-row"
    end

    test "nil layout returns empty" do
      assert Layout.to_classes(%{layout: nil}) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Gap
  # ---------------------------------------------------------------------------

  describe "gap" do
    test "standard Tailwind gap" do
      assert Layout.to_classes(%{gap: 16}) == "gap-4"
    end

    test "zero gap" do
      assert Layout.to_classes(%{gap: 0}) == "gap-0"
    end

    test "non-standard gap uses arbitrary value" do
      assert Layout.to_classes(%{gap: 13}) == "gap-[13px]"
    end

    test "nil gap returns empty" do
      assert Layout.to_classes(%{gap: nil}) == ""
    end

    test "variable ref gap is ignored" do
      assert Layout.to_classes(%{gap: "$spacing"}) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Padding
  # ---------------------------------------------------------------------------

  describe "padding" do
    test "uniform padding" do
      assert Layout.to_classes(%{padding: 24}) == "p-6"
    end

    test "per-side padding" do
      result = Layout.to_classes(%{padding: [8, 16, 8, 16]})
      assert result =~ "pt-2"
      assert result =~ "pr-4"
      assert result =~ "pb-2"
      assert result =~ "pl-4"
    end

    test "uniform per-side padding collapses to shorthand" do
      assert Layout.to_classes(%{padding: [16, 16, 16, 16]}) == "p-4"
    end

    test "non-standard padding uses arbitrary value" do
      assert Layout.to_classes(%{padding: 13}) == "p-[13px]"
    end

    test "nil padding returns empty" do
      assert Layout.to_classes(%{padding: nil}) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Justify content
  # ---------------------------------------------------------------------------

  describe "justify_content" do
    test "start" do
      assert Layout.to_classes(%{justify_content: :start}) == "justify-start"
    end

    test "center" do
      assert Layout.to_classes(%{justify_content: :center}) == "justify-center"
    end

    test "end" do
      assert Layout.to_classes(%{justify_content: :end}) == "justify-end"
    end

    test "between" do
      assert Layout.to_classes(%{justify_content: :between}) == "justify-between"
    end

    test "around" do
      assert Layout.to_classes(%{justify_content: :around}) == "justify-around"
    end
  end

  # ---------------------------------------------------------------------------
  # Align items
  # ---------------------------------------------------------------------------

  describe "align_items" do
    test "start" do
      assert Layout.to_classes(%{align_items: :start}) == "items-start"
    end

    test "center" do
      assert Layout.to_classes(%{align_items: :center}) == "items-center"
    end

    test "end" do
      assert Layout.to_classes(%{align_items: :end}) == "items-end"
    end

    test "stretch" do
      assert Layout.to_classes(%{align_items: :stretch}) == "items-stretch"
    end
  end

  # ---------------------------------------------------------------------------
  # Wrap
  # ---------------------------------------------------------------------------

  describe "wrap" do
    test "true adds flex-wrap" do
      assert Layout.to_classes(%{wrap: true}) == "flex-wrap"
    end

    test "false returns empty" do
      assert Layout.to_classes(%{wrap: false}) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Width
  # ---------------------------------------------------------------------------

  describe "width" do
    test "fill" do
      assert Layout.to_classes(%{width: :fill}) == "w-full"
    end

    test "hug" do
      assert Layout.to_classes(%{width: :hug}) == "w-fit"
    end

    test "pixel value" do
      assert Layout.to_classes(%{width: 320}) == "w-[320px]"
    end

    test "percentage" do
      assert Layout.to_classes(%{width: "50%"}) == "w-[50%]"
    end
  end

  # ---------------------------------------------------------------------------
  # Height
  # ---------------------------------------------------------------------------

  describe "height" do
    test "fill" do
      assert Layout.to_classes(%{height: :fill}) == "h-full"
    end

    test "hug" do
      assert Layout.to_classes(%{height: :hug}) == "h-fit"
    end

    test "pixel value" do
      assert Layout.to_classes(%{height: 200}) == "h-[200px]"
    end
  end

  # ---------------------------------------------------------------------------
  # Combined
  # ---------------------------------------------------------------------------

  describe "combined properties" do
    test "vertical layout with gap and padding" do
      result = Layout.to_classes(%{layout: :vertical, gap: 16, padding: 24})
      assert result =~ "flex flex-col"
      assert result =~ "gap-4"
      assert result =~ "p-6"
    end

    test "horizontal layout with justify and align" do
      result = Layout.to_classes(%{layout: :horizontal, justify_content: :between, align_items: :center})
      assert result =~ "flex flex-row"
      assert result =~ "justify-between"
      assert result =~ "items-center"
    end

    test "full layout specification" do
      result = Layout.to_classes(%{
        layout: :vertical,
        gap: 16,
        padding: 24,
        justify_content: :center,
        align_items: :stretch,
        wrap: true,
        width: :fill,
        height: :hug
      })

      assert result =~ "flex flex-col"
      assert result =~ "gap-4"
      assert result =~ "p-6"
      assert result =~ "justify-center"
      assert result =~ "items-stretch"
      assert result =~ "flex-wrap"
      assert result =~ "w-full"
      assert result =~ "h-fit"
    end

    test "empty map returns empty string" do
      assert Layout.to_classes(%{}) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # has_layout?
  # ---------------------------------------------------------------------------

  describe "has_layout?/1" do
    test "returns true when layout properties are set" do
      assert Layout.has_layout?(%{layout: :vertical})
      assert Layout.has_layout?(%{gap: 16})
      assert Layout.has_layout?(%{width: :fill})
    end

    test "returns false when no layout properties" do
      refute Layout.has_layout?(%{})
      refute Layout.has_layout?(%{layout: nil, gap: nil, wrap: false})
    end
  end
end
