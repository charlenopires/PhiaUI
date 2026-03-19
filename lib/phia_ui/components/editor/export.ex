defmodule PhiaUi.Components.Editor.Export do
  @moduledoc """
  Export Suite — 6 components for importing, exporting, and printing editor content.

  Provides dialogs and controls for document export (HTML, Markdown, PDF, DOCX,
  LaTeX, TXT), import (drag-and-drop file upload), print preview, template
  gallery, and page setup configuration.

  ## Components

  - `export_dialog/1`     — format selection radio buttons + Export action
  - `print_preview/1`     — page-sized white frame for print preview
  - `download_button/1`   — single-click download button with format icon
  - `import_dialog/1`     — drag-and-drop zone + file input for importing
  - `template_gallery/1`  — grid of document template cards
  - `page_setup_dialog/1` — page size, orientation, and margin controls
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. export_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :formats, :list, default: [:html, :markdown, :pdf, :docx, :latex, :txt]
  attr :selected_format, :atom, default: :html
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an export dialog with format selection and an Export button.

  Each format is displayed as a radio button. Fires `phx-click="export:run"`
  with the selected format on export.

  ## Example

      <.export_dialog id="export" visible={@show_export} selected_format={@export_format} />
  """
  def export_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <div class="w-full max-w-md rounded-xl border border-border bg-background p-6 shadow-lg">
        <div class="mb-4 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            <h3 class="text-base font-semibold text-foreground">Export Document</h3>
          </div>
          <button
            type="button"
            phx-click="export:close"
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div class="mb-6 space-y-2">
          <label
            :for={fmt <- @formats}
            class={cn([
              "flex cursor-pointer items-center gap-3 rounded-lg border px-4 py-3 transition-colors",
              fmt == @selected_format && "border-primary bg-primary/5",
              fmt != @selected_format && "border-border hover:bg-muted/50"
            ])}
          >
            <input
              type="radio"
              name="format"
              value={fmt}
              checked={fmt == @selected_format}
              phx-click="export:format"
              phx-value-format={fmt}
              phx-value-id={@id}
              class="h-4 w-4 border-border text-primary focus:ring-primary"
            />
            <div>
              <span class="text-sm font-medium text-foreground">{format_label(fmt)}</span>
              <p class="text-xs text-muted-foreground">{format_description(fmt)}</p>
            </div>
          </label>
        </div>

        <div class="flex justify-end gap-2">
          <button
            type="button"
            phx-click="export:close"
            phx-value-id={@id}
            class="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Cancel
          </button>
          <button
            type="button"
            phx-click="export:run"
            phx-value-format={@selected_format}
            phx-value-id={@id}
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Export
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp format_label(:html), do: "HTML"
  defp format_label(:markdown), do: "Markdown"
  defp format_label(:pdf), do: "PDF"
  defp format_label(:docx), do: "Word (DOCX)"
  defp format_label(:latex), do: "LaTeX"
  defp format_label(:txt), do: "Plain Text"
  defp format_label(fmt), do: fmt |> to_string() |> String.upcase()

  defp format_description(:html), do: "Web-ready HTML with styles"
  defp format_description(:markdown), do: "Lightweight markup for developers"
  defp format_description(:pdf), do: "Portable document for sharing"
  defp format_description(:docx), do: "Microsoft Word compatible"
  defp format_description(:latex), do: "Academic typesetting format"
  defp format_description(:txt), do: "Plain text without formatting"
  defp format_description(_), do: ""

  # ============================================================================
  # 2. print_preview/1
  # ============================================================================

  attr :id, :string, required: true
  attr :content, :string, default: ""
  attr :page_size, :atom, default: :a4, values: [:a4, :letter, :legal]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a page-sized white frame for print preview.

  The frame dimensions match the selected page size. Content is displayed
  inside with print-friendly margins.

  ## Example

      <.print_preview id="preview" content={@html_content} page_size={:letter} />
  """
  def print_preview(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-start justify-center overflow-auto bg-muted/30 p-8",
        @class
      ])}
      {@rest}
    >
      <div class={cn([
        "bg-white shadow-lg",
        page_size_class(@page_size)
      ])}>
        <div class="prose prose-sm max-w-none p-12 text-black dark:text-black">
          {Phoenix.HTML.raw(@content)}
        </div>
      </div>
    </div>
    """
  end

  defp page_size_class(:a4), do: "w-[210mm] min-h-[297mm]"
  defp page_size_class(:letter), do: "w-[8.5in] min-h-[11in]"
  defp page_size_class(:legal), do: "w-[8.5in] min-h-[14in]"

  # ============================================================================
  # 3. download_button/1
  # ============================================================================

  attr :editor_id, :string, required: true
  attr :format, :atom, default: :html
  attr :label, :string, default: "Download"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a download button that triggers export for the given editor and format.

  ## Example

      <.download_button editor_id="my-editor" format={:markdown} label="Download MD" />
  """
  def download_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="export:download"
      phx-value-editor-id={@editor_id}
      phx-value-format={@format}
      class={cn([
        "inline-flex items-center gap-2 rounded-lg border border-border bg-background px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted",
        @class
      ])}
      {@rest}
    >
      <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
        <polyline points="7 10 12 15 17 10" />
        <line x1="12" y1="15" x2="12" y2="3" />
      </svg>
      {@label}
    </button>
    """
  end

  # ============================================================================
  # 4. import_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :accepted_types, :list, default: [".html", ".md", ".txt", ".docx"]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an import dialog with a drag-and-drop zone and file input.

  Accepts files of the types listed in `:accepted_types`. Fires
  `phx-click="import:file"` when a file is selected.

  ## Example

      <.import_dialog id="import" visible={@show_import} />
  """
  def import_dialog(assigns) do
    assigns = assign(assigns, :accept_string, Enum.join(assigns.accepted_types, ","))

    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <div class="w-full max-w-md rounded-xl border border-border bg-background p-6 shadow-lg">
        <div class="mb-4 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
              <polyline points="17 8 12 3 7 8" />
              <line x1="12" y1="3" x2="12" y2="15" />
            </svg>
            <h3 class="text-base font-semibold text-foreground">Import Document</h3>
          </div>
          <button
            type="button"
            phx-click="import:close"
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <%!-- Drop zone --%>
        <label
          for={"#{@id}-file"}
          class="flex cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed border-border px-6 py-10 transition-colors hover:border-primary/50 hover:bg-muted/50"
        >
          <svg class="mb-3 h-10 w-10 text-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" y1="3" x2="12" y2="15" />
          </svg>
          <p class="mb-1 text-sm font-medium text-foreground">
            Drop file here or click to browse
          </p>
          <p class="text-xs text-muted-foreground">
            Supported: {Enum.join(@accepted_types, ", ")}
          </p>
          <input
            type="file"
            id={"#{@id}-file"}
            name="file"
            accept={@accept_string}
            class="sr-only"
            phx-change="import:file"
            phx-value-id={@id}
          />
        </label>

        <div class="mt-4 flex justify-end">
          <button
            type="button"
            phx-click="import:close"
            phx-value-id={@id}
            class="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 5. template_gallery/1
  # ============================================================================

  attr :id, :string, required: true
  attr :templates, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a grid of document template cards.

  Each item in `:templates` should be a map with `:name`, `:description`,
  `:thumbnail` (URL or nil), and `:id` keys.

  ## Example

      <.template_gallery id="tpl" templates={[
        %{id: "blank", name: "Blank", description: "Empty document", thumbnail: nil},
        %{id: "report", name: "Report", description: "Business report template", thumbnail: "/img/report.png"}
      ]} />
  """
  def template_gallery(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4",
        @class
      ])}
      {@rest}
    >
      <button
        :for={tpl <- @templates}
        type="button"
        phx-click="template:select"
        phx-value-template-id={tpl[:id] || tpl["id"]}
        class="group flex flex-col items-start rounded-xl border border-border bg-background p-3 text-left transition-all hover:border-primary/50 hover:shadow-md"
      >
        <div class="mb-3 flex h-28 w-full items-center justify-center overflow-hidden rounded-lg bg-muted">
          <img
            :if={tpl[:thumbnail] || tpl["thumbnail"]}
            src={tpl[:thumbnail] || tpl["thumbnail"]}
            alt={tpl[:name] || tpl["name"]}
            class="h-full w-full object-cover"
          />
          <svg
            :if={!(tpl[:thumbnail] || tpl["thumbnail"])}
            class="h-10 w-10 text-muted-foreground/50"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
            <polyline points="14 2 14 8 20 8" />
          </svg>
        </div>
        <span class="text-sm font-medium text-foreground group-hover:text-primary">
          {tpl[:name] || tpl["name"]}
        </span>
        <p class="mt-0.5 text-xs text-muted-foreground">
          {tpl[:description] || tpl["description"]}
        </p>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 6. page_setup_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :page_size, :atom, default: :a4
  attr :orientation, :atom, default: :portrait, values: [:portrait, :landscape]
  attr :margins, :map, default: %{}
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a page setup dialog with size, orientation, and margin controls.

  ## Example

      <.page_setup_dialog
        id="page-setup"
        visible={@show_page_setup}
        page_size={@page_size}
        orientation={@orientation}
        margins={%{top: 1, bottom: 1, left: 1, right: 1}}
      />
  """
  def page_setup_dialog(assigns) do
    assigns =
      assigns
      |> assign(:margin_top, Map.get(assigns.margins, :top, Map.get(assigns.margins, "top", 1)))
      |> assign(:margin_bottom, Map.get(assigns.margins, :bottom, Map.get(assigns.margins, "bottom", 1)))
      |> assign(:margin_left, Map.get(assigns.margins, :left, Map.get(assigns.margins, "left", 1)))
      |> assign(:margin_right, Map.get(assigns.margins, :right, Map.get(assigns.margins, "right", 1)))

    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <div class="w-full max-w-sm rounded-xl border border-border bg-background p-6 shadow-lg">
        <div class="mb-4 flex items-center justify-between">
          <h3 class="text-base font-semibold text-foreground">Page Setup</h3>
          <button
            type="button"
            phx-click="page-setup:close"
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <form phx-submit="page-setup:apply" phx-value-id={@id} class="space-y-4">
          <%!-- Page size --%>
          <div>
            <label for={"#{@id}-size"} class="mb-1 block text-xs font-medium text-muted-foreground">Page Size</label>
            <select
              id={"#{@id}-size"}
              name="page_size"
              class="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            >
              <option value="a4" selected={@page_size == :a4}>A4 (210 x 297 mm)</option>
              <option value="letter" selected={@page_size == :letter}>Letter (8.5 x 11 in)</option>
              <option value="legal" selected={@page_size == :legal}>Legal (8.5 x 14 in)</option>
            </select>
          </div>

          <%!-- Orientation --%>
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Orientation</span>
            <div class="flex gap-2">
              <label class={cn([
                "flex flex-1 cursor-pointer items-center justify-center gap-2 rounded-lg border px-3 py-2 text-sm transition-colors",
                @orientation == :portrait && "border-primary bg-primary/5 text-primary",
                @orientation != :portrait && "border-border text-foreground hover:bg-muted"
              ])}>
                <input type="radio" name="orientation" value="portrait" checked={@orientation == :portrait} class="sr-only" />
                <svg class="h-4 w-4" viewBox="0 0 16 20" fill="none" stroke="currentColor" stroke-width="1.5">
                  <rect x="1" y="1" width="14" height="18" rx="1" />
                </svg>
                Portrait
              </label>
              <label class={cn([
                "flex flex-1 cursor-pointer items-center justify-center gap-2 rounded-lg border px-3 py-2 text-sm transition-colors",
                @orientation == :landscape && "border-primary bg-primary/5 text-primary",
                @orientation != :landscape && "border-border text-foreground hover:bg-muted"
              ])}>
                <input type="radio" name="orientation" value="landscape" checked={@orientation == :landscape} class="sr-only" />
                <svg class="h-4 w-4" viewBox="0 0 20 16" fill="none" stroke="currentColor" stroke-width="1.5">
                  <rect x="1" y="1" width="18" height="14" rx="1" />
                </svg>
                Landscape
              </label>
            </div>
          </div>

          <%!-- Margins --%>
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Margins (inches)</span>
            <div class="grid grid-cols-2 gap-2">
              <div>
                <label for={"#{@id}-mt"} class="text-[10px] text-muted-foreground">Top</label>
                <input
                  type="number"
                  id={"#{@id}-mt"}
                  name="margin_top"
                  value={@margin_top}
                  step="0.25"
                  min="0"
                  class="w-full rounded border border-border bg-background px-2 py-1 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                />
              </div>
              <div>
                <label for={"#{@id}-mb"} class="text-[10px] text-muted-foreground">Bottom</label>
                <input
                  type="number"
                  id={"#{@id}-mb"}
                  name="margin_bottom"
                  value={@margin_bottom}
                  step="0.25"
                  min="0"
                  class="w-full rounded border border-border bg-background px-2 py-1 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                />
              </div>
              <div>
                <label for={"#{@id}-ml"} class="text-[10px] text-muted-foreground">Left</label>
                <input
                  type="number"
                  id={"#{@id}-ml"}
                  name="margin_left"
                  value={@margin_left}
                  step="0.25"
                  min="0"
                  class="w-full rounded border border-border bg-background px-2 py-1 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                />
              </div>
              <div>
                <label for={"#{@id}-mr"} class="text-[10px] text-muted-foreground">Right</label>
                <input
                  type="number"
                  id={"#{@id}-mr"}
                  name="margin_right"
                  value={@margin_right}
                  step="0.25"
                  min="0"
                  class="w-full rounded border border-border bg-background px-2 py-1 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                />
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-2">
            <button
              type="button"
              phx-click="page-setup:close"
              phx-value-id={@id}
              class="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
            >
              Apply
            </button>
          </div>
        </form>
      </div>
    </div>
    """
  end
end
