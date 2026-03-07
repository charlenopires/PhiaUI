defmodule PhiaUi.Components.DocumentUpload do
  @moduledoc """
  Document-specific upload dropzone with file-type icons.

  Provides `document_upload/1` — a drag-and-drop zone tailored for non-image
  documents (PDF, DOCX, XLSX, CSV, ZIP, etc.). Each accepted entry is rendered
  via `document_upload_entry/1`, which displays the file type icon, name, size
  hint, a progress bar, and a remove button.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:docs,
           accept: ~w(.pdf .docx .xlsx .csv .zip .txt),
           max_entries: 5,
           max_file_size: 20_971_520  # 20 MB
         )}
      end

  ## Basic usage

      <.document_upload
        upload={@uploads.docs}
        label="Upload documents"
        accepted_types=".pdf, .docx, .xlsx"
        on_cancel="cancel_upload"
      />

      <%!-- Customised entry slot --%>
      <.document_upload upload={@uploads.docs} label="Attach files">
        <:entry :let={entry}>
          <.document_upload_entry entry={entry} on_cancel="cancel_upload" />
        </:entry>
      </.document_upload>

  ## Handling cancel

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :docs, ref)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # document_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:label, :string,
    default: "Upload documents",
    doc: "Heading displayed inside the drop zone."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered above the drop zone."
  )

  attr(:accepted_types, :string,
    default: nil,
    doc: "Human-readable accepted formats hint, e.g. `\".pdf, .docx, .xlsx\"`."
  )

  attr(:max_size_label, :string,
    default: nil,
    doc: "Human-readable max file size hint, e.g. `\"20 MB\"`."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name fired when the × remove button is clicked."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  slot(:entry,
    doc: """
    Custom slot for rendering each entry. Receives the entry via `:let`.
    Defaults to `<.document_upload_entry>` when not provided.
    """
  )

  @doc """
  Renders a document upload dropzone with file-type icons.

  ## Examples

      <.document_upload upload={@uploads.docs} accepted_types=".pdf, .docx" max_size_label="20 MB" />
  """
  def document_upload(assigns) do
    entries = Map.get(assigns.upload, :entries, [])
    drop_ref = Map.get(assigns.upload, :ref)
    assigns = assign(assigns, entries: entries, drop_ref: drop_ref)

    ~H"""
    <div class={cn(["space-y-3", @class])}>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>

      <%!-- Drop zone --%>
      <label
        class="flex flex-col items-center justify-center gap-3 rounded-lg border-2 border-dashed border-border bg-muted/30 p-8 text-center cursor-pointer hover:border-primary hover:bg-muted/50 transition-colors"
        phx-drop-target={@drop_ref}
      >
        <%!-- Document stack icon --%>
        <div class="flex -space-x-1">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-muted-foreground/50 translate-y-1 -rotate-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" /><path d="M14 2v4a2 2 0 0 0 2 2h4" />
          </svg>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-9 w-9 text-muted-foreground/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" /><path d="M14 2v4a2 2 0 0 0 2 2h4" />
          </svg>
        </div>

        <div>
          <p class="text-sm font-medium text-foreground">{@label}</p>
          <p class="text-xs text-muted-foreground mt-0.5">
            <span class="font-medium text-primary">Click to browse</span>
            {" or drag and drop"}
          </p>
          <p :if={@accepted_types || @max_size_label} class="text-xs text-muted-foreground mt-1">
            <%= [@accepted_types, @max_size_label && "up to #{@max_size_label}"] |> Enum.reject(&is_nil/1) |> Enum.join(" — ") %>
          </p>
        </div>

        <%= if is_struct(@upload, Phoenix.LiveView.UploadConfig) do %>
          <.live_file_input upload={@upload} class="sr-only" />
        <% end %>
      </label>

      <%!-- Upload-level errors --%>
      <%= for err <- Map.get(@upload, :errors, []) do %>
        <p class="text-xs text-destructive">{humanize_error(err)}</p>
      <% end %>

      <%!-- Entry list --%>
      <div :if={@entries != []} class="space-y-2">
        <%= for entry <- @entries do %>
          <%= if @entry != [] do %>
            {render_slot(@entry, entry)}
          <% else %>
            <.document_upload_entry entry={entry} on_cancel={@on_cancel} />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # document_upload_entry/1
  # ---------------------------------------------------------------------------

  attr(:entry, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadEntry` struct or compatible map."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name for the × remove button."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the entry row."
  )

  @doc """
  Renders a single document entry row with file-type icon, name, progress, and remove button.

  ## Example

      <.document_upload_entry entry={entry} on_cancel="cancel_upload" />
  """
  def document_upload_entry(assigns) do
    name = entry_field(assigns.entry, :client_name)
    ext = name |> Path.extname() |> String.downcase()
    assigns = assign(assigns, ext: ext, name: name)

    ~H"""
    <div class={cn(["flex items-center gap-3 rounded-lg border border-border bg-background p-3", @class])}>
      <%!-- File type badge --%>
      <div class={cn(["flex h-10 w-10 items-center justify-center rounded-md shrink-0 text-xs font-bold tracking-wide uppercase", ext_color(@ext)])}>
        {ext_label(@ext)}
      </div>

      <%!-- Info + progress --%>
      <div class="flex-1 min-w-0 space-y-1">
        <p class="text-sm font-medium truncate">{@name}</p>
        <div class="h-1.5 w-full rounded-full bg-muted overflow-hidden">
          <div
            class="h-full bg-primary rounded-full transition-all"
            style={"width: #{entry_field(@entry, :progress) || 0}%"}
          ></div>
        </div>
        <%= for err <- (entry_field(@entry, :errors) || []) do %>
          <p class="text-xs text-destructive">{humanize_error(err)}</p>
        <% end %>
      </div>

      <%!-- Progress % --%>
      <span class="text-xs text-muted-foreground tabular-nums shrink-0">
        {entry_field(@entry, :progress) || 0}%
      </span>

      <%!-- Remove button --%>
      <button
        type="button"
        phx-click={@on_cancel}
        phx-value-ref={entry_field(@entry, :ref)}
        aria-label={"Remove #{@name}"}
        class="shrink-0 flex h-7 w-7 items-center justify-center rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
             aria-hidden="true">
          <path d="M18 6 6 18M6 6l12 12" />
        </svg>
      </button>
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
  defp ext_label(".ppt"), do: "PPT"
  defp ext_label(".pptx"), do: "PPT"
  defp ext_label(".zip"), do: "ZIP"
  defp ext_label(".rar"), do: "RAR"
  defp ext_label(".txt"), do: "TXT"
  defp ext_label(".md"), do: "MD"
  defp ext_label(".json"), do: "JSON"
  defp ext_label(".xml"), do: "XML"
  defp ext_label(ext), do: ext |> String.replace(".", "") |> String.upcase() |> String.slice(0, 4)

  defp ext_color(".pdf"), do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
  defp ext_color(".doc"), do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
  defp ext_color(".docx"), do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
  defp ext_color(".xls"), do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp ext_color(".xlsx"), do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp ext_color(".csv"), do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
  defp ext_color(".ppt"), do: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
  defp ext_color(".pptx"), do: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
  defp ext_color(".zip"), do: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp ext_color(".rar"), do: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp ext_color(_), do: "bg-muted text-muted-foreground"

  defp humanize_error(:too_large), do: "File too large"
  defp humanize_error(:not_accepted), do: "Invalid file type"
  defp humanize_error(:too_many_files), do: "Too many files"
  defp humanize_error(other), do: to_string(other)
end
