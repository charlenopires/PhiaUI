defmodule PhiaUi.Components.FormLayout do
  @moduledoc """
  Form layout structure components for grouping, organizing, and collecting
  feedback within complex forms.

  ## Components

  | Function | Purpose |
  |---|---|
  | `form_section/1` | Titled (optionally collapsible) field group |
  | `form_fieldset/1` | Accessible `<fieldset>` + `<legend>` wrapper |
  | `form_grid/1` | Responsive N-column form grid |
  | `form_row/1` | Horizontal equal-width field row |
  | `form_actions/1` | Submit/cancel/reset footer bar |
  | `form_summary/1` | Aggregate validation error list at form top |
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # form_section/1
  # ---------------------------------------------------------------------------

  attr :title, :string, required: true, doc: "Section heading text"
  attr :description, :string, default: nil, doc: "Optional helper text below the title"
  attr :collapsible, :boolean, default: false, doc: "Wraps content in native <details>/<summary>"
  attr :open, :boolean, default: true, doc: "Initial expanded state when collapsible is true"
  attr :class, :string, default: nil, doc: "Additional CSS classes on the root element"

  slot :inner_block, required: true
  slot :action, doc: "Optional header-right actions (e.g. badge, button)"

  @doc """
  Renders a titled form section that can optionally collapse via `<details>/<summary>`.

  When `:collapsible` is `true`, uses native HTML `<details>/<summary>` — zero JS required,
  consistent with the Tree component pattern.

  ## Examples

      <%!-- Static section --%>
      <.form_section title="Personal Information" description="Fill in your basic details.">
        <.phia_input field={@form[:name]} label="Name" />
      </.form_section>

      <%!-- Collapsible section --%>
      <.form_section title="Advanced Settings" collapsible={true} open={false}>
        <.phia_input field={@form[:api_key]} label="API Key" />
      </.form_section>
  """
  def form_section(%{collapsible: true} = assigns) do
    ~H"""
    <details
      open={@open}
      class={cn(["group rounded-lg border border-border bg-card", @class])}
    >
      <summary class="flex cursor-pointer list-none items-center justify-between px-4 py-3 select-none">
        <div class="flex-1 min-w-0">
          <h3 class="text-sm font-semibold text-foreground">{@title}</h3>
          <p :if={@description} class="mt-0.5 text-xs text-muted-foreground">{@description}</p>
        </div>
        <div class="ml-2 flex shrink-0 items-center gap-2">
          {render_slot(@action)}
          <svg
            class="h-4 w-4 text-muted-foreground transition-transform group-open:rotate-180"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <polyline points="6 9 12 15 18 9" />
          </svg>
        </div>
      </summary>
      <div class="border-t border-border px-4 py-4">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  def form_section(assigns) do
    ~H"""
    <div class={cn(["rounded-lg border border-border bg-card", @class])}>
      <div class="flex items-start justify-between border-b border-border px-4 py-3">
        <div class="flex-1 min-w-0">
          <h3 class="text-sm font-semibold text-foreground">{@title}</h3>
          <p :if={@description} class="mt-0.5 text-xs text-muted-foreground">{@description}</p>
        </div>
        <div :if={@action != []} class="ml-2 flex shrink-0 items-center gap-2">
          {render_slot(@action)}
        </div>
      </div>
      <div class="px-4 py-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_fieldset/1
  # ---------------------------------------------------------------------------

  attr :legend, :string, required: true, doc: "Text rendered inside the <legend> element"
  attr :required, :boolean, default: false, doc: "Appends a red asterisk to the legend"
  attr :disabled, :boolean, default: false, doc: "Disables all form elements inside the fieldset"
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders an accessible `<fieldset>` with a `<legend>` for grouping related inputs.

  ## Example

      <.form_fieldset legend="Billing Address" required={true}>
        <.phia_input field={@form[:street]} label="Street" />
        <.phia_input field={@form[:city]} label="City" />
      </.form_fieldset>
  """
  def form_fieldset(assigns) do
    ~H"""
    <fieldset
      disabled={@disabled}
      class={cn([
        "space-y-4 rounded-md border border-input px-4 pb-4 pt-2",
        @disabled && "opacity-60",
        @class
      ])}
    >
      <legend class="px-1 text-sm font-semibold text-foreground">
        {@legend}<span
          :if={@required}
          class="ml-0.5 text-destructive"
          aria-hidden="true"
        >*</span>
      </legend>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end

  # ---------------------------------------------------------------------------
  # form_grid/1
  # ---------------------------------------------------------------------------

  attr :cols, :integer, default: 2, doc: "Grid columns: 1–4. Collapses to 1 on mobile."
  attr :gap, :string, default: "md", doc: "Column/row gap: sm (gap-3) | md (gap-4) | lg (gap-6)"
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a responsive CSS grid for form fields.

  Always 1 column on mobile, expands to `:cols` columns at the `sm:` breakpoint.

  ## Example

      <.form_grid cols={2} gap="md">
        <.phia_input field={@form[:first_name]} label="First name" />
        <.phia_input field={@form[:last_name]} label="Last name" />
      </.form_grid>
  """
  def form_grid(assigns) do
    ~H"""
    <div class={cn(["grid grid-cols-1", grid_col_class(@cols), grid_gap_class(@gap), @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_row/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes on the row wrapper"

  slot :inner_block, required: true

  @doc """
  Renders a horizontal row of form fields that stack vertically on mobile.

  Each child occupies equal horizontal space (via `flex-1` applied by the child).

  ## Example

      <.form_row>
        <div class="flex-1"><.phia_input field={@form[:email]} label="Email" /></div>
        <div class="flex-1"><.phia_input field={@form[:phone]} label="Phone" /></div>
      </.form_row>
  """
  def form_row(assigns) do
    ~H"""
    <div class={cn(["flex flex-col gap-4 sm:flex-row", @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_actions/1
  # ---------------------------------------------------------------------------

  attr :align, :string, default: "end", doc: "Button alignment: start | center | end | between"
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a form footer bar for action buttons (submit, cancel, reset).

  ## Example

      <.form_actions align="between">
        <.button variant="ghost" type="button">Cancel</.button>
        <.button type="submit">Save changes</.button>
      </.form_actions>
  """
  def form_actions(assigns) do
    ~H"""
    <div class={cn(["flex flex-col-reverse gap-2 border-t border-border pt-4 sm:flex-row sm:gap-3", actions_align(@align), @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_summary/1
  # ---------------------------------------------------------------------------

  attr :errors, :list, default: [], doc: "List of error strings to display"

  attr :title, :string,
    default: "Please fix the following errors:",
    doc: "Heading text above the error list"

  attr :class, :string, default: nil

  @doc """
  Renders an aggregate validation error list at the top of a form.

  Renders **nothing** when `:errors` is empty. Uses `role="alert"` and
  `aria-live="polite"` so screen readers announce errors when they appear.

  ## Example

      <.form_summary errors={@form_errors} />
  """
  def form_summary(%{errors: []} = assigns) do
    ~H"""
    """
  end

  def form_summary(assigns) do
    ~H"""
    <div
      role="alert"
      aria-live="polite"
      class={cn([
        "rounded-md border border-destructive/40 bg-destructive/10 px-4 py-3",
        @class
      ])}
    >
      <p class="mb-2 text-sm font-semibold text-destructive">{@title}</p>
      <ul class="list-inside list-disc space-y-1">
        <li :for={error <- @errors} class="text-sm text-destructive">
          {error}
        </li>
      </ul>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp grid_col_class(1), do: nil
  defp grid_col_class(2), do: "sm:grid-cols-2"
  defp grid_col_class(3), do: "sm:grid-cols-3"
  defp grid_col_class(4), do: "sm:grid-cols-4"
  defp grid_col_class(_), do: "sm:grid-cols-2"

  defp grid_gap_class("sm"), do: "gap-3"
  defp grid_gap_class("md"), do: "gap-4"
  defp grid_gap_class("lg"), do: "gap-6"
  defp grid_gap_class(_), do: "gap-4"

  defp actions_align("start"), do: "justify-start"
  defp actions_align("center"), do: "justify-center"
  defp actions_align("end"), do: "justify-end"
  defp actions_align("between"), do: "justify-between"
  defp actions_align(_), do: "justify-end"
end
