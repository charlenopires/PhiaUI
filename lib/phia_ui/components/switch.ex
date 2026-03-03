defmodule PhiaUi.Components.Switch do
  @moduledoc """
  Switch (toggle on/off) component for PhiaUI.

  A two-state button rendered as an accessible on/off switch with
  `role="switch"` and `aria-checked`. Animates the thumb with a CSS
  `translate-x` transition — zero JavaScript required.

  Use `switch/1` for standalone switches and `form_switch/1` for integration
  with `Phoenix.HTML.FormField` and Ecto changesets.

  ## Examples

      <%!-- Standalone switch --%>
      <.switch checked={@enabled} phx-click="toggle" />

      <%!-- With label (compose manually) --%>
      <label class="flex items-center gap-3">
        <.switch checked={@notifications} phx-click="toggle_notifications" />
        <span>Enable notifications</span>
      </label>

      <%!-- Form-integrated switch --%>
      <.form_switch field={@form[:active]} label="Active" />

      <%!-- Disabled --%>
      <.switch checked={false} disabled />

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:checked, :boolean,
    required: true,
    doc: "Whether the switch is in the on (checked) state."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables the switch and reduces opacity."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the button."
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value name),
    doc: "HTML attributes forwarded to the button element."
  )

  @doc """
  Renders a standalone accessible switch button.
  """
  def switch(assigns) do
    ~H"""
    <button
      type="button"
      role="switch"
      aria-checked={to_string(@checked)}
      disabled={@disabled}
      class={cn([
        "relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full",
        "border-2 border-transparent transition-colors duration-200 ease-in-out",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        track_color(@checked),
        @disabled && "opacity-50 pointer-events-none",
        @class
      ])}
      {@rest}
    >
      <span class={cn([
        "pointer-events-none inline-block h-5 w-5 rounded-full bg-background shadow-sm",
        "transition-transform duration-200 ease-in-out",
        thumb_translate(@checked)
      ])}>
      </span>
    </button>
    """
  end

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "`Phoenix.HTML.FormField` struct from a form."
  )

  attr(:label, :string,
    default: nil,
    doc: "Optional label text rendered next to the switch."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper."
  )

  @doc """
  Renders a switch integrated with `Phoenix.HTML.Form`.

  The field value is used to derive the checked state. Uses a hidden
  checkbox input inside a `<label>` — clicking the visual switch toggles
  the checkbox without any JavaScript.
  """
  def form_switch(assigns) do
    assigns = assign(assigns, :checked, truthy?(assigns.field.value))

    ~H"""
    <label class={cn(["flex items-center gap-3 cursor-pointer", @class])}>
      <input
        type="checkbox"
        id={@field.id}
        name={@field.name}
        value="true"
        checked={@checked}
        class="sr-only"
      />
      <.switch checked={@checked} />
      <span :if={@label} class="text-sm font-medium leading-none">
        {@label}
      </span>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp track_color(true), do: "bg-primary"
  defp track_color(false), do: "bg-input"

  defp thumb_translate(true), do: "translate-x-5"
  defp thumb_translate(false), do: "translate-x-0"

  defp truthy?(value) when value in [true, "true", "on", 1, "1"], do: true
  defp truthy?(_), do: false
end
