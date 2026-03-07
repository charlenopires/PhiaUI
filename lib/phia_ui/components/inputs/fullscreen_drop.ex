defmodule PhiaUi.Components.FullscreenDrop do
  @moduledoc """
  Full-viewport drop overlay that appears when the user drags files over the browser window.

  Provides `fullscreen_drop/1` — an absolutely-positioned overlay that covers
  the entire viewport with a highlighted dashed border and a drop instruction.
  The overlay activates when a user drags a file over the browser window and
  deactivates when the drag leaves or a file is dropped.

  The overlay is wired to Phoenix LiveView's `phx-drop-target` so dropped files
  are processed by the LiveView upload system.

  ## JS Hook

  This component requires the `PhiaFullscreenDrop` JS hook to be registered in
  your application. Copy `priv/templates/js/hooks/fullscreen_drop.js` to your
  `assets/js/hooks/` directory and register it:

      // app.js
      import { PhiaFullscreenDrop } from "./hooks/fullscreen_drop"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaFullscreenDrop, ...otherHooks }
      })

  The hook listens to `dragenter` / `dragleave` / `drop` events on the document
  to toggle the overlay's visibility via `data-active` attribute, which is
  targeted by CSS classes.

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok, allow_upload(socket, :files, accept: :any, max_entries: 20)}
      end

  ## Basic usage

      <%!-- Place near the top of your root layout --%>
      <.fullscreen_drop
        upload={@uploads.files}
        label="Drop files anywhere to upload"
      />

  ## With custom label and icon

      <.fullscreen_drop
        upload={@uploads.attachments}
        label="Release to attach files"
        description="Supported: PDF, DOCX, PNG, JPG up to 50 MB"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # fullscreen_drop/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:label, :string,
    default: "Drop files to upload",
    doc: "Main instruction text rendered inside the overlay."
  )

  attr(:description, :string,
    default: nil,
    doc: "Optional secondary text (accepted formats, size limits) below the label."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the overlay wrapper."
  )

  @doc """
  Renders a full-viewport drag-and-drop overlay.

  Place this component once at the root of your LiveView template. It is
  invisible by default and activates via the `PhiaFullscreenDrop` JS hook
  when the user drags files over the browser window.

  ## Example

      <.fullscreen_drop upload={@uploads.files} label="Drop files to upload" />
  """
  def fullscreen_drop(assigns) do
    drop_ref = Map.get(assigns.upload, :ref)
    assigns = assign(assigns, :drop_ref, drop_ref)

    ~H"""
    <div
      id={"fullscreen-drop-#{@drop_ref}"}
      phx-hook="PhiaFullscreenDrop"
      data-drop-ref={@drop_ref}
      class={cn([
        "pointer-events-none fixed inset-0 z-[9999] hidden items-center justify-center",
        "bg-background/80 backdrop-blur-sm",
        "data-[active=true]:flex",
        @class
      ])}
      aria-hidden="true"
    >
      <%!-- Drop target — phx-drop-target must be on an element inside the overlay --%>
      <div
        phx-drop-target={@drop_ref}
        class="pointer-events-auto flex flex-col items-center justify-center gap-4 w-full h-full"
      >
        <%!-- Inner dashed frame --%>
        <div class="flex flex-col items-center justify-center gap-4 w-[calc(100%-4rem)] h-[calc(100%-4rem)] rounded-2xl border-4 border-dashed border-primary bg-primary/5">
          <%!-- Cloud upload icon --%>
          <div class="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-primary" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242" />
              <path d="M12 12v9" /><path d="m8 17 4-4 4 4" />
            </svg>
          </div>

          <div class="text-center space-y-1">
            <p class="text-xl font-semibold text-foreground">{@label}</p>
            <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
