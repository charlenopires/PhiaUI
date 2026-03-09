defmodule PhiaUi.Components.CodeSnippetTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CodeSnippet

    attr :id, :string, default: "test-snippet"
    attr :code, :string, default: "hello world"
    attr :language, :string, default: nil
    attr :filename, :string, default: nil
    attr :show_line_numbers, :boolean, default: false
    attr :highlight_lines, :list, default: []
    attr :max_height, :string, default: nil
    attr :class, :string, default: nil

    def render_code_snippet(assigns) do
      ~H"""
      <.code_snippet
        id={@id}
        code={@code}
        language={@language}
        filename={@filename}
        show_line_numbers={@show_line_numbers}
        highlight_lines={@highlight_lines}
        max_height={@max_height}
        class={@class}
      />
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.code_snippet id="rest-test" code="x = 1" data-testid="my-snippet" />
      """
    end
  end

  defp render_snippet(attrs \\ %{}) do
    render_component(&H.render_code_snippet/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # 1. Renders code content
  # ---------------------------------------------------------------------------

  describe "code content" do
    test "renders code text in the output" do
      html = render_snippet(%{code: "IO.puts(:ok)"})
      assert html =~ "IO.puts(:ok)"
    end

    test "renders multiline code" do
      code = "line1\nline2\nline3"
      html = render_snippet(%{code: code})
      assert html =~ "line1"
      assert html =~ "line3"
    end
  end

  # ---------------------------------------------------------------------------
  # 2. Renders filename in header
  # ---------------------------------------------------------------------------

  describe "filename" do
    test "renders filename text when provided" do
      html = render_snippet(%{filename: "app.js"})
      assert html =~ "app.js"
    end

    test "renders filename in a span with text-sm" do
      html = render_snippet(%{filename: "main.ex"})
      assert html =~ "text-sm"
      assert html =~ "main.ex"
    end
  end

  # ---------------------------------------------------------------------------
  # 3. Renders language badge
  # ---------------------------------------------------------------------------

  describe "language badge" do
    test "renders language text when provided" do
      html = render_snippet(%{language: "elixir"})
      assert html =~ "elixir"
    end

    test "renders language badge with text-xs styling" do
      html = render_snippet(%{language: "javascript"})
      assert html =~ "text-xs"
      assert html =~ "javascript"
    end
  end

  # ---------------------------------------------------------------------------
  # 4. Renders copy button with aria-label
  # ---------------------------------------------------------------------------

  describe "copy button" do
    test "renders button with aria-label Copy code" do
      html = render_snippet()
      assert html =~ ~s(aria-label="Copy code")
    end

    test "renders data-copy-btn attribute" do
      html = render_snippet()
      assert html =~ "data-copy-btn"
    end

    test "renders data-code attribute with the code content" do
      html = render_snippet(%{code: "foo bar"})
      assert html =~ ~s(data-code="foo bar")
    end
  end

  # ---------------------------------------------------------------------------
  # 5. Renders phx-hook
  # ---------------------------------------------------------------------------

  describe "phx-hook" do
    test "renders PhiaCodeSnippet hook" do
      html = render_snippet()
      assert html =~ ~s(phx-hook="PhiaCodeSnippet")
    end
  end

  # ---------------------------------------------------------------------------
  # 6. Shows line numbers when enabled
  # ---------------------------------------------------------------------------

  describe "line numbers enabled" do
    test "renders line number table when show_line_numbers is true" do
      html = render_snippet(%{code: "a\nb\nc", show_line_numbers: true})
      assert html =~ "<table"
      assert html =~ "<tbody"
    end

    test "renders sequential line numbers" do
      html = render_snippet(%{code: "x\ny\nz", show_line_numbers: true})
      assert html =~ ">1<"
      assert html =~ ">2<"
      assert html =~ ">3<"
    end

    test "renders code content in table cells" do
      html = render_snippet(%{code: "hello\nworld", show_line_numbers: true})
      assert html =~ "hello"
      assert html =~ "world"
    end

    test "highlights specified lines" do
      html = render_snippet(%{code: "a\nb\nc", show_line_numbers: true, highlight_lines: [2]})
      assert html =~ "bg-primary/10"
    end
  end

  # ---------------------------------------------------------------------------
  # 7. Does not show line numbers by default
  # ---------------------------------------------------------------------------

  describe "line numbers disabled by default" do
    test "does not render table element" do
      html = render_snippet(%{code: "simple code"})
      refute html =~ "<table"
    end

    test "renders code directly without line number markup" do
      html = render_snippet(%{code: "raw code here"})
      assert html =~ "raw code here"
      refute html =~ "<tbody"
    end
  end

  # ---------------------------------------------------------------------------
  # 8. Renders terminal dots when header present
  # ---------------------------------------------------------------------------

  describe "terminal dots" do
    test "renders three colored dots when filename is present" do
      html = render_snippet(%{filename: "test.ex"})
      assert html =~ "bg-red-400"
      assert html =~ "bg-yellow-400"
      assert html =~ "bg-green-400"
    end

    test "renders three colored dots when language is present" do
      html = render_snippet(%{language: "ruby"})
      assert html =~ "bg-red-400"
      assert html =~ "bg-yellow-400"
      assert html =~ "bg-green-400"
    end

    test "does not render dots when neither filename nor language" do
      html = render_snippet()
      refute html =~ "bg-red-400"
    end
  end

  # ---------------------------------------------------------------------------
  # 9. Renders max_height as style
  # ---------------------------------------------------------------------------

  describe "max_height" do
    test "renders max-height style when provided" do
      html = render_snippet(%{max_height: "300px"})
      assert html =~ "max-height: 300px"
    end

    test "renders overflow-y auto when max_height set" do
      html = render_snippet(%{max_height: "200px"})
      assert html =~ "overflow-y: auto"
    end

    test "does not render max-height style when nil" do
      html = render_snippet()
      refute html =~ "max-height"
    end
  end

  # ---------------------------------------------------------------------------
  # 10. Custom class merging
  # ---------------------------------------------------------------------------

  describe "custom class" do
    test "includes custom class in root element" do
      html = render_snippet(%{class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # 11. Renders rounded-lg border
  # ---------------------------------------------------------------------------

  describe "base styling" do
    test "renders rounded-lg" do
      html = render_snippet()
      assert html =~ "rounded-lg"
    end

    test "renders border-border" do
      html = render_snippet()
      assert html =~ "border-border"
    end

    test "renders bg-card" do
      html = render_snippet()
      assert html =~ "bg-card"
    end

    test "renders overflow-hidden" do
      html = render_snippet()
      assert html =~ "overflow-hidden"
    end
  end

  # ---------------------------------------------------------------------------
  # 12. Code without filename/language still shows copy button
  # ---------------------------------------------------------------------------

  describe "minimal mode (no filename, no language)" do
    test "still renders copy button" do
      html = render_snippet(%{code: "plain code"})
      assert html =~ ~s(aria-label="Copy code")
      assert html =~ "data-copy-btn"
    end

    test "renders compact header bar" do
      html = render_snippet(%{code: "plain code"})
      assert html =~ "flex justify-end"
    end
  end

  # ---------------------------------------------------------------------------
  # @rest passthrough
  # ---------------------------------------------------------------------------

  describe "@rest passthrough" do
    test "passes data-testid to the root element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-snippet")
    end
  end
end
