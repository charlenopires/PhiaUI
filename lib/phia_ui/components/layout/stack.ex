defmodule PhiaUi.Components.Layout.Stack do
  @moduledoc """
  Vertical or horizontal flex stack with consistent gap.

  `stack` is the workhorse layout component for most page regions. Use
  `:vertical` (default) for stacked sections and `:horizontal` for inline
  groups of elements.

  All layout attributes accept either a plain value (backward compatible) or a
  responsive map like `%{base: :vertical, md: :horizontal}` for per-breakpoint
  control.

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

      <%!-- Responsive: stack vertically on mobile, horizontal from md --%>
      <.stack direction={%{base: :vertical, md: :horizontal}} gap={%{base: 2, md: 4}}>
        <.card>A</.card>
        <.card>B</.card>
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
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2]

  attr(:direction, :any,
    default: :vertical,
    doc: "Stack direction. Accepts atom or responsive map, e.g. `%{base: :vertical, md: :horizontal}`."
  )

  attr(:gap, :any, default: 4, doc: "Gap between children (0–12) → `gap-N`. Accepts integer or responsive map.")

  attr(:align, :any,
    default: nil,
    doc: "align-items value. Accepts atom or responsive map."
  )

  attr(:justify, :any,
    default: nil,
    doc: "justify-content value. Accepts atom or responsive map."
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
        responsive(@direction, &direction_class/1),
        responsive(@gap, &gap_class/1),
        responsive(@align, &align_class/1),
        responsive(@justify, &justify_class/1),
        @wrap && "flex-wrap",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp responsive(value, mapper) do
    resolve_responsive(value, mapper)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

  defp direction_class(:vertical), do: "flex-col"
  defp direction_class(:horizontal), do: "flex-row"

  defp gap_class(nil), do: nil
  defp gap_class(n), do: "gap-#{n}"

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
