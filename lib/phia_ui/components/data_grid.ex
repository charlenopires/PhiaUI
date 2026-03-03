defmodule PhiaUi.Components.DataGrid do
  @moduledoc """
  Enhanced table component with server-side column sorting.

  Extends the Table primitive with sortable column headers via `phx-click`.
  Sort state is managed entirely in your LiveView — the component is stateless.
  Streams-compatible (`phx-update="stream"` on `data_grid_body/1`).

  ## Sub-components

  - `data_grid/1` — `<table>` wrapper with overflow container
  - `data_grid_head/1` — `<th>` with optional sort button (`:sort_key`, `:sort_dir`)
  - `data_grid_body/1` — `<tbody>`, accepts `phx-update="stream"`
  - `data_grid_row/1` — `<tr>` with `:class` for conditional styling
  - `data_grid_cell/1` — `<td>` with consistent padding

  ## Example

      <.data_grid>
        <thead>
          <tr>
            <.data_grid_head sort_key="name" sort_dir={@sort_dir} on_sort="sort">
              Name
            </.data_grid_head>
            <.data_grid_head>Actions</.data_grid_head>
          </tr>
        </thead>
        <.data_grid_body id="users" phx-update="stream">
          <.data_grid_row :for={{id, user} <- @streams.users} id={id}>
            <.data_grid_cell><%= user.name %></.data_grid_cell>
            <.data_grid_cell>...</.data_grid_cell>
          </.data_grid_row>
        </.data_grid_body>
      </.data_grid>

  ## LiveView sort handler

      def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
        {:noreply, assign(socket, sort_key: key, sort_dir: String.to_existing_atom(dir))}
      end

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the `<table>` wrapper with overflow container."
  def data_grid(assigns) do
    ~H"""
    <div class={cn(["w-full overflow-auto", @class])}>
      <table class="w-full caption-bottom text-sm" {@rest}>
        <%= render_slot(@inner_block) %>
      </table>
    </div>
    """
  end

  attr :sort_key, :string, default: nil, doc: "Column key sent with sort event; nil = non-sortable"
  attr :sort_dir, :atom,
    default: :none,
    values: [:none, :asc, :desc],
    doc: "Current sort direction for this column"
  attr :on_sort, :string, default: "sort", doc: "phx-click event name for sort"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a `<th>` column header.

  When `:sort_key` is provided, renders a sort button with the appropriate
  direction icon and `aria-sort`. Clicking fires `:on_sort` with
  `phx-value-key` and `phx-value-dir` (the toggled next direction).
  Without `:sort_key`, renders a plain non-interactive header.
  """
  def data_grid_head(assigns) do
    ~H"""
    <th
      aria-sort={if @sort_key, do: aria_sort(@sort_dir)}
      class={cn([
        "h-10 px-2 text-left align-middle font-medium text-muted-foreground",
        "[&:has([role=checkbox])]:pr-0",
        @class
      ])}
      {@rest}
    >
      <%= if @sort_key do %>
        <button
          type="button"
          phx-click={@on_sort}
          phx-value-key={@sort_key}
          phx-value-dir={next_dir(@sort_dir)}
          class="inline-flex items-center gap-1 hover:text-foreground transition-colors"
        >
          <%= render_slot(@inner_block) %>
          <.sort_icon dir={@sort_dir} />
        </button>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </th>
    """
  end

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders `<tbody>`. Accepts `phx-update='stream'` for LiveView streams."
  def data_grid_body(assigns) do
    ~H"""
    <tbody class={cn(["[&_tr:last-child]:border-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  attr :class, :string, default: nil, doc: "Additional CSS classes for conditional row styling"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders a `<tr>` table row."
  def data_grid_row(assigns) do
    ~H"""
    <tr
      class={cn([
        "border-b border-border transition-colors hover:bg-muted/50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders a `<td>` table cell with consistent padding."
  def data_grid_cell(assigns) do
    ~H"""
    <td
      class={cn(["p-2 align-middle [&:has([role=checkbox])]:pr-0", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp next_dir(:none), do: "asc"
  defp next_dir(:asc), do: "desc"
  defp next_dir(:desc), do: "none"

  defp aria_sort(:none), do: "none"
  defp aria_sort(:asc), do: "ascending"
  defp aria_sort(:desc), do: "descending"

  attr :dir, :atom, required: true, values: [:none, :asc, :desc]

  defp sort_icon(%{dir: :none} = assigns) do
    ~H"""
    <.icon name="chevrons-up-down" size={:sm} />
    """
  end

  defp sort_icon(%{dir: :asc} = assigns) do
    ~H"""
    <.icon name="chevron-up" size={:sm} />
    """
  end

  defp sort_icon(%{dir: :desc} = assigns) do
    ~H"""
    <.icon name="chevron-down" size={:sm} />
    """
  end
end
