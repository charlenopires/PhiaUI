defmodule PhiaUi.Components.NpsWidgetTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NpsWidget

    def render_high_score(assigns) do
      ~H"""
      <.nps_widget score={80} promoters={400} passives={80} detractors={20} total_responses={500} />
      """
    end

    def render_mid_score(assigns) do
      ~H"""
      <.nps_widget score={60} promoters={300} passives={100} detractors={100} total_responses={500} />
      """
    end

    def render_low_score(assigns) do
      ~H"""
      <.nps_widget score={30} promoters={100} passives={150} detractors={250} total_responses={500} />
      """
    end

    def render_zero_responses(assigns) do
      ~H"""
      <.nps_widget score={50} promoters={0} passives={0} detractors={0} total_responses={0} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.nps_widget score={50} promoters={10} passives={5} detractors={5} total_responses={20} class="my-nps" />
      """
    end
  end

  describe "nps_widget/1" do
    test "renders SVG element" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "<svg"
    end

    test "renders arc path element" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "<path"
    end

    test "score >= 75 uses green color" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "text-green-500"
    end

    test "score >= 50 uses amber color" do
      html = render_component(&H.render_mid_score/1, %{})
      assert html =~ "text-amber-500"
    end

    test "score < 50 uses red color" do
      html = render_component(&H.render_low_score/1, %{})
      assert html =~ "text-red-500"
    end

    test "score value is rendered" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "80"
    end

    test "NPS Score label is rendered" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "NPS Score"
    end

    test "breakdown rows are rendered" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "Promoters"
      assert html =~ "Passives"
      assert html =~ "Detractors"
    end

    test "green color for promoters row" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "bg-green-500"
    end

    test "red color for detractors row" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "bg-red-500"
    end

    test "total responses shown" do
      html = render_component(&H.render_high_score/1, %{})
      assert html =~ "500 total responses"
    end

    test "zero total_responses does not crash (guard max(total, 1))" do
      html = render_component(&H.render_zero_responses/1, %{})
      assert html =~ "NPS Score"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-nps"
    end
  end
end
