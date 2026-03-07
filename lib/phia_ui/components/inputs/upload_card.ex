defmodule PhiaUi.Components.UploadCard do
  @moduledoc """
  Card for displaying a completed file upload.

  Provides `upload_card/1` — a self-contained card that represents a file that
  has already been uploaded (not a pending entry). Displays:

  - A file-type colour badge derived from the extension
  - Filename, file size (human-readable), and optional upload timestamp
  - Status badge (`:done` or `:error`)
  - Optional thumbnail preview for images
  - Optional download link and/or remove button

  ## When to use

  Use `upload_card/1` in **file lists, attachment panels, and document managers**
  where you want to show files that have already been saved server-side — not
  files mid-upload. For files being uploaded use `upload_progress/1`.

  ## Basic usage

      <.upload_card
        filename="invoice_q1_2026.pdf"
        size_bytes={248_320}
        on_remove="remove_file"
      />

      <.upload_card
        filename="product_photo.jpg"
        size_bytes={1_843_200}
        thumbnail_url={@file.url}
        href={@file.url}
        status={:done}
        uploaded_at="Mar 6, 2026"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # upload_card/1
  # ---------------------------------------------------------------------------

  attr(:filename, :string,
    required: true,
    doc: "The filename of the uploaded file."
  )

  attr(:size_bytes, :integer,
    default: nil,
    doc: "File size in bytes. Rendered as a human-readable string (KB, MB, GB)."
  )

  attr(:uploaded_at, :string,
    default: nil,
    doc: "Human-readable timestamp string shown below the filename."
  )

  attr(:status, :atom,
    default: :done,
    values: [:done, :error],
    doc: "`:done` shows a green badge, `:error` shows a red badge."
  )

  attr(:thumbnail_url, :string,
    default: nil,
    doc: "Image URL for inline thumbnail preview. Only rendered for image files."
  )

  attr(:href, :string,
    default: nil,
    doc: "Download URL. When set, renders a download icon link."
  )

  attr(:on_remove, :string,
    default: nil,
    doc: "LiveView event name fired when the trash/remove button is clicked."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the card wrapper."
  )

  @doc """
  Renders a card representing a completed file upload.

  ## Examples

      <.upload_card filename="report.pdf" size_bytes={512_000} href="/files/report.pdf" on_remove="remove_file" />

      <.upload_card filename="logo.png" size_bytes={98_304} thumbnail_url={@url} status={:done} />
  """
  def upload_card(assigns) do
    ext = assigns.filename |> Path.extname() |> String.downcase()
    assigns = assign(assigns, :ext, ext)

    ~H"""
    <div class={cn([
      "flex items-center gap-3 rounded-lg border border-border bg-card p-3 shadow-sm",
      @class
    ])}>
      <%!-- Thumbnail or file-type badge --%>
      <%= if @thumbnail_url do %>
        <img
          src={@thumbnail_url}
          alt={@filename}
          class="h-12 w-12 shrink-0 rounded-md object-cover border border-border"
        />
      <% else %>
        <div class={cn(["flex h-12 w-12 shrink-0 items-center justify-center rounded-md text-[10px] font-bold uppercase tracking-wide", ext_color(@ext)])}>
          {ext_label(@ext)}
        </div>
      <% end %>

      <%!-- Info --%>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium truncate">{@filename}</p>
        <div class="flex items-center gap-2 mt-0.5">
          <span :if={@size_bytes} class="text-xs text-muted-foreground">
            {format_bytes(@size_bytes)}
          </span>
          <span :if={@size_bytes && @uploaded_at} class="text-muted-foreground/50 text-xs">·</span>
          <span :if={@uploaded_at} class="text-xs text-muted-foreground">
            {@uploaded_at}
          </span>
        </div>
      </div>

      <%!-- Status badge --%>
      <span class={cn(["shrink-0 inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium", status_badge_class(@status)])}>
        {status_label(@status)}
      </span>

      <%!-- Download link --%>
      <a
        :if={@href}
        href={@href}
        download
        aria-label={"Download #{@filename}"}
        class="shrink-0 flex h-7 w-7 items-center justify-center rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
             aria-hidden="true">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" x2="12" y1="15" y2="3" />
        </svg>
      </a>

      <%!-- Remove button --%>
      <button
        :if={@on_remove}
        type="button"
        phx-click={@on_remove}
        aria-label={"Remove #{@filename}"}
        class="shrink-0 flex h-7 w-7 items-center justify-center rounded text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
             aria-hidden="true">
          <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" />
          <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
        </svg>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp format_bytes(nil), do: ""
  defp format_bytes(bytes) when bytes < 1_024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1_024, 1)} KB"
  defp format_bytes(bytes) when bytes < 1_073_741_824, do: "#{Float.round(bytes / 1_048_576, 1)} MB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / 1_073_741_824, 2)} GB"

  defp status_badge_class(:done), do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp status_badge_class(:error), do: "bg-destructive/10 text-destructive"

  defp status_label(:done), do: "Uploaded"
  defp status_label(:error), do: "Failed"

  defp ext_label(".pdf"), do: "PDF"
  defp ext_label(".doc"), do: "DOC"
  defp ext_label(".docx"), do: "DOC"
  defp ext_label(".xls"), do: "XLS"
  defp ext_label(".xlsx"), do: "XLS"
  defp ext_label(".csv"), do: "CSV"
  defp ext_label(".ppt"), do: "PPT"
  defp ext_label(".pptx"), do: "PPT"
  defp ext_label(".zip"), do: "ZIP"
  defp ext_label(".txt"), do: "TXT"
  defp ext_label(".json"), do: "JSON"
  defp ext_label(".mp4"), do: "MP4"
  defp ext_label(".mp3"), do: "MP3"
  defp ext_label(".jpg"), do: "JPG"
  defp ext_label(".jpeg"), do: "JPG"
  defp ext_label(".png"), do: "PNG"
  defp ext_label(".gif"), do: "GIF"
  defp ext_label(".webp"), do: "WEBP"
  defp ext_label(".svg"), do: "SVG"
  defp ext_label(ext), do: ext |> String.replace(".", "") |> String.upcase() |> String.slice(0, 4)

  defp ext_color(".pdf"), do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
  defp ext_color(e) when e in [".doc", ".docx"],
    do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
  defp ext_color(e) when e in [".xls", ".xlsx", ".csv"],
    do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp ext_color(e) when e in [".ppt", ".pptx"],
    do: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
  defp ext_color(e) when e in [".zip", ".rar"],
    do: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp ext_color(e) when e in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"],
    do: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400"
  defp ext_color(e) when e in [".mp4", ".mov", ".avi"],
    do: "bg-pink-100 text-pink-700 dark:bg-pink-900/30 dark:text-pink-400"
  defp ext_color(e) when e in [".mp3", ".wav", ".ogg"],
    do: "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-400"
  defp ext_color(_), do: "bg-muted text-muted-foreground"
end
