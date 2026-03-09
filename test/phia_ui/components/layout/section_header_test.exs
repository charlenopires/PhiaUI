defmodule PhiaUi.Components.Layout.SectionHeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.SectionHeader

    def render_section_header(assigns) do
      ~H"""
      <.section_header
        title={assigns[:title] || "Default Title"}
        description={assigns[:description]}
        size={assigns[:size] || :default}
        divider={assigns[:divider] || false}
        class={assigns[:class]}
      />
      """
    end

    def render_section_header_with_actions(assigns) do
      ~H"""
      <.section_header title={assigns[:title] || "Title"}>
        <:actions>
          <button>Action</button>
        </:actions>
      </.section_header>
      """
    end

    def render_section_header_with_badge(assigns) do
      ~H"""
      <.section_header title={assigns[:title] || "Title"}>
        <:badge>
          <span class="test-badge">Beta</span>
        </:badge>
      </.section_header>
      """
    end
  end

  defp render_header(attrs \\ %{}), do: render_component(&H.render_section_header/1, attrs)

  defp render_header_with_actions(attrs \\ %{}),
    do: render_component(&H.render_section_header_with_actions/1, attrs)

  defp render_header_with_badge(attrs \\ %{}),
    do: render_component(&H.render_section_header_with_badge/1, attrs)

  describe "section_header/1" do
    test "renders title text" do
      html = render_header(%{title: "Team Members"})
      assert html =~ "Team Members"
    end

    test "renders description when provided" do
      html = render_header(%{description: "Last 30 days of changes"})
      assert html =~ "Last 30 days of changes"
      assert html =~ "text-muted-foreground"
    end

    test "does not render description when nil" do
      html = render_header()
      refute html =~ "<p"
    end

    test "default size renders text-base" do
      html = render_header()
      assert html =~ "text-base"
    end

    test "size sm renders text-sm" do
      html = render_header(%{size: :sm})
      assert html =~ "text-sm"
    end

    test "size lg renders text-lg" do
      html = render_header(%{size: :lg})
      assert html =~ "text-lg"
    end

    test "divider renders border-b" do
      html = render_header(%{divider: true})
      assert html =~ "border-b"
      assert html =~ "pb-4"
    end

    test "no divider by default" do
      html = render_header()
      refute html =~ "border-b"
      refute html =~ "pb-4"
    end

    test "actions slot renders" do
      html = render_header_with_actions()
      assert html =~ "<button>"
      assert html =~ "Action"
      assert html =~ "shrink-0"
    end

    test "badge slot renders" do
      html = render_header_with_badge()
      assert html =~ "test-badge"
      assert html =~ "Beta"
    end

    test "custom class merging" do
      html = render_header(%{class: "my-section"})
      assert html =~ "my-section"
    end
  end
end
