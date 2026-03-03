defmodule PhiaUi.Components.Textarea do
  @moduledoc """
  Textarea Form Component for Phoenix LiveView.

  Provides `phia_textarea/1` for multiline text input integrated with
  `Phoenix.HTML.Form` and Ecto changesets.

  ## Example

      <.phia_textarea field={@form[:bio]} label="Bio" rows={6} />

      <.phia_textarea
        field={@form[:description]}
        label="Description"
        description="Markdown is supported."
        placeholder="Write something..."
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_field: 1]

  # ---------------------------------------------------------------------------
  # phia_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"
  )

  attr(:label, :string, default: nil, doc: "Label text rendered above the textarea")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the textarea")
  attr(:rows, :integer, default: 4, doc: "Number of visible text rows")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text for the textarea")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the textarea element")

  @doc """
  Renders a multi-line `<textarea>` integrated with `Phoenix.HTML.FormField`.

  Wraps the native `<textarea>` in `form_field/1` to provide a consistent
  label, description, and automatic changeset error display via `form_message/1`.
  The element is resizable vertically (`resize-y`) and defaults to 4 visible
  rows; control height with the `:rows` attribute. `phx-debounce="blur"` is
  applied automatically so validation fires on focus-out rather than on every
  keystroke.

      <.phia_textarea field={@form[:bio]} label="Bio" rows={6} />
      <.phia_textarea field={@form[:notes]} label="Notes" placeholder="Optional…" />
  """
  def phia_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <textarea
        id={@field.id}
        name={@field.name}
        rows={@rows}
        placeholder={@placeholder}
        class={
          cn([
            "border rounded-md bg-background px-3 py-2 text-sm w-full resize-y min-h-[80px]",
            @class
          ])
        }
        phx-debounce="blur"
      >{@field.value}</textarea>
    </.form_field>
    """
  end
end
