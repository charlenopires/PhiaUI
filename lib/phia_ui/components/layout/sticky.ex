defmodule PhiaUi.Components.Layout.Sticky do
  @moduledoc """
  Sticky-positioned container that adheres to the top or bottom of the viewport
  as the user scrolls.

  Uses `position: sticky` so the element scrolls normally until it reaches the
  configured offset, then sticks in place. The parent must have overflow that
  allows sticky to work (i.e., not `overflow: hidden`).

  ## Examples

      <%!-- Sticky header inside a scrollable column --%>
      <.sticky position={:top} offset={0} z={20}>
        <.topbar title="Dashboard" />
      </.sticky>

      <%!-- Sticky at 64px (e.g., below a fixed 64px navbar) --%>
      <.sticky position={:top} offset={16}>
        <div class="bg-background border-b px-4 py-2">Filter bar</div>
      </.sticky>

      <%!-- Sticky footer actions inside a form panel --%>
      <.sticky position={:bottom} offset={0}>
        <div class="flex justify-end gap-2 p-4 bg-background border-t">
          <.button>Save</.button>
        </div>
      </.sticky>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:position, :atom,
    default: :top,
    values: [:top, :bottom],
    doc: "Which viewport edge to stick to."
  )

  attr(:offset, :integer,
    default: 0,
    doc: "Offset in Tailwind spacing units (0 = `top-0`, 4 = `top-4`, 16 = `top-16`, etc.)."
  )

  attr(:z, :integer,
    default: 10,
    values: [0, 10, 20, 30, 40, 50],
    doc: "z-index level."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Content to make sticky.")

  @doc "Renders a sticky-positioned container."
  def sticky(assigns) do
    ~H"""
    <div class={cn(["sticky", offset_class(@position, @offset), z_class(@z), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp offset_class(:top, 0), do: "top-0"
  defp offset_class(:top, n), do: "top-#{n}"
  defp offset_class(:bottom, 0), do: "bottom-0"
  defp offset_class(:bottom, n), do: "bottom-#{n}"

  defp z_class(0), do: "z-0"
  defp z_class(10), do: "z-10"
  defp z_class(20), do: "z-20"
  defp z_class(30), do: "z-30"
  defp z_class(40), do: "z-40"
  defp z_class(50), do: "z-50"
end
