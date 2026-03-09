defmodule PhiaUi.Components.Layout.SectionFooterTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.SectionFooter

    def render_section_footer(assigns) do
      ~H"""
      <.section_footer
        divider={assigns[:divider] != false}
        align={assigns[:align] || :end}
        class={assigns[:class]}
      >
        {assigns[:content] || "Footer content"}
      </.section_footer>
      """
    end
  end

  defp render_footer(attrs \\ %{}), do: render_component(&H.render_section_footer/1, attrs)

  describe "section_footer/1" do
    test "renders inner_block content" do
      html = render_footer(%{content: "Save changes"})
      assert html =~ "Save changes"
    end

    test "default divider renders border-t" do
      html = render_footer()
      assert html =~ "border-t"
      assert html =~ "pt-4"
    end

    test "no divider when false" do
      html = render_footer(%{divider: false})
      refute html =~ "border-t"
      refute html =~ "pt-4"
    end

    test "default align end renders justify-end" do
      html = render_footer()
      assert html =~ "justify-end"
    end

    test "align start renders justify-start" do
      html = render_footer(%{align: :start})
      assert html =~ "justify-start"
    end

    test "align between renders justify-between" do
      html = render_footer(%{align: :between})
      assert html =~ "justify-between"
    end

    test "align center renders justify-center" do
      html = render_footer(%{align: :center})
      assert html =~ "justify-center"
    end

    test "custom class merging" do
      html = render_footer(%{class: "my-footer"})
      assert html =~ "my-footer"
    end
  end
end
