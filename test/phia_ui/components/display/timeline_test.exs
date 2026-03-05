defmodule PhiaUi.Components.TimelineTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Timeline

    def render_timeline(assigns) do
      ~H"""
      <.timeline class={assigns[:class]}>
        <.timeline_item timestamp={assigns[:timestamp]} class={assigns[:item_class]}>
          {assigns[:content] || "Event content"}
        </.timeline_item>
      </.timeline>
      """
    end

    def render_item_with_icon(assigns) do
      ~H"""
      <.timeline_item timestamp="now">
        <:icon><span class="custom-icon" /></:icon>
        Content
      </.timeline_item>
      """
    end

    def render_item_no_timestamp(assigns) do
      ~H"""
      <.timeline_item>
        No timestamp content
      </.timeline_item>
      """
    end

    def render_multiple_items(assigns) do
      ~H"""
      <.timeline>
        <.timeline_item timestamp="1 hour ago">First event</.timeline_item>
        <.timeline_item timestamp="2 hours ago">Second event</.timeline_item>
        <.timeline_item>Third event</.timeline_item>
      </.timeline>
      """
    end
  end

  defp render_timeline(attrs \\ %{}), do: render_component(&H.render_timeline/1, attrs)
  defp render_item_with_icon, do: render_component(&H.render_item_with_icon/1, %{})
  defp render_item_no_timestamp, do: render_component(&H.render_item_no_timestamp/1, %{})
  defp render_multiple_items, do: render_component(&H.render_multiple_items/1, %{})

  # ---------------------------------------------------------------------------
  # timeline/1 — container
  # ---------------------------------------------------------------------------

  describe "timeline/1 — container" do
    test "renders ol element" do
      assert render_timeline() =~ "<ol"
    end

    test "has relative class on the ol element" do
      assert render_timeline() =~ "relative"
    end

    test "has space-y-6 class on the ol element" do
      assert render_timeline() =~ "space-y-6"
    end

    test "renders inner slot content" do
      assert render_timeline(%{content: "Event content"}) =~ "Event content"
    end

    test "custom class is applied to the timeline container" do
      assert render_timeline(%{class: "my-timeline"}) =~ "my-timeline"
    end

    test "base classes are preserved alongside custom class" do
      html = render_timeline(%{class: "my-timeline"})
      assert html =~ "relative"
      assert html =~ "space-y-6"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — item element
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — li element" do
    test "renders li element" do
      assert render_timeline() =~ "<li"
    end

    test "has pl-8 class for left padding" do
      assert render_timeline() =~ "pl-8"
    end

    test "has relative class on the li element" do
      assert render_timeline() =~ "relative"
    end

    test "custom class is applied to the timeline_item" do
      assert render_timeline(%{item_class: "custom-item"}) =~ "custom-item"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — timestamp
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — timestamp" do
    test "renders timestamp when provided" do
      assert render_timeline(%{timestamp: "2 hours ago"}) =~ "2 hours ago"
    end

    test "renders timestamp inside a p element" do
      html = render_timeline(%{timestamp: "2 hours ago"})
      assert html =~ "<p"
      assert html =~ "2 hours ago"
    end

    test "timestamp has muted foreground class (semantic token)" do
      html = render_timeline(%{timestamp: "2 hours ago"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render timestamp p element when timestamp is nil" do
      html = render_item_no_timestamp()
      refute html =~ "text-muted-foreground"
    end

    test "does not render timestamp text when nil" do
      refute render_item_no_timestamp() =~ "now"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — content
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — inner content" do
    test "renders inner_block content" do
      assert render_timeline(%{content: "My event description"}) =~ "My event description"
    end

    test "content is wrapped in a text-sm text-foreground div" do
      html = render_timeline(%{content: "Some content"})
      assert html =~ "text-sm"
      assert html =~ "text-foreground"
    end

    test "renders content without timestamp when timestamp is nil" do
      html = render_item_no_timestamp()
      assert html =~ "No timestamp content"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — default dot marker
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — default dot marker" do
    test "renders default dot span when no icon slot is given" do
      html = render_item_no_timestamp()
      assert html =~ "bg-primary"
    end

    test "default dot has rounded-full class" do
      html = render_item_no_timestamp()
      assert html =~ "h-2 w-2 rounded-full bg-primary"
    end

    test "marker wrapper has rounded-full class" do
      assert render_timeline() =~ "rounded-full"
    end

    test "marker wrapper uses bg-background semantic token" do
      assert render_timeline() =~ "bg-background"
    end

    test "marker wrapper uses ring-border semantic token" do
      assert render_timeline() =~ "ring-border"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — icon slot
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — icon slot" do
    test "renders icon slot content when icon is provided" do
      assert render_item_with_icon() =~ "custom-icon"
    end

    test "does not render default dot when icon slot is provided" do
      html = render_item_with_icon()
      refute html =~ "h-2 w-2 rounded-full bg-primary"
    end

    test "icon slot is rendered inside the marker wrapper" do
      html = render_item_with_icon()
      assert html =~ "custom-icon"
      assert html =~ "rounded-full"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — connector line
  # ---------------------------------------------------------------------------

  describe "timeline_item/1 — connector line" do
    test "renders connector span with bg-border" do
      assert render_timeline() =~ "bg-border"
    end

    test "connector has aria-hidden=true" do
      assert render_timeline() =~ ~s(aria-hidden="true")
    end

    test "connector has w-px for hairline width" do
      assert render_timeline() =~ "w-px"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline/1 — multiple items
  # ---------------------------------------------------------------------------

  describe "timeline/1 — multiple items" do
    test "renders multiple timeline_item children" do
      html = render_multiple_items()
      assert html =~ "First event"
      assert html =~ "Second event"
      assert html =~ "Third event"
    end

    test "renders multiple timestamps" do
      html = render_multiple_items()
      assert html =~ "1 hour ago"
      assert html =~ "2 hours ago"
    end

    test "item without timestamp renders no muted label" do
      html = render_multiple_items()
      assert String.contains?(html, "First event")
      assert String.contains?(html, "Third event")
    end
  end
end
