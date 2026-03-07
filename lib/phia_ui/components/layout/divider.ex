defmodule PhiaUi.Components.Layout.Divider do
  @moduledoc """
  Enhanced separator with optional centered text label.

  Extends the basic `separator` with a text label variant useful for grouping
  sections (e.g., "Or continue with" in authentication flows).

  Without a label, behaves identically to `separator`. With a label, renders
  a flex row with expanding lines on either side of the label text.

  ## Examples

      <%!-- Plain horizontal divider --%>
      <.divider />

      <%!-- Labeled divider (auth separator) --%>
      <.divider label="Or continue with" />

      <%!-- Label aligned to start --%>
      <.divider label="Filters" label_position={:start} />

      <%!-- Vertical divider --%>
      <.divider orientation="vertical" class="h-8" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Separator orientation."
  )

  attr(:label, :string,
    default: nil,
    doc: "Optional label text (horizontal only)."
  )

  attr(:label_position, :atom,
    default: :center,
    values: [:start, :center, :end],
    doc: "Where to position the label."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  @doc "Renders a divider, optionally with a centered label."
  def divider(%{label: nil} = assigns) do
    ~H"""
    <div
      class={cn([plain_class(@orientation), @class])}
      role="none"
      aria-hidden="true"
      {@rest}
    >
    </div>
    """
  end

  def divider(%{orientation: "horizontal"} = assigns) do
    ~H"""
    <div class={cn(["flex items-center gap-3", @class])} role="none" aria-hidden="true" {@rest}>
      <div class={left_line_class(@label_position)}></div>
      <span class="text-xs text-muted-foreground whitespace-nowrap">{@label}</span>
      <div class={right_line_class(@label_position)}></div>
    </div>
    """
  end

  def divider(assigns) do
    ~H"""
    <div
      class={cn([plain_class(@orientation), @class])}
      role="none"
      aria-hidden="true"
      {@rest}
    >
    </div>
    """
  end

  defp plain_class("horizontal"), do: "h-px w-full bg-border"
  defp plain_class("vertical"), do: "w-px h-full bg-border"

  defp left_line_class(:start), do: "w-8 h-px bg-border shrink-0"
  defp left_line_class(_), do: "flex-1 h-px bg-border"

  defp right_line_class(:end), do: "w-8 h-px bg-border shrink-0"
  defp right_line_class(_), do: "flex-1 h-px bg-border"
end
