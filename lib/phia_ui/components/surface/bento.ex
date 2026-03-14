defmodule PhiaUi.Components.Bento do
  @moduledoc """
  Bento grid components for PhiaUI — 4 components for Apple-style modular
  grid layouts with varying cell spans.

  ## Components
  - `bento_grid/1` — CSS grid container (3, 4, or 6 columns)
  - `bento_item/1` — grid cell with col/row span and variant styles
  - `bento_header/1` — structured header with icon, title, subtitle slots
  - `bento_badge/1` — positioned badge overlay for bento items
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 22. bento_grid/1
  # ---------------------------------------------------------------------------

  attr :cols, :string, values: ~w(3 4 6), default: "3"
  attr :gap, :string, values: ~w(sm md lg), default: "md"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Apple-style bento grid container.

  ## Examples

      <.bento_grid cols="3" gap="md">
        <.bento_item span_col="2">Wide item</.bento_item>
        <.bento_item>Narrow item</.bento_item>
      </.bento_grid>
  """
  def bento_grid(assigns) do
    ~H"""
    <div
      class={cn([
        "grid auto-rows-auto",
        bento_cols_class(@cols),
        bento_gap_class(@gap),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp bento_cols_class("3"), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3"
  defp bento_cols_class("4"), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
  defp bento_cols_class("6"), do: "grid-cols-2 sm:grid-cols-3 lg:grid-cols-6"

  defp bento_gap_class("sm"), do: "gap-2"
  defp bento_gap_class("md"), do: "gap-4"
  defp bento_gap_class("lg"), do: "gap-6"

  # ---------------------------------------------------------------------------
  # 23. bento_item/1
  # ---------------------------------------------------------------------------

  attr :span_col, :string, values: ~w(1 2 3), default: "1"
  attr :span_row, :string, values: ~w(1 2), default: "1"
  attr :variant, :atom, values: [:default, :glass, :gradient, :outlined, :dark], default: :default
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true
  slot :header

  @doc """
  Bento grid cell with configurable column/row span and visual variants.

  ## Examples

      <.bento_item span_col="2" span_row="2" variant="glass">
        <:header>
          <.bento_header>
            <:title>Big Feature</:title>
          </.bento_header>
        </:header>
        Content
      </.bento_item>
  """
  def bento_item(assigns) do
    ~H"""
    <div
      class={cn([
        "rounded-2xl overflow-hidden",
        bento_span_col_class(@span_col),
        bento_span_row_class(@span_row),
        bento_variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      {render_slot(@header)}
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp bento_span_col_class("1"), do: "col-span-1"
  defp bento_span_col_class("2"), do: "col-span-2"
  defp bento_span_col_class("3"), do: "col-span-3"

  defp bento_span_row_class("1"), do: "row-span-1"
  defp bento_span_row_class("2"), do: "row-span-2"

  defp bento_variant_class(:default),  do: "bg-card border border-border shadow-sm"
  defp bento_variant_class(:glass),    do: "backdrop-blur-md bg-white/20 dark:bg-black/20 border border-white/20"
  defp bento_variant_class(:gradient), do: "bg-gradient-to-br from-primary/20 to-primary/5 border border-primary/20"
  defp bento_variant_class(:outlined), do: "border-2 border-border bg-transparent"
  defp bento_variant_class(:dark),     do: "bg-foreground text-background"

  # ---------------------------------------------------------------------------
  # 24. bento_header/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block
  slot :icon
  slot :title
  slot :subtitle

  @doc """
  Structured bento cell header with icon, title, and subtitle slots.

  ## Examples

      <.bento_header>
        <:icon><.icon name="hero-star" class="size-5" /></:icon>
        <:title>Feature Name</:title>
        <:subtitle>Short description</:subtitle>
      </.bento_header>
  """
  def bento_header(assigns) do
    ~H"""
    <div class={cn(["p-6 flex flex-col gap-2", @class])} {@rest}>
      <div :if={@icon != []} class="text-primary">
        {render_slot(@icon)}
      </div>
      <div :if={@title != []} class="text-lg font-semibold">
        {render_slot(@title)}
      </div>
      <div :if={@subtitle != []} class="text-sm text-muted-foreground">
        {render_slot(@subtitle)}
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 25. bento_badge/1
  # ---------------------------------------------------------------------------

  attr :position, :string, values: ~w(top-left top-right bottom-left bottom-right), default: "top-right"
  attr :variant, :atom, values: [:default, :primary, :success, :warning, :destructive], default: :default
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Positioned badge overlay for bento items. Must be inside a `relative` parent.

  ## Examples

      <div class="relative">
        <.bento_badge position="top-right" variant="primary">New</.bento_badge>
      </div>
  """
  def bento_badge(assigns) do
    ~H"""
    <span
      class={cn([
        "absolute text-xs font-medium px-2 py-0.5 rounded-full",
        bento_badge_position_class(@position),
        bento_badge_variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp bento_badge_position_class("top-left"),     do: "top-3 left-3"
  defp bento_badge_position_class("top-right"),    do: "top-3 right-3"
  defp bento_badge_position_class("bottom-left"),  do: "bottom-3 left-3"
  defp bento_badge_position_class("bottom-right"), do: "bottom-3 right-3"

  defp bento_badge_variant_class(:default),     do: "bg-secondary text-secondary-foreground"
  defp bento_badge_variant_class(:primary),     do: "bg-primary text-primary-foreground"
  defp bento_badge_variant_class(:success),     do: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400"
  defp bento_badge_variant_class(:warning),     do: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp bento_badge_variant_class(:destructive), do: "bg-destructive/10 text-destructive"
end
