defmodule PhiaUi.Components.FileUpload do
  @moduledoc """
  File upload component for PhiaUI.

  Provides `file_upload/1` — a drag-and-drop file upload zone for any file type,
  and `file_upload_entry/1` — a file row with progress bar, error messages, and
  a cancel button.

  Unlike `image_upload/1` which is purpose-built for image previews,
  `file_upload/1` handles any file type, renders a prominent drop zone,
  and exposes slots for full customization of the entry list.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3` in `mount/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:documents,
           accept: ~w(.pdf .docx .xlsx),
           max_entries: 5,
           max_file_size: 10_485_760  # 10 MB
         )}
      end

  Then pass `@uploads.documents` as the `:upload` attribute.

  ## Basic example

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.file_upload upload={@uploads.documents} label="Upload Documents" accept=".pdf,.docx">
          <:empty>
            <p>Drag &amp; drop files here or click to browse</p>
          </:empty>
          <:file :let={entry}>
            <.file_upload_entry entry={entry} on_cancel="cancel_upload" />
          </:file>
        </.file_upload>
        <.button type="submit">Save</.button>
      </.form>

  ## Handling entry cancellation

  Add this event handler to support the cancel (×) button:

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :documents, ref)}
      end

  ## Consuming uploads after form submission

      def handle_event("save", _params, socket) do
        urls =
          consume_uploaded_entries(socket, :documents, fn %{path: tmp_path}, _entry ->
            dest = Path.join([:code.priv_dir(:my_app), "static", "uploads",
                              Path.basename(tmp_path)])
            File.cp!(tmp_path, dest)
            {:ok, "/uploads/" <> Path.basename(dest)}
          end)

        {:noreply, assign(socket, uploaded_files: urls)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # file_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    default: nil,
    doc: """
    A `Phoenix.LiveView.UploadConfig` struct returned by `@uploads.field_name`,
    or a plain map with `:ref` and `:entries` keys. When nil, only the drop zone
    and `:empty` slot are rendered.
    """
  )

  attr(:label, :string,
    default: "Upload Files",
    doc: "Label text rendered inside the `<label>` element above the drop zone."
  )

  attr(:accept, :string,
    default: nil,
    doc: "File type filter forwarded to the `<input type=\"file\" accept=...>` attribute."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper div."
  )

  slot(:empty,
    doc: "Content rendered inside the drop zone when no entries are present (or upload is nil)."
  )

  slot(:file,
    doc: """
    Content rendered for each entry in `upload.entries`. Receives each entry as
    its `:let` value. Use `<.file_upload_entry entry={entry} on_cancel=\"cancel_upload\" />`
    inside this slot for the default row rendering.
    """
  )

  @doc """
  Renders a drag-and-drop file upload zone for any file type.

  Renders:
  1. A `<label>` / hidden `<input type="file">` pair as the clickable trigger.
  2. A styled drop zone with `phx-drop-target` bound when `upload.ref` is present.
  3. An optional file list when `upload.entries` is non-empty, rendered via the
     `:file` slot.
  """
  def file_upload(assigns) do
    entries = get_entries(assigns.upload)
    drop_target_ref = get_ref(assigns.upload)
    assigns = assign(assigns, entries: entries, drop_target_ref: drop_target_ref)

    ~H"""
    <div class={cn(["file-upload-wrapper", @class])}>
      <%!-- Section label (not a <label> wrapping the input — live_file_input auto-wires itself) --%>
      <p class="block text-sm font-medium text-foreground mb-2">{@label}</p>

      <%!-- Drop zone — phx-drop-target is only added when upload.ref is available --%>
      <label
        class="drop-zone flex flex-col items-center justify-center gap-3 border-2 border-dashed border-border rounded-lg p-8 text-center text-muted-foreground hover:border-primary hover:bg-muted/40 transition-colors cursor-pointer"
        phx-drop-target={@drop_target_ref}
      >
        <%!-- Upload icon --%>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-muted-foreground/50" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" x2="12" y1="3" y2="15"/>
        </svg>

        <%!-- Slot content or default message --%>
        <%= if @empty != [] do %>
          {render_slot(@empty)}
        <% else %>
          <span class="text-sm">
            <span class="font-medium text-primary">Click to upload</span>
            <span class="text-muted-foreground"> or drag and drop</span>
          </span>
        <% end %>

        <%!-- Live file input (Phoenix-wired) or plain fallback --%>
        <%= if @upload != nil do %>
          <.live_file_input upload={@upload} class="sr-only" />
        <% else %>
          <input type="file" class="sr-only" accept={@accept} />
        <% end %>
      </label>

      <%!-- Per-upload validation errors --%>
      <%= if @upload != nil do %>
        <p :for={err <- upload_level_errors(@upload)}
           class="text-xs text-destructive mt-1">
          {humanize_upload_error(err)}
        </p>
      <% end %>

      <%!-- File list — only rendered when upload has at least one entry --%>
      <div :if={length(@entries) > 0} class="mt-4 space-y-2">
        <%= for entry <- @entries do %>
          <%= render_slot(@file, entry) %>
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # file_upload_entry/1
  # ---------------------------------------------------------------------------

  attr(:entry, :any,
    required: true,
    doc: """
    A `Phoenix.LiveView.UploadEntry` struct or a plain map with at least:
    `:client_name`, `:progress` (0–100), `:ref`, and `:errors` keys.
    """
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "The LiveView event name fired when the cancel button is clicked."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the entry row div."
  )

  @doc """
  Renders a single file entry row with filename, progress bar, error messages,
  and a cancel button.

  The cancel button emits `phx-click={@on_cancel}` with `phx-value-ref` set to
  the entry's `:ref`. The LiveView must handle this event:

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :documents, ref)}
      end
  """
  def file_upload_entry(assigns) do
    assigns =
      assign(assigns,
        name: entry_field(assigns.entry, :client_name),
        progress: entry_field(assigns.entry, :progress) || 0,
        ref: entry_field(assigns.entry, :ref),
        errors: entry_field(assigns.entry, :errors) || []
      )

    ~H"""
    <div class={cn(["flex items-center gap-3 p-3 border border-border rounded-lg bg-background", @class])}>
      <div class="flex-1 min-w-0">
        <%!-- Filename truncated to avoid overflow on long names --%>
        <p class="text-sm font-medium text-foreground truncate">{@name}</p>

        <%!-- Progress bar track + fill --%>
        <div class="mt-1 h-1.5 w-full bg-muted rounded-full overflow-hidden">
          <div
            class="h-full bg-primary transition-all"
            style={"width: #{@progress}%"}
          ></div>
        </div>

        <%!-- Per-entry validation error messages --%>
        <p :for={error <- @errors} class="text-xs text-destructive mt-1">{error}</p>
      </div>

      <%!-- Cancel / remove button --%>
      <button
        type="button"
        phx-click={@on_cancel}
        phx-value-ref={@ref}
        aria-label="Cancel upload"
        class="shrink-0 inline-flex items-center justify-center w-6 h-6 rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
      >
        &times;
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Extracts entries list from the upload config (struct or plain map), or returns [].
  defp get_entries(nil), do: []

  defp get_entries(upload) do
    Map.get(upload, :entries) || []
  end

  # Extracts the drop target ref from the upload config, or returns nil.
  defp get_ref(nil), do: nil

  defp get_ref(upload) do
    Map.get(upload, :ref)
  end

  # Reads a field from either a struct (dot access) or a plain map (bracket access).
  # This allows the component to work with both real LiveView UploadEntry structs
  # and plain maps used in tests.
  defp entry_field(entry, field) when is_struct(entry) do
    Map.get(entry, field)
  end

  defp entry_field(entry, field) when is_map(entry) do
    Map.get(entry, field) || Map.get(entry, to_string(field))
  end

  # Extracts upload-level errors from the upload config (not per-entry errors).
  defp upload_level_errors(nil), do: []
  defp upload_level_errors(upload), do: Map.get(upload, :errors) || []

  # Translates Phoenix.LiveView upload error atoms to human-readable strings.
  defp humanize_upload_error(:too_large), do: "File is too large"
  defp humanize_upload_error(:too_many_files), do: "Too many files selected"
  defp humanize_upload_error(:not_accepted), do: "File type is not accepted"
  defp humanize_upload_error(other), do: to_string(other)
end
