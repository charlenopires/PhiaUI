defmodule PhiaUi.Components.Timeline do
  @moduledoc """
  Timeline / Activity feed component for PhiaUI.

  Renders a vertical timeline of events using CSS-only techniques.
  Each `timeline_item/1` shows a connector line, an optional icon/dot,
  and arbitrary content with an optional timestamp.

  CSS-only — no JS hook required.

  ## Sub-components

  - `timeline/1` — root `<ol>` container
  - `timeline_item/1` — individual event row with connector, marker, and content

  ## Examples

      <.timeline>
        <.timeline_item timestamp="2 hours ago">
          <:icon>
            <.icon name="check-circle" size="sm" />
          </:icon>
          Account created successfully.
        </.timeline_item>

        <.timeline_item timestamp="1 day ago">
          Profile updated.
        </.timeline_item>
      </.timeline>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the timeline container")
  attr(:rest, :global, doc: "HTML attributes forwarded to the ol element")
  slot(:inner_block, required: true, doc: "timeline_item children")

  @doc """
  Renders a vertical timeline container. Place `timeline_item/1` components inside.
  """
  def timeline(assigns) do
    ~H"""
    <ol class={cn(["relative space-y-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end

  attr(:timestamp, :string, default: nil, doc: "Optional timestamp label (e.g. \"2 hours ago\")")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the item")
  attr(:rest, :global, doc: "HTML attributes forwarded to the li element")
  slot(:icon, doc: "Optional icon or dot displayed in the timeline marker")
  slot(:inner_block, required: true, doc: "Item content")

  @doc """
  Renders a single item in the timeline.

  Use the `:icon` slot to place an icon or custom marker. Without an icon,
  a default dot is rendered. The connector line is drawn via a `<span>`
  pseudo-element on the marker.
  """
  def timeline_item(assigns) do
    ~H"""
    <li class={cn(["relative pl-8", @class])} {@rest}>
      <%!-- Vertical connector line --%>
      <span class="absolute left-3 top-5 -bottom-6 w-px bg-border last-of-type:hidden" aria-hidden="true" />
      <%!-- Marker / icon --%>
      <span class="absolute left-0 flex h-6 w-6 items-center justify-center rounded-full bg-background ring-1 ring-border">
        <%= if @icon != [] do %>
          {render_slot(@icon)}
        <% else %>
          <span class="h-2 w-2 rounded-full bg-primary" />
        <% end %>
      </span>
      <%!-- Content --%>
      <div class="space-y-1">
        <p :if={@timestamp} class="text-xs text-muted-foreground">
          {@timestamp}
        </p>
        <div class="text-sm text-foreground">
          {render_slot(@inner_block)}
        </div>
      </div>
    </li>
    """
  end
end
