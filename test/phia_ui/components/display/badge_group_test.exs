defmodule PhiaUi.Components.BadgeGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BadgeGroup

    attr :variant, :atom, default: :default
    attr :size, :atom, default: :default
    attr :class, :string, default: nil

    def render_badge_group(assigns) do
      ~H"""
      <.badge_group variant={@variant} size={@size} class={@class}>
        <:badge>New</:badge>
        Check out our latest feature
      </.badge_group>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.badge_group data-testid="my-badge-group">
        <:badge>Beta</:badge>
        Description text
      </.badge_group>
      """
    end
  end

  defp render_badge_group(attrs \\ %{}) do
    render_component(&H.render_badge_group/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Base classes (present in every variant)
  # ---------------------------------------------------------------------------

  describe "base classes" do
    test "inline-flex" do
      assert render_badge_group() =~ "inline-flex"
    end

    test "items-center" do
      assert render_badge_group() =~ "items-center"
    end

    test "rounded-full" do
      assert render_badge_group() =~ "rounded-full"
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "variant :default" do
    test "renders border-border" do
      assert render_badge_group(%{variant: :default}) =~ "border-border"
    end

    test "renders bg-muted/50" do
      assert render_badge_group(%{variant: :default}) =~ "bg-muted/50"
    end
  end

  describe "variant :outline" do
    test "renders bg-transparent" do
      assert render_badge_group(%{variant: :outline}) =~ "bg-transparent"
    end

    test "renders border-border" do
      assert render_badge_group(%{variant: :outline}) =~ "border-border"
    end
  end

  describe "variant :ghost" do
    test "renders bg-muted/30" do
      assert render_badge_group(%{variant: :ghost}) =~ "bg-muted/30"
    end

    test "does not render border-border" do
      refute render_badge_group(%{variant: :ghost}) =~ "border-border"
    end
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  describe "badge slot" do
    test "renders badge content with bg-primary" do
      html = render_badge_group()
      assert html =~ "bg-primary"
      assert html =~ "New"
    end

    test "badge span has font-semibold" do
      assert render_badge_group() =~ "font-semibold"
    end
  end

  describe "inner block" do
    test "renders description text" do
      assert render_badge_group() =~ "Check out our latest feature"
    end

    test "description has text-muted-foreground" do
      assert render_badge_group() =~ "text-muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # Sizes
  # ---------------------------------------------------------------------------

  describe "size :sm" do
    test "renders text-xs on badge" do
      html = render_badge_group(%{size: :sm})
      assert html =~ "text-xs"
    end

    test "renders gap-2" do
      assert render_badge_group(%{size: :sm}) =~ "gap-2"
    end
  end

  # ---------------------------------------------------------------------------
  # Class override and @rest
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "adds custom class" do
      assert render_badge_group(%{class: "my-custom-class"}) =~ "my-custom-class"
    end
  end

  describe "@rest passthrough" do
    test "passes data-testid to the element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-badge-group")
    end
  end
end
