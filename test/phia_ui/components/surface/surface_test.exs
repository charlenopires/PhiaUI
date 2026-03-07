defmodule PhiaUi.Components.Surface.SurfaceTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Surface

    def render_surface(assigns), do: ~H[<.surface {assigns}>content</.surface>]
    def render_paper(assigns), do: ~H[<.paper {assigns}>content</.paper>]
    def render_inset(assigns), do: ~H[<.inset_surface {assigns}>content</.inset_surface>]

    def render_scrollable(assigns),
      do: ~H[<.scrollable_surface {assigns}>content</.scrollable_surface>]

    def render_tonal(assigns), do: ~H[<.tonal_surface {assigns}>content</.tonal_surface>]
  end

  # ---------------------------------------------------------------------------
  # surface/1
  # ---------------------------------------------------------------------------

  describe "surface/1" do
    test "renders flat variant" do
      html = render_component(&H.render_surface/1, %{variant: "flat", class: nil})
      assert html =~ "bg-card"
      assert html =~ "rounded-lg"
      refute html =~ "shadow-md"
    end

    test "renders raised variant" do
      html = render_component(&H.render_surface/1, %{variant: "raised", class: nil})
      assert html =~ "shadow-md"
      assert html =~ "bg-card"
    end

    test "renders floating variant" do
      html = render_component(&H.render_surface/1, %{variant: "floating", class: nil})
      assert html =~ "shadow-xl"
      assert html =~ "rounded-xl"
    end

    test "renders overlay variant" do
      html = render_component(&H.render_surface/1, %{variant: "overlay", class: nil})
      assert html =~ "bg-popover"
      assert html =~ "text-popover-foreground"
    end

    test "elevation overrides add shadow class" do
      html = render_component(&H.render_surface/1, %{variant: "flat", elevation: "5", class: nil})
      assert html =~ "shadow-2xl"
    end

    test "elevation 0 adds shadow-none" do
      html = render_component(&H.render_surface/1, %{variant: "flat", elevation: "0", class: nil})
      assert html =~ "shadow-none"
    end

    test "tonal adds primary/5 class" do
      html =
        render_component(&H.render_surface/1, %{
          variant: "flat",
          tonal: true,
          class: nil
        })

      assert html =~ "bg-primary/5"
    end

    test "outlined adds border class" do
      html =
        render_component(&H.render_surface/1, %{
          variant: "flat",
          outlined: true,
          class: nil
        })

      assert html =~ "border-border"
    end

    test "renders inner content" do
      html = render_component(&H.render_surface/1, %{variant: "flat", class: nil})
      assert html =~ "content"
    end

    test "passes extra class through" do
      html = render_component(&H.render_surface/1, %{variant: "flat", class: "my-custom"})
      assert html =~ "my-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # paper/1
  # ---------------------------------------------------------------------------

  describe "paper/1" do
    test "default elevation 1 renders shadow-sm" do
      html = render_component(&H.render_paper/1, %{elevation: "1", variant: "elevation", square: false, class: nil})
      assert html =~ "shadow-sm"
      assert html =~ "rounded-lg"
    end

    test "elevation 3 renders shadow-lg" do
      html = render_component(&H.render_paper/1, %{elevation: "3", variant: "elevation", square: false, class: nil})
      assert html =~ "shadow-lg"
    end

    test "variant outlined adds border" do
      html = render_component(&H.render_paper/1, %{elevation: "1", variant: "outlined", square: false, class: nil})
      assert html =~ "border border-border"
    end

    test "square removes rounding" do
      html = render_component(&H.render_paper/1, %{elevation: "1", variant: "elevation", square: true, class: nil})
      assert html =~ "rounded-none"
      refute html =~ "rounded-lg"
    end

    test "renders content" do
      html = render_component(&H.render_paper/1, %{elevation: "1", variant: "elevation", square: false, class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # inset_surface/1
  # ---------------------------------------------------------------------------

  describe "inset_surface/1" do
    test "depth sm renders shadow-inner with p-3" do
      html = render_component(&H.render_inset/1, %{depth: "sm", class: nil})
      assert html =~ "shadow-inner"
      assert html =~ "p-3"
    end

    test "depth md is default style" do
      html = render_component(&H.render_inset/1, %{depth: "md", class: nil})
      assert html =~ "p-4"
      assert html =~ "bg-muted"
    end

    test "depth lg renders ring-inset" do
      html = render_component(&H.render_inset/1, %{depth: "lg", class: nil})
      assert html =~ "ring-inset"
      assert html =~ "p-6"
    end

    test "renders content" do
      html = render_component(&H.render_inset/1, %{depth: "md", class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # scrollable_surface/1
  # ---------------------------------------------------------------------------

  describe "scrollable_surface/1" do
    test "renders overflow-y-auto" do
      html = render_component(&H.render_scrollable/1, %{max_height: "20rem", fade_edges: false, class: nil})
      assert html =~ "overflow-y-auto"
      assert html =~ ~s[max-height: 20rem]
    end

    test "fade_edges adds mask-image class" do
      html = render_component(&H.render_scrollable/1, %{max_height: "20rem", fade_edges: true, class: nil})
      assert html =~ "mask-image"
    end

    test "custom max_height is applied" do
      html = render_component(&H.render_scrollable/1, %{max_height: "40rem", fade_edges: false, class: nil})
      assert html =~ "max-height: 40rem"
    end

    test "renders content" do
      html = render_component(&H.render_scrollable/1, %{max_height: "20rem", fade_edges: false, class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # tonal_surface/1
  # ---------------------------------------------------------------------------

  describe "tonal_surface/1" do
    test "primary color renders bg-primary/10" do
      html = render_component(&H.render_tonal/1, %{color: "primary", class: nil})
      assert html =~ "bg-primary/10"
      assert html =~ "text-primary"
    end

    test "destructive color renders bg-destructive/10" do
      html = render_component(&H.render_tonal/1, %{color: "destructive", class: nil})
      assert html =~ "bg-destructive/10"
      assert html =~ "text-destructive"
    end

    test "muted color renders bg-muted" do
      html = render_component(&H.render_tonal/1, %{color: "muted", class: nil})
      assert html =~ "bg-muted"
    end

    test "accent color renders bg-accent" do
      html = render_component(&H.render_tonal/1, %{color: "accent", class: nil})
      assert html =~ "bg-accent"
    end

    test "secondary color renders bg-secondary" do
      html = render_component(&H.render_tonal/1, %{color: "secondary", class: nil})
      assert html =~ "bg-secondary"
    end

    test "renders content" do
      html = render_component(&H.render_tonal/1, %{color: "primary", class: nil})
      assert html =~ "content"
    end
  end
end
