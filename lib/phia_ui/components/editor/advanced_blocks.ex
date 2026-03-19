defmodule PhiaUi.Components.Editor.AdvancedBlocks do
  @moduledoc """
  Editor Advanced Block Components — 5 specialized blocks for power-user
  editing workflows: synced (reusable) blocks, multi-column layouts with
  drag-resize dividers, executable code sandboxes, A4 page containers,
  and page header/footer chrome.

  These components enable document-level features found in advanced editors
  like Notion, Google Docs, and Overleaf.

  All components render meaningful HTML without JavaScript (progressive
  enhancement) and support dark mode via Tailwind v4 design tokens.

  ## Components

  - `synced_block/1`         — reusable content reference with synced indicator
  - `columns_block/1`        — multi-column layout with drag-resize dividers
  - `code_sandbox_block/1`   — executable code editor with output area
  - `a4_page/1`              — A4 page container with margins and page numbering
  - `page_header_footer/1`   — header/footer bar for A4 page containers
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. synced_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the synced block instance."
  attr :source_id, :string, required: true, doc: "ID of the original source block being referenced."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "Block content (mirrors the source block)."

  @doc """
  Renders a reusable content reference block with a "Synced" badge indicator.

  Synced blocks display the same content as the original source block. Changes
  to the source propagate to all synced instances. The block has a subtle dashed
  border to visually distinguish it from regular blocks.

  ## Example

      <.synced_block id="sync-1" source_id="original-block-42">
        This content is synced from block 42.
      </.synced_block>
  """
  def synced_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="syncedBlock"
      data-source-id={@source_id}
      class={cn([
        "relative rounded-lg border border-dashed border-primary/40 bg-primary/5 p-4",
        "dark:bg-primary/10",
        @class
      ])}
      {@rest}
    >
      <div class="absolute -top-2.5 left-3 flex items-center gap-1 rounded-full bg-background px-2 py-0.5">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-primary">
          <path d="M21 12a9 9 0 0 1-9 9m9-9a9 9 0 0 0-9-9m9 9H3m9 9a9 9 0 0 1-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9" />
        </svg>
        <span class="text-[10px] font-medium text-primary">Synced</span>
      </div>
      <div class="text-sm leading-relaxed text-foreground">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ============================================================================
  # 2. columns_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the columns block."
  attr :columns, :integer, default: 2, doc: "Number of columns (1-4)."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  slot :column, doc: "Individual column content (repeatable slot)."

  @doc """
  Renders a multi-column layout with CSS grid and vertical dividers between columns.

  Each column has `min-w-0` to prevent content overflow, and a vertical divider
  with `cursor-col-resize` and hover highlight between columns. Columns are
  indexed via `data-column-index`.

  ## Example

      <.columns_block id="two-col" columns={2}>
        <:column>Left column content</:column>
        <:column>Right column content</:column>
      </.columns_block>
  """
  def columns_block(assigns) do
    clamped_cols = max(1, min(4, assigns.columns))
    indexed = Enum.with_index(assigns.column)
    assigns = assign(assigns, clamped_cols: clamped_cols, indexed_columns: indexed)

    ~H"""
    <div
      id={@id}
      data-type="columnsBlock"
      data-columns={@clamped_cols}
      role="presentation"
      class={cn(["my-4 flex gap-0", @class])}
      {@rest}
    >
      <%= for {col, idx} <- @indexed_columns do %>
        <div
          :if={idx > 0}
          class="group/divider flex w-3 shrink-0 cursor-col-resize items-stretch justify-center"
          aria-hidden="true"
          data-column-divider={idx}
        >
          <div class="h-full w-px bg-border transition-colors group-hover/divider:bg-primary" />
        </div>
        <div
          class="min-w-0 flex-1 text-sm leading-relaxed text-foreground"
          data-column-index={idx}
        >
          {render_slot(col)}
        </div>
      <% end %>
      <%!-- Handle the first column (no preceding divider) rendered by the for loop --%>
    </div>
    """
  end

  # ============================================================================
  # 3. code_sandbox_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the code sandbox."
  attr :language, :string, default: "javascript", doc: "Programming language label."
  attr :code, :string, default: "", doc: "Source code content."
  attr :output, :string, default: "", doc: "Execution output text."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders an executable code block with a code editor textarea and an output
  display area.

  The header shows the language label and a "Run" button that dispatches
  `phx-click="code-sandbox:run"` with the block ID. The output area renders
  in a monospace pre element with a muted background.

  ## Example

      <.code_sandbox_block
        id="sandbox-1"
        language="elixir"
        code="IO.puts(:hello)"
        output="hello"
      />
  """
  def code_sandbox_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="codeSandbox"
      data-language={@language}
      class={cn([
        "my-4 overflow-hidden rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <%!-- Header --%>
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
            <polyline points="16 18 22 12 16 6" />
            <polyline points="8 6 2 12 8 18" />
          </svg>
          <span class="rounded bg-muted px-1.5 py-0.5 text-xs font-mono font-medium text-muted-foreground">
            {@language}
          </span>
        </div>
        <button
          type="button"
          phx-click="code-sandbox:run"
          phx-value-block-id={@id}
          aria-label="Run code"
          class={cn([
            "inline-flex h-7 items-center gap-1.5 rounded-md px-3",
            "bg-primary text-xs font-medium text-primary-foreground",
            "hover:bg-primary/90 transition-colors",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <polygon points="5 3 19 12 5 21 5 3" />
          </svg>
          Run
        </button>
      </div>

      <%!-- Code editor area --%>
      <div class="border-b border-border p-3">
        <label for={"#{@id}-code"} class="sr-only">Code editor</label>
        <textarea
          id={"#{@id}-code"}
          name={"#{@id}-code"}
          rows="8"
          spellcheck="false"
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          class={cn([
            "w-full resize-y rounded-md border border-input bg-muted/30 px-3 py-2",
            "font-mono text-sm leading-relaxed text-foreground",
            "placeholder:text-muted-foreground",
            "focus:outline-none focus:ring-2 focus:ring-ring"
          ])}
        >{@code}</textarea>
      </div>

      <%!-- Output area --%>
      <div class="p-3">
        <div class="mb-1 flex items-center gap-1.5">
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-muted-foreground">
            <polyline points="4 17 10 11 4 5" />
            <line x1="12" y1="19" x2="20" y2="19" />
          </svg>
          <span class="text-[10px] font-medium uppercase tracking-wider text-muted-foreground">Output</span>
        </div>
        <pre
          class={cn([
            "min-h-[2.5rem] rounded-md bg-muted/30 px-3 py-2",
            "font-mono text-xs leading-relaxed text-foreground",
            "overflow-x-auto whitespace-pre-wrap"
          ])}
          aria-label="Code output"
        >{if @output != "" and @output != nil, do: @output, else: "No output"}</pre>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 4. a4_page/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the A4 page."
  attr :page_number, :integer, default: nil, doc: "Page number (displayed in footer)."
  attr :show_header, :boolean, default: true, doc: "Whether to render the header slot."
  attr :show_footer, :boolean, default: true, doc: "Whether to render the footer slot."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  slot :header, doc: "Optional header content for the page."
  slot :inner_block, required: true, doc: "Main page content."
  slot :footer, doc: "Optional footer content for the page."

  @doc """
  Renders an A4 page container with margins, white background, shadow, and
  optional header/footer areas.

  The container is styled for A4 dimensions (210mm x 297mm) at `@media print`.
  On screen, it renders as a white page with shadow and padding approximating
  standard margins (25.4mm). Page number is shown in the footer when provided.

  ## Example

      <.a4_page id="page-1" page_number={1}>
        <:header>My Document</:header>
        Page content goes here.
        <:footer>Confidential</:footer>
      </.a4_page>
  """
  def a4_page(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="a4Page"
      data-page-number={@page_number}
      class={cn([
        "phia-a4-page relative mx-auto bg-white dark:bg-zinc-950",
        "shadow-lg dark:shadow-zinc-900/50",
        "print:shadow-none print:m-0",
        @class
      ])}
      style="width: 210mm; min-height: 297mm; padding: 6rem 6rem 6rem 6rem; max-width: 100%;"
      {@rest}
    >
      <%!-- Header --%>
      <div
        :if={@show_header && @header != []}
        class="mb-6 border-b border-border/50 pb-3"
        data-page-header
      >
        {render_slot(@header)}
      </div>

      <%!-- Main content --%>
      <div class="flex-1 text-sm leading-relaxed text-foreground" data-page-content>
        {render_slot(@inner_block)}
      </div>

      <%!-- Footer --%>
      <div
        :if={@show_footer}
        class="mt-6 border-t border-border/50 pt-3"
        data-page-footer
      >
        <div
          :if={@footer != []}
          class="text-xs text-muted-foreground"
        >
          {render_slot(@footer)}
        </div>
        <div
          :if={@page_number}
          class={cn([
            "text-center text-xs tabular-nums text-muted-foreground",
            @footer != [] && "mt-2"
          ])}
        >
          {@page_number}
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 5. page_header_footer/1
  # ============================================================================

  attr :id, :string, default: nil, doc: "Optional identifier."

  attr :type, :atom,
    default: :header,
    values: [:header, :footer],
    doc: "Whether this is a header or footer."

  attr :page_number, :integer, default: nil, doc: "Current page number."
  attr :total_pages, :integer, default: nil, doc: "Total number of pages."
  attr :document_title, :string, default: nil, doc: "Document title to display."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a header or footer bar for A4 page containers.

  For headers: displays the document title on the left.
  For footers: displays the document title on the left and the page number
  (with optional total pages) on the right.

  ## Example

      <.page_header_footer type={:header} document_title="Annual Report 2025" />
      <.page_header_footer type={:footer} document_title="Annual Report" page_number={3} total_pages={12} />
  """
  def page_header_footer(assigns) do
    ~H"""
    <div
      id={@id}
      data-page-chrome={@type}
      class={cn([
        "flex items-center justify-between text-xs text-muted-foreground",
        @type == :header && "border-b border-border/50 pb-2",
        @type == :footer && "border-t border-border/50 pt-2",
        @class
      ])}
    >
      <span :if={@document_title} class="truncate">{@document_title}</span>
      <span :if={!@document_title} />

      <span :if={@type == :footer && @page_number} class="tabular-nums">
        {if @total_pages, do: "#{@page_number} / #{@total_pages}", else: to_string(@page_number)}
      </span>
    </div>
    """
  end
end
