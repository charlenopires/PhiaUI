defmodule PhiaUi.Components.Layout.FixedBar do
  @moduledoc """
  Fixed-positioned bar anchored to the top or bottom of the viewport.

  Spans the full width of the viewport (`inset-x-0`) and sits above page
  content via a configurable z-index. Useful for mobile CTA bars, persistent
  navigation, or cookie-consent banners.

  ## Examples

      <%!-- Fixed top navigation --%>
      <.fixed_bar position={:top} z={50}>
        <div class="max-w-screen-xl mx-auto px-4 flex items-center justify-between h-16">
          <span class="font-bold">Logo</span>
          <nav>...</nav>
        </div>
      </.fixed_bar>

      <%!-- Mobile bottom CTA --%>
      <.fixed_bar position={:bottom} class="p-4">
        <.button class="w-full">Buy now</.button>
      </.fixed_bar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:position, :atom,
    default: :bottom,
    values: [:top, :bottom],
    doc: "Viewport edge to anchor to."
  )

  attr(:z, :integer,
    default: 40,
    values: [0, 10, 20, 30, 40, 50],
    doc: "z-index level."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Bar content.")

  @doc "Renders a fixed-positioned full-width bar."
  def fixed_bar(assigns) do
    ~H"""
    <div
      class={cn([
        "fixed inset-x-0",
        position_class(@position),
        z_class(@z),
        "bg-background",
        border_class(@position),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp position_class(:top), do: "top-0"
  defp position_class(:bottom), do: "bottom-0"

  defp border_class(:top), do: "border-b border-border"
  defp border_class(:bottom), do: "border-t border-border"

  defp z_class(0), do: "z-0"
  defp z_class(10), do: "z-10"
  defp z_class(20), do: "z-20"
  defp z_class(30), do: "z-30"
  defp z_class(40), do: "z-40"
  defp z_class(50), do: "z-50"
end
