defmodule PhiaUi.Components.Layout.ResponsiveStack do
  @moduledoc """
  A responsive flex stack that switches from vertical (column) on mobile to
  horizontal (row) at a configurable breakpoint.

  This encodes the extremely common mobile-column / desktop-row pattern as a
  single component with typed attributes, eliminating repetitive
  `flex flex-col md:flex-row` class strings.

  ## Examples

      <%!-- Default: column on mobile, row from md --%>
      <.responsive_stack>
        <div>Left</div>
        <div>Right</div>
      </.responsive_stack>

      <%!-- Row from lg with larger gap --%>
      <.responsive_stack breakpoint={:lg} gap={8}>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
      </.responsive_stack>

      <%!-- Reversed row on desktop, centered --%>
      <.responsive_stack reverse align={:center}>
        <div>Media</div>
        <div>Content</div>
      </.responsive_stack>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :breakpoint, :atom,
    default: :md,
    values: [:sm, :md, :lg, :xl],
    doc: "Breakpoint at which the stack switches from column to row."

  attr :gap, :integer,
    default: 4,
    doc: "Gap between children (0-12) applied as `gap-N`."

  attr :reverse, :boolean,
    default: false,
    doc: "When true, uses `flex-row-reverse` instead of `flex-row` at the breakpoint."

  attr :align, :atom,
    default: nil,
    values: [nil, :start, :center, :end, :stretch, :baseline],
    doc: "align-items value applied to the flex container."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1."

  attr :rest, :global, doc: "HTML attributes forwarded to the root element."

  slot :inner_block, required: true, doc: "Stack children."

  @doc "Renders a responsive flex stack (column on mobile, row at breakpoint)."
  def responsive_stack(assigns) do
    ~H"""
    <div
      class={cn([
        "flex flex-col",
        row_class(@breakpoint, @reverse),
        "gap-#{@gap}",
        align_class(@align),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp row_class(bp, false), do: "#{bp}:flex-row"
  defp row_class(bp, true), do: "#{bp}:flex-row-reverse"

  defp align_class(nil), do: nil
  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"
  defp align_class(:baseline), do: "items-baseline"
end
