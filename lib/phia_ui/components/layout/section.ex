defmodule PhiaUi.Components.Layout.Section do
  @moduledoc """
  Semantic `<section>` wrapper with size-based vertical padding.

  Encodes the design-system vertical rhythm so page sections stay consistent
  across the app without hand-picking `py-N` values on each template.

  | Size  | Padding |
  |-------|---------|
  | `:sm` | `py-6`  |
  | `:md` | `py-12` |
  | `:lg` | `py-16` |
  | `:xl` | `py-24` |

  ## Examples

      <.section size={:lg}>
        <.container>
          <h2 class="text-3xl font-bold">Features</h2>
        </.container>
      </.section>

      <.section size={:sm} class="bg-muted">
        <p>Compact announcement bar</p>
      </.section>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:size, :atom,
    default: :md,
    values: [:sm, :md, :lg, :xl],
    doc: "Vertical padding preset."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<section>` element.")

  slot(:inner_block, required: true, doc: "Section content.")

  @doc "Renders a semantic `<section>` with size-based vertical padding."
  def section(assigns) do
    ~H"""
    <section class={cn([section_class(@size), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  defp section_class(:sm), do: "py-6"
  defp section_class(:md), do: "py-12"
  defp section_class(:lg), do: "py-16"
  defp section_class(:xl), do: "py-24"
end
