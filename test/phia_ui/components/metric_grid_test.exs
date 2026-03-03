defmodule PhiaUi.Components.MetricGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MetricGrid
    import PhiaUi.Components.StatCard

    attr :cols, :integer, default: 4
    attr :class, :string, default: nil

    def render_grid(assigns) do
      ~H"""
      <.metric_grid cols={@cols} class={@class}>
        <.stat_card title="Revenue" value="$1,000" />
        <.stat_card title="Users" value="500" />
      </.metric_grid>
      """
    end

    def render_grid_default(assigns) do
      ~H"""
      <.metric_grid>
        <.stat_card title="MRR" value="$9,999" />
      </.metric_grid>
      """
    end

  end

  defp render_grid(attrs \\ %{}) do
    render_component(&H.render_grid/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # :cols attr
  # ---------------------------------------------------------------------------

  describe "metric_grid/1 :cols attr" do
    test "default :cols is 4 — renders lg:grid-cols-4" do
      html = render_component(&H.render_grid_default/1, %{})
      assert html =~ "lg:grid-cols-4"
    end

    test ":cols 1 renders grid-cols-1 only" do
      html = render_grid(%{cols: 1})
      assert html =~ "grid-cols-1"
      refute html =~ "sm:grid-cols"
      refute html =~ "lg:grid-cols"
    end

    test ":cols 2 renders grid-cols-1 sm:grid-cols-2" do
      html = render_grid(%{cols: 2})
      assert html =~ "grid-cols-1"
      assert html =~ "sm:grid-cols-2"
      refute html =~ "lg:grid-cols"
    end

    test ":cols 3 renders grid-cols-1 sm:grid-cols-2 lg:grid-cols-3" do
      html = render_grid(%{cols: 3})
      assert html =~ "grid-cols-1"
      assert html =~ "sm:grid-cols-2"
      assert html =~ "lg:grid-cols-3"
    end

    test ":cols 4 renders grid-cols-1 sm:grid-cols-2 lg:grid-cols-4" do
      html = render_grid(%{cols: 4})
      assert html =~ "grid-cols-1"
      assert html =~ "sm:grid-cols-2"
      assert html =~ "lg:grid-cols-4"
    end
  end

  # ---------------------------------------------------------------------------
  # All 4 :cols values render without error
  # ---------------------------------------------------------------------------

  describe "all 4 :cols values render correctly" do
    for c <- [1, 2, 3, 4] do
      @c c
      test "cols=#{c} renders a div wrapper with stat_card child" do
        html = render_grid(%{cols: @c})
        assert html =~ "<div"
        assert html =~ "Revenue"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # gap-4
  # ---------------------------------------------------------------------------

  describe "metric_grid/1 gap" do
    test "has gap-4 between cards" do
      html = render_grid()
      assert html =~ "gap-4"
    end
  end

  # ---------------------------------------------------------------------------
  # inner_block slot
  # ---------------------------------------------------------------------------

  describe "metric_grid/1 inner_block slot" do
    test "renders stat_card children" do
      html = render_grid()
      assert html =~ "Revenue"
      assert html =~ "Users"
      assert html =~ "$1,000"
    end

    test "renders multiple children" do
      html = render_grid()
      assert html =~ "500"
    end
  end

  # ---------------------------------------------------------------------------
  # grid wrapper
  # ---------------------------------------------------------------------------

  describe "metric_grid/1 wrapper" do
    test "renders a div element" do
      html = render_grid()
      assert html =~ "<div"
    end

    test "has grid class" do
      html = render_grid()
      assert html =~ "grid"
    end

    test "accepts custom class" do
      html = render_grid(%{class: "my-dashboard"})
      assert html =~ "my-dashboard"
    end
  end
end
