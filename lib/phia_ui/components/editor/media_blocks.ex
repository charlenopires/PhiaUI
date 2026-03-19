defmodule PhiaUi.Components.Editor.MediaBlocks do
  @moduledoc """
  Editor Media Block Components — 9 rich media blocks for embedding images,
  tables, equations, attachments, diagrams, and drawings inside a rich text editor.

  All components render meaningful HTML without JavaScript (progressive enhancement).
  Interactive behaviors (table inserter hover, drawing canvas) use `phx-hook` for
  optional JS enhancement.

  ## Components

  ### Media & Embeds
  - `image_block/1`            — figure with image, caption, and alignment
  - `embed_block/1`            — iframe/embed for YouTube, Vimeo, Twitter, generic URLs
  - `file_attachment_block/1`  — downloadable file card with icon and metadata

  ### Table Tools
  - `table_inserter/1`         — hoverable grid for picking table dimensions (N x M)
  - `table_operations/1`       — toolbar with row/column/merge operations
  - `table_of_contents/1`      — navigation list generated from headings

  ### Specialized Blocks
  - `equation_editor/1`        — math equation textarea with preview area
  - `diagram_block/1`          — code editor for Mermaid/PlantUML/DOT with preview
  - `drawing_canvas/1`         — HTML canvas element with phx-hook for freehand drawing
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 10. image_block/1
  # ============================================================================

  attr :id, :string, required: true
  attr :src, :string, required: true
  attr :alt, :string, default: ""
  attr :caption, :string, default: nil

  attr :alignment, :atom,
    default: :center,
    values: [:left, :center, :right]

  attr :width, :string, default: "100%"
  attr :resizable, :boolean, default: false, doc: "Enable drag-to-resize handles via PhiaImageResize hook"
  attr :class, :string, default: nil

  @doc """
  Renders an image block as a `<figure>` with optional `<figcaption>`.

  Supports left/center/right alignment and configurable width.

  ## Example

      <.image_block id="hero-img" src="/images/hero.jpg" alt="Hero banner"
                    caption="Our latest product launch" alignment={:center} width="80%" />
  """
  def image_block(assigns) do
    ~H"""
    <figure
      id={@id}
      data-type="imageBlock"
      phx-hook={if @resizable, do: "PhiaImageResize", else: nil}
      class={cn([
        "my-4",
        image_alignment_class(@alignment),
        @class
      ])}
    >
      <div class="overflow-hidden rounded-lg">
        <img
          src={@src}
          alt={@alt}
          loading="lazy"
          style={"width: #{@width}; max-width: 100%;"}
          class="h-auto rounded-lg object-cover"
        />
      </div>
      <figcaption
        :if={@caption}
        class={cn([
          "mt-2 text-xs text-muted-foreground",
          image_caption_align(@alignment)
        ])}
      >
        {@caption}
      </figcaption>
    </figure>
    """
  end

  defp image_alignment_class(:left), do: "mr-auto"
  defp image_alignment_class(:center), do: "mx-auto"
  defp image_alignment_class(:right), do: "ml-auto"

  defp image_caption_align(:left), do: "text-left"
  defp image_caption_align(:center), do: "text-center"
  defp image_caption_align(:right), do: "text-right"

  # ============================================================================
  # 11. table_inserter/1
  # ============================================================================

  attr :id, :string, required: true
  attr :max_rows, :integer, default: 8
  attr :max_cols, :integer, default: 8
  attr :class, :string, default: nil

  @doc """
  Renders a grid of hoverable cells for picking table dimensions.

  Users hover over the grid to highlight cells and see a "N x M" label indicating
  the resulting table size. Each cell triggers a `phx-click` event with the
  selected row and column counts.

  ## Example

      <.table_inserter id="table-picker" max_rows={6} max_cols={6} />
  """
  def table_inserter(assigns) do
    cells =
      for row <- 1..assigns.max_rows, col <- 1..assigns.max_cols do
        %{row: row, col: col}
      end

    assigns = assign(assigns, :cells, cells)

    ~H"""
    <div
      id={@id}
      data-type="tableInserter"
      role="grid"
      aria-label="Select table dimensions"
      class={cn([
        "inline-flex flex-col items-center gap-2 rounded-lg border border-border bg-popover p-3 shadow-md",
        @class
      ])}
    >
      <div
        class="grid gap-1"
        style={"grid-template-columns: repeat(#{@max_cols}, 1fr);"}
      >
        <button
          :for={cell <- @cells}
          type="button"
          phx-click="table:insert"
          phx-value-rows={cell.row}
          phx-value-cols={cell.col}
          aria-label={"#{cell.row} by #{cell.col} table"}
          data-row={cell.row}
          data-col={cell.col}
          class={cn([
            "h-5 w-5 rounded-sm border border-border bg-background",
            "transition-colors duration-75",
            "hover:border-primary hover:bg-primary/20",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
          ])}
        />
      </div>
      <span
        data-table-inserter-label
        class="text-xs font-medium text-muted-foreground"
        aria-live="polite"
      >
        {@max_rows} &times; {@max_cols}
      </span>
    </div>
    """
  end

  # ============================================================================
  # 12. table_operations/1
  # ============================================================================

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :interactive, :boolean, default: false, doc: "Enable PhiaTableEditor hook for cell selection, resize, and Tab navigation"
  attr :class, :string, default: nil

  @doc """
  Renders a toolbar with table manipulation buttons: add/remove rows and columns,
  and merge cells.

  Each button dispatches a `phx-click` event with the operation name and the
  associated editor ID.

  ## Example

      <.table_operations id="table-ops" editor_id="my-editor" />
  """
  def table_operations(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label="Table operations"
      phx-hook={if @interactive, do: "PhiaTableEditor", else: nil}
      data-editor-id={@editor_id}
      class={cn([
        "flex flex-wrap items-center gap-1 rounded-md border border-input bg-background p-1",
        @class
      ])}
    >
      <button
        :for={op <- table_ops()}
        type="button"
        phx-click="table:operation"
        phx-value-operation={op.action}
        phx-value-editor-id={@editor_id}
        aria-label={op.label}
        title={op.label}
        class={cn([
          "inline-flex h-7 w-7 items-center justify-center rounded text-foreground transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
          op.destructive && "text-destructive hover:bg-destructive/10 hover:text-destructive"
        ])}
      >
        {Phoenix.HTML.raw(op.icon)}
      </button>
    </div>
    """
  end

  defp table_ops do
    [
      %{
        action: "add_row_above",
        label: "Add row above",
        destructive: false,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M3 10h18"/><path d="M12 3v7"/></svg>]
      },
      %{
        action: "add_row_below",
        label: "Add row below",
        destructive: false,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M3 14h18"/><path d="M12 14v7"/></svg>]
      },
      %{
        action: "add_col_left",
        label: "Add column left",
        destructive: false,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M10 3v18"/><path d="M3 12h7"/></svg>]
      },
      %{
        action: "add_col_right",
        label: "Add column right",
        destructive: false,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M14 3v18"/><path d="M14 12h7"/></svg>]
      },
      %{
        action: "delete_row",
        label: "Delete row",
        destructive: true,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M3 12h18"/><path d="M9 12l6 0"/><path d="M9 12l3-3m-3 3l3 3"/></svg>]
      },
      %{
        action: "delete_col",
        label: "Delete column",
        destructive: true,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M12 3v18"/><path d="M12 9l0 6"/><path d="M12 9l-3 3m3-3l3 3"/></svg>]
      },
      %{
        action: "merge_cells",
        label: "Merge cells",
        destructive: false,
        icon: ~s[<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5z"/><path d="M8 12h8"/><path d="M8 12l3-3m-3 3l3 3"/><path d="M16 12l-3-3m3 3l-3 3"/></svg>]
      }
    ]
  end

  # ============================================================================
  # 13. table_of_contents/1
  # ============================================================================

  attr :id, :string, required: true
  attr :headings, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Renders a table of contents navigation list generated from document headings.

  Each heading in the `:headings` list should be a map with `:level` (integer 1-6),
  `:text` (string), and `:id` (string anchor ID) keys. Items are indented by level.

  ## Example

      <.table_of_contents id="toc" headings={[
        %{level: 1, text: "Introduction", id: "intro"},
        %{level: 2, text: "Getting Started", id: "getting-started"},
        %{level: 2, text: "Configuration", id: "config"},
        %{level: 1, text: "API Reference", id: "api"}
      ]} />
  """
  def table_of_contents(assigns) do
    ~H"""
    <nav
      id={@id}
      aria-label="Table of contents"
      class={cn([
        "rounded-lg border border-border bg-muted/30 p-4",
        @class
      ])}
    >
      <h2 class="mb-3 text-xs font-semibold uppercase tracking-widest text-muted-foreground">
        Table of Contents
      </h2>
      <ul role="list" class="space-y-1">
        <li
          :for={heading <- @headings}
          style={"padding-left: #{(Map.get(heading, :level, 1) - 1) * 0.75}rem;"}
        >
          <a
            href={"##{Map.get(heading, :id, "")}"}
            class={cn([
              "block rounded-md px-2 py-1 text-sm transition-colors",
              "text-muted-foreground hover:text-foreground hover:bg-accent/50",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
              Map.get(heading, :level, 1) == 1 && "font-medium text-foreground"
            ])}
          >
            {Map.get(heading, :text, "")}
          </a>
        </li>
      </ul>
    </nav>
    """
  end

  # ============================================================================
  # 14. equation_editor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :class, :string, default: nil

  @doc """
  Renders a math equation editor with a textarea for input and a preview area.

  The preview div is a placeholder for client-side rendering (e.g., KaTeX or MathJax).
  Without JavaScript, the raw LaTeX source is shown in the preview.

  ## Example

      <.equation_editor id="eq-1" value="E = mc^2" />
  """
  def equation_editor(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="equationEditor"
      phx-hook="PhiaEquation"
      class={cn([
        "rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center gap-2 border-b border-border px-3 py-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-muted-foreground">
          <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z" />
          <path d="m12 15-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z" />
          <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0" />
          <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5" />
        </svg>
        <span class="text-xs font-medium text-muted-foreground">Equation Editor</span>
      </div>
      <div class="grid grid-cols-1 divide-y divide-border md:grid-cols-2 md:divide-x md:divide-y-0">
        <div class="p-3">
          <label for={"#{@id}-input"} class="mb-1 block text-xs font-medium text-muted-foreground">
            LaTeX Source
          </label>
          <textarea
            id={"#{@id}-input"}
            name={"#{@id}-equation"}
            rows="3"
            placeholder="E = mc^2"
            class={cn([
              "w-full resize-none rounded-md border border-input bg-muted/30 px-3 py-2",
              "font-mono text-sm text-foreground",
              "placeholder:text-muted-foreground",
              "focus:outline-none focus:ring-2 focus:ring-ring"
            ])}
          >{@value}</textarea>
        </div>
        <div class="p-3">
          <span class="mb-1 block text-xs font-medium text-muted-foreground">Preview</span>
          <div
            data-equation-preview
            aria-label="Equation preview"
            class="flex min-h-[4.5rem] items-center justify-center rounded-md bg-muted/20 p-3 font-mono text-sm text-foreground"
          >
            {if @value != "" and @value != nil, do: @value, else: "No equation entered"}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 15. embed_block/1
  # ============================================================================

  attr :id, :string, required: true
  attr :url, :string, required: true

  attr :type, :atom,
    default: :auto,
    values: [:auto, :youtube, :vimeo, :twitter, :generic]

  attr :class, :string, default: nil

  @doc """
  Renders an embed block for external content (YouTube, Vimeo, Twitter, generic URLs).

  The `:type` attribute can be set to `:auto` to detect the provider from the URL.
  YouTube and Vimeo URLs render responsive iframes; Twitter renders a link card;
  generic URLs render in a sandboxed iframe.

  ## Example

      <.embed_block id="vid-1" url="https://www.youtube.com/watch?v=dQw4w9WgXcQ" />
      <.embed_block id="tweet-1" url="https://twitter.com/elikiir/status/123" type={:twitter} />
  """
  def embed_block(assigns) do
    resolved_type = resolve_embed_type(assigns.type, assigns.url)
    embed_url = build_embed_url(resolved_type, assigns.url)

    assigns =
      assigns
      |> assign(:resolved_type, resolved_type)
      |> assign(:embed_url, embed_url)

    ~H"""
    <div
      id={@id}
      data-type="embedBlock"
      data-embed-type={@resolved_type}
      class={cn(["my-4 overflow-hidden rounded-lg border border-border", @class])}
    >
      <%!-- YouTube / Vimeo: responsive iframe --%>
      <div
        :if={@resolved_type in [:youtube, :vimeo]}
        class="relative aspect-video w-full"
      >
        <iframe
          src={@embed_url}
          title={"Embedded #{@resolved_type} video"}
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen
          loading="lazy"
          class="absolute inset-0 h-full w-full"
        />
      </div>

      <%!-- Twitter: link card fallback --%>
      <div
        :if={@resolved_type == :twitter}
        class="flex items-center gap-3 bg-muted/30 p-4"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="shrink-0 text-muted-foreground">
          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
        </svg>
        <div class="min-w-0 flex-1">
          <a
            href={@url}
            target="_blank"
            rel="noopener noreferrer"
            class="block truncate text-sm font-medium text-foreground hover:text-primary hover:underline"
          >
            {@url}
          </a>
          <span class="text-xs text-muted-foreground">View on X (Twitter)</span>
        </div>
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
          <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" /><polyline points="15 3 21 3 21 9" /><line x1="10" y1="14" x2="21" y2="3" />
        </svg>
      </div>

      <%!-- Generic: sandboxed iframe --%>
      <div
        :if={@resolved_type == :generic}
        class="relative aspect-video w-full"
      >
        <iframe
          src={@url}
          title="Embedded content"
          frameborder="0"
          sandbox="allow-scripts allow-same-origin"
          loading="lazy"
          class="absolute inset-0 h-full w-full"
        />
      </div>
    </div>
    """
  end

  defp resolve_embed_type(:auto, url) do
    cond do
      String.contains?(url, "youtube.com") or String.contains?(url, "youtu.be") -> :youtube
      String.contains?(url, "vimeo.com") -> :vimeo
      String.contains?(url, "twitter.com") or String.contains?(url, "x.com") -> :twitter
      true -> :generic
    end
  end

  defp resolve_embed_type(explicit, _url), do: explicit

  defp build_embed_url(:youtube, url) do
    video_id = extract_youtube_id(url)
    "https://www.youtube.com/embed/#{video_id}"
  end

  defp build_embed_url(:vimeo, url) do
    video_id = extract_vimeo_id(url)
    "https://player.vimeo.com/video/#{video_id}"
  end

  defp build_embed_url(_type, url), do: url

  defp extract_youtube_id(url) do
    cond do
      String.contains?(url, "youtu.be/") ->
        url |> String.split("youtu.be/") |> List.last() |> String.split("?") |> List.first()

      String.contains?(url, "v=") ->
        url |> String.split("v=") |> List.last() |> String.split("&") |> List.first()

      String.contains?(url, "/embed/") ->
        url |> String.split("/embed/") |> List.last() |> String.split("?") |> List.first()

      true ->
        ""
    end
  end

  defp extract_vimeo_id(url) do
    url
    |> String.split("/")
    |> Enum.reverse()
    |> Enum.find("", fn part -> String.match?(part, ~r/^\d+/) end)
    |> String.split("?")
    |> List.first()
  end

  # ============================================================================
  # 16. file_attachment_block/1
  # ============================================================================

  attr :name, :string, required: true
  attr :size, :string, default: nil
  attr :icon, :string, default: nil
  attr :href, :string, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a file attachment card with an icon, filename, optional size, and download link.

  When `:href` is provided, the card becomes a downloadable link. The `:icon` attribute
  accepts an emoji or text label; a default file icon SVG is used when omitted.

  ## Example

      <.file_attachment_block name="report.pdf" size="2.4 MB" href="/files/report.pdf" />
      <.file_attachment_block name="data.csv" size="128 KB" icon="📊" />
  """
  def file_attachment_block(assigns) do
    ~H"""
    <div class={cn([
      "flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3 transition-colors",
      @href && "hover:bg-accent/50",
      @class
    ])}>
      <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-muted text-muted-foreground">
        <span :if={@icon} class="text-lg" aria-hidden="true">{@icon}</span>
        <svg :if={!@icon} xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" />
          <path d="M14 2v4a2 2 0 0 0 2 2h4" />
        </svg>
      </div>
      <div class="min-w-0 flex-1">
        <a
          :if={@href}
          href={@href}
          download={@name}
          class="block truncate text-sm font-medium text-foreground hover:text-primary hover:underline"
        >
          {@name}
        </a>
        <span :if={!@href} class="block truncate text-sm font-medium text-foreground">{@name}</span>
        <span :if={@size} class="text-xs text-muted-foreground">{@size}</span>
      </div>
      <a
        :if={@href}
        href={@href}
        download={@name}
        aria-label={"Download #{@name}"}
        class="shrink-0 rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
        </svg>
      </a>
    </div>
    """
  end

  # ============================================================================
  # 17. diagram_block/1
  # ============================================================================

  attr :id, :string, required: true
  attr :source, :string, default: ""

  attr :language, :atom,
    default: :mermaid,
    values: [:mermaid, :plantuml, :dot]

  attr :class, :string, default: nil

  @doc """
  Renders a diagram block with a source code editor and a preview area.

  The source textarea accepts Mermaid, PlantUML, or DOT graph notation. The preview
  div is a placeholder for client-side rendering (the diagram library renders into it
  via a JS hook or external script). Without JavaScript, the raw source is displayed.

  ## Example

      <.diagram_block id="flow-1" language={:mermaid} source="graph TD; A-->B; B-->C;" />
  """
  def diagram_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="diagramBlock"
      data-language={@language}
      phx-hook="PhiaDiagram"
      class={cn([
        "rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-muted-foreground">
            <rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /><path d="M14 17h7" /><path d="M17.5 14v7" />
          </svg>
          <span class="text-xs font-medium text-muted-foreground">
            {diagram_language_label(@language)}
          </span>
        </div>
        <span class="rounded-md bg-muted px-2 py-0.5 text-xs font-mono text-muted-foreground">
          {@language}
        </span>
      </div>
      <div class="grid grid-cols-1 divide-y divide-border md:grid-cols-2 md:divide-x md:divide-y-0">
        <div class="p-3">
          <label for={"#{@id}-source"} class="mb-1 block text-xs font-medium text-muted-foreground">
            Source
          </label>
          <textarea
            id={"#{@id}-source"}
            name={"#{@id}-diagram-source"}
            rows="6"
            placeholder={diagram_placeholder(@language)}
            class={cn([
              "w-full resize-y rounded-md border border-input bg-muted/30 px-3 py-2",
              "font-mono text-xs leading-relaxed text-foreground",
              "placeholder:text-muted-foreground",
              "focus:outline-none focus:ring-2 focus:ring-ring"
            ])}
          >{@source}</textarea>
        </div>
        <div class="p-3">
          <span class="mb-1 block text-xs font-medium text-muted-foreground">Preview</span>
          <div
            data-diagram-preview
            aria-label="Diagram preview"
            class="flex min-h-[9rem] items-center justify-center rounded-md bg-muted/20 p-3"
          >
            <pre :if={@source != "" and @source != nil} class="text-xs text-muted-foreground whitespace-pre-wrap">{@source}</pre>
            <span :if={@source == "" or @source == nil} class="text-xs text-muted-foreground">No diagram source entered</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp diagram_language_label(:mermaid), do: "Mermaid Diagram"
  defp diagram_language_label(:plantuml), do: "PlantUML Diagram"
  defp diagram_language_label(:dot), do: "Graphviz DOT"

  defp diagram_placeholder(:mermaid), do: "graph TD;\n  A-->B;\n  B-->C;"
  defp diagram_placeholder(:plantuml), do: "@startuml\nAlice -> Bob: Hello\n@enduml"
  defp diagram_placeholder(:dot), do: "digraph G {\n  A -> B;\n  B -> C;\n}"

  # ============================================================================
  # 18. drawing_canvas/1
  # ============================================================================

  attr :id, :string, required: true
  attr :width, :string, default: "100%"
  attr :height, :string, default: "300px"
  attr :class, :string, default: nil

  @doc """
  Renders an HTML canvas element for freehand drawing.

  The `PhiaDrawingCanvas` hook initializes pointer-event-based drawing on the canvas.
  Without JavaScript, a placeholder message is shown via the `<canvas>` fallback content.

  ## Example

      <.drawing_canvas id="sketch-1" width="100%" height="400px" />
  """
  def drawing_canvas(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="drawingCanvas"
      class={cn([
        "rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-muted-foreground">
            <path d="m12 19 7-7 3 3-7 7-3-3z" /><path d="m18 13-1.5-7.5L2 2l3.5 14.5L13 18l5-5z" /><path d="m2 2 7.586 7.586" /><circle cx="11" cy="11" r="2" />
          </svg>
          <span class="text-xs font-medium text-muted-foreground">Drawing Canvas</span>
        </div>
        <div class="flex items-center gap-1">
          <button
            type="button"
            phx-click={"drawing:clear:#{@id}"}
            aria-label="Clear canvas"
            title="Clear canvas"
            class={cn([
              "inline-flex h-7 items-center gap-1 rounded-md px-2 text-xs text-muted-foreground",
              "transition-colors hover:bg-accent hover:text-foreground",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            ])}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
            </svg>
            Clear
          </button>
        </div>
      </div>
      <div class="p-2">
        <canvas
          id={"#{@id}-canvas"}
          phx-hook="PhiaDrawingCanvas"
          role="img"
          aria-label="Drawing canvas"
          style={"width: #{@width}; height: #{@height};"}
          class="w-full cursor-crosshair rounded-md bg-white dark:bg-zinc-900"
        >
          Your browser does not support the canvas element.
        </canvas>
      </div>
    </div>
    """
  end
end
