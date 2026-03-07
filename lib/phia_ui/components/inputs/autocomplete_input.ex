defmodule PhiaUi.Components.AutocompleteInput do
  @moduledoc """
  Text input with HTML5 datalist suggestions.

  Provides `autocomplete_input/1` — a standard text input wired to a native
  HTML `<datalist>` element. As the user types, the browser shows matching
  suggestions from the list. No JavaScript required — it is entirely native
  browser behaviour.

  Also provides `form_autocomplete_input/1` for changeset-integrated forms.

  ## When to use

  Use `autocomplete_input/1` when you need:
  - Simple suggestion lists (country, city, language, skill, tag)
  - Non-enforced suggestions — users can still type anything not in the list
  - The lightest possible implementation without a combobox or multi-select

  For enforced option selection use `phia_select/1`. For complex search with
  remote options use `combobox/1`.

  ## Basic usage

      <.autocomplete_input
        name="country"
        value={@country}
        placeholder="Start typing a country..."
        suggestions={["Brazil", "Canada", "France", "Germany", "United States"]}
        phx-change="update_country"
      />

  ## Dynamic suggestions from assigns

      <.autocomplete_input
        name="language"
        value={@language}
        suggestions={@available_languages}
        phx-change="update_language"
      />

  ## Form-integrated

      <.form_autocomplete_input
        field={@form[:city]}
        label="City"
        suggestions={@cities}
        phx-change="validate"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # autocomplete_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Auto-generated if nil. Also used to link the datalist."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current input value."
  )

  attr(:suggestions, :list,
    default: [],
    doc: """
    List of suggestion strings (or `{label, value}` tuples) rendered as
    `<option>` elements inside the `<datalist>`. The browser uses these
    as autocomplete candidates.
    """
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text shown when the input is empty."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the input."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown required readonly autocomplete autofocus),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a text input with native browser datalist suggestions.

  The `<datalist>` id is derived from the input's id so they are automatically
  linked via the `list` attribute. The browser handles rendering and filtering
  of suggestions natively — no JS needed.

  ## Examples

      <.autocomplete_input
        name="framework"
        value={@framework}
        suggestions={["React", "Vue", "Svelte", "Elixir"]}
        placeholder="Select a framework..."
      />
  """
  def autocomplete_input(assigns) do
    id = assigns.id || "ac-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    assigns = assign(assigns, :datalist_id, id <> "-list")

    ~H"""
    <div class="relative">
      <input
        type="text"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        list={@datalist_id}
        class={cn([
          "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
          "placeholder:text-muted-foreground",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])}
        {@rest}
      />
      <datalist id={@datalist_id}>
        <%= for suggestion <- @suggestions do %>
          <%= if is_tuple(suggestion) do %>
            <option value={elem(suggestion, 1)}>{elem(suggestion, 0)}</option>
          <% else %>
            <option value={suggestion}>{suggestion}</option>
          <% end %>
        <% end %>
      </datalist>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_autocomplete_input/1
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

  attr(:suggestions, :list,
    default: [],
    doc: "List of suggestion strings or `{label, value}` tuples."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce placeholder disabled required readonly),
    doc: "HTML attributes forwarded to `autocomplete_input/1`."
  )

  @doc """
  Renders a form-integrated autocomplete input with label and error messages.

  ## Examples

      <.form_autocomplete_input
        field={@form[:country]}
        label="Country"
        suggestions={@countries}
      />
  """
  def form_autocomplete_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <.autocomplete_input
        id={@id}
        name={@name}
        value={@value}
        suggestions={@suggestions}
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
