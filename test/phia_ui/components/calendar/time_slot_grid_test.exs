defmodule PhiaUi.Components.TimeSlotGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimeSlotGrid

    @slots ~w(3:00PM 3:30PM 4:00PM 4:30PM 5:00PM 5:30PM 6:00PM 6:30PM 7:00PM)

    def render_default(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_grid slots={@slots} />"
    end

    def render_with_selected(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_grid slots={@slots} selected="6:30PM" />]
    end

    def render_with_on_select(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_grid slots={@slots} on_select="pick_slot" />]
    end

    def render_disabled_grid(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_grid slots={@slots} disabled />"
    end

    def render_with_disabled_slot(assigns) do
      assigns =
        assign(assigns, :slots, [
          %{value: "3:00PM", label: "3:00PM", disabled: true},
          "3:30PM"
        ])

      ~H"<.time_slot_grid slots={@slots} />"
    end

    def render_cols_2(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_grid slots={@slots} cols={2} />"
    end

    def render_cols_4(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_grid slots={@slots} cols={4} />"
    end

    def render_with_class(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_grid slots={@slots} class="my-grid" />]
    end

    def render_map_slots(assigns) do
      assigns =
        assign(assigns, :slots, [
          %{value: "9:00AM", label: "9:00 AM"},
          %{value: "9:30AM", label: "9:30 AM"}
        ])

      ~H"<.time_slot_grid slots={@slots} />"
    end
  end

  describe "time_slot_grid/1" do
    test "renders all slot labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "3:00PM"
      assert html =~ "3:30PM"
      assert html =~ "4:00PM"
      assert html =~ "4:30PM"
      assert html =~ "5:00PM"
      assert html =~ "5:30PM"
      assert html =~ "6:00PM"
      assert html =~ "6:30PM"
      assert html =~ "7:00PM"
    end

    test "renders grid-cols-3 by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "grid-cols-3"
    end

    test "renders a grid wrapper div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
      assert html =~ "grid"
    end

    test "selected slot has border-primary" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "border-primary"
    end

    test "selected slot has text-primary" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "text-primary"
    end

    test "selected slot has font-semibold" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "font-semibold"
    end

    test "non-selected slots do not have border-primary when one is selected" do
      html = render_component(&H.render_with_selected/1, %{})
      # Count occurrences — only the selected button should have border-primary.
      # We check that the overall html has border-primary exactly once.
      occurrences = html |> String.split("border-primary") |> length() |> Kernel.-(1)
      assert occurrences == 1
    end

    test "on_select adds phx-click to buttons" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-click="pick_slot")
    end

    test "on_select adds phx-value-slot to buttons" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-value-slot="3:00PM")
    end

    test "no phx-click when on_select not set" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "phx-click"
    end

    test "disabled grid has opacity-50 on buttons" do
      html = render_component(&H.render_disabled_grid/1, %{})
      assert html =~ "opacity-50"
    end

    test "disabled grid has cursor-not-allowed on buttons" do
      html = render_component(&H.render_disabled_grid/1, %{})
      assert html =~ "cursor-not-allowed"
    end

    test "disabled grid has no phx-click on slots" do
      html = render_component(&H.render_disabled_grid/1, %{})
      refute html =~ "phx-click"
    end

    test "individual disabled slot has opacity-50" do
      html = render_component(&H.render_with_disabled_slot/1, %{})
      assert html =~ "opacity-50"
    end

    test "cols=2 renders grid-cols-2" do
      html = render_component(&H.render_cols_2/1, %{})
      assert html =~ "grid-cols-2"
    end

    test "cols=4 renders grid-cols-4" do
      html = render_component(&H.render_cols_4/1, %{})
      assert html =~ "grid-cols-4"
    end

    test "custom class is applied to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-grid"
    end

    test "renders 9 slot buttons" do
      html = render_component(&H.render_default/1, %{})
      button_count = html |> String.split("<button") |> length() |> Kernel.-(1)
      assert button_count == 9
    end

    test "slot as map %{value:, label:} renders label correctly" do
      html = render_component(&H.render_map_slots/1, %{})
      assert html =~ "9:00 AM"
      assert html =~ "9:30 AM"
    end

    test "selected slot has border-2" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "border-2"
    end
  end
end
