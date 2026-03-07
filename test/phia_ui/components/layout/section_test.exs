defmodule PhiaUi.Components.Layout.SectionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Section

    def render_section(assigns) do
      ~H"<.section size={assigns[:size] || :md} class={assigns[:class]}>content</.section>"
    end
  end

  defp render_section(attrs \\ %{}) do
    render_component(&H.render_section/1, attrs)
  end

  describe "section/1 tag" do
    test "renders a section element" do
      assert render_section() =~ "<section"
    end

    test "renders inner content" do
      assert render_section() =~ "content"
    end
  end

  describe "section/1 size variants" do
    test "sm applies py-6" do
      assert render_section(%{size: :sm}) =~ "py-6"
    end

    test "md applies py-12" do
      assert render_section(%{size: :md}) =~ "py-12"
    end

    test "lg applies py-16" do
      assert render_section(%{size: :lg}) =~ "py-16"
    end

    test "xl applies py-24" do
      assert render_section(%{size: :xl}) =~ "py-24"
    end
  end

  describe "section/1 class forwarding" do
    test "forwards custom class" do
      assert render_section(%{class: "bg-muted"}) =~ "bg-muted"
    end
  end
end
