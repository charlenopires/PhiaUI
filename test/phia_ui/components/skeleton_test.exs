defmodule PhiaUi.Components.SkeletonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Skeleton

    attr :shape, :atom, default: :rectangle
    attr :width, :string, default: nil
    attr :height, :string, default: nil
    attr :class, :string, default: nil

    def render_skeleton(assigns) do
      ~H"""
      <.skeleton shape={@shape} width={@width} height={@height} class={@class} />
      """
    end

    attr :lines, :integer, default: 3
    attr :class, :string, default: nil

    def render_skeleton_text(assigns) do
      ~H"""
      <.skeleton_text lines={@lines} class={@class} />
      """
    end

    attr :size, :string, default: "10"
    attr :class, :string, default: nil

    def render_skeleton_avatar(assigns) do
      ~H"""
      <.skeleton_avatar size={@size} class={@class} />
      """
    end

    attr :class, :string, default: nil

    def render_skeleton_card(assigns) do
      ~H"""
      <.skeleton_card class={@class} />
      """
    end
  end

  defp render_skeleton(attrs \\ %{}) do
    render_component(&H.render_skeleton/1, attrs)
  end

  defp render_skeleton_text(attrs \\ %{}) do
    render_component(&H.render_skeleton_text/1, attrs)
  end

  defp render_skeleton_avatar(attrs \\ %{}) do
    render_component(&H.render_skeleton_avatar/1, attrs)
  end

  defp render_skeleton_card(attrs \\ %{}) do
    render_component(&H.render_skeleton_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # skeleton/1 — base
  # ---------------------------------------------------------------------------

  describe "skeleton/1 base" do
    test "renders animate-pulse for shimmer effect" do
      assert render_skeleton() =~ "animate-pulse"
    end

    test "renders bg-muted (not hardcoded color)" do
      html = render_skeleton()
      assert html =~ "bg-muted"
      refute html =~ "bg-gray"
      refute html =~ "bg-[#"
    end
  end

  describe "skeleton/1 :rectangle shape" do
    test "is the default shape" do
      assert render_skeleton() =~ "rounded-md"
    end

    test "explicit :rectangle renders rounded-md" do
      assert render_skeleton(%{shape: :rectangle}) =~ "rounded-md"
    end

    test "does not render rounded-full" do
      refute render_skeleton(%{shape: :rectangle}) =~ "rounded-full"
    end
  end

  describe "skeleton/1 :circle shape" do
    test "renders rounded-full" do
      assert render_skeleton(%{shape: :circle}) =~ "rounded-full"
    end

    test "does not render rounded-md" do
      refute render_skeleton(%{shape: :circle}) =~ "rounded-md"
    end
  end

  describe "skeleton/1 :width and :height attrs" do
    test "applies width as inline style when provided" do
      html = render_skeleton(%{width: "200px"})
      assert html =~ "200px"
    end

    test "applies height as inline style when provided" do
      html = render_skeleton(%{height: "48px"})
      assert html =~ "48px"
    end

    test "renders without style attr when width/height are nil" do
      html = render_skeleton()
      refute html =~ ~s(style=)
    end
  end

  describe "skeleton/1 :class merge" do
    test "adds custom class" do
      assert render_skeleton(%{class: "w-32 h-4"}) =~ "w-32"
    end

    test "preserves animate-pulse alongside custom class" do
      html = render_skeleton(%{class: "w-32 h-4"})
      assert html =~ "animate-pulse"
    end
  end

  # ---------------------------------------------------------------------------
  # skeleton_text/1
  # ---------------------------------------------------------------------------

  describe "skeleton_text/1" do
    test "renders 3 lines by default" do
      html = render_skeleton_text()
      # Count occurrences of animate-pulse (one per line)
      count = html |> String.split("animate-pulse") |> length() |> Kernel.-(1)
      assert count == 3
    end

    test "renders :lines count of skeleton elements" do
      html = render_skeleton_text(%{lines: 5})
      count = html |> String.split("animate-pulse") |> length() |> Kernel.-(1)
      assert count == 5
    end

    test "last line is shorter than full width" do
      html = render_skeleton_text()
      # Last line should have a width less than w-full (e.g. w-3/4 or w-2/3)
      refute String.ends_with?(String.trim(html), ~s(w-full">))
      assert html =~ ~r/w-\d\/\d/
    end

    test "renders bg-muted on lines" do
      assert render_skeleton_text() =~ "bg-muted"
    end

    test "adds custom class to wrapper" do
      assert render_skeleton_text(%{class: "space-y-4"}) =~ "space-y-4"
    end
  end

  # ---------------------------------------------------------------------------
  # skeleton_avatar/1
  # ---------------------------------------------------------------------------

  describe "skeleton_avatar/1" do
    test "renders circular shape (rounded-full)" do
      assert render_skeleton_avatar() =~ "rounded-full"
    end

    test "renders animate-pulse" do
      assert render_skeleton_avatar() =~ "animate-pulse"
    end

    test "renders bg-muted" do
      assert render_skeleton_avatar() =~ "bg-muted"
    end

    test "default size produces w-10 h-10" do
      html = render_skeleton_avatar()
      assert html =~ "w-10"
      assert html =~ "h-10"
    end

    test "custom size attr is applied" do
      html = render_skeleton_avatar(%{size: "16"})
      assert html =~ "w-16"
      assert html =~ "h-16"
    end

    test "adds custom class" do
      assert render_skeleton_avatar(%{class: "ring-2"}) =~ "ring-2"
    end
  end

  # ---------------------------------------------------------------------------
  # skeleton_card/1
  # ---------------------------------------------------------------------------

  describe "skeleton_card/1" do
    test "renders animate-pulse elements" do
      assert render_skeleton_card() =~ "animate-pulse"
    end

    test "renders bg-muted" do
      assert render_skeleton_card() =~ "bg-muted"
    end

    test "renders a tall header/image area placeholder" do
      # Should contain a tall rectangle (e.g. h-40 or h-48)
      html = render_skeleton_card()
      assert html =~ ~r/h-\d+/
    end

    test "renders text lines in the content area" do
      # skeleton_card composes skeleton_text, so multiple lines expected
      count = render_skeleton_card() |> String.split("animate-pulse") |> length() |> Kernel.-(1)
      assert count >= 3
    end

    test "renders rounded-lg card wrapper" do
      assert render_skeleton_card() =~ "rounded-lg"
    end

    test "adds custom class to wrapper" do
      assert render_skeleton_card(%{class: "shadow-md"}) =~ "shadow-md"
    end
  end
end
