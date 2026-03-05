defmodule PhiaUi.Components.FloatButton do
  @moduledoc """
  Floating Action Button (FAB) component with optional speed-dial.

  Follows the Material Design / shadcn/ui FAB pattern adapted for Phoenix
  LiveView. Supports a simple single-button form and a speed-dial form with
  a main trigger button and one or more action items.

  ## Simple button

      <.float_button icon="plus" on_click="new_item" aria_label="Create new item" />

  ## Speed dial

      <.float_button position={:bottom_right}>
        <:main icon="menu" aria_label="Actions" />
        <:item icon="edit" on_click="edit" label="Edit" />
        <:item icon="share" on_click="share" label="Share" />
      </.float_button>

  ## Positions

  | Atom            | CSS classes          |
  |-----------------|----------------------|
  | `:bottom_right` | `bottom-6 right-6`   |
  | `:bottom_left`  | `bottom-6 left-6`    |
  | `:top_right`    | `top-6 right-6`      |
  | `:top_left`     | `top-6 left-6`       |

  ## Theme tokens

  - `bg-primary` / `text-primary-foreground` — main button background
  - `bg-secondary` / `text-secondary-foreground` — speed-dial item buttons
  - `hover:bg-primary/90` / `hover:bg-secondary/90` — hover states
  - `shadow-lg` / `shadow` — elevation
  - `focus-visible:ring-ring` — keyboard focus ring
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:icon, :string,
    default: nil,
    doc: "Lucide icon name to render inside the simple button (e.g. `\"plus\"`, `\"menu\"`)"
  )

  attr(:on_click, :string,
    default: nil,
    doc: "LiveView event name passed to `phx-click`"
  )

  attr(:aria_label, :string,
    default: "Action",
    doc: "Accessible label for the button; used by screen readers"
  )

  attr(:position, :atom,
    values: [:bottom_right, :bottom_left, :top_right, :top_left],
    default: :bottom_right,
    doc: "Fixed position of the FAB in the viewport"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1` (last wins)"
  )

  slot(:main,
    doc: "Main trigger button for speed-dial mode. Provide `:icon` and `:aria_label` attrs."
  ) do
    attr(:icon, :string, doc: "Lucide icon name for the main trigger button")
    attr(:aria_label, :string, doc: "Accessible label for the main trigger button")
  end

  slot(:item, doc: "Speed-dial action item. Provide `:icon`, `:on_click`, and `:label` attrs.") do
    attr(:icon, :string, doc: "Lucide icon name for the item button")
    attr(:on_click, :string, doc: "LiveView event name passed to `phx-click` for this item")
    attr(:label, :string, doc: "Visible label text rendered beside the item button")
  end

  @doc """
  Renders a Floating Action Button (FAB).

  When neither `main` nor `item` slots are provided, renders a simple
  circular button fixed to the specified corner of the viewport.

  When `main` or `item` slots are provided, renders a speed-dial: a
  vertically stacked group of action items revealed above the main trigger
  button.

  ## Examples

      <%!-- Simple FAB --%>
      <.float_button icon="plus" on_click="new_item" aria_label="Create new item" />

      <%!-- Top-left FAB --%>
      <.float_button icon="plus" on_click="new_item" position={:top_left} />

      <%!-- Speed-dial FAB --%>
      <.float_button position={:bottom_right}>
        <:main icon="menu" aria_label="Actions" />
        <:item icon="edit" on_click="edit" label="Edit" />
        <:item icon="share" on_click="share" label="Share" />
      </.float_button>
  """

  # Speed-dial form: at least one `main` or `item` slot provided.
  def float_button(%{main: [_ | _]} = assigns), do: render_speed_dial(assigns)
  def float_button(%{item: [_ | _]} = assigns), do: render_speed_dial(assigns)

  # Simple button form: no slots.
  def float_button(assigns), do: render_simple(assigns)

  # ---------------------------------------------------------------------------
  # Private render helpers
  # ---------------------------------------------------------------------------

  defp render_simple(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      aria-label={@aria_label}
      class={cn([
        "fixed",
        position_class(@position),
        "h-14 w-14 rounded-full",
        "bg-primary text-primary-foreground shadow-lg",
        "hover:bg-primary/90",
        "flex items-center justify-center",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @class
      ])}
    >
      <%= if @icon do %>
        <.icon name={@icon} class="h-6 w-6" />
      <% end %>
      <span class="sr-only">{@aria_label}</span>
    </button>
    """
  end

  defp render_speed_dial(assigns) do
    main_slot = List.first(assigns.main) || %{}
    main_aria_label = Map.get(main_slot, :aria_label, "Actions")
    main_icon = Map.get(main_slot, :icon, nil)

    assigns =
      assigns
      |> assign(:main_aria_label, main_aria_label)
      |> assign(:main_icon, main_icon)

    ~H"""
    <div class={cn([
      "fixed",
      position_class(@position),
      "flex flex-col-reverse items-center gap-3",
      @class
    ])}>
      <%!-- Speed-dial items rendered above the main button --%>
      <div class="flex flex-col-reverse gap-2" data-speed-dial-items>
        <%= for item <- @item do %>
          <div class="flex items-center gap-2">
            <span class="text-sm bg-background border border-border rounded px-2 py-1 shadow-sm">
              {Map.get(item, :label, "")}
            </span>
            <button
              type="button"
              phx-click={Map.get(item, :on_click)}
              aria-label={Map.get(item, :label, "")}
              class="h-10 w-10 rounded-full bg-secondary text-secondary-foreground shadow hover:bg-secondary/90 flex items-center justify-center focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              <%= if Map.get(item, :icon) do %>
                <.icon name={Map.get(item, :icon)} class="h-5 w-5" />
              <% end %>
            </button>
          </div>
        <% end %>
      </div>
      <%!-- Main trigger button --%>
      <button
        type="button"
        aria-label={@main_aria_label}
        aria-expanded="false"
        class="h-14 w-14 rounded-full bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 flex items-center justify-center focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      >
        <%= if @main_icon do %>
          <.icon name={@main_icon} class="h-6 w-6" />
        <% end %>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — pattern-matched, no case/cond
  # ---------------------------------------------------------------------------

  defp position_class(:bottom_right), do: "bottom-6 right-6"
  defp position_class(:bottom_left), do: "bottom-6 left-6"
  defp position_class(:top_right), do: "top-6 right-6"
  defp position_class(:top_left), do: "top-6 left-6"
end
