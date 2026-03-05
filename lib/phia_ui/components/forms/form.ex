defmodule PhiaUi.Components.Form do
  @moduledoc """
  Form Integration Components for Phoenix LiveView.

  Provides components that integrate with `Phoenix.HTML.Form` and Ecto changesets.
  Handles error display, real-time validation via `phx-debounce`, and form accessibility.

  ## Components

  | Function        | Purpose                                          |
  |-----------------|--------------------------------------------------|
  | `phia_input/1`  | All-in-one input: label + input + description + errors |
  | `form_field/1`  | Composable wrapper: label + slot + description + errors |
  | `form_label/1`  | Accessible `<label>` linked to input via `field.id` |
  | `form_message/1`| Conditional error messages from changeset        |

  ## Error Translation

  By default, errors are translated using a simple placeholder interpolator.
  To use a custom translator (e.g., from `gettext`), configure:

      config :phia_ui, :error_translator_function, {MyApp.CoreComponents, :translate_error}

  The custom function must accept `{message, opts}` and return a string.

  ## Example

      <.phia_input field={@form[:email]} type="email" label="Email" />

      <.phia_input
        field={@form[:password]}
        type="password"
        label="Password"
        description="At least 8 characters."
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # phia_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"
  )

  attr(:type, :string, default: "text", doc: "HTML input type")
  attr(:label, :string, default: nil, doc: "Label text rendered above the input")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the input")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the input element")

  attr(:rest, :global,
    include: ~w(autocomplete placeholder readonly required disabled),
    doc: "HTML attributes forwarded to the input element"
  )

  @doc """
  Renders a form input integrated with `Phoenix.HTML.FormField`.

  Includes label, input, description, and changeset error messages in a single component.
  Applies `phx-debounce="blur"` by default for real-time validation.
  """
  def phia_input(assigns) do
    ~H"""
    <div class="space-y-2">
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <input
        id={@field.id}
        name={@field.name}
        type={@type}
        value={@field.value}
        class={
          cn([
            "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
            "ring-offset-background placeholder:text-muted-foreground",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
            "disabled:cursor-not-allowed disabled:opacity-50",
            @field.errors != [] && "border-destructive focus-visible:ring-destructive",
            @class
          ])
        }
        phx-debounce="blur"
        {@rest}
      />
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <p :for={error <- @field.errors} class="text-sm font-medium text-destructive">
        {translate_error(error)}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_field/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"
  )

  attr(:label, :string, default: nil, doc: "Label text")
  attr(:description, :string, default: nil, doc: "Helper text below the input slot")

  slot(:inner_block,
    required: true,
    doc: "The input component (e.g. a native input or phia_input)"
  )

  @doc """
  Composable form field wrapper.

  Renders: label → slot (input) → description → error messages.
  Use this when you need full control over the input element inside.
  """
  def form_field(assigns) do
    ~H"""
    <div class="space-y-2">
      <.form_label :if={@label} field={@field}>{@label}</.form_label>
      <%= render_slot(@inner_block) %>
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <.form_message field={@field} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_label/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "FormField to link the label to")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the label element")

  slot(:inner_block, required: true, doc: "Label text or content")

  @doc """
  Renders an accessible `<label>` linked to the input via `for={@field.id}`.
  """
  def form_label(assigns) do
    ~H"""
    <label
      for={@field.id}
      class={
        cn([
          "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
          @class
        ])
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # form_message/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "FormField to read errors from")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders changeset error messages for a field. Renders nothing when there are no errors.
  """
  def form_message(assigns) do
    ~H"""
    <p :for={error <- @field.errors} class={cn(["text-sm font-medium text-destructive", @class])}>
      {translate_error(error)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # translate_error/1
  # ---------------------------------------------------------------------------

  @doc """
  Translates a `{message, opts}` error tuple from a changeset.

  Uses the configured `:error_translator_function` when set, otherwise falls back
  to interpolating `%{key}` placeholders with values from `opts`:

      Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{\#{k}}", to_string(v)) end)

  Configure a custom translator:

      config :phia_ui, :error_translator_function, {MyApp.CoreComponents, :translate_error}
  """
  def translate_error({msg, opts}) do
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
