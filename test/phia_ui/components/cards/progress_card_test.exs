defmodule PhiaUi.Components.ProgressCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ProgressCard

    attr(:title, :string, default: "Loading")
    attr(:value, :integer, default: 50)
    attr(:description, :string, default: nil)
    attr(:label, :string, default: nil)
    attr(:variant, :atom, default: :default)
    attr(:size, :atom, default: :md)
    attr(:show_value, :boolean, default: true)
    attr(:class, :string, default: nil)

    def render_progress_card(assigns) do
      ~H"""
      <.progress_card
        title={@title}
        value={@value}
        description={@description}
        label={@label}
        variant={@variant}
        size={@size}
        show_value={@show_value}
        class={@class}
      />
      """
    end

    attr(:title, :string, default: "Loading")
    attr(:value, :integer, default: 50)

    def render_with_icon(assigns) do
      ~H"""
      <.progress_card title={@title} value={@value}>
        <:icon>★</:icon>
      </.progress_card>
      """
    end

    attr(:title, :string, default: "Loading")
    attr(:value, :integer, default: 50)

    def render_with_footer(assigns) do
      ~H"""
      <.progress_card title={@title} value={@value}>
        <:footer>Step 1 of 4</:footer>
      </.progress_card>
      """
    end
  end

  defp render_progress_card(attrs \\ %{}) do
    render_component(&H.render_progress_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "progress_card/1 basic rendering" do
    test "renders a card wrapper" do
      html = render_progress_card()
      assert html =~ "<div"
    end

    test "renders the title" do
      html = render_progress_card(%{title: "Upload Progress"})
      assert html =~ "Upload Progress"
    end

    test "renders the value percentage label by default" do
      html = render_progress_card(%{value: 72})
      assert html =~ "72%"
    end

    test "renders a progress bar element" do
      html = render_progress_card(%{value: 50})
      assert html =~ ~s(role="progressbar")
    end

    test "progress bar reflects the value" do
      html = render_progress_card(%{value: 80})
      assert html =~ ~s(aria-valuenow="80")
    end
  end

  # ---------------------------------------------------------------------------
  # Description
  # ---------------------------------------------------------------------------

  describe "progress_card/1 description" do
    test "renders description when provided" do
      html = render_progress_card(%{description: "Almost done"})
      assert html =~ "Almost done"
    end

    test "description has muted-foreground styling" do
      html = render_progress_card(%{description: "hint text"})
      assert html =~ "text-muted-foreground"
    end

    test "description not rendered when nil" do
      html = render_progress_card(%{description: nil})
      refute html =~ "Almost done"
    end
  end

  # ---------------------------------------------------------------------------
  # Label override
  # ---------------------------------------------------------------------------

  describe "progress_card/1 label override" do
    test "renders custom label instead of percentage" do
      html = render_progress_card(%{value: 50, label: "Halfway"})
      assert html =~ "Halfway"
    end

    test "custom label replaces default percentage" do
      html = render_progress_card(%{value: 50, label: "Halfway"})
      # "Halfway" should appear in the label span, not "50%" as a standalone label
      # (the progress bar still has width: 50% in the inline style, which is expected)
      refute html =~ ">50%<"
    end
  end

  # ---------------------------------------------------------------------------
  # show_value
  # ---------------------------------------------------------------------------

  describe "progress_card/1 show_value" do
    test "hides value label when show_value is false" do
      html = render_progress_card(%{value: 65, show_value: false})
      # The progress bar still has width: 65% in inline style; check the label span is absent
      refute html =~ ">65%<"
    end

    test "shows value label when show_value is true (default)" do
      html = render_progress_card(%{value: 65})
      assert html =~ "65%"
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "progress_card/1 :default variant" do
    test "renders default height class h-2" do
      html = render_progress_card(%{variant: :default, size: :md})
      assert html =~ "h-2"
    end
  end

  describe "progress_card/1 :success variant" do
    test "renders emerald color class" do
      html = render_progress_card(%{variant: :success, size: :md})
      assert html =~ "emerald-500"
    end
  end

  describe "progress_card/1 :warning variant" do
    test "renders amber color class" do
      html = render_progress_card(%{variant: :warning, size: :md})
      assert html =~ "amber-500"
    end
  end

  describe "progress_card/1 :destructive variant" do
    test "renders destructive color class" do
      html = render_progress_card(%{variant: :destructive, size: :md})
      assert html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Sizes
  # ---------------------------------------------------------------------------

  describe "progress_card/1 :sm size" do
    test "renders h-1 height class" do
      html = render_progress_card(%{size: :sm})
      assert html =~ "h-1"
    end
  end

  describe "progress_card/1 :md size" do
    test "renders h-2 height class" do
      html = render_progress_card(%{size: :md})
      assert html =~ "h-2"
    end
  end

  describe "progress_card/1 :lg size" do
    test "renders h-3 height class" do
      html = render_progress_card(%{size: :lg})
      assert html =~ "h-3"
    end
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  describe "progress_card/1 :icon slot" do
    test "renders icon slot content" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "★"
    end
  end

  describe "progress_card/1 :footer slot" do
    test "renders footer slot content" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "Step 1 of 4"
    end

    test "footer not rendered when slot is empty" do
      html = render_progress_card()
      refute html =~ "Step 1 of 4"
    end
  end

  # ---------------------------------------------------------------------------
  # Custom class
  # ---------------------------------------------------------------------------

  describe "progress_card/1 class" do
    test "accepts custom class" do
      html = render_progress_card(%{class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end
  end
end
