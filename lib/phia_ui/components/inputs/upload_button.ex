defmodule PhiaUi.Components.UploadButton do
  @moduledoc """
  Button-style file picker — triggers the file dialog without a drop zone.

  Provides `upload_button/1` — a compact alternative to the full `file_upload/1`
  drop-zone when you just need a button to open the file picker. The selected
  file(s) appear in an optional compact list below the button.

  Useful for:
  - Attaching files in a messaging interface
  - Importing a CSV or JSON config file
  - Adding a single document to a form without the visual overhead of a dropzone

  ## Requirements

  The parent LiveView must configure the upload with `allow_upload/3`:

      def mount(_params, _session, socket) do
        {:ok, allow_upload(socket, :csv, accept: ~w(.csv), max_entries: 1)}
      end

  ## Basic usage

      <%!-- Simple upload trigger --%>
      <.upload_button upload={@uploads.csv} label="Import CSV" />

      <%!-- With icon and custom variant --%>
      <.upload_button
        upload={@uploads.documents}
        label="Attach files"
        variant="outline"
        on_cancel="cancel_upload"
      />

  ## Handling cancel

      def handle_event("cancel_upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :documents, ref)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # upload_button/1
  # ---------------------------------------------------------------------------

  attr(:upload, :any,
    required: true,
    doc: "A `Phoenix.LiveView.UploadConfig` struct from `@uploads.field_name`."
  )

  attr(:label, :string,
    default: "Upload file",
    doc: "Button label text."
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline ghost secondary),
    doc: "Button visual style."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg),
    doc: "Button size."
  )

  attr(:show_list, :boolean,
    default: true,
    doc: "When true, renders selected entries in a compact list below the button."
  )

  attr(:on_cancel, :string,
    default: "cancel_upload",
    doc: "LiveView event name fired when the × remove button is clicked on an entry."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a button that opens the system file picker when clicked.

  No drop zone is shown — only the button and an optional compact list of
  selected entries. Use `file_upload/1` when a visual drop zone is needed.

  ## Examples

      <.upload_button upload={@uploads.import} label="Import CSV" />

      <.upload_button upload={@uploads.docs} label="Attach" variant="outline" size="sm" />
  """
  def upload_button(assigns) do
    entries = Map.get(assigns.upload, :entries, [])
    assigns = assign(assigns, :entries, entries)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%!-- Trigger label wrapping the hidden live_file_input --%>
      <label class={cn([btn_class(@variant, @size), "inline-flex cursor-pointer items-center gap-2"])}>
        <%!-- Upload icon --%>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
             aria-hidden="true">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="17 8 12 3 7 8" />
          <line x1="12" x2="12" y1="3" y2="15" />
        </svg>
        {@label}
        <%= if is_struct(@upload, Phoenix.LiveView.UploadConfig) do %>
          <.live_file_input upload={@upload} class="sr-only" />
        <% end %>
      </label>

      <%!-- Upload-level errors --%>
      <%= for err <- Map.get(@upload, :errors, []) do %>
        <p class="text-xs text-destructive">{humanize_error(err)}</p>
      <% end %>

      <%!-- Compact entry list --%>
      <div :if={@show_list && @entries != []} class="space-y-1.5">
        <div
          :for={entry <- @entries}
          class="flex items-center gap-2 rounded-md border border-border bg-muted/30 px-3 py-2"
        >
          <%!-- File icon --%>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 shrink-0 text-muted-foreground"
               viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
               stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" />
            <path d="M14 2v4a2 2 0 0 0 2 2h4" />
          </svg>

          <span class="flex-1 min-w-0 truncate text-sm">{entry.client_name}</span>

          <%!-- Progress --%>
          <span class="text-xs text-muted-foreground tabular-nums shrink-0">
            {entry.progress}%
          </span>

          <%!-- Per-entry errors --%>
          <span :for={err <- Map.get(entry, :errors, [])} class="text-xs text-destructive shrink-0">
            {humanize_error(err)}
          </span>

          <%!-- Remove button --%>
          <button
            type="button"
            phx-click={@on_cancel}
            phx-value-ref={entry.ref}
            aria-label={"Remove #{entry.client_name}"}
            class="shrink-0 flex h-5 w-5 items-center justify-center rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp btn_class("default", size) do
    "rounded-md bg-primary text-primary-foreground shadow hover:bg-primary/90 " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      size_padding(size)
  end

  defp btn_class("outline", size) do
    "rounded-md border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      size_padding(size)
  end

  defp btn_class("ghost", size) do
    "rounded-md hover:bg-accent hover:text-accent-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      size_padding(size)
  end

  defp btn_class("secondary", size) do
    "rounded-md bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80 " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      size_padding(size)
  end

  defp btn_class(_, size), do: btn_class("default", size)

  defp size_padding("sm"), do: "h-8 px-3 text-xs"
  defp size_padding("lg"), do: "h-11 px-8 text-base"
  defp size_padding(_), do: "h-9 px-4 py-2 text-sm"

  defp humanize_error(:too_large), do: "File too large"
  defp humanize_error(:not_accepted), do: "Invalid file type"
  defp humanize_error(:too_many_files), do: "Too many files"
  defp humanize_error(other), do: to_string(other)
end
