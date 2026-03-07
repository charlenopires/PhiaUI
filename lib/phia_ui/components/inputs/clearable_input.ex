defmodule PhiaUi.Components.ClearableInput do
  @moduledoc """
  Text input with an inline × clear button.

  Provides `clearable_input/1` — a text input that renders a × button on the
  right side when the current value is non-empty. Clicking the button fires a
  server event (`:on_clear`) which the LiveView handles to reset the value.

  Also provides `form_clearable_input/1` for changeset-integrated fields with
  label, description, and error messages.

  ## When to use

  Use `clearable_input/1` when users need a quick way to empty a field —
  filter inputs, tag inputs, search boxes, or any single-line field where
  removing the current value is a frequent action.

  ## Basic usage

      <.clearable_input
        name="filter"
        value={@filter}
        placeholder="Filter by name..."
        on_clear="clear_filter"
        phx-change="filter_changed"
        phx-debounce="300"
      />

  ## Handling clear

      def handle_event("clear_filter", _params, socket) do
        {:noreply, assign(socket, filter: "")}
      end

  ## Form-integrated

      <.form_clearable_input
        field={@form[:username]}
        label="Username"
        on_clear="clear_username"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # clearable_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current input value."
  )

  attr(:type, :string,
    default: "text",
    doc: "HTML input type (text, email, tel, url, search)."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text shown when empty."
  )

  attr(:on_clear, :string,
    default: nil,
    doc: "LiveView event name fired when the × button is clicked."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the input and hides the clear button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element via `cn/1`."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown autocomplete required readonly autofocus),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a text input with an inline × clear button.

  The × button is rendered only when `:value` is non-empty AND `:on_clear` is
  set. Clicking it fires the LiveView event named by `:on_clear`. The LiveView
  is responsible for resetting the field value, which causes the button to
  disappear on re-render.

  ## Examples

      <.clearable_input name="q" value={@q} on_clear="clear_q" phx-change="search" />

      <.clearable_input name="email" value={@email} type="email" placeholder="you@example.com" />
  """
  def clearable_input(assigns) do
    id = assigns.id || "clearable-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    has_value = assigns.value != nil && assigns.value != ""
    assigns = assign(assigns, :has_value, has_value)

    ~H"""
    <div class="relative flex items-center">
      <input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        class={cn([
          base_input_class(),
          @has_value && @on_clear && "pr-9",
          @class
        ])}
        {@rest}
      />
      <button
        :if={@has_value && @on_clear && !@disabled}
        type="button"
        phx-click={@on_clear}
        aria-label="Clear input"
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
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_clearable_input/1
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

  attr(:on_clear, :string,
    default: nil,
    doc: "LiveView event name for the × clear button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce autocomplete placeholder disabled required readonly type),
    doc: "HTML attributes forwarded to `clearable_input/1`."
  )

  @doc """
  Renders a form-integrated clearable input with label and error messages.

  ## Examples

      <.form_clearable_input field={@form[:username]} label="Username" on_clear="clear_username" />
  """
  def form_clearable_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <.clearable_input
        id={@id}
        name={@name}
        value={@value}
        on_clear={@on_clear}
        class={cn([error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_input_class do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm " <>
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp error_class([]), do: nil
  defp error_class(_), do: "border-destructive focus-visible:ring-destructive"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
