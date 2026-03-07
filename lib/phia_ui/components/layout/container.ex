defmodule PhiaUi.Components.Layout.Container do
  @moduledoc """
  Max-width content constrainer with responsive size presets.

  Wraps page content in a centered, max-width constrained block. Designed for
  full-width page sections that need their content capped at a readable width.

  | Size    | Max-width            |
  |---------|----------------------|
  | `:sm`   | `max-w-screen-sm`    |
  | `:md`   | `max-w-screen-md`    |
  | `:lg`   | `max-w-screen-lg`    |
  | `:xl`   | `max-w-screen-xl`    |
  | `:"2xl"`| `max-w-screen-2xl`   |
  | `:full` | `max-w-full`         |
  | `:fluid`| unconstrained        |

  ## Examples

      <.container>
        <h1>Page content</h1>
      </.container>

      <.container size={:xl} class="py-8">
        <.simple_grid cols={3} gap={4}>
          ...
        </.simple_grid>
      </.container>

      <%!-- Full-width, no centering --%>
      <.container size={:fluid} centered={false} padding={false}>
        <canvas id="chart" />
      </.container>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:size, :atom,
    default: :lg,
    values: [:sm, :md, :lg, :xl, :"2xl", :full, :fluid],
    doc: "Max-width preset."
  )

  attr(:centered, :boolean, default: true, doc: "Adds `mx-auto` to center horizontally.")

  attr(:padding, :boolean,
    default: true,
    doc: "Adds `px-4 sm:px-6 lg:px-8` horizontal padding."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Content to constrain.")

  @doc "Renders a max-width content container."
  def container(assigns) do
    ~H"""
    <div
      class={cn([
        "w-full",
        size_class(@size),
        @centered && "mx-auto",
        @padding && "px-4 sm:px-6 lg:px-8",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp size_class(:sm), do: "max-w-screen-sm"
  defp size_class(:md), do: "max-w-screen-md"
  defp size_class(:lg), do: "max-w-screen-lg"
  defp size_class(:xl), do: "max-w-screen-xl"
  defp size_class(:"2xl"), do: "max-w-screen-2xl"
  defp size_class(:full), do: "max-w-full"
  defp size_class(:fluid), do: nil
end
