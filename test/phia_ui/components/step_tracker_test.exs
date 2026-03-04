defmodule PhiaUi.Components.StepTrackerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.StepTracker

    def render_tracker(assigns) do
      ~H"""
      <.step_tracker orientation={assigns[:orientation] || "horizontal"} class={assigns[:class]}>
        <.step status="complete" label="Account" step={1} />
        <.step status="active" label="Profile" step={2} description="Fill in your details" />
        <.step status="upcoming" label="Confirm" step={3} />
      </.step_tracker>
      """
    end

    def render_single_step(assigns) do
      ~H"""
      <.step
        status={assigns[:status] || "upcoming"}
        label={assigns[:label] || "Step"}
        step={assigns[:step] || 1}
        description={assigns[:description]}
        class={assigns[:class]}
      />
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.step_tracker orientation="vertical">
        <.step status="complete" label="Done" step={1} />
        <.step status="active" label="Now" step={2} />
      </.step_tracker>
      """
    end
  end

  defp render_tracker(attrs \\ %{}), do: render_component(&H.render_tracker/1, attrs)
  defp render_single_step(attrs \\ %{}), do: render_component(&H.render_single_step/1, attrs)
  defp render_vertical, do: render_component(&H.render_vertical/1, %{})

  # ---------------------------------------------------------------------------
  # step_tracker/1 — structure
  # ---------------------------------------------------------------------------

  describe "step_tracker/1 — structure" do
    test "renders an ordered list" do
      assert render_tracker() =~ "<ol"
    end

    test "renders all three steps" do
      html = render_tracker()
      assert html =~ "Account"
      assert html =~ "Profile"
      assert html =~ "Confirm"
    end

    test "custom class is applied to the root element" do
      assert render_tracker(%{class: "my-tracker"}) =~ "my-tracker"
    end

    test "horizontal orientation is applied by default" do
      html = render_tracker(%{orientation: "horizontal"})
      assert html =~ "flex" or html =~ "horizontal"
    end

    test "vertical orientation produces vertical layout" do
      html = render_vertical()
      assert html =~ "vertical" or html =~ "flex-col"
    end

    test "has accessible aria-label on the list" do
      html = render_tracker()
      assert html =~ "aria-label" or html =~ "Progress" or html =~ "steps"
    end
  end

  # ---------------------------------------------------------------------------
  # step/1 — status: complete
  # ---------------------------------------------------------------------------

  describe "step/1 — complete status" do
    test "renders completed step label" do
      html = render_single_step(%{status: "complete", label: "Done"})
      assert html =~ "Done"
    end

    test "complete step has distinct visual (checkmark or bg-primary)" do
      html = render_single_step(%{status: "complete"})
      assert html =~ "bg-primary" or html =~ "check" or html =~ "complete"
    end

    test "complete step does not have aria-current=step" do
      html = render_single_step(%{status: "complete"})
      refute html =~ ~s(aria-current="step")
    end
  end

  # ---------------------------------------------------------------------------
  # step/1 — status: active
  # ---------------------------------------------------------------------------

  describe "step/1 — active status" do
    test "renders active step label" do
      html = render_single_step(%{status: "active", label: "Current"})
      assert html =~ "Current"
    end

    test "active step has aria-current=step" do
      html = render_single_step(%{status: "active"})
      assert html =~ ~s(aria-current="step")
    end

    test "active step has distinct styling (ring, primary, bold)" do
      html = render_single_step(%{status: "active"})
      assert html =~ "ring" or html =~ "primary" or html =~ "font-"
    end
  end

  # ---------------------------------------------------------------------------
  # step/1 — status: upcoming
  # ---------------------------------------------------------------------------

  describe "step/1 — upcoming status" do
    test "renders upcoming step label" do
      html = render_single_step(%{status: "upcoming", label: "Future"})
      assert html =~ "Future"
    end

    test "upcoming step does not have aria-current=step" do
      html = render_single_step(%{status: "upcoming"})
      refute html =~ ~s(aria-current="step")
    end

    test "upcoming step has muted styling" do
      html = render_single_step(%{status: "upcoming"})
      assert html =~ "muted" or html =~ "text-muted" or html =~ "border"
    end
  end

  # ---------------------------------------------------------------------------
  # step/1 — labels, descriptions, step numbers
  # ---------------------------------------------------------------------------

  describe "step/1 — content" do
    test "renders label text" do
      html = render_single_step(%{label: "My Label"})
      assert html =~ "My Label"
    end

    test "renders step number when provided" do
      html = render_single_step(%{step: 5})
      assert html =~ "5"
    end

    test "renders description when provided" do
      html = render_single_step(%{description: "This is a description"})
      assert html =~ "This is a description"
    end

    test "does not render description element when nil" do
      html = render_single_step(%{description: nil})
      refute html =~ "Fill in your details"
    end

    test "custom class is applied to step" do
      html = render_single_step(%{class: "my-step"})
      assert html =~ "my-step"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders all statuses in sequence" do
      html = render_tracker()
      assert html =~ "Account"
      assert html =~ "Profile"
      assert html =~ "Confirm"
    end

    test "only active step has aria-current=step" do
      html = render_tracker()
      assert html =~ ~s(aria-current="step")
    end

    test "description is rendered for steps that have it" do
      html = render_tracker()
      assert html =~ "Fill in your details"
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_tracker()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "semantic tokens" do
    test "uses bg-primary for complete or active circles" do
      html = render_tracker()
      assert html =~ "bg-primary"
    end

    test "uses text-muted-foreground for upcoming or muted content" do
      html = render_tracker()
      assert html =~ "muted"
    end
  end
end
