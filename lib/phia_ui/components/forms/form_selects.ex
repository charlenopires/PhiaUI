defmodule PhiaUi.Components.FormSelects do
  @moduledoc """
  Selection group components: multi-checkbox groups, card-style radio groups,
  cascading selects, and dual-panel transfer lists.

  ## Components

  | Function | Purpose |
  |---|---|
  | `checkbox_group/1` | Multi-checkbox group with shared label/errors |
  | `checkbox_group_item/1` | Single item inside `checkbox_group` |
  | `form_checkbox_group/1` | Ecto-integrated checkbox group |
  | `radio_card/1` | Single card-style radio option |
  | `radio_card_group/1` | Container for `radio_card` items |
  | `form_radio_card_group/1` | Ecto-integrated radio card group |
  | `cascader/1` | Multi-level cascading select (PhiaCascader hook) |
  | `form_cascader/1` | Ecto-integrated cascader |
  | `button_transfer_list/1` | Dual-panel item mover (button-based, no DnD) |
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # checkbox_group/1
  # ---------------------------------------------------------------------------

  attr :label, :string, default: nil, doc: "Group legend text"
  attr :description, :string, default: nil, doc: "Helper text below the legend"
  attr :errors, :list, default: [], doc: "List of pre-translated error strings"
  attr :orientation, :string, default: "vertical", doc: "vertical | horizontal"
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders an accessible multi-checkbox group using `<fieldset>/<legend>`.

  ## Example

      <.checkbox_group label="Interests" orientation="horizontal">
        <.checkbox_group_item name="interests[]" value="elixir" label="Elixir" checked={true} />
        <.checkbox_group_item name="interests[]" value="rust" label="Rust" />
      </.checkbox_group>
  """
  def checkbox_group(assigns) do
    ~H"""
    <fieldset class={cn(["space-y-2", @class])}>
      <legend :if={@label} class="text-sm font-semibold text-foreground">{@label}</legend>
      <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      <div class={cn([
        if(@orientation == "horizontal", do: "flex flex-wrap gap-4", else: "flex flex-col gap-2")
      ])}>
        {render_slot(@inner_block)}
      </div>
      <p :for={error <- @errors} class="text-sm text-destructive">{error}</p>
    </fieldset>
    """
  end

  # ---------------------------------------------------------------------------
  # checkbox_group_item/1
  # ---------------------------------------------------------------------------

  attr :value, :string, required: true, doc: "Value submitted when checked"
  attr :label, :string, required: true, doc: "Label text next to the checkbox"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :name, :string, default: nil, doc: "Input name — use `name[]` for multi-value"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-click form)

  @doc """
  Renders a single checkbox option for use inside `checkbox_group/1`.
  """
  def checkbox_group_item(assigns) do
    ~H"""
    <label class={cn([
      "flex cursor-pointer select-none items-center gap-2 text-sm",
      @disabled && "cursor-not-allowed opacity-50",
      @class
    ])}>
      <input
        type="checkbox"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class={cn([
          "h-4 w-4 shrink-0 rounded-sm border border-primary accent-primary",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ])}
        {@rest}
      />
      <span class="text-foreground">{@label}</span>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # form_checkbox_group/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :options, :list, default: [], doc: "List of {label, value} tuples"
  attr :orientation, :string, default: "vertical"
  attr :class, :string, default: nil

  @doc """
  Renders a checkbox group integrated with `Phoenix.HTML.FormField`.

  The checked state of each item is derived by checking whether its value is
  included in `field.value` (which should be a list of selected values).

  ## Example

      <.form_checkbox_group
        field={@form[:roles]}
        label="Roles"
        options={[{"Admin", "admin"}, {"Editor", "editor"}, {"Viewer", "viewer"}]}
      />
  """
  def form_checkbox_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign(:selected, field.value |> List.wrap() |> Enum.map(&to_string/1))

    ~H"""
    <.checkbox_group
      label={@label}
      description={@description}
      errors={@errors}
      orientation={@orientation}
      class={@class}
    >
      <.checkbox_group_item
        :for={{opt_label, opt_value} <- @options}
        name={"#{@field.name}[]"}
        value={to_string(opt_value)}
        label={opt_label}
        checked={to_string(opt_value) in @selected}
      />
    </.checkbox_group>
    """
  end

  # ---------------------------------------------------------------------------
  # radio_card/1
  # ---------------------------------------------------------------------------

  attr :value, :string, required: true, doc: "Radio input value"
  attr :label, :string, required: true, doc: "Card heading text"
  attr :description, :string, default: nil, doc: "Optional card description"
  attr :checked, :boolean, default: false, doc: "Whether this card is the selected option"
  attr :disabled, :boolean, default: false
  attr :name, :string, default: nil, doc: "Radio input name — all cards in a group share one name"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-click form)

  slot :icon, doc: "Optional leading icon slot"

  @doc """
  Renders a card-style radio option with a hidden native `<input type="radio">`.

  Uses CSS `peer` + `peer-checked:*` classes for the selected border ring — no JS required.
  The ring overlay and check indicator are direct siblings of the hidden input to satisfy
  the CSS `~` sibling selector constraint.

  ## Example

      <.radio_card_group name="plan" value={@selected_plan}>
        <.radio_card name="plan" value="free" label="Free" description="Up to 5 projects" />
        <.radio_card name="plan" value="pro" label="Pro" description="Unlimited projects" />
      </.radio_card_group>
  """
  def radio_card(assigns) do
    ~H"""
    <label class={cn([
      "relative flex cursor-pointer rounded-lg border border-input bg-background p-4",
      "transition-colors hover:bg-accent/30",
      @disabled && "cursor-not-allowed opacity-50 pointer-events-none",
      @class
    ])}>
      <%!-- Hidden radio input — must be first child so peer-checked: works on siblings --%>
      <input
        type="radio"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class="peer sr-only"
        {@rest}
      />
      <%!-- Selected border overlay (direct sibling of .peer input) --%>
      <span class="pointer-events-none absolute inset-0 rounded-lg border-2 border-transparent peer-checked:border-primary transition-colors" />
      <%!-- Card content (direct sibling of .peer input) --%>
      <div class="flex w-full items-start gap-3">
        <span :if={@icon != []} class="mt-0.5 shrink-0 text-muted-foreground">
          {render_slot(@icon)}
        </span>
        <div class="flex-1 min-w-0">
          <span class="block text-sm font-medium text-foreground">{@label}</span>
          <span :if={@description} class="mt-0.5 block text-xs text-muted-foreground">
            {@description}
          </span>
        </div>
      </div>
      <%!-- Check dot indicator (direct sibling of .peer input) --%>
      <span class="pointer-events-none absolute right-4 top-4 h-4 w-4 rounded-full border-2 border-input transition-colors peer-checked:border-primary peer-checked:bg-primary" />
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # radio_card_group/1
  # ---------------------------------------------------------------------------

  attr :name, :string, required: true, doc: "Shared radio input name for all cards in the group"
  attr :value, :string, default: nil, doc: "Currently selected value (used to set checked state)"
  attr :orientation, :string, default: "vertical", doc: "vertical | horizontal (for stack layout)"
  attr :cols, :integer, default: 2, doc: "Grid columns when layout is 'grid' (2–4)"
  attr :layout, :string, default: "stack", doc: "stack | grid"
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a container for `radio_card/1` items with accessible `role="radiogroup"`.

  Use `layout="grid"` with `cols` for a multi-column card layout.
  """
  def radio_card_group(assigns) do
    ~H"""
    <div role="radiogroup" class={cn([radio_card_group_layout(@layout, @cols, @orientation), @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_radio_card_group/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :options, :list, required: true, doc: "List of {label, value} tuples or %{label:, value:, description:} maps"
  attr :cols, :integer, default: 2
  attr :layout, :string, default: "stack"
  attr :class, :string, default: nil

  @doc """
  Renders a radio card group integrated with `Phoenix.HTML.FormField`.
  """
  def form_radio_card_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <p :if={@label} class="text-sm font-semibold text-foreground">{@label}</p>
      <.radio_card_group name={@field.name} value={to_string(@field.value)} layout={@layout} cols={@cols} class={@class}>
        <.radio_card
          :for={opt <- normalize_card_options(@options)}
          name={@field.name}
          value={opt.value}
          label={opt.label}
          description={Map.get(opt, :description)}
          checked={to_string(@field.value) == opt.value}
        />
      </.radio_card_group>
      <p :for={error <- @errors} class="text-sm text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # cascader/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true, doc: "Required for phx-hook"
  attr :name, :string, default: nil, doc: "Hidden input name for form submission"
  attr :options, :list, default: [], doc: "List of {label, value} or {label, value, children} tuples"
  attr :value, :list, default: [], doc: "Current selection path as list of string values"
  attr :placeholder, :string, default: "Select..."
  attr :class, :string, default: nil

  @doc """
  Renders a multi-level cascading select powered by the `PhiaCascader` JS hook.

  Options are passed as JSON via `data-options`. The hook builds drill-down panels
  client-side. Sends `cascader-select` push events with `{level, value}` on each pick.

  ## Example

      <.cascader
        id="category"
        name="category"
        options={[
          {"Electronics", "electronics", [
            {"Phones", "phones", []},
            {"Laptops", "laptops", []}
          ]},
          {"Clothing", "clothing", []}
        ]}
        value={@selected_path}
      />
  """
  def cascader(assigns) do
    options_json = assigns.options |> format_cascader_options() |> Jason.encode!()
    assigns = assign(assigns, :options_json, options_json)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCascader"
      data-options={@options_json}
      data-value={Jason.encode!(@value)}
      class={cn(["relative inline-block w-full z-50", @class])}
    >
      <%!-- Trigger button --%>
      <button
        type="button"
        data-cascader-trigger
        class={cn([
          "flex h-10 w-full items-center justify-between rounded-md border border-input",
          "bg-background px-3 py-2 text-sm",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ])}
      >
        <span data-cascader-display class="min-w-0 truncate text-muted-foreground">
          {if @value == [], do: @placeholder, else: Enum.join(@value, " / ")}
        </span>
        <svg
          class="ml-2 h-4 w-4 shrink-0 text-muted-foreground"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>

      <%!-- Hidden input for form submission --%>
      <input
        :if={@name}
        type="hidden"
        name={@name}
        value={List.last(@value) || ""}
        data-cascader-input
      />

      <%!-- Panels container — JS builds and populates columns from data-options --%>
      <div
        data-cascader-panels
        class="absolute z-50 mt-1 hidden min-w-[200px] rounded-md border border-border bg-popover shadow-md"
      >
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_cascader/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :options, :list, default: []
  attr :placeholder, :string, default: "Select..."
  attr :class, :string, default: nil

  @doc """
  Renders a cascader integrated with `Phoenix.HTML.FormField`.
  """
  def form_cascader(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@field.id} class="text-sm font-semibold text-foreground">
        {@label}
      </label>
      <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      <.cascader
        id={@field.id}
        name={@field.name}
        options={@options}
        value={List.wrap(@field.value)}
        placeholder={@placeholder}
        class={@class}
      />
      <p :for={error <- @errors} class="text-sm text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # button_transfer_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :source_items, :list, default: [], doc: "List of {label, value} tuples in the source panel"
  attr :target_items, :list, default: [], doc: "List of {label, value} tuples in the target panel"
  attr :source_label, :string, default: "Available"
  attr :target_label, :string, default: "Selected"
  attr :class, :string, default: nil

  @doc """
  Renders a dual-panel item mover using `>>` / `>` / `<` / `<<` arrow buttons.

  No drag-and-drop required — simpler than `drag_transfer_list`. Moves are triggered
  by `phx-click` events that your LiveView handles to update the two item lists.

  ## Example

      <.button_transfer_list
        id="permissions"
        source_items={@available_permissions}
        target_items={@granted_permissions}
        source_label="Available permissions"
        target_label="Granted permissions"
      />
  """
  def button_transfer_list(assigns) do
    id = assigns.id || "btl-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <div id={@id} class={cn(["flex items-stretch gap-3", @class])}>
      <%!-- Source panel --%>
      <div class="flex-1 overflow-hidden rounded-md border border-input">
        <div class="border-b border-input bg-muted/40 px-3 py-2">
          <span class="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            {@source_label} ({length(@source_items)})
          </span>
        </div>
        <ul class="h-48 overflow-auto p-1">
          <li
            :for={{label, value} <- @source_items}
            data-transfer-source={value}
            class="cursor-pointer rounded px-2 py-1.5 text-sm hover:bg-accent hover:text-accent-foreground"
          >
            {label}
          </li>
        </ul>
      </div>

      <%!-- Control buttons --%>
      <div class="flex flex-col items-center justify-center gap-1.5">
        <button
          type="button"
          phx-click="transfer_move_selected"
          phx-value-direction="to_target"
          phx-value-id={@id}
          title="Move selected to target"
          class={cn([
            "flex h-8 w-8 items-center justify-center rounded border border-input bg-background text-sm font-medium",
            "hover:bg-accent hover:text-accent-foreground"
          ])}
        >
          &rsaquo;
        </button>
        <button
          type="button"
          phx-click="transfer_move_all"
          phx-value-direction="to_target"
          phx-value-id={@id}
          title="Move all to target"
          class={cn([
            "flex h-8 w-8 items-center justify-center rounded border border-input bg-background text-sm font-medium",
            "hover:bg-accent hover:text-accent-foreground"
          ])}
        >
          &raquo;
        </button>
        <button
          type="button"
          phx-click="transfer_move_all"
          phx-value-direction="to_source"
          phx-value-id={@id}
          title="Move all to source"
          class={cn([
            "flex h-8 w-8 items-center justify-center rounded border border-input bg-background text-sm font-medium",
            "hover:bg-accent hover:text-accent-foreground"
          ])}
        >
          &laquo;
        </button>
        <button
          type="button"
          phx-click="transfer_move_selected"
          phx-value-direction="to_source"
          phx-value-id={@id}
          title="Move selected to source"
          class={cn([
            "flex h-8 w-8 items-center justify-center rounded border border-input bg-background text-sm font-medium",
            "hover:bg-accent hover:text-accent-foreground"
          ])}
        >
          &lsaquo;
        </button>
      </div>

      <%!-- Target panel --%>
      <div class="flex-1 overflow-hidden rounded-md border border-input">
        <div class="border-b border-input bg-muted/40 px-3 py-2">
          <span class="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            {@target_label} ({length(@target_items)})
          </span>
        </div>
        <ul class="h-48 overflow-auto p-1">
          <li
            :for={{label, value} <- @target_items}
            data-transfer-target={value}
            class="cursor-pointer rounded px-2 py-1.5 text-sm hover:bg-accent hover:text-accent-foreground"
          >
            {label}
          </li>
        </ul>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp radio_card_group_layout("grid", 2, _), do: "grid grid-cols-2 gap-3"
  defp radio_card_group_layout("grid", 3, _), do: "grid grid-cols-3 gap-3"
  defp radio_card_group_layout("grid", 4, _), do: "grid grid-cols-4 gap-3"
  defp radio_card_group_layout("grid", _, _), do: "grid grid-cols-2 gap-3"
  defp radio_card_group_layout(_, _, "horizontal"), do: "flex flex-row flex-wrap gap-3"
  defp radio_card_group_layout(_, _, _), do: "flex flex-col gap-3"

  defp normalize_card_options(options) do
    Enum.map(options, fn
      {label, value} -> %{label: label, value: to_string(value)}
      %{} = map -> Map.update!(map, :value, &to_string/1)
    end)
  end

  defp format_cascader_options(options) do
    Enum.map(options, fn
      {label, value} ->
        %{label: label, value: to_string(value), children: []}

      {label, value, children} ->
        %{label: label, value: to_string(value), children: format_cascader_options(children)}

      %{label: label, value: value} = opt ->
        children = Map.get(opt, :children, [])
        %{label: label, value: to_string(value), children: format_cascader_options(children)}
    end)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
