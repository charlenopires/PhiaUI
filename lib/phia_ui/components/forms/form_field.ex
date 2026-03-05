defmodule PhiaUi.Components.FormField do
  @moduledoc """
  Composable form field wrapper for Phoenix LiveView.

  `form_field/1` provides a consistent layout shell — label, slot, optional
  description, and inline error messages — around any arbitrary input element
  passed via its `inner_block` slot. Use it when you need to compose your own
  input controls (e.g. custom selects, radio groups) while keeping the same
  visual structure as `PhiaUi.Components.PhiaInput`.

  ## Usage

      <.form_field field={@form[:email]} label="Email">
        <input id={@form[:email].id} name={@form[:email].name} type="email" />
      </.form_field>

      <.form_field
        field={@form[:role]}
        label="Role"
        description="Select the user's access level"
      >
        <.phia_select field={@form[:role]} options={@roles} />
      </.form_field>

  ## Error display

  Errors are sourced from `field.errors` and translated via the built-in
  placeholder interpolator, or the configured
  `{Module, :function}` set in:

      config :phia_ui, :error_translator_function, {MyApp.CoreComponents, :translate_error}
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def form_field(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <%= render_slot(@inner_block) %>
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <p :for={error <- @field.errors} class="text-sm font-medium text-destructive">
        {translate_error(error)}
      </p>
    </div>
    """
  end

  defp translate_error({msg, opts}) do
    translator = Application.get_env(:phia_ui, :error_translator_function)

    if translator do
      {mod, fun} = translator
      apply(mod, fun, [{msg, opts}])
    else
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end
  end
end
