defmodule PhiaUi.Components.PasswordInput do
  @moduledoc """
  Password input with a visibility toggle button.

  Provides a styled `<input type="password">` wrapped in a relative container
  with an absolute-positioned toggle button that switches the input between
  `type="password"` (hidden) and `type="text"` (visible) via LiveView JS.

  The toggle is purely client-side — no server round-trip required. Keyboard
  and pointer accessible: the button has `type="button"` so it does not submit
  forms, and carries an `aria-label="Show password"` for screen readers.

  ## Basic usage

      <.password_input name="password" id="pwd" placeholder="Enter password" />

  ## With default value (edit form)

      <.password_input id="pwd" name="password" value={@user.password} />

  ## Form-integrated (with label and error display)

      <.form_password_input field={@form[:password]} label="Password" />

  ## New password (sign-up form)

      <.form_password_input
        field={@form[:password]}
        label="New password"
        autocomplete="new-password"
      />

  ## Disabled state

      <.password_input id="pwd" name="password" disabled={true} />

  ## Class customisation

  Pass `:class` to merge extra Tailwind utilities into the `<input>` element
  via `cn/1`. Last-wins semantics apply:

      <.password_input id="pwd" name="password" class="font-mono tracking-widest" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # password_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Required for the JS toggle to work. Auto-generated if nil."
  )

  attr(:name, :string,
    required: true,
    doc: "HTML name attribute for the `<input>` element."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current input value."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text shown when the field is empty."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables both the input and the toggle button."
  )

  attr(:required, :boolean,
    default: false,
    doc: "Marks the input as required for native form validation."
  )

  attr(:autocomplete, :string,
    default: "current-password",
    doc: ~s(Autocomplete hint. Use "new-password" on sign-up forms.)
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional Tailwind classes merged into the `<input>` element via `cn/1`."
  )

  @doc """
  Renders a password input with an inline visibility toggle button.

  The toggle uses `Phoenix.LiveView.JS.toggle_attribute/2` to switch the
  input's `type` attribute between `"password"` and `"text"` on the client —
  no server round-trip is needed.

  Wrap in `form_password_input/1` when you need label + error integration with
  a `Phoenix.HTML.FormField`.

  ## Examples

      <%!-- Standalone input --%>
      <.password_input id="pwd" name="password" placeholder="Enter password" />

      <%!-- With a known value --%>
      <.password_input id="confirm_pwd" name="confirm_password" value={@confirm} />

      <%!-- Disabled --%>
      <.password_input id="legacy" name="old_password" disabled={true} />
  """
  def password_input(assigns) do
    assigns =
      assign_new(assigns, :id, fn ->
        "password-input-#{:erlang.unique_integer([:positive])}"
      end)

    ~H"""
    <div class="relative">
      <input
        type="password"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        required={@required}
        autocomplete={@autocomplete}
        class={cn([input_class(), @class])}
      />
      <button
        type="button"
        class="absolute right-2 top-1/2 -translate-y-1/2 h-8 w-8 flex items-center justify-center text-muted-foreground hover:text-foreground"
        aria-label="Show password"
        disabled={@disabled}
        phx-click={Phoenix.LiveView.JS.toggle_attribute({"type", "password", "text"}, to: "##{@id}")}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
          <circle cx="12" cy="12" r="3" />
        </svg>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_password_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`. Provides id, name, value, and errors."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input. When nil, no label element is rendered."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes forwarded to the inner `password_input/1`."
  )

  attr(:rest, :global,
    include: ~w(disabled required autocomplete placeholder),
    doc: "Additional HTML attributes forwarded to the inner `password_input/1`."
  )

  @doc """
  Renders a labeled password input integrated with `Phoenix.HTML.FormField`.

  Produces a `<div>` containing:
  1. An optional `<label>` linked via `for`/`id`
  2. The `password_input/1` component with the field's id, name, and value
  3. One `<p class="text-sm text-destructive">` per changeset error

  ## Examples

      <%!-- Sign-in form --%>
      <.form_password_input field={@form[:password]} label="Password" />

      <%!-- Sign-up form with new-password autocomplete --%>
      <.form_password_input
        field={@form[:password]}
        label="New password"
        autocomplete="new-password"
      />

      <%!-- Disabled --%>
      <.form_password_input field={@form[:password]} label="Password" disabled={true} />
  """
  def form_password_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <.password_input
        id={@id}
        name={@name}
        value={@value}
        class={@class}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm text-destructive">
        {error}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp input_class do
    "flex h-10 w-full rounded-md border border-border bg-background px-3 py-2 pr-10 " <>
      "text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end

  # Interpolates %{key} placeholders from Ecto error opts.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
