defmodule PhiaUi.Components.ButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper — wraps Button in a render-able function component.
  # render_component/2 returns the HTML string from a function component.
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Button

    attr :variant, :atom, default: :default
    attr :size, :atom, default: :default
    attr :class, :string, default: nil
    attr :disabled, :boolean, default: false

    def render_button(assigns) do
      ~H"""
      <.button variant={@variant} size={@size} class={@class} disabled={@disabled}>
        Click me
      </.button>
      """
    end

    def render_with_phx_click(assigns) do
      ~H"""
      <.button phx-click="save">Save</.button>
      """
    end

    def render_with_data_attr(assigns) do
      ~H"""
      <.button data-testid="my-btn">Click</.button>
      """
    end
  end

  defp render_button(attrs \\ %{}) do
    render_component(&H.render_button/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Variant tests
  # ---------------------------------------------------------------------------

  describe "variant :default" do
    test "renders bg-primary text-primary-foreground shadow" do
      html = render_button()
      assert html =~ "bg-primary"
      assert html =~ "text-primary-foreground"
      assert html =~ "shadow"
    end

    test "renders hover:bg-primary/90" do
      html = render_button()
      assert html =~ "hover:bg-primary/90"
    end
  end

  describe "variant :destructive" do
    test "renders bg-destructive text-destructive-foreground" do
      html = render_button(%{variant: :destructive})
      assert html =~ "bg-destructive"
      assert html =~ "text-destructive-foreground"
    end

    test "renders hover:bg-destructive/90" do
      html = render_button(%{variant: :destructive})
      assert html =~ "hover:bg-destructive/90"
    end
  end

  describe "variant :outline" do
    test "renders border border-input bg-background" do
      html = render_button(%{variant: :outline})
      assert html =~ "border-input"
      assert html =~ "bg-background"
    end

    test "renders hover:bg-accent hover:text-accent-foreground" do
      html = render_button(%{variant: :outline})
      assert html =~ "hover:bg-accent"
      assert html =~ "hover:text-accent-foreground"
    end
  end

  describe "variant :secondary" do
    test "renders bg-secondary text-secondary-foreground" do
      html = render_button(%{variant: :secondary})
      assert html =~ "bg-secondary"
      assert html =~ "text-secondary-foreground"
    end

    test "renders hover:bg-secondary/80" do
      html = render_button(%{variant: :secondary})
      assert html =~ "hover:bg-secondary/80"
    end
  end

  describe "variant :ghost" do
    test "renders hover:bg-accent hover:text-accent-foreground" do
      html = render_button(%{variant: :ghost})
      assert html =~ "hover:bg-accent"
      assert html =~ "hover:text-accent-foreground"
    end
  end

  describe "variant :link" do
    test "renders text-primary underline-offset-4 hover:underline" do
      html = render_button(%{variant: :link})
      assert html =~ "text-primary"
      assert html =~ "underline-offset-4"
      assert html =~ "hover:underline"
    end
  end

  # ---------------------------------------------------------------------------
  # Size tests
  # ---------------------------------------------------------------------------

  describe "size :default" do
    test "renders h-10 px-4 py-2" do
      html = render_button()
      assert html =~ "h-10"
      assert html =~ "px-4"
      assert html =~ "py-2"
    end
  end

  describe "size :sm" do
    test "renders h-9 px-3" do
      html = render_button(%{size: :sm})
      assert html =~ "h-9"
      assert html =~ "px-3"
    end
  end

  describe "size :lg" do
    test "renders h-11 px-8" do
      html = render_button(%{size: :lg})
      assert html =~ "h-11"
      assert html =~ "px-8"
    end
  end

  describe "size :icon" do
    test "renders h-10 w-10" do
      html = render_button(%{size: :icon})
      assert html =~ "h-10"
      assert html =~ "w-10"
    end
  end

  # ---------------------------------------------------------------------------
  # 24 variant × size combinations
  # ---------------------------------------------------------------------------

  describe "24 variant×size combinations render without error" do
    for v <- [:default, :destructive, :outline, :secondary, :ghost, :link],
        s <- [:default, :sm, :lg, :icon] do
      @v v
      @s s
      test "variant=#{v} size=#{s}" do
        html = render_component(&H.render_button/1, %{variant: @v, size: @s})
        assert html =~ "<button"
        assert html =~ "Click me"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # disabled state
  # ---------------------------------------------------------------------------

  describe "disabled state" do
    test "disabled=true adds pointer-events-none opacity-50" do
      html = render_button(%{disabled: true})
      assert html =~ "pointer-events-none"
      assert html =~ "opacity-50"
    end

    test "disabled=false does not add pointer-events-none" do
      html = render_button(%{disabled: false})
      refute html =~ "pointer-events-none"
    end

    test "disabled=true renders disabled HTML attribute" do
      html = render_button(%{disabled: true})
      assert html =~ "disabled"
    end
  end

  # ---------------------------------------------------------------------------
  # @rest passthrough
  # ---------------------------------------------------------------------------

  describe "@rest global attrs" do
    test "passes phx-click to the button element" do
      html = render_component(&H.render_with_phx_click/1, %{})
      assert html =~ ~s(phx-click="save")
    end

    test "passes data-testid to the button element" do
      html = render_component(&H.render_with_data_attr/1, %{})
      assert html =~ ~s(data-testid="my-btn")
    end
  end

  # ---------------------------------------------------------------------------
  # class override
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "adds custom class to the button" do
      html = render_button(%{class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # Renders inner_block slot
  # ---------------------------------------------------------------------------

  describe "inner_block slot" do
    test "renders text content inside the button" do
      html = render_button()
      assert html =~ "Click me"
    end
  end
end
