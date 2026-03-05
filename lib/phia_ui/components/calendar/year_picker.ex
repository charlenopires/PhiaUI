defmodule PhiaUi.Components.YearPicker do
  @moduledoc """
  Year selection input — styled `<input type="number">` scoped to year ranges.

  Wraps an HTML number input with PhiaUI's input styling (borders, focus ring,
  size variants, error state). Supports standalone use or Phoenix form field
  integration with changeset error display.

  Present in many UI kits: Ant Design `DatePicker` (year mode), MUI `DatePicker`
  (year view), Mantine `YearPickerInput`.

  Zero JavaScript — uses the native browser number input with `min`/`max` bounds.

  ## Examples

      <%!-- Standalone --%>
      <.year_picker id="year" name="year" label="Year" value={2026} />

      <%!-- Custom range --%>
      <.year_picker id="year" name="year" min_year={2000} max_year={2030} />

      <%!-- Form field integration --%>
      <.year_picker
        id="event_year"
        name={@form[:year].name}
        value={@form[:year].value}
        errors={Enum.map(@form[:year].errors, &translate_error/1)}
        label="Event Year"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Attributes
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML `id` for the input and label `for` link.")
  attr(:name, :string, default: nil, doc: "HTML `name` for form submission.")
  attr(:value, :integer, default: nil, doc: "Current year value as an integer, e.g. `2026`.")
  attr(:label, :string, default: nil, doc: "Label text rendered above the input.")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the label.")
  attr(:errors, :list, default: [], doc: "List of error message strings.")

  attr(:min_year, :integer,
    default: 1900,
    doc: "Minimum selectable year (maps to the `min` attribute)."
  )

  attr(:max_year, :integer,
    default: 2100,
    doc: "Maximum selectable year (maps to the `max` attribute)."
  )

  attr(:disabled, :boolean, default: false, doc: "Disables the input.")

  attr(:size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Input height/padding: `:sm` (h-8), `:default` (h-10), `:lg` (h-12)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged onto the input.")

  attr(:rest, :global,
    include: ~w(required placeholder phx-debounce step),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  def year_picker(assigns) do
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
        type="number"
        id={@id}
        name={@name}
        value={@value}
        min={@min_year}
        max={@max_year}
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

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

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
  defp error_class(_), do: "border-destructive focus-visible:ring-destructive"
end
