defmodule PhiaUi.Components.DraggableTree do
  @moduledoc """
  Draggable tree hierarchy components for PhiaUI.

  Provides `draggable_tree/1` and `draggable_tree_node/1`. Backed by the
  `PhiaDraggableTree` hook which handles circular-dependency prevention,
  three-zone drop positioning (before/inside/after), and expand/collapse.

  ## Example

      <.draggable_tree id="nav-tree" on_reorder="tree_reordered">
        <.draggable_tree_node id="node-1" label="Section A" depth={0}>
          <.draggable_tree_node id="node-1a" label="Item A1" depth={1} leaf={true} />
          <.draggable_tree_node id="node-1b" label="Item A2" depth={1} leaf={true} />
        </.draggable_tree_node>
        <.draggable_tree_node id="node-2" label="Section B" depth={0} leaf={true} />
      </.draggable_tree>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # draggable_tree/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :on_reorder, :string, default: "tree_reorder"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders the root of a draggable tree backed by the `PhiaDraggableTree` hook.

  The hook emits `on_reorder` with
  `%{id: "node-id", target_id: "sibling-id", position: "before"|"inside"|"after"}`.
  Drop position is determined by the vertical third of the target node that the
  pointer is over.
  """
  def draggable_tree(assigns) do
    ~H"""
    <ul
      id={@id}
      phx-hook="PhiaDraggableTree"
      data-on-reorder={@on_reorder}
      role="tree"
      aria-label="Draggable tree"
      class={cn(["flex flex-col gap-0.5", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # draggable_tree_node/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :depth, :integer, default: 0
  attr :expanded, :boolean, default: true
  attr :leaf, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block
  slot :icon

  @doc """
  Renders a single tree node with optional children.

  Use `leaf={true}` for nodes with no children — this hides the expand/collapse
  toggle button. Depth-based left padding is applied via inline `style` because
  the value is dynamic and cannot be expressed with static Tailwind classes.

  The `data-depth` attribute and `data-parent-id` (set by the hook after mount)
  are used by `PhiaDraggableTree` to prevent circular moves.
  """
  def draggable_tree_node(assigns) do
    ~H"""
    <li
      id={@id}
      data-tree-node
      data-depth={@depth}
      data-leaf={to_string(@leaf)}
      draggable="true"
      role="treeitem"
      aria-expanded={if !@leaf, do: to_string(@expanded), else: nil}
      class={cn([
        "select-none rounded-md",
        @class
      ])}
      {@rest}
    >
      <%!-- Node row --%>
      <div
        class="flex items-center gap-1.5 rounded-md px-2 py-1.5 text-sm
               hover:bg-muted/60 transition-colors cursor-grab active:cursor-grabbing
               data-[drag-over]:bg-primary/10 data-[drag-over]:ring-1 data-[drag-over]:ring-primary"
        style={"padding-left: #{8 + @depth * 16}px"}
      >
        <%!-- Expand/collapse toggle — only on non-leaf nodes --%>
        <button
          :if={!@leaf}
          type="button"
          data-tree-toggle
          aria-label={if @expanded, do: "Collapse", else: "Expand"}
          class="shrink-0 w-4 h-4 flex items-center justify-center rounded
                 text-muted-foreground hover:text-foreground transition-colors"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 16 16"
            fill="currentColor"
            class={cn(["w-3 h-3 transition-transform", @expanded && "rotate-90"])}
            aria-hidden="true"
          >
            <path d="M6 4l4 4-4 4" stroke="currentColor" stroke-width="1.5" fill="none"
              stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
        <%!-- Leaf spacer to align with branch nodes --%>
        <span :if={@leaf} class="w-4 shrink-0" aria-hidden="true"></span>

        <%!-- Optional icon slot --%>
        <span :if={@icon != []} class="shrink-0 text-muted-foreground">
          {render_slot(@icon)}
        </span>

        <span class="flex-1 truncate text-foreground">{@label}</span>
      </div>

      <%!-- Children — only rendered on non-leaf nodes when expanded --%>
      <ul :if={!@leaf && @expanded} role="group" class="flex flex-col gap-0.5">
        {render_slot(@inner_block)}
      </ul>
    </li>
    """
  end
end
