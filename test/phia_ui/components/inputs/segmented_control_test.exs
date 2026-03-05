defmodule PhiaUi.Components.SegmentedControlTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SegmentedControl

    def render_default(assigns) do
      ~H"""
      <.segmented_control
        id="view-mode"
        name="view"
        value="list"
        on_change="change_view"
        segments={[
          %{value: "list", label: "List"},
          %{value: "grid", label: "Grid"},
          %{value: "kanban", label: "Kanban"}
        ]}
      />
      """
    end

    def render_size_sm(assigns) do
      ~H"""
      <.segmented_control
        id="size-sm"
        name="size"
        value="list"
        size={:sm}
        segments={[%{value: "list", label: "List"}, %{value: "grid", label: "Grid"}]}
      />
      """
    end

    def render_size_lg(assigns) do
      ~H"""
      <.segmented_control
        id="size-lg"
        name="size"
        value="list"
        size={:lg}
        segments={[%{value: "list", label: "List"}, %{value: "grid", label: "Grid"}]}
      />
      """
    end

    def render_size_default(assigns) do
      ~H"""
      <.segmented_control
        id="size-default"
        name="size"
        value="list"
        size={:default}
        segments={[%{value: "list", label: "List"}, %{value: "grid", label: "Grid"}]}
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.segmented_control
        id="custom-class"
        name="mode"
        value="a"
        class="my-custom-class"
        segments={[%{value: "a", label: "A"}, %{value: "b", label: "B"}]}
      />
      """
    end

    def render_no_on_change(assigns) do
      ~H"""
      <.segmented_control
        id="no-event"
        name="tab"
        value="one"
        segments={[%{value: "one", label: "One"}, %{value: "two", label: "Two"}]}
      />
      """
    end

    def render_with_disabled(assigns) do
      ~H"""
      <.segmented_control
        id="with-disabled"
        name="tab"
        value="one"
        segments={[
          %{value: "one", label: "One"},
          %{value: "two", label: "Two", disabled: true}
        ]}
      />
      """
    end
  end

  defp render_default(attrs \\ %{}) do
    render_component(&H.render_default/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — container structure
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 container" do
    test "renders role=group on container" do
      assert render_default() =~ ~s(role="group")
    end

    test "renders inline-flex class on container" do
      assert render_default() =~ "inline-flex"
    end

    test "renders bg-muted class on container" do
      assert render_default() =~ "bg-muted"
    end

    test "renders rounded-lg class on container" do
      assert render_default() =~ "rounded-lg"
    end

    test "renders p-1 class on container" do
      assert render_default() =~ "p-1"
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — segments rendering
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 segments rendering" do
    test "renders all segment labels" do
      html = render_default()
      assert html =~ "List"
      assert html =~ "Grid"
      assert html =~ "Kanban"
    end

    test "renders radio inputs (type=radio)" do
      assert render_default() =~ ~s(type="radio")
    end

    test "radio inputs have sr-only class" do
      assert render_default() =~ "sr-only"
    end

    test "renders name attribute on radio inputs" do
      assert render_default() =~ ~s(name="view")
    end

    test "renders id-based ids on inputs using parent-id and segment value" do
      html = render_default()
      assert html =~ ~s(id="view-mode-list")
      assert html =~ ~s(id="view-mode-grid")
      assert html =~ ~s(id="view-mode-kanban")
    end

    test "label for= points to input id" do
      html = render_default()
      assert html =~ ~s(for="view-mode-list")
    end

    test "segment count matches segments list length" do
      html = render_default()
      # Count occurrences of type="radio" — should be 3 for 3 segments
      count =
        html
        |> String.split(~s(type="radio"))
        |> length()
        |> Kernel.-(1)

      assert count == 3
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — active / inactive state
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 active/inactive state" do
    test "selected segment label has bg-background class" do
      html = render_default()
      assert html =~ "bg-background"
    end

    test "selected segment label has shadow-sm class" do
      html = render_default()
      assert html =~ "shadow-sm"
    end

    test "unselected segments have text-muted-foreground class" do
      html = render_default()
      assert html =~ "text-muted-foreground"
    end

    test "radio input is checked for the active value" do
      html = render_default()
      # The checked attribute should appear on the input for value="list"
      assert html =~ ~s(value="list")
      assert html =~ "checked"
    end

    test "other radio inputs are not checked" do
      html = render_default()
      # Only 1 checked attribute should exist (for "list")
      # Count checked= occurrences
      count =
        html
        |> String.split("checked")
        |> length()
        |> Kernel.-(1)

      assert count == 1
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — on_change event
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 on_change" do
    test "renders phx-click on labels when on_change is set" do
      assert render_default() =~ ~s(phx-click="change_view")
    end

    test "renders phx-value-value on labels with segment value" do
      html = render_default()
      assert html =~ ~s(phx-value-value="list")
      assert html =~ ~s(phx-value-value="grid")
    end

    test "does not render phx-click when on_change is nil" do
      html = render_component(&H.render_no_on_change/1, %{})
      refute html =~ "phx-click"
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — size variants
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 size :sm" do
    test "applies text-xs class to labels" do
      html = render_component(&H.render_size_sm/1, %{})
      assert html =~ "text-xs"
    end

    test "applies px-2 class to labels" do
      html = render_component(&H.render_size_sm/1, %{})
      assert html =~ "px-2"
    end
  end

  describe "segmented_control/1 size :lg" do
    test "applies text-base class to labels" do
      html = render_component(&H.render_size_lg/1, %{})
      assert html =~ "text-base"
    end

    test "applies px-4 class to labels" do
      html = render_component(&H.render_size_lg/1, %{})
      assert html =~ "px-4"
    end
  end

  describe "segmented_control/1 size :default" do
    test "applies text-sm class to labels" do
      html = render_component(&H.render_size_default/1, %{})
      assert html =~ "text-sm"
    end

    test "applies px-3 class to labels" do
      html = render_component(&H.render_size_default/1, %{})
      assert html =~ "px-3"
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_control/1 — class override and disabled
  # ---------------------------------------------------------------------------

  describe "segmented_control/1 class and disabled" do
    test "custom class is applied to container" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-custom-class"
    end

    test "disabled segment input has disabled attribute" do
      html = render_component(&H.render_with_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "disabled segment label has opacity-50 class" do
      html = render_component(&H.render_with_disabled/1, %{})
      assert html =~ "opacity-50"
    end
  end
end
