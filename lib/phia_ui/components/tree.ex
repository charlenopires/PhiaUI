defmodule PhiaUi.Components.Tree do
  @moduledoc """
  Tree component for displaying hierarchical data with expandable/collapsible nodes.

  Uses native HTML `<details>/<summary>` for zero-JavaScript expand/collapse.
  The browser handles toggle natively — no Phoenix hooks required.

  ## Sub-components

  | Function      | Element    | Purpose                                          |
  |---------------|------------|--------------------------------------------------|
  | `tree/1`      | `ul`       | Root container with `role="tree"`               |
  | `tree_item/1` | `li`       | Leaf node or expandable branch                  |

  ## Example

      <.tree id="file-tree">
        <.tree_item label="src" expandable={true} expanded={true}>
          <.tree_item label="components" expandable={true}>
            <.tree_item label="button.ex" on_click="open_file" value="button.ex" />
          </.tree_item>
          <.tree_item label="app.ex" value="app.ex" />
        </.tree_item>
        <.tree_item label="mix.exs" value="mix.exs" />
      </.tree>

  ## Expandable Items

  Pass `expandable={true}` to render a branch node using `<details>/<summary>`.
  The `expanded` attribute controls the initial open/closed state server-side.

      <.tree_item label="src" expandable={true} expanded={true}>
        <.tree_item label="app.ex" />
      </.tree_item>

  ## Leaf Items

  Leaf nodes can fire Phoenix events via `on_click` and pass a `value`:

      <.tree_item label="button.ex" on_click="open_file" value="button.ex" />

  ## Indentation

  CSS handles indentation via `<ul role="group" class="ml-4">` nesting —
  no `level` prop needed.

  ## Accessibility

  - Root `<ul>` uses `role="tree"`
  - Each `<li>` uses `role="treeitem"`
  - Expandable items use `aria-expanded` to reflect open/closed state
  - Nested item groups use `role="group"`
  - Chevron SVG is presentational (no ARIA label needed)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID for the root tree element")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<ul>`")

  slot(:inner_block, required: true, doc: "`tree_item/1` sub-components")

  @doc """
  Renders the tree root container.

  The root element is a `<ul>` with `role="tree"` for ARIA semantics.
  """
  def tree(assigns) do
    ~H"""
    <ul id={@id} role="tree" class={cn(["text-sm", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # tree_item/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Display text for the tree item")

  attr(:expandable, :boolean,
    default: false,
    doc: "When true, renders a branch node using `<details>/<summary>`"
  )

  attr(:expanded, :boolean,
    default: false,
    doc: "Initial open/closed state for expandable items (server-side)"
  )

  attr(:on_click, :string,
    default: nil,
    doc: "Phoenix event name to fire when a leaf item is clicked"
  )

  attr(:value, :string,
    default: nil,
    doc: "Value passed as `phx-value-value` on click events"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  slot(:inner_block, doc: "Nested `tree_item/1` components for expandable branches")

  @doc """
  Renders a tree item — either a leaf node or an expandable branch.

  **Leaf nodes** render a simple `<li>` with a clickable row. When `on_click`
  is provided, the row fires a Phoenix event with `phx-value-value={@value}`.

  **Branch nodes** (when `expandable={true}`) use `<details>/<summary>` for
  zero-JavaScript expand/collapse. The `expanded` attribute sets the initial
  state. Nested items are rendered inside `<ul role="group" class="ml-4">`.
  """
  def tree_item(%{expandable: true} = assigns) do
    ~H"""
    <li role="treeitem" aria-expanded={to_string(@expanded)} class="list-none">
      <details open={@expanded}>
        <summary class={cn([
          "flex items-center gap-1 py-0.5 px-2 rounded hover:bg-accent cursor-pointer list-none",
          @class
        ])}>
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
            class="h-4 w-4 shrink-0 transition-transform details-open:rotate-90"
          >
            <polyline points="9 18 15 12 9 6" />
          </svg>
          <span class="truncate"><%= @label %></span>
        </summary>
        <ul role="group" class="ml-4">
          <%= render_slot(@inner_block) %>
        </ul>
      </details>
    </li>
    """
  end

  def tree_item(assigns) do
    ~H"""
    <li role="treeitem" class="list-none" aria-selected="false">
      <div
        class={cn([
          "flex items-center gap-1 py-0.5 px-2 rounded hover:bg-accent cursor-pointer",
          @class
        ])}
        phx-click={@on_click}
        phx-value-value={@value}
      >
        <span class="w-4 flex-shrink-0"></span>
        <span class="truncate"><%= @label %></span>
      </div>
    </li>
    """
  end
end
