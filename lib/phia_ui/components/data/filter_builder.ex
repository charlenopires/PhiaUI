defmodule PhiaUi.Components.FilterBuilder do
  @moduledoc """
  FilterBuilder component for PhiaUI.

  An advanced query-builder UI for constructing multi-condition filter rules
  at runtime. Each rule is a row containing:

  1. A **field selector** — which column/attribute to filter on
  2. An **operator selector** — how to compare (contains, equals, before, etc.)
  3. A **value input** — the comparison value (text, date, number, or select)
  4. A **remove button** — delete this rule

  New rules are added via an "Add filter" button that fires a server event.
  The entire state is owned by the LiveView — no client-side JS is required.

  ## When to use

  Use `FilterBuilder` for power-user search and reporting interfaces where
  users need to combine multiple conditions — like the filter panels in
  Notion, Linear, Airtable, or an admin reporting dashboard.

  For simple search + status dropdowns, use `FilterBar` instead.

  ## Anatomy

  | Component         | Element | Purpose                                         |
  |-------------------|---------|-------------------------------------------------|
  | `filter_builder/1`| `div`   | Root container: rule list + "Add filter" button |
  | `filter_rule/1`   | `div`   | One rule row: field / operator / value / remove |

  ## Field schema

  Each entry in the `fields` list is a map with:

  | Key        | Type                       | Required | Description                          |
  |------------|----------------------------|----------|--------------------------------------|
  | `:name`    | `String.t()`               | yes      | Unique field identifier              |
  | `:label`   | `String.t()`               | yes      | Display name in the field dropdown   |
  | `:type`    | `"text" | "select" | "date" | "number"` | yes | Controls available operators and value input |
  | `:options` | `[{label, value}]`         | only for `"select"` | Options for the value dropdown |

  ## Operator matrix

  | Field type | Available operators                                    |
  |------------|--------------------------------------------------------|
  | `text`     | contains, equals, starts with, ends with, is empty     |
  | `select`   | equals, not equals                                     |
  | `date`     | equals, before, after, between                         |
  | `number`   | equals, greater than, less than, between               |

  ## Complete example — advanced search for a CRM contacts table

      defp filter_fields do
        [
          %{name: "name",       label: "Name",       type: "text"},
          %{name: "email",      label: "Email",      type: "text"},
          %{name: "status",     label: "Status",     type: "select",
            options: [{"Active", "active"}, {"Churned", "churned"}, {"Prospect", "prospect"}]},
          %{name: "created_at", label: "Created",    type: "date"},
          %{name: "deal_value", label: "Deal Value", type: "number"}
        ]
      end

      # In the template:
      <.filter_builder
        fields={filter_fields()}
        rules={@filter_rules}
        on_add="add_filter"
        on_remove="remove_filter"
        on_change="update_filter"
      />

  ## LiveView state and handlers

      # Default state in mount/3:
      def mount(_params, _session, socket) do
        {:ok, assign(socket, filter_rules: [])}
      end

      # Add a new empty rule (UUID id ensures stable DOM keys):
      def handle_event("add_filter", _params, socket) do
        rule = %{id: Ecto.UUID.generate(), field: "name", operator: "contains", value: ""}
        {:noreply, update(socket, :filter_rules, &[&1 | [rule]])}
      end

      # Remove a specific rule by its id:
      def handle_event("remove_filter", %{"id" => id}, socket) do
        {:noreply, update(socket, :filter_rules, &Enum.reject(&1, fn r -> r.id == id end))}
      end

      # Update a specific rule field when user changes field/operator/value:
      def handle_event("update_filter", params, socket) do
        id = params["id"] || params["phx-value-id"]
        rules = Enum.map(socket.assigns.filter_rules, fn rule ->
          if rule.id == id do
            %{rule |
              field:    params["filter"][id]["field"]    || rule.field,
              operator: params["filter"][id]["operator"] || rule.operator,
              value:    params["filter"][id]["value"]    || rule.value
            }
          else
            rule
          end
        end)
        {:noreply, assign(socket, filter_rules: rules)}
      end

      # Apply rules to a query (example using Ecto):
      defp apply_filters(query, rules) do
        Enum.reduce(rules, query, fn
          %{field: "name", operator: "contains", value: v}, q ->
            from(r in q, where: ilike(r.name, ^"%\#{v}%"))
          %{field: "status", operator: "equals", value: v}, q ->
            from(r in q, where: r.status == ^v)
          _rule, q -> q
        end)
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # filter_builder/1
  # ---------------------------------------------------------------------------

  attr(:fields, :list,
    required: true,
    doc: """
    List of field definition maps. Each map must have `:name`, `:label`, `:type`,
    and optionally `:options` (for `type: "select"`).

        fields={[
          %{name: "status", label: "Status", type: "select",
            options: [{"Active", "active"}, {"Inactive", "inactive"}]},
          %{name: "created_at", label: "Created", type: "date"},
          %{name: "amount", label: "Amount", type: "number"}
        ]}
    """
  )

  attr(:rules, :list,
    default: [],
    doc: """
    List of active rule maps. Each map must have `:id`, `:field`, `:operator`,
    and `:value`. The `:id` must be unique and stable across re-renders (use
    `Ecto.UUID.generate()` when creating rules).

        rules={[
          %{id: "abc-123", field: "status", operator: "equals", value: "active"},
          %{id: "def-456", field: "created_at", operator: "after", value: "2026-01-01"}
        ]}
    """
  )

  attr(:on_add, :string,
    required: true,
    doc: """
    `phx-click` event name for the \"Add filter\" button.
    The handler should append a new default rule to the rules list.
    """
  )

  attr(:on_remove, :string,
    required: true,
    doc: """
    `phx-click` event name for the remove button on each rule row.
    The LiveView receives `%{"id" => rule_id}`.
    """
  )

  attr(:on_change, :string,
    required: true,
    doc: """
    `phx-change` event name fired when any field, operator, or value input changes.
    The LiveView receives `%{"filter" => %{rule_id => %{"field" => ..., "operator" => ..., "value" => ...}}}`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders the filter builder container.

  Renders existing rules as `filter_rule/1` rows and an "Add filter" button
  to append new rules. Entirely server-driven — no JS hook required.
  All interactivity goes through LiveView `phx-click` / `phx-change` events.
  """
  def filter_builder(assigns) do
    ~H"""
    <div class={cn(["flex flex-col gap-2", @class])} {@rest}>
      <%!-- Render one filter_rule row per active rule --%>
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

      <%!-- "Add filter" button — dashed border signals "interactive placeholder" --%>
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
    doc: """
    Unique rule identifier. Passed as `phx-value-id` on the remove button and
    embedded in input `name` attributes so the LiveView can identify which rule
    was changed: `filter[rule_id][field]`, `filter[rule_id][operator]`, etc.
    """
  )

  attr(:field, :string,
    required: true,
    doc: "Name of the currently selected field (must match a `:name` key in the `fields` list)"
  )

  attr(:operator, :string,
    required: true,
    doc: "Currently selected operator string (e.g. \"contains\", \"before\", \"equals\")"
  )

  attr(:value, :string,
    default: "",
    doc: "Current filter value string"
  )

  attr(:fields, :list,
    required: true,
    doc: "Same `fields` list passed to `filter_builder/1` — used to render field options"
  )

  attr(:on_remove, :string,
    required: true,
    doc: "`phx-click` event name for the remove button on this row"
  )

  attr(:on_change, :string,
    required: true,
    doc: "`phx-change` event name fired when any input on this row changes"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the row wrapper")

  attr(:rest, :global, doc: "HTML attributes forwarded to the row div")

  @doc """
  Renders a single filter rule row.

  The row contains a field dropdown, an operator dropdown (populated based on
  the selected field's type), a value input (type-appropriate: text, date,
  number, or select), and a remove button.

  The `current_field` is resolved at render time from the `fields` list so the
  operator list and value input are always consistent with the selected field.
  """
  def filter_rule(assigns) do
    # Resolve the current field definition so operators_for/1 and
    # rule_value_input/1 can dispatch on the field's type.
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
      <%!-- Field selector — which attribute to filter on --%>
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

      <%!-- Operator selector — populated dynamically based on the field type --%>
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

      <%!-- Value input — rendered as text, date, number, or select depending on field type --%>
      <.rule_value_input
        id={@id}
        current_field={@current_field}
        value={@value}
        on_change={@on_change}
      />

      <%!-- Remove button — deletes this rule from the list --%>
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
  # Private — rule value input (dispatches on field type via pattern matching)
  # ---------------------------------------------------------------------------

  # These are private function-head components. Pattern matching on the
  # `current_field.type` key allows each field type to render the most
  # appropriate HTML input without any runtime conditionals in the template.

  attr(:id, :string, required: true)
  attr(:current_field, :map, default: nil)
  attr(:value, :string, required: true)
  attr(:on_change, :string, required: true)

  # Select field type — renders a <select> populated with the field's own options.
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

  # Date field type — renders a native <input type="date"> for proper browser date pickers.
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

  # Number field type — renders <input type="number"> with a narrow fixed width.
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

  # Fallback for text fields (and any unknown field type) — plain text input.
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

  # Find a field definition by name so we can inspect its type.
  defp find_field(fields, field_name) do
    Enum.find(fields, fn f -> f.name == field_name end)
  end

  # Operator lists are scoped to each field type.
  # Select fields only make sense with equality operators.
  defp operators_for(%{type: "select"}),
    do: [{"equals", "equals"}, {"not equals", "not_equals"}]

  # Date fields support temporal comparisons including range boundaries.
  defp operators_for(%{type: "date"}),
    do: [
      {"equals", "equals"},
      {"before", "before"},
      {"after", "after"},
      {"between", "between"}
    ]

  # Number fields support numeric comparisons.
  defp operators_for(%{type: "number"}),
    do: [
      {"equals", "equals"},
      {"greater than", "gt"},
      {"less than", "lt"},
      {"between", "between"}
    ]

  # Text fields (and nil / unknown field types) default to string operators.
  defp operators_for(_text_or_nil),
    do: [
      {"contains", "contains"},
      {"equals", "equals"},
      {"starts with", "starts_with"},
      {"ends with", "ends_with"},
      {"is empty", "is_empty"}
    ]
end
