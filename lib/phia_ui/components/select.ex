defmodule PhiaUi.Components.Select do
  @moduledoc """
  Native HTML Select Form Component for Phoenix LiveView.

  Provides `phia_select/1` — a semantic wrapper over `<select>` with full
  `Phoenix.HTML.Form` integration, changeset error display, and a Lucide
  chevron-down icon overlaid on the right side.

  ## Example

      <.phia_select
        field={@form[:category]}
        options={[{"Technology", "tech"}, {"Sports", "sports"}]}
        label="Category"
        prompt="Choose a category"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_field: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # phia_select/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"

  attr :options, :list,
    required: true,
    doc: ~s(Options list — accepts [{"Label", value}], ["value"], or [value])

  attr :prompt, :string,
    default: nil,
    doc: "Placeholder option rendered as <option value=\"\"> at the top"

  attr :label, :string, default: nil, doc: "Label text rendered above the select"
  attr :description, :string, default: nil, doc: "Helper text rendered below the select"
  attr :class, :string, default: nil, doc: "Additional CSS classes for the select element"

  @doc """
  Renders a native `<select>` element integrated with `Phoenix.HTML.FormField`.

  No JavaScript is required — the browser's native dropdown handles interaction.
  A `chevron-down` icon is positioned absolutely on the right with
  `pointer-events-none` so it overlays the select without interfering with
  clicks. The `:options` list is rendered via `Phoenix.HTML.Form.options_for_select/2`,
  which accepts tuples `{"Label", value}`, plain strings, or integers. An
  optional `:prompt` renders a leading `<option value="">` placeholder.

      <.phia_select
        field={@form[:role]}
        options={[{"Admin", "admin"}, {"Member", "member"}]}
        label="Role"
        prompt="Select a role…"
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
              "h-10 w-full rounded-md border bg-background px-3 py-2 text-sm",
              "appearance-none pr-8 cursor-pointer",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
              "disabled:cursor-not-allowed disabled:opacity-50",
              @class
            ])
          }
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @field.value)}
        </select>
        <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none">
          <.icon name="chevron-down" size={:sm} />
        </div>
      </div>
    </.form_field>
    """
  end
end
