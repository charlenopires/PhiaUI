defmodule PhiaUi.Components.Surface.BentoTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Bento

    def render_grid(assigns), do: ~H[<.bento_grid {assigns}>items</.bento_grid>]

    def render_item(assigns), do: ~H[<.bento_item {assigns}>content</.bento_item>]

    def render_header(assigns) do
      ~H"""
      <.bento_header {assigns}>
        <:title>Title</:title>
        <:subtitle>Sub</:subtitle>
      </.bento_header>
      """
    end

    def render_badge(assigns), do: ~H[<.bento_badge {assigns}>NEW</.bento_badge>]
  end

  # ---------------------------------------------------------------------------
  # bento_grid/1
  # ---------------------------------------------------------------------------

  describe "bento_grid/1" do
    test "cols=3 renders grid-cols-3" do
      html = render_component(&H.render_grid/1, %{cols: "3", gap: "md", class: nil})
      assert html =~ "grid-cols-3"
    end

    test "cols=4 renders grid-cols-4" do
      html = render_component(&H.render_grid/1, %{cols: "4", gap: "md", class: nil})
      assert html =~ "grid-cols-4"
    end

    test "cols=6 renders grid-cols-6" do
      html = render_component(&H.render_grid/1, %{cols: "6", gap: "md", class: nil})
      assert html =~ "grid-cols-6"
    end

    test "gap=sm renders gap-2" do
      html = render_component(&H.render_grid/1, %{cols: "3", gap: "sm", class: nil})
      assert html =~ "gap-2"
    end

    test "gap=lg renders gap-6" do
      html = render_component(&H.render_grid/1, %{cols: "3", gap: "lg", class: nil})
      assert html =~ "gap-6"
    end

    test "has auto-rows-auto" do
      html = render_component(&H.render_grid/1, %{cols: "3", gap: "md", class: nil})
      assert html =~ "auto-rows-auto"
    end

    test "renders slot content" do
      html = render_component(&H.render_grid/1, %{cols: "3", gap: "md", class: nil})
      assert html =~ "items"
    end
  end

  # ---------------------------------------------------------------------------
  # bento_item/1
  # ---------------------------------------------------------------------------

  describe "bento_item/1" do
    test "default renders col-span-1 row-span-1" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "default", class: nil})
      assert html =~ "col-span-1"
      assert html =~ "row-span-1"
    end

    test "span_col=2 renders col-span-2" do
      html = render_component(&H.render_item/1, %{span_col: "2", span_row: "1", variant: "default", class: nil})
      assert html =~ "col-span-2"
    end

    test "span_row=2 renders row-span-2" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "2", variant: "default", class: nil})
      assert html =~ "row-span-2"
    end

    test "variant default renders bg-card border" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "default", class: nil})
      assert html =~ "bg-card"
      assert html =~ "border-border"
    end

    test "variant glass renders backdrop-blur-md" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "glass", class: nil})
      assert html =~ "backdrop-blur-md"
    end

    test "variant gradient renders bg-gradient-to-br" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "gradient", class: nil})
      assert html =~ "bg-gradient-to-br"
    end

    test "variant outlined renders border-2" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "outlined", class: nil})
      assert html =~ "border-2"
    end

    test "variant dark renders bg-foreground" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "dark", class: nil})
      assert html =~ "bg-foreground"
    end

    test "renders rounded-2xl" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "default", class: nil})
      assert html =~ "rounded-2xl"
    end

    test "renders content" do
      html = render_component(&H.render_item/1, %{span_col: "1", span_row: "1", variant: "default", class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # bento_header/1
  # ---------------------------------------------------------------------------

  describe "bento_header/1" do
    test "renders p-6 flex flex-col gap-2" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "p-6"
      assert html =~ "flex-col"
    end

    test "renders title slot" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "Title"
    end

    test "renders subtitle slot" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "Sub"
    end

    test "title has text-lg font-semibold" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "text-lg font-semibold"
    end

    test "subtitle has text-muted-foreground" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "text-muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # bento_badge/1
  # ---------------------------------------------------------------------------

  describe "bento_badge/1" do
    test "top-right position renders top-3 right-3" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "default", class: nil})
      assert html =~ "top-3 right-3"
    end

    test "top-left position renders top-3 left-3" do
      html = render_component(&H.render_badge/1, %{position: "top-left", variant: "default", class: nil})
      assert html =~ "top-3 left-3"
    end

    test "bottom-left position renders bottom-3 left-3" do
      html = render_component(&H.render_badge/1, %{position: "bottom-left", variant: "default", class: nil})
      assert html =~ "bottom-3 left-3"
    end

    test "bottom-right position renders bottom-3 right-3" do
      html = render_component(&H.render_badge/1, %{position: "bottom-right", variant: "default", class: nil})
      assert html =~ "bottom-3 right-3"
    end

    test "primary variant renders bg-primary" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "primary", class: nil})
      assert html =~ "bg-primary"
    end

    test "success variant renders bg-green" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "success", class: nil})
      assert html =~ "bg-green"
    end

    test "destructive variant renders bg-destructive" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "destructive", class: nil})
      assert html =~ "bg-destructive"
    end

    test "renders absolute positioning" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "default", class: nil})
      assert html =~ "absolute"
    end

    test "renders content" do
      html = render_component(&H.render_badge/1, %{position: "top-right", variant: "default", class: nil})
      assert html =~ "NEW"
    end
  end
end
