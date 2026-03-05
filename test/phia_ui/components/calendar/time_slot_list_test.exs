defmodule PhiaUi.Components.TimeSlotListTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimeSlotList

    @slots ~w(09:00 09:30 10:00 10:30 11:00 11:30)

    def render_default(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_list slots={@slots} />"
    end

    def render_with_selected(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_list slots={@slots} selected="10:00" />]
    end

    def render_with_on_select(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_list slots={@slots} on_select="pick_time" />]
    end

    def render_with_ampm(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_list slots={@slots} show_ampm={true} ampm="AM" on_ampm_change="toggle_ampm" />]
    end

    def render_pm_active(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_list slots={@slots} show_ampm={true} ampm="PM" />]
    end

    def render_with_disabled(assigns) do
      ~H"""
      <.time_slot_list slots={[%{value: "09:00", label: "09:00", disabled: true}, "10:00"]} />
      """
    end

    def render_with_class(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H[<.time_slot_list slots={@slots} class="my-list" />]
    end

    def render_no_ampm(assigns) do
      assigns = assign(assigns, :slots, @slots)
      ~H"<.time_slot_list slots={@slots} show_ampm={false} />"
    end
  end

  describe "time_slot_list/1" do
    test "renders all slot labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "09:00"
      assert html =~ "09:30"
      assert html =~ "10:00"
      assert html =~ "10:30"
      assert html =~ "11:00"
      assert html =~ "11:30"
    end

    test "default slot has text-foreground" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-foreground"
    end

    test "selected slot has border-primary" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "border-primary"
    end

    test "selected slot has text-primary" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "text-primary"
    end

    test "selected slot has bg-primary/5" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "bg-primary/5"
    end

    test "selected slot has font-semibold" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "font-semibold"
    end

    test "non-selected slot does not have border-primary" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "border-primary"
    end

    test "on_select adds phx-click to buttons" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-click="pick_time")
    end

    test "on_select adds phx-value-slot to buttons" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-value-slot="09:00")
    end

    test "no phx-click when on_select not set" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "phx-click"
    end

    test "disabled slot has opacity-50" do
      html = render_component(&H.render_with_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "disabled slot has cursor-not-allowed" do
      html = render_component(&H.render_with_disabled/1, %{})
      assert html =~ "cursor-not-allowed"
    end

    test "disabled slot has no phx-click" do
      html = render_component(&H.render_with_disabled/1, %{})
      refute html =~ "phx-click"
    end

    test "show_ampm renders AM button" do
      html = render_component(&H.render_with_ampm/1, %{})
      assert html =~ ~s(phx-value-ampm="AM")
    end

    test "show_ampm renders PM button" do
      html = render_component(&H.render_with_ampm/1, %{})
      assert html =~ ~s(phx-value-ampm="PM")
    end

    test "AM active has bg-primary when ampm=AM" do
      html = render_component(&H.render_with_ampm/1, %{})
      assert html =~ "bg-primary"
    end

    test "PM active has bg-primary when ampm=PM" do
      html = render_component(&H.render_pm_active/1, %{})
      assert html =~ "bg-primary"
    end

    test "AM/PM buttons have phx-click when on_ampm_change set" do
      html = render_component(&H.render_with_ampm/1, %{})
      assert html =~ ~s(phx-click="toggle_ampm")
    end

    test "no AM/PM toggle when show_ampm=false" do
      html = render_component(&H.render_no_ampm/1, %{})
      refute html =~ "phx-value-ampm"
    end

    test "overflow-y-auto present on scroll container" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "overflow-y-auto"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-list"
    end
  end
end
