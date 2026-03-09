defmodule PhiaUi.Components.Typography.Leader do
  @moduledoc """
  Dot/dash leader fill between two inline elements.

  Leaders are the horizontal fill characters (typically dots) that connect
  a label on the left to a value on the right — commonly seen in restaurant
  menus, tables of contents, and pricing lists.

  ## Examples

      <.leader>
        <:leading>Chapter 1</:leading>
        <:trailing>1</:trailing>
      </.leader>

      <.leader fill={:dash}>
        <:leading>Espresso</:leading>
        <:trailing>$3.50</:trailing>
      </.leader>

  ## Fill styles

  | Fill     | Border style                     |
  |----------|----------------------------------|
  | `:dot`   | `border-dotted` (default)        |
  | `:dash`  | `border-dashed`                  |
  | `:line`  | `border-solid`                   |
  | `:space` | `border-transparent` (invisible) |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:fill, :atom,
    default: :dot,
    values: [:dot, :dash, :line, :space],
    doc: "Leader fill style."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  slot(:leading, required: true, doc: "Left-side content (label, chapter title).")
  slot(:trailing, required: true, doc: "Right-side content (price, page number).")

  @doc "Renders a leader fill between leading and trailing content."
  def leader(assigns) do
    ~H"""
    <div class={cn(["flex items-baseline gap-2", @class])} {@rest}>
      <span class="shrink-0">{render_slot(@leading)}</span>
      <span class={cn(["flex-1 border-b-2 min-w-4 self-end mb-0.5", fill_class(@fill)])} aria-hidden="true" />
      <span class="shrink-0">{render_slot(@trailing)}</span>
    </div>
    """
  end

  defp fill_class(:dot), do: "border-dotted border-muted-foreground/40"
  defp fill_class(:dash), do: "border-dashed border-muted-foreground/40"
  defp fill_class(:line), do: "border-solid border-muted-foreground/40"
  defp fill_class(:space), do: "border-transparent"
end
