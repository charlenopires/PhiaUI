defmodule PhiaUi.Components.SegmentedControl do
  @moduledoc """
  Segmented control component for Phoenix LiveView.

  Renders a set of mutually-exclusive options as pill-style tabs. Each segment
  is a hidden radio input + visible label styled with Tailwind semantic tokens.
  The active segment is highlighted server-side based on the `:value` attribute —
  no JavaScript required.

  ## API

      <.segmented_control
        id="view-mode"
        name="view"
        value={@view}
        on_change="change_view"
        segments={[
          %{value: "list", label: "List"},
          %{value: "grid", label: "Grid"},
          %{value: "kanban", label: "Kanban"}
        ]}
      />

  When a label is clicked, the `on_change` event is dispatched via `phx-click`
  with `phx-value-value` set to the segment value, so the LiveView handler
  receives `%{"value" => "grid"}` in `handle_event/3`.

  ## Segments list

  Each segment map must have `:value` and `:label` keys. An optional `:disabled`
  boolean key (default `false`) disables the individual option:

      segments={[
        %{value: "active", label: "Active"},
        %{value: "archived", label: "Archived", disabled: true}
      ]}

  ## Sizes

  | Size       | Label classes           |
  |------------|-------------------------|
  | `:sm`      | `text-xs px-2 py-0.5`   |
  | `:default` | `text-sm px-3 py-1`     |
  | `:lg`      | `text-base px-4 py-1.5` |

  ## Accessibility

  - `role="group"` on the container groups items for assistive technologies
  - Native `<input type="radio">` hidden with `sr-only` handles keyboard
    navigation and screen reader announcements
  - Labels are associated to inputs via `for`/`id`
  - Disabled segments have the native `disabled` attribute on the input and
    `cursor-not-allowed opacity-50` on the label

  ## Examples

      <%!-- Basic view switcher --%>
      <.segmented_control
        id="view"
        name="view"
        value={@view_mode}
        on_change="set_view"
        segments={[
          %{value: "list", label: "List"},
          %{value: "grid", label: "Grid"}
        ]}
      />

      <%!-- Compact size --%>
      <.segmented_control
        id="density"
        name="density"
        value={@density}
        size={:sm}
        on_change="set_density"
        segments={[
          %{value: "compact", label: "Compact"},
          %{value: "comfortable", label: "Comfortable"}
        ]}
      />

      <%!-- With a disabled option --%>
      <.segmented_control
        id="period"
        name="period"
        value={@period}
        on_change="set_period"
        segments={[
          %{value: "day", label: "Day"},
          %{value: "week", label: "Week"},
          %{value: "month", label: "Month"},
          %{value: "year", label: "Year", disabled: true}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # segmented_control/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique HTML id for the container. Also used as a prefix for individual
    segment input ids: `\#{id}-\#{segment.value}`.
    """
  )

  attr(:name, :string,
    required: true,
    doc: "HTML `name` attribute shared by all radio inputs in the group."
  )

  attr(:value, :string,
    default: nil,
    doc: "The currently selected segment value. Segment with matching value renders as active."
  )

  attr(:on_change, :string,
    default: nil,
    doc: """
    LiveView event name dispatched via `phx-click` when a segment label is
    clicked. The event is sent with `phx-value-value` set to the clicked
    segment's value. Pass `nil` (default) to render a static control.
    """
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size variant controlling label padding and font size."
  )

  attr(:segments, :list,
    default: [],
    doc: """
    List of segment maps. Each map must have `:value` and `:label` keys.
    An optional `:disabled` boolean key (default `false`) disables that option.

    Example: `[%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta", disabled: true}]`
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged onto the container `<div>`."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the container `<div>` (aria-label, data-*, etc.)"
  )

  @doc """
  Renders a segmented control — a group of mutually-exclusive tab-style buttons.

  Each segment is rendered as a hidden `<input type="radio">` paired with a
  visible `<label>`. The active segment is highlighted server-side based on the
  `:value` attribute. Use `:on_change` to wire up LiveView events.

  ## Examples

      <.segmented_control
        id="view"
        name="view"
        value={@view}
        on_change="set_view"
        segments={[
          %{value: "list", label: "List"},
          %{value: "grid", label: "Grid"},
          %{value: "kanban", label: "Kanban"}
        ]}
      />
  """
  def segmented_control(assigns) do
    ~H"""
    <div
      role="group"
      class={cn(["inline-flex items-center rounded-lg bg-muted p-1 gap-1", @class])}
      {@rest}
    >
      <%= for segment <- @segments do %>
        <% seg_value = Map.get(segment, :value)
           seg_label = Map.get(segment, :label)
           seg_disabled = Map.get(segment, :disabled, false)
           seg_id = "#{@id}-#{seg_value}"
           active = seg_value == @value %>
        <input
          type="radio"
          id={seg_id}
          name={@name}
          value={seg_value}
          checked={active}
          disabled={seg_disabled}
          class="sr-only"
        />
        <label
          for={seg_id}
          phx-click={@on_change}
          phx-value-value={seg_value}
          class={cn([
            "cursor-pointer rounded-md font-medium transition-all",
            size_class(@size),
            if(active,
              do: "bg-background text-foreground shadow-sm",
              else: "text-muted-foreground hover:text-foreground"
            ),
            seg_disabled && "cursor-not-allowed opacity-50 pointer-events-none"
          ])}
        >
          {seg_label}
        </label>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp size_class(:sm), do: "text-xs px-2 py-0.5"
  defp size_class(:default), do: "text-sm px-3 py-1"
  defp size_class(:lg), do: "text-base px-4 py-1.5"
end
