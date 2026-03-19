defmodule PhiaUi.Components.Editor.RichEditor do
  @moduledoc """
  Rich Editor Suite — 8 components for building rich text editing experiences
  with Phoenix LiveView.

  This module provides PhiaUI's native rich text editor integration using the
  vanilla `PhiaEditor` engine (zero npm dependencies). All formatting is handled
  via `document.execCommand`, the Selection API, and DOM manipulation.

  ## Architecture

  - **JSON is canonical** — documents stored as typed JSON trees
  - **Server-driven toolbar** — active marks/nodes pushed from client, toolbar
    state lives in LiveView assigns (not JS)
  - **Form integration** — hidden input syncs content for standard form submission
  - **Phoenix events** — `on_update` and `on_selection` event names for LiveView handlers

  ## Components

  ### Core
  - `rich_editor/1`        — main editor with toolbar, content area, form integration (PhiaRichEditor)
  - `rich_toolbar/1`       — server-driven toolbar rendered from active marks/nodes assigns
  - `rich_content/1`       — read-only rendered content from editor JSON

  ### Floating UI
  - `rich_bubble_menu/1`   — selection-aware floating toolbar (PhiaRichEditor)
  - `rich_floating_menu/1` — empty-line insertion menu (PhiaRichEditor)
  - `rich_slash_commands/1` — "/" command palette (PhiaRichEditor)
  - `rich_mention/1`       — @ mention suggestions (PhiaRichEditor)

  ### Collaboration
  - `collab_cursors/1`     — collaborative cursor indicators (PhiaCollab)

  ## Setup

      # In app.js (zero npm dependencies needed):
      import PhiaRichEditor from "./hooks/phia_rich_editor"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaRichEditor } })
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Editor.EditorContent

  # ============================================================================
  # Core Components
  # ============================================================================

  # ----------------------------------------------------------------------------
  # rich_editor/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Type '/' for commands, or start writing..."
  attr :min_height, :string, default: "300px"
  attr :extensions, :list, default: [:starter_kit, :placeholder]
  attr :on_update, :string, default: "editor:update"
  attr :on_selection, :string, default: "editor:selection"
  attr :toolbar_variant, :atom, default: :default, values: [:default, :floating, :compact]
  attr :show_word_count, :boolean, default: true
  attr :show_find_replace, :boolean, default: false
  attr :content_format, :atom, default: :json, values: [:json, :html]
  attr :collab_enabled, :boolean, default: false, doc: "Enable collaborative editing mode"
  attr :collab_doc_id, :string, default: nil, doc: "Document ID for collaboration channel"
  attr :collab_user, :map, default: nil, doc: "Current user map with :id, :name, :color keys"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :toolbar_extra, doc: "Extra toolbar content appended after default groups"

  @doc """
  Main rich text editor with toolbar, content area, and form integration.

  Uses the `PhiaRichEditor` hook which initializes the vanilla `PhiaEditor`
  engine (execCommand-based, zero npm dependencies).

  ## Content Flow

      [Server: LiveView]
        assigns.content = JSON string
        push_event("editor:command:my-editor", %{command: "toggleBold"})
        |
      [Client: PhiaRichEditor hook]
        editor.getHTML() → pushEvent("editor:update", %{json, html, word_count})
        editor.isActive() → pushEvent("editor:selection", %{active_marks, ...})

  ## Examples

      <%!-- Standalone --%>
      <.rich_editor id="blog-editor" placeholder="Write..." min_height="400px" />

      <%!-- Form-integrated --%>
      <.form for={@form} phx-submit="publish">
        <.rich_editor id="post-editor" field={@form[:body]} />
      </.form>

      <%!-- With server-driven commands --%>
      def handle_event("make_bold", _, socket) do
        {:noreply, push_event(socket, "editor:command:post-editor", %{command: "toggleBold"})}
      end
  """
  def rich_editor(assigns) do
    field = assigns.field
    id = assigns.id

    initial_content =
      cond do
        field && field.value -> field.value
        assigns.value -> assigns.value
        true -> ""
      end

    assigns =
      assigns
      |> assign(:editor_id, "#{id}-content")
      |> assign(:hidden_id, if(field, do: field.id, else: "#{id}-value"))
      |> assign(:hidden_name, if(field, do: field.name, else: id))
      |> assign(:initial_content, initial_content)
      |> assign(:errors, if(field, do: field.errors, else: []))
      |> assign(:extensions_json, Jason.encode!(assigns.extensions))

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaRichEditor"
      data-content={@initial_content}
      data-placeholder={@placeholder}
      data-extensions={@extensions_json}
      data-on-update={@on_update}
      data-on-selection={@on_selection}
      data-content-format={to_string(@content_format)}
      data-collab-enabled={to_string(@collab_enabled)}
      data-collab-doc-id={@collab_doc_id}
      data-collab-user-id={@collab_user && @collab_user[:id]}
      data-collab-user-name={@collab_user && @collab_user[:name]}
      data-collab-user-color={@collab_user && @collab_user[:color]}
      class={cn([
        "flex flex-col rounded-xl border border-border bg-background shadow-sm",
        "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-1",
        @class
      ])}
      {@rest}
    >
      <%!-- Toolbar --%>
      <div class="border-b border-border">
        <.rich_toolbar
          variant={@toolbar_variant}
          editor_id={@id}
        >
          <:extra :if={@toolbar_extra != []}>
            {render_slot(@toolbar_extra)}
          </:extra>
        </.rich_toolbar>
      </div>

      <%!-- Editor content area — vanilla PhiaEditor mounts here --%>
      <div
        data-rich-content
        class="prose prose-sm max-w-none px-4 py-3 focus:outline-none dark:prose-invert"
        style={"min-height: #{@min_height}"}
      />

      <%!-- Hidden input for form submission --%>
      <input
        type="hidden"
        id={@hidden_id}
        name={@hidden_name}
        value={@initial_content}
        data-rich-hidden
      />

      <%!-- Word count footer --%>
      <div
        :if={@show_word_count}
        class="flex items-center border-t border-border px-4 py-1.5 text-xs text-muted-foreground"
        data-rich-footer
      >
        <span data-rich-word-count>0 words</span>
      </div>

      <%!-- Error display --%>
      <div
        :if={@errors != []}
        class="border-t border-destructive/30 px-4 py-2"
      >
        <p :for={error <- @errors} class="text-sm text-destructive">
          {translate_error(error)}
        </p>
      </div>
    </div>
    """
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  defp translate_error(msg) when is_binary(msg), do: msg

  # ----------------------------------------------------------------------------
  # rich_toolbar/1
  # ----------------------------------------------------------------------------

  attr :variant, :atom, default: :default, values: [:default, :floating, :compact]
  attr :editor_id, :string, required: true
  attr :active_marks, :list, default: []
  attr :active_nodes, :list, default: []
  attr :heading_level, :any, default: nil
  attr :class, :string, default: nil

  slot :extra, doc: "Extra toolbar content appended after default groups"

  @doc """
  Server-driven toolbar for the rich editor.

  Active states are determined by assigns (pushed from client via selection
  events), not by JavaScript DOM inspection.

  ## Example

      <.rich_toolbar
        editor_id="my-editor"
        active_marks={@editor_state.active_marks}
        active_nodes={@editor_state.active_nodes}
        heading_level={@editor_state.heading_level}
      />
  """
  def rich_toolbar(assigns) do
    ~H"""
    <div
      role="toolbar"
      aria-label="Editor formatting toolbar"
      class={cn([rich_toolbar_variant(@variant), @class])}
    >
      <%!-- History --%>
      <div role="group" aria-label="History" class="flex items-center gap-0.5">
        <button
          type="button"
          phx-click={editor_command(@editor_id, "undo")}
          aria-label="Undo"
          title="Undo (Ctrl+Z)"
          class={rich_btn_class(false)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M3.5 7H10a3 3 0 110 6H7" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M6 4L3 7L6 10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "redo")}
          aria-label="Redo"
          title="Redo (Ctrl+Shift+Z)"
          class={rich_btn_class(false)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M12.5 7H6a3 3 0 100 6h3" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M10 4L13 7L10 10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
      </div>

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <%!-- Text formatting marks --%>
      <div role="group" aria-label="Text formatting" class="flex items-center gap-0.5">
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleBold")}
          aria-label="Bold"
          aria-pressed={to_string("bold" in @active_marks)}
          title="Bold (Ctrl+B)"
          class={rich_btn_class("bold" in @active_marks)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleItalic")}
          aria-label="Italic"
          aria-pressed={to_string("italic" in @active_marks)}
          title="Italic (Ctrl+I)"
          class={rich_btn_class("italic" in @active_marks)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleStrike")}
          aria-label="Strikethrough"
          aria-pressed={to_string("strike" in @active_marks)}
          title="Strikethrough"
          class={rich_btn_class("strike" in @active_marks)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M5.5 10.5c0 1.105.895 2 2 2h1c1.105 0 2-.895 2-2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
            <path d="M10.5 5.5c0-1.105-.895-2-2-2h-1" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
            <line x1="2" y1="8" x2="14" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleCode")}
          aria-label="Inline code"
          aria-pressed={to_string("code" in @active_marks)}
          title="Inline code"
          class={rich_btn_class("code" in @active_marks)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M5 5L2 8L5 11M11 5L14 8L11 11" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
      </div>

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <%!-- Block-level nodes --%>
      <div role="group" aria-label="Block formatting" class="flex items-center gap-0.5">
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleBulletList")}
          aria-label="Bullet list"
          aria-pressed={to_string("bulletList" in @active_nodes)}
          title="Bullet list"
          class={rich_btn_class("bulletList" in @active_nodes)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <circle cx="3" cy="4.5" r="1" fill="currentColor" />
            <circle cx="3" cy="8" r="1" fill="currentColor" />
            <circle cx="3" cy="11.5" r="1" fill="currentColor" />
            <line x1="6" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
            <line x1="6" y1="8" x2="13" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
            <line x1="6" y1="11.5" x2="13" y2="11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleOrderedList")}
          aria-label="Ordered list"
          aria-pressed={to_string("orderedList" in @active_nodes)}
          title="Ordered list"
          class={rich_btn_class("orderedList" in @active_nodes)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M3 3h1v3H2.5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M2.5 9h2l-2 2.5h2" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" />
            <line x1="7" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
            <line x1="7" y1="10.5" x2="13" y2="10.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </button>
        <button
          type="button"
          phx-click={editor_command(@editor_id, "toggleBlockquote")}
          aria-label="Blockquote"
          aria-pressed={to_string("blockquote" in @active_nodes)}
          title="Blockquote"
          class={rich_btn_class("blockquote" in @active_nodes)}
        >
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
            <path d="M3 4h4v4H5l-2 3V8M9 4h4v4h-2l-2 3V8" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
      </div>

      <%!-- Extra slot --%>
      <div :if={@extra != []} class="ml-auto flex items-center">
        {render_slot(@extra)}
      </div>
    </div>
    """
  end

  defp rich_toolbar_variant(:default),
    do: "flex flex-wrap items-center gap-0.5 rounded-t-xl px-2 py-1.5"

  defp rich_toolbar_variant(:floating),
    do: "flex items-center gap-0.5 rounded-lg border border-border bg-popover px-1.5 py-1 shadow-lg backdrop-blur-sm"

  defp rich_toolbar_variant(:compact),
    do: "flex items-center gap-px rounded-t-xl px-1 py-0.5"

  defp rich_btn_class(active) do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded text-foreground transition-colors",
      "hover:bg-accent hover:text-accent-foreground",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      active && "bg-accent text-accent-foreground"
    ])
  end

  defp editor_command(editor_id, command) do
    Phoenix.LiveView.JS.push("editor:command",
      value: %{editor_id: editor_id, command: command}
    )
  end

  # ----------------------------------------------------------------------------
  # rich_content/1
  # ----------------------------------------------------------------------------

  attr :content, :any, default: nil
  attr :prose_size, :atom, default: :base, values: [:sm, :base, :lg]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders editor JSON content as read-only HTML.

  Uses `EditorContent.content_to_html/1` for server-side JSON-to-HTML conversion.
  Always sanitize content before display.

  ## Examples

      <%!-- From JSON map --%>
      <.rich_content content={@post.body_json} prose_size={:lg} />

      <%!-- From JSON string --%>
      <.rich_content content={Jason.decode!(@post.body)} />
  """
  def rich_content(assigns) do
    html =
      case assigns.content do
        nil -> ""
        content when is_binary(content) ->
          case Jason.decode(content) do
            {:ok, decoded} -> EditorContent.content_to_html(decoded)
            _ -> content
          end
        content when is_map(content) ->
          EditorContent.content_to_html(content)
        _ -> ""
      end

    assigns = assign(assigns, :rendered_html, html)

    ~H"""
    <div
      class={cn(["prose max-w-none dark:prose-invert", rich_prose_class(@prose_size), @class])}
      {@rest}
    >
      {Phoenix.HTML.raw(@rendered_html)}
    </div>
    """
  end

  defp rich_prose_class(:sm), do: "prose-sm"
  defp rich_prose_class(:base), do: ""
  defp rich_prose_class(:lg), do: "prose-lg"

  # ============================================================================
  # Floating UI Components
  # ============================================================================

  # ----------------------------------------------------------------------------
  # rich_bubble_menu/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Selection-aware floating toolbar for the rich editor.

  Appears above text selection using the vanilla PhiaEditor positioning.

  ## Example

      <.rich_bubble_menu id="bubble-1" editor_id="my-editor">
        <button phx-click={...}>Bold</button>
      </.rich_bubble_menu>
  """
  def rich_bubble_menu(assigns) do
    ~H"""
    <div
      id={@id}
      data-rich-bubble-menu
      data-editor-id={@editor_id}
      class={cn([
        "absolute z-50 hidden",
        "rounded-lg border border-border bg-popover px-1.5 py-1 shadow-lg backdrop-blur-sm",
        "phia-bubble-menu-open",
        @class
      ])}
      role="toolbar"
      aria-label="Floating formatting toolbar"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # rich_floating_menu/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Empty-line insertion menu for the rich editor.

  Appears at the cursor when the current block is empty.

  ## Example

      <.rich_floating_menu id="float-1" editor_id="my-editor">
        <button phx-click={...}>Heading</button>
        <button phx-click={...}>Image</button>
      </.rich_floating_menu>
  """
  def rich_floating_menu(assigns) do
    ~H"""
    <div
      id={@id}
      data-rich-floating-menu
      data-editor-id={@editor_id}
      class={cn([
        "absolute z-50 hidden",
        "rounded-lg border border-border bg-popover p-1.5 shadow-lg",
        @class
      ])}
      role="toolbar"
      aria-label="Block insertion toolbar"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # rich_slash_commands/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  slot :command do
    attr :label, :string, required: true
    attr :description, :string
    attr :icon, :string
    attr :action, :string, required: true
  end

  @doc """
  Slash command palette for the rich editor.

  Triggered by typing "/" at the start of a line.

  ## Example

      <.rich_slash_commands id="slash-1" editor_id="my-editor">
        <:command label="Heading 1" description="Large heading" action="setHeading" icon="heading" />
        <:command label="Bullet List" description="Unordered list" action="toggleBulletList" icon="list" />
      </.rich_slash_commands>
  """
  def rich_slash_commands(assigns) do
    ~H"""
    <div
      id={@id}
      data-rich-slash-commands
      data-editor-id={@editor_id}
      class={cn([
        "absolute z-50 hidden",
        "max-h-64 w-64 overflow-y-auto rounded-lg border border-border bg-popover py-1 shadow-lg",
        "phia-slash-menu-open",
        @class
      ])}
      role="listbox"
      aria-label="Editor commands"
    >
      <button
        :for={cmd <- @command}
        type="button"
        role="option"
        data-slash-action={cmd.action}
        class="flex w-full items-center gap-3 px-3 py-2 text-left text-sm text-foreground hover:bg-accent focus:bg-accent focus:outline-none"
      >
        <span
          :if={Map.get(cmd, :icon)}
          class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md border border-border bg-background text-muted-foreground"
        >
          {Map.get(cmd, :icon, "")}
        </span>
        <div class="min-w-0 flex-1">
          <div class="font-medium">{cmd.label}</div>
          <div :if={Map.get(cmd, :description)} class="text-xs text-muted-foreground">
            {cmd.description}
          </div>
        </div>
      </button>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # rich_mention/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :suggestions, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Mention suggestions dropdown for the rich editor.

  Triggered by typing "@". Shows a server-driven list of suggestions.

  ## Example

      <.rich_mention
        id="mention-1"
        editor_id="my-editor"
        suggestions={@mention_suggestions}
      />

  Each suggestion should be a map with `:id`, `:label`, and optionally `:avatar_url`.
  """
  def rich_mention(assigns) do
    ~H"""
    <div
      id={@id}
      data-rich-mention
      data-editor-id={@editor_id}
      class={cn([
        "absolute z-50 hidden",
        "max-h-48 w-56 overflow-y-auto rounded-lg border border-border bg-popover py-1 shadow-lg",
        @class
      ])}
      role="listbox"
      aria-label="Mention suggestions"
    >
      <button
        :for={suggestion <- @suggestions}
        type="button"
        role="option"
        data-mention-id={suggestion[:id] || suggestion["id"]}
        data-mention-label={suggestion[:label] || suggestion["label"]}
        class="flex w-full items-center gap-2.5 px-3 py-1.5 text-left text-sm text-foreground hover:bg-accent focus:bg-accent focus:outline-none"
      >
        <span
          :if={suggestion[:avatar_url] || suggestion["avatar_url"]}
          class="h-6 w-6 shrink-0 overflow-hidden rounded-full bg-muted"
        >
          <img
            src={suggestion[:avatar_url] || suggestion["avatar_url"]}
            alt=""
            class="h-full w-full object-cover"
          />
        </span>
        <span :if={!(suggestion[:avatar_url] || suggestion["avatar_url"])} class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary/10 text-xs font-medium text-primary">
          {String.first(suggestion[:label] || suggestion["label"] || "?")}
        </span>
        <span class="truncate">{suggestion[:label] || suggestion["label"]}</span>
      </button>

      <div
        :if={@suggestions == []}
        class="px-3 py-2 text-sm text-muted-foreground"
      >
        No matches found
      </div>
    </div>
    """
  end

  # ============================================================================
  # Collaboration
  # ============================================================================

  # ----------------------------------------------------------------------------
  # collab_cursors/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :cursors, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Collaborative cursor indicators for the rich editor.

  Renders colored cursor labels for connected users.

  ## Example

      <.collab_cursors
        id="cursors-1"
        editor_id="my-editor"
        cursors={@connected_users}
      />

  Each cursor should be a map with `:name`, `:color`, and optionally `:avatar_url`.
  """
  def collab_cursors(assigns) do
    ~H"""
    <div
      id={@id}
      data-collab-cursors
      data-editor-id={@editor_id}
      class={cn(["flex items-center gap-1", @class])}
      aria-label="Connected collaborators"
    >
      <div
        :for={cursor <- @cursors}
        class="relative flex h-6 items-center gap-1 rounded-full px-2 text-xs font-medium text-white"
        style={"background-color: #{cursor[:color] || cursor["color"] || "#6366f1"}"}
        title={cursor[:name] || cursor["name"]}
      >
        <span
          :if={cursor[:avatar_url] || cursor["avatar_url"]}
          class="h-4 w-4 overflow-hidden rounded-full"
        >
          <img src={cursor[:avatar_url] || cursor["avatar_url"]} alt="" class="h-full w-full object-cover" />
        </span>
        <span class="max-w-[6rem] truncate">{cursor[:name] || cursor["name"]}</span>
      </div>

      <div
        :if={length(@cursors) > 3}
        class="flex h-6 items-center rounded-full bg-muted px-2 text-xs font-medium text-muted-foreground"
      >
        +{length(@cursors) - 3}
      </div>
    </div>
    """
  end
end
