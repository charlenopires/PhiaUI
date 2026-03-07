defmodule PhiaUi.Components.ImageGalleryUpload do
  @moduledoc """
  Multi-image upload with a grid thumbnail gallery.

  Provides `image_gallery_upload/1` — a `max_entries`-aware upload zone that
  renders selected images as live thumbnails in a responsive grid. Each
  thumbnail shows a remove button. An "Add more" cell is rendered while the
  entry limit has not been reached.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:gallery,
           accept: ~w(.jpg .jpeg .png .webp),
           max_entries: 6,
           max_file_size: 10_000_000
         )}
      end

  ## Basic usage

      <.image_gallery_upload
        upload={@uploads.gallery}
        label="Product images"
        on_cancel="cancel_upload"
      />

  ## Handling cancel

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :gallery, ref)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # image_gallery_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label rendered above the gallery grid."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text shown below the label."
  )

  attr(:cols, :integer,
    default: 4,
    doc: "Number of grid columns (3, 4, or 5)."
  )

  attr(:aspect, :string,
    default: "square",
    values: ~w(square video portrait),
    doc: "Thumbnail aspect ratio — `square` (1:1), `video` (16:9), `portrait` (3:4)."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name fired when the × remove button is clicked."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a grid of image thumbnails with an "Add more" cell.

  ## Examples

      <.image_gallery_upload upload={@uploads.gallery} label="Photos" />

      <.image_gallery_upload upload={@uploads.photos} cols={3} aspect="video" />
  """
  def image_gallery_upload(assigns) do
    entries = Map.get(assigns.upload, :entries, [])
    max = Map.get(assigns.upload, :max_entries, 10)
    can_add = length(entries) < max
    assigns = assign(assigns, entries: entries, can_add: can_add)

    ~H"""
    <div class={cn(["space-y-3", @class])}>
      <div :if={@label || @description} class="space-y-1">
        <p :if={@label} class="text-sm font-medium">{@label}</p>
        <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      </div>

      <%!-- Upload-level errors --%>
      <%= for err <- Map.get(@upload, :errors, []) do %>
        <p class="text-xs text-destructive">{humanize_error(err)}</p>
      <% end %>

      <div class={grid_class(@cols)}>
        <%!-- Existing entry thumbnails --%>
        <%= for entry <- @entries do %>
          <div class={cn(["relative group overflow-hidden rounded-md bg-muted border border-border", aspect_class(@aspect)])}>
            <%= if is_struct(entry, Phoenix.LiveView.UploadEntry) do %>
              <.live_img_preview entry={entry} class="w-full h-full object-cover" />
            <% else %>
              <div class="w-full h-full bg-muted flex items-center justify-center text-xs text-muted-foreground">{Map.get(entry, :client_name, "")}</div>
            <% end %>

            <%!-- Progress overlay while uploading --%>
            <div
              :if={entry.progress < 100}
              class="absolute inset-0 flex flex-col items-center justify-center bg-black/40 gap-1"
            >
              <span class="text-white text-xs font-medium tabular-nums">{entry.progress}%</span>
              <div class="w-3/4 h-1 bg-white/30 rounded-full overflow-hidden">
                <div class="h-full bg-white rounded-full transition-all" style={"width: #{entry.progress}%"}></div>
              </div>
            </div>

            <%!-- Remove button --%>
            <button
              type="button"
              phx-click={@on_cancel}
              phx-value-ref={entry.ref}
              aria-label={"Remove #{entry.client_name}"}
              class="absolute top-1 right-1 flex h-6 w-6 items-center justify-center rounded-full bg-black/60 text-white opacity-0 group-hover:opacity-100 transition-opacity hover:bg-black/80"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                   aria-hidden="true">
                <path d="M18 6 6 18M6 6l12 12" />
              </svg>
            </button>

            <%!-- Per-entry errors --%>
            <div :if={Map.get(entry, :errors, []) != []} class="absolute bottom-0 inset-x-0 bg-destructive/80 p-1">
              <p :for={err <- Map.get(entry, :errors, [])} class="text-[10px] text-white leading-tight">
                {humanize_error(err)}
              </p>
            </div>
          </div>
        <% end %>

        <%!-- "Add more" cell --%>
        <label
          :if={@can_add}
          class={cn([
            "relative cursor-pointer rounded-md border-2 border-dashed border-border",
            "flex flex-col items-center justify-center gap-1.5",
            "text-muted-foreground hover:border-primary hover:text-primary hover:bg-muted/40",
            "transition-colors",
            aspect_class(@aspect)
          ])}
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
               aria-hidden="true">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" x2="12" y1="3" y2="15" />
          </svg>
          <span class="text-xs font-medium">Add photo</span>
          <%= if is_struct(@upload, Phoenix.LiveView.UploadConfig) do %>
            <.live_file_input upload={@upload} class="sr-only" />
          <% end %>
        </label>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp grid_class(3), do: "grid grid-cols-3 gap-2"
  defp grid_class(5), do: "grid grid-cols-5 gap-2"
  defp grid_class(_), do: "grid grid-cols-4 gap-2"

  defp aspect_class("video"), do: "aspect-video"
  defp aspect_class("portrait"), do: "aspect-[3/4]"
  defp aspect_class(_), do: "aspect-square"

  defp humanize_error(:too_large), do: "File too large"
  defp humanize_error(:not_accepted), do: "Invalid type"
  defp humanize_error(:too_many_files), do: "Limit reached"
  defp humanize_error(other), do: to_string(other)
end
