defmodule PhiaUi.Components.Select do
  @moduledoc """
  Native HTML select form component for Phoenix LiveView.

  `phia_select/1` wraps the browser's native `<select>` element with PhiaUI
  styling, a Lucide chevron-down icon overlay, and full `Phoenix.HTML.FormField`
  integration including changeset error display.

  ## When to use

  Use `phia_select/1` for dropdown selection when:
  - The option count is moderate (2–20 options work best with a native dropdown)
  - You want zero JavaScript and full browser accessibility for free
  - A simple, familiar dropdown interaction is appropriate

  For searchable or async-loaded options, consider `phia_combobox/1` instead.

  ## Basic usage

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.phia_select
          field={@form[:country]}
          options={[{"United States", "us"}, {"Canada", "ca"}, {"United Kingdom", "gb"}]}
          label="Country"
          prompt="Select your country"
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Options format

  The `:options` attribute accepts any format supported by
  `Phoenix.HTML.Form.options_for_select/2`:

      <%!-- Tuple list {label, value} — most common --%>
      options={[{"Free", "free"}, {"Pro", "pro"}, {"Enterprise", "enterprise"}]}

      <%!-- Plain strings — value equals label --%>
      options={["Small", "Medium", "Large"]}

      <%!-- Keyword list --%>
      options={[Free: "free", Pro: "pro"]}

      <%!-- Mixed integers --%>
      options={[{"1 month", 1}, {"6 months", 6}, {"1 year", 12}]}

  ## Pre-selecting a value

  The currently selected value is read from `field.value` automatically.
  When a changeset is loaded with existing data, the correct option will be
  pre-selected:

      # In your LiveView mount/2:
      changeset = Settings.change_preferences(user.preferences)
      assign(socket, form: to_form(changeset))

  ## Prompt (placeholder option)

  Use `:prompt` to render an unselectable leading option:

      <.phia_select
        field={@form[:role]}
        options={[{"Admin", "admin"}, {"Member", "member"}, {"Viewer", "viewer"}]}
        label="Role"
        prompt="Choose a role..."
      />

  ## Dynamic options from the database

      <.phia_select
        field={@form[:category_id]}
        options={Enum.map(@categories, &{&1.name, &1.id})}
        label="Category"
        prompt="Select a category"
      />

  ## No JavaScript

  The component is CSS-only. A `chevron-down` icon is positioned absolutely
  inside a `pointer-events-none` overlay so it does not interfere with the
  native `<select>` click target. The browser handles all keyboard navigation
  and accessibility natively.

  ## Accessibility

  The `<select>` is associated with its `<label>` via `for`/`id` from the field
  struct. Changeset errors appear below the element in destructive colour.
  Focus states use PhiaUI's standard ring tokens.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_field: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # phia_select/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct obtained via `@form[:field_name]`. Provides
    the element `id`, `name`, and current `value` for pre-selection, as well as
    `errors` for validation display.
    """
  )

  attr(:options, :list,
    required: true,
    doc: """
    The list of options to render. Accepts any format supported by
    `Phoenix.HTML.Form.options_for_select/2`:
    - `[{"Label", value}, ...]` — explicit label/value tuples (most readable)
    - `["value1", "value2"]` — plain strings where label equals value
    - `[label: "value", ...]` — keyword list format
    - Mixed integers and strings are supported as values.

    The currently selected option is determined by comparing each value against
    `field.value`.
    """
  )

  attr(:prompt, :string,
    default: nil,
    doc: """
    When provided, renders a leading `<option value="">` as a placeholder.
    The user sees this text before making a selection. Useful to communicate
    that a choice is required, e.g. `prompt="Select a country..."`.
    Submitting with the prompt selected sends an empty string value.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered in a `<label>` above the select. Associated via `for`/`id`
    so clicking the label opens the dropdown. When `nil`, no label is rendered.
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Helper text rendered below the label and above the select element.
    Use for constraints or context, e.g. "This affects all team members."
    Rendered in `text-muted-foreground`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional Tailwind CSS classes merged into the `<select>` element via
    `cn/1`. Use to adjust width, font, or other styles. Example:
    `class="w-48"` for a fixed-width dropdown.
    """
  )

  @doc """
  Renders a native `<select>` element integrated with `Phoenix.HTML.FormField`.

  No JavaScript is required — the browser's native dropdown handles all
  interaction. A `chevron-down` icon is positioned absolutely on the right with
  `pointer-events-none` so it overlays the select without interfering with
  clicks. The `:options` list is rendered via `Phoenix.HTML.Form.options_for_select/2`,
  which marks the correct `<option>` as selected based on `field.value`.

  An optional `:prompt` renders a leading `<option value="">` placeholder.
  Changeset errors from `field.errors` are displayed below the element by
  the `form_field/1` wrapper.

  ## Examples

      <%!-- User role assignment --%>
      <.phia_select
        field={@form[:role]}
        options={[{"Admin", "admin"}, {"Member", "member"}, {"Viewer", "viewer"}]}
        label="Role"
        prompt="Select a role..."
      />

      <%!-- Subscription plan selector --%>
      <.phia_select
        field={@form[:plan]}
        options={[{"Free", "free"}, {"Pro", "pro"}, {"Enterprise", "enterprise"}]}
        label="Plan"
      />

      <%!-- Dynamic options from assigns --%>
      <.phia_select
        field={@form[:category_id]}
        options={Enum.map(@categories, &{&1.name, &1.id})}
        label="Category"
        prompt="Choose a category"
      />

      <%!-- Fixed-width with description --%>
      <.phia_select
        field={@form[:timezone]}
        options={@timezones}
        label="Timezone"
        description="Used for scheduling reminders."
        class="w-64"
      />
  """
  def phia_select(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <div class="relative">
        <select
          id={@field.id}
          name={@field.name}
          class={
            cn([
              "phia-touch-target",
              "h-10 w-full rounded-md border bg-background px-3 py-2 text-sm",
              "appearance-none pr-8 cursor-pointer",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
              "disabled:cursor-not-allowed disabled:opacity-50",
              @class
            ])
          }
        >
          <%!-- Prompt renders as an unselectable leading option with an empty value --%>
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @field.value)}
        </select>
        <%!-- Icon overlay: pointer-events-none prevents it from blocking the native select click --%>
        <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none">
          <.icon name="chevron-down" size={:sm} />
        </div>
      </div>
    </.form_field>
    """
  end
end
