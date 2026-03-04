defmodule PhiaUi.Components.NumberInput do
  @moduledoc """
  Numeric stepper input component with optional prefix/suffix and form integration.

  Renders a number input flanked by decrement (−) and increment (+) buttons.
  The buttons use `type="button"` so they never trigger form submission — the
  parent form controls submit behaviour. The input itself is a native
  `<input type="number">` which preserves browser built-in keyboard behaviour
  (arrow keys, scroll wheel) and numeric validation.

  ## Basic usage

      <.number_input name="quantity" value={@qty} />

  ## With constraints

      <.number_input name="quantity" value={@qty} min={0} max={100} step={1} />

  ## With prefix and suffix

      <.number_input name="price" value={@price} prefix="$" suffix="USD" />

  ## Form-integrated usage

      <.form_number_input field={@form[:price]} label="Price" prefix="$" />

  ## Disabled / read-only

      <.number_input name="qty" value={0} disabled={true} />
      <.number_input name="qty" value={42} readonly={true} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # number_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id attribute for the underlying `<input>` element."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute forwarded to `<input>`. Required for form submission."
  )

  attr(:value, :any,
    default: nil,
    doc: "Current numeric value. Passed as the `value` attribute of the `<input>`."
  )

  attr(:min, :any,
    default: nil,
    doc: "Minimum allowed value. Maps to the native `min` attribute."
  )

  attr(:max, :any,
    default: nil,
    doc: "Maximum allowed value. Maps to the native `max` attribute."
  )

  attr(:step, :any,
    default: 1,
    doc: "Step increment/decrement amount. Defaults to `1`."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text shown when the input is empty."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the input and stepper buttons."
  )

  attr(:readonly, :boolean,
    default: false,
    doc: "Makes the input read-only."
  )

  attr(:prefix, :string,
    default: nil,
    doc: "Optional text shown to the left inside the input (e.g. `\"$\"`)."
  )

  attr(:suffix, :string,
    default: nil,
    doc: "Optional text shown to the right inside the input (e.g. `\"USD\"`)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional Tailwind classes merged into the `<input>` element via `cn/1`."
  )

  @doc """
  Renders a stepper-style number input with optional prefix/suffix decorators.

  The layout is: **[−] [input] [+]** — decrement button, the numeric input,
  and an increment button. Both buttons have `type="button"` and carry
  accessible `aria-label` attributes (`"Decrease"` / `"Increase"`).

  ARIA attributes `aria-valuemin`, `aria-valuemax`, and `aria-valuenow` are
  set on the input when the corresponding props are provided, making the range
  semantics available to assistive technology.

  ## Examples

      <%!-- Basic --%>
      <.number_input name="qty" value={@qty} />

      <%!-- With constraints --%>
      <.number_input name="qty" value={@qty} min={0} max={99} step={1} />

      <%!-- With currency prefix --%>
      <.number_input name="price" value={@price} prefix="$" />

      <%!-- Disabled state --%>
      <.number_input name="qty" value={0} disabled={true} />
  """
  def number_input(assigns) do
    ~H"""
    <div class="flex items-center">
      <button
        type="button"
        aria-label="Decrease"
        disabled={@disabled}
        class={
          cn([
            "h-10 w-10 flex items-center justify-center border border-border rounded-md",
            "bg-background text-foreground hover:bg-accent",
            "disabled:cursor-not-allowed disabled:opacity-50"
          ])
        }
      >
        −
      </button>
      <div class="relative flex items-center flex-1">
        <span
          :if={@prefix}
          class="absolute left-3 text-muted-foreground text-sm pointer-events-none"
        >
          {@prefix}
        </span>
        <input
          type="number"
          id={@id}
          name={@name}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          placeholder={@placeholder}
          disabled={@disabled}
          readonly={@readonly}
          aria-valuemin={@min}
          aria-valuemax={@max}
          aria-valuenow={@value}
          class={
            cn([
              "flex h-10 w-full rounded-md border border-border bg-background px-3 py-2",
              "text-sm text-foreground",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
              "disabled:cursor-not-allowed disabled:opacity-50",
              @prefix && "pl-7",
              @suffix && "pr-7",
              @class
            ])
          }
        />
        <span
          :if={@suffix}
          class="absolute right-3 text-muted-foreground text-sm pointer-events-none"
        >
          {@suffix}
        </span>
      </div>
      <button
        type="button"
        aria-label="Increase"
        disabled={@disabled}
        class={
          cn([
            "h-10 w-10 flex items-center justify-center border border-border rounded-md",
            "bg-background text-foreground hover:bg-accent",
            "disabled:cursor-not-allowed disabled:opacity-50"
          ])
        }
      >
        +
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_number_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct (typically `@form[:field_name]`).
    Provides `id`, `name`, `value`, and `errors` automatically.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input. Omit to suppress the `<label>` element."
  )

  attr(:prefix, :string,
    default: nil,
    doc: "Optional prefix text (e.g. `\"$\"`)."
  )

  attr(:suffix, :string,
    default: nil,
    doc: "Optional suffix text (e.g. `\"USD\"`)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional classes merged into the underlying `<input>`."
  )

  attr(:min, :any, default: nil, doc: "Minimum allowed value.")
  attr(:max, :any, default: nil, doc: "Maximum allowed value.")
  attr(:step, :any, default: 1, doc: "Step amount. Defaults to `1`.")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text.")
  attr(:disabled, :boolean, default: false, doc: "Disables the input.")
  attr(:readonly, :boolean, default: false, doc: "Makes the input read-only.")

  @doc """
  Renders a form-integrated number input with label and error messages.

  Wraps `number_input/1` with a `<label>` (when `:label` is given) and error
  `<p>` elements sourced from `field.errors`. Error messages are interpolated
  using the same `translate_error/1` helper as the rest of the PhiaUI form
  components.

  ## Examples

      <.form_number_input field={@form[:quantity]} label="Quantity" />

      <.form_number_input field={@form[:price]} label="Price" prefix="$" />

      <.form_number_input
        field={@form[:amount]}
        label="Amount"
        min={0}
        max={9999}
        step={0.01}
      />
  """
  def form_number_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <.number_input
        id={@id}
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        placeholder={@placeholder}
        disabled={@disabled}
        readonly={@readonly}
        prefix={@prefix}
        suffix={@suffix}
        class={@class}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">
        {error}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Interpolates `%{key}` placeholders from the `opts` keyword list produced
  # by Ecto changeset validations into the error message string.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
