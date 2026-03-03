# Utility & Composed Components

Utility components, layout helpers, and composed patterns built from primitives.

- [Aspect Ratio](#aspect-ratio)
- [Direction](#direction)
- [Empty State](#empty-state)
- [Field](#field)
- [Button Group](#button-group)
- [Avatar](#avatar)

---

## Aspect Ratio

Maintains a fixed aspect ratio for any content using the CSS padding-top trick. Zero JavaScript.

```heex
<%!-- 16:9 video wrapper --%>
<.aspect_ratio ratio={16/9}>
  <iframe src="https://www.youtube.com/embed/..." class="w-full h-full" />
</.aspect_ratio>

<%!-- Square image --%>
<.aspect_ratio ratio={1.0}>
  <img src="/hero.jpg" alt="Hero" class="w-full h-full object-cover" />
</.aspect_ratio>

<%!-- 4:3 card thumbnail --%>
<.aspect_ratio ratio={4/3} class="rounded-lg overflow-hidden">
  <img src="/thumbnail.jpg" alt="Thumbnail" class="w-full h-full object-cover" />
</.aspect_ratio>

<%!-- Portrait (9:16) for mobile stories --%>
<.aspect_ratio ratio={9/16}>
  <video src="/story.mp4" autoplay loop class="w-full h-full object-cover" />
</.aspect_ratio>
```

### How it works

The component generates `style="padding-top: X%"` where `X = (1 / ratio) * 100`. The child content is absolutely positioned inside:

```html
<div style="padding-top: 56.25%"> <!-- 16:9 -->
  <div class="absolute inset-0">
    <!-- your content -->
  </div>
</div>
```

### Common ratios

| Ratio | Float | Padding-top |
|-------|-------|-------------|
| 16:9 (widescreen) | `16/9` | 56.25% |
| 4:3 (standard) | `4/3` | 75% |
| 1:1 (square) | `1.0` | 100% |
| 21:9 (ultrawide) | `21/9` | 42.86% |
| 9:16 (portrait) | `9/16` | 177.78% |

---

## Direction

Minimal wrapper for controlling text direction (LTR/RTL) in multilingual applications.

```heex
<%!-- Default (LTR) --%>
<.direction>
  <p>Left to right content</p>
</.direction>

<%!-- RTL for Arabic, Hebrew, etc. --%>
<.direction dir="rtl">
  <p>مرحباً بكم في تطبيقنا</p>
</.direction>

<%!-- RTL section within LTR page --%>
<div>
  <h2>Bilingual Content</h2>
  <.direction dir="ltr" class="mb-4">
    <p>This is the English version.</p>
  </.direction>
  <.direction dir="rtl">
    <p>هذه هي النسخة العربية.</p>
  </.direction>
</div>
```

### Use cases

- Multilingual SaaS with user-selectable language direction
- Email templates with mixed RTL/LTR sections
- Documentation sites supporting Arabic/Hebrew locales

---

## Empty State

Centered placeholder shown when lists, tables, or sections have no data.

```heex
<%!-- Full featured --%>
<.empty>
  <:icon>
    <.icon name="inbox" size="lg" class="text-muted-foreground" />
  </:icon>
  <:title>No invoices found</:title>
  <:description>
    You haven't created any invoices yet. Get started by creating your first one.
  </:description>
  <:action>
    <.button phx-click="new-invoice">Create Invoice</.button>
  </:action>
</.empty>

<%!-- Minimal: title only --%>
<.empty>
  <:title>No results</:title>
</.empty>

<%!-- Inside a table --%>
<.table>
  <.table_header>
    <.table_row>
      <.table_head>Name</.table_head>
      <.table_head>Status</.table_head>
    </.table_row>
  </.table_header>
  <.table_body>
    <.table_row :if={@items == []}>
      <.table_cell colspan="2">
        <.empty>
          <:title>No items</:title>
          <:description>Add your first item to get started.</:description>
          <:action><.button size="sm">Add Item</.button></:action>
        </.empty>
      </.table_cell>
    </.table_row>
    <.table_row :for={item <- @items}>
      <.table_cell>{item.name}</.table_cell>
      <.table_cell>{item.status}</.table_cell>
    </.table_row>
  </.table_body>
</.table>

<%!-- Search no-results --%>
<.empty class="py-8">
  <:icon><.icon name="search" size="lg" class="text-muted-foreground" /></:icon>
  <:title>No results for "{@search}"</:title>
  <:description>Try adjusting your search or filters.</:description>
</.empty>
```

### Slots

| Slot | Required | Description |
|------|----------|-------------|
| `:icon` | No | Icon or illustration above title |
| `:title` | **Yes** | Main heading text |
| `:description` | No | Supporting text below title |
| `:action` | No | Call-to-action button or link |

---

## Field

Standalone form field layout components that work **without** `Phoenix.HTML.FormField`. Ideal for wrapping Checkbox, Radio, Switch, and other custom inputs.

```heex
<%!-- Basic field layout --%>
<.field>
  <.field_label for="name">Full Name</.field_label>
  <input id="name" name="name" type="text" class="..." />
</.field>

<%!-- With description and error --%>
<.field>
  <.field_label for="email" required={true}>Email</.field_label>
  <input id="email" name="email" type="email" />
  <.field_description>We'll never share your email with anyone.</.field_description>
  <.field_message error={@email_error} />
</.field>

<%!-- Wrapping a Checkbox --%>
<.field>
  <div class="flex items-center gap-2">
    <.checkbox id="terms" name="terms" />
    <.field_label for="terms">
      I agree to the <a href="/terms" class="underline">Terms of Service</a>
    </.field_label>
  </div>
  <.field_message error={@terms_error} />
</.field>

<%!-- Wrapping a Switch --%>
<.field>
  <div class="flex items-center justify-between">
    <.field_label for="notifications">Email Notifications</.field_label>
    <input type="checkbox" role="switch" id="notifications" name="notifications" />
  </div>
  <.field_description>Receive weekly digest emails.</.field_description>
</.field>

<%!-- Multiple checkboxes group --%>
<fieldset>
  <legend class="text-sm font-medium mb-2">Interests</legend>
  <.field :for={interest <- @interests}>
    <div class="flex items-center gap-2">
      <.checkbox id={"interest-#{interest.id}"} name="interests[]" value={interest.id} />
      <.field_label for={"interest-#{interest.id}"}>{interest.name}</.field_label>
    </div>
  </.field>
</fieldset>
```

### Sub-components

| Component | Description |
|-----------|-------------|
| `field/1` | Wrapper `<div class="space-y-2">` |
| `field_label/1` | Styled `<label>` with optional `:required` asterisk |
| `field_description/1` | Helper text in `text-muted-foreground text-sm` |
| `field_message/1` | Error message in `text-destructive`, only renders when `:error` is non-nil |

> **vs form_field/1**: Use `field/1` when you don't have a `Phoenix.HTML.FormField` (e.g. custom inputs, checkbox groups). Use `form_field/1` / `phia_input/1` when integrating with Ecto changesets.

---

## Button Group

Groups Button components into a unified toolbar with shared borders.

```heex
<%!-- Horizontal group (default) --%>
<.button_group>
  <.button variant="outline">Bold</.button>
  <.button variant="outline">Italic</.button>
  <.button variant="outline">Underline</.button>
</.button_group>

<%!-- Vertical group --%>
<.button_group orientation="vertical">
  <.button variant="outline">Top</.button>
  <.button variant="outline">Middle</.button>
  <.button variant="outline">Bottom</.button>
</.button_group>

<%!-- With icons (toolbar) --%>
<.button_group>
  <.button variant="outline" size="icon"><.icon name="align-left" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="align-center" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="align-right" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="align-justify" size="sm" /></.button>
</.button_group>

<%!-- As pagination controls --%>
<.button_group>
  <.button variant="outline" phx-click="prev" disabled={@page == 1}>&#8249;</.button>
  <.button variant="outline" disabled>Page {@page}</.button>
  <.button variant="outline" phx-click="next" disabled={@page == @total_pages}>&#8250;</.button>
</.button_group>

<%!-- Filter tabs --%>
<.button_group>
  <.button variant={if @filter == "all", do: "default", else: "outline"} phx-click="filter" phx-value-filter="all">All</.button>
  <.button variant={if @filter == "active", do: "default", else: "outline"} phx-click="filter" phx-value-filter="active">Active</.button>
  <.button variant={if @filter == "archived", do: "default", else: "outline"} phx-click="filter" phx-value-filter="archived">Archived</.button>
</.button_group>
```

### CSS approach

ButtonGroup uses Tailwind's `[&>*]` arbitrary group selectors to style children:

- `[&>*:not(:first-child)]:-ml-px` — removes duplicate borders between buttons
- `[&>*:first-child]:rounded-r-none` — removes right radius on first button
- `[&>*:last-child]:rounded-l-none` — removes left radius on last button
- Middle children: `rounded-none`

This approach works with **all Button variants** without any JavaScript.

---

## Avatar

Circular profile image component with automatic fallback to initials.

```heex
<%!-- Basic avatar with image and fallback --%>
<.avatar>
  <.avatar_image src={@user.avatar_url} alt={@user.name} />
  <.avatar_fallback name={@user.name} />
</.avatar>

<%!-- Sizes --%>
<.avatar size="sm"><.avatar_fallback name="Alice" /></.avatar>
<.avatar size="default"><.avatar_fallback name="Bob Smith" /></.avatar>
<.avatar size="lg"><.avatar_fallback name="Carol Jones" /></.avatar>
<.avatar size="xl"><.avatar_fallback name="David" /></.avatar>

<%!-- Custom fallback content --%>
<.avatar>
  <.avatar_fallback>
    <.icon name="user" size="sm" />
  </.avatar_fallback>
</.avatar>

<%!-- Avatar group (stacked) --%>
<.avatar_group>
  <.avatar>
    <.avatar_image src="/avatars/alice.jpg" alt="Alice" />
    <.avatar_fallback name="Alice Anderson" />
  </.avatar>
  <.avatar>
    <.avatar_image src="/avatars/bob.jpg" alt="Bob" />
    <.avatar_fallback name="Bob Brown" />
  </.avatar>
  <.avatar>
    <.avatar_fallback name="Carol" />
  </.avatar>
  <.avatar>
    <.avatar_fallback>+5</.avatar_fallback>
  </.avatar>
</.avatar_group>

<%!-- In a user list --%>
<div :for={user <- @users} class="flex items-center gap-3 p-2">
  <.avatar size="sm">
    <.avatar_image src={user.avatar_url} alt={user.name} />
    <.avatar_fallback name={user.name} />
  </.avatar>
  <div>
    <p class="text-sm font-medium">{user.name}</p>
    <p class="text-xs text-muted-foreground">{user.email}</p>
  </div>
</div>
```

### Fallback behaviour

When the image fails to load, the `onerror` inline handler:
1. Hides the `<img>` element
2. Shows the `[data-avatar-fallback]` sibling

Initials are auto-derived from `:name` — "John Doe" → "JD", "Alice" → "A".

### Sizes

| Size | Class | Pixels |
|------|-------|--------|
| `sm` | `h-6 w-6` | 24px |
| `default` | `h-10 w-10` | 40px |
| `lg` | `h-14 w-14` | 56px |
| `xl` | `h-18 w-18` | 72px |
