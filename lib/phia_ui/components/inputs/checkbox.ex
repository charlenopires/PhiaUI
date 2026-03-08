defmodule PhiaUi.Components.Checkbox do
  @moduledoc """
  Native HTML checkbox component styled with Tailwind CSS.

  Integrates with `Phoenix.HTML.FormField` and Ecto changesets. Supports
  checked, unchecked, and indeterminate states with full WAI-ARIA semantics.

  ## Sub-components

  | Function          | Purpose                                                          |
  |-------------------|------------------------------------------------------------------|
  | `checkbox/1`      | Standalone styled checkbox input, no form context needed         |
  | `form_checkbox/1` | Checkbox with label and changeset error display via `FormField`  |

  ## Standalone usage

      <%!-- Basic --%>
      <.checkbox id="agree" name="agree" />

      <%!-- Pre-checked --%>
      <.checkbox id="agree" name="agree" checked={true} />

      <%!-- Indeterminate state (e.g. "select all" that is partially selected) --%>
      <.checkbox id="select-all" name="select_all" indeterminate={true} />

      <%!-- With LiveView event --%>
      <.checkbox id="cb" name="cb" phx-change="toggle_item" />

  ## Form-integrated usage

      <%!-- Accept terms and conditions --%>
      <.form_checkbox
        field={@form[:agreed_to_terms]}
        label="I agree to the Terms of Service"
      />

      <%!-- Newsletter opt-in --%>
      <.form_checkbox
        field={@form[:marketing_emails]}
        label="Send me product updates and offers"
      />

      <%!-- Disabled state --%>
      <.form_checkbox
        field={@form[:required_field]}
        label="This cannot be changed"
        disabled={true}
      />

  ## Select-all pattern with indeterminate

  The indeterminate state is commonly used for a "select all" checkbox when some
  but not all items in a list are selected:

      <%!-- In your LiveView --%>
      defp all_selected?(items), do: Enum.all?(items, & &1.selected)
      defp some_selected?(items), do: Enum.any?(items, & &1.selected)

      <%!-- In your template --%>
      <.checkbox
        id="select-all"
        name="select_all"
        checked={all_selected?(@items)}
        indeterminate={some_selected?(@items) && !all_selected?(@items)}
        phx-click="toggle_all"
      />

  ## Accessibility

  - Native `<input type="checkbox">` is used, so keyboard (Space to toggle)
    and screen reader support is provided by the browser
  - `data-state` attribute reflects `"checked"`, `"unchecked"`, or
    `"indeterminate"` for CSS-based custom styling
  - `aria-checked="mixed"` is set for the indeterminate state
  - `aria-invalid="true"` is set on `form_checkbox/1` when the field has errors
  - Labels are associated via `for`/`id` for click-to-focus behaviour
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form, as: HTMLForm

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # checkbox/1 — standalone
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: """
    The `id` attribute of the input element. Required for associating with an
    external `<label for="...">`. When using `form_checkbox/1`, this is derived
    from the field struct automatically.
    """
  )

  attr(:name, :string,
    default: nil,
    doc: """
    The `name` attribute of the input element. Determines the key in the form
    submission payload. When using `form_checkbox/1`, this is derived from the
    field struct automatically.
    """
  )

  attr(:value, :string,
    default: "true",
    doc: """
    The value submitted when the checkbox is checked. Defaults to `"true"`,
    which works well with boolean changeset fields. For multi-value checkboxes
    (e.g. selecting multiple tags), set this to the specific item value.
    """
  )

  attr(:checked, :boolean,
    default: false,
    doc: "Whether the checkbox is in the checked state."
  )

  attr(:indeterminate, :boolean,
    default: false,
    doc: """
    When `true`, renders the checkbox in the indeterminate state. Indeterminate
    checkboxes typically appear with a dash (-) inside the box and signal a
    "partially selected" condition (e.g. some items in a list are selected).
    Sets `aria-checked="mixed"` and `data-state="indeterminate"`.
    Note: indeterminate takes visual precedence over `checked`.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables the checkbox. It cannot be toggled and appears faded."
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes merged into the input element via `cn/1`.
    Last-wins merge means your classes override the defaults.
    """
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-click form required aria-invalid),
    doc: """
    Additional HTML attributes forwarded to the `<input>` element. Commonly
    used: `phx-change` or `phx-click` to handle toggle events in LiveView,
    `form` to associate with a form outside the DOM hierarchy,
    `required` for native browser validation.
    """
  )

  @doc """
  Renders a styled native `<input type="checkbox">` element.

  Uses semantic Tailwind tokens (`border-primary`, `accent-primary`) so it
  respects the PhiaUI theme in both light and dark mode without any JavaScript.

  The `data-state` attribute is set to `"checked"`, `"unchecked"`, or
  `"indeterminate"` and can be targeted by CSS for custom indicator styling.
  For the indeterminate state, `aria-checked="mixed"` is applied for screen
  readers.

  ## Examples

      <%!-- Basic unchecked --%>
      <.checkbox id="agree" name="agree" />

      <%!-- Pre-checked --%>
      <.checkbox id="agree" name="agree" checked={true} />

      <%!-- Indeterminate (partially-selected "select all") --%>
      <.checkbox id="all" name="all" indeterminate={true} />

      <%!-- Disabled --%>
      <.checkbox id="agree" name="agree" disabled={true} />

      <%!-- LiveView event handler --%>
      <.checkbox id="agree" name="agree" phx-change="toggle" />

      <%!-- Custom class override --%>
      <.checkbox id="lg" name="lg" class="h-5 w-5" />
  """
  def checkbox(assigns) do
    ~H"""
    <input
      type="checkbox"
      id={@id}
      name={@name}
      value={@value}
      checked={@checked}
      disabled={@disabled}
      data-state={data_state(@indeterminate, @checked)}
      aria-checked={aria_checked(@indeterminate, @checked)}
      class={cn([
        "phia-touch-target",
        "h-4 w-4 shrink-0 rounded-sm border border-primary",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "accent-primary",
        @class
      ])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — FormField-integrated
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct obtained via `@form[:field_name]`. Provides
    the input `id`, `name`, and current `value` (used to derive `checked` state
    via `Phoenix.HTML.Form.normalize_value/2`), plus `errors` for validation.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered in a `<label>` next to the checkbox. The label is associated
    via `for`/`id` so clicking it toggles the checkbox. When `nil`, only the
    checkbox is rendered with no label.
    """
  )

  attr(:indeterminate, :boolean,
    default: false,
    doc: """
    When `true`, renders the checkbox in the indeterminate state. Useful for
    "select all" controls. See the standalone `checkbox/1` docs for details.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, disables the entire field (checkbox + label). The wrapper gains
    `opacity-50 pointer-events-none` to visually communicate the disabled state.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the flex wrapper `<div>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-click form required),
    doc: "HTML attributes forwarded to the underlying checkbox input element."
  )

  @doc """
  Renders a checkbox integrated with `Phoenix.HTML.FormField`.

  Produces a `<div>` wrapper containing the checkbox input and an optional
  `<label>`. Changeset errors from `field.errors` are displayed as `<p>`
  elements below the wrapper in destructive colour.

  The `checked` state is derived from `field.value` via
  `Phoenix.HTML.Form.normalize_value/2`, which handles the common case where
  the field value may be `true`, `"true"`, `"on"`, or `false`.

  When `field.errors` is non-empty, `aria-invalid="true"` is set on the input
  element for screen reader accessibility.

  ## Examples

      <%!-- Terms of service --%>
      <.form_checkbox field={@form[:agreed_to_terms]} label="I accept the Terms of Service" />

      <%!-- Newsletter subscription with phx-change --%>
      <.form_checkbox
        field={@form[:subscribed]}
        label="Subscribe to newsletter"
        phx-change="toggle_subscription"
      />

      <%!-- Disabled field --%>
      <.form_checkbox
        field={@form[:agreed_to_terms]}
        label="Terms accepted (cannot be changed)"
        disabled={true}
      />

      <%!-- Inside a settings form --%>
      <.form for={@form} phx-submit="save_settings">
        <.form_checkbox field={@form[:email_notifications]} label="Email notifications" />
        <.form_checkbox field={@form[:sms_notifications]}   label="SMS notifications" />
        <.form_checkbox field={@form[:push_notifications]}  label="Push notifications" />
        <.button type="submit">Save</.button>
      </.form>
  """
  def form_checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      # Translate raw {msg, opts} tuples to interpolated strings for the template.
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      # normalize_value handles boolean, string "true"/"false", and "on"/"off" values
      # from browser checkbox submissions so the checked state is always a boolean.
      |> assign(:checked, HTMLForm.normalize_value("checkbox", field.value))

    ~H"""
    <div class={cn(["flex items-center gap-2", @disabled && "opacity-50 pointer-events-none", @class])}>
      <.checkbox
        id={@field.id}
        name={@field.name}
        value="true"
        checked={@checked}
        indeterminate={@indeterminate}
        disabled={@disabled}
        aria-invalid={@errors != [] && "true"}
        {@rest}
      />
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
    </div>
    <p :for={error <- @errors} class="text-sm text-destructive mt-1">
      {error}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Three-way pattern match for data-state attribute.
  # Indeterminate takes priority — even if @checked is true, an indeterminate
  # state should always visually show as "indeterminate" for "select all" UIs.
  defp data_state(true, _checked), do: "indeterminate"
  defp data_state(false, true), do: "checked"
  defp data_state(false, false), do: "unchecked"

  # Three-way pattern match for aria-checked attribute.
  # WAI-ARIA spec uses "mixed" (not "indeterminate") for the third state.
  # This communicates to screen readers that the checkbox is partially selected.
  defp aria_checked(true, _checked), do: "mixed"
  defp aria_checked(false, true), do: "true"
  defp aria_checked(false, false), do: "false"

  # Interpolates %{key} placeholders from the opts keyword list.
  # Ecto changeset errors are tuples like {"must be accepted", [validation: :acceptance]}.
  # This lightweight substitution handles all standard Ecto error formats.
  # After ejection, replace with Gettext.dgettext/4 for i18n support.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
