defmodule PhiaUi.Components.BadgeDeltaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BadgeDelta

    def render_increase(assigns) do
      ~H"""
      <.badge_delta value="+12%" delta_type={:increase} />
      """
    end

    def render_decrease(assigns) do
      ~H"""
      <.badge_delta value="-5%" delta_type={:decrease} />
      """
    end

    def render_unchanged(assigns) do
      ~H"""
      <.badge_delta value="0%" delta_type={:unchanged} />
      """
    end

    def render_moderate_increase(assigns) do
      ~H"""
      <.badge_delta value="+3%" delta_type={:moderate_increase} />
      """
    end

    def render_moderate_decrease(assigns) do
      ~H"""
      <.badge_delta value="-3%" delta_type={:moderate_decrease} />
      """
    end

    def render_xs(assigns) do
      ~H"""
      <.badge_delta value="+1%" delta_type={:increase} size={:xs} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.badge_delta value="+1%" delta_type={:increase} size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.badge_delta value="+1%" delta_type={:increase} size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.badge_delta value="+1%" delta_type={:increase} class="my-custom" />
      """
    end

    def render_default(assigns) do
      ~H"""
      <.badge_delta value="—" />
      """
    end
  end

  describe "badge_delta/1" do
    test "renders a span element" do
      html = render_component(&H.render_increase/1, %{})
      assert html =~ "<span"
    end

    test ":increase has green background" do
      html = render_component(&H.render_increase/1, %{})
      assert html =~ "bg-green-100"
      assert html =~ "text-green-700"
    end

    test ":decrease has red background" do
      html = render_component(&H.render_decrease/1, %{})
      assert html =~ "bg-red-100"
      assert html =~ "text-red-700"
    end

    test ":unchanged has gray background" do
      html = render_component(&H.render_unchanged/1, %{})
      assert html =~ "bg-gray-100"
      assert html =~ "text-gray-600"
    end

    test ":moderate_increase has amber background" do
      html = render_component(&H.render_moderate_increase/1, %{})
      assert html =~ "bg-amber-100"
      assert html =~ "text-amber-700"
    end

    test ":moderate_decrease has orange background" do
      html = render_component(&H.render_moderate_decrease/1, %{})
      assert html =~ "bg-orange-100"
      assert html =~ "text-orange-700"
    end

    test ":increase renders arrow-up icon" do
      html = render_component(&H.render_increase/1, %{})
      assert html =~ "arrow-up"
    end

    test ":decrease renders arrow-down icon" do
      html = render_component(&H.render_decrease/1, %{})
      assert html =~ "arrow-down"
    end

    test ":unchanged renders minus icon" do
      html = render_component(&H.render_unchanged/1, %{})
      assert html =~ "minus"
    end

    test ":moderate_increase renders trending-up icon" do
      html = render_component(&H.render_moderate_increase/1, %{})
      assert html =~ "trending-up"
    end

    test ":moderate_decrease renders trending-down icon" do
      html = render_component(&H.render_moderate_decrease/1, %{})
      assert html =~ "trending-down"
    end

    test "value text is rendered" do
      html = render_component(&H.render_increase/1, %{})
      assert html =~ "+12%"
    end

    test ":xs size has px-1.5 class" do
      html = render_component(&H.render_xs/1, %{})
      assert html =~ "px-1.5"
    end

    test ":lg size has px-3 class" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "px-3"
    end

    test "custom class is applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-custom"
    end

    test "default delta_type renders (unchanged)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-gray-100"
    end
  end
end
