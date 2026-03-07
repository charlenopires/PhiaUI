defmodule PhiaUi.Components.PaginationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Pagination

    def render_cursor_with_both(assigns) do
      ~H"""
      <.cursor_pagination
        has_previous_page={true}
        has_next_page={true}
        on_previous="prev"
        on_next="next"
        previous_cursor="abc"
        next_cursor="xyz"
      />
      """
    end

    def render_cursor_first_page(assigns) do
      ~H"""
      <.cursor_pagination
        has_previous_page={false}
        has_next_page={true}
        on_previous="prev"
        on_next="next"
        previous_cursor={nil}
        next_cursor="xyz"
      />
      """
    end

    def render_cursor_last_page(assigns) do
      ~H"""
      <.cursor_pagination
        has_previous_page={true}
        has_next_page={false}
        on_previous="prev"
        on_next="next"
        previous_cursor="abc"
        next_cursor={nil}
      />
      """
    end

    def render_load_more(assigns) do
      ~H"""
      <.load_more on_click="load-items" label="Load more" loading={false} loading_label="Loading..." disabled={false} />
      """
    end

    def render_load_more_loading(assigns) do
      ~H"""
      <.load_more on_click="load-items" label="Load more" loading={true} loading_label="Loading..." disabled={false} />
      """
    end

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
  defp render_cursor_with_both, do: render_component(&H.render_cursor_with_both/1, %{})
  defp render_cursor_first_page, do: render_component(&H.render_cursor_first_page/1, %{})
  defp render_cursor_last_page, do: render_component(&H.render_cursor_last_page/1, %{})
  defp render_load_more, do: render_component(&H.render_load_more/1, %{})
  defp render_load_more_loading, do: render_component(&H.render_load_more_loading/1, %{})

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

  # ---------------------------------------------------------------------------
  # cursor_pagination/1
  # ---------------------------------------------------------------------------

  describe "cursor_pagination/1 — both pages available" do
    test "renders Previous button" do
      assert render_cursor_with_both() =~ "Previous"
    end

    test "renders Next button" do
      assert render_cursor_with_both() =~ "Next"
    end

    test "Previous button not disabled when has_previous_page=true" do
      html = render_cursor_with_both()
      refute html =~ ~s(disabled="disabled")
    end

    test "includes phx-value-cursor on previous button" do
      assert render_cursor_with_both() =~ ~s(phx-value-cursor="abc")
    end

    test "includes phx-value-cursor on next button" do
      assert render_cursor_with_both() =~ ~s(phx-value-cursor="xyz")
    end

    test "fires on_previous event" do
      assert render_cursor_with_both() =~ ~s(phx-click="prev")
    end

    test "fires on_next event" do
      assert render_cursor_with_both() =~ ~s(phx-click="next")
    end
  end

  describe "cursor_pagination/1 — first page (no previous)" do
    test "Previous button is disabled" do
      assert render_cursor_first_page() =~ "pointer-events-none"
    end

    test "Next button is not disabled" do
      html = render_cursor_first_page()
      # Should only have one pointer-events-none (the Previous button)
      count = html |> String.split("pointer-events-none") |> length() |> Kernel.-(1)
      assert count == 1
    end
  end

  describe "cursor_pagination/1 — last page (no next)" do
    test "Next button is disabled" do
      assert render_cursor_last_page() =~ "pointer-events-none"
    end
  end

  # ---------------------------------------------------------------------------
  # load_more/1
  # ---------------------------------------------------------------------------

  describe "load_more/1 — idle state" do
    test "renders the label text" do
      assert render_load_more() =~ "Load more"
    end

    test "has phx-click event" do
      assert render_load_more() =~ ~s(phx-click="load-items")
    end

    test "does not show spinner when not loading" do
      refute render_load_more() =~ "animate-spin"
    end
  end

  describe "load_more/1 — loading state" do
    test "renders loading label" do
      assert render_load_more_loading() =~ "Loading..."
    end

    test "shows animate-spin spinner" do
      assert render_load_more_loading() =~ "animate-spin"
    end

    test "is disabled while loading" do
      assert render_load_more_loading() =~ "pointer-events-none"
    end
  end
end
