defmodule PhiaUi.Components.CollapsibleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collapsible

    def render_closed(assigns) do
      ~H"""
      <.collapsible id="my-collapsible" open={false}>
        <.collapsible_trigger collapsible_id="my-collapsible" open={false}>
          Toggle
        </.collapsible_trigger>
        <.collapsible_content id="my-collapsible-content" open={false}>
          Hidden content
        </.collapsible_content>
      </.collapsible>
      """
    end

    def render_open(assigns) do
      ~H"""
      <.collapsible id="my-collapsible" open={true}>
        <.collapsible_trigger collapsible_id="my-collapsible" open={true}>
          Toggle
        </.collapsible_trigger>
        <.collapsible_content id="my-collapsible-content" open={true}>
          Visible content
        </.collapsible_content>
      </.collapsible>
      """
    end

    attr(:class, :string, default: nil)

    def render_collapsible_with_class(assigns) do
      ~H"""
      <.collapsible id="col-class" class={@class}>
        <.collapsible_trigger collapsible_id="col-class">Toggle</.collapsible_trigger>
        <.collapsible_content id="col-class-content">Content</.collapsible_content>
      </.collapsible>
      """
    end

    def render_trigger_with_class(assigns) do
      ~H"""
      <.collapsible id="col-trigger" class="extra">
        <.collapsible_trigger collapsible_id="col-trigger" class="trigger-class">
          Toggle
        </.collapsible_trigger>
        <.collapsible_content id="col-trigger-content">Content</.collapsible_content>
      </.collapsible>
      """
    end

    def render_content_with_class(assigns) do
      ~H"""
      <.collapsible id="col-content">
        <.collapsible_trigger collapsible_id="col-content">Toggle</.collapsible_trigger>
        <.collapsible_content id="col-content-content" class="content-class" open={true}>
          Content
        </.collapsible_content>
      </.collapsible>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.collapsible id="col-rest" data-testid="root">
        <.collapsible_trigger collapsible_id="col-rest" data-testid="trigger">
          Toggle
        </.collapsible_trigger>
        <.collapsible_content id="col-rest-content" data-testid="content">
          Content
        </.collapsible_content>
      </.collapsible>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: collapsible/1 aceita attr :open (bool, default false)
  # ---------------------------------------------------------------------------

  describe "collapsible/1" do
    test "renders with id attribute" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(id="my-collapsible")
    end

    test "renders inner content" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "Toggle"
    end

    test "renders as a div element" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "<div"
    end

    test "accepts open=false without error" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "<div"
    end

    test "accepts open=true without error" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "<div"
    end

    test "forwards extra attrs via @rest" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="root")
    end

    test "accepts custom class" do
      html = render_component(&H.render_collapsible_with_class/1, %{class: "my-class"})
      assert html =~ "my-class"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: collapsible_trigger/1 — aria-expanded, aria-controls
  # ---------------------------------------------------------------------------

  describe "collapsible_trigger/1" do
    test "has aria-expanded=false when closed" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-expanded="false")
    end

    test "has aria-expanded=true when open" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-expanded="true")
    end

    test "has aria-controls pointing to content element" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-controls="my-collapsible-content")
    end

    test "renders a button element" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "<button"
    end

    test "has type=button" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(type="button")
    end

    test "has phx-click attribute for LiveView.JS toggle" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "phx-click"
    end

    test "renders trigger content" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "Toggle"
    end

    test "has flex layout classes" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "flex"
      assert html =~ "w-full"
    end

    test "accepts custom class" do
      html = render_component(&H.render_trigger_with_class/1, %{})
      assert html =~ "trigger-class"
    end

    test "forwards extra attrs via @rest" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="trigger")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3 & 6: collapsible_content/1 — JS.toggle, hidden/visible, animation
  # ---------------------------------------------------------------------------

  describe "collapsible_content/1" do
    test "is hidden by default when open=false" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "display: none"
    end

    test "is visible when open=true" do
      html = render_component(&H.render_open/1, %{})
      refute html =~ "display: none"
    end

    test "renders content when open=true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Visible content"
    end

    test "renders content when open=false (hidden but present in DOM)" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "Hidden content"
    end

    test "has id attribute" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(id="my-collapsible-content")
    end

    test "has overflow-hidden class for animation support" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "accepts custom class" do
      html = render_component(&H.render_content_with_class/1, %{})
      assert html =~ "content-class"
    end

    test "forwards extra attrs via @rest" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="content")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: :id obrigatório conecta trigger com content via aria-controls
  # ---------------------------------------------------------------------------

  describe "aria-controls connection" do
    test "trigger aria-controls matches content id" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-controls="my-collapsible-content")
      assert html =~ ~s(id="my-collapsible-content")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: Zero JS Hooks
  # ---------------------------------------------------------------------------

  describe "zero JS hooks" do
    test "no phx-hook on the rendered HTML" do
      html = render_component(&H.render_closed/1, %{})
      refute html =~ "phx-hook"
    end

    test "open variant also has no phx-hook" do
      html = render_component(&H.render_open/1, %{})
      refute html =~ "phx-hook"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: Tests for initial open=false, click toggle, open=true
  # ---------------------------------------------------------------------------

  describe "state: open=false (default)" do
    test "content is hidden" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "display: none"
    end

    test "trigger aria-expanded is false" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ ~s(aria-expanded="false")
    end
  end

  describe "state: open=true" do
    test "content is visible" do
      html = render_component(&H.render_open/1, %{})
      refute html =~ "display: none"
    end

    test "trigger aria-expanded is true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-expanded="true")
    end

    test "content is rendered and accessible" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Visible content"
    end
  end

  describe "toggle via phx-click" do
    test "trigger has phx-click with toggle JS command targeting content" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "phx-click"
      assert html =~ "my-collapsible-content"
    end
  end
end
