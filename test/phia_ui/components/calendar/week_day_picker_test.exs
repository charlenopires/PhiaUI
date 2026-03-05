defmodule PhiaUi.Components.WeekDayPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.WeekDayPicker

    def render_week_day_picker(assigns) do
      ~H"""
      <.week_day_picker id="wdp1" name="days" />
      """
    end

    def render_with_selected(assigns) do
      ~H"""
      <.week_day_picker id="wdp2" name="days" value={["mon", "wed"]} />
      """
    end

    def render_pt_br(assigns) do
      ~H"""
      <.week_day_picker id="wdp3" name="days" locale="pt-BR" />
      """
    end

    def render_en(assigns) do
      ~H"""
      <.week_day_picker id="wdp4" name="days" locale="en" />
      """
    end

    def render_single_mode(assigns) do
      ~H"""
      <.week_day_picker id="wdp5" name="day" mode={:single} value={["tue"]} />
      """
    end

    def render_multiple_mode(assigns) do
      ~H"""
      <.week_day_picker id="wdp6" name="days" mode={:multiple} value={["mon", "fri"]} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.week_day_picker id="wdp7" name="days" class="my-picker-class" />
      """
    end

    def render_with_disabled(assigns) do
      ~H"""
      <.week_day_picker id="wdp8" name="days" disabled_days={["sat", "sun"]} />
      """
    end

    def render_on_change(assigns) do
      ~H"""
      <.week_day_picker id="wdp9" name="days" on_change="day_selected" />
      """
    end
  end

  describe "week_day_picker/1" do
    test "renders container div" do
      html = render_component(&H.render_week_day_picker/1, %{})
      assert html =~ "<div"
    end

    test "renders 7 day buttons" do
      html = render_component(&H.render_week_day_picker/1, %{})
      # 7 buttons for days
      buttons = Regex.scan(~r/<button/, html)
      assert length(buttons) == 7
    end

    test "pt-BR locale shows Portuguese abbreviations" do
      html = render_component(&H.render_pt_br/1, %{})
      assert html =~ "Seg" or html =~ "Dom" or html =~ "Ter"
    end

    test "en locale shows English abbreviations" do
      html = render_component(&H.render_en/1, %{})
      assert html =~ "Mon" or html =~ "Sun" or html =~ "Tue"
    end

    test "selected days have active styling" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "bg-primary"
    end

    test "hidden inputs rendered for form submission" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ ~s(type="hidden")
    end

    test "input name includes days[] for multiple mode" do
      html = render_component(&H.render_multiple_mode/1, %{})
      assert html =~ "days[]"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-picker-class"
    end

    test "disabled days have disabled attribute" do
      html = render_component(&H.render_with_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "on_change wires phx-click" do
      html = render_component(&H.render_on_change/1, %{})
      assert html =~ ~s(phx-click="day_selected")
    end

    test "single mode without [] suffix in name" do
      html = render_component(&H.render_single_mode/1, %{})
      assert html =~ ~s(name="day")
    end

    test "has flex layout class" do
      html = render_component(&H.render_week_day_picker/1, %{})
      assert html =~ "flex"
    end
  end
end
