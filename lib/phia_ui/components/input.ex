defmodule PhiaUi.Components.Input do
  @moduledoc """
  Form-aware Input component integrating with `Phoenix.HTML.FormField`.

  Renders a labeled text input with optional description text and inline
  error messages derived from the changeset. Designed for use inside
  `Phoenix.Component.form/1` or `Phoenix.HTML.Form`.

  ## Example

      <.form for={@form}>
        <.phia_input field={@form[:email]} label="Email" description="We'll never share it." />
        <.phia_input field={@form[:password]} type="password" label="Password"
                     phx-debounce="blur" />
      </.form>

  ## Error handling

  Errors are read directly from `field.errors` (a list of `{msg, opts}` tuples)
  and interpolated via the built-in `translate_error/1`. For Gettext-aware
  translations, translate errors before passing the field or override the
  component after ejection.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct (e.g., `@form[:email]`)"

  attr :label, :string, default: nil, doc: "Label text displayed above the input"

  attr :description, :string,
    default: nil,
    doc: "Helper text displayed below the label"

  attr :type, :string, default: "text", doc: "HTML input type"

  attr :class, :string, default: nil, doc: "Additional CSS classes for the input element"

  attr :rest, :global,
    include: ~w(autocomplete readonly disabled step max min placeholder phx-debounce),
    doc: "HTML attributes forwarded to the input element"

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
        class={cn([base_class(), error_class(@errors), @class])}
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

  defp base_class do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 " <>
      "text-sm ring-offset-background file:border-0 file:bg-transparent " <>
      "file:text-sm file:font-medium placeholder:text-muted-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp error_class([]), do: nil
  defp error_class(_errors), do: "border-destructive focus-visible:ring-destructive"

  # Interpolates %{key} placeholders from the opts keyword list.
  # This is a lightweight fallback — after ejection you can replace it
  # with Gettext.dgettext/4 for proper i18n support.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
