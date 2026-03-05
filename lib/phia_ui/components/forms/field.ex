defmodule PhiaUi.Components.Field do
  @moduledoc """
  Standalone field layout primitives for composing form fields without `Phoenix.HTML.FormField`.

  While `PhiaUi.Components.Form` (`form_field/1`, `form_label/1`, etc.) requires an
  Ecto changeset and a `Phoenix.HTML.FormField` struct, the primitives in this module
  accept plain strings and booleans. This makes them ideal wrappers for custom
  inputs — checkboxes, radio groups, switches, sliders, and other non-standard
  form controls — without needing a changeset.

  ## Components

  | Function              | Purpose                                                          |
  |-----------------------|------------------------------------------------------------------|
  | `field/1`             | Wrapper `<div>` with `space-y-2` vertical rhythm                 |
  | `field_label/1`       | Styled `<label>` with optional required asterisk (`*`)           |
  | `field_description/1` | Helper/hint text in `text-muted-foreground`                      |
  | `field_message/1`     | Conditional error message in `text-destructive`, renders nothing when `nil` |

  ## When to use

  Use `field/1` and its sub-components when:
  - You are building a custom input that does not bind directly to a Phoenix form
  - You want consistent field layout (label → input → description → error) without changesets
  - You are composing standalone UI (e.g. wizard steps, modal forms without Ecto)
  - You want to display a manually-constructed error string rather than a changeset error

  For Ecto changeset forms, prefer `PhiaUi.Components.Form.form_field/1` instead,
  which reads errors directly from `field.errors`.

  ## Basic composition

      <.field>
        <.field_label for="agree" required={true}>Accept Terms</.field_label>
        <input id="agree" type="checkbox" />
        <.field_description>You must accept the terms to continue.</.field_description>
        <.field_message error={@terms_error} />
      </.field>

  ## Wrapping custom components

  The `field/1` wrapper works with any PhiaUI component:

      <%!-- Wrapping a standalone radio group --%>
      <.field>
        <.field_label>Notification frequency</.field_label>
        <.radio_group :let={g} value={@frequency} name="frequency" phx-change="set_frequency">
          <.radio_group_item value="realtime" label="Real-time" {g} />
          <.radio_group_item value="daily"    label="Daily digest" {g} />
          <.radio_group_item value="never"    label="Never" {g} />
        </.radio_group>
        <.field_description>How often would you like to receive email notifications?</.field_description>
        <.field_message error={@frequency_error} />
      </.field>

      <%!-- Wrapping a slider --%>
      <.field>
        <.field_label for="volume" required={true}>Volume</.field_label>
        <.slider id="volume" name="volume" value={@volume} phx-change="set_volume" />
        <.field_message error={@volume_error} />
      </.field>

  ## Multi-field settings panel

      <.field>
        <.field_label>Profile visibility</.field_label>
        <.field_description>Controls who can see your public profile page.</.field_description>
        <.toggle_group type="single" value={@visibility} phx-change="set_visibility">
          <.toggle_group_item value="public">Public</.toggle_group_item>
          <.toggle_group_item value="friends">Friends only</.toggle_group_item>
          <.toggle_group_item value="private">Private</.toggle_group_item>
        </.toggle_group>
        <.field_message error={@visibility_error} />
      </.field>

  ## Error handling pattern

  `field_message/1` renders nothing when `:error` is `nil`, so it is safe to always
  render it and conditionally populate the error from your LiveView assigns:

      # In your LiveView:
      validate_form(attrs) ->
        errors = %{email: "must be a valid email address"}
        assign(socket, email_error: errors[:email])  # nil when valid

      # In your template — always renders, only shows when non-nil:
      <.field_message error={@email_error} />

  ## Dark mode

  All sub-components use semantic Tailwind tokens (`text-muted-foreground`,
  `text-destructive`) that automatically adapt to dark mode via PhiaUI's
  `@custom-variant dark` configuration.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # field/1 — wrapper container
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes merged into the wrapper `<div>` via `cn/1`.
    Use to adjust spacing or layout, e.g. `class="mt-4"` or `class="col-span-2"`.
    """
  )

  attr(:rest, :global,
    doc: "Any HTML attributes forwarded to the wrapper `<div>` (e.g. `id`, `data-*`)."
  )

  slot(:inner_block,
    required: true,
    doc: """
    The field's sub-components in order: label → input → description → message.
    All four are optional — only include what the field needs.
    """
  )

  @doc """
  Renders a field wrapper `<div>` with `space-y-2` vertical rhythm.

  This is the outermost container for a field layout. It provides consistent
  vertical spacing (`space-y-2`) between the label, input, description, and
  error message sub-components.

  ## Examples

      <%!-- Minimal wrapper --%>
      <.field>
        <.field_label for="email">Email</.field_label>
        <input id="email" type="email" class="..." />
      </.field>

      <%!-- Full field with all sub-components --%>
      <.field>
        <.field_label for="email" required={true}>Email</.field_label>
        <input id="email" type="email" class="..." />
        <.field_description>We'll never share your email.</.field_description>
        <.field_message error={@email_error} />
      </.field>

      <%!-- Custom spacing override --%>
      <.field class="mt-6">
        <.field_label for="bio">Bio</.field_label>
        <textarea id="bio" class="..." />
      </.field>
  """
  def field(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # field_label/1 — label element
  # ---------------------------------------------------------------------------

  attr(:for, :string,
    default: nil,
    doc: """
    The `id` of the associated form element. When set, the browser focuses the
    input when the label is clicked. Omit only when wrapping the input in the
    label directly (implicit association).
    """
  )

  attr(:required, :boolean,
    default: false,
    doc: """
    When `true`, appends a red asterisk (`*`) after the label text with
    `aria-hidden="true"`. The asterisk is hidden from screen readers because
    the required constraint should be communicated via `required` on the input
    itself, not by reading "asterisk" aloud.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<label>` element via `cn/1`."
  )

  attr(:rest, :global, doc: "Any HTML attributes forwarded to the `<label>` element.")

  slot(:inner_block,
    required: true,
    doc: "The label text. Can include inline elements like `<abbr>` for tooltips."
  )

  @doc """
  Renders a styled form field label.

  Applies `text-sm font-medium leading-none` with a disabled-state variant
  (`peer-disabled:cursor-not-allowed peer-disabled:opacity-70`) for when the
  associated input is disabled.

  When `:required` is `true`, appends a red asterisk with `aria-hidden="true"`
  so screen readers do not read it redundantly. The required constraint should
  also be set on the input element itself (`required` attr) for browser validation.

  ## Examples

      <%!-- Basic label --%>
      <.field_label for="email">Email address</.field_label>

      <%!-- Required field indicator --%>
      <.field_label for="password" required={true}>Password</.field_label>

      <%!-- Without `for` (implicit association via wrapping) --%>
      <label>
        <.field_label>Username</.field_label>
        <input type="text" />
      </label>

      <%!-- With extra styling --%>
      <.field_label for="name" class="text-base">Full name</.field_label>
  """
  def field_label(assigns) do
    ~H"""
    <label
      for={@for}
      class={cn([
        "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <%!-- aria-hidden prevents screen readers from announcing the asterisk symbol.
           The required state is communicated via the input's own `required` attribute. --%>
      <span :if={@required} class="ml-1 text-destructive" aria-hidden="true">*</span>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # field_description/1 — helper text
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the description `<p>` element via `cn/1`."
  )

  attr(:rest, :global, doc: "Any HTML attributes forwarded to the `<p>` element.")

  slot(:inner_block,
    required: true,
    doc: """
    The description text. Can include links or inline formatting. Keep it concise —
    ideally one sentence that helps the user understand what to enter.
    """
  )

  @doc """
  Renders helper text below a form field label.

  Displayed in `text-muted-foreground` to visually distinguish it from the label
  (which uses full foreground colour) and from error messages (which use destructive
  colour). Use it for format hints, character limits, privacy notes, or constraints.

  ## Examples

      <%!-- Format hint --%>
      <.field_description>Date format: YYYY-MM-DD</.field_description>

      <%!-- Privacy note --%>
      <.field_description>We'll never share your email with anyone else.</.field_description>

      <%!-- Constraint --%>
      <.field_description>Must be at least 8 characters, including a number.</.field_description>

      <%!-- With a link --%>
      <.field_description>
        By continuing you agree to our <a href="/terms" class="underline">Terms of Service</a>.
      </.field_description>
  """
  def field_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # field_message/1 — error message
  # ---------------------------------------------------------------------------

  attr(:error, :any,
    default: nil,
    doc: """
    Error message string to display, or `nil` to render nothing. When non-nil,
    renders a `<p>` in `text-destructive`. Safe to always render with a potentially
    nil value — no wrapper `if` expression needed in the template.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the error `<p>` element via `cn/1`."
  )

  attr(:rest, :global,
    doc: "Any HTML attributes forwarded to the `<p>` element (e.g. `id` for `aria-describedby`)."
  )

  @doc """
  Renders a field error message when `:error` is not `nil`.

  Displays nothing (no DOM element) when `error` is `nil`, so it is safe to
  always include this component and conditionally populate `:error` from your
  LiveView assigns. This avoids `if` expressions in the template.

  The error `<p>` renders in `text-sm font-medium text-destructive`. For
  accessibility, consider adding an `id` attribute and referencing it from
  the input via `aria-describedby`:

      <.field_message id="email-error" error={@email_error} />
      <input aria-describedby="email-error" ... />

  ## Examples

      <%!-- Always rendered, shows only when error is non-nil --%>
      <.field_message error={@form_error} />

      <%!-- With id for aria-describedby association --%>
      <.field_message id="password-error" error={@password_error} />

      <%!-- Explicit nil — renders nothing --%>
      <.field_message error={nil} />

      <%!-- Custom class --%>
      <.field_message error={@error} class="mt-2 text-xs" />
  """
  def field_message(assigns) do
    ~H"""
    <p :if={@error} class={cn(["text-sm font-medium text-destructive", @class])} {@rest}>
      {@error}
    </p>
    """
  end
end
