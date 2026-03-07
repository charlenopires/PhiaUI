defmodule PhiaUi.Components.Layout.Box do
  @moduledoc """
  Semantic HTML wrapper component with configurable element tag.

  `box` renders any HTML element specified via the `:as` attribute, defaulting
  to `div`. Use it to add semantic meaning (article, section, aside, main) to
  a container without losing access to PhiaUI's class merger.

  ## Examples

      <.box>content</.box>

      <.box as="article" class="p-4 rounded-lg border border-border">
        Card-like article
      </.box>

      <.box as="main" class="flex-1 overflow-auto">
        Main content area
      </.box>

      <.box as="aside" class="w-64 shrink-0">
        Sidebar
      </.box>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:as, :string,
    default: "div",
    values: ~w(div section article main aside header footer span p ul ol li nav figure),
    doc: "HTML element to render as."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Content rendered inside the element.")

  @doc "Renders a semantic HTML wrapper with a configurable tag."
  def box(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end
end
