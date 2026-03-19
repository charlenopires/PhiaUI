defmodule PhiaUi.Components.Editor.TrackChanges do
  @moduledoc """
  Track Changes Suite — 7 components for document revision tracking and collaboration.

  Provides visual change tracking (insert/delete marks), inline diffs,
  accept/reject controls, editing mode toggles, sharing permissions,
  and auto-save status indicators. Designed to complement the TipTap
  editor suite and OT engine.

  ## Components

  - `track_change_mark/1`       — inline `<ins>` / `<del>` annotation with author metadata
  - `track_change_panel/1`      — sidebar panel listing all tracked changes with accept/reject
  - `track_change_toggle/1`     — segmented control for editing / suggesting / viewing modes
  - `accept_reject_controls/1`  — toolbar with accept/reject current + accept/reject all buttons
  - `change_diff_inline/1`      — inline diff view showing old (red) and new (green) text
  - `share_permissions_dialog/1` — modal dialog for managing document sharing and roles
  - `auto_save_indicator/1`     — status dot with label showing save state

  ## Example

      <.track_change_mark type={:insert} author="Alice">
        new text here
      </.track_change_mark>

      <.track_change_panel id="changes" changes={@tracked_changes} />

      <.track_change_toggle id="mode" mode={@edit_mode} />

      <.auto_save_indicator status={@save_status} last_saved={@last_saved_at} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # track_change_mark/1
  # ============================================================================

  attr :type, :atom, required: true, values: [:insert, :delete]
  attr :author, :string, default: nil
  attr :timestamp, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders an inline tracked change annotation.

  Wraps content in `<ins>` (for inserts) or `<del>` (for deletes) with
  appropriate visual styling and optional author/timestamp metadata.

  - **Insert**: green background, underline decoration
  - **Delete**: red background, strikethrough decoration

  ## Example

      <.track_change_mark type={:insert} author="Alice" timestamp="2 min ago">
        added text
      </.track_change_mark>

      <.track_change_mark type={:delete} author="Bob">
        removed text
      </.track_change_mark>
  """
  def track_change_mark(assigns) do
    ~H"""
    <%= if @type == :insert do %>
      <ins
        class={cn([
          "no-underline rounded-sm px-0.5 py-px",
          "bg-emerald-100 text-emerald-900 decoration-emerald-500 underline decoration-2 underline-offset-2",
          "dark:bg-emerald-950/50 dark:text-emerald-200 dark:decoration-emerald-400",
          @class
        ])}
        data-author={@author}
        data-timestamp={@timestamp}
        title={change_title(:insert, @author, @timestamp)}
        {@rest}
      >
        {render_slot(@inner_block)}
      </ins>
    <% else %>
      <del
        class={cn([
          "rounded-sm px-0.5 py-px",
          "bg-red-100 text-red-900 line-through decoration-red-500 decoration-2",
          "dark:bg-red-950/50 dark:text-red-200 dark:decoration-red-400",
          @class
        ])}
        data-author={@author}
        data-timestamp={@timestamp}
        title={change_title(:delete, @author, @timestamp)}
        {@rest}
      >
        {render_slot(@inner_block)}
      </del>
    <% end %>
    """
  end

  defp change_title(type, author, timestamp) do
    action = if type == :insert, do: "Inserted", else: "Deleted"
    parts = [action]
    parts = if author, do: parts ++ ["by #{author}"], else: parts
    parts = if timestamp, do: parts ++ ["at #{timestamp}"], else: parts
    Enum.join(parts, " ")
  end

  # ============================================================================
  # track_change_panel/1
  # ============================================================================

  attr :id, :string, required: true
  attr :changes, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a panel listing all tracked changes with accept/reject buttons per change.

  Each change in the `:changes` list should be a map with:

    - `:type` — `:insert` or `:delete`
    - `:text` — the changed text content
    - `:author` — author name (optional)
    - `:timestamp` — human-readable timestamp (optional)

  ## Example

      <.track_change_panel
        id="changes-panel"
        changes={[
          %{type: :insert, text: "new text", author: "Alice", timestamp: "2 min ago"},
          %{type: :delete, text: "old text", author: "Bob", timestamp: "5 min ago"}
        ]}
      />
  """
  def track_change_panel(assigns) do
    ~H"""
    <div
      id={@id}
      role="region"
      aria-label="Tracked changes"
      class={cn([
        "flex flex-col divide-y divide-border rounded-lg border border-border bg-background",
        @class
      ])}
      {@rest}
    >
      <div class="flex items-center justify-between px-4 py-3">
        <h3 class="text-sm font-semibold text-foreground">
          Changes
          <span :if={@changes != []} class="ml-1.5 inline-flex items-center rounded-full bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground">
            {Kernel.length(@changes)}
          </span>
        </h3>
      </div>
      <div :if={@changes == []} class="flex items-center justify-center px-4 py-8">
        <p class="text-sm text-muted-foreground">No tracked changes</p>
      </div>
      <ul :if={@changes != []} class="divide-y divide-border" role="list">
        <li :for={{change, index} <- Enum.with_index(@changes)} class="group flex items-start gap-3 px-4 py-3">
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 mb-1">
              <span class={cn([
                "inline-flex items-center rounded px-1.5 py-0.5 text-xs font-medium",
                change_type_badge_class(change.type)
              ])}>
                {if change.type == :insert, do: "Insert", else: "Delete"}
              </span>
              <span :if={Map.get(change, :author)} class="text-xs text-muted-foreground">
                {change.author}
              </span>
              <span :if={Map.get(change, :timestamp)} class="text-xs text-muted-foreground">
                {change.timestamp}
              </span>
            </div>
            <p class={cn([
              "truncate text-sm",
              if(change.type == :insert,
                do: "text-emerald-700 dark:text-emerald-300",
                else: "text-red-700 line-through dark:text-red-300"
              )
            ])}>
              {change.text}
            </p>
          </div>
          <div class="flex items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100">
            <button
              type="button"
              phx-click="track_change:accept"
              phx-value-index={index}
              phx-value-panel-id={@id}
              aria-label={"Accept change: #{change.text}"}
              class="inline-flex h-7 w-7 items-center justify-center rounded text-emerald-600 hover:bg-emerald-100 dark:text-emerald-400 dark:hover:bg-emerald-950/50"
            >
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 6 9 17l-5-5" />
              </svg>
            </button>
            <button
              type="button"
              phx-click="track_change:reject"
              phx-value-index={index}
              phx-value-panel-id={@id}
              aria-label={"Reject change: #{change.text}"}
              class="inline-flex h-7 w-7 items-center justify-center rounded text-red-600 hover:bg-red-100 dark:text-red-400 dark:hover:bg-red-950/50"
            >
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 6 6 18" /><path d="m6 6 12 12" />
              </svg>
            </button>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp change_type_badge_class(:insert),
    do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300"

  defp change_type_badge_class(:delete),
    do: "bg-red-100 text-red-700 dark:bg-red-950/50 dark:text-red-300"

  defp change_type_badge_class(_), do: "bg-muted text-muted-foreground"

  # ============================================================================
  # track_change_toggle/1
  # ============================================================================

  attr :id, :string, required: true
  attr :mode, :atom, default: :editing, values: [:editing, :suggesting, :viewing]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a segmented control for switching between editing modes.

  Modes:
  - `:editing` — direct editing (no tracking)
  - `:suggesting` — changes are tracked as suggestions
  - `:viewing` — read-only view with visible tracked changes

  Emits `"track_change:mode"` phx-click events with `phx-value-mode`.

  ## Example

      <.track_change_toggle id="edit-mode" mode={@edit_mode} />
  """
  def track_change_toggle(assigns) do
    ~H"""
    <div
      id={@id}
      role="radiogroup"
      aria-label="Editing mode"
      class={cn([
        "inline-flex items-center rounded-lg border border-border bg-muted/50 p-0.5",
        @class
      ])}
      {@rest}
    >
      <button
        :for={mode <- [:editing, :suggesting, :viewing]}
        type="button"
        role="radio"
        aria-checked={to_string(mode == @mode)}
        phx-click="track_change:mode"
        phx-value-mode={mode}
        phx-value-toggle-id={@id}
        class={cn([
          "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs font-medium transition-all",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
          if(mode == @mode,
            do: "bg-background text-foreground shadow-sm",
            else: "text-muted-foreground hover:text-foreground"
          )
        ])}
      >
        <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <%= if mode == :editing do %>
            <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
          <% end %>
          <%= if mode == :suggesting do %>
            <path d="M12 20h9" /><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />
          <% end %>
          <%= if mode == :viewing do %>
            <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" />
          <% end %>
        </svg>
        {mode_label(mode)}
      </button>
    </div>
    """
  end

  defp mode_label(:editing), do: "Editing"
  defp mode_label(:suggesting), do: "Suggesting"
  defp mode_label(:viewing), do: "Viewing"

  # ============================================================================
  # accept_reject_controls/1
  # ============================================================================

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :has_changes, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a toolbar with four action buttons for tracked changes:

  1. Accept current change
  2. Reject current change
  3. Accept all changes
  4. Reject all changes

  All buttons are disabled when `:has_changes` is `false`.

  Emits phx-click events: `"track_change:accept_current"`,
  `"track_change:reject_current"`, `"track_change:accept_all"`,
  `"track_change:reject_all"` with the `editor_id` as value.

  ## Example

      <.accept_reject_controls
        id="ar-controls"
        editor_id="my-editor"
        has_changes={length(@tracked_changes) > 0}
      />
  """
  def accept_reject_controls(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label="Accept or reject changes"
      class={cn([
        "inline-flex items-center gap-1 rounded-lg border border-border bg-background p-1",
        @class
      ])}
      {@rest}
    >
      <button
        type="button"
        disabled={!@has_changes}
        phx-click="track_change:accept_current"
        phx-value-editor-id={@editor_id}
        aria-label="Accept current change"
        title="Accept current change"
        class={ar_button_class(:accept)}
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 6 9 17l-5-5" />
        </svg>
      </button>
      <button
        type="button"
        disabled={!@has_changes}
        phx-click="track_change:reject_current"
        phx-value-editor-id={@editor_id}
        aria-label="Reject current change"
        title="Reject current change"
        class={ar_button_class(:reject)}
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M18 6 6 18" /><path d="m6 6 12 12" />
        </svg>
      </button>
      <div class="mx-0.5 h-5 w-px bg-border" role="separator" aria-orientation="vertical"></div>
      <button
        type="button"
        disabled={!@has_changes}
        phx-click="track_change:accept_all"
        phx-value-editor-id={@editor_id}
        aria-label="Accept all changes"
        title="Accept all changes"
        class={ar_button_class(:accept)}
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M18 6 7 17l-5-5" /><path d="m22 10-9.5 9.5L10 17" />
        </svg>
      </button>
      <button
        type="button"
        disabled={!@has_changes}
        phx-click="track_change:reject_all"
        phx-value-editor-id={@editor_id}
        aria-label="Reject all changes"
        title="Reject all changes"
        class={ar_button_class(:reject)}
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M18 6 6 18" /><path d="m6 6 12 12" /><path d="m2 2 20 20" />
        </svg>
      </button>
    </div>
    """
  end

  defp ar_button_class(:accept) do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded text-emerald-600 transition-colors",
      "hover:bg-emerald-100 dark:text-emerald-400 dark:hover:bg-emerald-950/50",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      "disabled:pointer-events-none disabled:opacity-40"
    ])
  end

  defp ar_button_class(:reject) do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded text-red-600 transition-colors",
      "hover:bg-red-100 dark:text-red-400 dark:hover:bg-red-950/50",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      "disabled:pointer-events-none disabled:opacity-40"
    ])
  end

  defp ar_button_class(_), do: ar_button_class(:accept)

  # ============================================================================
  # change_diff_inline/1
  # ============================================================================

  attr :old_text, :string, default: ""
  attr :new_text, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an inline diff view showing the old text struck through in red
  and the new text highlighted in green.

  Uses simple `<del>` and `<ins>` elements for semantic correctness
  and accessibility.

  ## Example

      <.change_diff_inline
        old_text="Hello World"
        new_text="Hello Elixir"
      />
  """
  def change_diff_inline(assigns) do
    diff_segments = compute_inline_diff(assigns.old_text, assigns.new_text)
    assigns = assign(assigns, :diff_segments, diff_segments)

    ~H"""
    <span
      class={cn(["inline", @class])}
      {@rest}
    >
      <span :for={segment <- @diff_segments}>
        <%= case segment do %>
          <% {:equal, text} -> %>
            <span class="text-foreground">{text}</span>
          <% {:delete, text} -> %>
            <del class="rounded-sm bg-red-100 px-0.5 text-red-700 line-through decoration-red-500 decoration-2 dark:bg-red-950/50 dark:text-red-300 dark:decoration-red-400">{text}</del>
          <% {:insert, text} -> %>
            <ins class="no-underline rounded-sm bg-emerald-100 px-0.5 text-emerald-700 underline decoration-emerald-500 decoration-2 underline-offset-2 dark:bg-emerald-950/50 dark:text-emerald-300 dark:decoration-emerald-400">{text}</ins>
        <% end %>
      </span>
    </span>
    """
  end

  # Simple word-level diff algorithm. Splits both texts by words, finds the
  # longest common subsequence, and emits :equal / :delete / :insert segments.
  defp compute_inline_diff("", ""), do: []
  defp compute_inline_diff("", new_text), do: [{:insert, new_text}]
  defp compute_inline_diff(old_text, ""), do: [{:delete, old_text}]

  defp compute_inline_diff(old_text, new_text) do
    old_words = split_words(old_text)
    new_words = split_words(new_text)
    lcs = lcs_words(old_words, new_words)
    build_diff_segments(old_words, new_words, lcs)
  end

  defp split_words(text) do
    # Split into word tokens preserving whitespace as separate tokens
    Regex.scan(~r/\S+|\s+/, text)
    |> List.flatten()
  end

  # LCS via dynamic programming for word lists
  defp lcs_words(old_words, new_words) do
    old_len = Kernel.length(old_words)
    new_len = Kernel.length(new_words)
    old_indexed = Enum.with_index(old_words)
    new_indexed = Enum.with_index(new_words)

    # Build DP table
    table =
      Enum.reduce(old_indexed, %{}, fn {old_w, i}, table ->
        Enum.reduce(new_indexed, table, fn {new_w, j}, table ->
          val =
            cond do
              old_w == new_w ->
                Map.get(table, {i - 1, j - 1}, 0) + 1

              true ->
                max(
                  Map.get(table, {i - 1, j}, 0),
                  Map.get(table, {i, j - 1}, 0)
                )
            end

          Map.put(table, {i, j}, val)
        end)
      end)

    # Backtrack to find LCS
    backtrack_lcs(table, old_words, new_words, old_len - 1, new_len - 1, [])
  end

  defp backtrack_lcs(_table, _old, _new, i, _j, acc) when i < 0, do: acc
  defp backtrack_lcs(_table, _old, _new, _i, j, acc) when j < 0, do: acc

  defp backtrack_lcs(table, old_words, new_words, i, j, acc) do
    old_w = Enum.at(old_words, i)
    new_w = Enum.at(new_words, j)

    if old_w == new_w do
      backtrack_lcs(table, old_words, new_words, i - 1, j - 1, [old_w | acc])
    else
      up = Map.get(table, {i - 1, j}, 0)
      left = Map.get(table, {i, j - 1}, 0)

      if up >= left do
        backtrack_lcs(table, old_words, new_words, i - 1, j, acc)
      else
        backtrack_lcs(table, old_words, new_words, i, j - 1, acc)
      end
    end
  end

  defp build_diff_segments(old_words, new_words, lcs) do
    build_diff_segments(old_words, new_words, lcs, [])
    |> Enum.reverse()
    |> merge_diff_segments()
  end

  defp build_diff_segments([], [], [], acc), do: acc

  defp build_diff_segments([], [n | rest_new], lcs, acc) do
    build_diff_segments([], rest_new, lcs, [{:insert, n} | acc])
  end

  defp build_diff_segments([o | rest_old], [], lcs, acc) do
    build_diff_segments(rest_old, [], lcs, [{:delete, o} | acc])
  end

  defp build_diff_segments([o | rest_old], [n | rest_new], [l | rest_lcs], acc)
       when o == n and n == l do
    build_diff_segments(rest_old, rest_new, rest_lcs, [{:equal, o} | acc])
  end

  defp build_diff_segments([o | rest_old], new_words, [l | _] = lcs, acc)
       when o != l do
    build_diff_segments(rest_old, new_words, lcs, [{:delete, o} | acc])
  end

  defp build_diff_segments(old_words, [n | rest_new], [l | _] = lcs, acc)
       when n != l do
    build_diff_segments(old_words, rest_new, lcs, [{:insert, n} | acc])
  end

  # Fallback when LCS is empty
  defp build_diff_segments([o | rest_old], new_words, [], acc) do
    build_diff_segments(rest_old, new_words, [], [{:delete, o} | acc])
  end

  defp build_diff_segments([], [n | rest_new], [], acc) do
    build_diff_segments([], rest_new, [], [{:insert, n} | acc])
  end

  # Merge adjacent segments of the same type
  defp merge_diff_segments(segments) do
    Enum.reduce(segments, [], fn
      {type, text}, [{type, prev_text} | rest] ->
        [{type, prev_text <> text} | rest]

      segment, acc ->
        [segment | acc]
    end)
    |> Enum.reverse()
  end

  # ============================================================================
  # share_permissions_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :users, :list, default: []
  attr :visible, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a modal dialog for managing document sharing permissions.

  Each user in the `:users` list should be a map with:

    - `:name` — display name
    - `:email` — email address
    - `:role` — current role atom (`:owner`, `:editor`, `:commenter`, `:viewer`)

  The dialog includes a table of users with role dropdown selectors
  and a remove button per user.

  Emits phx-click/phx-change events:
  - `"share:role_change"` with `phx-value-email` and the selected role
  - `"share:remove"` with `phx-value-email`
  - `"share:close"` to dismiss the dialog

  ## Example

      <.share_permissions_dialog
        id="share-dialog"
        visible={@show_share_dialog}
        users={@shared_users}
      />
  """
  def share_permissions_dialog(assigns) do
    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="dialog"
      aria-modal="true"
      aria-labelledby={"#{@id}-title"}
      class="fixed inset-0 z-50 flex items-center justify-center"
      {@rest}
    >
      <%!-- Scrim --%>
      <div
        class="absolute inset-0 bg-black/50 backdrop-blur-sm"
        phx-click="share:close"
        phx-value-dialog-id={@id}
        aria-hidden="true"
      >
      </div>
      <%!-- Dialog --%>
      <div class={cn([
        "relative z-10 w-full max-w-lg rounded-xl border border-border bg-background shadow-xl",
        "animate-in fade-in-0 zoom-in-95",
        @class
      ])}>
        <%!-- Header --%>
        <div class="flex items-center justify-between border-b border-border px-6 py-4">
          <h2 id={"#{@id}-title"} class="text-base font-semibold text-foreground">
            Share & Permissions
          </h2>
          <button
            type="button"
            phx-click="share:close"
            phx-value-dialog-id={@id}
            aria-label="Close dialog"
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 6 6 18" /><path d="m6 6 12 12" />
            </svg>
          </button>
        </div>
        <%!-- Body --%>
        <div class="px-6 py-4">
          <div :if={@users == []} class="flex items-center justify-center py-8">
            <p class="text-sm text-muted-foreground">No users have been shared with yet.</p>
          </div>
          <table :if={@users != []} class="w-full">
            <thead>
              <tr class="text-left text-xs font-medium text-muted-foreground">
                <th class="pb-2 pr-4">User</th>
                <th class="pb-2 pr-4">Role</th>
                <th class="pb-2 w-10"><span class="sr-only">Actions</span></th>
              </tr>
            </thead>
            <tbody class="divide-y divide-border">
              <tr :for={user <- @users} class="group">
                <td class="py-2.5 pr-4">
                  <div class="flex flex-col">
                    <span class="text-sm font-medium text-foreground">{user.name}</span>
                    <span class="text-xs text-muted-foreground">{user.email}</span>
                  </div>
                </td>
                <td class="py-2.5 pr-4">
                  <select
                    name={"role-#{user.email}"}
                    phx-change="share:role_change"
                    phx-value-email={user.email}
                    phx-value-dialog-id={@id}
                    class={cn([
                      "h-8 rounded-md border border-input bg-background px-2 text-xs text-foreground",
                      "focus:outline-none focus:ring-1 focus:ring-ring"
                    ])}
                    disabled={Map.get(user, :role) == :owner}
                  >
                    <option value="owner" selected={Map.get(user, :role) == :owner}>Owner</option>
                    <option value="editor" selected={Map.get(user, :role) == :editor}>Editor</option>
                    <option value="commenter" selected={Map.get(user, :role) == :commenter}>Commenter</option>
                    <option value="viewer" selected={Map.get(user, :role) == :viewer}>Viewer</option>
                  </select>
                </td>
                <td class="py-2.5">
                  <button
                    :if={Map.get(user, :role) != :owner}
                    type="button"
                    phx-click="share:remove"
                    phx-value-email={user.email}
                    phx-value-dialog-id={@id}
                    aria-label={"Remove #{user.name}"}
                    class="inline-flex h-7 w-7 items-center justify-center rounded text-muted-foreground opacity-0 transition-opacity hover:bg-destructive/10 hover:text-destructive group-hover:opacity-100"
                  >
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <%!-- Footer --%>
        <div class="flex items-center justify-end gap-2 border-t border-border px-6 py-3">
          <button
            type="button"
            phx-click="share:close"
            phx-value-dialog-id={@id}
            class="inline-flex h-9 items-center justify-center rounded-md border border-input bg-background px-4 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Done
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # auto_save_indicator/1
  # ============================================================================

  attr :status, :atom, default: :saved, values: [:saved, :saving, :unsaved, :error]
  attr :last_saved, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a compact auto-save status indicator with a colored dot and label.

  Statuses:
  - `:saved` — green dot, "Saved" text
  - `:saving` — amber animated dot, "Saving..." text
  - `:unsaved` — gray dot, "Unsaved changes" text
  - `:error` — red dot, "Save failed" text

  When `:last_saved` is provided, it is displayed as secondary text for
  the `:saved` status.

  ## Example

      <.auto_save_indicator status={:saving} />
      <.auto_save_indicator status={:saved} last_saved="2 min ago" />
  """
  def auto_save_indicator(assigns) do
    ~H"""
    <div
      role="status"
      aria-live="polite"
      aria-label={status_aria_label(@status)}
      class={cn([
        "inline-flex items-center gap-1.5 text-xs",
        @class
      ])}
      {@rest}
    >
      <span class={cn([
        "relative flex h-2 w-2",
        status_dot_class(@status)
      ])}>
        <span
          :if={@status == :saving}
          class="absolute inline-flex h-full w-full animate-ping rounded-full bg-amber-400 opacity-75"
        >
        </span>
        <span class={cn([
          "relative inline-flex h-2 w-2 rounded-full",
          status_dot_fill(@status)
        ])}>
        </span>
      </span>
      <span class={cn(["font-medium", status_text_class(@status)])}>
        {status_label(@status)}
      </span>
      <span
        :if={@status == :saved && @last_saved}
        class="text-muted-foreground"
      >
        {@last_saved}
      </span>
    </div>
    """
  end

  defp status_dot_class(:saving), do: ""
  defp status_dot_class(_), do: ""

  defp status_dot_fill(:saved), do: "bg-emerald-500"
  defp status_dot_fill(:saving), do: "bg-amber-500"
  defp status_dot_fill(:unsaved), do: "bg-gray-400 dark:bg-gray-500"
  defp status_dot_fill(:error), do: "bg-red-500"

  defp status_text_class(:saved), do: "text-emerald-600 dark:text-emerald-400"
  defp status_text_class(:saving), do: "text-amber-600 dark:text-amber-400"
  defp status_text_class(:unsaved), do: "text-muted-foreground"
  defp status_text_class(:error), do: "text-red-600 dark:text-red-400"

  defp status_label(:saved), do: "Saved"
  defp status_label(:saving), do: "Saving..."
  defp status_label(:unsaved), do: "Unsaved changes"
  defp status_label(:error), do: "Save failed"

  defp status_aria_label(:saved), do: "Document saved"
  defp status_aria_label(:saving), do: "Saving document"
  defp status_aria_label(:unsaved), do: "Document has unsaved changes"
  defp status_aria_label(:error), do: "Failed to save document"
end
