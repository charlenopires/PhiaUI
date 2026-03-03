defmodule PhiaUi.Components.IconTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper — wraps Icon in a render-able function component.
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Icon

    attr :name, :string, default: "menu"
    attr :size, :atom, default: :md
    attr :class, :string, default: nil

    def render_icon(assigns) do
      ~H"""
      <.icon name={@name} size={@size} class={@class} />
      """
    end

    def render_icon_defaults(assigns) do
      ~H"""
      <.icon name="menu" />
      """
    end
  end

  defp render_icon(attrs \\ %{}) do
    render_component(&H.render_icon/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # attr :name
  # ---------------------------------------------------------------------------

  describe "attr :name" do
    test "embeds name in the use href as /icons/lucide-sprite.svg#icon-{name}" do
      html = render_icon(%{name: "menu"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-menu")
    end

    test "chevron-down uses href /icons/lucide-sprite.svg#icon-chevron-down" do
      html = render_icon(%{name: "chevron-down"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-chevron-down")
    end

    test "trending-up uses href /icons/lucide-sprite.svg#icon-trending-up" do
      html = render_icon(%{name: "trending-up"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-trending-up")
    end
  end

  # ---------------------------------------------------------------------------
  # attr :size
  # ---------------------------------------------------------------------------

  describe "size :xs" do
    test "renders w-3 h-3" do
      html = render_icon(%{size: :xs})
      assert html =~ "w-3"
      assert html =~ "h-3"
    end
  end

  describe "size :sm" do
    test "renders w-4 h-4" do
      html = render_icon(%{size: :sm})
      assert html =~ "w-4"
      assert html =~ "h-4"
    end
  end

  describe "size :md (default)" do
    test "renders w-5 h-5" do
      html = render_icon()
      assert html =~ "w-5"
      assert html =~ "h-5"
    end

    test "renders w-5 h-5 when no size attr provided" do
      html = render_component(&H.render_icon_defaults/1, %{})
      assert html =~ "w-5"
      assert html =~ "h-5"
    end
  end

  describe "size :lg" do
    test "renders w-6 h-6" do
      html = render_icon(%{size: :lg})
      assert html =~ "w-6"
      assert html =~ "h-6"
    end
  end

  # ---------------------------------------------------------------------------
  # all 4 size variants render without error
  # ---------------------------------------------------------------------------

  describe "4 size variants render without error" do
    for size <- [:xs, :sm, :md, :lg] do
      @size size
      test "size=#{size}" do
        html = render_icon(%{size: @size})
        assert html =~ "<svg"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # attr :class
  # ---------------------------------------------------------------------------

  describe "attr :class" do
    test "nil by default — literal 'nil' not present in output" do
      html = render_icon()
      refute html =~ "nil"
    end

    test "custom class is applied to the svg element" do
      html = render_icon(%{class: "text-primary"})
      assert html =~ "text-primary"
    end

    test "multiple custom classes are applied" do
      html = render_icon(%{class: "text-red-500 shrink-0"})
      assert html =~ "text-red-500"
      assert html =~ "shrink-0"
    end
  end

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  describe "accessibility" do
    test "renders aria-hidden=\"true\"" do
      html = render_icon()
      assert html =~ ~s(aria-hidden="true")
    end

    test "renders focusable=\"false\"" do
      html = render_icon()
      assert html =~ ~s(focusable="false")
    end
  end

  # ---------------------------------------------------------------------------
  # SVG structure
  # ---------------------------------------------------------------------------

  describe "SVG structure" do
    test "renders an <svg> element" do
      html = render_icon()
      assert html =~ "<svg"
    end

    test "renders a <use> element inside the svg" do
      html = render_icon()
      assert html =~ "<use"
    end
  end

  # ---------------------------------------------------------------------------
  # Minimum icon set — spot-check a few names render without error
  # ---------------------------------------------------------------------------

  describe "minimum icon set renders without error" do
    for name <- ~w(menu chevron-down chevron-right check x plus search pencil
                   trash-2 upload-cloud image bold italic underline heading list
                   list-ordered quote code-2 link trending-up trending-down minus
                   eye eye-off calendar tag loader-circle) do
      @name name
      test "icon name=#{name}" do
        html = render_icon(%{name: @name})
        assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-#{@name}")
      end
    end
  end
end
