defmodule PhiaUi.Components.Layout.DividerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Divider

    def render_divider(assigns) do
      ~H"""
      <.divider
        orientation={assigns[:orientation] || "horizontal"}
        label={assigns[:label]}
        label_position={assigns[:label_position] || :center}
        class={assigns[:class]}
      />
      """
    end
  end

  defp render_divider(attrs \\ %{}) do
    render_component(&H.render_divider/1, attrs)
  end

  describe "divider/1 plain horizontal" do
    test "renders a div" do
      assert render_divider() =~ "<div"
    end

    test "applies h-px w-full bg-border" do
      html = render_divider()
      assert html =~ "h-px"
      assert html =~ "w-full"
      assert html =~ "bg-border"
    end

    test "is aria-hidden" do
      assert render_divider() =~ ~s(aria-hidden="true")
    end
  end

  describe "divider/1 vertical" do
    test "applies w-px h-full" do
      html = render_divider(%{orientation: "vertical"})
      assert html =~ "w-px"
      assert html =~ "h-full"
    end
  end

  describe "divider/1 with label" do
    test "renders label text" do
      html = render_divider(%{label: "Or"})
      assert html =~ "Or"
    end

    test "renders two line divs" do
      html = render_divider(%{label: "Or"})
      assert html =~ "flex-1 h-px bg-border"
    end

    test "label_position start gives narrow left line" do
      html = render_divider(%{label: "Filters", label_position: :start})
      assert html =~ "w-8 h-px bg-border"
    end

    test "label_position end gives narrow right line" do
      html = render_divider(%{label: "End", label_position: :end})
      assert html =~ "w-8 h-px bg-border"
    end
  end

  describe "divider/1 class forwarding" do
    test "forwards custom class" do
      assert render_divider(%{class: "my-4"}) =~ "my-4"
    end
  end
end
