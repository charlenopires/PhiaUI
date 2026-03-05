defmodule PhiaUi.Components.ImageUpload do
  @moduledoc """
  Image upload component for PhiaUI.

  Provides `image_upload/1` — a styled wrapper over Phoenix LiveView's native
  file upload system (`live_file_input`). Renders a click-to-upload drop zone,
  live image previews via `live_img_preview/1`, per-entry progress bars,
  per-entry error messages, and entry removal buttons.

  This component uses **zero custom JavaScript** — all upload behaviour is
  handled by Phoenix LiveView's built-in upload machinery. No JS hook is needed.

  ## When to use

  Use `image_upload/1` for any image attachment field in a form:

  - Profile / avatar upload
  - Product image gallery
  - Article cover image
  - Document attachment (with accept: ~w(.pdf .docx .xlsx))
  - Receipt / invoice photo capture

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3` in `mount/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:avatar,
           accept: ~w(.jpg .jpeg .png .webp .gif),
           max_entries: 1,
           max_file_size: 5_242_880  # 5 MB
         )}
      end

  Then pass `@uploads.avatar` as the `:upload` attribute.

  ## Basic example

      <.form for={@form} phx-submit="save_profile" phx-change="validate">
        <.image_upload
          upload={@uploads.avatar}
          label="Drag & drop or click to upload a profile photo"
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Multiple files example

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:product_images,
           accept: ~w(.jpg .jpeg .png .webp),
           max_entries: 6,
           max_file_size: 10_000_000
         )}
      end

      <.image_upload
        upload={@uploads.product_images}
        label="Upload up to 6 product images"
      />

  ## Handling entry cancellation

  Add this event handler to support the entry removal (×) button:

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :avatar, ref)}
      end

  The upload name (`:avatar`) must match the atom used in `allow_upload/3`.

  ## Consuming uploads after form submission

  After a successful `phx-submit`, consume entries with `consume_uploaded_entries/3`:

      def handle_event("save_profile", _params, socket) do
        urls =
          consume_uploaded_entries(socket, :avatar, fn %{path: tmp_path}, _entry ->
            dest = Path.join([:code.priv_dir(:my_app), "static", "uploads",
                              Path.basename(tmp_path) <> ".jpg"])
            File.cp!(tmp_path, dest)
            {:ok, "/uploads/" <> Path.basename(dest)}
          end)

        {:noreply, assign(socket, profile_image_url: List.first(urls))}
      end

  ## Error messages

  The component maps Phoenix LiveView upload error atoms to English strings:

  | Atom              | Message                       |
  |-------------------|-------------------------------|
  | `:too_large`      | "File too large"              |
  | `:not_accepted`   | "Unsupported file format"     |
  | `:too_many_files` | "File limit reached"          |
  | other             | "Upload error"                |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # image_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: """
    A `Phoenix.LiveView.UploadConfig` struct returned by `@uploads.field_name`.
    Provides entry list, progress, errors, and the file input reference.
    """
  )

  attr(:label, :string,
    default: "Click or drag & drop to upload",
    doc: "Instructional text displayed inside the drop zone"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper div"
  )

  @doc """
  Renders an image upload zone integrated with Phoenix LiveView's upload system.

  Renders:
  1. A click-to-upload drop zone (a `<label>` wrapping `live_file_input/1`)
  2. A list of accepted entries — each with a thumbnail preview, filename,
     progress bar, and a remove button
  3. Per-entry error messages for validation failures

  The drop zone is hidden from the visible file input (`sr-only`) so the
  entire styled `<label>` area acts as the upload trigger. This approach
  requires no custom JS — it is standard HTML form behaviour.
  """
  def image_upload(assigns) do
    ~H"""
    <div class={cn(["space-y-3", @class])}>
      <%!-- Drop zone: clicking the <label> activates the hidden file input.
           The `for={@upload.ref}` links the label to live_file_input's generated id. --%>
      <label
        for={@upload.ref}
        class="flex flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-input bg-muted/50 px-6 py-10 text-center cursor-pointer hover:bg-muted transition-colors"
      >
        <.icon name="upload-cloud" size={:lg} class="text-muted-foreground" />
        <span class="text-sm text-muted-foreground">{@label}</span>
        <%!-- live_file_input is visually hidden but accessible to keyboard and assistive tech.
             It must be rendered inside the <form> for LiveView to process it. --%>
        <.live_file_input upload={@upload} class="sr-only" />
      </label>

      <%!-- Entry list — only rendered when at least one file has been selected --%>
      <div :if={@upload.entries != []} class="space-y-2">
        <div
          :for={entry <- @upload.entries}
          class="flex items-center gap-3 rounded-md border border-input bg-background p-3"
        >
          <%!-- live_img_preview: renders a local object URL preview before the upload completes.
               This works for image entries only (accept: image/*). --%>
          <div class="shrink-0">
            <.live_img_preview entry={entry} class="w-20 h-20 object-cover rounded" />
          </div>

          <%!-- File info + progress --%>
          <div class="flex-1 min-w-0 space-y-1.5">
            <%!-- Filename truncated to prevent overflow on long filenames --%>
            <p class="text-sm font-medium truncate">{entry.client_name}</p>

            <%!-- Semantic <progress> element — browser renders a native progress bar.
                 The hook updates entry.progress (0–100) as bytes are uploaded. --%>
            <progress
              class="w-full h-1.5 rounded-full"
              value={entry.progress}
              max="100"
            >
            </progress>

            <%!-- Per-entry validation errors (:too_large, :not_accepted, :too_many_files) --%>
            <p
              :for={err <- upload_errors(@upload, entry)}
              class="text-xs font-medium text-destructive"
            >
              {upload_error_message(err)}
            </p>
          </div>

          <%!-- Remove button — fires "cancel_upload" with the entry's ref.
               The LiveView must handle: cancel_upload(socket, :upload_name, ref) --%>
          <button
            type="button"
            phx-click="cancel_upload"
            phx-value-ref={entry.ref}
            aria-label={"Remove #{entry.client_name}"}
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

  # Map LiveView upload error atoms to human-readable English strings.
  # These atoms are returned by upload_errors/2 (Phoenix.LiveView.Upload).
  defp upload_error_message(:too_large), do: "File too large"
  defp upload_error_message(:not_accepted), do: "Unsupported file format"
  defp upload_error_message(:too_many_files), do: "File limit reached"
  defp upload_error_message(_other), do: "Upload error"
end
