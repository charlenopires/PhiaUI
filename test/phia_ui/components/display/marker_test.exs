defmodule PhiaUi.Components.MarkerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Marker

    def render_marker(assigns) do
      ~H"""
      <.marker
        x={assigns[:x] || "50%"}
        y={assigns[:y] || "50%"}
        label={assigns[:label]}
        variant={assigns[:variant] || :default}
        size={assigns[:size] || :md}
        pulse={assigns[:pulse] || false}
        icon={assigns[:icon]}
        on_click={assigns[:on_click]}
        class={assigns[:class]}
      />
      """
    end

    def render_marker_with_popover(assigns) do
      ~H"""
      <.marker x="25%" y="75%" label="Info">
        <:popover>Popover content</:popover>
      </.marker>
      """
    end

    def render_marker_with_content(assigns) do
      ~H"""
      <.marker x="10%" y="20%">
        <span>Custom content</span>
      </.marker>
      """
    end
  end

  defp render_marker(attrs \\ %{}), do: render_component(&H.render_marker/1, attrs)
  defp render_marker_with_popover, do: render_component(&H.render_marker_with_popover/1, %{})
  defp render_marker_with_content, do: render_component(&H.render_marker_with_content/1, %{})

  describe "marker/1" do
    test "renders with absolute positioning" do
      assert render_marker() =~ "absolute"
    end

    test "positions via inline style" do
      html = render_marker(%{x: "30%", y: "60%"})
      assert html =~ "left: 30%"
      assert html =~ "top: 60%"
    end

    test "renders as div by default (no on_click)" do
      html = render_marker()
      assert html =~ "<div"
    end

    test "renders as button when on_click provided" do
      html = render_marker(%{on_click: "select_marker"})
      assert html =~ "<button"
    end

    test "applies aria-label" do
      assert render_marker(%{label: "Room A"}) =~ "Room A"
    end

    test "variant :primary applies bg-primary" do
      assert render_marker(%{variant: :primary}) =~ "bg-primary"
    end

    test "variant :destructive applies bg-destructive" do
      assert render_marker(%{variant: :destructive}) =~ "bg-destructive"
    end

    test "size :sm applies size-4" do
      assert render_marker(%{size: :sm}) =~ "size-4"
    end

    test "size :lg applies size-8" do
      assert render_marker(%{size: :lg}) =~ "size-8"
    end

    test "pulse adds animate-ping element" do
      assert render_marker(%{pulse: true}) =~ "animate-ping"
    end

    test "no pulse by default" do
      refute render_marker() =~ "animate-ping"
    end

    test "renders popover slot" do
      html = render_marker_with_popover()
      assert html =~ "Popover content"
    end

    test "renders inner_block slot" do
      assert render_marker_with_content() =~ "Custom content"
    end

    test "custom class is applied" do
      assert render_marker(%{class: "my-marker"}) =~ "my-marker"
    end
  end
end
