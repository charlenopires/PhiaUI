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

      <%!-- Fluid padding: scales from px-4 to px-8 automatically --%>
      <.container fluid_padding>
        <h1>Smoothly scaled padding</h1>
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

  attr(:fluid_padding, :boolean,
    default: false,
    doc: "Uses CSS clamp-based fluid padding that scales smoothly between breakpoints. Overrides `:padding` when enabled."
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
        padding_class(@padding, @fluid_padding),
        @class
      ])}
      style={fluid_padding_style(@fluid_padding)}
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

  # When fluid_padding is on, padding is handled via inline style (clamp).
  defp padding_class(_padding, true), do: nil
  defp padding_class(true, false), do: "px-4 sm:px-6 lg:px-8"
  defp padding_class(false, false), do: nil

  # clamp(1rem, 2vw + 0.5rem, 2rem) scales from 16px to 32px fluidly.
  defp fluid_padding_style(true), do: "padding-inline: clamp(1rem, 2vw + 0.5rem, 2rem)"
  defp fluid_padding_style(false), do: nil
end
