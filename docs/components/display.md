# Display

27 display components — icons, badges, avatars, activity feeds, timelines, chat UI, theme controls, and display utilities. These are the atoms of your UI.

**Modules**:
- `PhiaUi.Components.Display` — icon, badge, avatar, avatar_group, activity_feed, timeline, chat_message, dark_mode_toggle, theme_provider, kbd, direction
- `PhiaUi.Components.Utilities` — visually_hidden, line_clamp, highlight_text, relative_time, number_format, reading_time, label_with_tooltip, print_only, screen_only, color_mode_value, diff_display, stat_unit, word_count, focus_trap, sticky_wrapper

```elixir
import PhiaUi.Components.Display
import PhiaUi.Components.Utilities
```

---

## Table of Contents

**Visual Identity**
- [icon](#icon)
- [badge](#badge)
- [avatar](#avatar)
- [avatar_group](#avatar_group)
- [kbd](#kbd)

**Feed & Timeline**
- [activity_feed](#activity_feed)
- [timeline](#timeline)
- [chat_message](#chat_message)

**Theme Controls**
- [dark_mode_toggle](#dark_mode_toggle)
- [theme_provider](#theme_provider)
- [direction](#direction)

**Utilities**
- [visually_hidden](#visually_hidden)
- [line_clamp](#line_clamp)
- [highlight_text](#highlight_text)
- [relative_time](#relative_time)
- [number_format](#number_format)
- [reading_time](#reading_time)
- [label_with_tooltip](#label_with_tooltip)
- [print_only / screen_only](#print_only--screen_only)
- [color_mode_value](#color_mode_value)
- [diff_display](#diff_display)
- [stat_unit](#stat_unit)
- [word_count](#word_count)
- [focus_trap](#focus_trap)
- [sticky_wrapper](#sticky_wrapper)

---

## icon

Lucide SVG sprite icon. Generate the sprite with `mix phia.icons`.

**Sizes**: `:xs` (12px) · `:sm` (16px) · `:md` (20px, default) · `:lg` (24px)

```heex
<.icon name="check" />
<.icon name="alert-triangle" size="lg" class="text-destructive" />
<.icon name="loader" class="animate-spin text-primary" />
<.icon name="arrow-up-right" size="xs" class="text-green-500" />
```

**Common names**: `home`, `settings`, `user`, `log-out`, `search`, `plus`, `trash`, `pencil`, `check`, `x`, `chevron-right`, `chevron-down`, `bar-chart-2`, `file-text`, `bell`, `star`, `shield`, `lock`, `mail`, `calendar`, `clock`, `upload`, `download`

---

## badge

Inline status and category labels.

**Variants**: `default` · `secondary` · `destructive` · `outline`

```heex
<.badge>Active</.badge>
<.badge variant="secondary">Draft</.badge>
<.badge variant="destructive">Failed</.badge>
<.badge variant="outline">Archived</.badge>
```

```elixir
# Dynamic variant from Elixir
defp status_variant("active"),   do: "default"
defp status_variant("draft"),    do: "secondary"
defp status_variant("failed"),   do: "destructive"
defp status_variant(_),          do: "outline"
```

```heex
<.badge variant={status_variant(@record.status)}>
  <%= String.capitalize(@record.status) %>
</.badge>
```

---

## avatar

Circular profile image with initials fallback.

**Sizes**: `:xs` · `:sm` · `:md` (default) · `:lg` · `:xl`

```heex
<.avatar size="md">
  <.avatar_image src={@user.avatar_url} alt={@user.name} />
  <.avatar_fallback name={@user.name} />
</.avatar>

<%!-- Always-initials fallback --%>
<.avatar size="lg">
  <.avatar_fallback name="Jane Doe" class="bg-primary text-primary-foreground" />
</.avatar>
```

---

## avatar_group

Stacked overlapping avatars with overflow count.

```heex
<.avatar_group max={4}>
  <%= for member <- @team.members do %>
    <.avatar size="sm">
      <.avatar_image src={member.avatar_url} alt={member.name} />
      <.avatar_fallback name={member.name} />
    </.avatar>
  <% end %>
</.avatar_group>
```

**Attrs**: `max` (integer — show up to N, then `+N more`), `class`

---

## kbd

Keyboard key indicator.

```heex
<span class="text-sm text-muted-foreground">
  Press <.kbd>⌘</.kbd><.kbd>K</.kbd> to open the command palette
</span>
```

**Attrs**: `size` (`:sm` | `:md` | `:lg`, default `:md`), `class`

---

## activity_feed

Chronological activity list with icons and timestamps.

```heex
<.activity_feed>
  <%= for event <- @events do %>
    <.activity_feed_item
      icon={event.icon}
      title={event.title}
      description={event.description}
      timestamp={event.inserted_at}
    />
  <% end %>
</.activity_feed>
```

---

## timeline

Vertical timeline with connector lines.

```heex
<.timeline>
  <.timeline_item
    title="Order placed"
    description="Your order #1234 was confirmed."
    timestamp={~N[2025-03-01 09:00:00]}
    icon="package"
    status={:complete}
  />
  <.timeline_item
    title="Delivery"
    description="Estimated arrival March 5."
    icon="home"
    status={:pending}
  />
</.timeline>
```

**Statuses**: `:complete` · `:active` · `:pending`

---

## chat_message

A single chat bubble. Supports both sent and received sides, avatars, and timestamps.

```heex
<%= for msg <- @messages do %>
  <.chat_message
    content={msg.body}
    side={if msg.user_id == @current_user.id, do: :right, else: :left}
    avatar_src={msg.user.avatar_url}
    name={msg.user.name}
    timestamp={msg.inserted_at}
  />
<% end %>
```

**Attrs**: `side` (`:left` | `:right`), `content`, `avatar_src`, `name`, `timestamp`

---

## dark_mode_toggle

Toggles `.dark` on `<html>` and persists to `localStorage`.

```heex
<.dark_mode_toggle />
<.dark_mode_toggle show_label={true} />
```

---

## theme_provider

Sets a colour theme on its wrapper div via `data-phia-theme`.

```heex
<.theme_provider theme="violet">
  <.button>Violet button</.button>
</.theme_provider>
```

**Available themes**: `zinc` · `slate` · `stone` · `gray` · `red` · `rose` · `orange` · `blue` · `green` · `violet`

---

## direction

RTL/LTR wrapper.

```heex
<.direction dir={:rtl}>
  <p>مرحباً بالعالم</p>
</.direction>
```

---

## visually_hidden

Hides content visually but keeps it accessible to screen readers.

```heex
<button phx-click="close">
  <.icon name="x" />
  <.visually_hidden>Close dialog</.visually_hidden>
</button>
```

**Attrs**: `as` (HTML tag string, default `"span"`), `class`

---

## line_clamp

Truncates text to N lines with a client-side "Read more / Read less" toggle. Zero LiveView round-trips.

```heex
<.line_clamp id="post-body" lines={3}>
  <%= @post.body %>
</.line_clamp>
```

**Attrs**: `id` (required), `lines` (integer), `class`

---

## highlight_text

XSS-safe text with query matches wrapped in `<mark>`. Case-insensitive.

```heex
<%!-- In a search results list --%>
<.highlight_text text={result.title} query={@search_query} />

<%!-- Custom mark style --%>
<.highlight_text
  text={result.body}
  query={@query}
  mark_class="bg-yellow-200 dark:bg-yellow-800 rounded px-0.5"
/>
```

**Attrs**: `text`, `query`, `mark_class`, `class`

---

## relative_time

Renders "just now", "5 minutes ago", "3 days ago" etc. from a `DateTime`.

```heex
<.relative_time datetime={@post.inserted_at} />
<.relative_time datetime={@comment.inserted_at} now={@current_time} />
```

**Attrs**: `datetime` (DateTime), `now` (DateTime, default `DateTime.utc_now()`), `class`

---

## number_format

Formats numbers with compact notation, decimals, prefix, and suffix — server-side.

```heex
<%!-- "1.2M" --%>
<.number_format value={1_234_567} compact={true} />

<%!-- "$1,234.56" --%>
<.number_format value={1234.56} decimals={2} prefix="$" />

<%!-- "98.6%" --%>
<.number_format value={98.6} decimals={1} suffix="%" />
```

**Attrs**: `value` (number), `compact` (boolean), `decimals` (integer), `prefix`, `suffix`

---

## reading_time

Estimates read time from word count.

```heex
<.reading_time text={@post.body} />
<%!-- "4 min read" --%>

<.reading_time text={@post.body} wpm={200} />
```

**Attrs**: `text`, `wpm` (integer, default 238), `label` (default `"min read"`)

---

## label_with_tooltip

A `<label>` with an inline help icon and tooltip.

```heex
<.label_with_tooltip
  label="API Key"
  tooltip="Your secret key. Never share it publicly."
  for="api-key-input"
/>
<.input id="api-key-input" name="api_key" type="password" />
```

---

## print_only / screen_only

Visibility wrappers for print vs screen media.

```heex
<.print_only>
  <p>Printed on <%= Date.utc_today() %></p>
</.print_only>

<.screen_only>
  <.button>Export PDF</.button>
</.screen_only>
```

---

## color_mode_value

Renders different content in light vs dark mode via CSS.

```heex
<.color_mode_value>
  <:light><img src="/logo-light.svg" alt="PhiaUI" /></:light>
  <:dark><img src="/logo-dark.svg" alt="PhiaUI" /></:dark>
</.color_mode_value>
```

---

## diff_display

Word-level diff between two strings. Renders `<del>` (red) and `<ins>` (green) inline.

```heex
<.diff_display
  before="The quick brown fox jumps"
  after="The slow green fox leaps"
/>
```

---

## stat_unit

A value + unit pair with consistent styling. Common in dashboards.

```heex
<.stat_unit value="42" unit="req/s" />
<.stat_unit value="99.9" unit="% uptime" />
<.stat_unit value="1.2M" unit="users" />
```

---

## word_count

Counts words and displays the result.

```heex
<.word_count text="one two three" />
<%!-- "3 words" --%>

<.word_count text={@draft} class="text-xs text-muted-foreground" />
```

---

## focus_trap

Traps keyboard focus within a container for accessible modals. Hook: `PhiaFocusTrap`.

```heex
<.focus_trap id="modal-trap" enabled={@modal_open}>
  <div role="dialog" aria-modal="true">
    <h2>Modal title</h2>
    <.button phx-click="close_modal">Close</.button>
  </div>
</.focus_trap>
```

**Attrs**: `id` (required), `enabled` (boolean, default `true`)

---

## sticky_wrapper

Sticky positioning with configurable top offset.

```heex
<.sticky_wrapper offset_top={64}>
  <div class="bg-card border-b px-6 py-3 flex items-center justify-between">
    <span>3 rows selected</span>
    <.button variant="destructive" size="sm">Delete selected</.button>
  </div>
</.sticky_wrapper>
```

**Attrs**: `offset_top` (integer px, default 0), `class`
