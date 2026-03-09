defmodule PhiaUi.Components.Layout.SectionHeader do
  @moduledoc """
  Section heading with optional description and action area.

  Used for content sections within a page — distinct from `page_header`
  which spans the full page width with breadcrumbs.

  ## Examples

      <.section_header title="Team Members" />

      <.section_header title="Recent Activity" description="Last 30 days of changes">
        <:actions>
          <.button size={:sm}>View All</.button>
        </:actions>
      </.section_header>

      <.section_header title="Settings" size={:lg} divider>
        <:badge><.badge>Beta</.badge></:badge>
      </.section_header>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Section heading text"
  attr :description, :string, default: nil, doc: "Optional description below heading"
  attr :size, :atom, values: [:sm, :default, :lg], default: :default
  attr :divider, :boolean, default: false, doc: "Show bottom border"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :actions, doc: "Action buttons (right side)"
  slot :badge, doc: "Optional badge next to title"

  def section_header(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-start justify-between gap-4",
        @divider && "border-b border-border pb-4",
        @class
      ])}
      {@rest}
    >
      <div class="min-w-0 flex-1">
        <div class="flex items-center gap-2">
          <h3 class={cn([heading_size(@size)])}>
            {@title}
          </h3>
          <%= for badge <- @badge do %>
            {render_slot(badge)}
          <% end %>
        </div>
        <%= if @description do %>
          <p class={cn(["mt-1 text-muted-foreground", desc_size(@size)])}>
            {@description}
          </p>
        <% end %>
      </div>
      <%= for actions <- @actions do %>
        <div class="flex shrink-0 items-center gap-2">
          {render_slot(actions)}
        </div>
      <% end %>
    </div>
    """
  end

  defp heading_size(:sm), do: "text-sm font-semibold text-foreground"
  defp heading_size(:default), do: "text-base font-semibold text-foreground"
  defp heading_size(:lg), do: "text-lg font-semibold text-foreground"

  defp desc_size(:sm), do: "text-xs"
  defp desc_size(:default), do: "text-sm"
  defp desc_size(:lg), do: "text-sm"
end
