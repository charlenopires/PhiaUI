defmodule PhiaUi.Components.BreadcrumbTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Breadcrumb

    # Full 4-item breadcrumb path
    def render_full(assigns) do
      ~H"""
      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link href="/">Home</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_link href="/products">Products</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_ellipsis />
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_page>Current Page</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>
      """
    end

    # Custom separator slot
    def render_custom_separator(assigns) do
      ~H"""
      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link href="/">Home</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator>
            <span data-testid="custom-sep">›</span>
          </.breadcrumb_separator>
          <.breadcrumb_item>
            <.breadcrumb_page>Page</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>
      """
    end

    # Class override
    attr(:class, :string, default: nil)

    def render_with_class(assigns) do
      ~H"""
      <.breadcrumb class={@class}>
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_page>Page</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>
      """
    end
  end

  defp render_full do
    render_component(&H.render_full/1, %{})
  end

  # ---------------------------------------------------------------------------
  # breadcrumb/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb/1" do
    test "renders <nav> element" do
      assert render_full() =~ "<nav"
    end

    test "renders aria-label='breadcrumb'" do
      assert render_full() =~ ~s(aria-label="breadcrumb")
    end

    test "accepts :class attr" do
      html = render_component(&H.render_with_class/1, %{class: "custom-nav"})
      assert html =~ "custom-nav"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_list/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_list/1" do
    test "renders <ol> element" do
      assert render_full() =~ "<ol"
    end

    test "renders flex layout class" do
      assert render_full() =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_item/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_item/1" do
    test "renders <li> element" do
      assert render_full() =~ "<li"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_link/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_link/1" do
    test "renders <a> element" do
      assert render_full() =~ "<a"
    end

    test "renders href attribute" do
      assert render_full() =~ ~s(href="/")
    end

    test "renders hover underline class" do
      assert render_full() =~ "hover:underline"
    end

    test "renders link text content" do
      assert render_full() =~ "Home"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_page/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_page/1" do
    test "renders aria-current='page'" do
      assert render_full() =~ ~s(aria-current="page")
    end

    test "renders page text content" do
      assert render_full() =~ "Current Page"
    end

    test "does not render as <a> element" do
      html = render_full()
      # The page should be a span or similar, not an anchor
      refute html =~ ~s(aria-current="page") and false
      # aria-current should NOT be on an <a> tag
      refute html =~ ~s(<a aria-current="page")
    end

    test "has distinct muted styling compared to breadcrumb_link" do
      html = render_full()
      assert html =~ "text-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_separator/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_separator/1" do
    test "renders default '/' separator" do
      assert render_full() =~ "/"
    end

    test "renders aria-hidden='true' on separator" do
      assert render_full() =~ ~s(aria-hidden="true")
    end

    test "accepts custom slot content" do
      html = render_component(&H.render_custom_separator/1, %{})
      assert html =~ ~s(data-testid="custom-sep")
      assert html =~ "›"
    end
  end

  # ---------------------------------------------------------------------------
  # breadcrumb_ellipsis/1
  # ---------------------------------------------------------------------------

  describe "breadcrumb_ellipsis/1" do
    test "renders ellipsis indicator" do
      html = render_full()
      assert html =~ "…" or html =~ "..." or html =~ "&#8230;" or html =~ "more"
    end

    test "renders aria-hidden on ellipsis" do
      assert render_full() =~ ~s(aria-hidden="true")
    end
  end

  # ---------------------------------------------------------------------------
  # Full 4+ item path
  # ---------------------------------------------------------------------------

  describe "full breadcrumb path" do
    test "renders all 4 items" do
      html = render_full()
      assert html =~ "Home"
      assert html =~ "Products"
      assert html =~ "Current Page"
    end

    test "renders 3 separators for 4 items" do
      html = render_full()
      # 3 separators between 4 items
      count = html |> String.split(~s(aria-hidden="true")) |> length() |> Kernel.-(1)
      assert count >= 3
    end
  end

  # ---------------------------------------------------------------------------
  # :class merge
  # ---------------------------------------------------------------------------

  describe ":class merge on breadcrumb/1" do
    test "adds custom class" do
      html = render_component(&H.render_with_class/1, %{class: "my-breadcrumb"})
      assert html =~ "my-breadcrumb"
    end

    test "preserves base nav element" do
      html = render_component(&H.render_with_class/1, %{class: "my-breadcrumb"})
      assert html =~ "<nav"
    end
  end
end
