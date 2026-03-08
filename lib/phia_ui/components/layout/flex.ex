defmodule PhiaUi.Components.Layout.Flex do
  @moduledoc """
  Full flexbox control component.

  Encodes all flexbox properties as typed attributes so you get autocomplete
  and compile-time validation rather than ad-hoc Tailwind strings.

  All layout attributes accept either a plain value (backward compatible) or a
  responsive map like `%{base: :col, md: :row}` for per-breakpoint control.

  ## Examples

      <%!-- Row with gap and centered alignment --%>
      <.flex gap={4} align={:center}>
        <.icon name="hero-user" />
        <span>Username</span>
      </.flex>

      <%!-- Column layout --%>
      <.flex direction={:col} gap={6}>
        <.card>A</.card>
        <.card>B</.card>
      </.flex>

      <%!-- Responsive direction: column on mobile, row from md up --%>
      <.flex direction={%{base: :col, md: :row}} gap={%{base: 2, lg: 4}}>
        <.card>A</.card>
        <.card>B</.card>
      </.flex>

      <%!-- Space-between toolbar --%>
      <.flex justify={:between} align={:center} class="px-4 h-14">
        <span>Logo</span>
        <nav>...</nav>
      </.flex>

      <%!-- Inline flex for badge composition --%>
      <.flex inline gap={1} align={:center}>
        <.badge>New</.badge>
        <span>Label</span>
      </.flex>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2]

  attr(:direction, :any,
    default: :row,
    doc: "Flex direction. Accepts atom or responsive map, e.g. `%{base: :col, md: :row}`."
  )

  attr(:wrap, :any,
    default: :nowrap,
    doc: "Flex wrap behavior. Accepts atom or responsive map."
  )

  attr(:gap, :any, default: nil, doc: "Uniform gap (0–12) → `gap-N`. Accepts integer or responsive map.")
  attr(:gap_x, :any, default: nil, doc: "Horizontal gap → `gap-x-N`. Accepts integer or responsive map.")
  attr(:gap_y, :any, default: nil, doc: "Vertical gap → `gap-y-N`. Accepts integer or responsive map.")

  attr(:align, :any,
    default: nil,
    doc: "align-items value. Accepts atom or responsive map."
  )

  attr(:justify, :any,
    default: nil,
    doc: "justify-content value. Accepts atom or responsive map."
  )

  attr(:grow, :boolean, default: false, doc: "Adds `flex-1` so the container grows.")

  attr(:inline, :boolean,
    default: false,
    doc: "Use `inline-flex` instead of `flex`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Flex children.")

  @doc "Renders a flex container with full property control."
  def flex(assigns) do
    ~H"""
    <div
      class={cn([
        flex_base(@inline),
        responsive(@direction, &direction_class/1),
        responsive(@wrap, &wrap_class/1),
        responsive(@gap, &gap_class/1),
        responsive(@gap_x, &gap_x_class/1),
        responsive(@gap_y, &gap_y_class/1),
        responsive(@align, &align_class/1),
        responsive(@justify, &justify_class/1),
        @grow && "flex-1",
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

  defp flex_base(false), do: "flex"
  defp flex_base(true), do: "inline-flex"

  defp direction_class(:row), do: "flex-row"
  defp direction_class(:col), do: "flex-col"
  defp direction_class(:row_reverse), do: "flex-row-reverse"
  defp direction_class(:col_reverse), do: "flex-col-reverse"

  defp wrap_class(:nowrap), do: nil
  defp wrap_class(:wrap), do: "flex-wrap"
  defp wrap_class(:wrap_reverse), do: "flex-wrap-reverse"

  defp gap_class(nil), do: nil
  defp gap_class(n), do: "gap-#{n}"

  defp gap_x_class(nil), do: nil
  defp gap_x_class(n), do: "gap-x-#{n}"

  defp gap_y_class(nil), do: nil
  defp gap_y_class(n), do: "gap-y-#{n}"

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
