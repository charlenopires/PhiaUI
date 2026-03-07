defmodule PhiaUi.Components.SegmentedControl do
  @moduledoc """
  Segmented control component for Phoenix LiveView.

  Renders a set of mutually-exclusive options as pill-style tabs. Each segment
  is a hidden radio input + visible label styled with Tailwind semantic tokens.
  The active segment is highlighted server-side based on the `:value` attribute —
  no JavaScript required.

  ## Enhancements

  - `:orientation` — `:horizontal` (default) or `:vertical` (stacks segments)
  - `icon` key in segment maps — renders an icon before the label

  ## API

      <.segmented_control
        id="view-mode"
        name="view"
        value={@view}
        on_change="change_view"
        segments={[
          %{value: "list", label: "List"},
          %{value: "grid", label: "Grid", icon: "grid-2x2"},
          %{value: "kanban", label: "Kanban"}
        ]}
      />

      <%!-- Vertical layout --%>
      <.segmented_control
        id="nav"
        name="nav"
        value={@section}
        orientation={:vertical}
        on_change="set_section"
        segments={[
          %{value: "profile", label: "Profile"},
          %{value: "security", label: "Security"}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # segmented_control/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique HTML id for the container.")
  attr(:name, :string, required: true, doc: "HTML `name` attribute shared by all radio inputs.")

  attr(:value, :string,
    default: nil,
    doc: "The currently selected segment value."
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event name dispatched via `phx-click` when a segment label is clicked."
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size variant controlling label padding and font size."
  )

  attr(:orientation, :atom,
    values: [:horizontal, :vertical],
    default: :horizontal,
    doc: "Layout orientation — `:horizontal` (default) or `:vertical` (stacks segments)."
  )

  attr(:segments, :list,
    default: [],
    doc: """
    List of segment maps. Required keys: `:value`, `:label`.
    Optional keys: `:disabled` (boolean), `:icon` (Lucide icon name string).
    Example: `[%{value: "a", label: "Alpha", icon: "star"}, %{value: "b", label: "Beta"}]`
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged onto the container `<div>`.")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the container `<div>`."
  )

  @doc """
  Renders a segmented control — a group of mutually-exclusive tab-style buttons.
  """
  def segmented_control(assigns) do
    ~H"""
    <div
      role="group"
      class={cn([container_class(@orientation), @class])}
      {@rest}
    >
      <%= for segment <- @segments do %>
        <% seg_value = Map.get(segment, :value)
           seg_label = Map.get(segment, :label)
           seg_disabled = Map.get(segment, :disabled, false)
           seg_icon = Map.get(segment, :icon)
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
            "cursor-pointer rounded-md font-medium transition-all flex items-center gap-1",
            size_class(@size),
            @orientation == :vertical && "w-full justify-start",
            if(active,
              do: "bg-background text-foreground shadow-sm",
              else: "text-muted-foreground hover:text-foreground"
            ),
            seg_disabled && "cursor-not-allowed opacity-50 pointer-events-none"
          ])}
        >
          <.icon :if={seg_icon} name={seg_icon} class="h-4 w-4 shrink-0" />
          {seg_label}
        </label>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp container_class(:vertical),
    do: "inline-flex flex-col rounded-lg bg-muted p-1 gap-1"

  defp container_class(_),
    do: "inline-flex items-center rounded-lg bg-muted p-1 gap-1"

  defp size_class(:sm), do: "text-xs px-2 py-0.5"
  defp size_class(:default), do: "text-sm px-3 py-1"
  defp size_class(:lg), do: "text-base px-4 py-1.5"
end
