defmodule PhiaUi.Components.Pagination do
  @moduledoc """
  Pagination navigation component for paginating large data sets.

  Built with pure HEEx and `phx-click` / `phx-value-page` for LiveView
  integration. No JavaScript hooks required.

  ## Sub-components

  | Component               | Element    | Purpose                                          |
  |-------------------------|------------|--------------------------------------------------|
  | `pagination/1`          | `<nav>`    | Landmark wrapper with `role="navigation"`        |
  | `pagination_content/1`  | `<ul>`     | Flex row container for all page items            |
  | `pagination_item/1`     | `<li>`     | Individual item wrapper                          |
  | `pagination_link/1`     | `<button>` | Page number button with active-state highlight   |
  | `pagination_previous/1` | `<button>` | Previous-page button (disabled on page 1)        |
  | `pagination_next/1`     | `<button>` | Next-page button (disabled on last page)         |
  | `pagination_ellipsis/1` | `<span>`   | `…` gap indicator for skipped page ranges        |

  ## Basic LiveView integration

  The simplest pattern: every page is rendered as a button. For small sets
  (≤ 7 pages) render all pages directly without ellipsis.

      defmodule MyAppWeb.PostsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, assign(socket, page: 1, total_pages: 10, posts: load_posts(1))}
        end

        def handle_event("go", %{"page" => page}, socket) do
          page = String.to_integer(page)
          {:noreply, assign(socket, page: page, posts: load_posts(page))}
        end
      end

  Template:

      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous current_page={@page} total_pages={@total_pages} on_change="go" />
          </.pagination_item>
          <%= for p <- 1..@total_pages do %>
            <.pagination_item>
              <.pagination_link page={p} current_page={@page} on_change="go">
                {p}
              </.pagination_link>
            </.pagination_item>
          <% end %>
          <.pagination_item>
            <.pagination_next current_page={@page} total_pages={@total_pages} on_change="go" />
          </.pagination_item>
        </.pagination_content>
      </.pagination>

  ## Pagination with ellipsis (large page counts)

  For large page counts, show first, last, current, and neighbours, with
  `pagination_ellipsis/1` for gaps. Compute the visible page range in the
  LiveView to keep the template clean:

      defp page_window(current, total) do
        neighbors = MapSet.new([1, total, current, current - 1, current + 1])
        Enum.filter(1..total, &MapSet.member?(neighbors, &1))
      end

  Then in the template:

      <.pagination_content>
        <.pagination_item>
          <.pagination_previous current_page={@page} total_pages={@total} on_change="go" />
        </.pagination_item>
        <%= for {p, idx} <- Enum.with_index(page_window(@page, @total)) do %>
          <%!-- Insert ellipsis when there's a gap between consecutive visible pages --%>
          <%= if idx > 0 and p - Enum.at(page_window(@page, @total), idx - 1) > 1 do %>
            <.pagination_item><.pagination_ellipsis /></.pagination_item>
          <% end %>
          <.pagination_item>
            <.pagination_link page={p} current_page={@page} on_change="go">{p}</.pagination_link>
          </.pagination_item>
        <% end %>
        <.pagination_item>
          <.pagination_next current_page={@page} total_pages={@total} on_change="go" />
        </.pagination_item>
      </.pagination_content>

  ## URL-based pagination with `handle_params`

  For shareable URLs use `phx-patch` or update params in `handle_event`:

      def handle_event("go", %{"page" => page}, socket) do
        {:noreply, push_patch(socket, to: ~p"/posts?page=\#{page}")}
      end

      def handle_params(%{"page" => page}, _uri, socket) do
        page = String.to_integer(page)
        {:noreply, assign(socket, page: page, posts: load_posts(page))}
      end

  ## Accessibility

  - The `<nav>` carries `role="navigation"` and `aria-label="pagination"`.
  - The active page button carries `aria-current="page"`.
  - Previous/next buttons carry descriptive `aria-label` attributes.
  - Disabled prev/next buttons set the HTML `disabled` attribute so keyboard
    navigation and screen readers skip them.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # pagination/1 — <nav> landmark wrapper
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<nav>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<nav>` element.")
  slot(:inner_block, required: true, doc: "Should contain a single `pagination_content/1`.")

  @doc """
  Renders the `<nav role="navigation" aria-label="pagination">` wrapper.

  This is the outermost container. Always place a `pagination_content/1`
  inside it.
  """
  def pagination(assigns) do
    ~H"""
    <nav aria-label="pagination" role="navigation" class={cn(["mx-auto flex w-full justify-center", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_content/1 — <ul> row container
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<ul>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<ul>` element.")
  slot(:inner_block, required: true, doc: "Should contain `pagination_item/1` children.")

  @doc """
  Renders the `<ul>` flex container for pagination items.

  All `pagination_item/1` children are rendered in a horizontal flex row
  with a small gap between items.
  """
  def pagination_content(assigns) do
    ~H"""
    <ul class={cn(["flex flex-row items-center gap-1", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_item/1 — <li> wrapper
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<li>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")

  slot(:inner_block,
    required: true,
    doc:
      "A `pagination_link/1`, `pagination_previous/1`, `pagination_next/1`, or `pagination_ellipsis/1`."
  )

  @doc """
  Renders a `<li>` wrapper for a single pagination control.

  Wrap each `pagination_link/1`, `pagination_previous/1`, `pagination_next/1`,
  and `pagination_ellipsis/1` in a `pagination_item/1`.
  """
  def pagination_item(assigns) do
    ~H"""
    <li class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_link/1 — page number button
  # ---------------------------------------------------------------------------

  attr(:page, :integer, required: true, doc: "The page number this button represents (1-based).")

  attr(:current_page, :integer,
    required: true,
    doc: "The currently active page number. Controls active styling and `aria-current`."
  )

  attr(:on_change, :string,
    default: "page-changed",
    doc:
      "The `phx-click` event name sent to the LiveView. Receives `page` as a string value via `phx-value-page`."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<button>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element.")
  slot(:inner_block, required: true, doc: "Page label — typically just the page number.")

  @doc """
  Renders a page number button.

  The active page (`page == current_page`) is highlighted with
  `bg-primary text-primary-foreground` and receives `aria-current="page"`.
  All other pages use a transparent background with a hover accent.

  Fires a `phx-click` event with `phx-value-page={page}` when clicked.
  The LiveView receives the page as a string, so cast with
  `String.to_integer/1` in `handle_event`.

  ## Example

      <.pagination_link page={3} current_page={@page} on_change="navigate">
        3
      </.pagination_link>
  """
  def pagination_link(assigns) do
    ~H"""
    <button
      phx-click={@on_change}
      phx-value-page={@page}
      aria-current={if @page == @current_page, do: "page", else: nil}
      class={cn([
        "inline-flex h-9 w-9 items-center justify-center rounded-md border text-sm transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        if(@page == @current_page,
          do: "bg-primary text-primary-foreground border-primary hover:bg-primary/90",
          else: "border-transparent bg-transparent"
        ),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_previous/1 — previous-page button
  # ---------------------------------------------------------------------------

  attr(:current_page, :integer,
    required: true,
    doc: "The currently active page. When `1`, the button is disabled."
  )

  attr(:total_pages, :integer,
    required: true,
    doc: "Total number of pages. Used to determine the page value sent on click."
  )

  attr(:on_change, :string,
    default: "page-changed",
    doc: "The `phx-click` event name sent to the LiveView."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<button>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element.")

  @doc """
  Renders a previous-page button with a `chevron-left` icon.

  When `current_page == 1`, the button is visually and functionally disabled:
  - The HTML `disabled` attribute is set (removes from tab order).
  - `pointer-events-none opacity-50` is applied.
  - `phx-click` is not attached (no event fires).

  ## Example

      <.pagination_previous current_page={@page} total_pages={@total} on_change="go" />
  """
  def pagination_previous(assigns) do
    ~H"""
    <button
      phx-click={if @current_page > 1, do: @on_change}
      phx-value-page={@current_page - 1}
      aria-label="Go to previous page"
      disabled={@current_page == 1}
      class={cn([
        "inline-flex h-9 items-center justify-center gap-1 rounded-md border border-transparent px-3 text-sm transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        if(@current_page == 1, do: "pointer-events-none opacity-50", else: nil),
        @class
      ])}
      {@rest}
    >
      <.icon name="chevron-left" size={:sm} />
      <span class="sr-only">Previous</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_next/1 — next-page button
  # ---------------------------------------------------------------------------

  attr(:current_page, :integer,
    required: true,
    doc: "The currently active page. When equal to `total_pages`, the button is disabled."
  )

  attr(:total_pages, :integer,
    required: true,
    doc: "Total number of pages. Used to disable the button on the last page."
  )

  attr(:on_change, :string,
    default: "page-changed",
    doc: "The `phx-click` event name sent to the LiveView."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<button>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element.")

  @doc """
  Renders a next-page button with a `chevron-right` icon.

  When `current_page == total_pages`, the button is visually and functionally
  disabled:
  - The HTML `disabled` attribute is set.
  - `pointer-events-none opacity-50` is applied.
  - `phx-click` is not attached.

  ## Example

      <.pagination_next current_page={@page} total_pages={@total} on_change="go" />
  """
  def pagination_next(assigns) do
    ~H"""
    <button
      phx-click={if @current_page < @total_pages, do: @on_change}
      phx-value-page={@current_page + 1}
      aria-label="Go to next page"
      disabled={@current_page == @total_pages}
      class={cn([
        "inline-flex h-9 items-center justify-center gap-1 rounded-md border border-transparent px-3 text-sm transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        if(@current_page == @total_pages, do: "pointer-events-none opacity-50", else: nil),
        @class
      ])}
      {@rest}
    >
      <span class="sr-only">Next</span>
      <.icon name="chevron-right" size={:sm} />
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination_ellipsis/1 — gap indicator
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<span>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<span>` element.")

  @doc """
  Renders a `…` ellipsis to indicate a gap in the page number sequence.

  Use between `pagination_link/1` items when collapsing a range of pages.
  The ellipsis is `aria-hidden="true"` because it carries no actionable
  information for screen readers — the surrounding visible page numbers
  provide sufficient context.

  ## Example

      <%!-- Renders: 1 … 4 5 6 … 20 --%>
      <.pagination_item><.pagination_link page={1} ...>1</.pagination_link></.pagination_item>
      <.pagination_item><.pagination_ellipsis /></.pagination_item>
      <.pagination_item><.pagination_link page={4} ...>4</.pagination_link></.pagination_item>
      ...
  """
  def pagination_ellipsis(assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={cn(["flex h-9 w-9 items-center justify-center text-sm", @class])}
      {@rest}
    >
      …
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # cursor_pagination/1 — cursor-based previous/next
  # ---------------------------------------------------------------------------

  attr(:has_previous_page, :boolean, required: true, doc: "Whether a previous page exists")
  attr(:has_next_page, :boolean, required: true, doc: "Whether a next page exists")
  attr(:on_previous, :string, default: "previous-page", doc: "phx-click event for previous")
  attr(:on_next, :string, default: "next-page", doc: "phx-click event for next")
  attr(:previous_cursor, :any, default: nil, doc: "Cursor value sent with previous event")
  attr(:next_cursor, :any, default: nil, doc: "Cursor value sent with next event")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders cursor-based pagination with Previous and Next buttons.

  Unlike offset pagination, cursor pagination uses opaque cursor tokens rather
  than page numbers. Useful for infinite-scroll APIs and large result sets where
  offset pagination is expensive.
  """
  def cursor_pagination(assigns) do
    ~H"""
    <nav aria-label="cursor pagination" role="navigation" class={cn(["flex items-center gap-2", @class])} {@rest}>
      <button
        type="button"
        phx-click={if @has_previous_page, do: @on_previous}
        phx-value-cursor={@previous_cursor}
        disabled={!@has_previous_page}
        aria-label="Go to previous page"
        class={cn([
          "inline-flex h-9 items-center justify-center gap-1 rounded-md border border-input px-3 text-sm transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          !@has_previous_page && "pointer-events-none opacity-50"
        ])}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <polyline points="15 18 9 12 15 6" />
        </svg>
        <span>Previous</span>
      </button>
      <button
        type="button"
        phx-click={if @has_next_page, do: @on_next}
        phx-value-cursor={@next_cursor}
        disabled={!@has_next_page}
        aria-label="Go to next page"
        class={cn([
          "inline-flex h-9 items-center justify-center gap-1 rounded-md border border-input px-3 text-sm transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          !@has_next_page && "pointer-events-none opacity-50"
        ])}
      >
        <span>Next</span>
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <polyline points="9 18 15 12 9 6" />
        </svg>
      </button>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # load_more/1 — infinite scroll trigger button
  # ---------------------------------------------------------------------------

  attr(:loading, :boolean, default: false, doc: "Shows spinner and loading_label when true")
  attr(:on_click, :string, required: true, doc: "phx-click event to load the next batch")
  attr(:label, :string, default: "Load more")
  attr(:loading_label, :string, default: "Loading...")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a centered "Load more" button for append-style infinite scroll.

  When `loading` is `true`, the button shows a spinner icon and the
  `loading_label` text and is non-interactive.
  """
  def load_more(assigns) do
    ~H"""
    <div class={cn(["flex justify-center", @class])}>
      <button
        type="button"
        phx-click={@on_click}
        disabled={@loading || @disabled}
        class={cn([
          "inline-flex h-9 items-center justify-center gap-2 rounded-md border border-input px-4 text-sm font-medium transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          (@loading || @disabled) && "pointer-events-none opacity-50"
        ])}
        {@rest}
      >
        <%= if @loading do %>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="animate-spin"
            aria-hidden="true"
          >
            <path d="M21 12a9 9 0 1 1-6.219-8.56" />
          </svg>
          {@loading_label}
        <% else %>
          {@label}
        <% end %>
      </button>
    </div>
    """
  end
end
