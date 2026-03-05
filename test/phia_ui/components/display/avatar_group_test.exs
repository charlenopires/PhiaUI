defmodule PhiaUi.Components.AvatarGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AvatarGroup

    def render_basic(assigns) do
      ~H"""
      <.avatar_group>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
      </.avatar_group>
      """
    end

    def render_no_overflow(assigns) do
      ~H"""
      <.avatar_group max={3}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
      </.avatar_group>
      """
    end

    def render_with_overflow(assigns) do
      ~H"""
      <.avatar_group max={2}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
        <:item src="/d.jpg" name="Dave" />
      </.avatar_group>
      """
    end

    def render_max_one(assigns) do
      ~H"""
      <.avatar_group max={1}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end

    def render_size_sm(assigns) do
      ~H"""
      <.avatar_group size="sm">
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end

    def render_size_default(assigns) do
      ~H"""
      <.avatar_group size="default">
        <:item src="/a.jpg" name="Alice" />
      </.avatar_group>
      """
    end

    def render_size_lg(assigns) do
      ~H"""
      <.avatar_group size="lg">
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end

    def render_size_xl(assigns) do
      ~H"""
      <.avatar_group size="xl">
        <:item src="/a.jpg" name="Alice" />
      </.avatar_group>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.avatar_group class="my-group-class">
        <:item src="/a.jpg" name="Alice" />
      </.avatar_group>
      """
    end

    def render_without_src(assigns) do
      ~H"""
      <.avatar_group>
        <:item name="Alice" />
        <:item name="Bob" />
      </.avatar_group>
      """
    end

    def render_overflow_size_sm(assigns) do
      ~H"""
      <.avatar_group size="sm" max={1}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
      </.avatar_group>
      """
    end

    def render_overflow_size_lg(assigns) do
      ~H"""
      <.avatar_group size="lg" max={1}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end

    def render_overflow_size_xl(assigns) do
      ~H"""
      <.avatar_group size="xl" max={1}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end

    def render_single_item(assigns) do
      ~H"""
      <.avatar_group>
        <:item src="/a.jpg" name="Alice" />
      </.avatar_group>
      """
    end

    def render_exact_max(assigns) do
      ~H"""
      <.avatar_group max={2}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
      </.avatar_group>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # avatar_group/1
  # ---------------------------------------------------------------------------

  describe "avatar_group/1" do
    test "renders a div container" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "container has role=list" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="list")
    end

    test "container has flex class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "flex"
    end

    test "container has negative space class for overlap" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "-space-x-2"
    end

    test "each visible item is wrapped with role=listitem" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="listitem")
    end

    test "renders all items when count is within max" do
      html = render_component(&H.render_no_overflow/1, %{})
      assert html =~ "Alice"
      assert html =~ "Bob"
      assert html =~ "Carol"
    end

    test "no overflow badge when items equal max" do
      html = render_component(&H.render_exact_max/1, %{})
      refute html =~ "+0"
      refute html =~ "+"
    end

    test "no overflow badge when count is within default max of 5" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "+"
    end

    test "renders only max visible items when items exceed max" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "Alice"
      assert html =~ "Bob"
      refute html =~ "Carol"
      refute html =~ "Dave"
    end

    test "renders overflow badge when items exceed max" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "+2"
    end

    test "overflow badge role=listitem" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ ~s(role="listitem")
    end

    test "max=1 with 2 items shows overflow +1" do
      html = render_component(&H.render_max_one/1, %{})
      assert html =~ "+1"
      assert html =~ "Alice"
      refute html =~ "Bob"
    end

    test "overflow badge has rounded-full class" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "rounded-full"
    end

    test "overflow badge has ring-2 class" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "ring-2"
    end

    test "overflow badge has bg-muted class" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "bg-muted"
    end

    test "overflow badge has text-muted-foreground class" do
      html = render_component(&H.render_with_overflow/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "single item renders without overflow" do
      html = render_component(&H.render_single_item/1, %{})
      refute html =~ "+"
    end

    test "slot item with src renders img element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<img"
    end

    test "slot item with src includes correct src attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(src="/a.jpg")
    end

    test "slot item without src does not render img" do
      html = render_component(&H.render_without_src/1, %{})
      refute html =~ "<img"
    end

    test "slot item without src shows fallback only" do
      html = render_component(&H.render_without_src/1, %{})
      assert html =~ "data-avatar-fallback"
    end

    test "avatar items have ring-2 class for separation" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "ring-2"
    end

    test "avatar items have ring-background class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "ring-background"
    end

    test "size sm applies h-6 w-6 to avatars" do
      html = render_component(&H.render_size_sm/1, %{})
      assert html =~ "h-6"
      assert html =~ "w-6"
    end

    test "size default applies h-10 w-10 to avatars" do
      html = render_component(&H.render_size_default/1, %{})
      assert html =~ "h-10"
      assert html =~ "w-10"
    end

    test "size lg applies h-14 w-14 to avatars" do
      html = render_component(&H.render_size_lg/1, %{})
      assert html =~ "h-14"
      assert html =~ "w-14"
    end

    test "size xl applies h-18 w-18 to avatars" do
      html = render_component(&H.render_size_xl/1, %{})
      assert html =~ "h-18"
      assert html =~ "w-18"
    end

    test "overflow badge size sm applies h-6 w-6 and text-xs" do
      html = render_component(&H.render_overflow_size_sm/1, %{})
      assert html =~ "text-xs"
    end

    test "overflow badge size lg applies text-sm" do
      html = render_component(&H.render_overflow_size_lg/1, %{})
      assert html =~ "text-sm"
    end

    test "overflow badge size xl applies text-base" do
      html = render_component(&H.render_overflow_size_xl/1, %{})
      assert html =~ "text-base"
    end

    test "custom class is applied to container" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-group-class"
    end

    test "items-center class present on container" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "items-center"
    end
  end
end
