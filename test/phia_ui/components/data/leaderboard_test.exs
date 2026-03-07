defmodule PhiaUi.Components.LeaderboardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Leaderboard

    def render_basic(assigns) do
      ~H"""
      <.leaderboard items={[
        %{rank: 1, name: "Alice",   metric: "9,842 pts"},
        %{rank: 2, name: "Bob",     metric: "8,120 pts"},
        %{rank: 3, name: "Charlie", metric: "7,654 pts"},
        %{rank: 4, name: "Dana",    metric: "6,200 pts"}
      ]} />
      """
    end

    def render_with_delta(assigns) do
      ~H"""
      <.leaderboard items={[
        %{rank: 1, name: "Eve", metric: "5,000 pts", delta: "+10%", delta_type: :increase}
      ]} />
      """
    end

    def render_with_avatar(assigns) do
      ~H"""
      <.leaderboard items={[
        %{rank: 1, name: "Fiona", metric: "3,000 pts", avatar_src: "/img/avatar.jpg"}
      ]} />
      """
    end

    def render_sm_size(assigns) do
      ~H"""
      <.leaderboard items={[%{rank: 1, name: "A", metric: "100"}]} size={:sm} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.leaderboard items={[%{rank: 1, name: "A", metric: "100"}]} class="my-board" />
      """
    end
  end

  describe "leaderboard/1" do
    test "renders an ol element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<ol"
    end

    test "rank 1 has gold badge class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-yellow-400"
    end

    test "rank 2 has silver badge class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-gray-300"
    end

    test "rank 3 has bronze badge class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-amber-600"
    end

    test "rank 4+ has muted badge class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-muted"
    end

    test "renders names" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "renders metric values" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "9,842 pts"
    end

    test "renders badge_delta when delta and delta_type present" do
      html = render_component(&H.render_with_delta/1, %{})
      assert html =~ "+10%"
      assert html =~ "bg-green-100"
    end

    test "renders avatar image when avatar_src present" do
      html = render_component(&H.render_with_avatar/1, %{})
      assert html =~ "<img"
      assert html =~ "/img/avatar.jpg"
    end

    test "renders initials fallback when no avatar_src" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "A"
    end

    test ":sm size uses py-2" do
      html = render_component(&H.render_sm_size/1, %{})
      assert html =~ "py-2"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-board"
    end
  end
end
