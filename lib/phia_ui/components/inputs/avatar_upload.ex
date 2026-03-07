defmodule PhiaUi.Components.AvatarUpload do
  @moduledoc """
  Circular or square profile photo uploader with overlay edit icon.

  Provides `avatar_upload/1` — a compact click-to-upload zone designed for
  profile pictures and avatars. When an existing photo URL is provided, it is
  shown as the background image with a semi-transparent overlay containing a
  camera icon on hover. When a new file is selected via LiveView's upload
  system, the `live_img_preview/1` helper renders an instant local preview.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:avatar,
           accept: ~w(.jpg .jpeg .png .webp .gif),
           max_entries: 1,
           max_file_size: 5_242_880
         )}
      end

  ## Basic usage

      <%!-- Profile photo upload --%>
      <.avatar_upload
        upload={@uploads.avatar}
        current_url={@user.avatar_url}
        on_cancel="cancel_avatar"
      />

  ## With shape and size variants

      <.avatar_upload
        upload={@uploads.avatar}
        current_url={@user.avatar_url}
        shape="square"
        size="lg"
      />

  ## Handling cancel

      def handle_event("cancel_avatar", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :avatar, ref)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # avatar_upload/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:current_url, :string,
    default: nil,
    doc: "URL of the currently saved photo. Shown as background until a new file is selected."
  )

  attr(:shape, :string,
    default: "circle",
    values: ~w(circle square),
    doc: "Shape of the upload zone — `circle` (rounded-full) or `square` (rounded-lg)."
  )

  attr(:size, :string,
    default: "md",
    values: ~w(sm md lg xl),
    doc: "Controls the width/height of the upload zone."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name fired when the remove (×) button is clicked."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a profile photo upload zone with optional existing image preview.

  Layout:
  1. If entries exist → `live_img_preview/1` of the first pending entry + remove button
  2. If no entries → click-to-upload zone showing `current_url` (or a placeholder icon)
  3. In both cases, a camera overlay icon is shown on hover

  ## Examples

      <.avatar_upload upload={@uploads.avatar} current_url={@user.photo_url} />

      <.avatar_upload upload={@uploads.avatar} shape="square" size="lg" />
  """
  def avatar_upload(assigns) do
    entries = Map.get(assigns.upload, :entries, [])
    assigns = assign(assigns, :entries, entries)

    ~H"""
    <div class={cn(["relative inline-flex shrink-0", @class])}>
      <%= if @entries != [] do %>
        <%!-- Preview of the newly selected file --%>
        <div class={cn([size_class(@size), shape_class(@shape), "relative overflow-hidden bg-muted"])}>
          <.live_img_preview
            entry={List.first(@entries)}
            class="w-full h-full object-cover"
          />
          <%!-- Remove button --%>
          <button
            type="button"
            phx-click={@on_cancel}
            phx-value-ref={List.first(@entries).ref}
            aria-label="Remove photo"
            class="absolute top-1 right-1 flex h-6 w-6 items-center justify-center rounded-full bg-background/80 text-foreground shadow-sm transition-colors hover:bg-background"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>
      <% else %>
        <%!-- Click-to-upload drop zone --%>
        <label
          for={@upload.ref}
          class={cn([
            "group relative cursor-pointer overflow-hidden bg-muted flex items-center justify-center",
            "border-2 border-dashed border-border hover:border-primary transition-colors",
            size_class(@size), shape_class(@shape)
          ])}
        >
          <%!-- Current photo background --%>
          <%= if @current_url do %>
            <img
              src={@current_url}
              alt="Current photo"
              class="absolute inset-0 h-full w-full object-cover"
            />
          <% else %>
            <%!-- Placeholder icon --%>
            <svg xmlns="http://www.w3.org/2000/svg" class={cn(["text-muted-foreground/40", placeholder_icon_size(@size)])}
                 viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M12 12a5 5 0 1 0 0-10 5 5 0 0 0 0 10zm0 2c-5.33 0-8 2.67-8 4v1h16v-1c0-1.33-2.67-4-8-4z" />
            </svg>
          <% end %>

          <%!-- Camera overlay (always visible on hover, semi-visible on current_url) --%>
          <div class={cn([
            "absolute inset-0 flex flex-col items-center justify-center gap-1",
            "transition-opacity",
            @current_url && "bg-black/30 opacity-0 group-hover:opacity-100",
            !@current_url && "opacity-100"
          ])}>
            <svg xmlns="http://www.w3.org/2000/svg" class={cn(["text-white", camera_icon_size(@size)])}
                 viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
                 stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
              <circle cx="12" cy="13" r="4" />
            </svg>
            <span class={cn(["text-white font-medium", camera_label_size(@size)])}>
              Upload
            </span>
          </div>

          <%= if is_struct(@upload, Phoenix.LiveView.UploadConfig) do %>
            <.live_file_input upload={@upload} class="sr-only" />
          <% end %>
        </label>
      <% end %>

      <%!-- Per-upload validation errors --%>
      <%= for err <- get_upload_errors(@upload) do %>
        <p class="absolute -bottom-5 left-0 right-0 text-center text-xs text-destructive">
          {humanize_error(err)}
        </p>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp size_class("sm"), do: "w-16 h-16"
  defp size_class("md"), do: "w-24 h-24"
  defp size_class("lg"), do: "w-32 h-32"
  defp size_class("xl"), do: "w-40 h-40"
  defp size_class(_), do: "w-24 h-24"

  defp shape_class("circle"), do: "rounded-full"
  defp shape_class("square"), do: "rounded-lg"
  defp shape_class(_), do: "rounded-full"

  defp camera_icon_size("sm"), do: "h-4 w-4"
  defp camera_icon_size("md"), do: "h-6 w-6"
  defp camera_icon_size("lg"), do: "h-7 w-7"
  defp camera_icon_size("xl"), do: "h-8 w-8"
  defp camera_icon_size(_), do: "h-6 w-6"

  defp camera_label_size("sm"), do: "hidden"
  defp camera_label_size("md"), do: "text-[10px]"
  defp camera_label_size("lg"), do: "text-xs"
  defp camera_label_size("xl"), do: "text-sm"
  defp camera_label_size(_), do: "text-[10px]"

  defp placeholder_icon_size("sm"), do: "h-7 w-7"
  defp placeholder_icon_size("md"), do: "h-10 w-10"
  defp placeholder_icon_size("lg"), do: "h-12 w-12"
  defp placeholder_icon_size("xl"), do: "h-16 w-16"
  defp placeholder_icon_size(_), do: "h-10 w-10"

  defp get_upload_errors(upload), do: Map.get(upload, :errors, [])

  defp humanize_error(:too_large), do: "File too large"
  defp humanize_error(:not_accepted), do: "Invalid file type"
  defp humanize_error(:too_many_files), do: "Too many files"
  defp humanize_error(other), do: to_string(other)
end
