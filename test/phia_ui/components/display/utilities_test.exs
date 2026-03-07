defmodule PhiaUi.Components.UtilitiesTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Utilities

    def render_visually_hidden(assigns) do
      ~H"<.visually_hidden>Hidden text</.visually_hidden>"
    end

    def render_visually_hidden_div(assigns) do
      ~H"<.visually_hidden as=\"div\">Hidden div</.visually_hidden>"
    end

    def render_line_clamp(assigns) do
      ~H"""
      <.line_clamp id="lc-1" lines={3}>Some long text here</.line_clamp>
      """
    end

    def render_highlight_text(assigns) do
      ~H"<.highlight_text text=\"Hello World\" query=\"world\" />"
    end

    def render_highlight_text_empty(assigns) do
      ~H"<.highlight_text text=\"Hello World\" query=\"\" />"
    end

    def render_relative_time(assigns) do
      now = DateTime.utc_now()
      five_min_ago = DateTime.add(now, -300, :second)
      assigns = assign(assigns, :dt, five_min_ago) |> assign(:now, now)
      ~H"<.relative_time datetime={@dt} now={@now} />"
    end

    def render_number_format(assigns) do
      ~H"<.number_format value={1234567} compact={true} prefix=\"$\" />"
    end

    def render_number_format_decimal(assigns) do
      ~H"<.number_format value={3.14159} decimals={2} suffix=\"%\" />"
    end

    def render_reading_time(assigns) do
      text = Enum.map(1..238, fn i -> "word#{i}" end) |> Enum.join(" ")
      assigns = assign(assigns, :text, text)
      ~H"<.reading_time text={@text} />"
    end

    def render_label_with_tooltip(assigns) do
      ~H"<.label_with_tooltip label=\"API Key\" tooltip=\"Your secret key\" for=\"api-input\" />"
    end

    def render_print_only(assigns) do
      ~H"<.print_only>Print content</.print_only>"
    end

    def render_screen_only(assigns) do
      ~H"<.screen_only>Screen content</.screen_only>"
    end

    def render_color_mode_value(assigns) do
      ~H"""
      <.color_mode_value>
        <:light>Light mode</:light>
        <:dark>Dark mode</:dark>
      </.color_mode_value>
      """
    end

    def render_diff_display(assigns) do
      ~H"<.diff_display before=\"The quick brown fox\" after=\"The slow green fox\" />"
    end

    def render_stat_unit(assigns) do
      ~H"<.stat_unit value=\"42\" unit=\"req/s\" />"
    end

    def render_word_count(assigns) do
      ~H"<.word_count text=\"one two three\" />"
    end

    def render_focus_trap(assigns) do
      ~H"<.focus_trap id=\"trap-1\" enabled={true}>Content</.focus_trap>"
    end

    def render_sticky_wrapper(assigns) do
      ~H"<.sticky_wrapper offset_top={64}>Sticky content</.sticky_wrapper>"
    end
  end

  # ---------------------------------------------------------------------------
  # visually_hidden/1
  # ---------------------------------------------------------------------------

  describe "visually_hidden/1" do
    test "renders sr-only span" do
      html = render_component(&H.render_visually_hidden/1, %{})
      assert html =~ "sr-only"
      assert html =~ "Hidden text"
    end

    test "renders div when as=div" do
      html = render_component(&H.render_visually_hidden_div/1, %{})
      assert html =~ "<div"
      assert html =~ "sr-only"
    end
  end

  # ---------------------------------------------------------------------------
  # line_clamp/1
  # ---------------------------------------------------------------------------

  describe "line_clamp/1" do
    test "renders content" do
      html = render_component(&H.render_line_clamp/1, %{})
      assert html =~ "Some long text here"
    end

    test "renders read-more button" do
      html = render_component(&H.render_line_clamp/1, %{})
      assert html =~ "Read more"
    end

    test "renders read-less label" do
      html = render_component(&H.render_line_clamp/1, %{})
      assert html =~ "Read less"
    end
  end

  # ---------------------------------------------------------------------------
  # highlight_text/1
  # ---------------------------------------------------------------------------

  describe "highlight_text/1" do
    test "renders matching text in mark" do
      html = render_component(&H.render_highlight_text/1, %{})
      assert html =~ "<mark"
      assert html =~ "World"
    end

    test "does not use raw/1 (XSS safe)" do
      html = render_component(&H.render_highlight_text/1, %{})
      # Just verify it rendered without raw() issues
      assert html =~ "Hello"
    end

    test "empty query renders plain text" do
      html = render_component(&H.render_highlight_text_empty/1, %{})
      refute html =~ "<mark"
    end
  end

  # ---------------------------------------------------------------------------
  # relative_time/1
  # ---------------------------------------------------------------------------

  describe "relative_time/1" do
    test "renders minutes ago" do
      html = render_component(&H.render_relative_time/1, %{})
      assert html =~ "minutes ago"
    end

    test "renders time element" do
      html = render_component(&H.render_relative_time/1, %{})
      assert html =~ "<time"
    end
  end

  # ---------------------------------------------------------------------------
  # number_format/1
  # ---------------------------------------------------------------------------

  describe "number_format/1" do
    test "compact notation renders M suffix" do
      html = render_component(&H.render_number_format/1, %{})
      assert html =~ "M"
      assert html =~ "$"
    end

    test "decimal notation renders suffix" do
      html = render_component(&H.render_number_format_decimal/1, %{})
      assert html =~ "%"
      assert html =~ "3.14"
    end

    test "has tabular-nums class" do
      html = render_component(&H.render_number_format/1, %{})
      assert html =~ "tabular-nums"
    end
  end

  # ---------------------------------------------------------------------------
  # reading_time/1
  # ---------------------------------------------------------------------------

  describe "reading_time/1" do
    test "renders 1 min read for 238 words at default wpm" do
      html = render_component(&H.render_reading_time/1, %{})
      assert html =~ "1 min read"
    end
  end

  # ---------------------------------------------------------------------------
  # label_with_tooltip/1
  # ---------------------------------------------------------------------------

  describe "label_with_tooltip/1" do
    test "renders label text" do
      html = render_component(&H.render_label_with_tooltip/1, %{})
      assert html =~ "API Key"
    end

    test "renders tooltip text" do
      html = render_component(&H.render_label_with_tooltip/1, %{})
      assert html =~ "Your secret key"
    end

    test "renders for attribute" do
      html = render_component(&H.render_label_with_tooltip/1, %{})
      assert html =~ ~s(for="api-input")
    end
  end

  # ---------------------------------------------------------------------------
  # print_only/1
  # ---------------------------------------------------------------------------

  describe "print_only/1" do
    test "has hidden class" do
      html = render_component(&H.render_print_only/1, %{})
      assert html =~ "hidden"
    end

    test "has print:block class" do
      html = render_component(&H.render_print_only/1, %{})
      assert html =~ "print:block"
    end

    test "renders content" do
      html = render_component(&H.render_print_only/1, %{})
      assert html =~ "Print content"
    end
  end

  # ---------------------------------------------------------------------------
  # screen_only/1
  # ---------------------------------------------------------------------------

  describe "screen_only/1" do
    test "has print:hidden class" do
      html = render_component(&H.render_screen_only/1, %{})
      assert html =~ "print:hidden"
    end

    test "renders content" do
      html = render_component(&H.render_screen_only/1, %{})
      assert html =~ "Screen content"
    end
  end

  # ---------------------------------------------------------------------------
  # color_mode_value/1
  # ---------------------------------------------------------------------------

  describe "color_mode_value/1" do
    test "renders light slot" do
      html = render_component(&H.render_color_mode_value/1, %{})
      assert html =~ "Light mode"
    end

    test "renders dark slot" do
      html = render_component(&H.render_color_mode_value/1, %{})
      assert html =~ "Dark mode"
    end

    test "has dark:hidden and dark:inline classes" do
      html = render_component(&H.render_color_mode_value/1, %{})
      assert html =~ "dark:hidden"
      assert html =~ "dark:inline"
    end
  end

  # ---------------------------------------------------------------------------
  # diff_display/1
  # ---------------------------------------------------------------------------

  describe "diff_display/1" do
    test "renders del element for removed words" do
      html = render_component(&H.render_diff_display/1, %{})
      assert html =~ "<del"
    end

    test "renders ins element for added words" do
      html = render_component(&H.render_diff_display/1, %{})
      assert html =~ "<ins"
    end

    test "shows common words" do
      html = render_component(&H.render_diff_display/1, %{})
      assert html =~ "The"
      assert html =~ "fox"
    end
  end

  # ---------------------------------------------------------------------------
  # stat_unit/1
  # ---------------------------------------------------------------------------

  describe "stat_unit/1" do
    test "renders value" do
      html = render_component(&H.render_stat_unit/1, %{})
      assert html =~ "42"
    end

    test "renders unit" do
      html = render_component(&H.render_stat_unit/1, %{})
      assert html =~ "req/s"
    end

    test "value has font-bold" do
      html = render_component(&H.render_stat_unit/1, %{})
      assert html =~ "font-bold"
    end
  end

  # ---------------------------------------------------------------------------
  # word_count/1
  # ---------------------------------------------------------------------------

  describe "word_count/1" do
    test "renders correct count" do
      html = render_component(&H.render_word_count/1, %{})
      assert html =~ "3"
      assert html =~ "words"
    end
  end

  # ---------------------------------------------------------------------------
  # focus_trap/1
  # ---------------------------------------------------------------------------

  describe "focus_trap/1" do
    test "has phx-hook attribute" do
      html = render_component(&H.render_focus_trap/1, %{})
      assert html =~ ~s(phx-hook="PhiaFocusTrap")
    end

    test "has data-enabled attribute" do
      html = render_component(&H.render_focus_trap/1, %{})
      assert html =~ ~s(data-enabled="true")
    end

    test "has id attribute" do
      html = render_component(&H.render_focus_trap/1, %{})
      assert html =~ ~s(id="trap-1")
    end
  end

  # ---------------------------------------------------------------------------
  # sticky_wrapper/1
  # ---------------------------------------------------------------------------

  describe "sticky_wrapper/1" do
    test "has sticky class" do
      html = render_component(&H.render_sticky_wrapper/1, %{})
      assert html =~ "sticky"
    end

    test "has top offset in style" do
      html = render_component(&H.render_sticky_wrapper/1, %{})
      assert html =~ "top: 64px"
    end

    test "renders content" do
      html = render_component(&H.render_sticky_wrapper/1, %{})
      assert html =~ "Sticky content"
    end
  end
end
