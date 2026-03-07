defmodule PhiaUi.Components.DropZone do
  @moduledoc """
  Drop zone and drag transfer list components for PhiaUI.

  - `drop_zone/1` — a styled drop target for files or arbitrary drag payloads,
    backed by the `PhiaDropZone` hook.
  - `drag_transfer_list/1` — a dual-list transfer widget backed by
    `PhiaDragTransferList`, with drag-and-drop and button-click fallbacks.

  ## drop_zone example

      <.drop_zone id="file-zone" label="Drop files here" on_drop="file_dropped"
        state={@zone_state} />

  ## drag_transfer_list example

      <.drag_transfer_list
        id="role-picker"
        source_label="Available roles"
        target_label="Assigned roles"
        source_items={@available}
        target_items={@assigned}
        on_transfer="roles_updated"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # drop_zone/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :state, :string, values: ~w(idle hover active error), default: "idle"
  attr :label, :string, default: "Drop files here"
  attr :accepts, :string, default: "*"
  attr :on_drop, :string, default: "zone_drop"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block
  slot :icon

  @doc """
  Renders a dashed-border drop zone target.

  The hook transitions `data-state` between `idle → hover → active → idle` as
  the user drags over the zone, and emits `on_drop` on file release.

  State colours:
  - `idle`   — muted border, muted background
  - `hover`  — primary/60 border, primary/5 background
  - `active` — primary border, primary/10 background (animated pulse)
  - `error`  — destructive border and background
  """
  def drop_zone(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaDropZone"
      data-on-drop={@on_drop}
      data-state={@state}
      data-accepts={@accepts}
      role="region"
      aria-label={@label}
      class={cn([
        "flex flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed p-8",
        "transition-colors duration-200 cursor-pointer",
        zone_state_class(@state),
        @class
      ])}
      {@rest}
    >
      <span :if={@icon != []} class="pointer-events-none">
        {render_slot(@icon)}
      </span>
      <span :if={@icon == []} class="pointer-events-none">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="w-10 h-10 opacity-60"
          aria-hidden="true"
        >
          <polyline points="16 16 12 12 8 16" />
          <line x1="12" y1="12" x2="12" y2="21" />
          <path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3" />
        </svg>
      </span>
      <span :if={@inner_block != []} class="text-sm font-medium pointer-events-none">
        {render_slot(@inner_block)}
      </span>
      <span :if={@inner_block == []} class="text-sm font-medium pointer-events-none">
        {@label}
      </span>
    </div>
    """
  end

  defp zone_state_class("idle"), do: "border-border bg-muted/30 text-muted-foreground"
  defp zone_state_class("hover"), do: "border-primary/60 bg-primary/5 text-primary"

  defp zone_state_class("active"),
    do:
      "border-primary bg-primary/10 text-primary animate-[phia-drag-pulse_1s_ease-in-out_infinite]"

  defp zone_state_class("error"), do: "border-destructive bg-destructive/10 text-destructive"

  # ---------------------------------------------------------------------------
  # drag_transfer_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :source_label, :string, default: "Available"
  attr :target_label, :string, default: "Selected"
  attr :source_items, :list, required: true
  attr :target_items, :list, required: true
  attr :on_transfer, :string, default: "items_transferred"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a dual-list transfer widget with drag-and-drop and button fallbacks.

  Each item in `source_items` / `target_items` must be a map with `:id` and
  `:label` keys. The hook emits `on_transfer` with:
  `%{item_id: "...", direction: "to_target" | "to_source"}`.
  """
  def drag_transfer_list(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaDragTransferList"
      data-on-transfer={@on_transfer}
      class={cn(["flex items-stretch gap-2", @class])}
      {@rest}
    >
      <%!-- Source list --%>
      <div class="flex flex-1 flex-col gap-1">
        <p class="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-1">
          {@source_label}
        </p>
        <ul
          data-transfer-source
          class="min-h-24 flex-1 rounded-md border border-border bg-background p-2 flex flex-col gap-1"
        >
          <li
            :for={item <- @source_items}
            id={"#{@id}-src-#{item.id}"}
            data-item-id={item.id}
            draggable="true"
            class="rounded px-3 py-2 text-sm cursor-grab active:cursor-grabbing
                   bg-muted/40 hover:bg-muted transition-colors select-none
                   data-[dragging]:opacity-40"
          >
            {item.label}
          </li>
        </ul>
      </div>

      <%!-- Transfer buttons --%>
      <div class="flex flex-col items-center justify-center gap-2 px-1">
        <button
          type="button"
          data-transfer-to-target
          aria-label="Move to selected"
          class="rounded border border-border bg-background px-2 py-1 text-sm
                 hover:bg-muted transition-colors"
        >
          &rsaquo;
        </button>
        <button
          type="button"
          data-transfer-to-source
          aria-label="Move to available"
          class="rounded border border-border bg-background px-2 py-1 text-sm
                 hover:bg-muted transition-colors"
        >
          &lsaquo;
        </button>
      </div>

      <%!-- Target list --%>
      <div class="flex flex-1 flex-col gap-1">
        <p class="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-1">
          {@target_label}
        </p>
        <ul
          data-transfer-target
          class="min-h-24 flex-1 rounded-md border border-border bg-background p-2 flex flex-col gap-1"
        >
          <li
            :for={item <- @target_items}
            id={"#{@id}-tgt-#{item.id}"}
            data-item-id={item.id}
            draggable="true"
            class="rounded px-3 py-2 text-sm cursor-grab active:cursor-grabbing
                   bg-muted/40 hover:bg-muted transition-colors select-none
                   data-[dragging]:opacity-40"
          >
            {item.label}
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
