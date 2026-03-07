defmodule PhiaUi.Components.FeedbackWidgetTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FeedbackWidget

    def render_thumb_helpful(assigns) do
      ~H"""
      <.feedback_thumb helpful={true} count={42} />
      """
    end

    def render_thumb_not_helpful(assigns) do
      ~H"""
      <.feedback_thumb helpful={false} />
      """
    end

    def render_thumb_with_class(assigns) do
      ~H"""
      <.feedback_thumb helpful={false} class="my-thumb" />
      """
    end

    def render_reaction(assigns) do
      ~H"""
      <.feedback_reaction
        reactions={[
          %{emoji: "👍", count: 10, value: "like"},
          %{emoji: "❤️", count: 5, value: "love"}
        ]}
        current_reaction="like"
      />
      """
    end

    def render_reaction_none(assigns) do
      ~H"""
      <.feedback_reaction reactions={[%{emoji: "👍", count: 3, value: "like"}]} />
      """
    end

    def render_nps(assigns) do
      ~H"""
      <.feedback_nps selected={9} />
      """
    end

    def render_nps_none(assigns) do
      ~H"""
      <.feedback_nps selected={nil} />
      """
    end

    def render_survey(assigns) do
      ~H"""
      <.feedback_survey_card
        title="Was this helpful?"
        phx-click-yes="helpful_yes"
        phx-click-no="helpful_no"
      />
      """
    end

    def render_survey_custom_labels(assigns) do
      ~H"""
      <.feedback_survey_card
        title="Useful?"
        yes_label="Very useful"
        no_label="Not useful"
        phx-click-yes="yes"
        phx-click-no="no"
      />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # feedback_thumb/1
  # ---------------------------------------------------------------------------

  describe "feedback_thumb/1" do
    test "renders as button" do
      html = render_component(&H.render_thumb_helpful/1, %{})
      assert html =~ "<button"
    end

    test "renders helpful label" do
      html = render_component(&H.render_thumb_helpful/1, %{})
      assert html =~ "Helpful"
    end

    test "renders count when provided" do
      html = render_component(&H.render_thumb_helpful/1, %{})
      assert html =~ "42"
    end

    test "aria-pressed=true when helpful" do
      html = render_component(&H.render_thumb_helpful/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "aria-pressed=false when not helpful" do
      html = render_component(&H.render_thumb_not_helpful/1, %{})
      assert html =~ ~s(aria-pressed="false")
    end

    test "helpful renders primary tint" do
      html = render_component(&H.render_thumb_helpful/1, %{})
      assert html =~ "bg-primary"
    end

    test "accepts :class override" do
      html = render_component(&H.render_thumb_with_class/1, %{})
      assert html =~ "my-thumb"
    end
  end

  # ---------------------------------------------------------------------------
  # feedback_reaction/1
  # ---------------------------------------------------------------------------

  describe "feedback_reaction/1" do
    test "renders emoji reactions" do
      html = render_component(&H.render_reaction/1, %{})
      assert html =~ "10"
      assert html =~ "5"
    end

    test "active reaction has aria-pressed=true" do
      html = render_component(&H.render_reaction/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "inactive reaction has aria-pressed=false" do
      html = render_component(&H.render_reaction/1, %{})
      assert html =~ ~s(aria-pressed="false")
    end

    test "active reaction renders primary tint" do
      html = render_component(&H.render_reaction/1, %{})
      assert html =~ "bg-primary"
    end

    test "renders buttons for each reaction" do
      html = render_component(&H.render_reaction/1, %{})
      assert html =~ ~s(phx-value-reaction="like")
      assert html =~ ~s(phx-value-reaction="love")
    end
  end

  # ---------------------------------------------------------------------------
  # feedback_nps/1
  # ---------------------------------------------------------------------------

  describe "feedback_nps/1" do
    test "renders the question text" do
      html = render_component(&H.render_nps/1, %{})
      assert html =~ "How likely are you to recommend us"
    end

    test "renders 0 through 10" do
      html = render_component(&H.render_nps/1, %{})
      for i <- 0..10 do
        assert html =~ ~s(phx-value-score="#{i}")
      end
    end

    test "selected score 9 has promoter green tint" do
      html = render_component(&H.render_nps/1, %{})
      assert html =~ "bg-success"
    end

    test "renders radiogroup role" do
      html = render_component(&H.render_nps/1, %{})
      assert html =~ ~s(role="radiogroup")
    end

    test "renders Not likely / Extremely likely labels" do
      html = render_component(&H.render_nps/1, %{})
      assert html =~ "Not likely"
      assert html =~ "Extremely likely"
    end
  end

  # ---------------------------------------------------------------------------
  # feedback_survey_card/1
  # ---------------------------------------------------------------------------

  describe "feedback_survey_card/1" do
    test "renders title" do
      html = render_component(&H.render_survey/1, %{})
      assert html =~ "Was this helpful?"
    end

    test "renders Yes and No buttons" do
      html = render_component(&H.render_survey/1, %{})
      assert html =~ "Yes"
      assert html =~ "No"
    end

    test "renders custom labels" do
      html = render_component(&H.render_survey_custom_labels/1, %{})
      assert html =~ "Very useful"
      assert html =~ "Not useful"
    end

    test "renders thumbs-up icon" do
      html = render_component(&H.render_survey/1, %{})
      assert html =~ "thumbs-up"
    end

    test "renders thumbs-down icon" do
      html = render_component(&H.render_survey/1, %{})
      assert html =~ "thumbs-down"
    end
  end
end
