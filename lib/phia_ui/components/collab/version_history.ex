defmodule PhiaUi.Components.Collab.VersionHistory do
  @moduledoc """
  Version history components for collaborative document editing.

  Provides a timeline of document versions, diff views, restore dialogs,
  and save-state indicators for TipTap-based collaborative editors.

  ## Components

  | Component                | Purpose                                           |
  |--------------------------|---------------------------------------------------|
  | `version_summary/1`      | Single version entry in the timeline              |
  | `version_list/1`         | Timeline of versions grouped by day               |
  | `version_diff/1`         | Diff view between two document versions           |
  | `version_restore_dialog/1` | Confirmation dialog for restoring a version     |
  | `version_panel/1`        | Full version history side panel                   |
  | `version_badge/1`        | "Saved N seconds ago" indicator                   |

  ## Version map shape

  Components that accept a `:version` map expect:

      %{
        id: "v-1",
        author_name: "Alice Adams",
        author_color: "#3B82F6",
        author_avatar_url: "/avatars/alice.jpg",  # optional
        created_at: ~U[2026-03-19 10:00:00Z],
        word_count: 1250,
        word_count_delta: "+42",                   # optional
        label: "Auto-save"                         # optional
      }
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  import PhiaUi.Components.Collab.CollabHelpers,
    only: [format_relative_time: 1, user_initials: 1]

  alias PhiaUi.Components.Collab.VersionHelpers

  # ---------------------------------------------------------------------------
  # version_summary/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :version, :map, required: true
  attr :active, :boolean, default: false
  attr :on_select, :string, default: "collab:version:select"
  attr :class, :string, default: nil

  @doc """
  Renders a single version entry in the timeline.

  Shows a colored dot on a vertical timeline line, author avatar, formatted
  time, an optional label, and a word count delta badge.

  ## Example

      <.version_summary
        id="v-1"
        version={%{id: "v-1", author_name: "Alice", author_color: "#3B82F6", created_at: ~U[2026-03-19T10:00:00Z], word_count: 1250, word_count_delta: "+42"}}
        active={false}
      />
  """
  def version_summary(assigns) do
    version = assigns.version
    created_at = Map.get(version, :created_at)
    color = Map.get(version, :author_color, "#6B7280")

    assigns =
      assigns
      |> assign(:time_label, format_relative_time(created_at))
      |> assign(:date_label, VersionHelpers.format_version_date(created_at))
      |> assign(:color, color)

    ~H"""
    <div
      id={@id}
      class={cn([
        "group relative flex items-start gap-3 rounded-lg px-3 py-2",
        "cursor-pointer transition-colors duration-150",
        if(@active, do: "bg-accent", else: "hover:bg-accent/50"),
        @class
      ])}
      phx-click={@on_select}
      phx-value-id={@version.id}
      role="option"
      aria-selected={to_string(@active)}
    >
      <div class="relative flex flex-col items-center">
        <span
          class="h-3 w-3 rounded-full ring-2 ring-background flex-shrink-0"
          style={"background-color: #{@color}"}
        />
        <span class="w-px flex-1 bg-border min-h-4" />
      </div>

      <div class="flex-1 min-w-0 pb-2">
        <div class="flex items-center gap-2">
          <span
            :if={Map.get(@version, :author_avatar_url)}
            class="h-5 w-5 flex-shrink-0 overflow-hidden rounded-full"
          >
            <img
              src={Map.get(@version, :author_avatar_url)}
              alt={Map.get(@version, :author_name, "")}
              class="h-full w-full object-cover"
            />
          </span>
          <span
            :if={!Map.get(@version, :author_avatar_url)}
            class="flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full text-[10px] font-medium text-white"
            style={"background-color: #{@color}"}
          >
            {user_initials(Map.get(@version, :author_name))}
          </span>
          <span class="truncate text-sm font-medium text-foreground">
            {Map.get(@version, :author_name, "Unknown")}
          </span>
        </div>

        <div class="mt-1 flex items-center gap-2 text-xs text-muted-foreground">
          <span>{@time_label}</span>
          <span
            :if={Map.get(@version, :label)}
            class="rounded bg-muted px-1.5 py-0.5 text-[10px] font-medium"
          >
            {Map.get(@version, :label)}
          </span>
          <span
            :if={Map.get(@version, :word_count_delta)}
            class={cn([
              "rounded px-1.5 py-0.5 text-[10px] font-medium",
              delta_class(Map.get(@version, :word_count_delta, "0"))
            ])}
          >
            {Map.get(@version, :word_count_delta)}
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # version_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :versions, :list, default: []
  attr :active_version_id, :string, default: nil
  attr :on_select, :string, default: "collab:version:select"
  attr :class, :string, default: nil

  @doc """
  Renders a timeline of versions grouped by day with date headers.

  Each day group has a sticky date header and a list of version summaries.

  ## Example

      <.version_list
        id="version-timeline"
        versions={@versions}
        active_version_id={@active_version_id}
      />
  """
  def version_list(assigns) do
    grouped = VersionHelpers.group_versions_by_day(assigns.versions)
    assigns = assign(assigns, :grouped, grouped)

    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col overflow-y-auto", @class])}
      role="listbox"
      aria-label="Version history"
    >
      <div
        :if={@versions == []}
        class="flex flex-col items-center justify-center py-12 text-muted-foreground"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 mb-3 opacity-40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
        </svg>
        <p class="text-sm">No versions yet</p>
      </div>

      <div :for={{date, day_versions} <- @grouped} class="flex flex-col">
        <div class="sticky top-0 z-10 bg-card/95 backdrop-blur-sm px-3 py-1.5 border-b border-border">
          <span class="text-xs font-semibold text-muted-foreground">
            {format_group_date(date)}
          </span>
        </div>

        <.version_summary
          :for={version <- day_versions}
          id={"#{@id}-v-#{Map.get(version, :id, "")}"}
          version={version}
          active={Map.get(version, :id) == @active_version_id}
          on_select={@on_select}
        />
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # version_diff/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :changes, :list, default: []
  attr :mode, :atom, default: :inline, values: [:inline, :side_by_side]
  attr :class, :string, default: nil

  @doc """
  Renders a diff view between two document versions.

  Additions are highlighted in green, removals in red, and modifications
  show both the old and new content. Supports `:inline` and `:side_by_side`
  display modes.

  ## Example

      <.version_diff
        id="diff-view"
        changes={[%{type: :added, path: [0], content: %{"type" => "paragraph"}}]}
        mode={:inline}
      />
  """
  def version_diff(assigns) do
    summary = VersionHelpers.diff_summary(assigns.changes)
    assigns = assign(assigns, :summary, summary)

    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col gap-2 rounded-lg border border-border bg-card p-4", @class])}
      role="region"
      aria-label="Version diff"
    >
      <div class="flex items-center justify-between">
        <span class="text-xs font-medium text-muted-foreground">Changes</span>
        <span class="text-xs text-muted-foreground">{@summary}</span>
      </div>

      <div
        :if={@changes == []}
        class="py-6 text-center text-sm text-muted-foreground"
      >
        No changes between versions
      </div>

      <div
        :if={@changes != [] and @mode == :inline}
        class="flex flex-col gap-1 font-mono text-xs"
      >
        <div
          :for={change <- @changes}
          class={cn([
            "rounded px-3 py-1.5",
            diff_line_class(change.type)
          ])}
        >
          <span class="mr-2 font-bold select-none">{diff_prefix(change.type)}</span>
          <span>{diff_content_text(change)}</span>
        </div>
      </div>

      <div
        :if={@changes != [] and @mode == :side_by_side}
        class="grid grid-cols-2 gap-2 font-mono text-xs"
      >
        <div class="flex flex-col gap-1">
          <span class="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">Before</span>
          <div
            :for={change <- @changes}
            class={cn([
              "rounded px-3 py-1.5",
              if(change.type in [:removed, :modified], do: "bg-red-50 text-red-800 dark:bg-red-950/30 dark:text-red-300", else: "bg-muted/30 text-muted-foreground")
            ])}
          >
            {diff_old_text(change)}
          </div>
        </div>
        <div class="flex flex-col gap-1">
          <span class="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">After</span>
          <div
            :for={change <- @changes}
            class={cn([
              "rounded px-3 py-1.5",
              if(change.type in [:added, :modified], do: "bg-green-50 text-green-800 dark:bg-green-950/30 dark:text-green-300", else: "bg-muted/30 text-muted-foreground")
            ])}
          >
            {diff_new_text(change)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # version_restore_dialog/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :version, :map, default: nil
  attr :open, :boolean, default: false
  attr :on_confirm, :string, default: "collab:version:restore"
  attr :on_cancel, :string, default: "collab:version:restore:cancel"
  attr :class, :string, default: nil

  @doc """
  Renders a confirmation dialog for restoring a previous version.

  Shows a modal overlay with version details, a warning message, and
  confirm/cancel buttons.

  ## Example

      <.version_restore_dialog
        id="restore-dialog"
        version={%{id: "v-1", author_name: "Alice", created_at: ~U[2026-03-19T10:00:00Z]}}
        open={true}
      />
  """
  def version_restore_dialog(assigns) do
    ~H"""
    <div
      :if={@open and @version != nil}
      id={@id}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center",
        @class
      ])}
      role="dialog"
      aria-modal="true"
      aria-labelledby={"#{@id}-title"}
    >
      <div
        class="absolute inset-0 bg-black/50 backdrop-blur-sm"
        phx-click={@on_cancel}
        aria-hidden="true"
      />

      <div class="relative z-10 w-full max-w-md rounded-xl border border-border bg-card p-6 shadow-xl">
        <h3 id={"#{@id}-title"} class="text-lg font-semibold text-foreground">
          Restore this version?
        </h3>

        <p class="mt-2 text-sm text-muted-foreground">
          This will replace the current document with the version saved by
          <span class="font-medium text-foreground">{Map.get(@version, :author_name, "Unknown")}</span>
          on <span class="font-medium text-foreground">{VersionHelpers.format_version_date(Map.get(@version, :created_at))}</span>.
        </p>

        <p class="mt-3 text-xs text-muted-foreground">
          A backup of the current version will be created automatically.
        </p>

        <div class="mt-6 flex items-center justify-end gap-3">
          <button
            type="button"
            class={cn([
              "inline-flex items-center justify-center rounded-md px-4 py-2",
              "text-sm font-medium text-foreground",
              "border border-border bg-background hover:bg-accent transition-colors"
            ])}
            phx-click={@on_cancel}
          >
            Cancel
          </button>
          <button
            type="button"
            class={cn([
              "inline-flex items-center justify-center rounded-md px-4 py-2",
              "text-sm font-medium text-primary-foreground",
              "bg-primary hover:bg-primary/90 transition-colors"
            ])}
            phx-click={@on_confirm}
            phx-value-id={Map.get(@version, :id)}
          >
            Restore version
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # version_panel/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :versions, :list, default: []
  attr :active_version_id, :string, default: nil
  attr :changes, :list, default: []
  attr :on_close, :string, default: "collab:version:panel:close"
  attr :class, :string, default: nil

  @doc """
  Renders a full version history side panel.

  Contains a header with title and close button, the version list timeline,
  and a diff view for the currently selected version.

  ## Example

      <.version_panel
        id="version-panel"
        versions={@versions}
        active_version_id={@active_version_id}
        changes={@changes}
      />
  """
  def version_panel(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex flex-col h-full w-80 border-l border-border bg-card",
        @class
      ])}
      role="complementary"
      aria-label="Version history"
    >
      <div class="flex items-center justify-between border-b border-border px-4 py-3">
        <h2 class="text-sm font-semibold text-foreground">Version History</h2>
        <button
          type="button"
          class="rounded p-1 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
          phx-click={@on_close}
          aria-label="Close version history"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>

      <.version_list
        id={"#{@id}-list"}
        versions={@versions}
        active_version_id={@active_version_id}
        class="flex-1"
      />

      <div
        :if={@changes != []}
        class="border-t border-border"
      >
        <.version_diff
          id={"#{@id}-diff"}
          changes={@changes}
          class="border-0 rounded-none"
        />
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # version_badge/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :last_saved_at, :any, default: nil
  attr :has_unsaved, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Renders a save-state indicator badge.

  Shows "Saved X ago" when changes are saved, or "Unsaved changes" with a
  warning style when there are pending unsaved modifications.

  ## Example

      <.version_badge
        id="save-badge"
        last_saved_at={~U[2026-03-19 10:00:00Z]}
        has_unsaved={false}
      />
  """
  def version_badge(assigns) do
    time_label =
      if assigns.last_saved_at do
        "Saved #{format_relative_time(assigns.last_saved_at)}"
      else
        "Not saved yet"
      end

    assigns = assign(assigns, :time_label, time_label)

    ~H"""
    <div
      id={@id}
      class={cn([
        "inline-flex items-center gap-1.5 rounded-md px-2.5 py-1 text-xs font-medium",
        if(@has_unsaved,
          do: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
          else: "bg-muted text-muted-foreground"
        ),
        @class
      ])}
      role="status"
      aria-live="polite"
    >
      <span :if={@has_unsaved} class="h-1.5 w-1.5 rounded-full bg-amber-500 animate-pulse" />
      <span :if={!@has_unsaved} class="h-1.5 w-1.5 rounded-full bg-green-500" />
      <span>
        {if @has_unsaved, do: "Unsaved changes", else: @time_label}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp delta_class(delta) when is_binary(delta) do
    cond do
      String.starts_with?(delta, "+") ->
        "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"

      String.starts_with?(delta, "-") ->
        "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"

      true ->
        "bg-muted text-muted-foreground"
    end
  end

  defp delta_class(_), do: "bg-muted text-muted-foreground"

  defp format_group_date(date) do
    today = Date.utc_today()

    cond do
      date == today -> "Today"
      date == Date.add(today, -1) -> "Yesterday"
      true -> Calendar.strftime(date, "%B %d, %Y")
    end
  end

  defp diff_line_class(:added),
    do: "bg-green-50 text-green-800 dark:bg-green-950/30 dark:text-green-300"

  defp diff_line_class(:removed),
    do: "bg-red-50 text-red-800 dark:bg-red-950/30 dark:text-red-300"

  defp diff_line_class(:modified),
    do: "bg-amber-50 text-amber-800 dark:bg-amber-950/30 dark:text-amber-300"

  defp diff_line_class(_), do: "bg-muted text-muted-foreground"

  defp diff_prefix(:added), do: "+"
  defp diff_prefix(:removed), do: "-"
  defp diff_prefix(:modified), do: "~"
  defp diff_prefix(_), do: " "

  defp diff_content_text(%{type: :added, content: content}), do: extract_text(content)
  defp diff_content_text(%{type: :removed, content: content}), do: extract_text(content)

  defp diff_content_text(%{type: :modified, old: old, new: new}) do
    "#{extract_text(old)} -> #{extract_text(new)}"
  end

  defp diff_content_text(_), do: ""

  defp diff_old_text(%{type: :removed, content: content}), do: extract_text(content)
  defp diff_old_text(%{type: :modified, old: old}), do: extract_text(old)
  defp diff_old_text(_), do: ""

  defp diff_new_text(%{type: :added, content: content}), do: extract_text(content)
  defp diff_new_text(%{type: :modified, new: new}), do: extract_text(new)
  defp diff_new_text(_), do: ""

  defp extract_text(content) when is_map(content) do
    case Map.get(content, "text") || Map.get(content, :text) do
      nil ->
        type = Map.get(content, "type") || Map.get(content, :type, "node")
        "[#{type}]"

      text ->
        text
    end
  end

  defp extract_text(content) when is_binary(content), do: content
  defp extract_text(_), do: "[content]"
end
