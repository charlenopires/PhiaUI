defmodule PhiaUi.Components.ProgressEnhancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ProgressEnhanced

    def render_labeled(assigns) do
      ~H"""
      <.labeled_progress label="Upload" value={50} />
      """
    end

    def render_labeled_with_count(assigns) do
      ~H"""
      <.labeled_progress label="Tasks" value={3} max={10} show_count />
      """
    end

    def render_labeled_success(assigns) do
      ~H"""
      <.labeled_progress label="Backup" value={100} variant={:success} />
      """
    end

    def render_labeled_warning(assigns) do
      ~H"""
      <.labeled_progress label="Disk" value={80} variant={:warning} />
      """
    end

    def render_labeled_destructive(assigns) do
      ~H"""
      <.labeled_progress label="Error" value={100} variant={:destructive} />
      """
    end

    def render_segmented(assigns) do
      ~H"""
      <.segmented_progress
        segments={[
          %{label: "Docs", value: 30, color: "bg-primary"},
          %{label: "Images", value: 50, color: "bg-blue-400"}
        ]}
        max={100}
      />
      """
    end

    def render_segmented_no_legend(assigns) do
      ~H"""
      <.segmented_progress
        segments={[%{label: "X", value: 50, color: "bg-primary"}]}
        max={100}
        show_legend={false}
      />
      """
    end

    def render_quota(assigns) do
      ~H"""
      <.quota_bar used={50} limit={100} label="Storage" unit="MB" />
      """
    end

    def render_quota_warning(assigns) do
      ~H"""
      <.quota_bar used={85} limit={100} label="Storage" />
      """
    end

    def render_quota_danger(assigns) do
      ~H"""
      <.quota_bar used={97} limit={100} label="Storage" />
      """
    end

    def render_step_bar(assigns) do
      ~H"""
      <.step_progress_bar current={2} total={5} />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # labeled_progress/1
  # ---------------------------------------------------------------------------

  describe "labeled_progress/1" do
    test "renders label text" do
      html = render_component(&H.render_labeled/1, %{})
      assert html =~ "Upload"
    end

    test "renders percentage" do
      html = render_component(&H.render_labeled/1, %{})
      assert html =~ "50%"
    end

    test "renders count format when show_count=true" do
      html = render_component(&H.render_labeled_with_count/1, %{})
      assert html =~ "3/10"
    end

    test "renders progressbar role" do
      html = render_component(&H.render_labeled/1, %{})
      assert html =~ ~s(role="progressbar")
    end

    test "success variant renders success fill" do
      html = render_component(&H.render_labeled_success/1, %{})
      assert html =~ "bg-success"
    end

    test "warning variant renders warning fill" do
      html = render_component(&H.render_labeled_warning/1, %{})
      assert html =~ "bg-warning"
    end

    test "destructive variant renders destructive fill" do
      html = render_component(&H.render_labeled_destructive/1, %{})
      assert html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # segmented_progress/1
  # ---------------------------------------------------------------------------

  describe "segmented_progress/1" do
    test "renders segment labels in legend" do
      html = render_component(&H.render_segmented/1, %{})
      assert html =~ "Docs"
      assert html =~ "Images"
    end

    test "renders segment colors" do
      html = render_component(&H.render_segmented/1, %{})
      assert html =~ "bg-primary"
      assert html =~ "bg-blue-400"
    end

    test "renders percentages in legend" do
      html = render_component(&H.render_segmented/1, %{})
      assert html =~ "30%"
      assert html =~ "50%"
    end

    test "no legend when show_legend=false" do
      html = render_component(&H.render_segmented_no_legend/1, %{})
      # Legend div has class space-y-2 — not present when show_legend=false
      refute html =~ "flex-wrap items-center gap-x-4"
    end

    test "renders meter role" do
      html = render_component(&H.render_segmented/1, %{})
      assert html =~ ~s(role="meter")
    end
  end

  # ---------------------------------------------------------------------------
  # quota_bar/1
  # ---------------------------------------------------------------------------

  describe "quota_bar/1" do
    test "renders label" do
      html = render_component(&H.render_quota/1, %{})
      assert html =~ "Storage"
    end

    test "renders used/limit with unit" do
      html = render_component(&H.render_quota/1, %{})
      assert html =~ "50 / 100 MB"
    end

    test "below warn_at renders primary fill" do
      html = render_component(&H.render_quota/1, %{})
      assert html =~ "bg-primary"
    end

    test "above warn_at renders warning fill and text" do
      html = render_component(&H.render_quota_warning/1, %{})
      assert html =~ "bg-warning"
      assert html =~ "Approaching limit"
    end

    test "above danger_at renders destructive fill and warning text" do
      html = render_component(&H.render_quota_danger/1, %{})
      assert html =~ "bg-destructive"
      assert html =~ "Consider upgrading"
    end

    test "renders meter role" do
      html = render_component(&H.render_quota/1, %{})
      assert html =~ ~s(role="meter")
    end
  end

  # ---------------------------------------------------------------------------
  # step_progress_bar/1
  # ---------------------------------------------------------------------------

  describe "step_progress_bar/1" do
    test "renders progressbar role" do
      html = render_component(&H.render_step_bar/1, %{})
      assert html =~ ~s(role="progressbar")
    end

    test "renders aria-valuenow" do
      html = render_component(&H.render_step_bar/1, %{})
      assert html =~ ~s(aria-valuenow="2")
    end

    test "renders aria-valuemax" do
      html = render_component(&H.render_step_bar/1, %{})
      assert html =~ ~s(aria-valuemax="5")
    end

    test "renders correct number of segments" do
      html = render_component(&H.render_step_bar/1, %{})
      # 5 total: 1 complete (bg-primary), 1 current (bg-primary/50), 3 upcoming (bg-secondary)
      assert html =~ "bg-primary"
      assert html =~ "bg-secondary"
    end
  end
end
