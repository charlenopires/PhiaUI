defmodule PhiaUi.Components.Switch do
  @moduledoc """
  Accessible on/off switch component for Phoenix LiveView.

  A two-state toggle rendered as a pill-shaped track with an animated sliding
  thumb. Uses `role="switch"` and `aria-checked` for full WAI-ARIA compliance.
  The animation is pure CSS (`translate-x` transition) — zero JavaScript required.

  ## Sub-components

  | Function       | Purpose                                                              |
  |----------------|----------------------------------------------------------------------|
  | `switch/1`     | Standalone switch button — manage state in your LiveView             |
  | `form_switch/1`| Switch integrated with `Phoenix.HTML.FormField` and Ecto changesets  |

  ## When to use

  Use a switch for binary settings that take effect immediately or are submitted
  as part of a form. Switches communicate an on/off state more clearly than
  checkboxes for settings like "Enable notifications", "Public profile", or
  "Auto-renew subscription".

  Use a `checkbox/1` instead when the control is part of a list of options, or
  when the action requires explicit confirmation (e.g. "I agree to the terms").

  ## Standalone usage

      <%!-- Server-state switch: the LiveView owns the boolean --%>
      <.switch checked={@notifications_enabled} phx-click="toggle_notifications" />

      <%!-- Labelled by wrapping in a <label> --%>
      <label class="flex items-center gap-3 cursor-pointer">
        <.switch checked={@dark_mode} phx-click="toggle_dark_mode" />
        <span class="text-sm font-medium">Dark mode</span>
      </label>

      <%!-- Disabled --%>
      <.switch checked={true} disabled />

  ## Form-integrated usage

  `form_switch/1` wraps a hidden checkbox so the value is submitted as part of
  the form. Clicking the visual switch toggles the hidden input without JS:

      <.form for={@form} phx-submit="save_settings" phx-change="validate">
        <.form_switch field={@form[:email_notifications]} label="Email notifications" />
        <.form_switch field={@form[:sms_notifications]}   label="SMS notifications" />
        <.form_switch field={@form[:marketing_emails]}    label="Marketing emails" />
        <.button type="submit">Save settings</.button>
      </.form>

  ## Settings panel example

      defmodule MyAppWeb.SettingsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          changeset = Settings.change_notifications(socket.assigns.current_user)
          {:ok, assign(socket, form: to_form(changeset))}
        end

        def handle_event("save_settings", %{"settings" => params}, socket) do
          case Settings.update_notifications(socket.assigns.current_user, params) do
            {:ok, _settings} -> {:noreply, put_flash(socket, :info, "Settings saved")}
            {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
          end
        end
      end

  ## Accessibility

  - `role="switch"` identifies the element as a switch widget to screen readers
  - `aria-checked="true"` / `"false"` reflects the on/off state
  - `disabled` prevents interaction and sets `aria-disabled` via the native attribute
  - The focus ring (`focus-visible:ring-2`) ensures keyboard navigability
  - In `form_switch/1`, the label is associated with the hidden input via `for`/`id`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # switch/1 — standalone
  # ---------------------------------------------------------------------------

  attr(:checked, :boolean,
    required: true,
    doc: """
    Whether the switch is in the on (checked) state. Controls the track colour
    and thumb position. Pass a boolean from your LiveView assigns and update it
    via `phx-click`.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, disables the switch. The button becomes non-interactive
    (`pointer-events-none`) and renders at 50% opacity to communicate its
    inactive state. The native `disabled` attribute is also set.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes applied to the outer `<button>` element via `cn/1`.
    Use to adjust sizing or spacing. Example: `class="scale-125"`.
    """
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value name),
    doc: """
    HTML attributes forwarded to the `<button>` element. Typically used for
    `phx-click` to toggle state in the LiveView:
    `phx-click="toggle_feature" phx-value-feature="notifications"`
    """
  )

  @doc """
  Renders a standalone accessible switch button.

  The switch is a `<button type="button">` with `role="switch"` and
  `aria-checked`. Track colour transitions from `bg-input` (off) to `bg-primary`
  (on). The thumb slides with a `translate-x` CSS transition — no JavaScript.

  Manage the state in your LiveView by passing `:checked` from your assigns
  and handling the `phx-click` event to toggle the boolean:

      # In your LiveView:
      def handle_event("toggle_notifications", _params, socket) do
        {:noreply, assign(socket, notifications: !socket.assigns.notifications)}
      end

      # In your template:
      <.switch checked={@notifications} phx-click="toggle_notifications" />

  ## Examples

      <%!-- Basic off/on --%>
      <.switch checked={false} phx-click="toggle" />
      <.switch checked={true}  phx-click="toggle" />

      <%!-- Disabled --%>
      <.switch checked={false} disabled />
      <.switch checked={true}  disabled />

      <%!-- With phx-value for context --%>
      <.switch
        checked={@feature_enabled}
        phx-click="toggle_feature"
        phx-value-feature="dark_mode"
      />

      <%!-- Custom size via class --%>
      <.switch checked={@enabled} phx-click="toggle" class="scale-90" />
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

  # ---------------------------------------------------------------------------
  # form_switch/1 — FormField-integrated
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct obtained via `@form[:field_name]`. Provides
    the hidden input `id` and `name`, and the current `value` used to derive the
    `checked` state via `truthy?/1`.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered next to the switch inside a `<label>`. The label wraps both
    the hidden input and the visual switch, so clicking anywhere on the row
    (label text or switch) toggles the checkbox. When `nil`, only the switch
    is rendered.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<label>` wrapper element."
  )

  @doc """
  Renders a switch integrated with `Phoenix.HTML.Form`.

  Internally uses a hidden `<input type="checkbox">` so the value is submitted
  as part of the form payload without JavaScript. The visual `switch/1` component
  reads `checked` from the field value and reflects the state via CSS.

  The `<label>` wraps both the hidden checkbox and the visual switch, making
  the entire row clickable to toggle the value. This is the standard PhiaUI
  pattern for form-bound switches.

  The field value is normalised via `truthy?/1` which handles `true`, `"true"`,
  `"on"`, `1`, and `"1"` as truthy — matching all the ways a checkbox value
  may arrive from browser submissions or Ecto changesets.

  ## Examples

      <%!-- Settings form --%>
      <.form for={@form} phx-submit="save">
        <.form_switch field={@form[:active]}         label="Account active" />
        <.form_switch field={@form[:email_opt_in]}   label="Email notifications" />
        <.form_switch field={@form[:two_factor_auth]} label="Two-factor authentication" />
        <.button type="submit">Save</.button>
      </.form>

      <%!-- Single inline setting --%>
      <.form_switch field={@form[:public_profile]} label="Make profile public" />

      <%!-- Without label --%>
      <.form_switch field={@form[:enabled]} />
  """
  def form_switch(assigns) do
    # Normalise all truthy representations to a plain boolean for the template.
    # Browser checkboxes submit "on" when checked and omit the field when unchecked,
    # while Ecto boolean fields may return true/false or "true"/"false" strings.
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

  # Two-clause match for track colour: primary (on) vs input (off).
  # Using pattern matching instead of a ternary keeps the intent explicit
  # and consistent with the codebase style — no case/cond expressions.
  defp track_color(true), do: "bg-primary"
  defp track_color(false), do: "bg-input"

  # Two-clause match for thumb horizontal offset.
  # translate-x-5 = 20px which equals the track width minus thumb width (44-20=24px approx),
  # landing the thumb flush with the right edge of the track when checked.
  defp thumb_translate(true), do: "translate-x-5"
  defp thumb_translate(false), do: "translate-x-0"

  # Normalises all common truthy representations to a boolean.
  # Browser checkboxes submit "on" when checked; Ecto may store true/"true"/1.
  # The catch-all clause maps everything else (nil, false, "false", "off") to false.
  defp truthy?(value) when value in [true, "true", "on", 1, "1"], do: true
  defp truthy?(_), do: false
end
