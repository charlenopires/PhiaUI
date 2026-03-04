defmodule PhiaUi.Components.FilterBuilder do
  @moduledoc """
  FilterBuilder component for PhiaUI.

  An advanced query-builder UI for constructing dynamic filter rules. Each rule
  is a row of: field selector + operator selector + value input + remove button.
  New rules are added via a button that fires a server event.

  ## Sub-components

  - `filter_builder/1` — root wrapper, rule list + "Add filter" button
  - `filter_rule/1` — individual rule row (field / operator / value / remove)

  ## Example

      <.filter_builder
        fields={[
          %{name: "status", label: "Status", type: "select",
            options: [{"Active", "active"}, {"Inactive", "inactive"}]},
          %{name: "name",   label: "Name",   type: "text"},
          %{name: "date",   label: "Date",   type: "date"}
        ]}
        rules={@filter_rules}
        on_add="add_filter_rule"
        on_remove="remove_filter_rule"
        on_change="update_filter_rule"
      />

  ## LiveView handlers

      def handle_event("add_filter_rule", _params, socket) do
        rule = %{id: Ecto.UUID.generate(), field: "name", operator: "contains", value: ""}
        {:noreply, update(socket, :filter_rules, &[rule | &1])}
      end

      def handle_event("remove_filter_rule", %{"id" => id}, socket) do
        {:noreply, update(socket, :filter_rules, &Enum.reject(&1, fn r -> r.id == id end))}
      end

      def handle_event("update_filter_rule", params, socket) do
        # params contains field/operator/value for the rule identified by phx-value-id
        {:noreply, socket}
      end

  ## Field schema

  Each field map in the `fields` list should contain:
  - `:name` — unique field identifier (string)
  - `:label` — display name (string)
  - `:type` — "text" | "select" | "date" | "number"
  - `:options` — list of `{label, value}` tuples (only for type "select")
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # filter_builder/1
  # ---------------------------------------------------------------------------

  attr(:fields, :list,
    required: true,
    doc: "List of %{name, label, type, options?} maps describing filterable fields"
  )

  attr(:rules, :list,
    default: [],
    doc: "List of %{id, field, operator, value} maps — one per active rule row"
  )

  attr(:on_add, :string, required: true, doc: "phx-click event to add a new rule")

  attr(:on_remove, :string,
    required: true,
    doc: "phx-click event to remove a rule (phx-value-id)"
  )

  attr(:on_change, :string, required: true, doc: "phx-change event when a rule field changes")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders the filter builder container.

  Renders existing rules as `filter_rule/1` rows and an "Add filter" button
  to append new rules. Entirely server-driven — no JS hook required.
  """
  def filter_builder(assigns) do
    ~H"""
    <div class={cn(["flex flex-col gap-2", @class])} {@rest}>
      <%!-- Rule rows --%>
      <div :if={@rules != []} class="flex flex-col gap-2">
        <.filter_rule
          :for={rule <- @rules}
          id={rule.id}
          field={rule.field}
          operator={rule.operator}
          value={rule.value}
          fields={@fields}
          on_remove={@on_remove}
          on_change={@on_change}
        />
      </div>

      <%!-- Add filter button --%>
      <button
        type="button"
        phx-click={@on_add}
        class={cn([
          "inline-flex w-fit items-center gap-1.5 rounded-md border border-dashed",
          "border-border px-3 py-1.5 text-sm text-muted-foreground",
          "hover:border-foreground hover:text-foreground transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ])}
      >
        <.icon name="plus" size={:xs} />
        Add filter
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # filter_rule/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Unique rule identifier (passed as phx-value-id on remove)"
  )

  attr(:field, :string,
    required: true,
    doc: "Currently selected field name (must match a name in the fields list)"
  )

  attr(:operator, :string, required: true, doc: "Currently selected operator")
  attr(:value, :string, default: "", doc: "Current filter value")

  attr(:fields, :list,
    required: true,
    doc: "List of available field definitions (same format as filter_builder)"
  )

  attr(:on_remove, :string, required: true, doc: "phx-click event to remove this rule")
  attr(:on_change, :string, required: true, doc: "phx-change event fired when any field changes")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the row wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the row div")

  @doc """
  Renders a single filter rule row.

  Displays a field selector, operator selector, value input, and a remove button.
  The component derives operators and value input type from the selected field's type.
  """
  def filter_rule(assigns) do
    assigns = assign(assigns, :current_field, find_field(assigns.fields, assigns.field))

    ~H"""
    <div
      class={cn([
        "flex flex-wrap items-center gap-2 rounded-md border border-border",
        "bg-background px-3 py-2",
        @class
      ])}
      {@rest}
    >
      <%!-- Field selector --%>
      <select
        name={"filter[#{@id}][field]"}
        phx-change={@on_change}
        phx-value-id={@id}
        class={cn([
          "h-8 rounded border border-input bg-background px-2 text-sm",
          "text-foreground focus-visible:outline-none focus-visible:ring-1",
          "focus-visible:ring-ring"
        ])}
      >
        <option :for={f <- @fields} value={f.name} selected={f.name == @field}>
          {f.label}
        </option>
      </select>

      <%!-- Operator selector --%>
      <select
        name={"filter[#{@id}][operator]"}
        phx-change={@on_change}
        phx-value-id={@id}
        class={cn([
          "h-8 rounded border border-input bg-background px-2 text-sm",
          "text-foreground focus-visible:outline-none focus-visible:ring-1",
          "focus-visible:ring-ring"
        ])}
      >
        <option
          :for={{op_label, op_value} <- operators_for(@current_field)}
          value={op_value}
          selected={op_value == @operator}
        >
          {op_label}
        </option>
      </select>

      <%!-- Value input --%>
      <.rule_value_input
        id={@id}
        current_field={@current_field}
        value={@value}
        on_change={@on_change}
      />

      <%!-- Remove button --%>
      <button
        type="button"
        phx-click={@on_remove}
        phx-value-id={@id}
        aria-label="Remove filter rule"
        class={cn([
          "ml-auto rounded p-1 text-muted-foreground",
          "hover:bg-muted hover:text-foreground transition-colors",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        ])}
      >
        <.icon name="x" size={:xs} />
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private — rule value input
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:current_field, :map, default: nil)
  attr(:value, :string, required: true)
  attr(:on_change, :string, required: true)

  defp rule_value_input(%{current_field: %{type: "select", options: options}} = assigns) do
    assigns = assign(assigns, :options, options)

    ~H"""
    <select
      name={"filter[#{@id}][value]"}
      phx-change={@on_change}
      phx-value-id={@id}
      class={cn([
        "h-8 rounded border border-input bg-background px-2 text-sm",
        "text-foreground focus-visible:outline-none focus-visible:ring-1",
        "focus-visible:ring-ring"
      ])}
    >
      <option :for={{opt_label, opt_value} <- @options} value={opt_value} selected={opt_value == @value}>
        {opt_label}
      </option>
    </select>
    """
  end

  defp rule_value_input(%{current_field: %{type: "date"}} = assigns) do
    ~H"""
    <input
      type="date"
      name={"filter[#{@id}][value]"}
      value={@value}
      phx-change={@on_change}
      phx-value-id={@id}
      class={cn([
        "h-8 rounded border border-input bg-background px-2 text-sm",
        "text-foreground focus-visible:outline-none focus-visible:ring-1",
        "focus-visible:ring-ring"
      ])}
    />
    """
  end

  defp rule_value_input(%{current_field: %{type: "number"}} = assigns) do
    ~H"""
    <input
      type="number"
      name={"filter[#{@id}][value]"}
      value={@value}
      phx-change={@on_change}
      phx-value-id={@id}
      class={cn([
        "h-8 w-28 rounded border border-input bg-background px-2 text-sm",
        "text-foreground focus-visible:outline-none focus-visible:ring-1",
        "focus-visible:ring-ring"
      ])}
    />
    """
  end

  defp rule_value_input(assigns) do
    ~H"""
    <input
      type="text"
      name={"filter[#{@id}][value]"}
      value={@value}
      phx-change={@on_change}
      phx-value-id={@id}
      class={cn([
        "h-8 rounded border border-input bg-background px-2 text-sm",
        "text-foreground placeholder:text-muted-foreground",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      ])}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp find_field(fields, field_name) do
    Enum.find(fields, fn f -> f.name == field_name end)
  end

  defp operators_for(%{type: "select"}),
    do: [{"equals", "equals"}, {"not equals", "not_equals"}]

  defp operators_for(%{type: "date"}),
    do: [
      {"equals", "equals"},
      {"before", "before"},
      {"after", "after"},
      {"between", "between"}
    ]

  defp operators_for(%{type: "number"}),
    do: [
      {"equals", "equals"},
      {"greater than", "gt"},
      {"less than", "lt"},
      {"between", "between"}
    ]

  defp operators_for(_text_or_nil),
    do: [
      {"contains", "contains"},
      {"equals", "equals"},
      {"starts with", "starts_with"},
      {"ends with", "ends_with"},
      {"is empty", "is_empty"}
    ]
end
