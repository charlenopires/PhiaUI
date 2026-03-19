defmodule PhiaUi.Components.Editor.BlockControls do
  @moduledoc """
  Editor Block Control Components — 4 components for manipulating, converting,
  and reordering content blocks within a rich text editor.

  These components provide the UI chrome around editor blocks: add buttons,
  type conversion menus, per-block floating toolbars, and drop zone indicators
  for drag-and-drop reordering.

  All components render without JavaScript and support dark mode via Tailwind v4
  design tokens.

  ## Components

  - `block_add_button/1`        — "+" button between blocks to insert new content
  - `block_conversion_menu/1`   — dropdown menu to convert a block's type
  - `block_toolbar/1`           — per-block floating toolbar with drag, type, and actions
  - `block_drag_indicator/1`    — thin colored drop zone indicator line
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @conversion_types [
    %{type: "paragraph", label: "Paragraph", icon_path: "M13 4v16M3 4h13a4 4 0 0 1 0 8H3"},
    %{type: "heading-1", label: "Heading 1", icon_path: "M4 12h8M4 4v16M12 4v16M20 8v12M20 8l-4 0"},
    %{type: "heading-2", label: "Heading 2", icon_path: "M4 12h8M4 4v16M12 4v16M21.12 20H17a3 3 0 0 1 0-6h1"},
    %{type: "heading-3", label: "Heading 3", icon_path: "M4 12h8M4 4v16M12 4v16M17.5 15.5a2.5 2.5 0 1 0 0 5M17.5 15.5a2.5 2.5 0 1 1 0-5"},
    %{type: "bulletList", label: "Bullet List", icon_path: "M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"},
    %{type: "orderedList", label: "Numbered List", icon_path: "M10 6h11M10 12h11M10 18h11M4 6h1v4M4 10h2M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"},
    %{type: "blockquote", label: "Blockquote", icon_path: "M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V21z"},
    %{type: "codeBlock", label: "Code Block", icon_path: "m18 16 4-4-4-4M6 8l-4 4 4 4M14.5 4l-5 16"},
    %{type: "callout", label: "Callout", icon_path: "M12 16v-4M12 8h.01M22 12c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2s10 4.477 10 10z"},
    %{type: "toggleList", label: "Toggle List", icon_path: "m9 18 6-6-6-6"}
  ]

  # ============================================================================
  # 1. block_add_button/1
  # ============================================================================

  attr :id, :string, default: nil, doc: "Optional identifier for the add button."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes (e.g. phx-click)."

  @doc """
  Renders a small circular "+" button for inserting a new block between
  existing blocks.

  The button is centered, semi-transparent, and becomes more visible on hover.
  It dispatches whatever event is passed via the `:rest` global attributes
  (typically `phx-click`).

  ## Example

      <.block_add_button phx-click="block:add" phx-value-position="3" />
  """
  def block_add_button(assigns) do
    ~H"""
    <div class={cn(["flex justify-center py-1", @class])}>
      <button
        id={@id}
        type="button"
        aria-label="Add block"
        title="Add block"
        class={cn([
          "inline-flex h-6 w-6 items-center justify-center rounded-full",
          "border border-border bg-background text-muted-foreground",
          "opacity-0 transition-all duration-150",
          "hover:opacity-100 hover:border-primary hover:text-primary hover:bg-primary/10",
          "focus-visible:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "group-hover/block:opacity-60"
        ])}
        {@rest}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M5 12h14" />
          <path d="M12 5v14" />
        </svg>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 2. block_conversion_menu/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the conversion menu."
  attr :visible, :boolean, default: false, doc: "Whether the menu is currently displayed."
  attr :current_type, :string, default: "paragraph", doc: "The current block type."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  @doc """
  Renders a dropdown menu for converting a block's type.

  Displays 10 conversion options: paragraph, heading 1-3, bullet list,
  numbered list, blockquote, code block, callout, and toggle list. The
  currently active type is highlighted.

  ## Example

      <.block_conversion_menu
        id="convert-menu-1"
        visible={@show_conversion}
        current_type="paragraph"
      />
  """
  def block_conversion_menu(assigns) do
    assigns = assign(assigns, :types, @conversion_types)

    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="menu"
      aria-label="Convert block type"
      class={cn([
        "w-56 rounded-lg border border-border bg-popover p-1 shadow-lg",
        "animate-[phia-dropdown-in_150ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <button
        :for={item <- @types}
        type="button"
        role="menuitem"
        phx-click="block:convert"
        phx-value-type={item.type}
        phx-value-block-id={@id}
        class={cn([
          "flex w-full items-center gap-2.5 rounded-md px-2 py-1.5 text-sm transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
          @current_type == item.type && "bg-accent/50 font-medium text-accent-foreground",
          @current_type != item.type && "text-foreground"
        ])}
      >
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
          aria-hidden="true"
          class="shrink-0 text-muted-foreground"
        >
          <path d={item.icon_path} />
        </svg>
        <span>{item.label}</span>
        <svg
          :if={@current_type == item.type}
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="ml-auto text-primary"
        >
          <path d="M20 6 9 17l-5-5" />
        </svg>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 3. block_toolbar/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the block toolbar."
  attr :visible, :boolean, default: false, doc: "Whether the toolbar is currently displayed."
  attr :block_type, :string, default: "paragraph", doc: "Current block type label."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  @doc """
  Renders a compact per-block floating toolbar with a drag handle, block type
  indicator, duplicate button, and delete button.

  The drag handle uses a 6-dot grip pattern. The toolbar appears when `visible`
  is true and is typically positioned to the left of the active block.

  ## Example

      <.block_toolbar
        id="toolbar-block-1"
        visible={@active_block == "block-1"}
        block_type="heading-1"
      />
  """
  def block_toolbar(assigns) do
    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="toolbar"
      aria-label="Block actions"
      class={cn([
        "flex items-center gap-0.5 rounded-md border border-border bg-popover p-0.5 shadow-sm",
        "animate-[phia-bubble-in_100ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <%!-- Drag handle (6-dot grip) --%>
      <button
        type="button"
        aria-label="Drag to reorder"
        title="Drag to reorder"
        class={toolbar_btn_class()}
        draggable="true"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <circle cx="9" cy="5" r="1.5" />
          <circle cx="15" cy="5" r="1.5" />
          <circle cx="9" cy="12" r="1.5" />
          <circle cx="15" cy="12" r="1.5" />
          <circle cx="9" cy="19" r="1.5" />
          <circle cx="15" cy="19" r="1.5" />
        </svg>
      </button>

      <%!-- Block type indicator --%>
      <span class="px-1.5 text-[10px] font-medium text-muted-foreground select-none">
        {format_block_type(@block_type)}
      </span>

      <span class="h-4 w-px bg-border" aria-hidden="true" />

      <%!-- Duplicate button --%>
      <button
        type="button"
        aria-label="Duplicate block"
        title="Duplicate block"
        phx-click="block:duplicate"
        phx-value-block-id={@id}
        class={toolbar_btn_class()}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <rect width="14" height="14" x="8" y="8" rx="2" ry="2" />
          <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2" />
        </svg>
      </button>

      <%!-- Delete button --%>
      <button
        type="button"
        aria-label="Delete block"
        title="Delete block"
        phx-click="block:delete"
        phx-value-block-id={@id}
        class={cn([
          toolbar_btn_class(),
          "text-destructive hover:bg-destructive/10 hover:text-destructive"
        ])}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M3 6h18" />
          <path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" />
          <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
        </svg>
      </button>
    </div>
    """
  end

  defp toolbar_btn_class do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded text-muted-foreground",
      "transition-colors",
      "hover:bg-accent hover:text-accent-foreground",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
    ])
  end

  defp format_block_type("heading-1"), do: "H1"
  defp format_block_type("heading-2"), do: "H2"
  defp format_block_type("heading-3"), do: "H3"
  defp format_block_type("bulletList"), do: "Bullet"
  defp format_block_type("orderedList"), do: "Numbered"
  defp format_block_type("blockquote"), do: "Quote"
  defp format_block_type("codeBlock"), do: "Code"
  defp format_block_type("callout"), do: "Callout"
  defp format_block_type("toggleList"), do: "Toggle"
  defp format_block_type("paragraph"), do: "Paragraph"
  defp format_block_type(type), do: type

  # ============================================================================
  # 4. block_drag_indicator/1
  # ============================================================================

  attr :position, :atom,
    default: :above,
    values: [:above, :below],
    doc: "Placement of the indicator line relative to the block."

  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a thin colored drop zone indicator line.

  Used during drag-and-drop block reordering to show where the dragged block
  will be dropped. The `:above` position applies a negative top margin; `:below`
  applies a negative bottom margin.

  ## Example

      <.block_drag_indicator position={:above} />
      <.block_drag_indicator position={:below} />
  """
  def block_drag_indicator(assigns) do
    ~H"""
    <div
      role="presentation"
      aria-hidden="true"
      class={cn([
        "h-0.5 w-full rounded-full bg-primary",
        @position == :above && "-mt-1",
        @position == :below && "-mb-1",
        @class
      ])}
    />
    """
  end
end
