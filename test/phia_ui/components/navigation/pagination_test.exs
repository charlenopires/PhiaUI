defmodule PhiaUi.Components.PaginationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Pagination

    # Middle page (page 3 of 5)
    def render_middle(assigns) do
      ~H"""
      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous current_page={3} total_pages={5} on_change="go" />
          </.pagination_item>
          <.pagination_item>
            <.pagination_link page={1} current_page={3} on_change="go">1</.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_link page={3} current_page={3} on_change="go">3</.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_ellipsis />
          </.pagination_item>
          <.pagination_item>
            <.pagination_next current_page={3} total_pages={5} on_change="go" />
          </.pagination_item>
        </.pagination_content>
      </.pagination>
      """
    end

    # First page (page 1 of 5) — prev should be disabled
    def render_first(assigns) do
      ~H"""
      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous current_page={1} total_pages={5} on_change="go" />
          </.pagination_item>
          <.pagination_item>
            <.pagination_link page={1} current_page={1} on_change="go">1</.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_next current_page={1} total_pages={5} on_change="go" />
          </.pagination_item>
        </.pagination_content>
      </.pagination>
      """
    end

    # Last page (page 5 of 5) — next should be disabled
    def render_last(assigns) do
      ~H"""
      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous current_page={5} total_pages={5} on_change="go" />
          </.pagination_item>
          <.pagination_item>
            <.pagination_link page={5} current_page={5} on_change="go">5</.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_next current_page={5} total_pages={5} on_change="go" />
          </.pagination_item>
        </.pagination_content>
      </.pagination>
      """
    end
  end

  defp render_middle, do: render_component(&H.render_middle/1, %{})
  defp render_first, do: render_component(&H.render_first/1, %{})
  defp render_last, do: render_component(&H.render_last/1, %{})

  # ---------------------------------------------------------------------------
  # pagination/1
  # ---------------------------------------------------------------------------

  describe "pagination/1" do
    test "renders <nav> element" do
      assert render_middle() =~ "<nav"
    end

    test "renders aria-label='pagination'" do
      assert render_middle() =~ ~s(aria-label="pagination")
    end
  end

  # ---------------------------------------------------------------------------
  # pagination_content/1
  # ---------------------------------------------------------------------------

  describe "pagination_content/1" do
    test "renders <ul> element" do
      assert render_middle() =~ "<ul"
    end

    test "renders flex layout" do
      assert render_middle() =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # pagination_link/1
  # ---------------------------------------------------------------------------

  describe "pagination_link/1 — active page" do
    test "active page has bg-primary class" do
      assert render_middle() =~ "bg-primary"
    end

    test "active page has text-primary-foreground class" do
      assert render_middle() =~ "text-primary-foreground"
    end

    test "active page has aria-current='page'" do
      assert render_middle() =~ ~s(aria-current="page")
    end
  end

  describe "pagination_link/1 — inactive page" do
    test "inactive page does not have aria-current='page'" do
      # Page 1 is inactive when current is 3
      html = render_middle()
      # aria-current should appear exactly once (only on active page)
      count = html |> String.split(~s(aria-current="page")) |> length() |> Kernel.-(1)
      assert count == 1
    end
  end

  describe "pagination_link/1 — phx-click" do
    test "has phx-click attribute" do
      assert render_middle() =~ "phx-click"
    end

    test "fires on_change event name" do
      assert render_middle() =~ ~s(phx-click="go")
    end

    test "includes page value as phx-value" do
      assert render_middle() =~ "phx-value"
    end
  end

  # ---------------------------------------------------------------------------
  # pagination_previous/1
  # ---------------------------------------------------------------------------

  describe "pagination_previous/1 — middle page" do
    test "is not disabled on middle page" do
      html = render_middle()
      # Should have phx-click enabled
      assert html =~ "phx-click"
      refute html =~ "pointer-events-none"
    end

    test "renders chevron-left icon" do
      assert render_middle() =~ "chevron-left"
    end
  end

  describe "pagination_previous/1 — first page" do
    test "is disabled on first page" do
      assert render_first() =~ "pointer-events-none"
    end

    test "has opacity-50 when disabled" do
      assert render_first() =~ "opacity-50"
    end

    test "renders chevron-left icon" do
      assert render_first() =~ "chevron-left"
    end
  end

  # ---------------------------------------------------------------------------
  # pagination_next/1
  # ---------------------------------------------------------------------------

  describe "pagination_next/1 — middle page" do
    test "is not disabled on middle page" do
      html = render_middle()
      refute html =~ "pointer-events-none"
    end

    test "renders chevron-right icon" do
      assert render_middle() =~ "chevron-right"
    end
  end

  describe "pagination_next/1 — last page" do
    test "is disabled on last page" do
      assert render_last() =~ "pointer-events-none"
    end

    test "has opacity-50 when disabled" do
      assert render_last() =~ "opacity-50"
    end

    test "renders chevron-right icon" do
      assert render_last() =~ "chevron-right"
    end
  end

  # ---------------------------------------------------------------------------
  # pagination_ellipsis/1
  # ---------------------------------------------------------------------------

  describe "pagination_ellipsis/1" do
    test "renders ellipsis indicator" do
      html = render_middle()
      assert html =~ "…" or html =~ "..." or html =~ "more"
    end

    test "renders aria-hidden='true'" do
      assert render_middle() =~ ~s(aria-hidden="true")
    end
  end
end
