defmodule PhiaUi.Components.Toc do
  @moduledoc """
  Sticky table of contents with scroll-spy via IntersectionObserver.

  Uses the `PhiaToc` hook from `priv/templates/js/hooks/toc.js`.
  The hook watches heading elements in the page and marks the active TOC link
  with `data-toc-active` as the user scrolls.

  Two components:

  - `toc/1` — the sticky nav container
  - `toc_item/1` — an individual TOC link with depth indent and active state
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # toc/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Required for phx-hook")
  attr(:title, :string, default: "On this page")
  attr(:sticky, :boolean, default: true, doc: "Adds sticky top-6 positioning")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "toc_item/1 children")

  @doc """
  Renders a sticky table of contents with IntersectionObserver scroll-spy.

  Place heading elements in the article with matching `id` attributes.
  The PhiaToc hook marks the visible heading's corresponding `toc_item` with
  `data-toc-active`, which triggers `data-[toc-active]:text-primary` styling.
  """
  def toc(assigns) do
    ~H"""
    <nav
      id={@id}
      phx-hook="PhiaToc"
      aria-label="Table of contents"
      class={cn([
        "text-sm",
        @sticky && "sticky top-6",
        @class
      ])}
      {@rest}
    >
      <p class="mb-3 text-sm font-semibold text-foreground">{@title}</p>
      <ul class="space-y-1">
        {render_slot(@inner_block)}
      </ul>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # toc_item/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "The heading element ID to scroll to (e.g. 'introduction')")
  attr(:depth, :integer, default: 1, doc: "Nesting depth: 1=H2, 2=H3, 3=H4")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders an individual table of contents link.

  The hook sets `data-toc-active` on the link corresponding to the currently
  visible heading, triggering the `data-[toc-active]:text-primary` style.
  """
  def toc_item(assigns) do
    ~H"""
    <li>
      <a
        href={"##{@id}"}
        data-toc-target={@id}
        class={cn([
          depth_indent(@depth),
          "block py-1 text-muted-foreground transition-colors",
          "hover:text-foreground",
          "data-[toc-active]:text-primary data-[toc-active]:font-medium",
          @class
        ])}
        {@rest}
      >
        {render_slot(@inner_block)}
      </a>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp depth_indent(1), do: "pl-0"
  defp depth_indent(2), do: "pl-4"
  defp depth_indent(3), do: "pl-8"
  defp depth_indent(_), do: "pl-8"
end
