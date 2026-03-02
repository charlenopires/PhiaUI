defmodule PhiaUi.Components.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Badge

    attr :variant, :atom, default: :default
    attr :class, :string, default: nil

    def render_badge(assigns) do
      ~H"""
      <.badge variant={@variant} class={@class}>Label</.badge>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.badge data-testid="my-badge">Label</.badge>
      """
    end
  end

  defp render_badge(attrs \\ %{}) do
    render_component(&H.render_badge/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Base classes (present in every variant)
  # ---------------------------------------------------------------------------

  describe "base classes" do
    test "inline-flex" do
      assert render_badge() =~ "inline-flex"
    end

    test "items-center" do
      assert render_badge() =~ "items-center"
    end

    test "rounded-md" do
      assert render_badge() =~ "rounded-md"
    end

    test "border" do
      assert render_badge() =~ "border"
    end

    test "px-2.5 py-0.5" do
      html = render_badge()
      assert html =~ "px-2.5"
      assert html =~ "py-0.5"
    end

    test "text-xs font-semibold" do
      html = render_badge()
      assert html =~ "text-xs"
      assert html =~ "font-semibold"
    end

    test "transition-colors" do
      assert render_badge() =~ "transition-colors"
    end

    test "renders inner content" do
      assert render_badge() =~ "Label"
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "variant :default" do
    test "renders bg-primary" do
      assert render_badge(%{variant: :default}) =~ "bg-primary"
    end

    test "renders text-primary-foreground" do
      assert render_badge(%{variant: :default}) =~ "text-primary-foreground"
    end

    test "renders hover:bg-primary/80" do
      assert render_badge(%{variant: :default}) =~ "hover:bg-primary/80"
    end
  end

  describe "variant :secondary" do
    test "renders bg-secondary" do
      assert render_badge(%{variant: :secondary}) =~ "bg-secondary"
    end

    test "renders text-secondary-foreground" do
      assert render_badge(%{variant: :secondary}) =~ "text-secondary-foreground"
    end

    test "renders hover:bg-secondary/80" do
      assert render_badge(%{variant: :secondary}) =~ "hover:bg-secondary/80"
    end
  end

  describe "variant :destructive" do
    test "renders bg-destructive" do
      assert render_badge(%{variant: :destructive}) =~ "bg-destructive"
    end

    test "renders text-destructive-foreground" do
      assert render_badge(%{variant: :destructive}) =~ "text-destructive-foreground"
    end

    test "renders hover:bg-destructive/80" do
      assert render_badge(%{variant: :destructive}) =~ "hover:bg-destructive/80"
    end
  end

  describe "variant :outline" do
    test "renders text-foreground" do
      assert render_badge(%{variant: :outline}) =~ "text-foreground"
    end

    test "has border from base classes" do
      assert render_badge(%{variant: :outline}) =~ "border"
    end

    test "does not add a bg- color" do
      html = render_badge(%{variant: :outline})
      refute html =~ "bg-primary"
      refute html =~ "bg-secondary"
      refute html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # class override and @rest
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "adds custom class" do
      assert render_badge(%{class: "uppercase tracking-wide"}) =~ "uppercase"
    end
  end

  describe "@rest passthrough" do
    test "passes data-testid to the element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-badge")
    end
  end
end
