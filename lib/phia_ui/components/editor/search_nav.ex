defmodule PhiaUi.Components.Editor.SearchNav do
  @moduledoc """
  Editor Search & Navigation Suite — 6 components for document search, outline
  navigation, keyboard shortcuts, and minimap visualization.

  ## Components

  - `regex_search_bar/1`         — search + replace bar with regex/case/word toggles
  - `document_outline/1`         — nested heading list for document navigation
  - `navigation_pane/1`          — tabbed sidebar with outline, bookmarks, and comments
  - `keyboard_shortcuts_panel/1` — grouped shortcut reference with `<kbd>` tags
  - `go_to_line/1`               — small dialog to jump to a specific line number
  - `minimap/1`                  — thin vertical document minimap with viewport indicator
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. regex_search_bar/1
  # ============================================================================

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :query, :string, default: ""
  attr :replace_text, :string, default: ""
  attr :match_count, :integer, default: 0
  attr :current_match, :integer, default: 0
  attr :use_regex, :boolean, default: false
  attr :case_sensitive, :boolean, default: false
  attr :whole_word, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a search + replace bar with regex, case-sensitivity, and whole-word
  toggle buttons, plus prev/next navigation and replace/replace-all actions.

  The match counter displays "N of M" when matches are found.

  ## Example

      <.regex_search_bar
        id="search"
        editor_id="my-editor"
        query={@search_query}
        match_count={@match_count}
        current_match={@current_match}
      />
  """
  def regex_search_bar(assigns) do
    ~H"""
    <div
      id={@id}
      role="search"
      aria-label="Find and replace"
      class={cn([
        "flex flex-col gap-1.5 rounded-lg border border-border bg-popover p-2 shadow-md",
        "animate-[phia-find-slide_150ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <%!-- Search row --%>
      <div class="flex items-center gap-1">
        <div class="relative flex-1">
          <input
            type="text"
            id={"#{@id}-query"}
            name="query"
            value={@query}
            placeholder="Find..."
            aria-label="Search text"
            phx-keydown="search:find"
            phx-target={"##{@id}"}
            class="h-7 w-full rounded border border-border bg-background pl-2 pr-16 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          />
          <span
            :if={@query != ""}
            class="absolute right-2 top-1/2 -translate-y-1/2 text-[10px] text-muted-foreground tabular-nums"
          >
            {if @match_count > 0, do: "#{@current_match} of #{@match_count}", else: "No results"}
          </span>
        </div>

        <%!-- Toggle buttons --%>
        <button
          type="button"
          phx-click="search:toggle_regex"
          aria-label="Use regular expression"
          aria-pressed={to_string(@use_regex)}
          title="Regex"
          class={cn([search_toggle_class(), @use_regex && "bg-accent text-accent-foreground"])}
        >
          <span class="text-[10px] font-mono font-bold">.*</span>
        </button>
        <button
          type="button"
          phx-click="search:toggle_case"
          aria-label="Match case"
          aria-pressed={to_string(@case_sensitive)}
          title="Match Case"
          class={cn([search_toggle_class(), @case_sensitive && "bg-accent text-accent-foreground"])}
        >
          <span class="text-[10px] font-bold">Aa</span>
        </button>
        <button
          type="button"
          phx-click="search:toggle_word"
          aria-label="Match whole word"
          aria-pressed={to_string(@whole_word)}
          title="Whole Word"
          class={cn([search_toggle_class(), @whole_word && "bg-accent text-accent-foreground"])}
        >
          <span class="text-[10px] font-bold underline">ab</span>
        </button>

        <%!-- Nav buttons --%>
        <div class="flex items-center gap-0.5 ml-1">
          <button
            type="button"
            phx-click="search:prev"
            aria-label="Previous match"
            title="Previous"
            disabled={@match_count == 0}
            class={search_nav_class()}
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
              <path d="M11 13l-5-5 5-5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </button>
          <button
            type="button"
            phx-click="search:next"
            aria-label="Next match"
            title="Next"
            disabled={@match_count == 0}
            class={search_nav_class()}
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
              <path d="M5 3l5 5-5 5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </button>
        </div>
      </div>

      <%!-- Replace row --%>
      <div class="flex items-center gap-1">
        <input
          type="text"
          id={"#{@id}-replace"}
          name="replace"
          value={@replace_text}
          placeholder="Replace..."
          aria-label="Replace text"
          class="h-7 flex-1 rounded border border-border bg-background px-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring"
        />
        <button
          type="button"
          phx-click="search:replace"
          aria-label="Replace current match"
          title="Replace"
          disabled={@match_count == 0}
          class={cn([search_nav_class(), "px-2"])}
        >
          <span class="text-[10px] font-medium">Replace</span>
        </button>
        <button
          type="button"
          phx-click="search:replace_all"
          aria-label="Replace all matches"
          title="Replace All"
          disabled={@match_count == 0}
          class={cn([search_nav_class(), "px-2"])}
        >
          <span class="text-[10px] font-medium">All</span>
        </button>
      </div>
    </div>
    """
  end

  defp search_toggle_class do
    "inline-flex h-6 w-6 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
  end

  defp search_nav_class do
    "inline-flex h-6 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-40"
  end

  # ============================================================================
  # 2. document_outline/1
  # ============================================================================

  attr :id, :string, required: true
  attr :headings, :list, default: []
  attr :active_id, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a nested navigation list of document headings indented by level.

  Each heading is a map with `:id`, `:text`, and `:level` (1-6) keys.
  The `active_id` highlights the currently visible heading.

  ## Example

      <.document_outline
        id="outline"
        active_id="heading-2"
        headings={[
          %{id: "heading-1", text: "Introduction", level: 1},
          %{id: "heading-2", text: "Methods", level: 2}
        ]}
      />
  """
  def document_outline(assigns) do
    ~H"""
    <nav
      id={@id}
      aria-label="Document outline"
      class={cn(["text-sm", @class])}
      {@rest}
    >
      <ul :if={@headings != []} class="space-y-0.5">
        <li :for={heading <- @headings}>
          <a
            href={"##{Map.get(heading, :id, "")}"}
            class={cn([
              "block truncate rounded px-2 py-1 text-sm transition-colors",
              "hover:bg-accent hover:text-accent-foreground",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
              outline_indent(Map.get(heading, :level, 1)),
              @active_id == Map.get(heading, :id) && "bg-accent/50 font-medium text-accent-foreground",
              @active_id != Map.get(heading, :id) && "text-muted-foreground"
            ])}
          >
            {Map.get(heading, :text, "")}
          </a>
        </li>
      </ul>
      <p :if={@headings == []} class="px-2 py-3 text-center text-xs text-muted-foreground">
        No headings found
      </p>
    </nav>
    """
  end

  defp outline_indent(1), do: "pl-2"
  defp outline_indent(2), do: "pl-5"
  defp outline_indent(3), do: "pl-8"
  defp outline_indent(4), do: "pl-11"
  defp outline_indent(5), do: "pl-14"
  defp outline_indent(_), do: "pl-16"

  # ============================================================================
  # 3. navigation_pane/1
  # ============================================================================

  attr :id, :string, required: true
  attr :active_tab, :atom, default: :outline, values: [:outline, :bookmarks, :comments]
  attr :headings, :list, default: []
  attr :bookmarks, :list, default: []
  attr :comments, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a tabbed navigation sidebar with outline, bookmarks, and comments panels.

  Each bookmark is a map with `:id` and `:name` keys.
  Each comment is a map with `:id`, `:text`, and `:author` keys.

  ## Example

      <.navigation_pane
        id="nav-pane"
        active_tab={:outline}
        headings={@doc_headings}
        bookmarks={@doc_bookmarks}
        comments={@doc_comments}
      />
  """
  def navigation_pane(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col rounded-lg border border-border bg-card", @class])}
      {@rest}
    >
      <%!-- Tab bar --%>
      <div role="tablist" class="flex border-b border-border">
        <button
          :for={tab <- [:outline, :bookmarks, :comments]}
          type="button"
          role="tab"
          aria-selected={to_string(@active_tab == tab)}
          aria-controls={"#{@id}-panel-#{tab}"}
          phx-click="nav_pane:tab"
          phx-value-tab={tab}
          class={cn([
            "flex-1 px-3 py-2 text-xs font-medium transition-colors",
            "hover:text-foreground",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
            @active_tab == tab && "border-b-2 border-primary text-foreground",
            @active_tab != tab && "text-muted-foreground"
          ])}
        >
          {tab_label(tab)}
        </button>
      </div>

      <%!-- Panels --%>
      <div class="flex-1 overflow-y-auto p-2">
        <%!-- Outline panel --%>
        <div
          :if={@active_tab == :outline}
          id={"#{@id}-panel-outline"}
          role="tabpanel"
        >
          <ul :if={@headings != []} class="space-y-0.5">
            <li :for={h <- @headings}>
              <a
                href={"##{Map.get(h, :id, "")}"}
                class="block truncate rounded px-2 py-1 text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
                style={"padding-left: #{(Map.get(h, :level, 1) - 1) * 12 + 8}px"}
              >
                {Map.get(h, :text, "")}
              </a>
            </li>
          </ul>
          <p :if={@headings == []} class="py-4 text-center text-xs text-muted-foreground">No headings</p>
        </div>

        <%!-- Bookmarks panel --%>
        <div
          :if={@active_tab == :bookmarks}
          id={"#{@id}-panel-bookmarks"}
          role="tabpanel"
        >
          <ul :if={@bookmarks != []} class="space-y-0.5">
            <li :for={b <- @bookmarks}>
              <a
                href={"##{Map.get(b, :id, "")}"}
                class="flex items-center gap-2 rounded px-2 py-1.5 text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
              >
                <svg class="h-3.5 w-3.5 shrink-0" viewBox="0 0 16 16" fill="none">
                  <path d="M4 2v12l4-3 4 3V2H4z" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round" />
                </svg>
                <span class="truncate">{Map.get(b, :name, "")}</span>
              </a>
            </li>
          </ul>
          <p :if={@bookmarks == []} class="py-4 text-center text-xs text-muted-foreground">No bookmarks</p>
        </div>

        <%!-- Comments panel --%>
        <div
          :if={@active_tab == :comments}
          id={"#{@id}-panel-comments"}
          role="tabpanel"
        >
          <ul :if={@comments != []} class="space-y-1">
            <li
              :for={c <- @comments}
              class="rounded border border-border/50 px-2 py-1.5"
            >
              <span class="block text-xs font-medium text-foreground">{Map.get(c, :author, "")}</span>
              <span class="block text-xs text-muted-foreground line-clamp-2">{Map.get(c, :text, "")}</span>
            </li>
          </ul>
          <p :if={@comments == []} class="py-4 text-center text-xs text-muted-foreground">No comments</p>
        </div>
      </div>
    </div>
    """
  end

  defp tab_label(:outline), do: "Outline"
  defp tab_label(:bookmarks), do: "Bookmarks"
  defp tab_label(:comments), do: "Comments"

  # ============================================================================
  # 4. keyboard_shortcuts_panel/1
  # ============================================================================

  attr :id, :string, required: true
  attr :shortcuts, :list, default: []
  attr :visible, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a grouped keyboard shortcut reference panel.

  Each shortcut is a map with `:key`, `:description`, and `:category` keys.
  Shortcuts are grouped by category and displayed with `<kbd>` styled tags.

  ## Example

      <.keyboard_shortcuts_panel
        id="shortcuts"
        visible={true}
        shortcuts={[
          %{key: "Ctrl+B", description: "Bold", category: "Formatting"},
          %{key: "Ctrl+I", description: "Italic", category: "Formatting"},
          %{key: "Ctrl+F", description: "Find", category: "Navigation"}
        ]}
      />
  """
  def keyboard_shortcuts_panel(assigns) do
    grouped =
      assigns.shortcuts
      |> Enum.group_by(&Map.get(&1, :category, "General"))
      |> Enum.sort_by(fn {cat, _} -> cat end)

    assigns = assign(assigns, :grouped, grouped)

    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="dialog"
      aria-label="Keyboard shortcuts"
      class={cn([
        "rounded-lg border border-border bg-popover p-4 shadow-lg",
        "animate-[phia-bubble-in_150ms_ease-out]",
        "max-h-96 overflow-y-auto",
        @class
      ])}
      {@rest}
    >
      <h3 class="text-sm font-semibold text-foreground mb-3">Keyboard Shortcuts</h3>
      <div class="space-y-4">
        <div :for={{category, items} <- @grouped}>
          <h4 class="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-1.5">{category}</h4>
          <dl class="space-y-1">
            <div
              :for={shortcut <- items}
              class="flex items-center justify-between gap-4"
            >
              <dt class="text-sm text-foreground">{Map.get(shortcut, :description, "")}</dt>
              <dd class="shrink-0">
                <kbd class="inline-flex items-center gap-0.5 rounded border border-border bg-muted px-1.5 py-0.5 text-[10px] font-mono font-medium text-muted-foreground">
                  {Map.get(shortcut, :key, "")}
                </kbd>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 5. go_to_line/1
  # ============================================================================

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :visible, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a small dialog with a line number input and "Go" button.

  Hidden when `visible` is false.

  ## Example

      <.go_to_line id="goto" editor_id="my-editor" visible={@show_goto} />
  """
  def go_to_line(assigns) do
    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="dialog"
      aria-label="Go to line"
      class={cn([
        "flex items-center gap-2 rounded-lg border border-border bg-popover p-2 shadow-lg",
        "animate-[phia-find-slide_150ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <label for={"#{@id}-input"} class="text-xs font-medium text-muted-foreground whitespace-nowrap">
        Go to line:
      </label>
      <input
        id={"#{@id}-input"}
        type="number"
        name="line"
        min="1"
        placeholder="Line"
        aria-label="Line number"
        phx-keydown="goto:submit"
        phx-key="Enter"
        phx-value-editor-id={@editor_id}
        class="h-7 w-20 rounded border border-border bg-background px-2 text-sm text-foreground tabular-nums focus:outline-none focus:ring-1 focus:ring-ring"
      />
      <button
        type="button"
        phx-click="goto:go"
        phx-value-editor-id={@editor_id}
        class="h-7 rounded bg-primary px-3 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
      >
        Go
      </button>
      <button
        type="button"
        phx-click="goto:close"
        aria-label="Close"
        class="inline-flex h-6 w-6 items-center justify-center rounded text-muted-foreground hover:bg-accent transition-colors"
      >
        <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
          <path d="M4 4l8 8M12 4l-8 8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
        </svg>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 6. minimap/1
  # ============================================================================

  attr :id, :string, required: true
  attr :content_height, :integer, default: 1000
  attr :viewport_height, :integer, default: 500
  attr :scroll_position, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a thin vertical minimap bar with a viewport position indicator.

  The minimap shows the relative position and size of the viewport within
  the full document height.

  ## Example

      <.minimap
        id="minimap"
        content_height={2000}
        viewport_height={600}
        scroll_position={350}
      />
  """
  def minimap(assigns) do
    content_h = max(1, assigns.content_height)
    viewport_h = min(assigns.viewport_height, content_h)
    scroll_pos = max(0, min(assigns.scroll_position, content_h - viewport_h))

    # Map height is fixed at 200px; compute viewport indicator proportionally
    map_height = 200
    indicator_h = max(12, round(viewport_h / content_h * map_height))
    indicator_top = round(scroll_pos / content_h * map_height)

    assigns =
      assigns
      |> assign(:map_height, map_height)
      |> assign(:indicator_h, indicator_h)
      |> assign(:indicator_top, indicator_top)

    ~H"""
    <div
      id={@id}
      role="presentation"
      aria-label="Document minimap"
      class={cn(["relative w-8 shrink-0", @class])}
      style={"height: #{@map_height}px"}
      {@rest}
    >
      <%!-- Track --%>
      <div class="absolute inset-0 rounded bg-muted/50" />

      <%!-- Viewport indicator --%>
      <div
        class="absolute left-0.5 right-0.5 rounded-sm bg-primary/20 border border-primary/30 transition-all duration-100"
        style={"top: #{@indicator_top}px; height: #{@indicator_h}px"}
      />

      <%!-- Position lines (decorative content hint) --%>
      <div class="absolute inset-x-1 top-0 bottom-0 flex flex-col justify-evenly pointer-events-none">
        <div :for={_ <- 1..8} class="h-px w-full bg-muted-foreground/10" />
      </div>
    </div>
    """
  end
end
