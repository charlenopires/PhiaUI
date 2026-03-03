defmodule PhiaUi.Components.Field do
  @moduledoc """
  Standalone field layout components for form fields without requiring `Phoenix.HTML.FormField`.

  Unlike `PhiaUi.Components.Form` which requires an Ecto changeset and `Phoenix.HTML.FormField`,
  these components accept a plain `:error` string, making them ideal wrappers for
  custom inputs like Checkbox, Radio, Switch, and other non-standard form controls.

  ## Components

  | Function            | Purpose                                           |
  |---------------------|---------------------------------------------------|
  | `field/1`           | Wrapper container with `space-y-2` layout         |
  | `field_label/1`     | Styled `<label>` with optional required asterisk  |
  | `field_description/1` | Helper/hint text in muted foreground            |
  | `field_message/1`   | Conditional error message in destructive color    |

  ## Example

      <.field>
        <.field_label for="agree" required={true}>Accept Terms</.field_label>
        <input id="agree" type="checkbox" />
        <.field_description>You must accept the terms to continue.</.field_description>
        <.field_message error={@error} />
      </.field>

  ## Dark Mode

  All sub-components use semantic Tailwind tokens (`text-muted-foreground`,
  `text-destructive`) that automatically adapt to dark mode via `@custom-variant dark`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # field/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to root element")
  slot(:inner_block, required: true, doc: "Field content (label + input + description + message)")

  @doc """
  Renders a field wrapper container.

  Provides `space-y-2` vertical rhythm between the label, input, description,
  and message sub-components. Accepts any HTML attributes via `@rest`.

  ## Example

      <.field>
        <.field_label for="email">Email</.field_label>
        <input id="email" type="email" />
        <.field_description>We'll never share your email.</.field_description>
        <.field_message error={@email_error} />
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
  # field_label/1
  # ---------------------------------------------------------------------------

  attr(:for, :string, default: nil, doc: "The id of the associated form element")
  attr(:required, :boolean, default: false, doc: "Whether to show required asterisk")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to label element")
  slot(:inner_block, required: true, doc: "Label text content")

  @doc """
  Renders a styled form field label.

  When `:required` is `true`, appends a red asterisk (`*`) with `aria-hidden="true"`
  so screen readers do not read it redundantly.

  ## Example

      <.field_label for="email" required={true}>Email</.field_label>
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
      <span :if={@required} class="ml-1 text-destructive" aria-hidden="true">*</span>
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # field_description/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to root element")
  slot(:inner_block, required: true, doc: "Description text content")

  @doc """
  Renders helper text below a form field.

  Displayed in `text-muted-foreground` to visually distinguish it from the
  label and error message. Use it for hints, format guidance, or constraints.

  ## Example

      <.field_description>At least 8 characters.</.field_description>
  """
  def field_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # field_message/1
  # ---------------------------------------------------------------------------

  attr(:error, :any, default: nil, doc: "Error message string, or nil to render nothing")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to root element")

  @doc """
  Renders a field error message when `:error` is not `nil`.

  Displays nothing when `error` is `nil`, so it is safe to always render
  this component and pass `error={@changeset_error_or_nil}`.

  ## Example

      <.field_message error={@form_error} />
  """
  def field_message(assigns) do
    ~H"""
    <p :if={@error} class={cn(["text-sm font-medium text-destructive", @class])} {@rest}>
      {@error}
    </p>
    """
  end
end
