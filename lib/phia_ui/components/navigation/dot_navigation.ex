defmodule PhiaUi.Components.DotNavigation do
  @moduledoc """
  Dot-style page indicator navigation component.

  Provides two components:

  - `dot_navigation/1` — container nav with alignment and gap controls
  - `dot_navigation_item/1` — individual dot rendered as `<a>` or `<button>`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # dot_navigation/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:variant, :atom, values: [:circle, :pill, :dash], default: :circle)
  attr(:align, :atom, values: [:center, :start, :end], default: :center)
  attr(:gap, :atom, values: [:sm, :md, :lg], default: :md)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def dot_navigation(assigns) do
    ~H"""
    <nav
      class={cn([
        "flex items-center",
        dot_nav_align_class(@align),
        dot_nav_gap_class(@gap),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # dot_navigation_item/1
  # ---------------------------------------------------------------------------

  attr(:active, :boolean, default: false)
  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:variant, :atom, values: [:circle, :pill, :dash], default: :circle)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def dot_navigation_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        aria-label={@label}
        aria-current={@active && "page"}
        class={cn([
          "block transition-colors",
          dot_item_size_class(@variant),
          @active && "bg-primary",
          !@active && "bg-muted hover:bg-muted-foreground/50",
          @class
        ])}
        {@rest}
      ></a>
    <% else %>
      <button
        type="button"
        aria-label={@label}
        aria-current={@active && "page"}
        phx-click={@on_click}
        class={cn([
          "block transition-colors",
          dot_item_size_class(@variant),
          @active && "bg-primary",
          !@active && "bg-muted hover:bg-muted-foreground/50",
          @class
        ])}
        {@rest}
      ></button>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp dot_nav_align_class(:center), do: "justify-center"
  defp dot_nav_align_class(:start), do: "justify-start"
  defp dot_nav_align_class(:end), do: "justify-end"

  defp dot_nav_gap_class(:sm), do: "gap-1"
  defp dot_nav_gap_class(:md), do: "gap-2"
  defp dot_nav_gap_class(:lg), do: "gap-3"

  defp dot_item_size_class(:circle), do: "size-2 rounded-full"
  defp dot_item_size_class(:pill), do: "h-2 w-4 rounded-full"
  defp dot_item_size_class(:dash), do: "h-0.5 w-4"
end
