defmodule PhiaUi.Components.CircularProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CircularProgress

    def render_default(assigns) do
      ~H"""
      <.circular_progress value={50} />
      """
    end

    def render_zero(assigns) do
      ~H"""
      <.circular_progress value={0} />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.circular_progress value={100} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.circular_progress value={50} size="sm" />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.circular_progress value={50} size="lg" />
      """
    end

    def render_xl(assigns) do
      ~H"""
      <.circular_progress value={50} size="xl" />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.circular_progress value={75} color="stroke-green-500" />
      """
    end

    def render_thickness(assigns) do
      ~H"""
      <.circular_progress value={50} thickness={12} />
      """
    end

    def render_no_label(assigns) do
      ~H"""
      <.circular_progress value={50} show_label={false} />
      """
    end

    def render_with_label_slot(assigns) do
      ~H"""
      <.circular_progress value={75}>
        <:label>Done</:label>
      </.circular_progress>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.circular_progress value={50} class="my-class" />
      """
    end
  end

  describe "circular_progress/1" do
    test "renders SVG element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "has role=progressbar" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="progressbar")
    end

    test "aria-valuenow reflects value" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-valuenow="50")
    end

    test "aria-valuemin is 0" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-valuemin="0")
    end

    test "aria-valuemax is 100" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-valuemax="100")
    end

    test "renders circle elements" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders stroke-dasharray" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-dasharray"
    end

    test "renders stroke-dashoffset" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-dashoffset"
    end

    test "value=0 has full dashoffset (no progress)" do
      html = render_component(&H.render_zero/1, %{})
      assert html =~ ~s(stroke-dashoffset="263.89")
    end

    test "value=100 has zero dashoffset (full progress)" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ ~s(stroke-dashoffset="0.0")
    end

    test "shows percentage label by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "50%"
    end

    test "show_label=false hides percentage label" do
      html = render_component(&H.render_no_label/1, %{})
      refute html =~ "50%"
    end

    test "size sm has h-16 w-16 class" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-16"
      assert html =~ "w-16"
    end

    test "default size has h-24 w-24 class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-24"
      assert html =~ "w-24"
    end

    test "size lg has h-32 w-32 class" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-32"
      assert html =~ "w-32"
    end

    test "size xl has h-40 w-40 class" do
      html = render_component(&H.render_xl/1, %{})
      assert html =~ "h-40"
      assert html =~ "w-40"
    end

    test "custom color class applied to arc" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "stroke-green-500"
    end

    test "default color is stroke-primary" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-primary"
    end

    test "track circle has stroke-muted class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-muted"
    end

    test "thickness sets stroke-width attribute" do
      html = render_component(&H.render_thickness/1, %{})
      assert html =~ ~s(stroke-width="12")
    end

    test "default thickness stroke-width is 8" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(stroke-width="8")
    end

    test "label slot overrides percentage text" do
      html = render_component(&H.render_with_label_slot/1, %{})
      assert html =~ "Done"
      refute html =~ "75%"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-class"
    end

    test "SVG has -rotate-90 to start arc at top" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "-rotate-90"
    end

    test "arc has stroke-linecap=round" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(stroke-linecap="round")
    end
  end
end
