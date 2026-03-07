# Tutorial: PhiaUI in Livebook

Build a simple interactive **Task Manager** UI using PhiaUI components rendered live inside a Livebook notebook. This tutorial shows how to prototype Phoenix LiveView component layouts, explore PhiaUI's visual system, and build interactive demos — all without running a Phoenix server.

## What you'll build

- A task list rendered with PhiaUI `table` and `badge` components
- A quick-add form using `phia_input` and `button`
- A stat summary bar with `stat_card` and `badge_delta`
- Dark mode toggle that affects the notebook preview

## How PhiaUI renders in Livebook

PhiaUI uses [`kino_live_component`](https://hex.pm/packages/kino_live_component), a Kino package that runs a minimal Phoenix endpoint inside Livebook. This allows fully styled function components — including Tailwind CSS — to render directly in notebook outputs.

> **Note**: `kino_live_component` requires Livebook 0.12+ and Elixir 1.17+.

---

## Step 1 — Create a new Livebook notebook

Open [Livebook](https://livebook.dev) (local or livebook.dev) and create a new notebook named **"PhiaUI Task Manager"**.

---

## Step 2 — Add dependencies

In the first Elixir cell, install PhiaUI and `kino_live_component`:

```elixir
Mix.install([
  {:phia_ui, "~> 0.1.11"},
  {:kino_live_component, "~> 0.0.5"},
  {:kino, "~> 0.14"}
])
```

Run the cell. Hex will fetch and compile both packages.

---

## Step 3 — Configure the Kino endpoint

`kino_live_component` needs a minimal Phoenix endpoint to serve the Tailwind CSS and run component rendering. Add this in the next cell:

```elixir
defmodule NotebookEndpoint do
  use Phoenix.Endpoint, otp_app: :phia_ui_notebook

  plug(Plug.Static,
    at: "/",
    from: {:phia_ui, "priv/static"},
    gzip: false
  )

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]
  )

  plug(Plug.Session, @session_options)
  plug(:router)

  def router(conn, _opts), do: conn

  @session_options [
    store: :cookie,
    key: "_phia_key",
    signing_salt: "phia_notebook"
  ]
end

Application.put_env(:phia_ui_notebook, NotebookEndpoint,
  url: [host: "localhost"],
  secret_key_base: String.duplicate("a", 64),
  live_view: [signing_salt: "phia_salt"],
  render_errors: [formats: [html: PhiaUi.ErrorHTML], layout: false],
  pubsub_server: PhiaUiNotebook.PubSub,
  server: false
)

{:ok, _} = Supervisor.start_link([
  {Phoenix.PubSub, name: PhiaUiNotebook.PubSub},
  NotebookEndpoint
], strategy: :one_for_one)
```

---

## Step 4 — Import PhiaUI components

```elixir
import PhiaUi.Components.Buttons
import PhiaUi.Components.Inputs
import PhiaUi.Components.Display
import PhiaUi.Components.Feedback
import PhiaUi.Components.Cards
import PhiaUi.Components.Data
```

---

## Step 5 — Render your first component

Use `KinoLiveComponent.render/2` to render any PhiaUI component:

```elixir
alias KinoLiveComponent, as: KLC

KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6 space-y-2">
    <.badge variant="default">Active</.badge>
    <.badge variant="secondary">Draft</.badge>
    <.badge variant="destructive">Deleted</.badge>
    <.badge variant="outline">Archived</.badge>
  </div>
  """
end)
```

You should see four coloured badges rendered inline in the notebook output.

---

## Step 6 — Build the task list

Define some sample tasks and render them in a table:

```elixir
tasks = [
  %{id: 1, title: "Design new landing page",  status: "active",   priority: "high"},
  %{id: 2, title: "Set up CI/CD pipeline",    status: "active",   priority: "medium"},
  %{id: 3, title: "Write API documentation",  status: "done",     priority: "low"},
  %{id: 4, title: "Fix authentication bug",   status: "active",   priority: "high"},
  %{id: 5, title: "Migrate to PostgreSQL 16", status: "backlog",  priority: "medium"}
]

status_variant = fn
  "active"  -> "default"
  "done"    -> "secondary"
  "backlog" -> "outline"
  _         -> "outline"
end

priority_variant = fn
  "high"   -> "destructive"
  "medium" -> "secondary"
  _        -> "outline"
end

KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6">
    <h2 class="text-xl font-semibold mb-4">Tasks</h2>
    <div class="border rounded-lg overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-muted/50 border-b">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-muted-foreground">#</th>
            <th class="text-left px-4 py-3 font-medium text-muted-foreground">Title</th>
            <th class="text-left px-4 py-3 font-medium text-muted-foreground">Status</th>
            <th class="text-left px-4 py-3 font-medium text-muted-foreground">Priority</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <%= for task <- tasks do %>
            <tr class="hover:bg-muted/30 transition-colors">
              <td class="px-4 py-3 text-muted-foreground"><%= task.id %></td>
              <td class="px-4 py-3 font-medium"><%= task.title %></td>
              <td class="px-4 py-3">
                <.badge variant={status_variant.(task.status)}>
                  <%= String.capitalize(task.status) %>
                </.badge>
              </td>
              <td class="px-4 py-3">
                <.badge variant={priority_variant.(task.priority)}>
                  <%= String.capitalize(task.priority) %>
                </.badge>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  </div>
  """
end)
```

---

## Step 7 — Add a stat summary bar

```elixir
active_count  = Enum.count(tasks, &(&1.status == "active"))
done_count    = Enum.count(tasks, &(&1.status == "done"))
backlog_count = Enum.count(tasks, &(&1.status == "backlog"))
high_priority = Enum.count(tasks, &(&1.priority == "high"))

KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6 grid grid-cols-4 gap-4">
    <div class="bg-card border rounded-lg p-4">
      <p class="text-sm text-muted-foreground">Active</p>
      <p class="text-3xl font-bold mt-1"><%= active_count %></p>
    </div>
    <div class="bg-card border rounded-lg p-4">
      <p class="text-sm text-muted-foreground">Completed</p>
      <p class="text-3xl font-bold mt-1 text-green-600"><%= done_count %></p>
    </div>
    <div class="bg-card border rounded-lg p-4">
      <p class="text-sm text-muted-foreground">Backlog</p>
      <p class="text-3xl font-bold mt-1 text-muted-foreground"><%= backlog_count %></p>
    </div>
    <div class="bg-card border rounded-lg p-4 border-destructive/30">
      <p class="text-sm text-muted-foreground">High Priority</p>
      <p class="text-3xl font-bold mt-1 text-destructive"><%= high_priority %></p>
    </div>
  </div>
  """
end)
```

---

## Step 8 — Add a quick-add form

```elixir
KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6 max-w-lg">
    <h3 class="text-lg font-semibold mb-4">Add a task</h3>
    <div class="space-y-4 bg-card border rounded-lg p-4">
      <div>
        <label class="text-sm font-medium block mb-1">Title</label>
        <input
          type="text"
          placeholder="Task title…"
          class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
        />
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="text-sm font-medium block mb-1">Status</label>
          <select class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
            <option value="active">Active</option>
            <option value="backlog">Backlog</option>
          </select>
        </div>
        <div>
          <label class="text-sm font-medium block mb-1">Priority</label>
          <select class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
            <option value="high">High</option>
            <option value="medium">Medium</option>
            <option value="low">Low</option>
          </select>
        </div>
      </div>
      <.button variant="default" class="w-full">Add task</.button>
    </div>
  </div>
  """
end)
```

> **Note**: In Livebook, forms don't fire LiveView events — they are static renders. For interactive forms, move the logic to a real Phoenix LiveView. Use Livebook to prototype the UI, then copy the HEEx template into your LiveView.

---

## Step 9 — Explore other components

Try rendering more PhiaUI components in subsequent cells:

```elixir
# Alert
KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-4 space-y-3">
    <.alert variant="success">
      <:icon><.icon name="check-circle" /></:icon>
      Task completed successfully.
    </.alert>
    <.alert variant="warning">
      <:icon><.icon name="alert-triangle" /></:icon>
      3 tasks are overdue.
    </.alert>
    <.alert variant="destructive">
      <:icon><.icon name="x-circle" /></:icon>
      Failed to sync with server.
    </.alert>
  </div>
  """
end)
```

```elixir
# Progress indicators
KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6 space-y-4">
    <div>
      <div class="flex justify-between text-sm mb-1">
        <span>Sprint progress</span>
        <span class="text-muted-foreground">60%</span>
      </div>
      <.progress value={60} />
    </div>
    <div>
      <div class="flex justify-between text-sm mb-1">
        <span>Storage used</span>
        <span class="text-muted-foreground">80%</span>
      </div>
      <.progress value={80} class="[&>div]:bg-destructive" />
    </div>
  </div>
  """
end)
```

```elixir
# Avatar group
KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="p-6 flex items-center gap-3">
    <.avatar_group max={4}>
      <.avatar size="sm"><.avatar_fallback name="Alice Smith" /></.avatar>
      <.avatar size="sm"><.avatar_fallback name="Bob Jones" /></.avatar>
      <.avatar size="sm"><.avatar_fallback name="Carol White" /></.avatar>
      <.avatar size="sm"><.avatar_fallback name="Dave Brown" /></.avatar>
      <.avatar size="sm"><.avatar_fallback name="Eve Davis" /></.avatar>
    </.avatar_group>
    <span class="text-sm text-muted-foreground">5 team members</span>
  </div>
  """
end)
```

---

## Step 10 — Dark mode preview

Toggle to dark mode to preview components in both colour schemes:

```elixir
KLC.render(NotebookEndpoint, fn assigns ->
  ~H"""
  <div class="dark bg-zinc-900 p-6 rounded-lg space-y-4">
    <h3 class="text-white font-semibold">Dark mode preview</h3>
    <.badge variant="default">Active</.badge>
    <.badge variant="secondary">Secondary</.badge>
    <div class="bg-card border border-border rounded-lg p-4 mt-3">
      <p class="text-foreground">This card uses semantic tokens.</p>
      <p class="text-muted-foreground text-sm mt-1">It looks correct in both modes.</p>
    </div>
    <.button variant="default">Dark mode button</.button>
  </div>
  """
end)
```

---

## Next steps

Now that you can render PhiaUI components in Livebook:

1. **Explore the full component catalog** in the Components section of the sidebar
2. **Build a real LiveView** — copy your HEEx templates from the notebook
3. **Run a tutorial** — see [Analytics Dashboard](tutorial-dashboard.md) or [Booking Platform](tutorial-booking.md) for complete LiveView implementations

### Useful patterns when prototyping in Livebook

| Goal | Approach |
|---|---|
| Test a layout | Render with `KLC.render/2`, iterate in the same cell |
| Try component variants | Render multiple instances side by side in one cell |
| Evaluate dark mode | Wrap the render in `<div class="dark bg-zinc-900">` |
| Share a component demo | Export the notebook as `.livemd` and share the file |
| Move to production | Copy the `~H"""` block directly into your LiveView |

---

## Resources

- [`kino_live_component` on Hex](https://hex.pm/packages/kino_live_component) — the Kino package used here
- [Livebook documentation](https://livebook.dev/docs) — notebook features and tips
- [PhiaUI component catalog](https://hexdocs.pm/phia_ui) — all 534 components with examples
- [Phoenix LiveView docs](https://hexdocs.pm/phoenix_live_view) — official LiveView reference
