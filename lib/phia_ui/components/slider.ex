defmodule PhiaUi.Components.Slider do
  @moduledoc """
  Range slider component for continuous numeric value selection.

  `slider/1` is a CSS-only `input[type=range]` with semantic Tailwind tokens and
  full WAI-ARIA attributes. `form_slider/1` integrates it with `Phoenix.HTML.FormField`
  and Ecto changesets, adding label, description, and error display.

  No JavaScript is required — the browser handles all drag, click, and keyboard
  interaction natively.

  ## When to use

  Use a slider when:
  - The range of valid values is continuous or has many discrete steps
  - The precise value matters less than the relative position (volume, brightness)
  - You want to allow quick adjustment without typing

  Use `phia_input/1` with `type="number"` instead when the user needs to enter
  an exact numeric value.

  ## Standalone slider

      <%!-- Basic slider, 0–100 in steps of 1 --%>
      <.slider value={50} phx-change="update_value" name="value" />

      <%!-- Custom range and step --%>
      <.slider value={@volume} min={0} max={100} step={5} phx-change="set_volume" name="volume" />

      <%!-- Disabled --%>
      <.slider value={@brightness} disabled={true} />

  ## Form-integrated slider

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.form_slider
          field={@form[:font_size]}
          label="Font size"
          description="Controls the base font size for the editor."
          min={12}
          max={24}
          step={1}
        />
        <.form_slider
          field={@form[:opacity]}
          label="Overlay opacity"
          min={0}
          max={100}
          step={5}
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Settings panel example

      <div class="space-y-6">
        <.field>
          <.field_label>Volume</.field_label>
          <.slider value={@volume} min={0} max={100} step={1}
                   phx-change="set_volume" name="volume" />
          <.field_description>Current: {@volume}%</.field_description>
        </.field>

        <.field>
          <.field_label>Playback speed</.field_label>
          <.slider value={@speed} min={50} max={200} step={25}
                   phx-change="set_speed" name="speed" />
        </.field>
      </div>

  ## Displaying the current value

  The slider does not display a current value label — add one yourself alongside
  the component if needed:

      <div class="flex items-center justify-between">
        <span class="text-sm font-medium">Volume</span>
        <span class="text-sm text-muted-foreground">{@volume}%</span>
      </div>
      <.slider value={@volume} min={0} max={100} phx-change="set_volume" name="volume" />

  ## Keyboard interaction

  The native `input[type=range]` supports full keyboard control out-of-the-box:
  - Arrow Left / Arrow Down — decrement by one step
  - Arrow Right / Arrow Up — increment by one step
  - Home — jump to minimum value
  - End — jump to maximum value
  - Page Up / Page Down — increment/decrement by a larger step (browser-defined)

  ## Accessibility

  - `role="slider"` identifies the element to assistive technologies
  - `aria-valuenow`, `aria-valuemin`, `aria-valuemax` expose the current value
  - Focus ring (`focus-visible:ring-2`) ensures keyboard visibility
  - `disabled` attribute communicates non-interactive state to screen readers
  - When using `form_slider/1`, the label is associated via `for`/`id`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # slider/1 — standalone
  # ---------------------------------------------------------------------------

  attr(:value, :integer,
    default: 0,
    doc: """
    The current value of the slider. Must be between `:min` and `:max`.
    Pass from your LiveView assigns and update via `phx-change`.
    """
  )

  attr(:min, :integer,
    default: 0,
    doc: "Minimum allowed value. Defaults to `0`."
  )

  attr(:max, :integer,
    default: 100,
    doc: "Maximum allowed value. Defaults to `100`."
  )

  attr(:step, :integer,
    default: 1,
    doc: """
    Step increment between valid values. Defaults to `1` (continuous).
    Example: `step={5}` for 0, 5, 10, 15, ... or `step={25}` for quarters.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, disables the slider. The native `disabled` attribute prevents
    all interaction, and the element renders at 50% opacity with `cursor-not-allowed`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element via `cn/1`."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-blur name id),
    doc: """
    HTML attributes forwarded to the `<input>` element. Typically used for:
    - `name` — required for form submission
    - `id` — for label association
    - `phx-change` — LiveView event name to handle value changes
    - `phx-blur` — event fired when the slider loses focus
    """
  )

  @doc """
  Renders a range slider input.

  Uses native `input[type=range]` styled with semantic Tailwind v4 tokens.
  The `accent-primary` class colours the thumb and track fill using the active
  PhiaUI theme colour. No JavaScript hook is required.

  WAI-ARIA attributes (`role`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`)
  are set automatically from the component attributes to supplement the native
  browser semantics.

  ## Examples

      <%!-- Basic --%>
      <.slider value={50} phx-change="update" name="val" />

      <%!-- Volume control (0–100, step 5) --%>
      <.slider value={@volume} min={0} max={100} step={5}
               phx-change="set_volume" name="volume" />

      <%!-- Disabled preview --%>
      <.slider value={75} disabled />

      <%!-- Custom class for width --%>
      <.slider value={@rating} min={1} max={10} class="w-48" phx-change="rate" name="rating" />
  """
  def slider(assigns) do
    ~H"""
    <input
      type="range"
      value={@value}
      min={@min}
      max={@max}
      step={@step}
      disabled={@disabled}
      role="slider"
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      class={cn([slider_class(), @disabled && "opacity-50 cursor-not-allowed", @class])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — FormField-integrated
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct obtained via `@form[:field_name]`. Provides
    the input `id`, `name`, and current `value` for the slider position, plus
    `errors` for validation display.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered in a `<label>` above the slider, associated via `for`/`id`.
    When `nil`, no label element is rendered.
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Helper text rendered below the label. Use to explain the scale or unit,
    e.g. `"Measured in seconds"` or `"Higher is faster"`.
    """
  )

  attr(:min, :integer,
    default: 0,
    doc: "Minimum allowed value. Defaults to `0`."
  )

  attr(:max, :integer,
    default: 100,
    doc: "Maximum allowed value. Defaults to `100`."
  )

  attr(:step, :integer,
    default: 1,
    doc: "Step increment between valid values. Defaults to `1`."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<input>` element via `cn/1`."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-blur phx-debounce disabled),
    doc: """
    HTML attributes forwarded to the `<input>` element. Commonly used:
    - `phx-change` — validate on each position change
    - `phx-debounce` — throttle change events (e.g. `phx-debounce="300"`)
    - `disabled` — disables the slider
    """
  )

  @doc """
  Renders a form-integrated slider with label, description, and changeset errors.

  Produces a `<div>` containing an optional `<label>`, optional description `<p>`,
  the `<input type="range">` element, and one `<p class="text-destructive">` per
  changeset error from `field.errors`.

  The input `id`, `name`, and initial `value` are derived from the field struct.
  When `field.errors` is non-empty, the slider accent colour switches to
  `accent-destructive` to give a visual error signal alongside the error text.

  The field value defaults to `0` if `field.value` is `nil` (e.g. for a new
  record), preventing the slider from rendering without a position.

  ## Examples

      <%!-- Basic form slider --%>
      <.form_slider field={@form[:rating]} label="Rating" />

      <%!-- Custom range with description --%>
      <.form_slider
        field={@form[:font_size]}
        label="Font size"
        description="Base font size in pixels (12–24)."
        min={12}
        max={24}
        step={1}
      />

      <%!-- Inside a full settings form --%>
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.form_slider
          field={@form[:volume]}
          label="Notification volume"
          min={0}
          max={100}
          step={10}
          phx-debounce="300"
        />
        <.button type="submit">Save</.button>
      </.form>
  """
  def form_slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      # Translate raw {msg, opts} error tuples into strings for the template.
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      # Default to 0 when the changeset has no persisted value (e.g. new record),
      # so the slider always has a valid position on initial render.
      |> assign_new(:value, fn -> field.value || 0 end)

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
        type="range"
        id={@id}
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        role="slider"
        aria-valuenow={@value}
        aria-valuemin={@min}
        aria-valuemax={@max}
        class={cn([slider_class(), @errors != [] && "accent-destructive", @class])}
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

  # Shared class string for both slider/1 and form_slider/1.
  # accent-primary colours the thumb and progress fill using the active
  # PhiaUI theme token (Tailwind v4 CSS variable). bg-secondary gives the
  # unfilled track a subtle contrast against the background.
  defp slider_class do
    "w-full h-2 cursor-pointer accent-primary bg-secondary rounded-full " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  # Interpolates %{key} placeholders from the opts keyword list.
  # Ecto errors like {"must be greater than %{number}", [number: 0]} are resolved
  # to human-readable strings. After ejection, replace with Gettext for i18n.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
