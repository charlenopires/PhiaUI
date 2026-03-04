defmodule PhiaUi.Components.MultiSelect do
  @moduledoc """
  Multi-select form component for Phoenix LiveView.

  `multi_select/1` renders a native `<select multiple>` element with PhiaUI
  styling, selected-value chip display, and remove-chip buttons. It is suited
  for selecting **predefined options** from a fixed list (unlike `tags_input/1`
  which accepts freeform text typed by the user).

  `form_multi_select/1` wraps the bare component with `Phoenix.HTML.FormField`
  integration: label, error messages, and automatic id/name/value extraction.

  ## When to use

  - The user picks one or more values from a known, finite list of options.
  - You want zero JavaScript with native browser multi-select semantics.
  - An accessible chip row showing current selections is required.

  For freeform tag entry, use `phia_tags_input/1` instead.

  ## Basic usage

      <.multi_select
        id="framework-select"
        name="frameworks"
        options={[{"Elixir", "elixir"}, {"Phoenix", "phoenix"}, {"LiveView", "liveview"}]}
        selected={@selected_frameworks}
        placeholder="Select frameworks..."
        on_change="update_frameworks"
      />

  ## Form integration

      <.form_multi_select
        field={@form[:categories]}
        options={@category_options}
        label="Categories"
        on_change="update_categories"
      />

  ## Handling events

  The chip remove buttons emit `phx-click={@on_change}` with
  `phx-value-deselect={val}`, so the LiveView can pattern-match:

      def handle_event("update_frameworks", %{"deselect" => val}, socket) do
        updated = List.delete(socket.assigns.selected_frameworks, val)
        {:noreply, assign(socket, selected_frameworks: updated)}
      end

  The native `<select multiple>` submission sends all selected values as
  `name[]` parameters to the server automatically via form submit.

  ## Accessibility

  - `<select multiple>` uses `aria-label={@placeholder}` for screen readers.
  - Chip remove buttons carry `aria-label="Remove {value}"`.
  - The `disabled` attribute is forwarded to the `<select>` element.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # multi_select/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "HTML `id` attribute for the underlying `<select>` element."
  )

  attr(:name, :string,
    required: true,
    doc: """
    Base `name` attribute. The component automatically appends `[]` to produce
    `name[]`, so all selected values are submitted as an array.
    """
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of `{label, value}` tuples to render as `<option>` elements.
    `label` is the human-readable text; `value` is the submitted form value.
    """
  )

  attr(:selected, :list,
    default: [],
    doc: """
    List of currently selected values (strings). Options whose value appears
    in this list are rendered with the `selected` attribute and displayed as
    removable chips above the select.
    """
  )

  attr(:placeholder, :string,
    default: "Select...",
    doc: """
    Placeholder text used as the `aria-label` of the `<select>` element.
    Helps screen-reader users understand what to select.
    """
  )

  attr(:on_change, :string,
    default: nil,
    doc: """
    LiveView event name fired when the user clicks a chip's remove button.
    The event receives `phx-value-deselect` with the value being removed.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional Tailwind CSS classes merged into the root `<div>` wrapper via `cn/1`."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, the `<select>` element is rendered with the `disabled` attribute."
  )

  @doc """
  Renders a native `<select multiple>` with chip display for selected values.

  Selected values appear as removable chips above the native select. Each chip
  shows the human-readable label (resolved via `find_label/2`) and a `×` button
  that fires the `on_change` event with `phx-value-deselect`.

  The native `<select multiple>` follows below and marks the matching options
  as `selected`. This dual representation lets the component work both with
  standard form submission and LiveView event-driven updates.

  ## Examples

      <%!-- Basic usage --%>
      <.multi_select
        id="roles"
        name="roles"
        options={[{"Admin", "admin"}, {"Member", "member"}, {"Viewer", "viewer"}]}
        selected={@roles}
        placeholder="Assign roles..."
        on_change="update_roles"
      />

      <%!-- Disabled --%>
      <.multi_select
        id="locked"
        name="locked"
        options={[{"A", "a"}, {"B", "b"}]}
        selected={["a"]}
        disabled={true}
        on_change="noop"
      />
  """
  def multi_select(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <%!-- Selected-value chips — only rendered when something is selected --%>
      <div :if={length(@selected) > 0} class="flex flex-wrap gap-1 mb-2" data-selected-chips>
        <span
          :for={val <- @selected}
          class="inline-flex items-center gap-1 rounded-full bg-secondary text-secondary-foreground text-xs px-2 py-0.5"
        >
          {find_label(@options, val)}
          <button
            type="button"
            phx-click={@on_change}
            phx-value-deselect={val}
            aria-label={"Remove #{val}"}
            class="hover:text-foreground"
          >
            &times;
          </button>
        </span>
      </div>

      <%!-- Native multiple select --%>
      <select
        id={@id}
        name={"#{@name}[]"}
        multiple
        disabled={@disabled}
        aria-label={@placeholder}
        class={cn([
          "flex h-auto w-full min-h-[2.5rem] rounded-md border border-border",
          "bg-background px-3 py-2 text-sm text-foreground",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50"
        ])}
      >
        <option
          :for={{label, value} <- @options}
          value={value}
          selected={value in @selected}
        >
          {label}
        </option>
      </select>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_multi_select/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct from `@form[:field_name]`. Provides the
    element `id`, `name`, current `value` (used as selected list), and `errors`
    for changeset error display.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Text rendered in a `<label>` above the select. Omitted when `nil`."
  )

  attr(:options, :list,
    default: [],
    doc: "List of `{label, value}` tuples — forwarded to `multi_select/1`."
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event name for chip removal — forwarded to `multi_select/1`."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional Tailwind CSS classes merged into the root `<div>` wrapper."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Forwarded to the underlying `multi_select/1` to disable the select."
  )

  @doc """
  `Phoenix.HTML.FormField`-integrated multi-select with label and error display.

  Extracts `id`, `name`, and `value` from the `field` struct and delegates to
  `multi_select/1`. Renders changeset errors below the select in
  `text-destructive` colour.

  ## Example

      <.form_multi_select
        field={@form[:categories]}
        options={@category_options}
        label="Categories"
        on_change="update_categories"
      />
  """
  def form_multi_select(assigns) do
    # Normalise field.value to a list of strings for the selected= attr.
    selected = normalise_selected(assigns.field.value)
    assigns = assign(assigns, :selected, selected)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <.multi_select
        id={@field.id}
        name={@field.name}
        options={@options}
        selected={@selected}
        on_change={@on_change}
        disabled={@disabled}
      />
      <p :for={error <- @field.errors} class="text-sm font-medium text-destructive">
        {translate_error(error)}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Finds the human-readable label for a given value in the options list.
  # Returns the value itself as a fallback when no matching option is found,
  # so chips are always displayed rather than silently disappearing.
  defp find_label(options, value) do
    case Enum.find(options, fn {_label, opt_value} -> to_string(opt_value) == to_string(value) end) do
      {label, _value} -> label
      nil -> value
    end
  end

  # Normalises the field value to a list of plain strings.
  # FormField values may arrive as nil, a single string, or a list.
  defp normalise_selected(nil), do: []
  defp normalise_selected(value) when is_binary(value), do: [value]
  defp normalise_selected(values) when is_list(values), do: Enum.map(values, &to_string/1)
  defp normalise_selected(value), do: [to_string(value)]

  # Interpolates %{key} placeholders from the opts keyword list.
  # Mirrors the pattern used in PhiaUi.Components.Form.translate_error/1.
  defp translate_error({msg, opts}) do
    case Application.get_env(:phia_ui, :error_translator_function) do
      {mod, fun} ->
        apply(mod, fun, [{msg, opts}])

      nil ->
        Enum.reduce(opts, msg, fn {k, v}, acc ->
          String.replace(acc, "%{#{k}}", to_string(v))
        end)
    end
  end
end
