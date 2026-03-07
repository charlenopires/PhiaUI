defmodule PhiaUi.Components.TimelineTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TimelineTable

    def render_timeline(assigns) do
      ~H"""
      <.timeline_table>
        <.timeline_table_row title="Event A" timestamp="now" />
        <.timeline_table_row title="Event B" timestamp="1h ago" />
      </.timeline_table>
      """
    end

    attr(:title, :string, default: "Test Event")
    attr(:timestamp, :string, default: "now")
    attr(:icon, :string, default: "circle")
    attr(:icon_color, :atom, default: :default)
    attr(:description, :string, default: nil)
    attr(:user, :string, default: nil)

    def render_row(assigns) do
      ~H"""
      <ul>
        <.timeline_table_row
          title={@title}
          timestamp={@timestamp}
          icon={@icon}
          icon_color={@icon_color}
          description={@description}
          user={@user}
        />
      </ul>
      """
    end

    def render_row_with_slots(assigns) do
      ~H"""
      <ul>
        <.timeline_table_row title="Event" timestamp="now">
          <:meta><span class="badge">v1.0</span></:meta>
          <:detail><p>Detail content</p></:detail>
        </.timeline_table_row>
      </ul>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_table/1
  # ---------------------------------------------------------------------------

  describe "timeline_table/1" do
    test "renders div with flow-root" do
      html = render_component(&H.render_timeline/1, %{})
      assert html =~ "flow-root"
    end

    test "renders ul with role=list" do
      html = render_component(&H.render_timeline/1, %{})
      assert html =~ ~s(role="list")
    end

    test "renders inner rows" do
      html = render_component(&H.render_timeline/1, %{})
      assert html =~ "Event A"
      assert html =~ "Event B"
    end

    test "has divide-y styling" do
      html = render_component(&H.render_timeline/1, %{})
      assert html =~ "divide-y"
    end
  end

  # ---------------------------------------------------------------------------
  # timeline_table_row/1
  # ---------------------------------------------------------------------------

  describe "timeline_table_row/1" do
    test "renders li element" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "<li"
    end

    test "renders title" do
      html = render_component(&H.render_row/1, %{title: "My Event"})
      assert html =~ "My Event"
    end

    test "renders timestamp" do
      html = render_component(&H.render_row/1, %{timestamp: "2 hours ago"})
      assert html =~ "2 hours ago"
    end

    test "renders description when provided" do
      html = render_component(&H.render_row/1, %{description: "Some detail"})
      assert html =~ "Some detail"
    end

    test "does not render description when nil" do
      html = render_component(&H.render_row/1, %{description: nil})
      refute html =~ "Some detail"
    end

    test "renders user when provided" do
      html = render_component(&H.render_row/1, %{user: "Alice"})
      assert html =~ "Alice"
    end

    test "does not render user when nil" do
      html = render_component(&H.render_row/1, %{user: nil})
      refute html =~ "by "
    end

    test "applies primary icon color class" do
      html = render_component(&H.render_row/1, %{icon_color: :primary})
      assert html =~ "bg-primary/10"
      assert html =~ "text-primary"
    end

    test "applies success icon color class" do
      html = render_component(&H.render_row/1, %{icon_color: :success})
      assert html =~ "bg-green-500/10"
      assert html =~ "text-green-600"
    end

    test "applies warning icon color class" do
      html = render_component(&H.render_row/1, %{icon_color: :warning})
      assert html =~ "bg-amber-500/10"
      assert html =~ "text-amber-600"
    end

    test "applies destructive icon color class" do
      html = render_component(&H.render_row/1, %{icon_color: :destructive})
      assert html =~ "bg-destructive/10"
      assert html =~ "text-destructive"
    end

    test "applies default icon color class" do
      html = render_component(&H.render_row/1, %{icon_color: :default})
      assert html =~ "bg-muted"
      assert html =~ "text-muted-foreground"
    end

    test "renders meta slot" do
      html = render_component(&H.render_row_with_slots/1, %{})
      assert html =~ "v1.0"
    end

    test "renders detail slot" do
      html = render_component(&H.render_row_with_slots/1, %{})
      assert html =~ "Detail content"
    end
  end
end
