defmodule PhiaUi.Components.Layout.Wrap do
  @moduledoc """
  Flex-wrap container for tags, chips, and button groups.

  Items wrap onto new lines automatically when they exceed the container width.
  Ideal for tag clouds, filter chips, and multi-select badge displays.

  All layout attributes accept either a plain value (backward compatible) or a
  responsive map like `%{base: 2, md: 4}` for per-breakpoint control.

  ## Examples

      <%!-- Tag cloud --%>
      <.wrap gap={2}>
        <%= for tag <- @tags do %>
          <.badge>{tag}</.badge>
        <% end %>
      </.wrap>

      <%!-- Responsive gap --%>
      <.wrap gap={%{base: 1, md: 2, lg: 3}}>
        <.chip>Design</.chip>
        <.chip>Engineering</.chip>
      </.wrap>

      <%!-- Centered chips --%>
      <.wrap justify={:center} gap={2}>
        <.chip>Design</.chip>
        <.chip>Engineering</.chip>
        <.chip>Product</.chip>
      </.wrap>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2]

  attr(:gap, :any, default: 2, doc: "Uniform gap (0–12) → `gap-N`. Accepts integer or responsive map.")
  attr(:gap_x, :any, default: nil, doc: "Horizontal gap → `gap-x-N`. Accepts integer or responsive map.")
  attr(:gap_y, :any, default: nil, doc: "Vertical gap → `gap-y-N`. Accepts integer or responsive map.")

  attr(:align, :any,
    default: :start,
    doc: "align-items value. Accepts atom or responsive map."
  )

  attr(:justify, :any,
    default: :start,
    doc: "justify-content value. Accepts atom or responsive map."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Wrappable children.")

  @doc "Renders a flex-wrap container."
  def wrap(assigns) do
    ~H"""
    <div
      class={cn([
        "flex flex-wrap",
        gap_responsive(@gap, @gap_x, @gap_y),
        responsive(@align, &align_class/1),
        responsive(@justify, &justify_class/1),
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

  # When gap_x or gap_y are provided (non-nil), use them instead of gap.
  # This preserves the original behavior where gap_x/gap_y override gap.
  defp gap_responsive(gap, nil, nil), do: responsive(gap, &gap_class/1)

  defp gap_responsive(_gap, gap_x, gap_y) do
    parts = [
      gap_x && responsive(gap_x, &gap_x_class/1),
      gap_y && responsive(gap_y, &gap_y_class/1)
    ]

    parts
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

  defp gap_class(n), do: "gap-#{n}"
  defp gap_x_class(n), do: "gap-x-#{n}"
  defp gap_y_class(n), do: "gap-y-#{n}"

  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"

  defp justify_class(:start), do: "justify-start"
  defp justify_class(:center), do: "justify-center"
  defp justify_class(:end), do: "justify-end"
  defp justify_class(:between), do: "justify-between"
  defp justify_class(:around), do: "justify-around"
end
