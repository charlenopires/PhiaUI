defmodule PhiaUi.Components.SearchInput do
  @moduledoc """
  Search input component with icon, optional clear button, and shortcut badge.

  Provides `search_input/1` — a styled text input with a magnifier icon on the
  left, an optional × clear button, and an optional keyboard shortcut badge
  (e.g. `⌘K`). Supports three visual variants: `:default`, `:minimal`, `:ghost`.

  Also provides `form_search_input/1` for form-integrated search with label,
  description, and changeset error display.

  ## Variants

  - `:default` — bordered input with background (standard form use)
  - `:minimal` — no border, muted fill, for search bars inside containers
  - `:ghost` — fully transparent until focused, for toolbar search

  ## Basic usage

      <%!-- Standalone search bar --%>
      <.search_input
        name="q"
        value={@query}
        placeholder="Search products..."
        phx-change="search"
        phx-debounce="300"
      />

      <%!-- With command palette shortcut hint --%>
      <.search_input
        name="q"
        value={@query}
        placeholder="Search..."
        shortcut="⌘K"
      />

      <%!-- With clear button and custom variant --%>
      <.search_input
        name="q"
        value={@query}
        placeholder="Filter..."
        variant="minimal"
        on_clear="clear_search"
      />

  ## Handling clear

  When `:on_clear` is set, the × button fires a `phx-click` event. Handle it
  server-side to reset the search value:

      def handle_event("clear_search", _params, socket) do
        {:noreply, assign(socket, query: "")}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # search_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: "search",
    doc: "HTML name attribute forwarded to `<input>`."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current input value."
  )

  attr(:placeholder, :string,
    default: "Search...",
    doc: "Placeholder text shown when the input is empty."
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default minimal ghost),
    doc: "Visual style — `default`, `minimal`, or `ghost`."
  )

  attr(:shortcut, :string,
    default: nil,
    doc: "Keyboard shortcut badge displayed inside the input (e.g. `\"⌘K\"`)."
  )

  attr(:on_clear, :string,
    default: nil,
    doc: "LiveView event name fired when the × clear button is clicked."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the input and clear button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the outer wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-submit phx-keydown phx-debounce autofocus autocomplete),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a search input with a magnifier icon, optional × clear button, and
  optional keyboard shortcut badge.

  The layout is a relative wrapper containing:
  1. A left-aligned magnifier icon
  2. The styled `<input type="search">`
  3. (optional) × clear button firing `:on_clear`
  4. (optional) shortcut `<kbd>` badge on the right

  ## Examples

      <.search_input name="q" value={@q} phx-change="search" phx-debounce="300" />

      <.search_input name="q" value={@q} shortcut="⌘K" placeholder="Jump to..." />

      <.search_input name="q" value={@q} on_clear="clear_q" variant="minimal" />
  """
  def search_input(assigns) do
    id = assigns.id || "search-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    has_value = assigns.value != nil && assigns.value != ""
    assigns = assign(assigns, :has_value, has_value)

    ~H"""
    <div class={cn(["relative flex items-center", @class])}>
      <%!-- Magnifier icon --%>
      <span class="pointer-events-none absolute left-3 flex items-center text-muted-foreground">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" />
        </svg>
      </span>

      <input
        type="search"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        class={cn([
          input_class(@variant),
          "pl-9",
          @shortcut && "pr-16",
          (@on_clear && @has_value) && "pr-8",
          @disabled && "cursor-not-allowed opacity-50"
        ])}
        aria-label={@placeholder}
        {@rest}
      />

      <%!-- Clear button — only when value is present and on_clear is configured --%>
      <button
        :if={@on_clear && @has_value && !@disabled}
        type="button"
        phx-click={@on_clear}
        aria-label="Clear search"
        class="absolute right-2 flex h-6 w-6 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-3.5 w-3.5"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M18 6 6 18M6 6l12 12" />
        </svg>
      </button>

      <%!-- Keyboard shortcut badge --%>
      <span :if={@shortcut && !@has_value} class="pointer-events-none absolute right-2 flex items-center">
        <kbd class="hidden select-none items-center gap-1 rounded border border-border bg-muted px-1.5 py-0.5 font-mono text-[10px] font-medium text-muted-foreground sm:flex">
          {@shortcut}
        </kbd>
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_search_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default minimal ghost),
    doc: "Visual style."
  )

  attr(:shortcut, :string,
    default: nil,
    doc: "Keyboard shortcut badge."
  )

  attr(:on_clear, :string,
    default: nil,
    doc: "LiveView event name for the × clear button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown disabled placeholder autocomplete),
    doc: "HTML attributes forwarded to the inner `search_input/1`."
  )

  @doc """
  Renders a form-integrated search input with label and error messages.

  Wraps `search_input/1` with a `<label>` (when `:label` is given) and error
  `<p>` elements sourced from `field.errors`.

  ## Examples

      <.form_search_input field={@form[:query]} label="Search products" />
  """
  def form_search_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)

    ~H"""
    <div class="space-y-2">
      <label
        :if={@label}
        for={@id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.search_input
        id={@id}
        name={@name}
        value={@value}
        variant={@variant}
        shortcut={@shortcut}
        on_clear={@on_clear}
        class={@class}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp input_class("default") do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm " <>
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 " <>
      "[&::-webkit-search-cancel-button]:hidden"
  end

  defp input_class("minimal") do
    "flex h-10 w-full rounded-md border-0 bg-muted/50 px-3 py-2 text-sm " <>
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 " <>
      "[&::-webkit-search-cancel-button]:hidden"
  end

  defp input_class("ghost") do
    "flex h-10 w-full rounded-md border-0 bg-transparent px-3 py-2 text-sm " <>
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:bg-muted/50 " <>
      "disabled:cursor-not-allowed disabled:opacity-50 " <>
      "[&::-webkit-search-cancel-button]:hidden"
  end

  defp input_class(_), do: input_class("default")

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
