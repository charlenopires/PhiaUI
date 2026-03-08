defmodule PhiaUi.Components.Input do
  @moduledoc """
  Form-aware text input component integrating with `Phoenix.HTML.FormField`.

  `phia_input/1` renders a labeled `<input>` element with optional description
  text and inline validation error messages sourced directly from the Ecto
  changeset. It is the building block for text-based form fields in PhiaUI.

  ## When to use

  Use `phia_input/1` whenever you need a single-line text, email, password,
  number, or URL input that is bound to an Ecto changeset field. For multi-line
  text, use `phia_textarea/1` instead. For select dropdowns, use `phia_select/1`.

  ## Basic usage

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.phia_input field={@form[:email]} label="Email address" />
        <.phia_input field={@form[:password]} type="password" label="Password" />
        <.button type="submit">Sign in</.button>
      </.form>

  ## With description and debounce

  The `:description` attribute renders helper text below the label. Combine with
  `phx-debounce` to avoid validating on every keystroke:

      <.phia_input
        field={@form[:username]}
        label="Username"
        description="3–20 characters. Letters, numbers, and underscores only."
        phx-debounce="blur"
      />

  ## Number input with constraints

      <.phia_input
        field={@form[:age]}
        type="number"
        label="Age"
        min="18"
        max="120"
        placeholder="Your age"
      />

  ## File input

      <.phia_input field={@form[:avatar]} type="file" label="Profile picture" />

  ## Read-only / disabled

      <.phia_input field={@form[:email]} label="Email" readonly />
      <.phia_input field={@form[:plan]}  label="Plan"  disabled />

  ## Error handling

  Errors are read directly from `field.errors` — a list of `{msg, opts}` tuples
  produced by Ecto's changeset validation. They are interpolated via the built-in
  `translate_error/1` which substitutes `%{key}` placeholders from `opts`.

  For Gettext-aware translations, translate the errors before passing the field
  or replace `translate_error/1` after ejection:

      # After `mix phia.eject Input`, customise lib/my_app_web/components/input.ex:
      defp translate_error({msg, opts}) do
        Gettext.dgettext(MyAppWeb.Gettext, "errors", msg, opts)
      end

  ## Class customisation

  Pass `:class` to merge additional Tailwind classes into the input via `cn/1`.
  The last-wins merge strategy means your classes override the defaults:

      <.phia_input field={@form[:code]} label="Code" class="font-mono tracking-widest" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct, typically obtained via `@form[:field_name]`
    inside a `Phoenix.Component.form/1` block. Provides the input `id`, `name`,
    `value`, and `errors` automatically.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered in a `<label>` element above the input. The label is associated
    with the input via `for`/`id` so clicking it focuses the input. When `nil`,
    no label element is rendered — useful when the label is provided externally.
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Helper text rendered below the label but above the input. Use it to explain
    format requirements, constraints, or privacy notes. Rendered in
    `text-muted-foreground` to visually separate it from the label.
    """
  )

  attr(:type, :string,
    default: "text",
    doc: """
    HTML `<input>` type attribute. Common values: `"text"` (default), `"email"`,
    `"password"`, `"number"`, `"url"`, `"tel"`, `"search"`, `"file"`, `"date"`.
    The component passes this value unchanged to the native element.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional Tailwind CSS classes applied to the `<input>` element. Merged via
    `cn/1` so conflicting utilities are resolved by last-wins. Example:
    `class="font-mono"` to render a monospace code input.
    """
  )

  attr(:rest, :global,
    include: ~w(autocomplete readonly disabled step max min placeholder phx-debounce),
    doc: """
    Additional HTML attributes forwarded directly to the `<input>` element.
    Commonly used attributes include:
    - `autocomplete` — browser autocomplete hint (e.g. `"email"`, `"new-password"`)
    - `placeholder` — ghost text shown when the field is empty
    - `phx-debounce` — delay (ms) or `"blur"` before sending `phx-change` events
    - `readonly` — prevents editing without disabling form submission
    - `disabled` — disables the input entirely
    - `min` / `max` / `step` — numeric constraints for `type="number"` inputs
    """
  )

  @doc """
  Renders a labeled text input integrated with `Phoenix.HTML.FormField`.

  Produces a `<div>` containing:
  1. An optional `<label>` linked via `for`/`id`
  2. An optional description `<p>` in muted foreground
  3. The `<input>` element with full Tailwind styling and focus ring
  4. One `<p class="text-destructive">` per changeset error

  The input ID, name, and value are derived from the `field` struct automatically.
  When `field.errors` is non-empty, the input gains a destructive border and focus
  ring to give an immediate visual error signal alongside the error text below.

  ## Examples

      <%!-- Minimal — label from the field struct --%>
      <.phia_input field={@form[:email]} label="Email" />

      <%!-- With placeholder and debounce --%>
      <.phia_input
        field={@form[:email]}
        label="Email"
        placeholder="you@example.com"
        phx-debounce="blur"
      />

      <%!-- Password field --%>
      <.phia_input field={@form[:password]} type="password" label="Password" />

      <%!-- Number with range constraints --%>
      <.phia_input field={@form[:quantity]} type="number" label="Quantity" min="1" max="99" />

      <%!-- Custom class override --%>
      <.phia_input field={@form[:code]} label="Invite code" class="uppercase font-mono" />
  """
  def phia_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      # Translate raw {msg, opts} error tuples into interpolated strings
      # so the template only deals with plain binaries.
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      # Use assign_new so callers can override id/name/value if needed.
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
        <%= @label %>
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">
        <%= @description %>
      </p>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        class={cn(["phia-touch-target", base_class(), error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">
        <%= error %>
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns the full baseline Tailwind class string for the input element.
  # Defined as a function (not a module attribute) so it participates in
  # cn/1 merging at call time rather than being evaluated at compile time.
  defp base_class do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 " <>
      "text-sm ring-offset-background file:border-0 file:bg-transparent " <>
      "file:text-sm file:font-medium placeholder:text-muted-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  # Returns nil when there are no errors (cn/1 ignores nil entries), or the
  # destructive border/ring classes that paint the input red on validation failure.
  # Pattern matching on an empty list avoids an `if` expression in the template.
  defp error_class([]), do: nil
  defp error_class(_errors), do: "border-destructive focus-visible:ring-destructive"

  # Interpolates %{key} placeholders from the opts keyword list.
  # Ecto validation messages use this format, e.g.:
  #   {"should be at most %{count} character(s)", [count: 10, validation: :length]}
  # This lightweight implementation handles the common case. After ejection,
  # replace with Gettext.dgettext/4 for proper i18n support.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
