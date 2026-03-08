defmodule PhiaUi.Components.MegaMenu do
  @moduledoc """
  Full-width mega menu navigation component.

  Requires the `PhiaMegaMenu` JavaScript hook registered in `app.js`.

  Provides six components:

  - `mega_menu/1` — root container with JS hook anchor
  - `mega_menu_trigger/1` — trigger button
  - `mega_menu_content/1` — full-width content panel
  - `mega_menu_section/1` — column section with title
  - `mega_menu_item/1` — link item with icon + title + description
  - `mega_menu_featured/1` — highlighted promotional item
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # mega_menu/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def mega_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaMegaMenu"
      class={cn(["relative z-50", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # mega_menu_trigger/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def mega_menu_trigger(assigns) do
    ~H"""
    <button
      type="button"
      data-mega-trigger
      aria-haspopup="true"
      aria-expanded="false"
      class={cn([
        "inline-flex items-center gap-1 px-3 py-2 text-sm font-medium",
        "rounded-md hover:bg-accent transition-colors",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <svg
        class="h-4 w-4 transition-transform data-[open]:rotate-180"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <polyline points="6 9 12 15 18 9" />
      </svg>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # mega_menu_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:cols, :atom, values: [:auto, :"2", :"3", :"4"], default: :auto)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def mega_menu_content(assigns) do
    ~H"""
    <div
      data-mega-content
      class={cn([
        "absolute top-full left-0 right-0 z-50 hidden",
        "border-t border-border bg-background shadow-lg",
        mega_menu_cols_class(@cols),
        @class
      ])}
      {@rest}
    >
      <div class={cn([
        "mx-auto max-w-screen-xl px-6 py-6",
        mega_menu_grid_class(@cols)
      ])}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # mega_menu_section/1
  # ---------------------------------------------------------------------------

  attr(:title, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def mega_menu_section(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])} {@rest}>
      <p
        :if={@title}
        class="text-xs font-semibold uppercase tracking-wider text-muted-foreground mb-2"
      >
        {@title}
      </p>
      <div class="space-y-1">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # mega_menu_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: "#")
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:icon)

  def mega_menu_item(assigns) do
    ~H"""
    <a
      href={@href}
      class={cn([
        "flex items-start gap-3 rounded-md p-3 hover:bg-accent transition-colors",
        @class
      ])}
      {@rest}
    >
      <span :if={@icon != []} class="mt-0.5 shrink-0 text-muted-foreground">
        {render_slot(@icon)}
      </span>
      <div class="min-w-0">
        <p class="text-sm font-medium text-foreground">{@title}</p>
        <p :if={@description} class="text-xs text-muted-foreground mt-0.5">{@description}</p>
      </div>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # mega_menu_featured/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: "#")
  attr(:title, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:image)
  slot(:inner_block)

  def mega_menu_featured(assigns) do
    ~H"""
    <a
      href={@href}
      class={cn([
        "block rounded-lg bg-gradient-to-br from-primary/10 to-primary/5 p-4 hover:from-primary/15 hover:to-primary/10 transition-colors",
        @class
      ])}
      {@rest}
    >
      <div :if={@image != []} class="mb-3 overflow-hidden rounded-md">
        {render_slot(@image)}
      </div>
      <p :if={@title} class="text-sm font-semibold text-foreground">{@title}</p>
      <p :if={@description} class="mt-1 text-xs text-muted-foreground">{@description}</p>
      <div :if={@inner_block != []} class="mt-2">
        {render_slot(@inner_block)}
      </div>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp mega_menu_cols_class(_), do: ""

  defp mega_menu_grid_class(:auto), do: "grid gap-6 grid-cols-auto"
  defp mega_menu_grid_class(:"2"), do: "grid gap-6 grid-cols-2"
  defp mega_menu_grid_class(:"3"), do: "grid gap-6 grid-cols-3"
  defp mega_menu_grid_class(:"4"), do: "grid gap-6 grid-cols-4"
end
