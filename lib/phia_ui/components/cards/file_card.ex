defmodule PhiaUi.Components.FileCard do
  @moduledoc """
  File attachment card with type-based icon and color coding.

  Displays a file's name, size, upload date, and a type-specific icon.
  Supports two layout variants: `:default` (icon + stacked info) and
  `:compact` (single row, suitable for lists or tables).
  File type is automatically detected from the file extension.

  ## Supported file types and icon colors

  | Extension(s)                | Detected type | Icon colour  |
  |-----------------------------|---------------|--------------|
  | `.pdf`                      | `:pdf`        | Red          |
  | `.doc`, `.docx`             | `:doc`        | Blue         |
  | `.xls`, `.xlsx`             | `:xls`        | Emerald      |
  | `.ppt`, `.pptx`             | `:ppt`        | Orange       |
  | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp` | `:image` | Violet |
  | `.zip`, `.rar`, `.tar`, `.gz` | `:archive` | Yellow       |
  | `.mp3`, `.wav`, `.mp4`, `.mov` | `:media`  | Pink         |
  | Anything else               | `:default`    | Muted        |

  ## Layout variants

  - `:default` — icon block on the left, filename + extension badge on top,
    size and date below. Actions slot wraps below the info block.
  - `:compact` — single row: icon (smaller, 36×36) + filename + size/date
    inline. Actions slot stays in the row.

  ## Examples

      <%!-- PDF attachment in default layout --%>
      <.file_card filename="report-q1.pdf" size="2.4 MB" uploaded_at="Mar 6, 2026">
        <:actions>
          <.button size={:sm} variant={:outline} href="/files/report-q1.pdf" download>
            Download
          </.button>
        </:actions>
      </.file_card>

      <%!-- Compact list row --%>
      <.file_card filename="presentation.pptx" size="8.1 MB" variant={:compact} />

      <%!-- File list from assigns --%>
      <div class="space-y-2">
        <.file_card
          :for={file <- @attachments}
          filename={file.name}
          size={file.human_size}
          uploaded_at={file.inserted_at_label}
          href={file.download_url}
        />
      </div>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:filename, :string, required: true, doc: "File name including extension")
  attr(:size, :string, default: nil, doc: "Human-readable file size (e.g. '2.4 MB')")
  attr(:uploaded_at, :string, default: nil, doc: "Upload date/time label")
  attr(:href, :string, default: nil, doc: "Download link for the file")

  attr(:variant, :atom,
    default: :default,
    values: [:default, :compact],
    doc: "Layout variant: :default (stacked) or :compact (single row)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the card element")

  slot(:actions, doc: "Action buttons (download, delete, share, etc.)")

  @doc """
  Renders a file attachment card.

  The card layout contains:
  - A colored icon block (auto-detected from `filename` extension).
  - The `filename` with a monospace extension badge (e.g. "PDF", "XLSX").
  - Optional `size` and `uploaded_at` metadata labels.
  - An optional `:actions` slot for download, delete, or share buttons.

  When `href` is set, the filename renders as a download link. When no
  `href` is provided, the filename is a plain `<span>`.

  ## Examples

      <%!-- PDF attachment --%>
      <.file_card filename="invoice.pdf" size="1.2 MB" uploaded_at="Mar 6, 2026">
        <:actions>
          <.button size={:sm} variant={:outline}>Download</.button>
        </:actions>
      </.file_card>

      <%!-- Compact single-row layout --%>
      <.file_card filename="data.xlsx" size="512 KB" variant={:compact} />

      <%!-- With download link --%>
      <.file_card
        filename="contract.docx"
        size="320 KB"
        href="/downloads/contract.docx"
        uploaded_at="2 days ago"
      />
  """
  def file_card(assigns) do
    assigns = assign(assigns, :ftype, file_type(assigns.filename))
    assigns = assign(assigns, :ext_label, ext_label(assigns.filename))

    ~H"""
    <.card class={cn([@class])} {@rest}>
      <.card_content class={content_padding(@variant)}>
        <div class={layout_class(@variant)}>
          <%!-- Icon block --%>
          <div class={cn(["rounded-lg flex items-center justify-center shrink-0", icon_size(@variant), type_bg(@ftype)])}>
            <.icon name={type_icon_name(@ftype)} size={:md} />
          </div>

          <%!-- File info --%>
          <div class={cn(["min-w-0", info_flex(@variant)])}>
            <div class={cn(["flex items-center gap-2", name_row_class(@variant)])}>
              <a
                :if={@href}
                href={@href}
                download
                class="hover:underline truncate text-sm font-medium"
              >
                {@filename}
              </a>
              <span :if={!@href} class="truncate text-sm font-medium">{@filename}</span>
              <span class="shrink-0 rounded px-1 py-0.5 text-xs font-mono bg-muted text-muted-foreground uppercase">
                {@ext_label}
              </span>
            </div>

            <div :if={@variant == :default} class="flex items-center gap-3 mt-1">
              <span :if={@size} class="text-xs text-muted-foreground">{@size}</span>
              <span :if={@uploaded_at} class="text-xs text-muted-foreground">{@uploaded_at}</span>
            </div>

            <div :if={@variant == :compact} class="flex items-center gap-2 text-xs text-muted-foreground">
              <span :if={@size}>{@size}</span>
              <span :if={@size && @uploaded_at} class="text-muted-foreground/40">·</span>
              <span :if={@uploaded_at}>{@uploaded_at}</span>
            </div>
          </div>

          <%!-- Actions --%>
          <div :if={@actions != []} class="shrink-0">
            {render_slot(@actions)}
          </div>
        </div>
      </.card_content>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — layout
  # ---------------------------------------------------------------------------

  defp content_padding(:default), do: "p-4"
  defp content_padding(:compact), do: "p-3"

  defp layout_class(:default), do: "flex flex-col gap-3"
  defp layout_class(:compact), do: "flex items-center gap-3"

  defp icon_size(:default), do: "w-12 h-12"
  defp icon_size(:compact), do: "w-9 h-9"

  defp info_flex(:default), do: "w-full"
  defp info_flex(:compact), do: "flex-1"

  defp name_row_class(:default), do: "flex-wrap"
  defp name_row_class(:compact), do: "flex-nowrap"

  # ---------------------------------------------------------------------------
  # Private helpers — file type detection
  # ---------------------------------------------------------------------------

  defp ext_label(filename) do
    filename |> Path.extname() |> String.trim_leading(".") |> String.upcase()
  end

  defp file_type(filename) do
    filename |> Path.extname() |> String.downcase() |> ext_to_type()
  end

  defp ext_to_type(".pdf"), do: :pdf
  defp ext_to_type(".doc"), do: :doc
  defp ext_to_type(".docx"), do: :doc
  defp ext_to_type(".xls"), do: :xls
  defp ext_to_type(".xlsx"), do: :xls
  defp ext_to_type(".ppt"), do: :ppt
  defp ext_to_type(".pptx"), do: :ppt
  defp ext_to_type(ext) when ext in [".jpg", ".jpeg", ".png", ".gif", ".webp"], do: :image
  defp ext_to_type(ext) when ext in [".zip", ".rar", ".tar", ".gz"], do: :archive
  defp ext_to_type(ext) when ext in [".mp3", ".wav", ".mp4", ".mov"], do: :media
  defp ext_to_type(_), do: :default

  defp type_bg(:pdf), do: "bg-red-100 text-red-600"
  defp type_bg(:doc), do: "bg-blue-100 text-blue-600"
  defp type_bg(:xls), do: "bg-emerald-100 text-emerald-600"
  defp type_bg(:ppt), do: "bg-orange-100 text-orange-600"
  defp type_bg(:image), do: "bg-violet-100 text-violet-600"
  defp type_bg(:archive), do: "bg-yellow-100 text-yellow-600"
  defp type_bg(:media), do: "bg-pink-100 text-pink-600"
  defp type_bg(:default), do: "bg-muted text-muted-foreground"

  defp type_icon_name(:pdf), do: "file-text"
  defp type_icon_name(:doc), do: "file-text"
  defp type_icon_name(:xls), do: "table"
  defp type_icon_name(:ppt), do: "presentation"
  defp type_icon_name(:image), do: "image"
  defp type_icon_name(:archive), do: "archive"
  defp type_icon_name(:media), do: "play-circle"
  defp type_icon_name(:default), do: "file"
end
