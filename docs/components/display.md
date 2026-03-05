# Display

Visual identity, status indicators, avatars, chat UI, and theme controls.

## Table of Contents

- [icon](#icon)
- [badge](#badge)
- [avatar](#avatar)
- [avatar_group](#avatar_group)
- [activity_feed](#activity_feed)
- [timeline](#timeline)
- [chat_message](#chat_message)
- [dark_mode_toggle](#dark_mode_toggle)
- [theme_provider](#theme_provider)
- [kbd](#kbd)
- [direction](#direction)

---

## icon

Lucide SVG sprite icon. Generate the sprite with `mix phia.icons`.

**Sizes**: `:xs` (12px), `:sm` (16px), `:md` (20px, default), `:lg` (24px)

```heex
<.icon name="check" />
<.icon name="alert-triangle" size="lg" class="text-destructive" />
<.icon name="loader" size="sm" class="animate-spin text-primary" />
<.icon name="arrow-up-right" size="xs" class="text-green-500" />
```

**Common names**: `home`, `settings`, `user`, `log-out`, `search`, `plus`, `trash`, `pencil`, `check`, `x`, `chevron-right`, `chevron-down`, `bar-chart-2`, `file-text`, `bell`, `star`, `heart`, `shield`, `lock`, `key`, `mail`, `phone`, `calendar`, `clock`, `tag`, `upload`, `download`

---

## badge

Status and category labels.

**Variants**: `default`, `secondary`, `destructive`, `outline`

```heex
<.badge>Active</.badge>
<.badge variant="secondary">Draft</.badge>
<.badge variant="destructive">Failed</.badge>
<.badge variant="outline">Archived</.badge>
```

```elixir
# Dynamic variant based on status
defp status_variant("active"),   do: "default"
defp status_variant("draft"),    do: "secondary"
defp status_variant("failed"),   do: "destructive"
defp status_variant(_),          do: "outline"
```

```heex
<%!-- In a table cell --%>
<.table_cell>
  <.badge variant={status_variant(@order.status)}>
    <%= String.capitalize(@order.status) %>
  </.badge>
</.table_cell>
```

---

## avatar

Circular profile image with initials fallback. 5 sizes: `:xs`, `:sm`, `:md`, `:lg`, `:xl`.

**Sub-components**: `avatar_image/1`, `avatar_fallback/1`

```heex
<%!-- Image with fallback --%>
<.avatar size="md">
  <.avatar_image src={@user.avatar_url} alt={@user.name} />
  <.avatar_fallback name={@user.name} />
</.avatar>

<%!-- Initials only --%>
<.avatar size="lg">
  <.avatar_fallback name="Alice Martin" />
</.avatar>

<%!-- Different sizes --%>
<.avatar size="xs"><.avatar_fallback name="XS" /></.avatar>
<.avatar size="sm"><.avatar_fallback name="SM" /></.avatar>
<.avatar size="md"><.avatar_fallback name="MD" /></.avatar>
<.avatar size="lg"><.avatar_fallback name="LG" /></.avatar>
<.avatar size="xl"><.avatar_fallback name="XL" /></.avatar>
```

---

## avatar_group

Overlapping avatar row with `+N` overflow badge.

**Attrs**: `max` (integer, default 4)

```heex
<%!-- Show up to 5, then +N more --%>
<.avatar_group max={5}>
  <.avatar :for={user <- @team_members}>
    <.avatar_image src={user.avatar_url} alt={user.name} />
    <.avatar_fallback name={user.name} />
  </.avatar>
</.avatar_group>

<%!-- With tooltip on hover for names --%>
<.avatar_group max={4}>
  <.tooltip :for={user <- @collaborators}>
    <:trigger>
      <.avatar size="sm">
        <.avatar_fallback name={user.name} />
      </.avatar>
    </:trigger>
    <:content><%= user.name %></:content>
  </.tooltip>
</.avatar_group>
```

---

## activity_feed

Chronological event log with `role="log"` and `aria-live="polite"`. Groups events by date. 6 activity types with distinct icons.

**Sub-components**: `activity_group/1`, `activity_item/1`

**Activity types**: `mention`, `file`, `call`, `task`, `reaction`, `system`

```heex
<.activity_feed>
  <.activity_group label="Today">
    <.activity_item
      type="mention"
      name="Alice Martin"
      description="mentioned you in Project Alpha discussion"
      timestamp="2 minutes ago"
    >
      <:avatar>
        <.avatar size="sm">
          <.avatar_image src="/images/alice.jpg" alt="Alice" />
          <.avatar_fallback name="Alice Martin" />
        </.avatar>
      </:avatar>
    </.activity_item>

    <.activity_item
      type="task"
      name="Bob Chen"
      description="completed task: Deploy to staging"
      timestamp="15 minutes ago"
    >
      <:avatar><.avatar size="sm"><.avatar_fallback name="Bob Chen" /></.avatar></:avatar>
    </.activity_item>

    <.activity_item
      type="file"
      name="Carol Davis"
      description="uploaded Design System v2.pdf"
      timestamp="1 hour ago"
    />
  </.activity_group>

  <.activity_group label="Yesterday">
    <.activity_item
      type="system"
      name="System"
      description="Deployment to production completed successfully"
      timestamp="March 4 at 11:45 PM"
    />
  </.activity_group>

  <:footer>
    <.button variant="ghost" size="sm" class="w-full" phx-click="load_more_activity">
      Load more
    </.button>
  </:footer>
</.activity_feed>
```

### Streaming activity updates

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Phoenix.PubSub.subscribe(MyApp.PubSub, "activity")
  {:ok, stream(socket, :activities, ActivityFeed.recent(50))}
end

def handle_info({:new_activity, activity}, socket) do
  {:noreply, stream_insert(socket, :activities, activity, at: 0)}
end
```

---

## timeline

Vertical event timeline with CSS-only connector line. Use for order status, deployment history, and audit logs.

**Sub-components**: `timeline_item/1`
**Statuses**: `complete`, `active`, `upcoming`

```heex
<%!-- Order tracking --%>
<.timeline>
  <.timeline_item status="complete">
    <:icon><.icon name="check-circle" size="sm" class="text-green-500" /></:icon>
    <:content>
      <p class="font-medium">Order placed</p>
      <p class="text-sm text-muted-foreground">March 1 at 10:00 AM</p>
    </:content>
  </.timeline_item>
  <.timeline_item status="complete">
    <:icon><.icon name="package" size="sm" class="text-green-500" /></:icon>
    <:content>
      <p class="font-medium">Packed and shipped</p>
      <p class="text-sm text-muted-foreground">March 2 at 3:15 PM · FedEx #1234</p>
    </:content>
  </.timeline_item>
  <.timeline_item status="active">
    <:icon><.icon name="truck" size="sm" class="text-primary" /></:icon>
    <:content>
      <p class="font-medium text-primary">In transit</p>
      <p class="text-sm text-muted-foreground">Estimated delivery: March 5</p>
    </:content>
  </.timeline_item>
  <.timeline_item status="upcoming">
    <:icon><.icon name="home" size="sm" class="text-muted-foreground" /></:icon>
    <:content>
      <p class="font-medium text-muted-foreground">Delivered</p>
    </:content>
  </.timeline_item>
</.timeline>
```

---

## chat_message

Full AI/human chat interface. Sub-components compose into a complete chat UI.

**Sub-components**: `chat_container/1`, `chat_bubble/1`, `chat_suggestions/1`, `chat_input/1`

```heex
<%!-- Complete chat UI --%>
<.chat_container id="ai-chat" class="h-[600px] flex flex-col">
  <div class="flex-1 overflow-y-auto p-4 space-y-4">
    <.chat_message role="assistant" id="msg-0">
      <.chat_bubble role="assistant" timestamp="2:30 PM">
        <:avatar>
          <.avatar size="sm">
            <.avatar_fallback name="AI" />
          </.avatar>
        </:avatar>
        Hello! I'm your AI assistant. How can I help you today?
      </.chat_bubble>
      <.chat_suggestions
        suggestions={["What can you do?", "Help me write a report", "Analyze my data"]}
        on_select="send_suggestion"
      />
    </.chat_message>

    <.chat_message :for={msg <- @messages} role={msg.role} id={"msg-#{msg.id}"}>
      <.chat_bubble role={msg.role} timestamp={format_time(msg.inserted_at)}>
        <:avatar :if={msg.role == "assistant"}>
          <.avatar size="sm"><.avatar_fallback name="AI" /></.avatar>
        </:avatar>
        <%= msg.content %>
      </.chat_bubble>
    </.chat_message>

    <div :if={@ai_typing} class="flex items-center gap-2 text-muted-foreground">
      <.spinner size="sm" /> AI is typing…
    </div>
  </div>

  <.chat_input
    id="chat-compose"
    on_submit="send_message"
    placeholder="Ask anything…"
    disabled={@ai_typing}
  />
</.chat_container>
```

```elixir
def handle_event("send_message", %{"message" => text}, socket) when text != "" do
  user_msg = %{id: Ecto.UUID.generate(), role: "user", content: text, inserted_at: DateTime.utc_now()}
  socket = socket
    |> stream_insert(:messages, user_msg)
    |> assign(ai_typing: true)
  # Trigger async AI response
  send(self(), {:ask_ai, text})
  {:noreply, socket}
end

def handle_event("send_suggestion", %{"suggestion" => text}, socket) do
  handle_event("send_message", %{"message" => text}, socket)
end
```

---

## dark_mode_toggle

Sun/moon icon toggle. Reads and writes `localStorage['phia-mode']`. Syncs with `prefers-color-scheme`. Adds/removes `class="dark"` on `<html>`.

**Hook**: `PhiaDarkMode`

```heex
<%!-- In topbar or header --%>
<.dark_mode_toggle id="theme-toggle" />
```

```javascript
// app.js
import PhiaDarkMode from "./phia_hooks/dark_mode"
// hooks: { PhiaDarkMode }
```

```html
<!-- Anti-FOUC: add to <head> before any stylesheet -->
<script>
  (function() {
    var mode = localStorage.getItem('phia-mode');
    if (mode === 'dark' || (!mode && matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark');
    }
  })();
</script>
```

---

## theme_provider

Scoped CSS theme wrapper. Sets `data-phia-theme` on its wrapper `<div>`, so PhiaUI tokens inside use the specified preset.

```heex
<%!-- Scope a section to the rose preset --%>
<.theme_provider theme={:rose}>
  <.button>Rose button</.button>
  <.badge>Rose badge</.badge>
</.theme_provider>

<%!-- Preview multiple themes --%>
<div class="grid grid-cols-4 gap-4">
  <.theme_provider :for={preset <- [:blue, :rose, :green, :violet]} theme={preset}>
    <.card>
      <.card_content class="pt-4">
        <.button class="w-full"><%= preset %></.button>
      </.card_content>
    </.card>
  </.theme_provider>
</div>
```

---

## kbd

Semantic `<kbd>` element for displaying keyboard shortcuts.

```heex
<p>Press <.kbd>Ctrl</.kbd> + <.kbd>K</.kbd> to open the command palette.</p>
<p>Use <.kbd>⌘</.kbd> + <.kbd>Z</.kbd> to undo.</p>
<p>Navigate with <.kbd>↑</.kbd> <.kbd>↓</.kbd> arrow keys.</p>
```

---

## direction

LTR/RTL wrapper for multilingual layouts. Sets the HTML `dir` attribute on its container.

```heex
<.direction dir="ltr">
  <p>Left-to-right content (English, French, etc.)</p>
</.direction>

<.direction dir="rtl">
  <p>محتوى من اليمين إلى اليسار</p>
</.direction>
```

← [Back to README](../../README.md)
