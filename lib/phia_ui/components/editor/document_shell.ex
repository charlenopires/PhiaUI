defmodule PhiaUi.Components.Editor.DocumentShell do
  @moduledoc """
  Document Shell Suite — 6 components for building full-page document editors.

  Provides the structural layout primitives for a Google Docs / Notion-style
  document editing experience: header with title and status, collapsible
  sidebar, footer status bar, and breadcrumb navigation.

  ## Components

  - `document_editor/1`     — full-page flexbox layout shell with header/toolbar/content/sidebar/footer slots
  - `document_header/1`     — top bar with title, share button, and save status indicator
  - `document_title/1`      — contenteditable `<h1>` for the document title
  - `document_sidebar/1`    — collapsible right panel with tab navigation
  - `document_footer/1`     — status bar with word count, page count, zoom, save status
  - `document_breadcrumb/1` — breadcrumb trail with "/" separators
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. document_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  slot :header, doc: "Document header area"
  slot :toolbar, doc: "Editor toolbar area"
  slot :content, required: true, doc: "Main editor content area"
  slot :sidebar, doc: "Collapsible sidebar panel"
  slot :footer, doc: "Status bar / footer area"

  @doc """
  Renders a full-page document editor layout with flexbox.

  Arranges header, toolbar, content (with optional sidebar), and footer in a
  vertical stack. The content area fills all remaining vertical space.

  ## Example

      <.document_editor id="my-doc">
        <:header>
          <.document_header id="doc-header" title="My Document" />
        </:header>
        <:toolbar>
          <.rich_toolbar editor_id="editor" />
        </:toolbar>
        <:content>
          <div id="editor-content" contenteditable="true" />
        </:content>
        <:sidebar>
          <.document_sidebar id="doc-sidebar" />
        </:sidebar>
        <:footer>
          <.document_footer word_count={@word_count} />
        </:footer>
      </.document_editor>
  """
  def document_editor(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex h-full min-h-screen flex-col bg-background",
        @class
      ])}
      {@rest}
    >
      <%!-- Header slot --%>
      <div :if={@header != []} class="shrink-0">
        {render_slot(@header)}
      </div>

      <%!-- Toolbar slot --%>
      <div :if={@toolbar != []} class="shrink-0 border-b border-border">
        {render_slot(@toolbar)}
      </div>

      <%!-- Content + Sidebar --%>
      <div class="flex flex-1 overflow-hidden">
        <main class="flex-1 overflow-y-auto">
          {render_slot(@content)}
        </main>
        <aside :if={@sidebar != []} class="shrink-0">
          {render_slot(@sidebar)}
        </aside>
      </div>

      <%!-- Footer slot --%>
      <div :if={@footer != []} class="shrink-0">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  # ============================================================================
  # 2. document_header/1
  # ============================================================================

  attr :id, :string, required: true
  attr :title, :string, default: "Untitled"
  attr :status, :atom, default: :saved, values: [:saved, :saving, :unsaved]
  attr :share_count, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a document header with title, save status indicator, and share button.

  ## Example

      <.document_header id="hdr" title="Q4 Report" status={:saving} share_count={3} />
  """
  def document_header(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-center justify-between border-b border-border bg-background px-4 py-2",
        @class
      ])}
      {@rest}
    >
      <div class="flex items-center gap-3">
        <%!-- Document icon --%>
        <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
          <polyline points="14 2 14 8 20 8" />
        </svg>
        <h1 class="text-sm font-semibold text-foreground">{@title}</h1>

        <%!-- Status indicator --%>
        <span class={cn(["flex items-center gap-1.5 text-xs", status_class(@status)])}>
          <span class={cn(["h-1.5 w-1.5 rounded-full", status_dot_class(@status)])} />
          {status_label(@status)}
        </span>
      </div>

      <div class="flex items-center gap-2">
        <%!-- Share button --%>
        <button
          type="button"
          phx-click="doc:share"
          phx-value-id={@id}
          class="inline-flex items-center gap-1.5 rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-foreground transition-colors hover:bg-muted"
        >
          <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8" />
            <polyline points="16 6 12 2 8 6" />
            <line x1="12" y1="2" x2="12" y2="15" />
          </svg>
          Share
          <span
            :if={@share_count > 0}
            class="inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-primary px-1 text-[10px] font-medium text-primary-foreground"
          >
            {@share_count}
          </span>
        </button>
      </div>
    </div>
    """
  end

  defp status_class(:saved), do: "text-green-600 dark:text-green-400"
  defp status_class(:saving), do: "text-yellow-600 dark:text-yellow-400"
  defp status_class(:unsaved), do: "text-muted-foreground"

  defp status_dot_class(:saved), do: "bg-green-500"
  defp status_dot_class(:saving), do: "bg-yellow-500 animate-pulse"
  defp status_dot_class(:unsaved), do: "bg-muted-foreground"

  defp status_label(:saved), do: "Saved"
  defp status_label(:saving), do: "Saving..."
  defp status_label(:unsaved), do: "Unsaved changes"

  # ============================================================================
  # 3. document_title/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Untitled document"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a contenteditable `<h1>` for the document title.

  Emits `phx-blur` with the updated text for server-side persistence.

  ## Example

      <.document_title id="doc-title" value={@doc_title} />
  """
  def document_title(assigns) do
    ~H"""
    <h1
      id={@id}
      contenteditable="true"
      phx-blur="doc:title:update"
      phx-value-id={@id}
      data-placeholder={@placeholder}
      class={cn([
        "text-3xl font-bold text-foreground outline-none",
        "empty:before:text-muted-foreground/50 empty:before:content-[attr(data-placeholder)]",
        @class
      ])}
      {@rest}
    >{@value}</h1>
    """
  end

  # ============================================================================
  # 4. document_sidebar/1
  # ============================================================================

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :active_tab, :atom, default: :comments, values: [:comments, :outline, :history, :info]
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Renders a collapsible right sidebar panel with tab navigation.

  Tabs allow switching between Comments, Outline, History, and Info views.
  The sidebar collapses to zero width when `:open` is false.

  ## Example

      <.document_sidebar id="sidebar" open={@sidebar_open} active_tab={@sidebar_tab}>
        <p>Sidebar content here</p>
      </.document_sidebar>
  """
  def document_sidebar(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "border-l border-border bg-background transition-all duration-200",
        @open && "w-80",
        !@open && "w-0 overflow-hidden",
        @class
      ])}
      {@rest}
    >
      <div :if={@open} class="flex h-full flex-col">
        <%!-- Tab bar --%>
        <div class="flex border-b border-border">
          <button
            :for={tab <- [:comments, :outline, :history, :info]}
            type="button"
            phx-click="doc:sidebar:tab"
            phx-value-tab={tab}
            phx-value-id={@id}
            class={cn([
              "flex-1 px-2 py-2.5 text-xs font-medium transition-colors",
              tab == @active_tab && "border-b-2 border-primary text-primary",
              tab != @active_tab && "text-muted-foreground hover:text-foreground"
            ])}
          >
            {sidebar_tab_label(tab)}
          </button>
        </div>

        <%!-- Tab content --%>
        <div class="flex-1 overflow-y-auto p-4">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  defp sidebar_tab_label(:comments), do: "Comments"
  defp sidebar_tab_label(:outline), do: "Outline"
  defp sidebar_tab_label(:history), do: "History"
  defp sidebar_tab_label(:info), do: "Info"

  # ============================================================================
  # 5. document_footer/1
  # ============================================================================

  attr :word_count, :integer, default: 0
  attr :page_count, :integer, default: 1
  attr :zoom, :integer, default: 100
  attr :status, :atom, default: :saved
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a document status bar at the bottom.

  Displays word count, page count, zoom level, and save status.

  ## Example

      <.document_footer word_count={@word_count} page_count={2} zoom={125} status={:saved} />
  """
  def document_footer(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-center justify-between border-t border-border bg-muted/30 px-4 py-1.5 text-xs text-muted-foreground",
        @class
      ])}
      {@rest}
    >
      <div class="flex items-center gap-4">
        <span>{@word_count} {if @word_count == 1, do: "word", else: "words"}</span>
        <span class="h-3 w-px bg-border" />
        <span>Page {@page_count}</span>
      </div>

      <div class="flex items-center gap-4">
        <span>{@zoom}%</span>
        <span class="h-3 w-px bg-border" />
        <span class={cn(["flex items-center gap-1.5", footer_status_class(@status)])}>
          <span class={cn(["h-1.5 w-1.5 rounded-full", footer_status_dot(@status)])} />
          {footer_status_label(@status)}
        </span>
      </div>
    </div>
    """
  end

  defp footer_status_class(:saved), do: "text-green-600 dark:text-green-400"
  defp footer_status_class(:saving), do: "text-yellow-600 dark:text-yellow-400"
  defp footer_status_class(:unsaved), do: "text-muted-foreground"
  defp footer_status_class(_), do: "text-muted-foreground"

  defp footer_status_dot(:saved), do: "bg-green-500"
  defp footer_status_dot(:saving), do: "bg-yellow-500 animate-pulse"
  defp footer_status_dot(:unsaved), do: "bg-muted-foreground"
  defp footer_status_dot(_), do: "bg-muted-foreground"

  defp footer_status_label(:saved), do: "Saved"
  defp footer_status_label(:saving), do: "Saving..."
  defp footer_status_label(:unsaved), do: "Unsaved"
  defp footer_status_label(_), do: ""

  # ============================================================================
  # 6. document_breadcrumb/1
  # ============================================================================

  attr :items, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a breadcrumb trail with "/" separators.

  Each item in `:items` should be a map with `:label` and optional `:href` keys.
  The last item is rendered as plain text (current page).

  ## Example

      <.document_breadcrumb items={[
        %{label: "Documents", href: "/docs"},
        %{label: "Projects", href: "/docs/projects"},
        %{label: "Q4 Report"}
      ]} />
  """
  def document_breadcrumb(assigns) do
    assigns = assign(assigns, :indexed_items, Enum.with_index(assigns.items))

    ~H"""
    <nav
      aria-label="Breadcrumb"
      class={cn(["flex items-center gap-1.5 text-sm", @class])}
      {@rest}
    >
      <ol class="flex items-center gap-1.5">
        <li
          :for={{item, idx} <- @indexed_items}
          class="flex items-center gap-1.5"
        >
          <span
            :if={idx > 0}
            class="text-muted-foreground"
            aria-hidden="true"
          >/</span>

          <a
            :if={item[:href] && idx < length(@items) - 1}
            href={item[:href]}
            class="text-muted-foreground transition-colors hover:text-foreground"
          >
            {item[:label] || item["label"]}
          </a>
          <span
            :if={!item[:href] || idx == length(@items) - 1}
            class={cn([
              idx == length(@items) - 1 && "font-medium text-foreground",
              idx != length(@items) - 1 && "text-muted-foreground"
            ])}
          >
            {item[:label] || item["label"]}
          </span>
        </li>
      </ol>
    </nav>
    """
  end
end
