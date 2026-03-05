defmodule PhiaUi.Components.StatCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.StatCard

    attr(:title, :string, default: "Revenue")
    attr(:value, :string, default: "$12,345")
    attr(:trend, :atom, default: :neutral)
    attr(:trend_value, :string, default: nil)
    attr(:description, :string, default: nil)
    attr(:class, :string, default: nil)

    def render_stat_card(assigns) do
      ~H"""
      <.stat_card
        title={@title}
        value={@value}
        trend={@trend}
        trend_value={@trend_value}
        description={@description}
        class={@class}
      />
      """
    end

    attr(:title, :string, default: "Revenue")
    attr(:value, :string, default: "$12,345")

    def render_with_footer(assigns) do
      ~H"""
      <.stat_card title={@title} value={@value}>
        <:footer>Updated 2 min ago</:footer>
      </.stat_card>
      """
    end

    attr(:title, :string, default: "Revenue")
    attr(:value, :string, default: "$12,345")

    def render_with_icon(assigns) do
      ~H"""
      <.stat_card title={@title} value={@value}>
        <:icon>$</:icon>
      </.stat_card>
      """
    end
  end

  defp render_stat_card(attrs \\ %{}) do
    render_component(&H.render_stat_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # stat_card/1 — basic rendering
  # ---------------------------------------------------------------------------

  describe "stat_card/1 basic rendering" do
    test "renders a card wrapper" do
      html = render_stat_card()
      assert html =~ "<div"
    end

    test "renders the title" do
      html = render_stat_card(%{title: "Total Revenue"})
      assert html =~ "Total Revenue"
    end

    test "renders the value" do
      html = render_stat_card(%{value: "$99,999"})
      assert html =~ "$99,999"
    end

    test "value is displayed prominently (text-2xl font-bold)" do
      html = render_stat_card(%{value: "$1,000"})
      assert html =~ "text-2xl"
      assert html =~ "font-bold"
    end

    test "title has text-sm styling" do
      html = render_stat_card(%{title: "Revenue"})
      assert html =~ "text-sm"
    end

    test "accepts custom class" do
      html = render_stat_card(%{class: "my-custom"})
      assert html =~ "my-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # Trend — up
  # ---------------------------------------------------------------------------

  describe "stat_card/1 trend :up" do
    test "renders trend_value when provided" do
      html = render_stat_card(%{trend: :up, trend_value: "+12%"})
      assert html =~ "+12%"
    end

    test "up trend uses default badge variant (positive)" do
      html = render_stat_card(%{trend: :up, trend_value: "+5%"})
      # Badge with :default variant has bg-primary
      assert html =~ "bg-primary"
    end

    test "up trend shows trending-up svg icon instead of Unicode ↑" do
      html = render_stat_card(%{trend: :up, trend_value: "+5%"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-trending-up")
      refute html =~ "↑"
    end
  end

  # ---------------------------------------------------------------------------
  # Trend — down
  # ---------------------------------------------------------------------------

  describe "stat_card/1 trend :down" do
    test "renders trend_value for down trend" do
      html = render_stat_card(%{trend: :down, trend_value: "-3%"})
      assert html =~ "-3%"
    end

    test "down trend uses destructive badge variant" do
      html = render_stat_card(%{trend: :down, trend_value: "-3%"})
      assert html =~ "bg-destructive"
    end

    test "down trend shows trending-down svg icon instead of Unicode ↓" do
      html = render_stat_card(%{trend: :down, trend_value: "-3%"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-trending-down")
      refute html =~ "↓"
    end
  end

  # ---------------------------------------------------------------------------
  # Trend — neutral
  # ---------------------------------------------------------------------------

  describe "stat_card/1 trend :neutral" do
    test "renders trend_value for neutral trend" do
      html = render_stat_card(%{trend: :neutral, trend_value: "0%"})
      assert html =~ "0%"
    end

    test "neutral trend uses secondary badge variant" do
      html = render_stat_card(%{trend: :neutral, trend_value: "0%"})
      assert html =~ "bg-secondary"
    end

    test "neutral trend shows minus svg icon instead of Unicode →" do
      html = render_stat_card(%{trend: :neutral, trend_value: "0%"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-minus")
      refute html =~ "→"
    end

    test "no badge rendered when trend_value is nil" do
      html = render_stat_card(%{trend: :neutral, trend_value: nil})
      refute html =~ "bg-secondary"
      refute html =~ "bg-primary"
      refute html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Description
  # ---------------------------------------------------------------------------

  describe "stat_card/1 description" do
    test "renders description when provided" do
      html = render_stat_card(%{description: "vs. last month"})
      assert html =~ "vs. last month"
    end

    test "description has muted-foreground styling" do
      html = render_stat_card(%{description: "hint"})
      assert html =~ "text-muted-foreground"
    end

    test "no description element when nil" do
      html = render_stat_card()
      # Should not have description paragraph when not set
      refute html =~ "vs."
    end
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  describe "stat_card/1 :footer slot" do
    test "renders footer slot content" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "Updated 2 min ago"
    end

    test "does not render footer area when slot is empty" do
      html = render_stat_card()
      refute html =~ "Updated"
    end
  end

  describe "stat_card/1 :icon slot" do
    test "renders icon slot content" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "$"
    end
  end
end
