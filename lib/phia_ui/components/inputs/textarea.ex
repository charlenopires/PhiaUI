defmodule PhiaUi.Components.Textarea do
  @moduledoc """
  Multi-line textarea form component for Phoenix LiveView.

  `phia_textarea/1` renders a styled `<textarea>` integrated with
  `Phoenix.HTML.FormField` and Ecto changesets. It delegates label, description,
  and error display to `form_field/1`, keeping the markup consistent with other
  PhiaUI form components.

  ## When to use

  Use `phia_textarea/1` whenever you need multi-line free-text input bound to a
  changeset field — user bios, post bodies, support messages, notes, descriptions,
  or any content longer than a single line. For single-line inputs, use
  `phia_input/1`. For code or markdown, consider pairing with a `RichTextEditor`.

  ## Basic usage

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.phia_textarea field={@form[:bio]} label="Bio" />
        <.button type="submit">Save</.button>
      </.form>

  ## Controlling height

  The `:rows` attribute sets the visible text row count (default 4). The textarea
  is also user-resizable vertically (`resize-y`) so users can expand it further:

      <%!-- Compact note field --%>
      <.phia_textarea field={@form[:note]} label="Note" rows={2} />

      <%!-- Tall editor for long-form content --%>
      <.phia_textarea field={@form[:body]} label="Post body" rows={12} />

  ## With description and placeholder

      <.phia_textarea
        field={@form[:description]}
        label="Product description"
        description="Markdown is supported. Maximum 500 characters."
        placeholder="Describe your product..."
        rows={6}
      />

  ## Support ticket form example

      <.form for={@form} phx-submit="submit_ticket">
        <.phia_input field={@form[:subject]} label="Subject" />
        <.phia_textarea
          field={@form[:message]}
          label="Message"
          description="Include as much detail as possible."
          rows={8}
          placeholder="Describe your issue..."
        />
        <.button type="submit">Submit ticket</.button>
      </.form>

  ## Debounce

  `phx-debounce="blur"` is applied automatically, so changeset validation fires
  only when the user leaves the field rather than on every keystroke. This avoids
  premature error messages while the user is still typing.

  ## Class customisation

  Pass `:class` to override or extend the default Tailwind classes via `cn/1`:

      <.phia_textarea field={@form[:code]} label="Code snippet" class="font-mono text-xs" />

  ## Accessibility

  The `<textarea>` receives `id` and `name` from the field struct, and the
  `form_field/1` wrapper renders a `<label for={id}>` association. Error messages
  from the changeset appear below the textarea in destructive colour. Screen
  readers announce both the label and any error messages.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_field: 1]

  # ---------------------------------------------------------------------------
  # phia_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` struct, obtained via `@form[:field_name]` inside
    a `Phoenix.Component.form/1` block. Provides `id`, `name`, `value`, and
    `errors` automatically.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: """
    Text rendered in a `<label>` element above the textarea. Associated with
    the textarea via `for`/`id` so clicking the label focuses the element.
    When `nil`, no label is rendered.
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Helper text rendered below the label. Use for format hints, character
    limits, or markdown support notices. Rendered in `text-muted-foreground`.
    """
  )

  attr(:rows, :integer,
    default: 4,
    doc: """
    Number of visible text rows. Controls the initial height of the textarea.
    Users can resize vertically beyond this if needed (`resize-y` is always on).
    Common values: `2` for short notes, `4` (default) for descriptions,
    `8`–`12` for long-form content.
    """
  )

  attr(:placeholder, :string,
    default: nil,
    doc: """
    Ghost text shown when the textarea is empty. Use to illustrate the expected
    format or provide a writing prompt. Rendered in `text-muted-foreground`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional Tailwind CSS classes merged into the `<textarea>` element via
    `cn/1`. Use to override font, spacing, or sizing defaults. Example:
    `class="font-mono text-xs"` for a code textarea.
    """
  )

  @doc """
  Renders a multi-line `<textarea>` integrated with `Phoenix.HTML.FormField`.

  Wraps the native `<textarea>` in `form_field/1` to provide a consistent
  label, description, and automatic changeset error display via `form_message/1`.

  The element is always resizable vertically (`resize-y`) with a minimum height
  of `80px`. Height is controlled primarily via `:rows`. Validation fires on
  blur (`phx-debounce="blur"`) to prevent premature errors during typing.

  ## Examples

      <%!-- Minimal --%>
      <.phia_textarea field={@form[:bio]} label="Bio" />

      <%!-- Custom height and placeholder --%>
      <.phia_textarea
        field={@form[:notes]}
        label="Notes"
        rows={6}
        placeholder="Optional notes about this order..."
      />

      <%!-- With description --%>
      <.phia_textarea
        field={@form[:description]}
        label="Description"
        description="Markdown is supported."
        placeholder="Write something..."
      />

      <%!-- Monospace code input --%>
      <.phia_textarea
        field={@form[:snippet]}
        label="Code snippet"
        class="font-mono text-xs"
        rows={8}
      />
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
