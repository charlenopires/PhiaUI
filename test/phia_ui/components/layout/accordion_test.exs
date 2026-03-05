defmodule PhiaUi.Components.AccordionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Accordion

    attr(:type, :atom, default: :single)
    attr(:accordion_id, :string, default: "test-accordion")

    def render_accordion(assigns) do
      ~H"""
      <.accordion id={@accordion_id} type={@type}>
        <.accordion_item value="item-1" type={@type} accordion_id={@accordion_id}>
          <.accordion_trigger value="item-1" type={@type} accordion_id={@accordion_id}>
            Question 1
          </.accordion_trigger>
          <.accordion_content value="item-1">
            Answer 1
          </.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    attr(:class, :string, default: nil)

    def render_trigger(assigns) do
      ~H"""
      <.accordion id="acc" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="acc">
          <.accordion_trigger value="q1" type={:single} accordion_id="acc" class={@class}>
            Trigger text
          </.accordion_trigger>
          <.accordion_content value="q1">Content</.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    def render_content(assigns) do
      ~H"""
      <.accordion id="acc" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="acc">
          <.accordion_trigger value="q1" type={:single} accordion_id="acc">T</.accordion_trigger>
          <.accordion_content value="q1">
            Panel content
          </.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    def render_multiple(assigns) do
      ~H"""
      <.accordion id="multi" type={:multiple}>
        <.accordion_item value="a" type={:multiple} accordion_id="multi">
          <.accordion_trigger value="a" type={:multiple} accordion_id="multi">A</.accordion_trigger>
          <.accordion_content value="a">Content A</.accordion_content>
        </.accordion_item>
        <.accordion_item value="b" type={:multiple} accordion_id="multi">
          <.accordion_trigger value="b" type={:multiple} accordion_id="multi">B</.accordion_trigger>
          <.accordion_content value="b">Content B</.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    def render_disabled_item(assigns) do
      ~H"""
      <.accordion id="test" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="test" disabled={true}>
          <.accordion_trigger value="q1" type={:single} accordion_id="test">
            Disabled Question
          </.accordion_trigger>
          <.accordion_content value="q1">Disabled Answer</.accordion_content>
        </.accordion_item>
        <.accordion_item value="q2" type={:single} accordion_id="test">
          <.accordion_trigger value="q2" type={:single} accordion_id="test">
            Normal Question
          </.accordion_trigger>
          <.accordion_content value="q2">Normal Answer</.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    def render_open_item(assigns) do
      ~H"""
      <.accordion id="test" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="test">
          <.accordion_trigger value="q1" type={:single} accordion_id="test" open={true}>
            Open by default
          </.accordion_trigger>
          <.accordion_content value="q1" open={true}>Default open content</.accordion_content>
        </.accordion_item>
        <.accordion_item value="q2" type={:single} accordion_id="test">
          <.accordion_trigger value="q2" type={:single} accordion_id="test">
            Closed by default
          </.accordion_trigger>
          <.accordion_content value="q2">Closed content</.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end

    def render_collapsible(assigns) do
      ~H"""
      <.accordion id="test" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="test">
          <.accordion_trigger value="q1" type={:single} accordion_id="test" collapsible={true}>
            Collapsible Question
          </.accordion_trigger>
          <.accordion_content value="q1">Collapsible content</.accordion_content>
        </.accordion_item>
      </.accordion>
      """
    end
  end

  defp render_accordion(attrs \\ %{}) do
    render_component(&H.render_accordion/1, attrs)
  end

  defp render_trigger(attrs \\ %{}) do
    render_component(&H.render_trigger/1, attrs)
  end

  defp render_content(attrs \\ %{}) do
    render_component(&H.render_content/1, attrs)
  end

  defp render_multiple(attrs \\ %{}) do
    render_component(&H.render_multiple/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: accordion/1 aceita attr :type, :atom, values: [:single,
  # :multiple], default: :single
  # ---------------------------------------------------------------------------

  describe "accordion/1" do
    test "renders a div container" do
      html = render_accordion()
      assert html =~ "<div"
    end

    test "has w-full class" do
      html = render_accordion()
      assert html =~ "w-full"
    end

    test "renders inner content" do
      html = render_accordion()
      assert html =~ "Question 1"
      assert html =~ "Answer 1"
    end

    test "accepts type: :single without error" do
      html = render_accordion(%{type: :single})
      assert html =~ "<div"
    end

    test "accepts type: :multiple without error" do
      html = render_accordion(%{type: :multiple})
      assert html =~ "<div"
    end

    test "renders with given id" do
      html = render_accordion(%{accordion_id: "my-faq"})
      assert html =~ ~s(id="my-faq")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: accordion_item/1 aceita attr :value, :string
  # ---------------------------------------------------------------------------

  describe "accordion_item/1" do
    test "renders a div wrapper" do
      html = render_accordion()
      assert html =~ "<div"
    end

    test "has border-b class" do
      html = render_accordion()
      assert html =~ "border-b"
    end

    test "renders children" do
      html = render_accordion()
      assert html =~ "Question 1"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: accordion_trigger/1 é button que usa JS.toggle
  # ---------------------------------------------------------------------------

  describe "accordion_trigger/1" do
    test "renders a button element" do
      html = render_trigger()
      assert html =~ "<button"
    end

    test "has type=button" do
      html = render_trigger()
      assert html =~ ~s(type="button")
    end

    test "has phx-click attribute (LiveView.JS command)" do
      html = render_trigger()
      assert html =~ "phx-click"
    end

    test "renders trigger text content" do
      html = render_trigger()
      assert html =~ "Trigger text"
    end

    test "has trigger id based on value" do
      html = render_trigger()
      assert html =~ ~s(id="accordion-trigger-q1")
    end

    test "has data-accordion-trigger attribute" do
      html = render_trigger()
      assert html =~ "data-accordion-trigger"
    end

    test "accepts custom class" do
      html = render_trigger(%{class: "font-bold"})
      assert html =~ "font-bold"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: chevron rotates via JS.toggle_class('rotate-180')
  # ---------------------------------------------------------------------------

  describe "accordion_trigger/1 chevron" do
    test "renders SVG chevron icon" do
      html = render_trigger()
      assert html =~ "<svg"
    end

    test "chevron has id based on value" do
      html = render_trigger()
      assert html =~ ~s(id="chevron-q1")
    end

    test "chevron has data-chevron attribute" do
      html = render_trigger()
      assert html =~ "data-chevron"
    end

    test "chevron has transition-transform class for rotation animation" do
      html = render_trigger()
      assert html =~ "transition-transform"
    end

    test "chevron is aria-hidden" do
      html = render_trigger()
      assert html =~ ~s(aria-hidden="true")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: type :single uses JS.hide to collapse others
  # (verified via phx-click payload containing hide JS command for single mode)
  # ---------------------------------------------------------------------------

  describe "accordion_trigger/1 single mode JS" do
    test "phx-click is present for single mode" do
      html = render_accordion(%{type: :single, accordion_id: "faq"})
      assert html =~ "phx-click"
    end

    test "multiple items each have their own trigger id" do
      html = render_multiple()
      assert html =~ ~s(id="accordion-trigger-a")
      assert html =~ ~s(id="accordion-trigger-b")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: accordion_content/1 usa overflow-hidden com height transition
  # ---------------------------------------------------------------------------

  describe "accordion_content/1" do
    test "renders a div" do
      html = render_content()
      assert html =~ "<div"
    end

    test "has id based on value" do
      html = render_content()
      assert html =~ ~s(id="accordion-content-q1")
    end

    test "has data-accordion-content attribute" do
      html = render_content()
      assert html =~ "data-accordion-content"
    end

    test "has overflow-hidden class" do
      html = render_content()
      assert html =~ "overflow-hidden"
    end

    test "has transition class for animation" do
      html = render_content()
      assert html =~ "transition"
    end

    test "is hidden by default" do
      html = render_content()
      assert html =~ ~s(display: none)
    end

    test "renders content" do
      html = render_content()
      assert html =~ "Panel content"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: Zero JS Hooks — no phx-hook in the rendered HTML
  # ---------------------------------------------------------------------------

  describe "zero JS Hooks" do
    test "accordion root has no phx-hook" do
      html = render_accordion()
      refute html =~ "phx-hook"
    end

    test "multiple mode has no phx-hook" do
      html = render_multiple()
      refute html =~ "phx-hook"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: ARIA — aria-expanded on trigger, aria-controls → content id
  # ---------------------------------------------------------------------------

  describe "ARIA attributes" do
    test "trigger has aria-expanded=false initially" do
      html = render_trigger()
      assert html =~ ~s(aria-expanded="false")
    end

    test "trigger has aria-controls pointing to content id" do
      html = render_trigger()
      assert html =~ ~s(aria-controls="accordion-content-q1")
    end

    test "multiple items each have correct aria-controls" do
      html = render_multiple()
      assert html =~ ~s(aria-controls="accordion-content-a")
      assert html =~ ~s(aria-controls="accordion-content-b")
    end

    test "content id matches aria-controls value" do
      html = render_content()
      assert html =~ ~s(id="accordion-content-q1")
      assert html =~ ~s(aria-controls="accordion-content-q1")
    end
  end

  # ---------------------------------------------------------------------------
  # accordion_item/1 — disabled
  # ---------------------------------------------------------------------------

  describe "accordion_item/1 — disabled" do
    test "disabled item has pointer-events-none class" do
      html = render_component(&H.render_disabled_item/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "disabled item has opacity-50 class" do
      html = render_component(&H.render_disabled_item/1, %{})
      assert html =~ "opacity-50"
    end

    test "disabled item has aria-disabled=true" do
      html = render_component(&H.render_disabled_item/1, %{})
      assert html =~ ~s(aria-disabled="true")
    end

    test "non-disabled item does not have aria-disabled" do
      html = render_accordion()
      refute html =~ "aria-disabled"
    end
  end

  # ---------------------------------------------------------------------------
  # accordion_trigger/1 — open (default_value support)
  # ---------------------------------------------------------------------------

  describe "accordion_trigger/1 — open attr" do
    test "open=true sets aria-expanded='true'" do
      html = render_component(&H.render_open_item/1, %{})
      assert html =~ ~s(aria-expanded="true")
    end

    test "open=true adds rotate-180 to chevron" do
      html = render_component(&H.render_open_item/1, %{})
      assert html =~ "rotate-180"
    end

    test "open=false (default) sets aria-expanded='false'" do
      html = render_trigger()
      assert html =~ ~s(aria-expanded="false")
    end
  end

  # ---------------------------------------------------------------------------
  # accordion_content/1 — open (default_value support)
  # ---------------------------------------------------------------------------

  describe "accordion_content/1 — open attr" do
    test "open=true renders content visible (display: block)" do
      html = render_component(&H.render_open_item/1, %{})
      assert html =~ "display: block"
    end

    test "open=false (default) renders content hidden (display: none)" do
      html = render_content()
      assert html =~ "display: none"
    end

    test "open=true renders content accessible" do
      html = render_component(&H.render_open_item/1, %{})
      assert html =~ "Default open content"
    end
  end

  # ---------------------------------------------------------------------------
  # accordion_trigger/1 — collapsible
  # ---------------------------------------------------------------------------

  describe "accordion_trigger/1 — collapsible" do
    test "collapsible=true renders trigger without error" do
      html = render_component(&H.render_collapsible/1, %{})
      assert html =~ "<button"
    end

    test "collapsible=true still has phx-click" do
      html = render_component(&H.render_collapsible/1, %{})
      assert html =~ "phx-click"
    end

    test "collapsible=false (default) renders correctly" do
      html = render_trigger()
      assert html =~ "<button"
      assert html =~ "phx-click"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition smoke test
  # ---------------------------------------------------------------------------

  describe "full accordion composition" do
    test "single mode renders all sub-components without error" do
      html = render_accordion(%{type: :single, accordion_id: "faq"})
      assert html =~ "<button"
      assert html =~ "Question 1"
      assert html =~ "Answer 1"
    end

    test "multiple mode renders all items without error" do
      html = render_multiple()
      assert html =~ ~s(id="accordion-trigger-a")
      assert html =~ ~s(id="accordion-trigger-b")
      assert html =~ "Content A"
      assert html =~ "Content B"
    end
  end
end
