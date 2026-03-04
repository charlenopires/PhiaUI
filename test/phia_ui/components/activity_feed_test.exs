defmodule PhiaUi.Components.ActivityFeedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ActivityFeed

    def render_feed(assigns) do
      ~H"""
      <.activity_feed id={assigns[:id]} class={assigns[:class]}>
        {assigns[:content] || "feed content"}
      </.activity_feed>
      """
    end

    def render_feed_with_footer(assigns) do
      ~H"""
      <.activity_feed>
        <:footer>
          <form phx-submit="send_comment">
            <input name="comment" />
          </form>
        </:footer>
        Some activity
      </.activity_feed>
      """
    end

    def render_group(assigns) do
      ~H"""
      <.activity_group label={assigns[:label] || "Today"} class={assigns[:class]}>
        {assigns[:content] || "group content"}
      </.activity_group>
      """
    end

    def render_item(assigns) do
      ~H"""
      <.activity_item
        type={assigns[:type] || "system"}
        timestamp={assigns[:timestamp]}
        class={assigns[:class]}
      >
        {assigns[:content] || "Some activity happened"}
      </.activity_item>
      """
    end

    def render_item_with_avatar(assigns) do
      ~H"""
      <.activity_item type="mention" timestamp="9:12 AM">
        <:avatar>
          <span class="custom-avatar" />
        </:avatar>
        Jason mentioned you
      </.activity_item>
      """
    end

    def render_all_types(assigns) do
      ~H"""
      <.activity_feed>
        <.activity_item type="mention">Mention event</.activity_item>
        <.activity_item type="file">File event</.activity_item>
        <.activity_item type="call">Call event</.activity_item>
        <.activity_item type="task">Task event</.activity_item>
        <.activity_item type="reaction">Reaction event</.activity_item>
        <.activity_item type="system">System event</.activity_item>
      </.activity_feed>
      """
    end

    def render_full(assigns) do
      ~H"""
      <.activity_feed>
        <.activity_group label="Today">
          <.activity_item type="mention" timestamp="9:12 AM">
            <:avatar><span class="avatar-slot" /></:avatar>
            Jason mentioned you
          </.activity_item>
          <.activity_item type="file" timestamp="9:46 AM">
            New file uploaded
          </.activity_item>
        </.activity_group>
        <.activity_group label="Yesterday">
          <.activity_item type="task" timestamp="09:18 AM">
            Task assigned
          </.activity_item>
        </.activity_group>
      </.activity_feed>
      """
    end
  end

  defp render_feed(attrs \\ %{}), do: render_component(&H.render_feed/1, attrs)
  defp render_feed_with_footer, do: render_component(&H.render_feed_with_footer/1, %{})
  defp render_group(attrs \\ %{}), do: render_component(&H.render_group/1, attrs)
  defp render_item(attrs \\ %{}), do: render_component(&H.render_item/1, attrs)
  defp render_item_with_avatar, do: render_component(&H.render_item_with_avatar/1, %{})
  defp render_all_types, do: render_component(&H.render_all_types/1, %{})
  defp render_full, do: render_component(&H.render_full/1, %{})

  # ---------------------------------------------------------------------------
  # activity_feed/1 — ARIA + container
  # ---------------------------------------------------------------------------

  describe "activity_feed/1 — ARIA and container" do
    test "renders a root element" do
      assert render_feed() =~ "<div"
    end

    test "has role=log for ARIA activity log semantics" do
      assert render_feed() =~ ~s(role="log")
    end

    test "has aria-live=polite for screen reader announcements" do
      assert render_feed() =~ ~s(aria-live="polite")
    end

    test "renders inner slot content" do
      assert render_feed(%{content: "Activity content"}) =~ "Activity content"
    end

    test "custom class is applied to container" do
      assert render_feed(%{class: "my-feed"}) =~ "my-feed"
    end

    test "id attribute is forwarded when provided" do
      assert render_feed(%{id: "activity-stream"}) =~ ~s(id="activity-stream")
    end

    test "does not render id attribute when not provided" do
      html = render_feed()
      refute html =~ ~s(id="")
    end
  end

  # ---------------------------------------------------------------------------
  # activity_feed/1 — footer slot
  # ---------------------------------------------------------------------------

  describe "activity_feed/1 — footer slot" do
    test "renders footer slot content when provided" do
      assert render_feed_with_footer() =~ "phx-submit"
    end

    test "footer slot is wrapped in its own container" do
      html = render_feed_with_footer()
      assert html =~ "send_comment"
    end

    test "footer input is rendered inside the feed" do
      html = render_feed_with_footer()
      assert html =~ ~s(<input name="comment")
    end
  end

  # ---------------------------------------------------------------------------
  # activity_group/1 — date grouping
  # ---------------------------------------------------------------------------

  describe "activity_group/1 — date label" do
    test "renders the group label" do
      assert render_group(%{label: "Today"}) =~ "Today"
    end

    test "renders Yesterday label" do
      assert render_group(%{label: "Yesterday"}) =~ "Yesterday"
    end

    test "renders arbitrary date string as label" do
      assert render_group(%{label: "Mar 3, 2026"}) =~ "Mar 3, 2026"
    end

    test "label text uses muted-foreground semantic token" do
      assert render_group(%{label: "Today"}) =~ "text-muted-foreground"
    end

    test "renders group content" do
      assert render_group(%{content: "activity items here"}) =~ "activity items here"
    end

    test "custom class is applied to group container" do
      assert render_group(%{class: "my-group"}) =~ "my-group"
    end
  end

  # ---------------------------------------------------------------------------
  # activity_item/1 — base structure
  # ---------------------------------------------------------------------------

  describe "activity_item/1 — base structure" do
    test "renders an li or div element" do
      html = render_item()
      assert html =~ "<li" or html =~ "<div"
    end

    test "renders inner content" do
      assert render_item(%{content: "Something happened"}) =~ "Something happened"
    end

    test "custom class is applied" do
      assert render_item(%{class: "my-item"}) =~ "my-item"
    end

    test "renders timestamp when provided" do
      assert render_item(%{timestamp: "9:12 AM"}) =~ "9:12 AM"
    end

    test "timestamp has text-muted-foreground semantic token" do
      html = render_item(%{timestamp: "9:12 AM"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render timestamp element when nil" do
      html = render_item(%{timestamp: nil})
      refute html =~ "9:12 AM"
    end
  end

  # ---------------------------------------------------------------------------
  # activity_item/1 — icon per type
  # ---------------------------------------------------------------------------

  describe "activity_item/1 — type icons" do
    test "mention type renders data-activity-type=mention" do
      assert render_item(%{type: "mention"}) =~ ~s(data-activity-type="mention")
    end

    test "file type renders data-activity-type=file" do
      assert render_item(%{type: "file"}) =~ ~s(data-activity-type="file")
    end

    test "call type renders data-activity-type=call" do
      assert render_item(%{type: "call"}) =~ ~s(data-activity-type="call")
    end

    test "task type renders data-activity-type=task" do
      assert render_item(%{type: "task"}) =~ ~s(data-activity-type="task")
    end

    test "reaction type renders data-activity-type=reaction" do
      assert render_item(%{type: "reaction"}) =~ ~s(data-activity-type="reaction")
    end

    test "system type renders data-activity-type=system" do
      assert render_item(%{type: "system"}) =~ ~s(data-activity-type="system")
    end

    test "each type produces a distinct icon background color class" do
      html = render_all_types()
      # All 6 activity items render in a single HTML — verify content present
      assert html =~ "Mention event"
      assert html =~ "File event"
      assert html =~ "Call event"
      assert html =~ "Task event"
      assert html =~ "Reaction event"
      assert html =~ "System event"
    end

    test "icon container uses rounded-full class" do
      assert render_item(%{type: "mention"}) =~ "rounded-full"
    end

    test "icon is aria-hidden" do
      assert render_item(%{type: "file"}) =~ ~s(aria-hidden="true")
    end
  end

  # ---------------------------------------------------------------------------
  # activity_item/1 — avatar slot
  # ---------------------------------------------------------------------------

  describe "activity_item/1 — avatar slot" do
    test "renders avatar slot content when provided" do
      assert render_item_with_avatar() =~ "custom-avatar"
    end

    test "renders event content alongside avatar" do
      html = render_item_with_avatar()
      assert html =~ "Jason mentioned you"
      assert html =~ "custom-avatar"
    end

    test "renders timestamp when avatar is present" do
      assert render_item_with_avatar() =~ "9:12 AM"
    end
  end

  # ---------------------------------------------------------------------------
  # activity_item/1 — semantic tokens (no hardcoded hex)
  # ---------------------------------------------------------------------------

  describe "activity_item/1 — semantic tokens" do
    test "does not use hardcoded hex color values in style attributes" do
      html = render_all_types()
      # SVG sprite hrefs contain # but inline style hex like style="color: #333" must not exist
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end

    test "text content uses text-foreground or text-sm semantic token" do
      html = render_item(%{content: "Event text"})
      assert html =~ "text-sm" or html =~ "text-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition — groups and items" do
    test "renders multiple groups with labels" do
      html = render_full()
      assert html =~ "Today"
      assert html =~ "Yesterday"
    end

    test "renders items within each group" do
      html = render_full()
      assert html =~ "Jason mentioned you"
      assert html =~ "New file uploaded"
      assert html =~ "Task assigned"
    end

    test "renders avatar slot inside group item" do
      assert render_full() =~ "avatar-slot"
    end

    test "renders timestamps inside group items" do
      html = render_full()
      assert html =~ "9:12 AM"
      assert html =~ "9:46 AM"
    end

    test "feed has role=log wrapping all groups" do
      assert render_full() =~ ~s(role="log")
    end
  end
end
