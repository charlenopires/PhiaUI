defmodule PhiaUi.Components.Editor.Presets do
  @moduledoc """
  Editor Presets — 10 pre-composed editor configurations for common use cases.

  Each preset composes the lower-level PhiaUI editor components into a
  ready-to-use editor with opinionated defaults. Import one preset component
  and drop it into your LiveView for an instant editing experience.

  ## Presets

  ### Original (v0.1.17)
  - `simple_editor/1`          — minimal editor with bold/italic/link/lists toolbar
  - `article_editor/1`         — Medium-style editor for blog posts and articles
  - `document_editor_full/1`   — full document shell with header/footer/sidebar
  - `academic_editor/1`        — academic editor with citation toolbar
  - `email_composer/1`         — email-style editor with To/Subject/Signature

  ### v2 Presets (v0.1.17)
  - `notion_editor/1`          — Notion-style: slash commands, drag, block toolbars
  - `google_docs_editor/1`     — GDocs: menu bar, A4 pages, track changes
  - `medium_editor_v2/1`       — Medium: floating toolbar, clean reading, images
  - `code_notes_editor/1`      — Dev notes: syntax hl, code sandbox, markdown
  - `collaborative_editor/1`   — Full collab: presence, cursors, comments sidebar

  ## Usage

      # In your LiveView template:
      <.simple_editor id="my-editor" value={@content} />

      # Or for a full document experience:
      <.document_editor_full id="doc" title="Q4 Report" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Editor.RichEditor

  # ============================================================================
  # 1. simple_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Start writing..."
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a minimal editor with a compact toolbar (bold, italic, link, lists).

  This is the simplest preset — ideal for comments, short notes, and forms
  where a lightweight rich text input is needed.

  ## Example

      <.simple_editor id="comment-editor" placeholder="Add a comment..." />
  """
  def simple_editor(assigns) do
    ~H"""
    <.rich_editor
      id={@id}
      value={@value}
      placeholder={@placeholder}
      on_update={@on_update}
      toolbar_variant={:compact}
      show_word_count={false}
      min_height="150px"
      class={@class}
      {@rest}
    />
    """
  end

  # ============================================================================
  # 2. article_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a Medium-style article editor with heading selector, image support,
  and embeds.

  Features a full toolbar with text formatting, heading levels, lists,
  blockquotes, code blocks, and media insertion. Ideal for blog posts,
  documentation, and long-form content.

  ## Example

      <.article_editor id="blog-editor" value={@draft_content} />
  """
  def article_editor(assigns) do
    ~H"""
    <div class={cn(["mx-auto max-w-3xl", @class])} {@rest}>
      <%!-- Article-specific header bar --%>
      <div class="mb-4 flex items-center justify-between rounded-xl border border-border bg-background px-4 py-2">
        <div class="flex items-center gap-2 text-sm text-muted-foreground">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 20h9" /><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" />
          </svg>
          <span>Article Editor</span>
        </div>
        <div class="flex items-center gap-1">
          <button
            type="button"
            phx-click="editor:preview"
            phx-value-editor-id={@id}
            class="rounded-lg px-3 py-1.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            Preview
          </button>
          <button
            type="button"
            phx-click="editor:publish"
            phx-value-editor-id={@id}
            class="rounded-lg bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Publish
          </button>
        </div>
      </div>

      <%!-- Editor --%>
      <.rich_editor
        id={@id}
        value={@value}
        on_update={@on_update}
        placeholder="Tell your story..."
        min_height="500px"
        toolbar_variant={:default}
        show_word_count={true}
      />
    </div>
    """
  end

  # ============================================================================
  # 3. document_editor_full/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :title, :string, default: "Untitled"
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a full document editor with header, toolbar, content, sidebar, and footer.

  This is the most complete preset — a Google Docs-like experience with title
  bar, save status, collapsible sidebar, word count footer, and full formatting
  toolbar.

  ## Example

      <.document_editor_full id="report" title="Q4 Report" value={@content} />
  """
  def document_editor_full(assigns) do
    ~H"""
    <div class={cn(["flex h-screen flex-col bg-muted/20", @class])} {@rest}>
      <%!-- Document header --%>
      <header class="flex items-center justify-between border-b border-border bg-background px-4 py-2">
        <div class="flex items-center gap-3">
          <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
            <polyline points="14 2 14 8 20 8" />
          </svg>
          <h1
            contenteditable="true"
            phx-blur="doc:title:update"
            phx-value-id={@id}
            class="text-sm font-semibold text-foreground outline-none"
          >{@title}</h1>
        </div>
        <div class="flex items-center gap-2">
          <span class="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span class="h-1.5 w-1.5 rounded-full bg-green-500" />
            Saved
          </span>
          <button
            type="button"
            phx-click="doc:export"
            phx-value-id={@id}
            class="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-foreground transition-colors hover:bg-muted"
          >
            Export
          </button>
          <button
            type="button"
            phx-click="doc:share"
            phx-value-id={@id}
            class="rounded-lg bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Share
          </button>
        </div>
      </header>

      <%!-- Main area --%>
      <div class="flex flex-1 overflow-hidden">
        <%!-- Editor in centered page view --%>
        <main class="flex-1 overflow-y-auto px-4 py-8">
          <div class="mx-auto max-w-3xl rounded-xl bg-background shadow-sm">
            <.rich_editor
              id={@id}
              value={@value}
              on_update={@on_update}
              placeholder="Start writing your document..."
              min_height="600px"
              toolbar_variant={:default}
              show_word_count={true}
            />
          </div>
        </main>
      </div>

      <%!-- Footer status bar --%>
      <footer class="flex items-center justify-between border-t border-border bg-background px-4 py-1.5 text-xs text-muted-foreground">
        <span data-doc-word-count>0 words</span>
        <span>Page 1 | 100%</span>
      </footer>
    </div>
    """
  end

  # ============================================================================
  # 4. academic_editor/1
  # ============================================================================

  @citation_styles [
    %{value: :apa, label: "APA"},
    %{value: :mla, label: "MLA"},
    %{value: :chicago, label: "Chicago"},
    %{value: :harvard, label: "Harvard"},
    %{value: :ieee, label: "IEEE"},
    %{value: :vancouver, label: "Vancouver"}
  ]

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :citation_style, :atom, default: :apa
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an academic editor with citation toolbar and formatting for papers.

  Includes a citation style selector, footnote insertion, bibliography tools,
  and standard text formatting. The toolbar is tailored for academic writing.

  ## Example

      <.academic_editor id="paper" citation_style={:mla} value={@paper_content} />
  """
  def academic_editor(assigns) do
    assigns = assign(assigns, :citation_styles, @citation_styles)

    ~H"""
    <div class={cn(["mx-auto max-w-3xl", @class])} {@rest}>
      <%!-- Academic toolbar --%>
      <div class="mb-2 flex items-center gap-3 rounded-xl border border-border bg-background px-4 py-2">
        <div class="flex items-center gap-2">
          <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z" />
            <path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z" />
          </svg>
          <span class="text-xs font-medium text-muted-foreground">Academic</span>
        </div>

        <div class="h-4 w-px bg-border" />

        <%!-- Citation style selector --%>
        <select
          name="citation_style"
          phx-change="editor:citation_style"
          phx-value-editor-id={@id}
          class="rounded border border-border bg-background px-2 py-1 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
        >
          <option
            :for={style <- @citation_styles}
            value={style.value}
            selected={style.value == @citation_style}
          >
            {style.label}
          </option>
        </select>

        <div class="h-4 w-px bg-border" />

        <%!-- Citation tools --%>
        <div class="flex items-center gap-1">
          <button
            type="button"
            phx-click="editor:insert_citation"
            phx-value-editor-id={@id}
            class="rounded px-2 py-1 text-xs text-foreground transition-colors hover:bg-muted"
            title="Insert citation"
          >
            Cite
          </button>
          <button
            type="button"
            phx-click="editor:insert_footnote"
            phx-value-editor-id={@id}
            class="rounded px-2 py-1 text-xs text-foreground transition-colors hover:bg-muted"
            title="Insert footnote"
          >
            Footnote
          </button>
          <button
            type="button"
            phx-click="editor:bibliography"
            phx-value-editor-id={@id}
            class="rounded px-2 py-1 text-xs text-foreground transition-colors hover:bg-muted"
            title="Manage bibliography"
          >
            Bibliography
          </button>
        </div>

        <div class="h-4 w-px bg-border" />

        <%!-- Export to LaTeX --%>
        <button
          type="button"
          phx-click="editor:export_latex"
          phx-value-editor-id={@id}
          class="rounded px-2 py-1 text-xs text-foreground transition-colors hover:bg-muted"
          title="Export to LaTeX"
        >
          LaTeX
        </button>
      </div>

      <%!-- Editor --%>
      <.rich_editor
        id={@id}
        value={@value}
        on_update={@on_update}
        placeholder="Begin your manuscript..."
        min_height="600px"
        toolbar_variant={:default}
        show_word_count={true}
      />
    </div>
    """
  end

  # ============================================================================
  # 5. email_composer/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :to, :string, default: ""
  attr :subject, :string, default: ""
  attr :signature, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an email-style composer with To, Subject, body, and signature fields.

  The body uses the rich editor with a compact toolbar. The signature is
  appended below the editor as a preview.

  ## Example

      <.email_composer
        id="email"
        to="user@example.com"
        subject="Meeting Follow-Up"
        signature="Best regards,\\nJohn"
      />
  """
  def email_composer(assigns) do
    ~H"""
    <div class={cn(["rounded-xl border border-border bg-background shadow-sm", @class])} {@rest}>
      <%!-- Email header fields --%>
      <div class="space-y-0 border-b border-border">
        <div class="flex items-center border-b border-border px-4 py-2">
          <label for={"#{@id}-to"} class="w-16 shrink-0 text-sm text-muted-foreground">To</label>
          <input
            type="email"
            id={"#{@id}-to"}
            name="to"
            value={@to}
            placeholder="recipient@example.com"
            class="flex-1 border-0 bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-0"
          />
        </div>
        <div class="flex items-center px-4 py-2">
          <label for={"#{@id}-subject"} class="w-16 shrink-0 text-sm text-muted-foreground">Subject</label>
          <input
            type="text"
            id={"#{@id}-subject"}
            name="subject"
            value={@subject}
            placeholder="Email subject"
            class="flex-1 border-0 bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-0"
          />
        </div>
      </div>

      <%!-- Email body editor --%>
      <.rich_editor
        id={@id}
        value={@value}
        placeholder="Compose your email..."
        min_height="300px"
        toolbar_variant={:compact}
        show_word_count={false}
        class="rounded-none border-0 shadow-none"
      />

      <%!-- Signature preview --%>
      <div :if={@signature != ""} class="border-t border-border px-4 py-3">
        <div class="text-sm text-muted-foreground">
          <div class="mb-2 h-px w-16 bg-border" />
          <p :for={line <- String.split(@signature, "\n")} class="leading-relaxed">
            {line}
          </p>
        </div>
      </div>

      <%!-- Actions --%>
      <div class="flex items-center justify-between border-t border-border px-4 py-2">
        <div class="flex items-center gap-1">
          <button
            type="button"
            phx-click="email:attach"
            phx-value-editor-id={@id}
            class="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            title="Attach file"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48" />
            </svg>
          </button>
          <button
            type="button"
            phx-click="email:schedule"
            phx-value-editor-id={@id}
            class="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            title="Schedule send"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
          </button>
        </div>
        <div class="flex items-center gap-2">
          <button
            type="button"
            phx-click="email:discard"
            phx-value-editor-id={@id}
            class="rounded-lg border border-border px-4 py-1.5 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Discard
          </button>
          <button
            type="button"
            phx-click="email:send"
            phx-value-editor-id={@id}
            class="rounded-lg bg-primary px-4 py-1.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Send
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 6. notion_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a Notion-style editor with slash commands, drag handles, and
  per-block floating toolbars. Minimal chrome, maximum content focus.

  Features: block-level operations, drag reorder, "/" command palette,
  markdown input shortcuts (via v2 engine).

  ## Example

      <.notion_editor id="notes-editor" value={@content} />
  """
  def notion_editor(assigns) do
    ~H"""
    <div class={cn(["mx-auto max-w-3xl", @class])} {@rest}>
      <%!-- Minimal top bar --%>
      <div class="mb-2 flex items-center justify-between px-1 py-1.5">
        <div class="flex items-center gap-2 text-sm text-muted-foreground">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4 6h16M4 12h16M4 18h7" />
          </svg>
          <span class="text-xs font-medium">Notion-style</span>
        </div>
        <div class="flex items-center gap-1 text-xs text-muted-foreground">
          <span class="rounded bg-muted px-1.5 py-0.5 font-mono">/</span>
          <span>for commands</span>
        </div>
      </div>

      <%!-- Editor with no visible toolbar --%>
      <.rich_editor
        id={@id}
        value={@value}
        on_update={@on_update}
        placeholder="Press '/' for commands, or just start typing..."
        min_height="400px"
        toolbar_variant={:floating}
        show_word_count={false}
      />
    </div>
    """
  end

  # ============================================================================
  # 7. google_docs_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :title, :string, default: "Untitled Document"
  attr :on_update, :string, default: "editor:update"
  attr :track_changes, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a Google Docs-style editor with a full menu bar, toolbar,
  A4-formatted pages, and optional track changes mode.

  Features: document title, save status, full formatting toolbar,
  A4 page layout, word count footer, track changes toggle.

  ## Example

      <.google_docs_editor id="doc" title="Q4 Report" track_changes={true} />
  """
  def google_docs_editor(assigns) do
    ~H"""
    <div class={cn(["flex h-screen flex-col bg-muted/30", @class])} {@rest}>
      <%!-- Menu bar --%>
      <header class="flex items-center justify-between border-b border-border bg-background px-4 py-1.5">
        <div class="flex items-center gap-3">
          <svg class="h-6 w-6 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
            <polyline points="14 2 14 8 20 8" />
            <line x1="16" y1="13" x2="8" y2="13" />
            <line x1="16" y1="17" x2="8" y2="17" />
          </svg>
          <div>
            <h1
              contenteditable="true"
              phx-blur="doc:title:update"
              phx-value-id={@id}
              class="text-sm font-semibold text-foreground outline-none"
            >{@title}</h1>
            <nav class="flex items-center gap-3 text-xs text-muted-foreground" role="menubar">
              <button type="button" class="hover:text-foreground transition-colors">File</button>
              <button type="button" class="hover:text-foreground transition-colors">Edit</button>
              <button type="button" class="hover:text-foreground transition-colors">View</button>
              <button type="button" class="hover:text-foreground transition-colors">Insert</button>
              <button type="button" class="hover:text-foreground transition-colors">Format</button>
              <button type="button" class="hover:text-foreground transition-colors">Tools</button>
            </nav>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <%!-- Track changes toggle --%>
          <div :if={@track_changes} class="flex items-center gap-1.5 rounded-full border border-primary/30 bg-primary/5 px-2.5 py-1">
            <span class="h-1.5 w-1.5 rounded-full bg-primary" />
            <span class="text-xs font-medium text-primary">Suggesting</span>
          </div>
          <span class="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span class="h-1.5 w-1.5 rounded-full bg-green-500" />
            Saved
          </span>
          <button
            type="button"
            phx-click="doc:share"
            phx-value-id={@id}
            class="rounded-full bg-primary px-4 py-1.5 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Share
          </button>
        </div>
      </header>

      <%!-- Content area with A4 page look --%>
      <div class="flex-1 overflow-y-auto py-8">
        <div class="phia-a4-page mx-auto">
          <.rich_editor
            id={@id}
            value={@value}
            on_update={@on_update}
            placeholder="Start typing your document..."
            min_height="900px"
            toolbar_variant={:default}
            show_word_count={true}
          />
        </div>
      </div>

      <%!-- Footer --%>
      <footer class="flex items-center justify-between border-t border-border bg-background px-4 py-1 text-xs text-muted-foreground">
        <span data-doc-word-count>0 words</span>
        <div class="flex items-center gap-4">
          <span>English</span>
          <span>Page 1 of 1</span>
          <span>100%</span>
        </div>
      </footer>
    </div>
    """
  end

  # ============================================================================
  # 8. medium_editor_v2/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a Medium-style writing experience with floating toolbar, clean
  reading typography, and image-focused layout.

  Features: floating selection toolbar, large headings, wide image support,
  drop cap option, distraction-free writing.

  ## Example

      <.medium_editor_v2 id="story" value={@story_content} />
  """
  def medium_editor_v2(assigns) do
    ~H"""
    <div class={cn(["mx-auto max-w-2xl px-4 py-12", @class])} {@rest}>
      <%!-- Clean header --%>
      <div class="mb-8 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
            <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 20h9" /><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" />
            </svg>
          </div>
          <span class="text-sm font-medium text-foreground">Write</span>
        </div>
        <div class="flex items-center gap-2">
          <button
            type="button"
            phx-click="editor:preview"
            phx-value-editor-id={@id}
            class="rounded-full px-4 py-1.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            Preview
          </button>
          <button
            type="button"
            phx-click="editor:publish"
            phx-value-editor-id={@id}
            class="rounded-full bg-green-600 px-4 py-1.5 text-xs font-medium text-white transition-colors hover:bg-green-700"
          >
            Publish
          </button>
        </div>
      </div>

      <%!-- Editor with floating toolbar --%>
      <.rich_editor
        id={@id}
        value={@value}
        on_update={@on_update}
        placeholder="Tell your story..."
        min_height="500px"
        toolbar_variant={:floating}
        show_word_count={true}
        class="prose prose-lg max-w-none"
      />
    </div>
    """
  end

  # ============================================================================
  # 9. code_notes_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :on_update, :string, default: "editor:update"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a developer-focused notes editor with syntax highlighting,
  code sandbox blocks, and markdown input shortcuts.

  Features: code blocks with language detection and highlighting,
  inline code formatting, monospace-friendly layout, markdown shortcuts.

  ## Example

      <.code_notes_editor id="dev-notes" value={@notes} />
  """
  def code_notes_editor(assigns) do
    ~H"""
    <div class={cn(["mx-auto max-w-4xl", @class])} {@rest}>
      <%!-- Dev toolbar --%>
      <div class="mb-2 flex items-center justify-between rounded-lg border border-border bg-background px-4 py-2">
        <div class="flex items-center gap-2">
          <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="16 18 22 12 16 6" /><polyline points="8 6 2 12 8 18" />
          </svg>
          <span class="text-xs font-medium text-muted-foreground">Code Notes</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="flex items-center gap-1 rounded bg-muted px-2 py-0.5 text-xs text-muted-foreground">
            <svg class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="4 7 4 4 20 4 20 7" />
              <line x1="9" y1="20" x2="15" y2="20" />
              <line x1="12" y1="4" x2="12" y2="20" />
            </svg>
            Markdown shortcuts active
          </div>
          <button
            type="button"
            phx-click="editor:insert_code_block"
            phx-value-editor-id={@id}
            class="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-foreground transition-colors hover:bg-muted"
          >
            + Code Block
          </button>
        </div>
      </div>

      <%!-- Editor with full toolbar --%>
      <.rich_editor
        id={@id}
        value={@value}
        on_update={@on_update}
        placeholder="# Start with a heading, or ``` for a code block..."
        min_height="500px"
        toolbar_variant={:default}
        show_word_count={true}
        class="font-mono"
      />
    </div>
    """
  end

  # ============================================================================
  # 10. collaborative_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :title, :string, default: "Shared Document"
  attr :on_update, :string, default: "editor:update"
  attr :collaborators, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a full collaborative editing experience with presence indicators,
  cursor tracking, comments sidebar, and version history access.

  Designed to integrate with PhiaUI's Collab Suite (CollabRoom, CollabPresence,
  etc.) for real-time multi-user editing.

  ## Example

      <.collaborative_editor
        id="collab-doc"
        title="Team Notes"
        collaborators={@online_users}
      />
  """
  def collaborative_editor(assigns) do
    ~H"""
    <div class={cn(["flex h-screen flex-col bg-background", @class])} {@rest}>
      <%!-- Collab header --%>
      <header class="flex items-center justify-between border-b border-border px-4 py-2">
        <div class="flex items-center gap-3">
          <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" />
            <circle cx="9" cy="7" r="4" />
            <path d="M23 21v-2a4 4 0 00-3-3.87" />
            <path d="M16 3.13a4 4 0 010 7.75" />
          </svg>
          <h1 class="text-sm font-semibold text-foreground">{@title}</h1>
        </div>
        <div class="flex items-center gap-3">
          <%!-- Presence avatars --%>
          <div class="flex -space-x-2">
            <div
              :for={user <- Enum.take(@collaborators, 5)}
              class="h-7 w-7 rounded-full border-2 border-background flex items-center justify-center text-xs font-medium text-white"
              style={"background-color: #{Map.get(user, :color, "#6b7280")};"}
              title={Map.get(user, :name, "User")}
            >
              {String.first(Map.get(user, :name, "U"))}
            </div>
            <div
              :if={length(@collaborators) > 5}
              class="h-7 w-7 rounded-full border-2 border-background bg-muted flex items-center justify-center text-xs font-medium text-muted-foreground"
            >
              +{length(@collaborators) - 5}
            </div>
          </div>

          <div class="h-4 w-px bg-border" />

          <%!-- Actions --%>
          <button
            type="button"
            phx-click="collab:comments"
            phx-value-id={@id}
            class="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            title="Comments"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" />
            </svg>
          </button>
          <button
            type="button"
            phx-click="collab:history"
            phx-value-id={@id}
            class="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            title="Version history"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
            </svg>
          </button>
          <button
            type="button"
            phx-click="doc:share"
            phx-value-id={@id}
            class="rounded-lg bg-primary px-4 py-1.5 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Share
          </button>
        </div>
      </header>

      <%!-- Main content area --%>
      <div class="flex flex-1 overflow-hidden">
        <main class="flex-1 overflow-y-auto px-4 py-8">
          <div class="mx-auto max-w-3xl rounded-xl bg-background shadow-sm">
            <.rich_editor
              id={@id}
              value={@value}
              on_update={@on_update}
              placeholder="Start collaborating..."
              min_height="600px"
              toolbar_variant={:default}
              show_word_count={true}
              collab_enabled={true}
            />
          </div>
        </main>
      </div>

      <%!-- Footer --%>
      <footer class="flex items-center justify-between border-t border-border bg-background px-4 py-1.5 text-xs text-muted-foreground">
        <div class="flex items-center gap-2">
          <span class="h-1.5 w-1.5 rounded-full bg-green-500" />
          <span>{length(@collaborators)} online</span>
        </div>
        <span data-doc-word-count>0 words</span>
      </footer>
    </div>
    """
  end
end
