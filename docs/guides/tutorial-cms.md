# Tutorial: Content Management System

Build a full-featured CMS admin panel in Phoenix LiveView using PhiaUI. The result is a production-ready content management interface with a sortable data grid, editorial kanban board, rich text editor, activity feed, advanced filtering, and bulk actions — all in a single LiveView.

## What you'll build

- Shell layout with sidebar navigation and topbar
- Post data grid with sorting, filtering, and pagination
- Bulk action bar for multi-row operations
- Kanban board for editorial workflow (Draft → Review → Published)
- Edit drawer with rich text editor
- Activity feed showing recent changes
- Filter bar for quick filtering + filter builder for advanced queries
- Delete confirmation dialog
- Command palette (Ctrl+K) for quick navigation
- Dark mode toggle

## Prerequisites

- Phoenix 1.8+ with LiveView 1.1+
- Elixir 1.17+
- TailwindCSS v4 configured
- PhiaUI 0.1.5
- An existing Phoenix app with Ecto and a database

---

## Step 1 — Install PhiaUI

```elixir
# mix.exs
def deps do
  [{:phia_ui, "~> 0.1.5"}]
end
```

```bash
mix deps.get
mix phia.install
```

```css
/* assets/css/app.css */
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

---

## Step 2 — Eject components

```bash
mix phia.add shell sidebar topbar dark_mode_toggle mobile_sidebar_toggle
mix phia.add data_grid table bulk_action_bar filter_bar filter_builder
mix phia.add kanban_board rich_text_editor activity_feed
mix phia.add drawer alert_dialog command toast
mix phia.add button badge chip icon segmented_control dropdown_menu
mix phia.add phia_input select form separator breadcrumb pagination
mix phia.add avatar spinner empty_state
```

---

## Step 3 — Register JS hooks

```javascript
// assets/js/app.js
import PhiaRichTextEditor from "./phia_hooks/rich_text_editor"
import PhiaDarkMode       from "./phia_hooks/dark_mode"
import PhiaDrawer         from "./phia_hooks/drawer"
import PhiaDialog         from "./phia_hooks/dialog"
import PhiaDropdownMenu   from "./phia_hooks/dropdown_menu"
import PhiaCommand        from "./phia_hooks/command"
import PhiaToast          from "./phia_hooks/toast"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaRichTextEditor, PhiaDarkMode, PhiaDrawer,
    PhiaDialog, PhiaDropdownMenu, PhiaCommand, PhiaToast
  }
})
```

---

## Step 4 — Post schema and context

```elixir
# lib/my_app/cms/post.ex
defmodule MyApp.CMS.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title,      :string
    field :slug,       :string
    field :content,    :string
    field :status,     :string, default: "draft"  # draft | review | published | archived
    field :author_id,  :integer
    belongs_to :author, MyApp.Accounts.User
    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :content, :status])
    |> validate_required([:title, :content])
    |> validate_inclusion(:status, ~w[draft review published archived])
    |> validate_length(:title, min: 3, max: 200)
    |> unique_constraint(:slug)
    |> slugify_title()
  end

  defp slugify_title(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title -> put_change(changeset, :slug, Slug.slugify(title))
    end
  end
end
```

```elixir
# lib/my_app/cms.ex
defmodule MyApp.CMS do
  import Ecto.Query
  alias MyApp.Repo
  alias MyApp.CMS.Post

  def list_posts(opts \\ []) do
    sort_by  = Keyword.get(opts, :sort_by, "inserted_at")
    sort_dir = Keyword.get(opts, :sort_dir, :desc)
    search   = Keyword.get(opts, :search, "")
    status   = Keyword.get(opts, :status, "")
    page     = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    Post
    |> preload(:author)
    |> filter_search(search)
    |> filter_status(status)
    |> order_by([p], [{^sort_dir, field(p, ^String.to_existing_atom(sort_by))}])
    |> offset(^((page - 1) * per_page))
    |> limit(^per_page)
    |> Repo.all()
  end

  def count_posts(opts \\ []) do
    Post
    |> filter_search(Keyword.get(opts, :search, ""))
    |> filter_status(Keyword.get(opts, :status, ""))
    |> Repo.aggregate(:count)
  end

  defp filter_search(query, ""), do: query
  defp filter_search(query, q) do
    where(query, [p], ilike(p.title, ^"%#{q}%"))
  end

  defp filter_status(query, ""), do: query
  defp filter_status(query, s), do: where(query, [p], p.status == ^s)

  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload(:author)

  def create_post(attrs), do: %Post{} |> Post.changeset(attrs) |> Repo.insert()

  def update_post(%Post{} = post, attrs) do
    post |> Post.changeset(attrs) |> Repo.update()
  end

  def delete_post(%Post{} = post), do: Repo.delete(post)

  def bulk_update_status(ids, status) do
    from(p in Post, where: p.id in ^ids)
    |> Repo.update_all(set: [status: status, updated_at: DateTime.utc_now()])
  end

  def bulk_delete(ids) do
    from(p in Post, where: p.id in ^ids) |> Repo.delete_all()
  end
end
```

---

## Step 5 — Create CmsLive

```elixir
# lib/my_app_web/live/cms_live.ex
defmodule MyAppWeb.CmsLive do
  use MyAppWeb, :live_view
  alias MyApp.CMS
  alias MyApp.CMS.Post

  @per_page 20

  @impl true
  def mount(_params, _session, socket) do
    posts = CMS.list_posts()
    {:ok, stream(socket, :posts, posts)
      |> assign(
        # Filters
        search: "", status_filter: "", sort_by: "inserted_at", sort_dir: :desc,
        page: 1, total: CMS.count_posts(), per_page: @per_page,
        # Selection
        selected_ids: [],
        # Edit drawer
        edit_post: nil, edit_form: nil, drawer_open: false,
        # Delete confirm
        delete_id: nil, show_delete_confirm: false,
        # View mode
        view_mode: "list",
        # Command palette
        command_open: false, command_query: "",
        # Current path for sidebar active state
        current_path: "/cms"
      )
    }
  end

  # --- Filtering & Sorting ---

  @impl true
  def handle_event("search", %{"query" => q}, socket) do
    reload(assign(socket, search: q, page: 1))
  end

  def handle_event("filter-status", %{"value" => status}, socket) do
    reload(assign(socket, status_filter: status, page: 1))
  end

  def handle_event("reset-filters", _params, socket) do
    reload(assign(socket, search: "", status_filter: "", page: 1))
  end

  def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
    reload(assign(socket, sort_by: key, sort_dir: String.to_existing_atom(dir)))
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    reload(assign(socket, page: String.to_integer(page)))
  end

  # --- Selection & Bulk Actions ---

  def handle_event("toggle-select", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    ids = socket.assigns.selected_ids
    updated = if id in ids, do: List.delete(ids, id), else: [id | ids]
    {:noreply, assign(socket, selected_ids: updated)}
  end

  def handle_event("clear-selection", _params, socket) do
    {:noreply, assign(socket, selected_ids: [])}
  end

  def handle_event("bulk-publish", _params, socket) do
    CMS.bulk_update_status(socket.assigns.selected_ids, "published")
    reload(assign(socket, selected_ids: []))
    |> then(&{:noreply, push_event(&1, "phia-toast", %{title: "Posts published", variant: "success"})})
  end

  def handle_event("bulk-archive", _params, socket) do
    CMS.bulk_update_status(socket.assigns.selected_ids, "archived")
    reload(assign(socket, selected_ids: []))
    |> then(&{:noreply, push_event(&1, "phia-toast", %{title: "Posts archived"})})
  end

  def handle_event("bulk-delete", _params, socket) do
    CMS.bulk_delete(socket.assigns.selected_ids)
    reload(assign(socket, selected_ids: []))
    |> then(&{:noreply, push_event(&1, "phia-toast", %{title: "Posts deleted", variant: "destructive"})})
  end

  # --- Edit Drawer ---

  def handle_event("open-edit", %{"id" => id_str}, socket) do
    post = CMS.get_post!(String.to_integer(id_str))
    form = post |> Post.changeset(%{}) |> to_form()
    {:noreply, assign(socket, edit_post: post, edit_form: form, drawer_open: true)}
  end

  def handle_event("close-edit", _params, socket) do
    {:noreply, assign(socket, drawer_open: false, edit_post: nil)}
  end

  def handle_event("validate-post", %{"post" => params}, socket) do
    form = socket.assigns.edit_post
      |> Post.changeset(params)
      |> Map.put(:action, :validate)
      |> to_form()
    {:noreply, assign(socket, edit_form: form)}
  end

  def handle_event("save-post", %{"post" => params}, socket) do
    case CMS.update_post(socket.assigns.edit_post, params) do
      {:ok, _post} ->
        socket = socket
          |> assign(drawer_open: false, edit_post: nil)
          |> push_event("phia-toast", %{title: "Post saved", variant: "success"})
        {:noreply, elem(reload(socket), 1)}

      {:error, changeset} ->
        {:noreply, assign(socket, edit_form: to_form(changeset))}
    end
  end

  # --- Delete ---

  def handle_event("confirm-delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, delete_id: String.to_integer(id), show_delete_confirm: true)}
  end

  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, delete_id: nil, show_delete_confirm: false)}
  end

  def handle_event("do-delete", _params, socket) do
    post = CMS.get_post!(socket.assigns.delete_id)
    CMS.delete_post(post)
    socket = socket |> assign(delete_id: nil, show_delete_confirm: false)
    socket = push_event(socket, "phia-toast", %{title: "Post deleted", variant: "destructive"})
    {:noreply, elem(reload(socket), 1)}
  end

  # --- View mode ---

  def handle_event("change-view", %{"value" => view}, socket) do
    {:noreply, assign(socket, view_mode: view)}
  end

  # --- Command palette ---

  def handle_event("open-command", _params, socket) do
    {:noreply, assign(socket, command_open: true)}
  end

  def handle_event("search-commands", %{"query" => q}, socket) do
    {:noreply, assign(socket, command_query: q)}
  end

  # --- Helpers ---

  defp reload(socket) do
    a = socket.assigns
    posts = CMS.list_posts(
      search: a.search, status: a.status_filter,
      sort_by: a.sort_by, sort_dir: a.sort_dir,
      page: a.page, per_page: @per_page
    )
    total = CMS.count_posts(search: a.search, status: a.status_filter)
    {:noreply, socket |> stream(:posts, posts, reset: true) |> assign(total: total)}
  end

  defp status_variant("published"), do: "default"
  defp status_variant("review"),    do: "secondary"
  defp status_variant("archived"),  do: "outline"
  defp status_variant(_),           do: "outline"
end
```

---

## Step 6 — Build the template

```heex
<%!-- lib/my_app_web/live/cms_live.html.heex --%>

<.toast id="cms-toast" />

<.shell>
  <:topbar>
    <.topbar>
      <:brand>
        <.icon name="file-text" class="h-5 w-5 text-primary" />
        <span class="font-bold">CMS</span>
      </:brand>
      <:actions>
        <.button variant="ghost" size="icon" phx-click="open-command">
          <.icon name="search" />
        </.button>
        <.dark_mode_toggle id="cms-dark-mode" />
      </:actions>
      <.mobile_sidebar_toggle />
    </.topbar>
  </:topbar>

  <:sidebar>
    <.sidebar>
      <:brand><span class="font-bold">Content</span></:brand>
      <:nav_items>
        <.sidebar_item href="/cms" active={true}>
          <:icon><.icon name="file-text" /></:icon> Posts
        </.sidebar_item>
        <.sidebar_item href="/cms/media">
          <:icon><.icon name="image" /></:icon> Media
        </.sidebar_item>
        <.sidebar_item href="/cms/categories">
          <:icon><.icon name="tag" /></:icon> Categories
        </.sidebar_item>
        <.sidebar_item href="/cms/settings">
          <:icon><.icon name="settings" /></:icon> Settings
        </.sidebar_item>
      </:nav_items>
    </.sidebar>
  </:sidebar>

  <main class="flex flex-col gap-4 p-6 overflow-y-auto">

    <%!-- Page header --%>
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold">Posts</h1>
        <p class="text-sm text-muted-foreground"><%= @total %> total posts</p>
      </div>
      <div class="flex gap-2">
        <.segmented_control id="view-mode" name="view" value={@view_mode}
          on_change="change-view"
          segments={[%{value: "list", label: "List"}, %{value: "kanban", label: "Kanban"}]} />
        <.button phx-click="open-edit" phx-value-id="new">
          <.icon name="plus" size="sm" /> New post
        </.button>
      </div>
    </div>

    <%!-- Filter bar --%>
    <.filter_bar>
      <.filter_search value={@search} placeholder="Search posts…"
        on_search="search" phx-debounce="300" />
      <.filter_select label="Status" name="status"
        options={[{"All", ""}, {"Draft", "draft"}, {"Review", "review"},
                  {"Published", "published"}, {"Archived", "archived"}]}
        value={@status_filter} on_change="filter-status" />
      <.filter_reset on_click="reset-filters" />
    </.filter_bar>

    <%!-- Bulk action bar (appears when rows selected) --%>
    <.bulk_action_bar :if={@selected_ids != []}
      count={length(@selected_ids)} label="posts selected" on_clear="clear-selection">
      <.bulk_action label="Publish" on_click="bulk-publish" icon="send" />
      <.bulk_action label="Archive" on_click="bulk-archive" icon="archive" />
      <.bulk_action label="Delete"  on_click="bulk-delete"  icon="trash" variant="destructive" />
    </.bulk_action_bar>

    <%!-- LIST VIEW --%>
    <div :if={@view_mode == "list"}>
      <.data_grid
        id="posts-grid"
        rows={@streams.posts}
        columns={[
          %{key: "title",       label: "Title",   sortable: true},
          %{key: "status",      label: "Status",  sortable: false},
          %{key: "author",      label: "Author",  sortable: false},
          %{key: "inserted_at", label: "Created", sortable: true}
        ]}
        sort_by={@sort_by}
        sort_dir={to_string(@sort_dir)}
        on_sort="sort"
      >
        <:select_col>
          <.checkbox
            :for={{_dom_id, post} <- @streams.posts}
            id={"select-#{post.id}"}
            checked={post.id in @selected_ids}
            phx-click="toggle-select"
            phx-value-id={post.id}
          />
        </:select_col>
        <:custom_cell :let={%{key: "status", row: {_dom_id, post}}}>
          <.badge variant={status_variant(post.status)}>
            <%= String.capitalize(post.status) %>
          </.badge>
        </:custom_cell>
        <:actions :let={{_dom_id, post}}>
          <.dropdown_menu id={"post-menu-#{post.id}"}>
            <:trigger>
              <.button variant="ghost" size="icon">
                <.icon name="more-horizontal" size="sm" />
              </.button>
            </:trigger>
            <:content>
              <.dropdown_menu_item phx-click="open-edit" phx-value-id={post.id}>
                <.icon name="pencil" size="sm" /> Edit
              </.dropdown_menu_item>
              <.dropdown_menu_separator />
              <.dropdown_menu_item class="text-destructive"
                phx-click="confirm-delete" phx-value-id={post.id}>
                <.icon name="trash" size="sm" /> Delete
              </.dropdown_menu_item>
            </:content>
          </.dropdown_menu>
        </:actions>
      </.data_grid>

      <%!-- Pagination --%>
      <.pagination class="mt-4">
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous on_change="paginate" current_page={@page} />
          </.pagination_item>
          <.pagination_item :for={n <- page_range(@page, ceil(@total / @per_page))}>
            <.pagination_link on_change="paginate" page={n} current_page={@page}>
              <%= n %>
            </.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_next on_change="paginate" current_page={@page}
              total_pages={ceil(@total / @per_page)} />
          </.pagination_item>
        </.pagination_content>
      </.pagination>
    </div>

    <%!-- KANBAN VIEW --%>
    <.kanban_board :if={@view_mode == "kanban"}>
      <.kanban_column label="Draft" count={count_by_status(@streams.posts, "draft")}>
        <.kanban_card
          :for={{_dom_id, post} <- @streams.posts, post.status == "draft"}
          id={"kanban-#{post.id}"}
          title={post.title}
          phx-click="open-edit"
          phx-value-id={post.id}
        >
          <:footer>
            <.avatar size="xs"><.avatar_fallback name={post.author.name} /></.avatar>
            <span class="text-xs text-muted-foreground">
              <%= Calendar.strftime(post.inserted_at, "%b %d") %>
            </span>
          </:footer>
        </.kanban_card>
      </.kanban_column>

      <.kanban_column label="In Review" count={count_by_status(@streams.posts, "review")}>
        <.kanban_card
          :for={{_dom_id, post} <- @streams.posts, post.status == "review"}
          id={"kanban-#{post.id}"}
          title={post.title}
          phx-click="open-edit"
          phx-value-id={post.id}
        />
      </.kanban_column>

      <.kanban_column label="Published" count={count_by_status(@streams.posts, "published")}>
        <.kanban_card
          :for={{_dom_id, post} <- @streams.posts, post.status == "published"}
          id={"kanban-#{post.id}"}
          title={post.title}
          phx-click="open-edit"
          phx-value-id={post.id}
        />
      </.kanban_column>
    </.kanban_board>

  </main>
</.shell>

<%!-- EDIT DRAWER --%>
<.drawer_content id="edit-drawer" open={@drawer_open} direction="right">
  <.drawer_header>
    <h2 class="text-lg font-semibold">
      <%= if @edit_post && @edit_post.id, do: "Edit post", else: "New post" %>
    </h2>
  </.drawer_header>
  <.drawer_close phx-click="close-edit" />

  <div :if={@edit_form} class="flex-1 overflow-y-auto px-6 py-4">
    <.form for={@edit_form} id="post-form" phx-change="validate-post" phx-submit="save-post">
      <div class="space-y-4">
        <.phia_input field={@edit_form[:title]} label="Title" />
        <.form_select field={@edit_form[:status]} label="Status"
          options={[{"Draft", "draft"}, {"Review", "review"},
                    {"Published", "published"}, {"Archived", "archived"}]} />
        <.separator />
        <.field>
          <.field_label>Content</.field_label>
          <.rich_text_editor field={@edit_form[:content]} min_height="400px"
            placeholder="Write your post…" />
        </.field>
      </div>
    </.form>
  </div>

  <.drawer_footer>
    <.button variant="outline" phx-click="close-edit">Cancel</.button>
    <.button phx-click="save-post" form="post-form" type="submit">Save post</.button>
  </.drawer_footer>
</.drawer_content>

<%!-- DELETE CONFIRM --%>
<.alert_dialog id="delete-post" open={@show_delete_confirm}>
  <.alert_dialog_header>
    <.alert_dialog_title>Delete this post?</.alert_dialog_title>
    <.alert_dialog_description>
      This will permanently remove the post and cannot be undone.
    </.alert_dialog_description>
  </.alert_dialog_header>
  <.alert_dialog_footer>
    <.alert_dialog_cancel phx-click="cancel-delete">Cancel</.alert_dialog_cancel>
    <.alert_dialog_action variant="destructive" phx-click="do-delete">Delete</.alert_dialog_action>
  </.alert_dialog_footer>
</.alert_dialog>

<%!-- COMMAND PALETTE --%>
<.command_dialog id="cms-command" open={@command_open}>
  <.command_input value={@command_query} placeholder="Search posts or navigate…"
    on_change="search-commands" />
  <.command_list>
    <.command_group label="Navigation">
      <.command_item on_click="navigate-to" value="/cms">
        <.icon name="file-text" size="sm" class="mr-2" /> Posts
      </.command_item>
      <.command_item on_click="navigate-to" value="/cms/media">
        <.icon name="image" size="sm" class="mr-2" /> Media library
      </.command_item>
    </.command_group>
    <.command_separator />
    <.command_group label="Actions">
      <.command_item on_click="open-edit" value="new">
        <.icon name="plus" size="sm" class="mr-2" /> New post
      </.command_item>
    </.command_group>
  </.command_list>
</.command_dialog>
```

---

## Step 7 — Add helper functions

```elixir
# In cms_live.ex (or a view helpers module)

defp count_by_status(stream, status) do
  stream |> Enum.count(fn {_dom_id, post} -> post.status == status end)
end

defp page_range(current, total) when total <= 7, do: Enum.to_list(1..max(total, 1))
defp page_range(current, total) do
  cond do
    current <= 4 -> [1, 2, 3, 4, 5, :ellipsis, total]
    current >= total - 3 -> [1, :ellipsis, total-4, total-3, total-2, total-1, total]
    true -> [1, :ellipsis, current-1, current, current+1, :ellipsis, total]
  end
end
```

---

## Step 8 — Add to router

```elixir
scope "/cms", MyAppWeb do
  pipe_through [:browser, :require_authenticated_user]
  live "/", CmsLive, :index
end
```

---

## What you've built

A production-ready CMS admin panel with:

| Feature | Component |
|---------|-----------|
| Dashboard shell | `shell/1`, `sidebar/1`, `topbar/1` |
| Sortable post grid | `data_grid/1` with streams |
| Quick filters | `filter_bar/1` |
| Bulk operations | `bulk_action_bar/1` |
| Kanban workflow | `kanban_board/1` |
| Rich text editing | `rich_text_editor/1` in a `drawer/1` |
| Delete confirmation | `alert_dialog/1` |
| Command palette | `command/1` (Ctrl+K) |
| Toast notifications | `toast/1` via `push_event` |
| Dark mode | `dark_mode_toggle/1` |

> **Next steps:** Add real-time collaboration with Phoenix PubSub + `activity_feed/1` to show who's editing what, integrate the `heatmap_calendar/1` to visualize publishing frequency, or add a `filter_builder/1` in a drawer for advanced content queries.


**See also**: [data_grid](data.md#data_grid) · [kanban_board](data.md#kanban_board) · [rich_text_editor](inputs.md#rich_text_editor) · [activity_feed](display.md#activity_feed)
