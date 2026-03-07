defmodule PhiaUi.Components.ActionSheet do
  @moduledoc """
  Mobile-style action sheet component — a sliding bottom panel.

  Requires the `PhiaActionSheet` JavaScript hook registered in `app.js`.

  Provides five components:

  - `action_sheet/1` — root container with JS hook anchor
  - `action_sheet_trigger/1` — trigger wrapper element
  - `action_sheet_content/1` — sliding bottom panel
  - `action_sheet_item/1` — individual action button
  - `action_sheet_cancel/1` — cancel button
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # action_sheet/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def action_sheet(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaActionSheet"
      class={cn(["", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # action_sheet_trigger/1
  # ---------------------------------------------------------------------------

  attr(:action_sheet_id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def action_sheet_trigger(assigns) do
    ~H"""
    <div
      data-action-sheet-trigger={@action_sheet_id}
      class={cn(["cursor-pointer", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # action_sheet_content/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:title, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def action_sheet_content(assigns) do
    ~H"""
    <div>
      <%!-- Backdrop --%>
      <div
        data-action-sheet-backdrop
        class="fixed inset-0 z-50 bg-foreground/50 hidden"
      ></div>
      <%!-- Panel --%>
      <div
        id={@id}
        data-action-sheet-panel
        class={cn([
          "fixed bottom-0 left-0 right-0 z-50 flex flex-col",
          "rounded-t-2xl bg-background shadow-xl",
          "transition-transform translate-y-full",
          "max-h-[85vh]",
          @class
        ])}
        {@rest}
      >
        <div class="mx-auto mt-3 h-1 w-10 rounded-full bg-border shrink-0"></div>
        <div :if={@title || @description} class="px-4 pt-4 pb-2 text-center shrink-0">
          <p :if={@title} class="text-sm font-semibold text-foreground">{@title}</p>
          <p :if={@description} class="text-xs text-muted-foreground mt-1">{@description}</p>
        </div>
        <div class="overflow-y-auto flex-1">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # action_sheet_item/1
  # ---------------------------------------------------------------------------

  attr(:on_click, :string, default: nil)
  attr(:href, :string, default: nil)
  attr(:variant, :atom, values: [:default, :destructive], default: :default)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:icon)

  def action_sheet_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        class={cn([
          "flex items-center gap-3 px-4 py-4 text-sm font-medium border-t border-border hover:bg-accent transition-colors",
          @variant == :destructive && "text-destructive hover:bg-destructive/10",
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        {render_slot(@inner_block)}
      </a>
    <% else %>
      <button
        type="button"
        phx-click={@on_click}
        disabled={@disabled}
        class={cn([
          "flex w-full items-center gap-3 px-4 py-4 text-sm font-medium border-t border-border hover:bg-accent transition-colors text-left",
          @variant == :destructive && "text-destructive hover:bg-destructive/10",
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        {render_slot(@inner_block)}
      </button>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # action_sheet_cancel/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block)

  def action_sheet_cancel(assigns) do
    ~H"""
    <div class="px-4 pb-4 pt-2 shrink-0">
      <button
        type="button"
        data-action-sheet-close
        class={cn([
          "mt-2 w-full rounded-xl bg-secondary text-sm font-semibold py-4 hover:bg-secondary/80 transition-colors",
          @class
        ])}
        {@rest}
      >
        <%= if @inner_block != [] do %>
          {render_slot(@inner_block)}
        <% else %>
          Cancel
        <% end %>
      </button>
    </div>
    """
  end
end
