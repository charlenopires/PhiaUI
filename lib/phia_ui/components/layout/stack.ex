defmodule PhiaUi.Components.Layout.Stack do
  @moduledoc """
  Vertical or horizontal flex stack with consistent gap.

  `stack` is the workhorse layout component for most page regions. Use
  `:vertical` (default) for stacked sections and `:horizontal` for inline
  groups of elements.

  ## Examples

      <%!-- Vertical stack (VStack equivalent) --%>
      <.stack gap={4}>
        <.card>First</.card>
        <.card>Second</.card>
        <.card>Third</.card>
      </.stack>

      <%!-- Horizontal stack (HStack equivalent) --%>
      <.stack direction={:horizontal} gap={2} align={:center}>
        <.icon name="hero-bell" />
        <span>Notifications</span>
        <.badge>3</.badge>
      </.stack>

      <%!-- Centered vertical stack --%>
      <.stack gap={6} align={:center} class="py-12">
        <h1>Title</h1>
        <p>Subtitle</p>
        <.button>Get started</.button>
      </.stack>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:direction, :atom,
    default: :vertical,
    values: [:vertical, :horizontal],
    doc: "Stack direction: `:vertical` (flex-col) or `:horizontal` (flex-row)."
  )

  attr(:gap, :integer, default: 4, doc: "Gap between children (0–12) → `gap-N`.")

  attr(:align, :atom,
    default: nil,
    values: [nil, :start, :center, :end, :stretch, :baseline],
    doc: "align-items value."
  )

  attr(:justify, :atom,
    default: nil,
    values: [nil, :start, :center, :end, :between, :around, :evenly],
    doc: "justify-content value."
  )

  attr(:wrap, :boolean, default: false, doc: "Allow children to wrap onto multiple lines.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Stack children.")

  @doc "Renders a flex stack container."
  def stack(assigns) do
    ~H"""
    <div
      class={cn([
        "flex",
        direction_class(@direction),
        "gap-#{@gap}",
        align_class(@align),
        justify_class(@justify),
        @wrap && "flex-wrap",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp direction_class(:vertical), do: "flex-col"
  defp direction_class(:horizontal), do: "flex-row"

  defp align_class(nil), do: nil
  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"
  defp align_class(:baseline), do: "items-baseline"

  defp justify_class(nil), do: nil
  defp justify_class(:start), do: "justify-start"
  defp justify_class(:center), do: "justify-center"
  defp justify_class(:end), do: "justify-end"
  defp justify_class(:between), do: "justify-between"
  defp justify_class(:around), do: "justify-around"
  defp justify_class(:evenly), do: "justify-evenly"
end
