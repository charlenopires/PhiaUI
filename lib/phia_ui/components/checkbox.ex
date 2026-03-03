defmodule PhiaUi.Components.Checkbox do
  @moduledoc """
  Native HTML checkbox component styled with Tailwind CSS.

  Integrates with `Phoenix.HTML.FormField` and Ecto changesets.
  Supports checked, unchecked, and indeterminate states.

  ## Sub-components

  - `checkbox/1` — standalone checkbox input
  - `form_checkbox/1` — checkbox with label and error messages, integrated
    with `Phoenix.HTML.FormField`

  ## Examples

      <%!-- Standalone checkbox --%>
      <.checkbox id="agree" name="agree" checked={true} />

      <%!-- With indeterminate state --%>
      <.checkbox id="select-all" name="select_all" indeterminate={true} />

      <%!-- Form-integrated checkbox --%>
      <.form_checkbox field={@form[:agreed]} label="I agree to the terms" />

      <%!-- With phx-change --%>
      <.checkbox id="cb" name="cb" phx-change="toggle_item" />
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form, as: HTMLForm

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, default: nil, doc: "Input ID")
  attr(:name, :string, default: nil, doc: "Input name")
  attr(:value, :string, default: "true", doc: "Checkbox value when checked")
  attr(:checked, :boolean, default: false, doc: "Whether the checkbox is checked")

  attr(:indeterminate, :boolean,
    default: false,
    doc: "Whether the checkbox is in indeterminate state (aria-checked=mixed)"
  )

  attr(:disabled, :boolean, default: false, doc: "Whether the checkbox is disabled")

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes (merged via cn/1, last wins)"
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-click form required aria-invalid),
    doc: "HTML attributes forwarded to the input element"
  )

  @doc """
  Renders a styled native `<input type="checkbox">` element.

  Uses semantic Tailwind tokens (`border-primary`, `accent-primary`) so it
  respects the PhiaUI theme in both light and dark mode without any JS.

  The `data-state` attribute is set to `"checked"`, `"unchecked"`, or
  `"indeterminate"` and can be used for CSS-based styling. For the
  indeterminate state, `aria-checked="mixed"` is applied for screen readers.

  ## Examples

      <.checkbox id="agree" name="agree" />

      <.checkbox id="agree" name="agree" checked={true} />

      <.checkbox id="all" name="all" indeterminate={true} />

      <.checkbox id="agree" name="agree" disabled={true} />

      <.checkbox id="agree" name="agree" phx-change="toggle" />
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

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct (e.g., `@form[:agreed]`)"
  )

  attr(:label, :string, default: nil, doc: "Label text displayed next to the checkbox")

  attr(:indeterminate, :boolean,
    default: false,
    doc: "Whether the checkbox is in indeterminate state"
  )

  attr(:disabled, :boolean, default: false, doc: "Whether the checkbox is disabled")

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the wrapper element"
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-click form required),
    doc: "HTML attributes forwarded to the checkbox input"
  )

  @doc """
  Renders a checkbox integrated with `Phoenix.HTML.FormField`.

  Produces a `<div>` wrapper containing the checkbox input, an optional
  `<label>`, and one `<p>` per error sourced from `field.errors`. Errors
  are displayed in destructive color below the checkbox.

  When `field.errors` is non-empty, `aria-invalid="true"` is set on the
  input for screen reader accessibility.

  ## Examples

      <.form_checkbox field={@form[:agreed]} label="I accept the terms" />

      <.form_checkbox field={@form[:subscribed]}
                      label="Subscribe to newsletter"
                      phx-change="toggle_subscription" />

      <.form_checkbox field={@form[:agreed]} disabled={true} />
  """
  def form_checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
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

  defp data_state(true, _checked), do: "indeterminate"
  defp data_state(false, true), do: "checked"
  defp data_state(false, false), do: "unchecked"

  defp aria_checked(true, _checked), do: "mixed"
  defp aria_checked(false, true), do: "true"
  defp aria_checked(false, false), do: "false"

  # Interpolates %{key} placeholders from the opts keyword list.
  # Lightweight fallback — after ejection can be replaced with Gettext for i18n.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
