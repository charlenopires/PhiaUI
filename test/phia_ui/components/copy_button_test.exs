defmodule PhiaUi.Components.CopyButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CopyButton

    def render_default(assigns) do
      ~H"""
      <.copy_button id="copy-1" value="npm install phia_ui" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.copy_button id="copy-2" value={@value} label={@label} />
      """
    end

    def render_with_timeout(assigns) do
      ~H"""
      <.copy_button id="copy-3" value="secret" timeout={3000} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.copy_button id="copy-4" value="text" class="my-custom-class" />
      """
    end

    def render_with_id(assigns) do
      ~H"""
      <.copy_button id="my-copy-btn" value="hello" />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})

  defp render_with_label(label),
    do: render_component(&H.render_with_label/1, %{value: "some text", label: label})

  defp render_with_timeout, do: render_component(&H.render_with_timeout/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})
  defp render_with_id, do: render_component(&H.render_with_id/1, %{})

  # ---------------------------------------------------------------------------
  # copy_button/1
  # ---------------------------------------------------------------------------

  describe "copy_button/1" do
    test "renders button element" do
      assert render_default() =~ "<button"
    end

    test "button has phx-hook=\"PhiaCopyButton\"" do
      assert render_default() =~ ~s(phx-hook="PhiaCopyButton")
    end

    test "button has data-value with the value" do
      assert render_default() =~ ~s(data-value="npm install phia_ui")
    end

    test "button has data-timeout with timeout value" do
      assert render_with_timeout() =~ ~s(data-timeout="3000")
    end

    test "default timeout is 2000" do
      assert render_default() =~ ~s(data-timeout="2000")
    end

    test "renders aria-label with default \"Copy\"" do
      assert render_default() =~ ~s(aria-label="Copy")
    end

    test "renders custom label" do
      assert render_with_label("Copy API key") =~ ~s(aria-label="Copy API key")
    end

    test "renders copy icon SVG (data-copy-icon attribute)" do
      assert render_default() =~ "data-copy-icon"
    end

    test "renders check icon SVG (data-copy-check attribute)" do
      assert render_default() =~ "data-copy-check"
    end

    test "check icon has hidden class initially" do
      html = render_default()
      # The check icon SVG block contains both data-copy-check and hidden class
      assert html =~ ~r/class="h-4 w-4 hidden"[^<]*data-copy-check/s
    end

    test "copy icon visible initially (no hidden class on copy icon)" do
      html = render_default()
      # The copy icon SVG block contains data-copy-icon with class "h-4 w-4" (no hidden)
      assert html =~ ~r/class="h-4 w-4"[^<]*data-copy-icon/s
    end

    test "renders aria-live span" do
      assert render_default() =~ ~s(aria-live="polite")
    end

    test "renders with custom class" do
      assert render_with_class() =~ "my-custom-class"
    end

    test "button has focus-visible ring classes" do
      assert render_default() =~ "focus-visible:ring-2"
      assert render_default() =~ "focus-visible:ring-ring"
    end

    test "button has border and bg classes" do
      html = render_default()
      assert html =~ "border-border"
      assert html =~ "bg-background"
    end

    test "value is required attr — component exports copy_button/1" do
      assert function_exported?(PhiaUi.Components.CopyButton, :copy_button, 1)
    end

    test "renders with custom id" do
      assert render_with_id() =~ ~s(id="my-copy-btn")
    end

    test "renders custom timeout value in data attribute" do
      assert render_with_timeout() =~ ~s(data-timeout="3000")
    end
  end
end
