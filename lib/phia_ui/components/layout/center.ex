defmodule PhiaUi.Components.Layout.Center do
  @moduledoc """
  Centers content both horizontally and vertically.

  Three variants cover the most common centering patterns:

  - `:default` — block flex container that fills its parent
  - `:inline` — inline-flex for use inside text or tightly-sized wrappers
  - `:absolute` — absolute inset-0 overlay (for centering over a positioned parent)

  ## Examples

      <%!-- Full-area centering --%>
      <.center class="h-64">
        <.spinner />
      </.center>

      <%!-- Inline centering for icon badges --%>
      <.center variant={:inline} class="h-8 w-8 rounded-full bg-primary">
        <.icon name="hero-check" class="text-primary-foreground" />
      </.center>

      <%!-- Absolute overlay loader --%>
      <div class="relative h-40">
        <.center variant={:absolute}>
          <.spinner />
        </.center>
      </div>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    default: :default,
    values: [:default, :inline, :absolute],
    doc: "Centering strategy: `default` (flex), `inline` (inline-flex), `absolute` (inset overlay)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Content to be centered.")

  @doc "Renders a centering container."
  def center(assigns) do
    ~H"""
    <div class={cn([center_class(@variant), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp center_class(:default), do: "flex items-center justify-center"
  defp center_class(:inline), do: "inline-flex items-center justify-center"
  defp center_class(:absolute), do: "absolute inset-0 flex items-center justify-center"
end
