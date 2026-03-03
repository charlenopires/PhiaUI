defmodule PhiaUi.Components.ImageUpload do
  @moduledoc """
  Image Upload Manager Component for Phoenix LiveView.

  Provides `image_upload/1` — a semantic wrapper over Phoenix LiveView's
  native file upload system (`live_file_input`). Renders a styled drop zone,
  image previews, progress bars, and entry removal buttons.

  ## Requirements

  The parent LiveView must configure uploads with `allow_upload/3` in `mount/3`.

  ## Example

      # In your LiveView mount/3:
      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:cover_image,
           accept: ~w(.jpg .jpeg .png .webp),
           max_entries: 1,
           max_file_size: 5_000_000
         )}
      end

      # In your template:
      <.image_upload
        upload={@uploads.cover_image}
        label="Imagem de capa"
        class="mt-4"
      />

  ## Handling cancel_upload

  Add this event handler to your LiveView to support entry removal:

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :cover_image, ref)}
      end

  ## Consuming uploads

  After form submission, consume entries with `consume_uploaded_entries/3`:

      defp consume_cover_image(socket) do
        consume_uploaded_entries(socket, :cover_image, fn %{path: path}, _entry ->
          dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", Path.basename(path)])
          File.cp!(path, dest)
          {:ok, "/uploads/" <> Path.basename(dest)}
        end)
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # image_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` returned by `allow_upload/3`"
  )

  attr(:label, :string,
    default: "Imagem de capa",
    doc: "Instructional text displayed inside the drop zone"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper"
  )

  @doc """
  Renders an image upload zone integrated with Phoenix LiveView's upload system.

  Displays a click-to-upload drop zone, live image previews, upload progress bars,
  and per-entry error messages. Syncs with `cancel_upload` events for entry removal.
  """
  def image_upload(assigns) do
    ~H"""
    <div class={cn(["space-y-3", @class])}>
      <%!-- Drop zone — clicking the label activates the hidden file input --%>
      <label
        for={@upload.ref}
        class="flex flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-input bg-muted/50 px-6 py-10 text-center cursor-pointer hover:bg-muted transition-colors"
      >
        <.icon name="upload-cloud" size={:lg} class="text-muted-foreground" />
        <span class="text-sm text-muted-foreground">{@label}</span>
        <%!-- live_file_input visually hidden but accessible (AC: sr-only) --%>
        <.live_file_input upload={@upload} class="sr-only" />
      </label>

      <%!-- Entry list — only rendered when there are entries (AC: empty state) --%>
      <div :if={@upload.entries != []} class="space-y-2">
        <div
          :for={entry <- @upload.entries}
          class="flex items-center gap-3 rounded-md border border-input bg-background p-3"
        >
          <%!-- Thumbnail preview (AC: w-20 h-20 object-cover rounded) --%>
          <div class="shrink-0">
            <.live_img_preview entry={entry} class="w-20 h-20 object-cover rounded" />
          </div>

          <%!-- File info + progress --%>
          <div class="flex-1 min-w-0 space-y-1.5">
            <%!-- Filename truncated (AC: nome do arquivo truncado) --%>
            <p class="text-sm font-medium truncate">{entry.client_name}</p>

            <%!-- Progress bar (AC: <progress value={entry.progress} max="100">) --%>
            <progress
              class="w-full h-1.5 rounded-full"
              value={entry.progress}
              max="100"
            >
            </progress>

            <%!-- Per-entry errors (AC: :too_large, :not_accepted, :too_many_files) --%>
            <p
              :for={err <- upload_errors(@upload, entry)}
              class="text-xs font-medium text-destructive"
            >
              {upload_error_message(err)}
            </p>
          </div>

          <%!-- Remove button (AC: phx-click="cancel_upload" phx-value-ref={entry.ref}) --%>
          <button
            type="button"
            phx-click="cancel_upload"
            phx-value-ref={entry.ref}
            aria-label={"Remover #{entry.client_name}"}
            class="shrink-0 inline-flex items-center justify-center rounded p-1 text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
          >
            <.icon name="x" size={:sm} />
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # AC: :too_large → "Arquivo muito grande", :not_accepted → "Formato não suportado",
  #     :too_many_files → "Limite de arquivos atingido"
  defp upload_error_message(:too_large), do: "Arquivo muito grande"
  defp upload_error_message(:not_accepted), do: "Formato não suportado"
  defp upload_error_message(:too_many_files), do: "Limite de arquivos atingido"
  defp upload_error_message(_other), do: "Erro no upload"
end
