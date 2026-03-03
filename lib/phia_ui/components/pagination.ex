defmodule PhiaUi.Components.Pagination do
  @moduledoc """
  Pagination navigation component.

  Pure HEEx + `phx-click` for LiveView page navigation.
  No JavaScript hooks required.

  ## Sub-components

  - `pagination/1` — `<nav aria-label="pagination">` wrapper
  - `pagination_content/1` — `<ul>` flex container
  - `pagination_item/1` — `<li>` wrapper
  - `pagination_link/1` — page number button with active state
  - `pagination_previous/1` — previous button (disabled on first page)
  - `pagination_next/1` — next button (disabled on last page)
  - `pagination_ellipsis/1` — `…` gap indicator

  ## Example

      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous current_page={@page} total_pages={@total} on_change="go" />
          </.pagination_item>
          <%= for p <- 1..@total do %>
            <.pagination_item>
              <.pagination_link page={p} current_page={@page} on_change="go">
                <%= p %>
              </.pagination_link>
            </.pagination_item>
          <% end %>
          <.pagination_item>
            <.pagination_next current_page={@page} total_pages={@total} on_change="go" />
          </.pagination_item>
        </.pagination_content>
      </.pagination>

  In your LiveView:

      def handle_event("go", %{"page" => page}, socket) do
        {:noreply, assign(socket, page: String.to_integer(page))}
      end

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the `<nav aria-label='pagination'>` wrapper."
  def pagination(assigns) do
    ~H"""
    <nav aria-label="pagination" role="navigation" class={cn(["mx-auto flex w-full justify-center", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the `<ul>` flex container for pagination items."
  def pagination_content(assigns) do
    ~H"""
    <ul class={cn(["flex flex-row items-center gap-1", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders a `<li>` pagination item wrapper."
  def pagination_item(assigns) do
    ~H"""
    <li class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr :page, :integer, required: true, doc: "The page number this link represents"
  attr :current_page, :integer, required: true, doc: "The currently active page"
  attr :on_change, :string, default: "page-changed", doc: "phx-click event name"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a page number button.

  The active page is highlighted with `bg-primary text-primary-foreground`
  and receives `aria-current='page'`.
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

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :on_change, :string, default: "page-changed"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a previous-page button with a chevron-left icon.
  Disabled (pointer-events-none, opacity-50) when `current_page == 1`.
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

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :on_change, :string, default: "page-changed"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a next-page button with a chevron-right icon.
  Disabled (pointer-events-none, opacity-50) when `current_page == total_pages`.
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

  attr :class, :string, default: nil
  attr :rest, :global

  @doc "Renders a `…` ellipsis to indicate skipped page ranges."
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
end
