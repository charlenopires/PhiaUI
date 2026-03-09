defmodule PhiaUi.Components.ThumbnavTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Thumbnav

    def render_thumbnav(assigns) do
      ~H"""
      <.thumbnav
        orientation={assigns[:orientation] || :horizontal}
        gap={assigns[:gap] || :md}
        class={assigns[:class]}
      >
        <.thumbnav_item
          src={assigns[:src] || "/img/1.jpg"}
          alt={assigns[:alt] || "Photo 1"}
          active={assigns[:active] || false}
          on_click={assigns[:on_click]}
          value={assigns[:value]}
          width={assigns[:width] || "w-16"}
          height={assigns[:height] || "h-16"}
        />
      </.thumbnav>
      """
    end

    def render_thumbnav_with_link(assigns) do
      ~H"""
      <.thumbnav>
        <.thumbnav_item src="/img/1.jpg" href="/photo/1" active={true} />
      </.thumbnav>
      """
    end

    def render_multiple_items(assigns) do
      ~H"""
      <.thumbnav>
        <.thumbnav_item src="/img/1.jpg" active={true} on_click="select" value="0" />
        <.thumbnav_item src="/img/2.jpg" on_click="select" value="1" />
        <.thumbnav_item src="/img/3.jpg" on_click="select" value="2" />
      </.thumbnav>
      """
    end
  end

  defp render_thumbnav(attrs \\ %{}), do: render_component(&H.render_thumbnav/1, attrs)
  defp render_thumbnav_with_link, do: render_component(&H.render_thumbnav_with_link/1, %{})
  defp render_multiple_items, do: render_component(&H.render_multiple_items/1, %{})

  describe "thumbnav/1" do
    test "renders nav element with tablist role" do
      html = render_thumbnav()
      assert html =~ "<nav"
      assert html =~ "tablist"
    end

    test "default orientation is horizontal (flex-row)" do
      assert render_thumbnav() =~ "flex-row"
    end

    test "vertical orientation applies flex-col" do
      assert render_thumbnav(%{orientation: :vertical}) =~ "flex-col"
    end

    test "default gap is md (gap-2)" do
      assert render_thumbnav() =~ "gap-2"
    end

    test "custom class is applied" do
      assert render_thumbnav(%{class: "my-nav"}) =~ "my-nav"
    end
  end

  describe "thumbnav_item/1" do
    test "renders button by default" do
      html = render_thumbnav()
      assert html =~ "<button"
    end

    test "renders img with src" do
      html = render_thumbnav(%{src: "/img/test.jpg"})
      assert html =~ "/img/test.jpg"
    end

    test "active item has ring-2 ring-primary" do
      html = render_thumbnav(%{active: true})
      assert html =~ "ring-2"
      assert html =~ "ring-primary"
    end

    test "inactive item has opacity-70" do
      html = render_thumbnav(%{active: false})
      assert html =~ "opacity-70"
    end

    test "renders as link when href provided" do
      html = render_thumbnav_with_link()
      assert html =~ "<a"
      assert html =~ "/photo/1"
    end

    test "has tab role and aria-selected" do
      html = render_thumbnav(%{active: true})
      assert html =~ "tab"
      assert html =~ "aria-selected"
    end

    test "renders multiple items" do
      html = render_multiple_items()
      assert html =~ "/img/1.jpg"
      assert html =~ "/img/2.jpg"
      assert html =~ "/img/3.jpg"
    end
  end
end
