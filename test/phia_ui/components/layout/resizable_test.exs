defmodule PhiaUi.Components.ResizableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Resizable

    attr(:direction, :string, default: "horizontal")
    attr(:class, :string, default: nil)

    def render_resizable(assigns) do
      ~H"""
      <.resizable direction={@direction} class={@class}>
        <.resizable_panel default_size={50}>Left</.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={50}>Right</.resizable_panel>
      </.resizable>
      """
    end

    attr(:default_size, :integer, default: 50)
    attr(:min_size, :integer, default: 10)
    attr(:max_size, :integer, default: 90)
    attr(:class, :string, default: nil)

    def render_panel(assigns) do
      ~H"""
      <.resizable_panel
        default_size={@default_size}
        min_size={@min_size}
        max_size={@max_size}
        class={@class}
      >
        Content
      </.resizable_panel>
      """
    end

    attr(:class, :string, default: nil)

    def render_handle(assigns) do
      ~H"""
      <.resizable_handle class={@class} />
      """
    end
  end

  defp render_resizable(attrs \\ %{}), do: render_component(&H.render_resizable/1, attrs)
  defp render_panel(attrs \\ %{}), do: render_component(&H.render_panel/1, attrs)
  defp render_handle(attrs \\ %{}), do: render_component(&H.render_handle/1, attrs)

  # ---------------------------------------------------------------------------
  # resizable/1 — container
  # ---------------------------------------------------------------------------

  describe "resizable/1 — horizontal (default)" do
    test "renders flex class for horizontal direction" do
      html = render_resizable()
      assert html =~ "flex"
      refute html =~ "flex-col"
    end

    test "renders h-full and w-full for horizontal" do
      html = render_resizable()
      assert html =~ "h-full"
      assert html =~ "w-full"
    end

    test "renders phx-hook=\"PhiaResizable\" attribute" do
      assert render_resizable() =~ ~s(phx-hook="PhiaResizable")
    end

    test "renders data-direction=\"horizontal\" by default" do
      assert render_resizable() =~ ~s(data-direction="horizontal")
    end

    test "renders inner slot content (panels)" do
      html = render_resizable()
      assert html =~ "Left"
      assert html =~ "Right"
    end
  end

  describe "resizable/1 — vertical direction" do
    test "renders flex-col for vertical direction" do
      html = render_resizable(%{direction: "vertical"})
      assert html =~ "flex-col"
    end

    test "renders data-direction=\"vertical\"" do
      assert render_resizable(%{direction: "vertical"}) =~ ~s(data-direction="vertical")
    end

    test "vertical does not render without flex-col base class" do
      html = render_resizable(%{direction: "vertical"})
      assert html =~ "flex"
    end
  end

  describe "resizable/1 — :class merge" do
    test "custom class is applied to the container" do
      assert render_resizable(%{class: "custom-container"}) =~ "custom-container"
    end

    test "base classes are preserved alongside custom class" do
      html = render_resizable(%{class: "custom-container"})
      assert html =~ "flex"
      assert html =~ "custom-container"
    end
  end

  # ---------------------------------------------------------------------------
  # resizable_panel/1
  # ---------------------------------------------------------------------------

  describe "resizable_panel/1 — structure" do
    test "renders overflow-hidden" do
      assert render_panel() =~ "overflow-hidden"
    end

    test "renders data-panel attribute" do
      assert render_panel() =~ "data-panel"
    end

    test "renders data-default-size with given value" do
      assert render_panel(%{default_size: 30}) =~ ~s(data-default-size="30")
    end

    test "renders default data-default-size of 50" do
      assert render_panel() =~ ~s(data-default-size="50")
    end

    test "renders data-min-size with given value" do
      assert render_panel(%{min_size: 20}) =~ ~s(data-min-size="20")
    end

    test "renders default data-min-size of 10" do
      assert render_panel() =~ ~s(data-min-size="10")
    end

    test "renders data-max-size with given value" do
      assert render_panel(%{max_size: 80}) =~ ~s(data-max-size="80")
    end

    test "renders default data-max-size of 90" do
      assert render_panel() =~ ~s(data-max-size="90")
    end

    test "renders inline flex style for initial size" do
      assert render_panel(%{default_size: 40}) =~ "flex: 40 1 0%"
    end

    test "renders inner slot content" do
      assert render_panel() =~ "Content"
    end
  end

  describe "resizable_panel/1 — :class merge" do
    test "custom class is applied to the panel" do
      assert render_panel(%{class: "panel-custom"}) =~ "panel-custom"
    end

    test "overflow-hidden is preserved alongside custom class" do
      html = render_panel(%{class: "panel-custom"})
      assert html =~ "overflow-hidden"
      assert html =~ "panel-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # resizable_handle/1
  # ---------------------------------------------------------------------------

  describe "resizable_handle/1 — structure" do
    test "renders role=\"separator\"" do
      assert render_handle() =~ ~s(role="separator")
    end

    test "renders aria-orientation attribute" do
      assert render_handle() =~ "aria-orientation"
    end

    test "renders tabindex=\"0\" for keyboard accessibility" do
      assert render_handle() =~ ~s(tabindex="0")
    end

    test "renders cursor-col-resize for drag cursor" do
      assert render_handle() =~ "cursor-col-resize"
    end

    test "renders aria-valuenow=\"50\" at default midpoint" do
      assert render_handle() =~ ~s(aria-valuenow="50")
    end

    test "renders aria-valuemin=\"0\"" do
      assert render_handle() =~ ~s(aria-valuemin="0")
    end

    test "renders aria-valuemax=\"100\"" do
      assert render_handle() =~ ~s(aria-valuemax="100")
    end

    test "renders data-panel-handle marker" do
      assert render_handle() =~ "data-panel-handle"
    end

    test "renders bg-border for semantic handle color" do
      assert render_handle() =~ "bg-border"
    end

    test "renders select-none to prevent text selection during drag" do
      assert render_handle() =~ "select-none"
    end

    test "renders focus-visible ring for keyboard focus" do
      html = render_handle()
      assert html =~ "focus-visible:ring-1"
      assert html =~ "focus-visible:ring-ring"
    end
  end

  describe "resizable_handle/1 — :class merge" do
    test "custom class is applied to the handle" do
      assert render_handle(%{class: "handle-custom"}) =~ "handle-custom"
    end

    test "base handle classes are preserved alongside custom class" do
      html = render_handle(%{class: "handle-custom"})
      assert html =~ "bg-border"
      assert html =~ "handle-custom"
    end
  end
end
