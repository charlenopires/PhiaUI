defmodule PhiaUi.Components.TimeSliderPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimeSliderPicker

    def render_default(assigns) do
      ~H"<.time_slider_picker hour={12} minute={30} />"
    end

    def render_am(assigns) do
      ~H"<.time_slider_picker hour={9} minute={0} />"
    end

    def render_midnight(assigns) do
      ~H"<.time_slider_picker hour={0} minute={0} />"
    end

    def render_with_on_select(assigns) do
      ~H'<.time_slider_picker hour={12} minute={30} on_select="pick_time" />'
    end

    def render_with_step(assigns) do
      ~H"<.time_slider_picker hour={12} minute={30} step_minutes={60} start_hour={8} end_hour={18} />"
    end

    def render_with_class(assigns) do
      ~H'<.time_slider_picker hour={12} minute={30} class="my-slider" />'
    end

    def render_default_step(assigns) do
      ~H"<.time_slider_picker hour={12} minute={30} step_minutes={30} start_hour={0} end_hour={24} />"
    end

    def render_narrow_range(assigns) do
      ~H"<.time_slider_picker hour={10} minute={0} start_hour={9} end_hour={11} />"
    end
  end

  describe "time_slider_picker/1" do
    # 1. renders "12:30" in time display
    test "renders 12:30 in time display" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "12:30"
    end

    # 2. renders AM time 9:00
    test "renders 9:00 AM time" do
      html = render_component(&H.render_am/1, %{})
      assert html =~ "9:00"
    end

    # 3. midnight hour=0 renders "12:00" in 12-hour format
    test "midnight hour=0 renders 12:00 in 12-hour format" do
      html = render_component(&H.render_midnight/1, %{})
      assert html =~ "12:00"
    end

    # 4. selected tick has h-6 (tall)
    test "selected tick has h-6 class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-6"
    end

    # 5. selected tick has bg-primary
    test "selected tick has bg-primary class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-primary"
    end

    # 6. non-selected ticks have h-3 (short)
    test "non-selected ticks have h-3 class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-3"
    end

    # 7. non-selected ticks have bg-border
    test "non-selected ticks have bg-border class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-border"
    end

    # 8. on_select adds phx-click to ticks
    test "on_select adds phx-click to ticks" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-click="pick_time")
    end

    # 9. on_select adds phx-value-time
    test "on_select adds phx-value-time attribute" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ "phx-value-time"
    end

    # 10. phx-value-time contains "12:30"
    test "phx-value-time contains 12:30" do
      html = render_component(&H.render_with_on_select/1, %{})
      assert html =~ ~s(phx-value-time="12:30")
    end

    # 11. no phx-click when on_select not set
    test "no phx-click when on_select not set" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "phx-click"
    end

    # 12. hour label shown for full-hour ticks (minute==0)
    test "hour label shown for full-hour ticks" do
      html = render_component(&H.render_default/1, %{})
      # With default step_minutes=30 and full 0-24 range, hour marks have labels
      assert html =~ ~s(text-[9px])
    end

    # 13. custom class applied
    test "custom class is applied to container" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-slider"
    end

    # 14. text-3xl font-bold on time display
    test "time display has text-3xl font-bold classes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-3xl"
      assert html =~ "font-bold"
    end

    # 15. overflow-x-auto on ruler container
    test "ruler container has overflow-x-auto class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "overflow-x-auto"
    end

    # 16. step_minutes=60 produces fewer ticks than step_minutes=30
    test "step_minutes=60 produces fewer ticks than step_minutes=30" do
      html_60 = render_component(&H.render_with_step/1, %{})
      html_30 = render_component(&H.render_default_step/1, %{})
      # Count tick divs by counting width: 20px occurrences (one per tick)
      count_60 = html_60 |> String.split("width: 20px") |> length()
      count_30 = html_30 |> String.split("width: 20px") |> length()
      assert count_30 > count_60
    end

    # 17. start_hour and end_hour limit tick range
    test "start_hour and end_hour limit tick range" do
      html = render_component(&H.render_narrow_range/1, %{})
      html_full = render_component(&H.render_default/1, %{})
      count_narrow = html |> String.split("width: 20px") |> length()
      count_full = html_full |> String.split("width: 20px") |> length()
      assert count_full > count_narrow
    end

    # 18. tabular-nums on time display
    test "time display has tabular-nums class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "tabular-nums"
    end
  end
end
