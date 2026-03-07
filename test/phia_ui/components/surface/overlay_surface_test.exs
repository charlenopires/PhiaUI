defmodule PhiaUi.Components.Surface.OverlaySurfaceTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.OverlaySurface

    def render_scrim(assigns), do: ~H[<.scrim {assigns} />]
    def render_image_scrim(assigns), do: ~H[<.image_scrim {assigns}>content</.image_scrim>]

    def render_gradient_overlay(assigns),
      do: ~H[<.gradient_overlay {assigns}>content</.gradient_overlay>]

    def render_spotlight(assigns),
      do: ~H[<.spotlight_overlay {assigns} />]

    def render_sheet(assigns) do
      ~H"""
      <.bottom_sheet id={assigns.id} modal={assigns.modal} class={assigns.class}>
        <:header>Header</:header>
        Body content
        <:footer>Footer</:footer>
      </.bottom_sheet>
      """
    end

    def render_trigger(assigns) do
      ~H[<.bottom_sheet_trigger for={assigns.for} class={assigns.class}>Trigger</.bottom_sheet_trigger>]
    end
  end

  # ---------------------------------------------------------------------------
  # scrim/1
  # ---------------------------------------------------------------------------

  describe "scrim/1" do
    test "dark md renders bg-black/40" do
      html = render_component(&H.render_scrim/1, %{color: "dark", opacity: "md", blur: false, class: nil})
      assert html =~ "bg-black/40"
    end

    test "dark sm renders bg-black/20" do
      html = render_component(&H.render_scrim/1, %{color: "dark", opacity: "sm", blur: false, class: nil})
      assert html =~ "bg-black/20"
    end

    test "dark lg renders bg-black/60" do
      html = render_component(&H.render_scrim/1, %{color: "dark", opacity: "lg", blur: false, class: nil})
      assert html =~ "bg-black/60"
    end

    test "light md renders bg-white/40" do
      html = render_component(&H.render_scrim/1, %{color: "light", opacity: "md", blur: false, class: nil})
      assert html =~ "bg-white/40"
    end

    test "blur adds backdrop-blur-sm" do
      html = render_component(&H.render_scrim/1, %{color: "dark", opacity: "md", blur: true, class: nil})
      assert html =~ "backdrop-blur-sm"
    end

    test "renders fixed inset-0 z-40" do
      html = render_component(&H.render_scrim/1, %{color: "dark", opacity: "md", blur: false, class: nil})
      assert html =~ "fixed"
      assert html =~ "inset-0"
    end
  end

  # ---------------------------------------------------------------------------
  # image_scrim/1
  # ---------------------------------------------------------------------------

  describe "image_scrim/1" do
    test "bottom md renders from-black/60 to-transparent" do
      html = render_component(&H.render_image_scrim/1, %{direction: "bottom", intensity: "md", class: nil})
      assert html =~ "from-black/60"
      assert html =~ "to-transparent"
      assert html =~ "bg-gradient-to-t"
    end

    test "top renders bg-gradient-to-b" do
      html = render_component(&H.render_image_scrim/1, %{direction: "top", intensity: "md", class: nil})
      assert html =~ "bg-gradient-to-b"
    end

    test "left renders bg-gradient-to-r" do
      html = render_component(&H.render_image_scrim/1, %{direction: "left", intensity: "md", class: nil})
      assert html =~ "bg-gradient-to-r"
    end

    test "right renders bg-gradient-to-l" do
      html = render_component(&H.render_image_scrim/1, %{direction: "right", intensity: "md", class: nil})
      assert html =~ "bg-gradient-to-l"
    end

    test "all direction renders plain bg-black/40" do
      html = render_component(&H.render_image_scrim/1, %{direction: "all", intensity: "md", class: nil})
      assert html =~ "bg-black/40"
    end

    test "intensity full renders from-black to-transparent" do
      html = render_component(&H.render_image_scrim/1, %{direction: "bottom", intensity: "full", class: nil})
      assert html =~ "from-black"
    end

    test "renders absolute inset-0" do
      html = render_component(&H.render_image_scrim/1, %{direction: "bottom", intensity: "md", class: nil})
      assert html =~ "absolute"
      assert html =~ "inset-0"
    end
  end

  # ---------------------------------------------------------------------------
  # gradient_overlay/1
  # ---------------------------------------------------------------------------

  describe "gradient_overlay/1" do
    test "default direction b" do
      html = render_component(&H.render_gradient_overlay/1, %{
        direction: "b",
        from_color: "from-black/60",
        to_color: "to-transparent",
        class: nil
      })
      assert html =~ "bg-gradient-to-b"
      assert html =~ "from-black/60"
      assert html =~ "to-transparent"
    end

    test "direction t renders bg-gradient-to-t" do
      html = render_component(&H.render_gradient_overlay/1, %{
        direction: "t",
        from_color: "from-black/60",
        to_color: "to-transparent",
        class: nil
      })
      assert html =~ "bg-gradient-to-t"
    end

    test "renders absolute inset-0" do
      html = render_component(&H.render_gradient_overlay/1, %{
        direction: "b",
        from_color: "from-black/60",
        to_color: "to-transparent",
        class: nil
      })
      assert html =~ "absolute inset-0"
    end

    test "renders content" do
      html = render_component(&H.render_gradient_overlay/1, %{
        direction: "b",
        from_color: "from-black/60",
        to_color: "to-transparent",
        class: nil
      })
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # spotlight_overlay/1
  # ---------------------------------------------------------------------------

  describe "spotlight_overlay/1" do
    test "renders radial-gradient in style" do
      html = render_component(&H.render_spotlight/1, %{size: "md", position: "center", class: nil})
      assert html =~ "radial-gradient"
    end

    test "center position uses 50% 50%" do
      html = render_component(&H.render_spotlight/1, %{size: "md", position: "center", class: nil})
      assert html =~ "50%"
    end

    test "top position uses 20%" do
      html = render_component(&H.render_spotlight/1, %{size: "md", position: "top", class: nil})
      assert html =~ "20%"
    end

    test "renders absolute inset-0" do
      html = render_component(&H.render_spotlight/1, %{size: "md", position: "center", class: nil})
      assert html =~ "absolute inset-0"
    end

    test "renders pointer-events-none" do
      html = render_component(&H.render_spotlight/1, %{size: "md", position: "center", class: nil})
      assert html =~ "pointer-events-none"
    end
  end

  # ---------------------------------------------------------------------------
  # bottom_sheet/1
  # ---------------------------------------------------------------------------

  describe "bottom_sheet/1" do
    test "renders hidden by default" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ ~s[id="test-sheet"]
      assert html =~ "hidden"
    end

    test "panel has translate-y-full" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "translate-y-full"
    end

    test "renders drag handle" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "h-1.5 w-12 rounded-full"
    end

    test "renders header slot" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "Header"
    end

    test "renders footer slot" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "Footer"
    end

    test "renders body content" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "Body content"
    end

    test "modal=true renders backdrop" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ ~s[data-part="backdrop"]
    end

    test "modal=false does not render backdrop" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: false, class: nil})
      refute html =~ ~s[data-part="backdrop"]
    end

    test "panel has rounded-t-2xl" do
      html = render_component(&H.render_sheet/1, %{id: "test-sheet", modal: true, class: nil})
      assert html =~ "rounded-t-2xl"
    end
  end

  # ---------------------------------------------------------------------------
  # bottom_sheet_trigger/1
  # ---------------------------------------------------------------------------

  describe "bottom_sheet_trigger/1" do
    test "renders trigger content" do
      html = render_component(&H.render_trigger/1, %{for: "test-sheet", class: nil})
      assert html =~ "Trigger"
    end

    test "has phx-click attribute" do
      html = render_component(&H.render_trigger/1, %{for: "test-sheet", class: nil})
      assert html =~ "phx-click"
    end
  end
end
