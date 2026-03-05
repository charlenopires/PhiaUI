defmodule PhiaUi.Components.ProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Progress

    attr(:value, :integer, default: 0)
    attr(:max, :integer, default: 100)
    attr(:class, :string, default: nil)

    def render_progress(assigns) do
      ~H"""
      <.progress value={@value} max={@max} class={@class} />
      """
    end
  end

  defp render_progress(attrs \\ %{}) do
    render_component(&H.render_progress/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # progress/1 — role and ARIA
  # ---------------------------------------------------------------------------

  describe "progress/1 ARIA semantics" do
    test "renders role=progressbar" do
      assert render_progress() =~ ~s(role="progressbar")
    end

    test "renders aria-valuemin=0" do
      assert render_progress() =~ ~s(aria-valuemin="0")
    end

    test "renders aria-valuemax equal to :max (default 100)" do
      assert render_progress() =~ ~s(aria-valuemax="100")
    end

    test "renders aria-valuemax equal to custom :max" do
      assert render_progress(%{max: 200}) =~ ~s(aria-valuemax="200")
    end

    test "renders aria-valuenow equal to :value" do
      assert render_progress(%{value: 42}) =~ ~s(aria-valuenow="42")
    end

    test "aria-valuenow=0 when value is 0" do
      assert render_progress(%{value: 0}) =~ ~s(aria-valuenow="0")
    end

    test "aria-valuenow=100 when value is 100" do
      assert render_progress(%{value: 100}) =~ ~s(aria-valuenow="100")
    end
  end

  # ---------------------------------------------------------------------------
  # progress/1 — visual track
  # ---------------------------------------------------------------------------

  describe "progress/1 track styling" do
    test "renders bg-secondary for track (semantic token)" do
      html = render_progress()
      assert html =~ "bg-secondary"
      refute html =~ "bg-gray"
      refute html =~ "bg-[#"
    end

    test "renders rounded track" do
      assert render_progress() =~ "rounded-full"
    end

    test "track has fixed height class" do
      html = render_progress()
      assert html =~ ~r/h-\d/
    end
  end

  # ---------------------------------------------------------------------------
  # progress/1 — inner bar width
  # ---------------------------------------------------------------------------

  describe "progress/1 inner bar width" do
    test "inner bar uses bg-primary (semantic token)" do
      html = render_progress(%{value: 50})
      assert html =~ "bg-primary"
    end

    test "inner bar width is 0% when value=0" do
      html = render_progress(%{value: 0})
      assert html =~ "width: 0%"
    end

    test "inner bar width is 50% when value=50" do
      html = render_progress(%{value: 50})
      assert html =~ "width: 50%"
    end

    test "inner bar width is 100% when value=100" do
      html = render_progress(%{value: 100})
      assert html =~ "width: 100%"
    end

    test "inner bar width calculated correctly for custom max" do
      # value=1 of max=4 = 25%
      html = render_progress(%{value: 1, max: 4})
      assert html =~ "width: 25%"
    end

    test "inner bar width rounds to integer percentage" do
      # value=1 of max=3 = 33%
      html = render_progress(%{value: 1, max: 3})
      assert html =~ "width: 33%"
    end

    test "inner bar has transition for smooth animation" do
      assert render_progress(%{value: 50}) =~ "transition"
    end
  end

  # ---------------------------------------------------------------------------
  # progress/1 — class customization
  # ---------------------------------------------------------------------------

  describe "progress/1 :class customization" do
    test "applies custom class to root element" do
      assert render_progress(%{class: "h-4"}) =~ "h-4"
    end

    test "custom class does not remove bg-secondary" do
      html = render_progress(%{class: "w-full"})
      assert html =~ "bg-secondary"
    end

    test "nil class renders without issues" do
      html = render_progress(%{class: nil})
      assert html =~ ~s(role="progressbar")
    end
  end

  # ---------------------------------------------------------------------------
  # progress/1 — no hardcoded colors
  # ---------------------------------------------------------------------------

  describe "progress/1 semantic tokens only" do
    test "does not use hardcoded gray colors" do
      html = render_progress(%{value: 60})
      refute html =~ "bg-gray-"
      refute html =~ "bg-zinc-"
      refute html =~ "bg-slate-"
    end

    test "does not use arbitrary color values" do
      html = render_progress(%{value: 60})
      refute html =~ ~r/bg-\[#[0-9a-fA-F]/
    end
  end
end
