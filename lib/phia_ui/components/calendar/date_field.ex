defmodule PhiaUi.Components.DateField do
  @moduledoc """
  Form-aware standalone date input component for Phoenix LiveView.

  `date_field/1` renders a styled `<input type="date">` — label, optional
  description, date input, and inline validation errors. It is a lightweight
  alternative to `date_picker/1` (which opens a popover calendar); `date_field/1`
  uses the native browser date picker with no JavaScript.

  ## Usage

      <.date_field id="start" name="start_date" label="Start date" />

      <.date_field
        id="due"
        name="due_date"
        label="Due date"
        description="Must be in the future"
        min={Date.to_iso8601(Date.utc_today())}
      />

      <.date_field
        id="birth"
        name="birth_date"
        value="1990-01-15"
        label="Date of birth"
        max="2010-12-31"
        errors={["is required"]}
      />

  ## Error display

  Pass a list of pre-translated error strings via `:errors`. For form-aware
  integration, use `phia_input/1` with `type="date"` or `date_picker/1`.

  ## Global attributes

  The following HTML attributes are forwarded to the `<input>` element via
  the `:global` attribute: `required`, `placeholder`, `phx-debounce`,
  `autocomplete`, `min`, `max`.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:disabled, :boolean, default: false)
  attr(:size, :atom, default: :default, values: [:sm, :default, :lg])
  attr(:class, :string, default: nil)

  attr(:rest, :global,
    include: ~w(required placeholder phx-debounce autocomplete min max)
  )

  def date_field(assigns) do
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
        type="date"
        id={@id}
        name={@name}
        value={@value}
        disabled={@disabled}
        class={cn([input_class(@size), error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">
        {error}
      </p>
    </div>
    """
  end

  defp input_class(:sm) do
    "flex h-8 w-full rounded-md border border-input bg-background px-2 py-1 text-xs " <>
      "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp input_class(:default) do
    "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm " <>
      "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp input_class(:lg) do
    "flex h-12 w-full rounded-md border border-input bg-background px-4 py-3 text-base " <>
      "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp error_class([]), do: nil
  defp error_class(_errors), do: "border-destructive focus-visible:ring-destructive"
end
