defmodule PhiaUi.Components.Timeline do
  @moduledoc """
  Vertical timeline / activity feed component.

  Renders a vertical sequence of events with connecting lines, optional
  icons or dot markers, and timestamped content. CSS-only — no JavaScript
  required.

  ## Sub-components

  | Component        | Element | Purpose                                              |
  |------------------|---------|------------------------------------------------------|
  | `timeline/1`     | `<ol>`  | Ordered list container for the full event sequence   |
  | `timeline_item/1`| `<li>`  | Single event row with connector line, marker, content|

  ## Basic usage

      <.timeline>
        <.timeline_item timestamp="Just now">
          New comment added to ticket #1234.
        </.timeline_item>
        <.timeline_item timestamp="2 hours ago">
          Status changed from <strong>Open</strong> to <strong>In Progress</strong>.
        </.timeline_item>
        <.timeline_item timestamp="Yesterday">
          Ticket assigned to Jane Smith.
        </.timeline_item>
      </.timeline>

  ## With icons

  Provide a `<:icon>` slot to replace the default dot marker with an icon:

      <.timeline>
        <.timeline_item timestamp="10:32 AM">
          <:icon><.icon name="check-circle" size={:sm} class="text-green-500" /></:icon>
          Deployment completed successfully.
        </.timeline_item>
        <.timeline_item timestamp="10:15 AM">
          <:icon><.icon name="upload-cloud" size={:sm} class="text-blue-500" /></:icon>
          Build uploaded to staging environment.
        </.timeline_item>
        <.timeline_item timestamp="10:00 AM">
          <:icon><.icon name="git-commit" size={:sm} /></:icon>
          Commit <code>a3f9c2e</code> pushed to main.
        </.timeline_item>
      </.timeline>

  ## Order history / e-commerce tracking

      <.timeline>
        <.timeline_item timestamp="March 3, 2:14 PM">
          <:icon><.icon name="package-check" size={:sm} class="text-green-500" /></:icon>
          <strong>Delivered</strong> — Left at front door.
        </.timeline_item>
        <.timeline_item timestamp="March 3, 8:02 AM">
          <:icon><.icon name="truck" size={:sm} class="text-blue-500" /></:icon>
          <strong>Out for delivery</strong> — With courier.
        </.timeline_item>
        <.timeline_item timestamp="March 2, 11:45 PM">
          <:icon><.icon name="warehouse" size={:sm} /></:icon>
          <strong>In transit</strong> — Arrived at local facility.
        </.timeline_item>
        <.timeline_item timestamp="March 1, 9:30 AM">
          <:icon><.icon name="package" size={:sm} /></:icon>
          Order packed and ready for collection.
        </.timeline_item>
      </.timeline>

  ## Audit log / user activity feed

      <.timeline>
        <%= for event <- @audit_events do %>
          <.timeline_item timestamp={Calendar.strftime(event.inserted_at, "%b %d, %H:%M")}>
            <:icon>
              <.avatar size="sm">
                <.avatar_image src={event.user.avatar_url} alt={event.user.name} />
                <.avatar_fallback name={event.user.name} />
              </.avatar>
            </:icon>
            <span class="font-medium">{event.user.name}</span>
            {event.description}
          </.timeline_item>
        <% end %>
      </.timeline>

  ## How the connector line works

  Each `timeline_item/1` contains an absolutely-positioned `<span>` that draws
  a 1px `bg-border` line from just below the marker to the bottom of the item.
  The last item's connector is hidden via Tailwind's `last-of-type:hidden`
  utility, preventing a dangling line below the final event.

  ## Accessibility

  The `<ol>` element communicates that the events are ordered (chronological).
  Screen readers announce item count and position (e.g. "list item 1 of 5").
  Add `aria-label` to the `<ol>` via `:rest` when the context is not obvious:

      <.timeline aria-label="Order tracking events">
        ...
      </.timeline>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # timeline/1 — container
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the `<ol>` container.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<ol>` element (e.g. `aria-label`).")
  slot(:inner_block, required: true, doc: "`timeline_item/1` children, in display order (newest first or oldest first, your choice).")

  @doc """
  Renders a vertical timeline container.

  Uses `space-y-6` for comfortable vertical spacing between events.
  Place `timeline_item/1` components inside.
  """
  def timeline(assigns) do
    ~H"""
    <ol class={cn(["relative space-y-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # timeline_item/1 — single event
  # ---------------------------------------------------------------------------

  attr(:timestamp, :string, default: nil, doc: "Optional timestamp label displayed above the event content (e.g. `\"2 hours ago\"`, `\"March 3, 10:32 AM\"`). When `nil`, no timestamp is shown.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the `<li>` element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")
  slot(:icon, doc: "Optional icon or custom marker. When provided, replaces the default dot. Use `<.icon>`, `<.avatar>`, or any element. Sized to fit the 24×24px marker circle.")
  slot(:inner_block, required: true, doc: "Event description content. Supports any HEEx — plain text, formatted HTML, or components.")

  @doc """
  Renders a single event item in the timeline.

  Each item consists of three layers:

  1. **Connector line** — a 1px `bg-border` vertical line spanning from the
     marker to the next item. Hidden on the last item via `last-of-type:hidden`.
  2. **Marker** — a 24×24px circle (`ring-1 ring-border`) containing either
     the `:icon` slot content or a small primary-coloured dot.
  3. **Content** — optional timestamp in muted small text followed by the
     main event description.

  ## Example

      <.timeline_item timestamp="2 hours ago">
        <:icon>
          <.icon name="user-plus" size={:sm} class="text-primary" />
        </:icon>
        <strong>Jane Smith</strong> joined the organization.
      </.timeline_item>
  """
  def timeline_item(assigns) do
    ~H"""
    <li class={cn(["relative pl-8", @class])} {@rest}>
      <%!-- Connector line: runs from the bottom of the marker to the top of
           the next item. `last-of-type:hidden` removes it from the final item. --%>
      <span class="absolute left-3 top-5 -bottom-6 w-px bg-border last-of-type:hidden" aria-hidden="true" />

      <%!-- Marker circle: houses the icon slot or the default dot --%>
      <span class="absolute left-0 flex h-6 w-6 items-center justify-center rounded-full bg-background ring-1 ring-border">
        <%= if @icon != [] do %>
          <%!-- Custom icon: caller controls colour and size via the slot --%>
          {render_slot(@icon)}
        <% else %>
          <%!-- Default dot: small primary-coloured filled circle --%>
          <span class="h-2 w-2 rounded-full bg-primary" />
        <% end %>
      </span>

      <%!-- Content area: timestamp (optional) above the event description --%>
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
