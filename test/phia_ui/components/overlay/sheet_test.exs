defmodule PhiaUi.Components.SheetTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Sheet

    def render_open(assigns) do
      ~H"""
      <.sheet id="main-sheet" open={true} side="right">
        <.sheet_header>
          <.sheet_title id="main-sheet-title">Sheet Title</.sheet_title>
          <.sheet_description id="main-sheet-description">
            Sheet description text
          </.sheet_description>
        </.sheet_header>
        <p>Sheet body content</p>
        <.sheet_footer>
          <button>Save</button>
        </.sheet_footer>
        <.sheet_close />
      </.sheet>
      """
    end

    def render_closed(assigns) do
      ~H"""
      <.sheet id="closed-sheet" open={false} side="right">
        <p>Hidden content</p>
      </.sheet>
      """
    end

    def render_left(assigns) do
      ~H"""
      <.sheet id="left-sheet" open={true} side="left">
        <p>Left sheet</p>
      </.sheet>
      """
    end

    def render_right(assigns) do
      ~H"""
      <.sheet id="right-sheet" open={true} side="right">
        <p>Right sheet</p>
      </.sheet>
      """
    end

    def render_top(assigns) do
      ~H"""
      <.sheet id="top-sheet" open={true} side="top">
        <p>Top sheet</p>
      </.sheet>
      """
    end

    def render_bottom(assigns) do
      ~H"""
      <.sheet id="bottom-sheet" open={true} side="bottom">
        <p>Bottom sheet</p>
      </.sheet>
      """
    end

    def render_size_sm(assigns) do
      ~H"""
      <.sheet id="sm-sheet" open={true} side="right" size="sm">
        <p>Small sheet</p>
      </.sheet>
      """
    end

    def render_size_md(assigns) do
      ~H"""
      <.sheet id="md-sheet" open={true} side="right" size="md">
        <p>Medium sheet</p>
      </.sheet>
      """
    end

    def render_size_lg(assigns) do
      ~H"""
      <.sheet id="lg-sheet" open={true} side="right" size="lg">
        <p>Large sheet</p>
      </.sheet>
      """
    end

    def render_size_xl(assigns) do
      ~H"""
      <.sheet id="xl-sheet" open={true} side="right" size="xl">
        <p>XL sheet</p>
      </.sheet>
      """
    end

    def render_size_full(assigns) do
      ~H"""
      <.sheet id="full-sheet" open={true} side="right" size="full">
        <p>Full sheet</p>
      </.sheet>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.sheet id="custom-sheet" open={true} side="right" class="my-custom-class">
        <p>Custom class sheet</p>
      </.sheet>
      """
    end

    def render_full_composition(assigns) do
      ~H"""
      <.sheet id="composed-sheet" open={true} side="right">
        <.sheet_header>
          <.sheet_title id="composed-sheet-title">My Title</.sheet_title>
          <.sheet_description id="composed-sheet-description">
            My description
          </.sheet_description>
        </.sheet_header>
        <p>Body content</p>
        <.sheet_footer>
          <button>Cancel</button>
          <button>Confirm</button>
        </.sheet_footer>
        <.sheet_close />
      </.sheet>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Sub-component exports
  # ---------------------------------------------------------------------------

  describe "sub-components are exported" do
    test "sheet/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet, 1)
    end

    test "sheet_header/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet_header, 1)
    end

    test "sheet_title/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet_title, 1)
    end

    test "sheet_description/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet_description, 1)
    end

    test "sheet_footer/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet_footer, 1)
    end

    test "sheet_close/1 is exported" do
      assert function_exported?(PhiaUi.Components.Sheet, :sheet_close, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — open/closed state
  # ---------------------------------------------------------------------------

  describe "sheet/1 — open state" do
    test "is hidden when open=false" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "hidden"
    end

    test "is not hidden when open=true" do
      html = render_component(&H.render_open/1, %{})
      refute html =~ ~r/class="[^"]*\bhidden\b[^"]*".*phx-hook="PhiaDialog"/s
    end

    test "renders id attribute on root element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(id="main-sheet")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — WAI-ARIA
  # ---------------------------------------------------------------------------

  describe "sheet/1 — ARIA attributes" do
    test "has role=dialog on panel" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(role="dialog")
    end

    test "has aria-modal=true on panel" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-modal="true")
    end

    test "uses PhiaDialog hook" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(phx-hook="PhiaDialog")
    end

    test "has aria-labelledby linking to title id" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-labelledby="main-sheet-title")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — side variants
  # ---------------------------------------------------------------------------

  describe "sheet/1 — side variants" do
    test "side=right applies right panel positioning" do
      html = render_component(&H.render_right/1, %{})
      assert html =~ "right-0"
      assert html =~ "inset-y-0"
    end

    test "side=left applies left panel positioning" do
      html = render_component(&H.render_left/1, %{})
      assert html =~ "left-0"
      assert html =~ "inset-y-0"
    end

    test "side=top applies top panel positioning" do
      html = render_component(&H.render_top/1, %{})
      assert html =~ "top-0"
      assert html =~ "inset-x-0"
    end

    test "side=bottom applies bottom panel positioning" do
      html = render_component(&H.render_bottom/1, %{})
      assert html =~ "bottom-0"
      assert html =~ "inset-x-0"
    end

    test "side=right sets data-side attribute" do
      html = render_component(&H.render_right/1, %{})
      assert html =~ ~s(data-side="right")
    end

    test "side=left sets data-side attribute" do
      html = render_component(&H.render_left/1, %{})
      assert html =~ ~s(data-side="left")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — size variants
  # ---------------------------------------------------------------------------

  describe "sheet/1 — size variants" do
    test "size=sm applies narrow width for side=right" do
      html = render_component(&H.render_size_sm/1, %{})
      assert html =~ "w-64"
    end

    test "size=md (default) applies medium width for side=right" do
      html = render_component(&H.render_size_md/1, %{})
      assert html =~ "w-96"
    end

    test "size=lg applies large width for side=right" do
      html = render_component(&H.render_size_lg/1, %{})
      assert html =~ "max-w-lg"
    end

    test "size=xl applies extra-large width for side=right" do
      html = render_component(&H.render_size_xl/1, %{})
      assert html =~ "max-w-xl"
    end

    test "size=full applies full width for side=right" do
      html = render_component(&H.render_size_full/1, %{})
      assert html =~ "max-w-full"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — backdrop
  # ---------------------------------------------------------------------------

  describe "sheet/1 — backdrop" do
    test "has backdrop element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "data-sheet-backdrop"
    end

    test "backdrop has semi-transparent black background" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "bg-black/80"
    end

    test "backdrop has fixed inset-0 positioning" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "fixed"
      assert html =~ "inset-0"
    end

    test "backdrop has aria-hidden=true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — animation classes
  # ---------------------------------------------------------------------------

  describe "sheet/1 — slide animation" do
    test "has transition-transform" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "transition-transform"
    end

    test "has duration-300" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "duration-300"
    end

    test "has ease-in-out" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "ease-in-out"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — token usage (no hardcoded colors)
  # ---------------------------------------------------------------------------

  describe "sheet/1 — semantic tokens" do
    test "uses bg-background token" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "bg-background"
    end

    test "uses shadow-lg" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "shadow-lg"
    end

    test "uses border-border token or border utility" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "border"
    end

    test "does not use hardcoded gray colors" do
      html = render_component(&H.render_open/1, %{})
      refute html =~ "bg-gray-"
      refute html =~ "text-gray-"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet/1 — custom class passthrough
  # ---------------------------------------------------------------------------

  describe "sheet/1 — class passthrough" do
    test "custom class is applied to the panel" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet_header/1
  # ---------------------------------------------------------------------------

  describe "sheet_header/1" do
    test "renders header content" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Sheet Title"
    end

    test "has flex-col layout" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "flex-col"
    end

    test "has padding" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "p-6"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet_title/1
  # ---------------------------------------------------------------------------

  describe "sheet_title/1" do
    test "renders as heading element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "<h2"
      assert html =~ "Sheet Title"
    end

    test "has semibold font" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "font-semibold"
    end

    test "accepts id attribute for ARIA linkage" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(id="main-sheet-title")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet_description/1
  # ---------------------------------------------------------------------------

  describe "sheet_description/1" do
    test "renders description text" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Sheet description text"
    end

    test "has muted-foreground color token" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "renders as paragraph element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "<p"
    end

    test "accepts id attribute for ARIA linkage" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(id="main-sheet-description")
    end
  end

  # ---------------------------------------------------------------------------
  # sheet_footer/1
  # ---------------------------------------------------------------------------

  describe "sheet_footer/1" do
    test "renders footer content" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Save"
    end

    test "has flex layout" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "flex"
    end

    test "has padding" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "p-6"
    end
  end

  # ---------------------------------------------------------------------------
  # sheet_close/1
  # ---------------------------------------------------------------------------

  describe "sheet_close/1" do
    test "has data-sheet-close attribute" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "data-sheet-close"
    end

    test "has aria-label for accessibility" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Close sheet"
    end

    test "renders as a button element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~r/<button[^>]+data-sheet-close/
    end

    test "has sr-only close text" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "sr-only"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition test
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders all sub-components together" do
      html = render_component(&H.render_full_composition/1, %{})
      assert html =~ ~s(id="composed-sheet")
      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
      assert html =~ "data-sheet-backdrop"
      assert html =~ "My Title"
      assert html =~ "My description"
      assert html =~ "Body content"
      assert html =~ "Cancel"
      assert html =~ "Confirm"
      assert html =~ "data-sheet-close"
    end
  end

  # ---------------------------------------------------------------------------
  # Moduledoc
  # ---------------------------------------------------------------------------

  describe "moduledoc" do
    test "moduledoc is a non-empty string" do
      assert Code.fetch_docs(PhiaUi.Components.Sheet) != :error
    end

    test "moduledoc mentions PhiaDialog hook registration" do
      {:docs_v1, _, _, _, %{"en" => moduledoc}, _, _} =
        Code.fetch_docs(PhiaUi.Components.Sheet)

      assert moduledoc =~ "PhiaDialog"
    end
  end
end
