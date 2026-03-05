defmodule PhiaUi.Components.PhiaInput do
  @moduledoc """
  Form-aware standalone input component for Phoenix LiveView.

  `phia_input/1` renders a complete input field — label, optional description,
  `<input>` element, and inline validation errors — bound directly to a
  `Phoenix.HTML.FormField`. It is the all-in-one alternative to composing
  `form_field/1` with a bare `<input>`.

  ## Usage

      <.phia_input field={@form[:email]} type="email" label="Email address" />

      <.phia_input
        field={@form[:username]}
        label="Username"
        description="3–20 characters, letters and numbers only"
        phx-debounce="300"
      />

      <.phia_input field={@form[:password]} type="password" label="Password" />

  ## Error display

  Errors are sourced from `field.errors` and translated via the built-in
  placeholder interpolator, or the configured
  `{Module, :function}` set in:

      config :phia_ui, :error_translator_function, {MyApp.CoreComponents, :translate_error}

  ## Global attributes

  The following HTML attributes are forwarded to the `<input>` element via
  the `:global` attribute: `autocomplete`, `readonly`, `disabled`, `step`,
  `max`, `min`, `placeholder`, `phx-debounce`.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:type, :string, default: "text")
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)

  attr(:rest, :global,
    include: ~w(autocomplete readonly disabled step max min placeholder phx-debounce)
  )

  def phia_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        class={cn([base_class(), error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">
        {error}
      </p>
    </div>
    """
  end

  defp base_class do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 " <>
      "text-sm ring-offset-background file:border-0 file:bg-transparent " <>
      "file:text-sm file:font-medium placeholder:text-muted-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp error_class([]), do: nil
  defp error_class(_errors), do: "border-destructive focus-visible:ring-destructive"

  defp translate_error({msg, opts}) do
    translator = Application.get_env(:phia_ui, :error_translator_function)

    if translator do
      {mod, fun} = translator
      apply(mod, fun, [{msg, opts}])
    else
      Enum.reduce(opts, msg, fn
        {key, value}, acc when is_binary(acc) ->
          String.replace(acc, "%{#{key}}", to_string(value))

        _other, acc ->
          acc
      end)
    end
  end
end
