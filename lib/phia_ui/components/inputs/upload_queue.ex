defmodule PhiaUi.Components.UploadQueue do
  @moduledoc """
  Ordered upload queue showing per-file progress for multiple entries.

  Provides `upload_queue/1` — a list component that renders every entry in a
  Phoenix LiveView `UploadConfig` as a progress row. Each row shows a file-type
  icon, filename, progress bar, percentage, individual error messages, and a
  cancel button. Upload-level errors are shown at the top.

  ## When to use

  Use `upload_queue/1` when you need to upload multiple files simultaneously
  and want to show per-file progress for each — document managers, batch import
  tools, media libraries, or any interface where users upload several files at
  once and need visibility into each one.

  Compare with `file_upload/1` (drop zone + custom entry slot) — `upload_queue/1`
  renders the full queue itself with no drop zone.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:files,
           accept: :any,
           max_entries: 10,
           max_file_size: 50_000_000
         )}
      end

  ## Basic usage

      <%!-- Drop zone elsewhere; queue shows progress --%>
      <.upload_queue
        upload={@uploads.files}
        on_cancel="cancel_upload"
      />

  ## Combined with a trigger button

      <.upload_button upload={@uploads.files} label="Add files" />
      <.upload_queue upload={@uploads.files} on_cancel="cancel_upload" />

  ## Handling cancel

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :files, ref)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # upload_queue/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name fired when the × cancel button is clicked."
  )

  attr(:show_empty, :boolean,
    default: false,
    doc: "When true, renders an empty state message when there are no entries."
  )

  attr(:empty_label, :string,
    default: "No files selected",
    doc: "Text shown in the empty state when `show_empty` is true."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a multi-entry upload queue with per-file progress rows.

  ## Examples

      <.upload_queue upload={@uploads.imports} on_cancel="cancel_import" />

      <.upload_queue upload={@uploads.photos} show_empty={true} empty_label="Add photos above" />
  """
  def upload_queue(assigns) do
    entries = Map.get(assigns.upload, :entries, [])
    errors = Map.get(assigns.upload, :errors, [])
    assigns = assign(assigns, entries: entries, upload_errors: errors)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%!-- Upload-level errors --%>
      <div :if={@upload_errors != []} class="space-y-1">
        <p :for={err <- @upload_errors} class="text-xs text-destructive">
          {humanize_error(err)}
        </p>
      </div>

      <%!-- Empty state --%>
      <div
        :if={@entries == [] && @show_empty}
        class="flex items-center justify-center rounded-lg border border-dashed border-border p-6 text-sm text-muted-foreground"
      >
        {@empty_label}
      </div>

      <%!-- Queue rows --%>
      <.upload_queue_item
        :for={entry <- @entries}
        entry={entry}
        on_cancel={@on_cancel}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # upload_queue_item/1
  # ---------------------------------------------------------------------------

  attr(:entry, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadEntry` struct or compatible map."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name for the cancel button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the row."
  )

  @doc """
  Renders a single upload queue row with icon, filename, progress bar, and cancel.

  ## Example

      <.upload_queue_item entry={entry} on_cancel="cancel_upload" />
  """
  def upload_queue_item(assigns) do
    name = entry_field(assigns.entry, :client_name) || "Unknown file"
    progress = entry_field(assigns.entry, :progress) || 0
    ref = entry_field(assigns.entry, :ref)
    entry_errors = entry_field(assigns.entry, :errors) || []
    ext = name |> Path.extname() |> String.downcase()

    assigns =
      assign(assigns,
        name: name,
        progress: progress,
        ref: ref,
        entry_errors: entry_errors,
        ext: ext,
        done: progress >= 100
      )

    ~H"""
    <div class={cn(["flex items-center gap-3 rounded-lg border border-border bg-background p-3", @class])}>
      <%!-- File type badge --%>
      <div class={cn(["flex h-9 w-9 shrink-0 items-center justify-center rounded-md text-[9px] font-bold uppercase tracking-wide", ext_color(@ext)])}>
        {ext_label(@ext)}
      </div>

      <%!-- File info + progress --%>
      <div class="flex-1 min-w-0 space-y-1">
        <div class="flex items-center justify-between gap-2">
          <p class="text-sm font-medium truncate">{@name}</p>
          <span class={cn(["text-xs tabular-nums shrink-0", @done && "text-green-600 dark:text-green-400", !@done && "text-muted-foreground"])}>
            <%= if @done, do: "Done", else: "#{@progress}%" %>
          </span>
        </div>

        <div class="h-1.5 w-full overflow-hidden rounded-full bg-muted">
          <div
            class={cn([
              "h-full rounded-full transition-all duration-300",
              @done && "bg-green-500 dark:bg-green-400",
              !@done && @entry_errors == [] && "bg-primary",
              @entry_errors != [] && "bg-destructive"
            ])}
            style={"width: #{@progress}%"}
          ></div>
        </div>

        <%!-- Per-entry errors --%>
        <p :for={err <- @entry_errors} class="text-xs text-destructive">
          {humanize_error(err)}
        </p>
      </div>

      <%!-- Cancel button --%>
      <button
        :if={!@done}
        type="button"
        phx-click={@on_cancel}
        phx-value-ref={@ref}
        aria-label={"Cancel #{@name}"}
        class="shrink-0 flex h-6 w-6 items-center justify-center rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
             aria-hidden="true">
          <path d="M18 6 6 18M6 6l12 12" />
        </svg>
      </button>

      <%!-- Done checkmark --%>
      <div :if={@done && @entry_errors == []} class="shrink-0 flex h-6 w-6 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-green-600 dark:text-green-400" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <polyline points="20 6 9 17 4 12" />
        </svg>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp entry_field(entry, field) when is_struct(entry), do: Map.get(entry, field)
  defp entry_field(entry, field) when is_map(entry),
    do: Map.get(entry, field) || Map.get(entry, to_string(field))

  defp ext_label(".pdf"), do: "PDF"
  defp ext_label(".doc"), do: "DOC"
  defp ext_label(".docx"), do: "DOC"
  defp ext_label(".xls"), do: "XLS"
  defp ext_label(".xlsx"), do: "XLS"
  defp ext_label(".csv"), do: "CSV"
  defp ext_label(".zip"), do: "ZIP"
  defp ext_label(".txt"), do: "TXT"
  defp ext_label(".json"), do: "JSON"
  defp ext_label(".jpg"), do: "JPG"
  defp ext_label(".jpeg"), do: "JPG"
  defp ext_label(".png"), do: "PNG"
  defp ext_label(".gif"), do: "GIF"
  defp ext_label(".mp4"), do: "MP4"
  defp ext_label(".mp3"), do: "MP3"
  defp ext_label(ext), do: ext |> String.replace(".", "") |> String.upcase() |> String.slice(0, 4)

  defp ext_color(".pdf"), do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
  defp ext_color(e) when e in [".doc", ".docx"],
    do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
  defp ext_color(e) when e in [".xls", ".xlsx", ".csv"],
    do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp ext_color(e) when e in [".zip", ".rar"],
    do: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp ext_color(e) when e in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"],
    do: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400"
  defp ext_color(_), do: "bg-muted text-muted-foreground"

  defp humanize_error(:too_large), do: "File too large"
  defp humanize_error(:not_accepted), do: "Invalid file type"
  defp humanize_error(:too_many_files), do: "Too many files"
  defp humanize_error(other), do: to_string(other)
end
