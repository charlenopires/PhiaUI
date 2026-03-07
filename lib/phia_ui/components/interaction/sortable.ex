defmodule PhiaUi.Components.Sortable do
  @moduledoc """
  Sortable drag-and-drop list components for PhiaUI.

  Provides `drag_handle/1`, `drop_indicator/1`, `sortable_list/1`, and
  `sortable_item/1`. Pair `sortable_list/1` with the `PhiaSortable` hook for
  full drag-and-drop reordering with keyboard navigation and ARIA announcements.

  ## Minimal example

      <.sortable_list id="tasks" on_reorder="reorder_tasks">
        <.sortable_item :for={{item, idx} <- Enum.with_index(@items)} id={item.id} index={idx}>
          {item.title}
        </.sortable_item>
      </.sortable_list>

  ## With drag handles

      <.sortable_list id="tasks" handle={true} on_reorder="reorder_tasks">
        <.sortable_item :for={{item, idx} <- Enum.with_index(@items)} id={item.id} index={idx}>
          <.drag_handle />
          {item.title}
        </.sortable_item>
      </.sortable_list>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # drag_handle/1
  # ---------------------------------------------------------------------------

  attr :aria_label, :string, default: "Drag to reorder"
  attr :size, :string, values: ~w(sm md lg), default: "md"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a drag handle button with a 6-dot grip icon.

  Place this inside a `sortable_item/1`. When `handle={true}` is set on the
  parent `sortable_list/1`, only dragging from the handle initiates a reorder.
  """
  def drag_handle(assigns) do
    ~H"""
    <button
      type="button"
      data-sortable-handle
      tabindex="0"
      aria-label={@aria_label}
      class={cn([
        "cursor-grab active:cursor-grabbing touch-none select-none",
        "text-muted-foreground hover:text-foreground transition-colors",
        handle_size_class(@size),
        @class
      ])}
      {@rest}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 10 16"
        fill="currentColor"
        aria-hidden="true"
        class="w-full h-full"
      >
        <circle cx="3" cy="2.5" r="1.25" />
        <circle cx="7" cy="2.5" r="1.25" />
        <circle cx="3" cy="8" r="1.25" />
        <circle cx="7" cy="8" r="1.25" />
        <circle cx="3" cy="13.5" r="1.25" />
        <circle cx="7" cy="13.5" r="1.25" />
      </svg>
    </button>
    """
  end

  defp handle_size_class("sm"), do: "w-3 h-4"
  defp handle_size_class("md"), do: "w-4 h-5"
  defp handle_size_class("lg"), do: "w-5 h-6"

  # ---------------------------------------------------------------------------
  # drop_indicator/1
  # ---------------------------------------------------------------------------

  attr :orientation, :string, values: ~w(horizontal vertical), default: "horizontal"
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a thin line that marks the drop position between sortable items.

  The hook toggles the active state by setting `data-active` on the element.
  """
  def drop_indicator(assigns) do
    ~H"""
    <div
      data-drop-indicator
      aria-hidden="true"
      class={cn([drop_indicator_class(@orientation, @active), @class])}
      {@rest}
    >
    </div>
    """
  end

  defp drop_indicator_class("horizontal", false), do: "h-0.5 w-full bg-transparent transition-colors"
  defp drop_indicator_class("horizontal", true), do: "h-0.5 w-full bg-primary transition-colors"
  defp drop_indicator_class("vertical", false), do: "w-0.5 h-full bg-transparent transition-colors"
  defp drop_indicator_class("vertical", true), do: "w-0.5 h-full bg-primary transition-colors"

  # ---------------------------------------------------------------------------
  # sortable_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :orientation, :string, values: ~w(vertical horizontal), default: "vertical"
  attr :handle, :boolean, default: false
  attr :on_reorder, :string, default: "reorder"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a sortable list container backed by the `PhiaSortable` hook.

  Set `handle={true}` when each item contains a `drag_handle/1` — the hook will
  then only initiate a drag when the user grabs the handle, not the whole item.

  The hook emits `on_reorder` (default `"reorder"`) with
  `%{old_index: N, new_index: M, id: "dom-id"}`.
  """
  def sortable_list(assigns) do
    ~H"""
    <ul
      id={@id}
      role="list"
      phx-hook="PhiaSortable"
      data-orientation={@orientation}
      data-handle={to_string(@handle)}
      data-on-reorder={@on_reorder}
      class={cn([
        "flex gap-2",
        list_orientation_class(@orientation),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  defp list_orientation_class("vertical"), do: "flex-col"
  defp list_orientation_class("horizontal"), do: "flex-row flex-wrap"

  # ---------------------------------------------------------------------------
  # sortable_item/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :index, :integer, required: true
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  slot :handle

  @doc """
  Renders a single sortable list item.

  Pass a `drag_handle/1` in the `:handle` slot (or inline in `inner_block`) if
  using handle-based dragging. The `data-index` attribute is used by the hook
  to calculate reorder positions.
  """
  def sortable_item(assigns) do
    ~H"""
    <li
      id={@id}
      data-sortable-item
      data-index={@index}
      draggable={if @disabled, do: "false", else: "true"}
      aria-roledescription="sortable item"
      class={cn([
        "relative rounded-md border border-border bg-background p-3",
        "transition-all duration-150",
        "data-[dragging]:opacity-40 data-[dragging]:shadow-lg",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <span :if={@handle != []} class="mr-2 inline-flex align-middle">
        {render_slot(@handle)}
      </span>
      {render_slot(@inner_block)}
    </li>
    """
  end
end
