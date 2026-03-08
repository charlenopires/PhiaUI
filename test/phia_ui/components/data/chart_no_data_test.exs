defmodule PhiaUi.Components.Data.ChartNoDataTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.ChartNoData

    def render_default(assigns) do
      ~H"""
      <.chart_no_data />
      """
    end

    def render_custom_text(assigns) do
      ~H"""
      <.chart_no_data text="No results found" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.chart_no_data class="h-80" />
      """
    end
  end

  describe "chart_no_data/1" do
    test "renders default No data text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "No data"
    end

    test "renders dashed border" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border-dashed"
    end

    test "renders custom text" do
      html = render_component(&H.render_custom_text/1, %{})
      assert html =~ "No results found"
    end

    test "applies custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "h-80"
    end

    test "uses muted foreground for text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-muted-foreground"
    end
  end
end
