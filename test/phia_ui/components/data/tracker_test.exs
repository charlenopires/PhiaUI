defmodule PhiaUi.Components.Data.TrackerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.Tracker

    def render_default(assigns) do
      ~H"""
      <.tracker data={[
        %{color: "oklch(0.70 0.18 145)", tooltip: "Operational"},
        %{color: "oklch(0.65 0.22 30)", tooltip: "Degraded"},
        %{color: "oklch(0.60 0.20 240)", tooltip: "Operational"}
      ]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.tracker data={[]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.tracker data={[%{color: "red"}]} class="h-6" />
      """
    end
  end

  describe "tracker/1" do
    test "renders tracker blocks with colors" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "oklch(0.70 0.18 145)"
      assert html =~ "oklch(0.65 0.22 30)"
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "renders tooltips on blocks" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Operational"
      assert html =~ "Degraded"
    end

    test "renders list role for accessibility" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="list")
      assert html =~ ~s(role="listitem")
    end

    test "renders empty tracker" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ ~s(role="list")
    end

    test "applies custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "h-6"
    end
  end
end
