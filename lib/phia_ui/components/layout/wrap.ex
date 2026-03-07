defmodule PhiaUi.Components.Layout.Wrap do
  @moduledoc """
  Flex-wrap container for tags, chips, and button groups.

  Items wrap onto new lines automatically when they exceed the container width.
  Ideal for tag clouds, filter chips, and multi-select badge displays.

  ## Examples

      <%!-- Tag cloud --%>
      <.wrap gap={2}>
        <%= for tag <- @tags do %>
          <.badge>{tag}</.badge>
        <% end %>
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

  attr(:gap, :integer, default: 2, doc: "Uniform gap (0–12) → `gap-N`.")
  attr(:gap_x, :integer, default: nil, doc: "Horizontal gap → `gap-x-N`.")
  attr(:gap_y, :integer, default: nil, doc: "Vertical gap → `gap-y-N`.")

  attr(:align, :atom,
    default: :start,
    values: [:start, :center, :end, :stretch],
    doc: "align-items value."
  )

  attr(:justify, :atom,
    default: :start,
    values: [:start, :center, :end, :between, :around],
    doc: "justify-content value."
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
        gap_class(@gap, @gap_x, @gap_y),
        align_class(@align),
        justify_class(@justify),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp gap_class(gap, nil, nil), do: "gap-#{gap}"

  defp gap_class(_gap, gap_x, gap_y) do
    [gap_x && "gap-x-#{gap_x}", gap_y && "gap-y-#{gap_y}"]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

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
