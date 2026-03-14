defmodule PhiaUi.Components.ItemTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Item

    def render_default(assigns) do
      ~H"""
      <.item>
        <.item_title>John Doe</.item_title>
        <.item_description>Software Engineer</.item_description>
      </.item>
      """
    end

    def render_with_media(assigns) do
      ~H"""
      <.item>
        <:media>
          <span class="avatar-placeholder">JD</span>
        </:media>
        <.item_title>John Doe</.item_title>
      </.item>
      """
    end

    def render_with_trailing(assigns) do
      ~H"""
      <.item>
        <.item_title>Settings</.item_title>
        <:trailing>
          <span class="trailing-icon">></span>
        </:trailing>
      </.item>
      """
    end

    def render_with_media_and_trailing(assigns) do
      ~H"""
      <.item>
        <:media>
          <span class="avatar">A</span>
        </:media>
        <.item_title>Full Item</.item_title>
        <.item_description>With all slots</.item_description>
        <:trailing>
          <span class="badge">New</span>
        </:trailing>
      </.item>
      """
    end

    def render_outline(assigns) do
      ~H"""
      <.item variant={:outline}>
        <.item_title>Outlined</.item_title>
      </.item>
      """
    end

    def render_muted(assigns) do
      ~H"""
      <.item variant={:muted}>
        <.item_title>Muted</.item_title>
      </.item>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.item href="/profile">
        <.item_title>Profile</.item_title>
      </.item>
      """
    end

    def render_with_navigate(assigns) do
      ~H"""
      <.item navigate="/users/42">
        <.item_title>View User</.item_title>
      </.item>
      """
    end

    def render_with_patch(assigns) do
      ~H"""
      <.item patch="/settings?tab=profile">
        <.item_title>Profile Tab</.item_title>
      </.item>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.item class="my-custom-class">
        <.item_title>Classy</.item_title>
      </.item>
      """
    end

    def render_title_with_class(assigns) do
      ~H"""
      <.item>
        <.item_title class="text-lg">Big Title</.item_title>
      </.item>
      """
    end

    def render_description_with_class(assigns) do
      ~H"""
      <.item>
        <.item_title>Title</.item_title>
        <.item_description class="text-xs">Small desc</.item_description>
      </.item>
      """
    end
  end

  describe "item/1 basics" do
    test "renders as a div by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
      assert html =~ "John Doe"
      assert html =~ "Software Engineer"
    end

    test "renders media slot" do
      html = render_component(&H.render_with_media/1, %{})
      assert html =~ "avatar-placeholder"
      assert html =~ "JD"
      assert html =~ "flex-shrink-0"
    end

    test "renders trailing slot" do
      html = render_component(&H.render_with_trailing/1, %{})
      assert html =~ "trailing-icon"
    end

    test "renders all slots together" do
      html = render_component(&H.render_with_media_and_trailing/1, %{})
      assert html =~ "avatar"
      assert html =~ "Full Item"
      assert html =~ "With all slots"
      assert html =~ "badge"
    end

    test "has flex layout classes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "flex items-center gap-3"
    end
  end

  describe "item/1 variants" do
    test "outline variant has border" do
      html = render_component(&H.render_outline/1, %{})
      assert html =~ "border-border"
    end

    test "muted variant has bg-muted" do
      html = render_component(&H.render_muted/1, %{})
      assert html =~ "bg-muted/50"
    end
  end

  describe "item/1 links" do
    test "renders as anchor when href is set" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ "href=\"/profile\""
      assert html =~ "hover:bg-accent"
      assert html =~ "cursor-pointer"
    end

    test "renders as link when navigate is set" do
      html = render_component(&H.render_with_navigate/1, %{})
      assert html =~ "href=\"/users/42\""
      assert html =~ "data-phx-link"
      assert html =~ "hover:bg-accent"
    end

    test "renders as link when patch is set" do
      html = render_component(&H.render_with_patch/1, %{})
      assert html =~ "href=\"/settings?tab=profile\""
      assert html =~ "data-phx-link"
      assert html =~ "hover:bg-accent"
    end

    test "div item does not have cursor-pointer" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "cursor-pointer"
    end
  end

  describe "item/1 class merging" do
    test "merges custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-custom-class"
    end
  end

  describe "item_title/1" do
    test "renders with font-medium" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "font-medium"
      assert html =~ "John Doe"
    end

    test "merges custom class" do
      html = render_component(&H.render_title_with_class/1, %{})
      assert html =~ "text-lg"
      assert html =~ "Big Title"
    end
  end

  describe "item_description/1" do
    test "renders with muted foreground" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-muted-foreground"
      assert html =~ "Software Engineer"
    end

    test "has line-clamp-1" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "line-clamp-1"
    end

    test "merges custom class" do
      html = render_component(&H.render_description_with_class/1, %{})
      assert html =~ "text-xs"
      assert html =~ "Small desc"
    end
  end
end
