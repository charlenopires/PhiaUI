# Typography

Semantic typographic primitives for Phoenix LiveView. All 18 components live in `PhiaUi.Components.Typography` and belong to the `:primitive` tier. Components cover headings, body text, code, quotes, links, and prose formatting with consistent typographic scale.

```elixir
import PhiaUi.Components.Typography
```

---

## heading/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Semantic `<h1>`–`<h6>` with consistent typographic scale and optional anchor link.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `level` | `:integer` | `2` | Heading level 1–6 |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.heading level={1}>Enterprise Dashboard</.heading>
<.heading level={2} class="text-muted-foreground">Analytics Overview</.heading>
```

---

## display_text/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Extra-large hero display text. Configurable size from `xl` to `4xl`. Intended for hero sections and marketing pages.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `size` | `:string` | `"2xl"` | Display size: `"xl"`, `"2xl"`, `"3xl"`, `"4xl"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.display_text size="3xl">
  Build something beautiful
</.display_text>
```

---

## text/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Inline `<span>` with semantic size, weight, and color variants.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `size` | `:string` | `"base"` | Size: `"xs"`, `"sm"`, `"base"`, `"lg"`, `"xl"` |
| `weight` | `:string` | `"normal"` | Weight: `"light"`, `"normal"`, `"medium"`, `"semibold"`, `"bold"` |
| `color` | `:string` | `nil` | Color variant: `"muted"`, `"destructive"`, `"primary"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.text size="sm" color="muted">Last updated 3 minutes ago</.text>
<.text weight="semibold">Important</.text>
```

---

## paragraph/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Body paragraph with configurable size and leading. Renders a `<p>` element.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `size` | `:string` | `"base"` | Text size: `"sm"`, `"base"`, `"lg"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.paragraph>
  PhiaUI is an enterprise-ready Phoenix LiveView component library with
  zero heavy JavaScript dependencies.
</.paragraph>
```

---

## lead/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Introductory paragraph with larger font size and line-height. Used below headings as a subtitle or introduction.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.heading level={1}>Documentation</.heading>
<.lead>Everything you need to build enterprise applications with Phoenix LiveView.</.lead>
```

---

## blockquote/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Styled `<blockquote>` with left border accent and optional citation.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `cite` | `:string` | `nil` | Attribution text shown below the quote |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.blockquote cite="— Linus Torvalds">
  Talk is cheap. Show me the code.
</.blockquote>
```

---

## inline_code/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

`<code>` with monospace font and subtle background. For inline code snippets within prose.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.paragraph>
  Call <.inline_code>mix phia.install</.inline_code> to set up the library.
</.paragraph>
```

---

## code_block/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Preformatted code block with language label and optional copy button.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `language` | `:string` | `"text"` | Language label displayed in header |
| `show_copy` | `:boolean` | `true` | Show copy button |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.code_block language="elixir">
defmodule MyApp do
  use Phoenix.Component
end
</.code_block>
```

---

## mark/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

`<mark>` highlighted text span with semantic highlight styling.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.paragraph>
  The <.mark>343 components</.mark> are all implemented and tested.
</.paragraph>
```

---

## text_link/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Styled `<a>` anchor with underline-on-hover and optional external link icon.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `href` | `:string` | required | Link href |
| `external` | `:boolean` | `false` | Show external link icon and `target="_blank"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.text_link href="/docs">Read the documentation</.text_link>
<.text_link href="https://hex.pm/packages/phia_ui" external>View on Hex.pm</.text_link>
```

---

## overline/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Small uppercase spaced label displayed above a heading. Used in marketing sections and category labels.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.overline>New in v0.1.7</.overline>
<.heading level={2}>Forms Suite</.heading>
```

---

## caption/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Small caption text for figures, tables, images, and media. Renders below the content it describes.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<img src="/chart.png" alt="Monthly revenue chart" />
<.caption>Figure 1: Monthly revenue for Q1 2026</.caption>
```

---

## abbr/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

`<abbr>` with dotted underline and title tooltip. Uses `border-b border-dotted` instead of `decoration-dotted` to avoid cn/1 group conflicts.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `title` | `:string` | required | Full expansion of the abbreviation |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.abbr title="HyperText Markup Language">HTML</.abbr>
<.abbr title="Application Programming Interface">API</.abbr>
```

---

## prose_list/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Styled unordered `<ul>` with custom bullet markers and consistent spacing.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.prose_list>
  <li>Zero npm runtime dependencies</li>
  <li>Full WAI-ARIA accessibility</li>
  <li>TailwindCSS v4 semantic tokens</li>
</.prose_list>
```

---

## ordered_list/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Styled `<ol>` with decimal, roman numeral, or alphabetical numbering variants.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `:string` | `"decimal"` | Numbering style: `"decimal"`, `"roman"`, `"alpha"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.ordered_list>
  <li>Install PhiaUI with `mix deps.get`</li>
  <li>Run `mix phia.install` to copy hooks</li>
  <li>Import components in your LiveView</li>
</.ordered_list>
```

---

## gradient_text/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Text with CSS gradient fill. Uses `background-clip: text`. The gradient direction and colors are configurable.

> **Note:** `bg-clip-text` must be outside `cn/1` to avoid conflict with `bg-gradient-to-*` in the `:bg` group.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `from` | `:string` | `"primary"` | Gradient start color |
| `to` | `:string` | `"secondary"` | Gradient end color |
| `direction` | `:string` | `"r"` | Direction: `"r"`, `"l"`, `"t"`, `"b"`, `"tr"`, `"br"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.gradient_text from="blue-600" to="violet-600" class="text-4xl font-bold">
  PhiaUI
</.gradient_text>
```

---

## truncated_text/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Single or multi-line text truncation with configurable line clamp.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `lines` | `:integer` | `1` | Number of visible lines before truncation |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<%!-- Single line truncation --%>
<.truncated_text lines={1} class="w-64">{@very_long_title}</.truncated_text>

<%!-- Multi-line clamp --%>
<.truncated_text lines={3}>{@article.excerpt}</.truncated_text>
```

---

## prose/1

**Module**: `PhiaUi.Components.Typography`
**Tier**: primitive

Prose container for long-form HTML content: articles, blog posts, and documentation. Applies consistent typographic styling to all child HTML elements (`h1`–`h6`, `p`, `ul`, `ol`, `code`, `blockquote`, etc.).

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `size` | `:string` | `"base"` | Prose scale: `"sm"`, `"base"`, `"lg"`, `"xl"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.prose class="max-w-prose">
  {@post.html_body |> Phoenix.HTML.raw()}
</.prose>
```

> **Security note:** Always sanitize HTML content before passing to `prose/1`.

### Use Cases

- Blog post rendering
- Documentation pages
- CMS content areas
- Release notes and changelogs
