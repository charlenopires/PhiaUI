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

    attr(:variant, :atom, default: :default)
    attr(:size, :atom, default: :default)
    attr(:class, :string, default: nil)
    attr(:disabled, :boolean, default: false)

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

    def render_xs(assigns) do
      ~H"""
      <.button size={:xs}>XS Button</.button>
      """
    end

    def render_icon_sm(assigns) do
      ~H"""
      <.button size={:icon_sm} aria-label="small icon">✕</.button>
      """
    end

    def render_icon_lg(assigns) do
      ~H"""
      <.button size={:icon_lg} aria-label="large icon">✕</.button>
      """
    end

    def render_left_icon(assigns) do
      ~H"""
      <.button>
        <:left_icon>→</:left_icon>
        With icon
      </.button>
      """
    end

    def render_right_icon(assigns) do
      ~H"""
      <.button>
        With icon
        <:right_icon>←</:right_icon>
      </.button>
      """
    end

    def render_both_icons(assigns) do
      ~H"""
      <.button>
        <:left_icon>→</:left_icon>
        With icons
        <:right_icon>←</:right_icon>
      </.button>
      """
    end

    def render_loading(assigns) do
      ~H"""
      <.button loading={true}>Save</.button>
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

  # ---------------------------------------------------------------------------
  # size :xs
  # ---------------------------------------------------------------------------

  describe "size :xs" do
    test "has h-7 class" do
      html = render_component(&H.render_xs/1, %{})
      assert html =~ "h-7"
    end

    test "has px-2 class" do
      html = render_component(&H.render_xs/1, %{})
      assert html =~ "px-2"
    end

    test "has text-xs class" do
      html = render_component(&H.render_xs/1, %{})
      assert html =~ "text-xs"
    end
  end

  # ---------------------------------------------------------------------------
  # size :icon_sm
  # ---------------------------------------------------------------------------

  describe "size :icon_sm" do
    test "has h-8 class" do
      html = render_component(&H.render_icon_sm/1, %{})
      assert html =~ "h-8"
    end

    test "has w-8 class" do
      html = render_component(&H.render_icon_sm/1, %{})
      assert html =~ "w-8"
    end
  end

  # ---------------------------------------------------------------------------
  # size :icon_lg
  # ---------------------------------------------------------------------------

  describe "size :icon_lg" do
    test "has h-12 class" do
      html = render_component(&H.render_icon_lg/1, %{})
      assert html =~ "h-12"
    end

    test "has w-12 class" do
      html = render_component(&H.render_icon_lg/1, %{})
      assert html =~ "w-12"
    end
  end

  # ---------------------------------------------------------------------------
  # left_icon slot
  # ---------------------------------------------------------------------------

  describe "left_icon slot" do
    test "renders icon content" do
      html = render_component(&H.render_left_icon/1, %{})
      assert html =~ "→"
    end

    test "renders label content alongside icon" do
      html = render_component(&H.render_left_icon/1, %{})
      assert html =~ "With icon"
    end

    test "adds gap-2 class to button when left_icon is provided" do
      html = render_component(&H.render_left_icon/1, %{})
      assert html =~ "gap-2"
    end
  end

  # ---------------------------------------------------------------------------
  # right_icon slot
  # ---------------------------------------------------------------------------

  describe "right_icon slot" do
    test "renders icon content" do
      html = render_component(&H.render_right_icon/1, %{})
      assert html =~ "←"
    end

    test "renders label content alongside icon" do
      html = render_component(&H.render_right_icon/1, %{})
      assert html =~ "With icon"
    end

    test "adds gap-2 class to button when right_icon is provided" do
      html = render_component(&H.render_right_icon/1, %{})
      assert html =~ "gap-2"
    end
  end

  describe "both icon slots" do
    test "renders both icons and label" do
      html = render_component(&H.render_both_icons/1, %{})
      assert html =~ "→"
      assert html =~ "←"
      assert html =~ "With icons"
    end

    test "no gap-2 on button without any icon slot" do
      html = render_button()
      refute html =~ "gap-2"
    end
  end

  # ---------------------------------------------------------------------------
  # loading state
  # ---------------------------------------------------------------------------

  describe "loading state" do
    test "loading=true renders an animate-spin spinner" do
      html = render_component(&H.render_loading/1, %{})
      assert html =~ "animate-spin"
    end

    test "loading=true adds pointer-events-none" do
      html = render_component(&H.render_loading/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "loading=true sets aria-busy=true" do
      html = render_component(&H.render_loading/1, %{})
      assert html =~ ~s(aria-busy="true")
    end

    test "loading=false (default) has no spinner" do
      html = render_button()
      refute html =~ "animate-spin"
    end

    test "loading=false has no aria-busy" do
      html = render_button()
      refute html =~ "aria-busy"
    end
  end
end
