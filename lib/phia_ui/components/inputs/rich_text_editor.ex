defmodule PhiaUi.Components.RichTextEditor do
  @moduledoc """
  Rich text editor component for PhiaUI.

  Provides `rich_text_editor/1` — a `contenteditable`-based WYSIWYG editor
  with a full formatting toolbar, `Phoenix.HTML.FormField` integration, and
  changeset error display. Zero npm dependencies.

  The editor is powered by the `PhiaRichTextEditor` JS hook, which uses:
  - `document.execCommand()` for formatting commands (bold, italic, lists, etc.)
  - The `Selection` API for active-state detection (highlighting toolbar buttons)
  - A `MutationObserver` to sync the HTML content to a hidden `<input>` on change

  ## When to use

  Use `rich_text_editor/1` for fields that need multi-line formatted content:

  - Blog post / article body
  - Email template editor
  - Product description with emphasis and lists
  - Knowledge base article
  - Comment with basic formatting support

  For plain text without formatting, use a regular `textarea` or `input`.

  ## Registration

  Register the hook in `app.js`:

      import PhiaRichTextEditor from "./hooks/rich_text_editor"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaRichTextEditor }
      })

  ## Basic example

      <.form for={@form} phx-submit="publish">
        <.rich_text_editor
          field={@form[:body]}
          label="Article body"
          placeholder="Write your article here..."
          min_height="400px"
        />
        <.button type="submit">Publish</.button>
      </.form>

  ## Multiple editors on one page

  Each editor is independent. Giving each a unique `field` is sufficient:

      <.rich_text_editor field={@form[:summary]} label="Summary" min_height="120px" />
      <.rich_text_editor field={@form[:body]}    label="Body"    min_height="400px" />

  ## Toolbar groups

  | Group     | Buttons                                    |
  |-----------|--------------------------------------------|
  | Marks     | Bold, Italic, Underline, Strikethrough     |
  | Blocks    | Heading 1, Heading 2, Heading 3, Paragraph |
  | Lists     | Bullet List, Ordered List                  |
  | Quotes    | Blockquote, Inline Code, Code Block        |
  | Links     | Add Link, Remove Link                      |

  Each button has `data-action` which the hook reads to dispatch the correct
  `execCommand`. Active state is toggled via the `is-active` CSS class,
  which the hook sets based on `document.queryCommandState()`.

  ## Changeset integration

  The hook syncs the `contenteditable` HTML to a `<input type="hidden">` bound
  to `field.name`. On `phx-submit`, the hidden input carries the HTML string
  which the changeset receives:

      def changeset(post, attrs) do
        post
        |> cast(attrs, [:body])
        |> validate_required([:body])
        # Optionally sanitise HTML server-side with HtmlSanitizeEx:
        # |> update_change(:body, &HtmlSanitizeEx.basic_html/1)
      end

  ## Placeholder

  The placeholder is implemented via CSS `::before` pseudo-element using
  `data-placeholder` and the `is-empty` class toggled by the hook. This avoids
  native `placeholder` which is not supported on `contenteditable` elements.

  ## Security note

  The editor produces raw HTML. Always sanitise the stored HTML server-side
  before rendering it back to other users. Consider `HtmlSanitizeEx` or
  `Earmark` for sanitisation.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_message: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # rich_text_editor/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: """
    A `Phoenix.HTML.FormField` from `@form[:field_name]`.
    Provides `id`, `name`, `value`, and `errors` for full form integration.
    The field value is loaded into the editor as initial HTML content.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the editor. Pass `nil` to omit the label."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: """
    Placeholder text shown when the editor is empty.
    Rendered via a CSS `::before` pseudo-element using `data-placeholder`
    and the `is-empty` class — not via the native `placeholder` attribute.
    """
  )

  attr(:min_height, :string,
    default: "200px",
    doc: """
    Minimum height of the editable content area as a CSS value.
    The editor grows vertically beyond this minimum as content is added.
    Example values: `"200px"`, `"400px"`, `"50vh"`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper div"
  )

  @doc """
  Renders a rich text editor integrated with `Phoenix.HTML.FormField`.

  The editor consists of:
  1. An optional `<label>` linked to `field.id`
  2. A bordered container with a formatting toolbar and the editable area
  3. A `<input type="hidden">` bound to `field.name` (synced by the hook)
  4. Changeset validation errors from `field.errors`

  The `PhiaRichTextEditor` hook:
  - Sets `contenteditable="true"` on the editor div on mount
  - Loads `data-content` (the field's current value) as initial HTML
  - Attaches `input` events to sync changes to the hidden input
  - Attaches `click` events to toolbar buttons and dispatches `execCommand`
  - Tracks active formatting via `queryCommandState` to toggle `is-active`
  """
  def rich_text_editor(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%!-- Label linked to the hidden input's id (field.id) for form accessibility --%>
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>

      <div class="rounded-md border border-input bg-background focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2">
        <%!-- ================================================================
             Toolbar — 5 button groups separated by vertical dividers.
             Each button has `data-action` (read by the hook) and
             `aria-pressed="false"` (toggled by the hook to "true" when active).
             ================================================================ --%>
        <div class="flex flex-wrap items-center gap-0.5 border-b border-input p-1">

          <%!-- Group 1: Inline marks — bold, italic, underline, strikethrough --%>
          <button
            type="button"
            data-action="bold"
            aria-label="Bold"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="bold" size={:sm} />
          </button>
          <button
            type="button"
            data-action="italic"
            aria-label="Italic"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="italic" size={:sm} />
          </button>
          <button
            type="button"
            data-action="underline"
            aria-label="Underline"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="underline" size={:sm} />
          </button>
          <button
            type="button"
            data-action="strike"
            aria-label="Strikethrough"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="strikethrough" size={:sm} />
          </button>

          <div class="mx-1 h-5 w-px bg-border" aria-hidden="true"></div>

          <%!-- Group 2: Block formats — H1, H2, H3, paragraph --%>
          <button
            type="button"
            data-action="h1"
            aria-label="Heading 1"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="heading-1" size={:sm} />
          </button>
          <button
            type="button"
            data-action="h2"
            aria-label="Heading 2"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="heading-2" size={:sm} />
          </button>
          <button
            type="button"
            data-action="h3"
            aria-label="Heading 3"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="heading-3" size={:sm} />
          </button>
          <button
            type="button"
            data-action="paragraph"
            aria-label="Paragraph"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="pilcrow" size={:sm} />
          </button>

          <div class="mx-1 h-5 w-px bg-border" aria-hidden="true"></div>

          <%!-- Group 3: List formats — bullet list, ordered list --%>
          <button
            type="button"
            data-action="bulletList"
            aria-label="Bullet List"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="list" size={:sm} />
          </button>
          <button
            type="button"
            data-action="orderedList"
            aria-label="Ordered List"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="list-ordered" size={:sm} />
          </button>

          <div class="mx-1 h-5 w-px bg-border" aria-hidden="true"></div>

          <%!-- Group 4: Quotes and code — blockquote, inline code, code block --%>
          <button
            type="button"
            data-action="blockquote"
            aria-label="Blockquote"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="text-quote" size={:sm} />
          </button>
          <button
            type="button"
            data-action="code"
            aria-label="Inline Code"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="code" size={:sm} />
          </button>
          <button
            type="button"
            data-action="codeBlock"
            aria-label="Code Block"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="square-code" size={:sm} />
          </button>

          <div class="mx-1 h-5 w-px bg-border" aria-hidden="true"></div>

          <%!-- Group 5: Links — add link, remove link --%>
          <button
            type="button"
            data-action="link"
            aria-label="Add Link"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground is-active:bg-accent is-active:text-accent-foreground"
          >
            <.icon name="link" size={:sm} />
          </button>
          <button
            type="button"
            data-action="unlink"
            aria-label="Remove Link"
            aria-pressed="false"
            class="inline-flex items-center justify-center rounded p-1.5 text-sm font-medium text-foreground hover:bg-accent hover:text-accent-foreground"
          >
            <.icon name="link-2-off" size={:sm} />
          </button>
        </div>

        <%!-- Editable content area.
             `data-phia-editor` is the hook's selector for the editable div.
             `data-content` is read by the hook on mount to set the initial HTML.
             `data-placeholder` is used by the CSS ::before placeholder trick.
             The hook sets `contenteditable="true"` and manages `is-empty` class. --%>
        <div
          phx-hook="PhiaRichTextEditor"
          data-phia-editor
          data-content={@field.value}
          {if @placeholder, do: ["data-placeholder": @placeholder], else: []}
          style={"min-height: #{@min_height}"}
          class="prose prose-sm max-w-none px-3 py-2 text-sm focus:outline-none [&.is-empty]:before:pointer-events-none [&.is-empty]:before:float-left [&.is-empty]:before:h-0 [&.is-empty]:before:text-muted-foreground [&.is-empty]:before:content-[attr(data-placeholder)]"
        >
        </div>
      </div>

      <%!-- Hidden input: the hook syncs editor HTML to this input on every change.
           `id={@field.id}` links it to the <label> above for accessibility. --%>
      <input type="hidden" id={@field.id} name={@field.name} />

      <%!-- Changeset validation errors from field.errors --%>
      <.form_message field={@field} />
    </div>
    """
  end
end
