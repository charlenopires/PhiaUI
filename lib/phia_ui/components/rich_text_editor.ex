defmodule PhiaUi.Components.RichTextEditor do
  @moduledoc """
  Rich Text Editor Component for Phoenix LiveView.

  Provides `rich_text_editor/1` — a contenteditable-based rich text editor
  with a full toolbar, Phoenix.HTML.Form integration, and changeset error display.

  The editor is powered by the `PhiaRichTextEditor` JS hook (zero npm dependencies).
  It uses `document.execCommand()` for formatting and the Selection API for
  active-state detection, inspired by TipTap but built natively.

  ## Registration

  Register the hook in `app.js`:

      import PhiaRichTextEditor from "./phia_hooks/rich_text_editor.js"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaRichTextEditor } })

  ## Example

      <.rich_text_editor field={@form[:body]} label="Content" placeholder="Write something..." />

      <.rich_text_editor
        field={@form[:description]}
        label="Description"
        min_height="400px"
      />
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
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"
  )

  attr(:label, :string, default: nil, doc: "Label text rendered above the editor")

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text shown when the editor is empty"
  )

  attr(:min_height, :string,
    default: "200px",
    doc: "Minimum height of the editable area (CSS value)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper")

  @doc """
  Renders a rich text editor integrated with `Phoenix.HTML.FormField`.

  Uses the `PhiaRichTextEditor` JS hook for formatting commands and active-state
  tracking. Content is synced to a hidden input so Phoenix changesets work normally.
  """
  def rich_text_editor(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label
        :if={@label}
        for={@field.id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>

      <div class="rounded-md border border-input bg-background focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2">
        <%!-- Toolbar --%>
        <div class="flex flex-wrap items-center gap-0.5 border-b border-input p-1">
          <%!-- Group 1: Inline marks --%>
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

          <%!-- Group 2: Headings + paragraph --%>
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

          <%!-- Group 3: Lists --%>
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

          <%!-- Group 4: Blockquote + code --%>
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

          <%!-- Group 5: Link --%>
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

        <%!-- Editable area --%>
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

      <%!-- Hidden input for changeset integration --%>
      <input type="hidden" id={@field.id} name={@field.name} />

      <%!-- Changeset errors --%>
      <.form_message field={@field} />
    </div>
    """
  end
end
