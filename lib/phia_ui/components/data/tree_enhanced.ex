defmodule PhiaUi.Components.TreeEnhanced do
  @moduledoc """
  Enhanced tree view components for PhiaUI.

  10 components extending the base `tree/1` and `tree_item/1` with icons,
  tri-state checkboxes, file-system display, search filtering, lazy loading,
  and virtual rendering for large datasets.

  ## Component Overview

  | Component          | Tier           | Key Feature                              |
  |--------------------|----------------|------------------------------------------|
  | `icon_tree`        | `:widget`      | Tree root with icon support              |
  | `icon_tree_item`   | `:widget`      | Leaf/branch + Lucide icon + badge        |
  | `checkbox_tree`    | `:interactive` | Tri-state checkbox tree root             |
  | `checkbox_tree_item` | `:interactive` | Checkbox item with indeterminate state |
  | `searchable_tree`  | `:widget`      | Tree with search input above             |
  | `file_tree`        | `:widget`      | File-system display tree root            |
  | `file_tree_item`   | `:widget`      | File/folder item with extension icon     |
  | `lazy_tree`        | `:interactive` | Tree root with lazy-load hook            |
  | `lazy_tree_item`   | `:interactive` | Item with loading/loaded states          |
  | `virtual_tree`     | `:widget`      | Hook-owned virtual rendering tree        |

  ## Hooks required

  - `PhiaCheckboxTree` — checkbox_tree, checkbox_tree_item (sets `.indeterminate`)
  - `PhiaLazyTree` — lazy_tree, lazy_tree_item (fires expand events)
  - `PhiaVirtualTree` — virtual_tree (owns DOM rendering)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # icon_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Tree root with icon-item support.

  ## Example

      <.icon_tree id="nav-tree">
        <.icon_tree_item label="Components" icon="layers" expandable={true}>
          <.icon_tree_item label="Button" icon="square" />
        </.icon_tree_item>
      </.icon_tree>
  """
  def icon_tree(assigns) do
    ~H"""
    <ul id={@id} role="tree" class={cn(["text-sm space-y-0.5", @class])} {@rest}>
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # icon_tree_item/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true)
  attr(:icon, :string, default: nil, doc: "Lucide icon name shown before the label")
  attr(:badge, :string, default: nil, doc: "Optional badge text")
  attr(:badge_variant, :string, default: "secondary", doc: "Badge color variant string")
  attr(:href, :string, default: nil, doc: "When set, renders label as `<a>` link")
  attr(:expandable, :boolean, default: false)
  attr(:expanded, :boolean, default: false)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:on_click, :string, default: nil)
  attr(:value, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block)

  @doc """
  Tree item with optional icon, badge, href, and expandable branch support.

  Uses `<details>/<summary>` for branches (zero-JS expand/collapse).
  Disabled items are non-interactive and visually dimmed.

  ## Example

      <.icon_tree_item label="Settings" icon="settings" on_click="nav" value="settings" />

      <.icon_tree_item label="src" icon="folder" expandable={true} expanded={true}>
        <.icon_tree_item label="app.ex" icon="file-code" />
      </.icon_tree_item>
  """
  def icon_tree_item(%{expandable: true} = assigns) do
    ~H"""
    <li role="treeitem" aria-expanded={to_string(@expanded)} class={cn(["list-none", @disabled && "opacity-50 pointer-events-none"])}>
      <details open={@expanded}>
        <summary class={cn([
          "flex items-center gap-1.5 py-1 px-2 rounded-md cursor-pointer list-none",
          "hover:bg-accent hover:text-accent-foreground select-none",
          @selected && "bg-accent text-accent-foreground",
          @class
        ])}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-3.5 w-3.5 shrink-0 transition-transform details-open:rotate-90 text-muted-foreground"
          >
            <polyline points="9 18 15 12 9 6" />
          </svg>
          <.icon :if={@icon} name={@icon} class="h-4 w-4 shrink-0 text-muted-foreground" />
          <span class="flex-1 truncate">{@label}</span>
          <span
            :if={@badge}
            class="ml-auto text-xs px-1.5 py-0.5 rounded bg-secondary text-secondary-foreground"
          >
            {@badge}
          </span>
        </summary>
        <ul role="group" class="ml-4 mt-0.5 space-y-0.5">
          {render_slot(@inner_block)}
        </ul>
      </details>
    </li>
    """
  end

  def icon_tree_item(assigns) do
    ~H"""
    <li role="treeitem" aria-selected={to_string(@selected)} class={cn(["list-none", @disabled && "opacity-50 pointer-events-none"])}>
      <a
        :if={@href}
        href={@href}
        class={cn([
          "flex items-center gap-1.5 py-1 px-2 pl-[26px] rounded-md",
          "hover:bg-accent hover:text-accent-foreground",
          @selected && "bg-accent text-accent-foreground font-medium",
          @class
        ])}
      >
        <.icon :if={@icon} name={@icon} class="h-4 w-4 shrink-0 text-muted-foreground" />
        <span class="flex-1 truncate">{@label}</span>
        <span
          :if={@badge}
          class="ml-auto text-xs px-1.5 py-0.5 rounded bg-secondary text-secondary-foreground"
        >
          {@badge}
        </span>
      </a>
      <div
        :if={!@href}
        class={cn([
          "flex items-center gap-1.5 py-1 px-2 pl-[26px] rounded-md cursor-pointer",
          "hover:bg-accent hover:text-accent-foreground",
          @selected && "bg-accent text-accent-foreground font-medium",
          @class
        ])}
        phx-click={@on_click}
        phx-value-value={@value}
      >
        <.icon :if={@icon} name={@icon} class="h-4 w-4 shrink-0 text-muted-foreground" />
        <span class="flex-1 truncate">{@label}</span>
        <span
          :if={@badge}
          class="ml-auto text-xs px-1.5 py-0.5 rounded bg-secondary text-secondary-foreground"
        >
          {@badge}
        </span>
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # checkbox_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Checkbox tree root. Requires `PhiaCheckboxTree` hook to set the
  `.indeterminate` JS property on items with `data-indeterminate="true"`.

  ## Example

      <.checkbox_tree id="permission-tree">
        <.checkbox_tree_item
          id="perm-read"
          label="Read"
          checked={:read in @permissions}
          on_check="toggle_permission"
          value="read"
        />
      </.checkbox_tree>
  """
  def checkbox_tree(assigns) do
    ~H"""
    <ul
      id={@id}
      role="tree"
      phx-hook="PhiaCheckboxTree"
      class={cn(["text-sm space-y-1", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # checkbox_tree_item/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID for the checkbox element")
  attr(:label, :string, required: true)
  attr(:checked, :boolean, default: false)
  attr(:indeterminate, :boolean, default: false, doc: "Server-computed partial-check state")
  attr(:on_check, :string, default: "check_tree_item", doc: "phx-click event name")
  attr(:value, :string, default: nil, doc: "phx-value-value sent on check")
  attr(:depth, :integer, default: 0, doc: "Indentation depth (multiplied by ml-4)")
  attr(:class, :string, default: nil)
  slot(:inner_block)

  @doc """
  Checkbox tree item with tri-state support.

  The `.indeterminate` JS property is set by the `PhiaCheckboxTree` hook on
  `mounted()` and `updated()` when `data-indeterminate="true"`.

  ## Example

      <.checkbox_tree_item
        id="item-files"
        label="Files"
        checked={:files in @checked}
        indeterminate={has_partial_check?(@checked, @file_ids)}
        on_check="toggle_perm"
        value="files"
      >
        <.checkbox_tree_item id="item-read" label="Read" checked={:read in @checked} />
      </.checkbox_tree_item>
  """
  def checkbox_tree_item(assigns) do
    ~H"""
    <li
      role="treeitem"
      aria-checked={if @indeterminate, do: "mixed", else: to_string(@checked)}
      class={cn(["list-none", @class])}
      style={"margin-left: #{@depth * 1}rem;"}
    >
      <label class="flex items-center gap-2 py-0.5 px-2 rounded-md hover:bg-accent cursor-pointer">
        <input
          type="checkbox"
          id={@id}
          checked={@checked}
          data-indeterminate={to_string(@indeterminate)}
          phx-click={@on_check}
          phx-value-value={@value}
          class="h-4 w-4 rounded border-border accent-primary"
          aria-label={@label}
        />
        <span class="text-sm">{@label}</span>
      </label>
      <ul :if={@inner_block != []} role="group" class="ml-4 mt-0.5 space-y-0.5">
        {render_slot(@inner_block)}
      </ul>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # searchable_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:search_placeholder, :string, default: "Search...")
  attr(:on_search, :string, default: "search_tree", doc: "phx-change event for search input")
  attr(:search_value, :string, default: "", doc: "Current search value for controlled input")
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  @doc """
  Tree with a search input above. Filtering logic lives in the LiveView.

  The search input fires `on_search` with `phx-debounce="200"`. Your
  LiveView filters the tree data and re-renders only matching items.

  ## Example

      <.searchable_tree id="file-search" on_search="filter_files" search_value={@search}>
        <.icon_tree_item :for={file <- @filtered_files} label={file.name} icon="file" />
      </.searchable_tree>
  """
  def searchable_tree(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <div class="relative">
        <.icon name="search" class="absolute left-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
        <input
          type="search"
          placeholder={@search_placeholder}
          value={@search_value}
          phx-change={@on_search}
          phx-debounce="200"
          class="w-full rounded-md border border-input bg-background pl-7 pr-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
        />
      </div>
      <ul id={@id} role="tree" class="text-sm space-y-0.5">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # file_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  File-system display tree root.

  ## Example

      <.file_tree id="project-files">
        <.file_tree_item label="src" type={:folder} expanded={true}>
          <.file_tree_item label="app.ex" type={:file} />
        </.file_tree_item>
      </.file_tree>
  """
  def file_tree(assigns) do
    ~H"""
    <ul
      id={@id}
      role="tree"
      aria-label="File tree"
      class={cn(["text-sm space-y-0.5 font-mono", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # file_tree_item/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "File or folder name")
  attr(:type, :atom, default: :file, values: [:file, :folder], doc: "Item type")
  attr(:expanded, :boolean, default: false)
  attr(:selected, :boolean, default: false)
  attr(:size, :string, default: nil, doc: "Optional file size string (e.g. '4.2 KB')")
  attr(:modified, :string, default: nil, doc: "Optional last-modified string")
  attr(:on_click, :string, default: nil)
  attr(:value, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block)

  @doc """
  File or folder tree item with extension-based icon.

  Folders show a folder icon and use `<details>/<summary>`.
  Files show a file-type icon based on their extension.

  ## Example

      <.file_tree_item label="mix.exs" type={:file} on_click="open" value="mix.exs" />

      <.file_tree_item label="lib" type={:folder} expanded={true}>
        <.file_tree_item label="app.ex" type={:file} />
      </.file_tree_item>
  """
  def file_tree_item(%{type: :folder} = assigns) do
    ext = assigns.label |> Path.extname() |> String.trim_leading(".")
    assigns = assign(assigns, :icon_name, file_icon(ext))

    ~H"""
    <li role="treeitem" aria-expanded={to_string(@expanded)} class="list-none">
      <details open={@expanded}>
        <summary class={cn([
          "flex items-center gap-1.5 py-0.5 px-2 rounded cursor-pointer list-none",
          "hover:bg-accent hover:text-accent-foreground select-none",
          @selected && "bg-accent",
          @class
        ])}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-3.5 w-3.5 shrink-0 transition-transform details-open:rotate-90 text-muted-foreground"
          >
            <polyline points="9 18 15 12 9 6" />
          </svg>
          <.icon name="folder" class="h-4 w-4 shrink-0 text-amber-500 dark:text-amber-400" />
          <span class="flex-1 truncate">{@label}</span>
        </summary>
        <ul role="group" class="ml-4 mt-0.5 space-y-0.5">
          {render_slot(@inner_block)}
        </ul>
      </details>
    </li>
    """
  end

  def file_tree_item(assigns) do
    ext = assigns.label |> Path.extname() |> String.trim_leading(".")
    assigns = assign(assigns, :icon_name, file_icon(ext))

    ~H"""
    <li role="treeitem" aria-selected={to_string(@selected)} class="list-none">
      <div
        class={cn([
          "flex items-center gap-1.5 py-0.5 px-2 pl-7 rounded cursor-pointer",
          "hover:bg-accent hover:text-accent-foreground",
          @selected && "bg-accent",
          @class
        ])}
        phx-click={@on_click}
        phx-value-value={@value}
      >
        <.icon name={@icon_name} class="h-4 w-4 shrink-0 text-muted-foreground" />
        <span class="flex-1 truncate">{@label}</span>
        <span :if={@size} class="text-xs text-muted-foreground ml-auto">{@size}</span>
        <span :if={@modified} class="text-xs text-muted-foreground ml-2">{@modified}</span>
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # lazy_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook)")
  attr(:on_expand, :string, default: "tree_expand", doc: "push_event name when a node expands")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Tree root with lazy-load support via the `PhiaLazyTree` hook.

  When a `lazy_tree_item` is expanded by the user, the hook fires
  `push_event(@on_expand, %{"id" => item_id})` to the LiveView, which
  can load children and update the item's `loaded` assign.

  ## Example

      <.lazy_tree id="repo-tree" on_expand="load_children">
        <.lazy_tree_item id="src" label="src" expandable={true} loaded={@src_loaded}>
          <.lazy_tree_item :for={f <- @src_files} id={f.id} label={f.name} />
        </.lazy_tree_item>
      </.lazy_tree>
  """
  def lazy_tree(assigns) do
    ~H"""
    <ul
      id={@id}
      role="tree"
      phx-hook="PhiaLazyTree"
      data-on-expand={@on_expand}
      class={cn(["text-sm space-y-0.5", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # lazy_tree_item/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Node ID sent to the hook on expand")
  attr(:label, :string, required: true)
  attr(:expandable, :boolean, default: false)
  attr(:expanded, :boolean, default: false)
  attr(:loading, :boolean, default: false, doc: "Shows a spinner while children load")
  attr(:loaded, :boolean, default: false, doc: "When true, children are present and loading is done")
  attr(:class, :string, default: nil)
  slot(:inner_block)

  @doc """
  Lazy tree item. Fires an expand event to load children on first open.

  When `loading` is `true`, shows a spinner instead of children.
  When `loaded` is `true`, children are rendered normally.

  ## Example

      <.lazy_tree_item id="src-dir" label="src" expandable={true} loaded={@src_loaded} loading={@src_loading}>
        <.lazy_tree_item :for={f <- @src_files} id={f.id} label={f.name} />
      </.lazy_tree_item>
  """
  def lazy_tree_item(%{expandable: true} = assigns) do
    ~H"""
    <li
      role="treeitem"
      aria-expanded={to_string(@expanded)}
      data-node-id={@id}
      data-loaded={to_string(@loaded)}
      class={cn(["list-none", @class])}
    >
      <details open={@expanded}>
        <summary class="flex items-center gap-1.5 py-1 px-2 rounded-md cursor-pointer list-none hover:bg-accent hover:text-accent-foreground select-none">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="h-3.5 w-3.5 shrink-0 transition-transform details-open:rotate-90 text-muted-foreground"
          >
            <polyline points="9 18 15 12 9 6" />
          </svg>
          <span class="flex-1 truncate">{@label}</span>
          <.icon :if={@loading} name="loader-circle" class="h-3.5 w-3.5 animate-spin text-muted-foreground" />
        </summary>
        <ul role="group" class="ml-4 mt-0.5 space-y-0.5">
          {render_slot(@inner_block)}
        </ul>
      </details>
    </li>
    """
  end

  def lazy_tree_item(assigns) do
    ~H"""
    <li
      role="treeitem"
      data-node-id={@id}
      data-loaded={to_string(@loaded)}
      class={cn(["list-none", @class])}
    >
      <div class="flex items-center gap-1.5 py-1 px-2 pl-7 rounded-md cursor-pointer hover:bg-accent hover:text-accent-foreground">
        <span class="flex-1 truncate">{@label}</span>
        <.icon :if={@loading} name="loader-circle" class="h-3.5 w-3.5 animate-spin text-muted-foreground" />
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # virtual_tree/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook)")
  attr(:nodes, :list, required: true, doc: "Flat list of node maps with :id, :label, :depth, :expandable, :expanded")
  attr(:row_height, :integer, default: 32, doc: "Height of each rendered row in pixels")
  attr(:height, :integer, default: 400, doc: "Container height in pixels (viewport)")
  attr(:class, :string, default: nil)

  @doc """
  Virtual-rendered tree for large datasets (1000+ nodes).

  The `PhiaVirtualTree` hook owns the DOM — only visible rows are rendered.
  Initial node data is passed as `data-nodes` JSON; subsequent updates are
  sent via `push_event("update-nodes", %{nodes: [...]})`.

  Use `phx-update="ignore"` (set automatically) to prevent LiveView from
  reconciling the hook-managed DOM.

  ## Example

      <.virtual_tree
        id="large-tree"
        nodes={@flat_nodes}
        row_height={28}
        height={500}
      />

  ## LiveView update

      {:noreply, push_event(socket, "update-nodes", %{nodes: flat_nodes})}
  """
  def virtual_tree(assigns) do
    nodes_json = Jason.encode!(assigns.nodes)
    assigns = assign(assigns, :nodes_json, nodes_json)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaVirtualTree"
      phx-update="ignore"
      data-nodes={@nodes_json}
      data-row-height={to_string(@row_height)}
      data-height={to_string(@height)}
      class={cn(["overflow-auto relative", @class])}
      style={"height: #{@height}px;"}
      role="tree"
      aria-label="Virtual tree"
    >
      <%!-- DOM managed entirely by PhiaVirtualTree hook --%>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp file_icon("ex"), do: "file-code"
  defp file_icon("exs"), do: "file-code"
  defp file_icon(ext) when ext in ~w(js ts tsx jsx mjs cjs), do: "file-code"
  defp file_icon("json"), do: "file-json"
  defp file_icon(ext) when ext in ~w(md mdx), do: "file-text"
  defp file_icon("txt"), do: "file-text"
  defp file_icon(ext) when ext in ~w(png jpg jpeg gif svg webp avif), do: "file-image"
  defp file_icon(ext) when ext in ~w(pdf), do: "file-type"
  defp file_icon(ext) when ext in ~w(doc docx), do: "file-type"
  defp file_icon(ext) when ext in ~w(zip tar gz bz2), do: "file-archive"
  defp file_icon(ext) when ext in ~w(mp3 wav ogg flac), do: "file-audio"
  defp file_icon(ext) when ext in ~w(mp4 mov avi webm), do: "file-video"
  defp file_icon(_), do: "file"
end
