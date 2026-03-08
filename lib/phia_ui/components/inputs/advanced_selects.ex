defmodule PhiaUi.Components.AdvancedSelects do
  @moduledoc """
  Advanced select components for PhiaUI.

  Provides three higher-level selection patterns beyond the native `<select>`:

  - `tree_select/1` + `tree_select_option/1` — hierarchical dropdown with
    expand/collapse via the `PhiaTreeSelect` JS hook.
  - `rich_select/1` + `rich_select_option/1` — visible option list where each
    option has an avatar/icon, title, and optional description. Pure HEEx.
  - `visual_select/1` + `visual_select_item/1` — grid of image/icon tiles backed
    by radio inputs. Pure HEEx.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tree_select/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID — required for PhiaTreeSelect hook.")

  attr(:value, :string,
    default: nil,
    doc: "Currently selected node value."
  )

  attr(:placeholder, :string,
    default: "Select…",
    doc: "Text shown when no value is selected."
  )

  attr(:options, :list,
    default: [],
    doc: """
    Nested option list. Each map: `%{label: String, value: String, children: [...]}`.
    Children are optional.
    """
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event name fired when a node is selected."
  )

  attr(:disabled, :boolean, default: false, doc: "Disables the trigger.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes on the root element.")

  @doc """
  Renders a hierarchical tree-select dropdown.

  The trigger button opens a popover panel. Nodes with children show an expand
  toggle. Selecting a leaf fires `on_change` via the `PhiaTreeSelect` JS hook.
  The tree structure is passed via `data-options` (JSON) and rendered client-side.
  A hidden `<input>` carries the selected value for form submission.
  """
  def tree_select(assigns) do
    selected_label = find_label(assigns.options, assigns.value)
    assigns = assign(assigns, :selected_label, selected_label)

    ~H"""
    <div
      id={@id}
      class={cn(["relative inline-block z-50", @class])}
      phx-hook="PhiaTreeSelect"
      data-options={Jason.encode!(@options)}
      data-value={@value}
      data-on-change={@on_change}
    >
      <button
        type="button"
        disabled={@disabled}
        class={cn([
          "inline-flex items-center justify-between w-full min-w-48 px-3 py-2 text-sm",
          "border border-border rounded-md bg-background text-foreground",
          "hover:bg-accent hover:text-accent-foreground",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50"
        ])}
        aria-haspopup="tree"
        aria-expanded="false"
        data-tree-trigger
      >
        <span class={cn([@value == nil && "text-muted-foreground"])}>
          {@selected_label || @placeholder}
        </span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4 ml-2 shrink-0 opacity-50"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          aria-hidden="true"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>

      <div
        class="hidden absolute z-50 mt-1 w-full min-w-48 max-h-64 overflow-auto rounded-md border border-border bg-popover shadow-md"
        data-tree-panel
        role="tree"
      >
        <div class="p-1">
          <%= for option <- @options do %>
            <.tree_select_option
              option={option}
              selected_value={@value}
              level={0}
              id_prefix={@id}
            />
          <% end %>
        </div>
      </div>

      <input type="hidden" name={@on_change && "#{@on_change}_value"} value={@value} data-tree-input />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # tree_select_option/1
  # ---------------------------------------------------------------------------

  attr(:option, :map, required: true, doc: "Option map: `%{label, value, children: [...]}`.")
  attr(:selected_value, :string, default: nil, doc: "Currently selected value.")
  attr(:level, :integer, default: 0, doc: "Nesting depth (0 = root).")
  attr(:id_prefix, :string, default: "ts", doc: "ID prefix for expand toggles.")

  @doc """
  Renders a single tree node: expand toggle (if children) + clickable label.
  Children are rendered recursively, initially hidden (managed by JS hook).
  """
  def tree_select_option(assigns) do
    children = Map.get(assigns.option, :children, [])
    has_children = children != []
    opt_value = Map.get(assigns.option, :value, "")
    opt_label = Map.get(assigns.option, :label, "")
    is_active = opt_value == assigns.selected_value
    assigns =
      assigns
      |> assign(:children, children)
      |> assign(:has_children, has_children)
      |> assign(:opt_value, opt_value)
      |> assign(:opt_label, opt_label)
      |> assign(:is_active, is_active)

    ~H"""
    <div data-tree-node data-value={@opt_value} data-has-children={to_string(@has_children)}>
      <div
        class={cn([
          "flex items-center gap-1 px-2 py-1.5 text-sm rounded-sm cursor-pointer",
          "hover:bg-accent hover:text-accent-foreground",
          @is_active && "bg-accent font-medium",
          "select-none"
        ])}
        style={"padding-left: #{8 + @level * 16}px"}
        data-tree-row
      >
        <%= if @has_children do %>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-3 w-3 shrink-0 transition-transform"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            data-tree-chevron
            aria-hidden="true"
          >
            <path d="m9 18 6-6-6-6" />
          </svg>
        <% else %>
          <span class="w-3 shrink-0"></span>
        <% end %>
        <span>{@opt_label}</span>
      </div>

      <div class="hidden" data-tree-children>
        <%= for child <- @children do %>
          <.tree_select_option
            option={child}
            selected_value={@selected_value}
            level={@level + 1}
            id_prefix={@id_prefix}
          />
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # rich_select/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id for the fieldset.")

  attr(:value, :string,
    default: nil,
    doc: "Currently selected option value."
  )

  attr(:name, :string,
    default: "rich_select",
    doc: "Name attribute for the hidden radio inputs."
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event name fired via `phx-click` when an option is selected."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Optional prompt text shown above the options list (aria-label fallback)."
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of option maps. Supported keys:
    - `:value` (required) — option value string
    - `:label` (required) — display title
    - `:description` — optional subtitle text
    - `:icon` — Lucide icon name string
    - `:avatar_src` — URL for an avatar image
    """
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Controls option row height and text size."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders a visible list of rich radio options — each with avatar/icon + title + description.
  Pure HEEx, no JS required. Use `phx-click` or wrap in a Phoenix form for submission.
  """
  def rich_select(assigns) do
    ~H"""
    <fieldset
      id={@id}
      class={cn(["space-y-1", @class])}
      aria-label={@placeholder || "Select an option"}
    >
      <%= for opt <- @options do %>
        <% opt_val = Map.get(opt, :value, "")
           opt_label = Map.get(opt, :label, "")
           opt_desc = Map.get(opt, :description)
           opt_icon = Map.get(opt, :icon)
           opt_avatar = Map.get(opt, :avatar_src)
           is_active = opt_val == @value
           input_id = "#{@id || @name}-#{opt_val}" %>
        <label
          for={input_id}
          phx-click={@on_change}
          phx-value-value={opt_val}
          class={cn([
            "flex items-center gap-3 px-3 rounded-lg border cursor-pointer transition-colors",
            rich_size_class(@size),
            if(is_active,
              do: "border-primary bg-primary/5 text-foreground",
              else: "border-border bg-background hover:bg-accent hover:text-accent-foreground"
            )
          ])}
        >
          <input
            type="radio"
            id={input_id}
            name={@name}
            value={opt_val}
            checked={is_active}
            class="sr-only"
          />
          <%= if opt_avatar do %>
            <img
              src={opt_avatar}
              alt=""
              class={cn(["rounded-full object-cover shrink-0", rich_avatar_class(@size)])}
              aria-hidden="true"
            />
          <% end %>
          <div class="flex-1 min-w-0">
            <p class={cn(["font-medium truncate", is_active && "text-primary"])}>
              {opt_label}
            </p>
            <p :if={opt_desc} class="text-xs text-muted-foreground truncate">
              {opt_desc}
            </p>
          </div>
          <svg
            :if={is_active}
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 text-primary shrink-0"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
          >
            <path d="M20 6 9 17l-5-5" />
          </svg>
        </label>
      <% end %>
    </fieldset>
    """
  end

  # ---------------------------------------------------------------------------
  # rich_select_option/1
  # ---------------------------------------------------------------------------

  attr(:value, :string, required: true, doc: "Option value.")
  attr(:label, :string, required: true, doc: "Display title.")
  attr(:description, :string, default: nil, doc: "Optional subtitle text.")
  attr(:icon, :string, default: nil, doc: "Lucide icon name.")
  attr(:avatar_src, :string, default: nil, doc: "Avatar image URL.")
  attr(:selected, :boolean, default: false, doc: "Whether this option is currently selected.")
  attr(:name, :string, default: "rich_select", doc: "Radio input name.")
  attr(:on_change, :string, default: nil, doc: "LiveView event name.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Standalone rich select option row — for composable usage outside `rich_select/1`.
  """
  def rich_select_option(assigns) do
    input_id = "rs-#{assigns.name}-#{assigns.value}"
    assigns = assign(assigns, :input_id, input_id)

    ~H"""
    <label
      for={@input_id}
      phx-click={@on_change}
      phx-value-value={@value}
      class={cn([
        "flex items-center gap-3 px-3 py-2 rounded-lg border cursor-pointer transition-colors",
        if(@selected,
          do: "border-primary bg-primary/5",
          else: "border-border bg-background hover:bg-accent"
        ),
        @class
      ])}
    >
      <input
        type="radio"
        id={@input_id}
        name={@name}
        value={@value}
        checked={@selected}
        class="sr-only"
      />
      <%= if @avatar_src do %>
        <img src={@avatar_src} alt="" class="h-8 w-8 rounded-full object-cover shrink-0" aria-hidden="true" />
      <% end %>
      <div class="flex-1 min-w-0">
        <p class={cn(["font-medium truncate text-sm", @selected && "text-primary"])}>{@label}</p>
        <p :if={@description} class="text-xs text-muted-foreground truncate">{@description}</p>
      </div>
      <svg
        :if={@selected}
        xmlns="http://www.w3.org/2000/svg"
        class="h-4 w-4 text-primary shrink-0"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        aria-hidden="true"
      >
        <path d="M20 6 9 17l-5-5" />
      </svg>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # visual_select/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id for the fieldset.")
  attr(:name, :string, required: true, doc: "Name attribute for the radio inputs.")
  attr(:value, :string, default: nil, doc: "Currently selected option value.")

  attr(:cols, :integer,
    default: 3,
    doc: "Number of grid columns (2, 3, or 4)."
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of option maps. Supported keys:
    - `:value` (required)
    - `:label` — display text below the tile
    - `:icon` — Lucide icon name (shown if no image)
    - `:image_src` — image URL for the tile thumbnail
    - `:description` — small descriptive text
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes on the grid container.")

  @doc """
  Renders a grid of visual radio-backed option tiles.
  Each tile can display an image, an icon, a label, and a description.
  Pure HEEx — no JS required.
  """
  def visual_select(assigns) do
    ~H"""
    <fieldset
      id={@id}
      class={cn([grid_cols_class(@cols), "gap-3", @class])}
      aria-label="Select an option"
    >
      <%= for opt <- @options do %>
        <% opt_val = Map.get(opt, :value, "")
           opt_label = Map.get(opt, :label)
           opt_desc = Map.get(opt, :description)
           opt_img = Map.get(opt, :image_src)
           is_active = opt_val == @value
           input_id = "#{@id || @name}-vs-#{opt_val}" %>
        <label
          for={input_id}
          class={cn([
            "relative flex flex-col items-center gap-2 p-3 rounded-lg border cursor-pointer",
            "transition-colors text-center",
            if(is_active,
              do: "border-primary bg-primary/5 ring-2 ring-primary/20",
              else: "border-border bg-background hover:bg-accent"
            )
          ])}
        >
          <input
            type="radio"
            id={input_id}
            name={@name}
            value={opt_val}
            checked={is_active}
            class="sr-only peer"
          />
          <%= if opt_img do %>
            <img
              src={opt_img}
              alt={opt_label || ""}
              class="h-12 w-full object-cover rounded"
            />
          <% else %>
            <div class={cn([
              "h-12 w-full rounded flex items-center justify-center",
              if(is_active, do: "bg-primary/10", else: "bg-muted")
            ])}>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class={cn(["h-6 w-6", if(is_active, do: "text-primary", else: "text-muted-foreground")])}
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                aria-hidden="true"
              >
                <rect width="7" height="7" x="3" y="3" rx="1" />
                <rect width="7" height="7" x="14" y="3" rx="1" />
                <rect width="7" height="7" x="14" y="14" rx="1" />
                <rect width="7" height="7" x="3" y="14" rx="1" />
              </svg>
            </div>
          <% end %>
          <p :if={opt_label} class="text-xs font-medium leading-tight">{opt_label}</p>
          <p :if={opt_desc} class="text-xs text-muted-foreground leading-tight">{opt_desc}</p>
          <svg
            :if={is_active}
            xmlns="http://www.w3.org/2000/svg"
            class="absolute top-1.5 right-1.5 h-3.5 w-3.5 text-primary"
            viewBox="0 0 24 24"
            fill="currentColor"
            aria-hidden="true"
          >
            <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm-1.5 14.5-4-4 1.41-1.41L10.5 13.67l6.09-6.08 1.41 1.41z" />
          </svg>
        </label>
      <% end %>
    </fieldset>
    """
  end

  # ---------------------------------------------------------------------------
  # visual_select_item/1
  # ---------------------------------------------------------------------------

  attr(:value, :string, required: true, doc: "Option value.")
  attr(:label, :string, default: nil, doc: "Display label below the tile.")
  attr(:image_src, :string, default: nil, doc: "Thumbnail image URL.")
  attr(:description, :string, default: nil, doc: "Small descriptive text.")
  attr(:selected, :boolean, default: false, doc: "Whether this item is currently selected.")
  attr(:name, :string, default: "visual_select", doc: "Radio input name.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Standalone visual select tile — for composable usage outside `visual_select/1`.
  """
  def visual_select_item(assigns) do
    input_id = "vsi-#{assigns.name}-#{assigns.value}"
    assigns = assign(assigns, :input_id, input_id)

    ~H"""
    <label
      for={@input_id}
      class={cn([
        "relative flex flex-col items-center gap-2 p-3 rounded-lg border cursor-pointer transition-colors text-center",
        if(@selected,
          do: "border-primary bg-primary/5 ring-2 ring-primary/20",
          else: "border-border bg-background hover:bg-accent"
        ),
        @class
      ])}
    >
      <input
        type="radio"
        id={@input_id}
        name={@name}
        value={@value}
        checked={@selected}
        class="sr-only"
      />
      <%= if @image_src do %>
        <img src={@image_src} alt={@label || ""} class="h-12 w-full object-cover rounded" />
      <% else %>
        <div class={cn(["h-12 w-full rounded flex items-center justify-center", if(@selected, do: "bg-primary/10", else: "bg-muted")])}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class={cn(["h-6 w-6", if(@selected, do: "text-primary", else: "text-muted-foreground")])}
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
          >
            <rect width="7" height="7" x="3" y="3" rx="1" />
            <rect width="7" height="7" x="14" y="3" rx="1" />
            <rect width="7" height="7" x="14" y="14" rx="1" />
            <rect width="7" height="7" x="3" y="14" rx="1" />
          </svg>
        </div>
      <% end %>
      <p :if={@label} class="text-xs font-medium leading-tight">{@label}</p>
      <p :if={@description} class="text-xs text-muted-foreground leading-tight">{@description}</p>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp grid_cols_class(2), do: "grid grid-cols-2"
  defp grid_cols_class(4), do: "grid grid-cols-4"
  defp grid_cols_class(_), do: "grid grid-cols-3"

  defp rich_size_class(:sm), do: "py-1.5"
  defp rich_size_class(:lg), do: "py-3"
  defp rich_size_class(_), do: "py-2"

  defp rich_avatar_class(:sm), do: "h-6 w-6"
  defp rich_avatar_class(:lg), do: "h-10 w-10"
  defp rich_avatar_class(_), do: "h-8 w-8"

  defp find_label([], _value), do: nil

  defp find_label([opt | rest], value) do
    opt_value = Map.get(opt, :value)
    opt_label = Map.get(opt, :label)
    children = Map.get(opt, :children, [])

    cond do
      opt_value == value -> opt_label
      children != [] -> find_label(children, value) || find_label(rest, value)
      true -> find_label(rest, value)
    end
  end
end
