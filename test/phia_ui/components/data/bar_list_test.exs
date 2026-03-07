defmodule PhiaUi.Components.BarListTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BarList

    def render_basic(assigns) do
      ~H"""
      <.bar_list data={[
        %{name: "Direct", value: 100},
        %{name: "Referral", value: 50},
        %{name: "Organic", value: 25}
      ]} />
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.bar_list data={[%{name: "Google", value: 200, href: "https://example.com"}]} />
      """
    end

    def render_with_formatter(assigns) do
      ~H"""
      <.bar_list
        data={[%{name: "Sales", value: 1234}]}
        value_formatter={fn v -> "$#{v}" end}
      />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.bar_list data={[%{name: "Items", value: 10}]} color="bg-blue-500" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.bar_list data={[%{name: "A", value: 1}]} class="my-bar-list" />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.bar_list data={[]} />
      """
    end
  end

  describe "bar_list/1" do
    test "renders a container div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders item names" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Direct"
      assert html =~ "Referral"
      assert html =~ "Organic"
    end

    test "first item (max) has 100.0% width" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "width: 100.0%"
    end

    test "second item has proportional width" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "width: 50.0%"
    end

    test "renders href as anchor link" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ "href"
    end

    test "item without href renders as plain text" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "<a"
    end

    test "value formatter is applied" do
      html = render_component(&H.render_with_formatter/1, %{})
      assert html =~ "$1234"
    end

    test "custom color class is applied to bar" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "bg-blue-500"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-bar-list"
    end

    test "empty data renders container without items" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<div"
    end
  end
end
