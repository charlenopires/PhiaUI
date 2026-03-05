defmodule PhiaUi.Components.TimePicker do
  @moduledoc """
  Time selection input — styled native `<input type="time">`.

  Wraps the browser's native time picker with PhiaUI's input styling (borders,
  focus ring, size variants, error state). Supports standalone use or
  Phoenix form field integration with changeset error display.

  Present in every major UI kit: Mantine `TimeInput`, Ant Design `TimePicker`,
  MUI `TimePicker`, React Aria `TimeField`.

  Zero JavaScript — uses the native browser time control.

  ## Examples

      <%!-- Standalone --%>
      <.time_picker id="start" name="start_time" label="Start Time" value="09:00" />

      <%!-- With seconds --%>
      <.time_picker id="dur" name="duration" with_seconds={true} />

      <%!-- Form field integration --%>
      <.time_picker
        id="event_time"
        name={@form[:time].name}
        value={@form[:time].value}
        errors={Enum.map(@form[:time].errors, &translate_error/1)}
        label="Event Time"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Attributes
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML `id` for the input and label `for` link.")
  attr(:name, :string, default: nil, doc: "HTML `name` for form submission.")
  attr(:value, :string, default: nil, doc: "Current time value as `\"HH:MM\"` or `\"HH:MM:SS\"`.")
  attr(:label, :string, default: nil, doc: "Label text rendered above the input.")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the label.")
  attr(:errors, :list, default: [], doc: "List of error message strings.")

  attr(:with_seconds, :boolean,
    default: false,
    doc: "When `true`, sets `step=\"1\"` so seconds are shown in the native picker."
  )

  attr(:disabled, :boolean, default: false, doc: "Disables the input.")

  attr(:size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Input height/padding: `:sm` (h-8), `:default` (h-10), `:lg` (h-12)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged onto the input.")

  attr(:rest, :global,
    include: ~w(required placeholder phx-debounce autocomplete min max),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  def time_picker(assigns) do
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
        type="time"
        id={@id}
        name={@name}
        value={@value}
        disabled={@disabled}
        step={if @with_seconds, do: "1"}
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
