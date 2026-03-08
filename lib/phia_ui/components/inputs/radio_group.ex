defmodule PhiaUi.Components.RadioGroup do
  @moduledoc """
  Mutually-exclusive radio button group component for Phoenix LiveView.

  Renders a group of radio buttons with custom circular indicators styled with
  Tailwind semantic tokens. All inputs are native `<input type="radio">` elements,
  so keyboard navigation (arrow keys), screen readers, and browser autofill work
  out-of-the-box without any JavaScript.

  ## Sub-components

  | Function           | Purpose                                                             |
  |--------------------|---------------------------------------------------------------------|
  | `radio_group/1`    | Container with `role="radiogroup"`, exposes context via `:let`      |
  | `radio_group_item/1` | Individual styled radio option with a custom circular indicator   |
  | `form_radio_group/1` | Full group integrated with `Phoenix.HTML.FormField` and errors   |

  ## Standalone usage with `:let` context

  The `:let` pattern passes the group's shared `name` and current `value` down
  to each item automatically, avoiding repetition:

      <.radio_group :let={group} value={@plan} name="plan" phx-change="set_plan">
        <.radio_group_item value="free"       label="Free"       {group} />
        <.radio_group_item value="pro"        label="Pro"        {group} />
        <.radio_group_item value="enterprise" label="Enterprise" {group} />
      </.radio_group>

  The `{group}` spread assigns `name={group.name}` and `group_value={group.group_value}`
  to each item so they know which one is currently selected.

  ## Horizontal layout

      <.radio_group :let={group} value={@size} name="size" orientation="horizontal">
        <.radio_group_item value="xs" label="XS" {group} />
        <.radio_group_item value="sm" label="SM" {group} />
        <.radio_group_item value="md" label="MD" {group} />
        <.radio_group_item value="lg" label="LG" {group} />
      </.radio_group>

  ## Form-integrated usage

  `form_radio_group/1` is the simplest API for Ecto changeset forms. Pass an
  `options` list and the component handles name, value, and error display:

      <.form_radio_group
        field={@form[:plan]}
        label="Subscription plan"
        options={[{"Free", "free"}, {"Pro", "pro"}, {"Team", "team"}]}
      />

      <.form_radio_group
        field={@form[:experience_level]}
        label="Experience level"
        orientation="horizontal"
        options={[{"Beginner", "beginner"}, {"Intermediate", "intermediate"}, {"Advanced", "advanced"}]}
      />

  ## Settings form example

      <.form for={@form} phx-submit="save_preferences">
        <.form_radio_group
          field={@form[:theme]}
          label="Color theme"
          orientation="horizontal"
          options={[{"Light", "light"}, {"Dark", "dark"}, {"System", "system"}]}
        />
        <.form_radio_group
          field={@form[:notifications]}
          label="Notification frequency"
          options={[
            {"Real-time", "realtime"},
            {"Hourly digest", "hourly"},
            {"Daily digest", "daily"},
            {"Never", "never"}
          ]}
        />
        <.button type="submit">Save preferences</.button>
      </.form>

  ## Accessibility

  - `role="radiogroup"` on the container groups items for screen readers
  - Native `<input type="radio">` with `class="sr-only"` handles keyboard
    navigation (arrow keys cycle through options) and screen reader announcements
  - Labels are associated via `for`/`id` so clicking the text selects the option
  - `peer-focus-visible:ring-2` on the visual indicator provides keyboard focus feedback
  - Disabled items have `aria-disabled` semantics via the native `disabled` attribute
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # radio_group/1 — container
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    default: nil,
    doc: """
    The currently selected value. The `radio_group_item/1` whose `:value`
    matches this string will render as checked. Pass `nil` for an unselected
    group. This should mirror your LiveView assign (e.g. `@selected_plan`).
    """
  )

  attr(:name, :string,
    default: nil,
    doc: """
    The HTML `name` attribute shared by all radio inputs in this group. All
    radios with the same name are mutually exclusive. Required for form
    submission. When using `form_radio_group/1`, this is derived from the
    field struct automatically.
    """
  )

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal),
    doc: """
    Layout direction for the items. `"vertical"` (default) stacks items in a
    column with `flex-col`. `"horizontal"` places them inline with `flex-row
    flex-wrap`, which wraps on narrow viewports.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the group container `<div>`."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-value),
    doc: """
    HTML attributes forwarded to the group `<div>`. Typically used for
    `phx-change` to notify the LiveView when the selection changes.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    One or more `radio_group_item/1` components. Use `:let={group}` on the
    parent to pass context, then spread `{group}` onto each item.
    """
  )

  @doc """
  Renders a radio button group container with `role="radiogroup"`.

  Exposes group context via `:let` so items receive their shared `name` and
  `group_value` (the currently selected value) automatically. Items use this
  context to compute their `checked` state without needing it passed explicitly:

      <.radio_group :let={group} value={@selected} name="fruit" phx-change="select_fruit">
        <.radio_group_item value="apple"  label="Apple"  {group} />
        <.radio_group_item value="banana" label="Banana" {group} />
        <.radio_group_item value="cherry" label="Cherry" {group} />
      </.radio_group>

  The `{group}` spread is equivalent to:
  `name={group.name} group_value={group.group_value}`

  ## Examples

      <%!-- Vertical (default) --%>
      <.radio_group :let={g} value={@color} name="color" phx-change="pick_color">
        <.radio_group_item value="red"  label="Red"   {g} />
        <.radio_group_item value="blue" label="Blue"  {g} />
      </.radio_group>

      <%!-- Horizontal --%>
      <.radio_group :let={g} value={@size} name="size" orientation="horizontal">
        <.radio_group_item value="sm" label="Small"  {g} />
        <.radio_group_item value="md" label="Medium" {g} />
        <.radio_group_item value="lg" label="Large"  {g} />
      </.radio_group>
  """
  def radio_group(assigns) do
    ~H"""
    <div
      role="radiogroup"
      class={cn(["flex gap-2", orientation_class(@orientation), @class])}
      {@rest}
    >
      {render_slot(@inner_block, %{group_value: @value, name: @name})}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # radio_group_item/1 — individual item
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: """
    The value this radio button represents. Submitted to the server when this
    option is selected. Should match the expected changeset field values.
    """
  )

  attr(:label, :string,
    required: true,
    doc: "Visible text label rendered next to the custom circular indicator."
  )

  attr(:name, :string,
    default: nil,
    doc: """
    HTML `name` attribute for this radio input. In normal usage this is
    inherited from the group context via `:let` + `{group}` spread. Only
    set this manually when composing items without the group container.
    """
  )

  attr(:group_value, :string,
    default: nil,
    doc: """
    The group's currently selected value. This item renders as checked when
    `group_value == value`. Inherited from the group context via `{group}`
    spread in typical usage. Only set manually when composing without the group.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, disables this radio option. The item becomes non-interactive
    and renders at 50% opacity with `cursor-not-allowed`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<label>` wrapper element."
  )

  @doc """
  Renders a single radio button item within a `radio_group/1`.

  The visible indicator is a custom-styled circle built with CSS. The actual
  `<input type="radio">` is hidden with `class="sr-only"` but remains fully
  functional for keyboard navigation and form submission. The `<label>` wraps
  both the hidden input and the visual indicator so clicking anywhere on the
  row selects the option.

  The `checked` state is computed at render time by comparing `group_value`
  against this item's `value`. A filled inner circle (`<span>`) is rendered
  conditionally only when checked.

  ## Examples

      <%!-- Typical usage inside radio_group with :let context --%>
      <.radio_group :let={g} value={@plan} name="plan">
        <.radio_group_item value="free" label="Free plan" {g} />
        <.radio_group_item value="pro"  label="Pro plan"  {g} />
      </.radio_group>

      <%!-- Manual usage without group context --%>
      <.radio_group_item
        value="monthly"
        label="Monthly billing"
        name="billing_cycle"
        group_value={@billing_cycle}
      />

      <%!-- Disabled item --%>
      <.radio_group_item value="enterprise" label="Enterprise (contact us)" {g} disabled={true} />
  """
  def radio_group_item(assigns) do
    assigns =
      assign(assigns,
        # Derive checked boolean at assign time so the template stays declarative.
        checked: assigns.group_value == assigns.value,
        # Build a stable, unique id from name + value to associate label and input.
        input_id: "radio_#{assigns.name}_#{assigns.value}"
      )

    ~H"""
    <label
      for={@input_id}
      class={cn(["phia-touch-target", "flex items-center gap-2 cursor-pointer", @disabled && "cursor-not-allowed opacity-50", @class])}
    >
      <%!-- sr-only input: invisible but receives keyboard focus and handles browser radio logic --%>
      <input
        type="radio"
        id={@input_id}
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class="sr-only peer"
      />
      <%!-- Custom visual indicator: outer ring + conditionally rendered inner fill dot --%>
      <span class={cn([
        "inline-flex h-4 w-4 items-center justify-center rounded-full border border-primary",
        "transition-colors peer-focus-visible:ring-2 peer-focus-visible:ring-ring peer-focus-visible:ring-offset-2"
      ])}>
        <span :if={@checked} class="h-2 w-2 rounded-full bg-primary block"></span>
      </span>
      <span class="text-sm leading-none">{@label}</span>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # form_radio_group/1 — FormField-integrated
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct obtained via `@form[:field_name]`. Provides
    the group `name`, current `value` (for pre-selection), and `errors` for
    changeset validation display.
    """
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of `{label, value}` tuples defining the available radio options.
    Each tuple becomes a `radio_group_item/1`. Values are coerced to strings
    via `to_string/1` for comparison with the field value.

    Example: `[{"Free", "free"}, {"Pro", "pro"}, {"Enterprise", "enterprise"}]`
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Optional group label rendered as a `<p>` above the options. Use to
    describe what the user is choosing. For accessibility, consider wrapping
    in a `<fieldset>` with `<legend>` in complex forms.
    """
  )

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal),
    doc: """
    Layout direction forwarded to the `radio_group/1` container.
    `"vertical"` (default) stacks options. `"horizontal"` places them inline.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper `<div>`."
  )

  @doc """
  Renders a complete radio group integrated with `Phoenix.HTML.FormField`.

  This is the simplest API for Ecto changeset forms. Provide `:field` and
  `:options` and the component handles everything: deriving the `name` from
  the field, pre-selecting the current value, and displaying changeset errors.

  Options are provided as `{label, value}` tuples. Values are coerced to
  strings via `to_string/1` before comparison, so integer and atom values
  from changesets work transparently.

  ## Examples

      <%!-- Subscription plan selector --%>
      <.form_radio_group
        field={@form[:plan]}
        label="Subscription plan"
        options={[{"Free", "free"}, {"Pro", "pro"}, {"Team", "team"}]}
      />

      <%!-- Horizontal notification preference --%>
      <.form_radio_group
        field={@form[:notification_frequency]}
        label="Notifications"
        orientation="horizontal"
        options={[
          {"Real-time", "realtime"},
          {"Daily digest", "daily"},
          {"Never", "never"}
        ]}
      />

      <%!-- Dynamic options from the database --%>
      <.form_radio_group
        field={@form[:category_id]}
        label="Category"
        options={Enum.map(@categories, &{&1.name, to_string(&1.id)})}
      />
  """
  def form_radio_group(assigns) do
    # Coerce the field value to a string for consistent comparison.
    # Ecto may return an atom, integer, or nil depending on the schema type.
    assigns = assign(assigns, :group_value, to_string(assigns.field.value || ""))

    ~H"""
    <div class={@class}>
      <p :if={@label} class="text-sm font-medium mb-2">{@label}</p>
      <.radio_group value={@group_value} name={@field.name} orientation={@orientation}>
        <.radio_group_item
          :for={{opt_label, opt_value} <- @options}
          value={to_string(opt_value)}
          label={opt_label}
          name={@field.name}
          group_value={@group_value}
        />
      </.radio_group>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Maps orientation to the flex direction class. Using a two-clause function
  # instead of a map or cond keeps the pattern consistent with other helpers
  # in this codebase and allows compile-time exhaustiveness checking.
  defp orientation_class("vertical"), do: "flex-col"
  defp orientation_class("horizontal"), do: "flex-row flex-wrap"
end
