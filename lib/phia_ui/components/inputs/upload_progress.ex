defmodule PhiaUi.Components.UploadProgress do
  @moduledoc """
  Standalone upload progress component with status states.

  Provides `upload_progress/1` — a self-contained progress row that shows the
  upload status of a single file. Useful outside of Phoenix LiveView's native
  upload system, e.g. when tracking progress from a custom JS uploader or
  when displaying server-side upload task status.

  ## Status states

  | Status | Visual |
  |--------|--------|
  | `:pending` | Pulsing grey bar — queued, not yet started |
  | `:uploading` | Animated blue bar with progress % |
  | `:done` | Solid green bar at 100% with checkmark |
  | `:error` | Red bar with error message + retry button |
  | `:canceled` | Strikethrough name, greyed out |

  ## Basic usage

      <.upload_progress
        filename="invoice.pdf"
        status={:uploading}
        progress={42}
      />

      <.upload_progress
        filename="report.xlsx"
        status={:done}
        progress={100}
      />

      <.upload_progress
        filename="photo.png"
        status={:error}
        error_message="File too large — maximum 10 MB"
        on_retry="retry_upload"
        on_cancel="cancel_upload"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # upload_progress/1
  # ---------------------------------------------------------------------------

  attr(:filename, :string,
    required: true,
    doc: "Name of the file being uploaded."
  )

  attr(:status, :atom,
    default: :pending,
    values: [:pending, :uploading, :done, :error, :canceled],
    doc: "Current upload status atom."
  )

  attr(:progress, :integer,
    default: 0,
    doc: "Upload progress percentage (0–100). Only meaningful for `:uploading` and `:done`."
  )

  attr(:error_message, :string,
    default: nil,
    doc: "Error description shown in the `:error` state."
  )

  attr(:on_cancel, :string,
    default: nil,
    doc: "LiveView event name for the cancel button (shown in `:pending` and `:uploading` states)."
  )

  attr(:on_retry, :string,
    default: nil,
    doc: "LiveView event name for the retry button (shown in `:error` state)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a single-file upload progress row.

  ## Examples

      <.upload_progress filename="cv.pdf" status={:uploading} progress={67} on_cancel="cancel" />

      <.upload_progress filename="photo.jpg" status={:done} progress={100} />

      <.upload_progress filename="data.csv" status={:error} error_message="Network error" on_retry="retry" />
  """
  def upload_progress(assigns) do
    ~H"""
    <div class={cn(["flex items-start gap-3 rounded-lg border border-border bg-background p-3", @class])}>
      <%!-- Status icon --%>
      <div class={cn(["mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-md", status_icon_bg(@status)])}>
        {status_icon(assigns)}
      </div>

      <%!-- Content --%>
      <div class="flex-1 min-w-0 space-y-1.5">
        <%!-- Filename --%>
        <p class={cn(["text-sm font-medium truncate", @status == :canceled && "line-through text-muted-foreground"])}>
          {@filename}
        </p>

        <%!-- Progress bar --%>
        <div :if={@status != :canceled} class="h-1.5 w-full overflow-hidden rounded-full bg-muted">
          <div
            class={cn(["h-full rounded-full transition-all duration-300", bar_class(@status)])}
            style={"width: #{bar_width(@status, @progress)}%"}
          ></div>
        </div>

        <%!-- Status label / error --%>
        <div class="flex items-center justify-between gap-2">
          <p class={cn(["text-xs", status_text_class(@status)])}>
            <%= status_label(@status, @progress, @error_message) %>
          </p>

          <%!-- Retry link (error state) --%>
          <button
            :if={@status == :error && @on_retry}
            type="button"
            phx-click={@on_retry}
            class="text-xs text-primary hover:underline shrink-0"
          >
            Retry
          </button>
        </div>
      </div>

      <%!-- Cancel / dismiss button --%>
      <button
        :if={@on_cancel && @status in [:pending, :uploading, :error]}
        type="button"
        phx-click={@on_cancel}
        aria-label="Cancel upload"
        class="mt-0.5 shrink-0 flex h-6 w-6 items-center justify-center rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none"
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

  defp status_icon_bg(:pending), do: "bg-muted text-muted-foreground"
  defp status_icon_bg(:uploading), do: "bg-primary/10 text-primary"
  defp status_icon_bg(:done), do: "bg-green-100 text-green-600 dark:bg-green-900/30 dark:text-green-400"
  defp status_icon_bg(:error), do: "bg-destructive/10 text-destructive"
  defp status_icon_bg(:canceled), do: "bg-muted text-muted-foreground"

  defp status_icon(%{status: :pending} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
    </svg>
    """
  end

  defp status_icon(%{status: :uploading} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
    """
  end

  defp status_icon(%{status: :done} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <polyline points="20 6 9 17 4 12" />
    </svg>
    """
  end

  defp status_icon(%{status: :error} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10" /><line x1="12" x2="12" y1="8" y2="12" /><line x1="12" x2="12.01" y1="16" y2="16" />
    </svg>
    """
  end

  defp status_icon(%{status: :canceled} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10" /><path d="m4.9 4.9 14.2 14.2" />
    </svg>
    """
  end

  defp bar_class(:pending), do: "bg-muted-foreground/40 animate-pulse"
  defp bar_class(:uploading), do: "bg-primary"
  defp bar_class(:done), do: "bg-green-500 dark:bg-green-400"
  defp bar_class(:error), do: "bg-destructive"
  defp bar_class(:canceled), do: "bg-muted-foreground/30"

  defp bar_width(:pending, _), do: 100
  defp bar_width(:done, _), do: 100
  defp bar_width(:error, pct), do: pct
  defp bar_width(:canceled, _), do: 100
  defp bar_width(_, pct), do: pct

  defp status_text_class(:error), do: "text-destructive"
  defp status_text_class(:done), do: "text-green-600 dark:text-green-400"
  defp status_text_class(:canceled), do: "text-muted-foreground"
  defp status_text_class(_), do: "text-muted-foreground"

  defp status_label(:pending, _, _), do: "Queued"
  defp status_label(:uploading, pct, _), do: "Uploading… #{pct}%"
  defp status_label(:done, _, _), do: "Upload complete"
  defp status_label(:error, _, msg), do: msg || "Upload failed"
  defp status_label(:canceled, _, _), do: "Canceled"
end
