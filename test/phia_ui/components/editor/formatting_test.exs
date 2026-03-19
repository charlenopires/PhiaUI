defmodule PhiaUi.Components.Editor.FormattingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Editor.Formatting
    import PhiaUi.Components.Editor.FormattingToolbar

    def render_font_family_selector(assigns) do
      assigns = Map.put_new(assigns, :id, "font-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, "sans-serif")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.font_family_selector id={@id} editor_id={@editor_id} value={@value} class={@class} />"
    end

    def render_font_size_selector(assigns) do
      assigns = Map.put_new(assigns, :id, "size-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, nil)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.font_size_selector id={@id} editor_id={@editor_id} value={@value} class={@class} />"
    end

    def render_text_color_picker(assigns) do
      assigns = Map.put_new(assigns, :id, "color-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, nil)
      assigns = Map.put_new(assigns, :colors, ~w(#000000 #ff0000 #00ff00))
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.text_color_picker id={@id} editor_id={@editor_id} value={@value} colors={@colors} class={@class} />"
    end

    def render_bg_color_picker(assigns) do
      assigns = Map.put_new(assigns, :id, "bg-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, nil)
      assigns = Map.put_new(assigns, :colors, ~w(#ffff00 #00ffff))
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.bg_color_picker id={@id} editor_id={@editor_id} value={@value} colors={@colors} class={@class} />"
    end

    def render_text_case_toggle(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :current_case, :original)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.text_case_toggle editor_id={@editor_id} current_case={@current_case} class={@class} />"
    end

    def render_clear_formatting_button(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.clear_formatting_button editor_id={@editor_id} class={@class} />"
    end

    def render_format_painter(assigns) do
      assigns = Map.put_new(assigns, :id, "painter-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.format_painter id={@id} editor_id={@editor_id} active={@active} class={@class} />"
    end

    def render_text_align_group(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active_alignment, "left")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.text_align_group editor_id={@editor_id} active_alignment={@active_alignment} class={@class} />"
    end

    def render_indent_controls(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.indent_controls editor_id={@editor_id} class={@class} />"
    end

    def render_line_height_selector(assigns) do
      assigns = Map.put_new(assigns, :id, "lh-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, "1.5")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.line_height_selector id={@id} editor_id={@editor_id} value={@value} class={@class} />"
    end

    def render_letter_spacing_selector(assigns) do
      assigns = Map.put_new(assigns, :id, "ls-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :value, "normal")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.letter_spacing_selector id={@id} editor_id={@editor_id} value={@value} class={@class} />"
    end

    def render_paragraph_spacing(assigns) do
      assigns = Map.put_new(assigns, :id, "ps-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :space_before, "0")
      assigns = Map.put_new(assigns, :space_after, "0.5em")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.paragraph_spacing id={@id} editor_id={@editor_id} space_before={@space_before} space_after={@space_after} class={@class} />"
    end

    def render_subscript_button(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.subscript_button editor_id={@editor_id} active={@active} class={@class} />"
    end

    def render_superscript_button(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.superscript_button editor_id={@editor_id} active={@active} class={@class} />"
    end

    def render_small_caps_button(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.small_caps_button editor_id={@editor_id} active={@active} class={@class} />"
    end

    def render_drop_cap_toggle(assigns) do
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.drop_cap_toggle editor_id={@editor_id} active={@active} class={@class} />"
    end

    def render_formatting_toolbar(assigns) do
      assigns = Map.put_new(assigns, :id, "ft-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active_marks, [])
      assigns = Map.put_new(assigns, :active_nodes, [])
      assigns = Map.put_new(assigns, :heading_level, nil)
      assigns = Map.put_new(assigns, :active_alignment, "left")
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.formatting_toolbar id={@id} editor_id={@editor_id} active_marks={@active_marks} active_nodes={@active_nodes} heading_level={@heading_level} active_alignment={@active_alignment} class={@class} />"
    end

    def render_formatting_toolbar_compact(assigns) do
      assigns = Map.put_new(assigns, :id, "ftc-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active_marks, [])
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.formatting_toolbar_compact id={@id} editor_id={@editor_id} active_marks={@active_marks} class={@class} />"
    end

    def render_formatting_toolbar_ribbon(assigns) do
      assigns = Map.put_new(assigns, :id, "ftr-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active_tab, :home)
      assigns = Map.put_new(assigns, :active_marks, [])
      assigns = Map.put_new(assigns, :active_nodes, [])
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.formatting_toolbar_ribbon id={@id} editor_id={@editor_id} active_tab={@active_tab} active_marks={@active_marks} active_nodes={@active_nodes} class={@class} />"
    end

    def render_formatting_toolbar_floating(assigns) do
      assigns = Map.put_new(assigns, :id, "ftf-1")
      assigns = Map.put_new(assigns, :editor_id, "ed")
      assigns = Map.put_new(assigns, :active_marks, [])
      assigns = Map.put_new(assigns, :visible, false)
      assigns = Map.put_new(assigns, :class, nil)
      ~H"<.formatting_toolbar_floating id={@id} editor_id={@editor_id} active_marks={@active_marks} visible={@visible} class={@class} />"
    end
  end

  # ── font_family_selector ──────────────────────────────────────────────────

  describe "font_family_selector/1" do
    test "renders select with font options" do
      html = render_component(&H.render_font_family_selector/1, %{})
      assert html =~ "Sans Serif"
      assert html =~ "Serif"
      assert html =~ "Monospace"
    end

    test "renders with aria-label" do
      html = render_component(&H.render_font_family_selector/1, %{})
      assert html =~ ~s[aria-label="Font family"]
    end
  end

  # ── font_size_selector ────────────────────────────────────────────────────

  describe "font_size_selector/1" do
    test "renders select with size options" do
      html = render_component(&H.render_font_size_selector/1, %{})
      assert html =~ "12"
      assert html =~ "24"
      assert html =~ "48"
    end

    test "renders with aria-label" do
      html = render_component(&H.render_font_size_selector/1, %{})
      assert html =~ ~s[aria-label="Font size"]
    end
  end

  # ── text_color_picker ─────────────────────────────────────────────────────

  describe "text_color_picker/1" do
    test "renders color swatches" do
      html = render_component(&H.render_text_color_picker/1, %{})
      assert html =~ "#000000"
      assert html =~ "#ff0000"
    end

    test "renders with group role" do
      html = render_component(&H.render_text_color_picker/1, %{})
      assert html =~ ~s[role="group"]
      assert html =~ "Text color"
    end
  end

  # ── bg_color_picker ───────────────────────────────────────────────────────

  describe "bg_color_picker/1" do
    test "renders highlight color swatches" do
      html = render_component(&H.render_bg_color_picker/1, %{})
      assert html =~ "#ffff00"
      assert html =~ "Highlight color"
    end
  end

  # ── text_case_toggle ──────────────────────────────────────────────────────

  describe "text_case_toggle/1" do
    test "renders toggle button" do
      html = render_component(&H.render_text_case_toggle/1, %{})
      assert html =~ "Toggle text case"
    end
  end

  # ── clear_formatting_button ───────────────────────────────────────────────

  describe "clear_formatting_button/1" do
    test "renders clear button" do
      html = render_component(&H.render_clear_formatting_button/1, %{})
      assert html =~ "Clear formatting"
    end
  end

  # ── format_painter ────────────────────────────────────────────────────────

  describe "format_painter/1" do
    test "renders with aria-pressed" do
      html = render_component(&H.render_format_painter/1, %{active: true})
      assert html =~ ~s[aria-pressed="true"]
    end

    test "renders inactive by default" do
      html = render_component(&H.render_format_painter/1, %{})
      assert html =~ ~s[aria-pressed="false"]
    end
  end

  # ── text_align_group ──────────────────────────────────────────────────────

  describe "text_align_group/1" do
    test "renders 4 alignment buttons" do
      html = render_component(&H.render_text_align_group/1, %{})
      assert html =~ "Align left"
      assert html =~ "Align center"
      assert html =~ "Align right"
      assert html =~ "Justify"
    end

    test "marks active alignment" do
      html = render_component(&H.render_text_align_group/1, %{active_alignment: "center"})
      assert html =~ ~s[aria-pressed="true"]
    end
  end

  # ── indent_controls ───────────────────────────────────────────────────────

  describe "indent_controls/1" do
    test "renders indent and outdent buttons" do
      html = render_component(&H.render_indent_controls/1, %{})
      assert html =~ "Decrease indent"
      assert html =~ "Increase indent"
    end
  end

  # ── line_height_selector ──────────────────────────────────────────────────

  describe "line_height_selector/1" do
    test "renders options" do
      html = render_component(&H.render_line_height_selector/1, %{})
      assert html =~ "1.0"
      assert html =~ "1.5"
      assert html =~ "2.0"
    end
  end

  # ── letter_spacing_selector ───────────────────────────────────────────────

  describe "letter_spacing_selector/1" do
    test "renders options" do
      html = render_component(&H.render_letter_spacing_selector/1, %{})
      assert html =~ "Tight"
      assert html =~ "Normal"
      assert html =~ "Wide"
    end
  end

  # ── paragraph_spacing ─────────────────────────────────────────────────────

  describe "paragraph_spacing/1" do
    test "renders before and after inputs" do
      html = render_component(&H.render_paragraph_spacing/1, %{})
      assert html =~ "Before"
      assert html =~ "After"
    end
  end

  # ── subscript_button ──────────────────────────────────────────────────────

  describe "subscript_button/1" do
    test "renders with aria-label" do
      html = render_component(&H.render_subscript_button/1, %{})
      assert html =~ "Subscript"
    end

    test "renders active state" do
      html = render_component(&H.render_subscript_button/1, %{active: true})
      assert html =~ ~s[aria-pressed="true"]
    end
  end

  # ── superscript_button ────────────────────────────────────────────────────

  describe "superscript_button/1" do
    test "renders with aria-label" do
      html = render_component(&H.render_superscript_button/1, %{})
      assert html =~ "Superscript"
    end
  end

  # ── small_caps_button ─────────────────────────────────────────────────────

  describe "small_caps_button/1" do
    test "renders with aria-label" do
      html = render_component(&H.render_small_caps_button/1, %{})
      assert html =~ "Small caps"
    end
  end

  # ── drop_cap_toggle ───────────────────────────────────────────────────────

  describe "drop_cap_toggle/1" do
    test "renders with aria-label" do
      html = render_component(&H.render_drop_cap_toggle/1, %{})
      assert html =~ "Drop cap"
    end
  end

  # ── formatting_toolbar ────────────────────────────────────────────────────

  describe "formatting_toolbar/1" do
    test "renders full toolbar with role" do
      html = render_component(&H.render_formatting_toolbar/1, %{})
      assert html =~ ~s[role="toolbar"]
      assert html =~ "Full formatting toolbar"
    end

    test "renders font selectors" do
      html = render_component(&H.render_formatting_toolbar/1, %{})
      assert html =~ "Font family"
      assert html =~ "Font size"
    end
  end

  # ── formatting_toolbar_compact ────────────────────────────────────────────

  describe "formatting_toolbar_compact/1" do
    test "renders compact toolbar" do
      html = render_component(&H.render_formatting_toolbar_compact/1, %{})
      assert html =~ "Compact formatting toolbar"
      assert html =~ "Bold"
      assert html =~ "Link"
    end
  end

  # ── formatting_toolbar_ribbon ─────────────────────────────────────────────

  describe "formatting_toolbar_ribbon/1" do
    test "renders tabs" do
      html = render_component(&H.render_formatting_toolbar_ribbon/1, %{})
      assert html =~ "Home"
      assert html =~ "Insert"
      assert html =~ "Format"
    end

    test "marks active tab" do
      html = render_component(&H.render_formatting_toolbar_ribbon/1, %{active_tab: :home})
      assert html =~ ~s[aria-selected="true"]
    end
  end

  # ── formatting_toolbar_floating ───────────────────────────────────────────

  describe "formatting_toolbar_floating/1" do
    test "renders floating toolbar" do
      html = render_component(&H.render_formatting_toolbar_floating/1, %{})
      assert html =~ "Floating formatting toolbar"
    end

    test "hidden by default" do
      html = render_component(&H.render_formatting_toolbar_floating/1, %{visible: false})
      assert html =~ "opacity-0"
    end

    test "visible when set" do
      html = render_component(&H.render_formatting_toolbar_floating/1, %{visible: true})
      assert html =~ "opacity-100"
    end
  end
end
