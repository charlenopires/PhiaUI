# Tutorial: Rich Editor v2

Build rich text editors for Phoenix LiveView — from simple blog posts to full Notion-style document editors. PhiaUI's editor system provides 170+ components across 12 modules, 10 preset editors, and the PhiaEditor v2 JS engine.

## What you'll learn

- How to use preset editors for common use cases
- How to compose a custom editor from blocks and controls
- How to enable track changes and collaboration
- How to use A4 page layout for document editing
- How to embed media blocks (images, code, diagrams)

---

## Prerequisites

- Elixir 1.17+ and Phoenix 1.7+ with LiveView 1.0+
- TailwindCSS v4 configured in your project
- PhiaUI installed: `{:phia_ui, "~> 0.1.17"}` in `mix.exs`
- Hooks installed: `mix phia.install` (registers all JS hooks)

---

## Step 1 — Drop in a preset editor

The fastest way to get a rich editor working. Import presets and use one component:

```elixir
defmodule MyAppWeb.PostLive.Edit do
  use MyAppWeb, :live_view
  import PhiaUi.Components.Editor.Presets

  def mount(%{"id" => id}, _session, socket) do
    post = Posts.get!(id)
    {:ok, assign(socket, post: post, body: post.body)}
  end

  def handle_event("save", %{"post" => %{"body" => body}}, socket) do
    case Posts.update(socket.assigns.post, %{body: body}) do
      {:ok, post} -> {:noreply, assign(socket, post: post, body: body)}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Save failed")}
    end
  end

  def render(assigns) do
    ~H"""
    <.form for={%{}} phx-submit="save">
      <.notion_editor id="post-editor" name="post[body]" value={@body} />
      <.button type="submit" class="mt-4">Save</.button>
    </.form>
    """
  end
end
```

### Available presets

| Preset | Best for |
|--------|----------|
| `simple_editor` | Comments, short descriptions |
| `article_editor` | Blog posts, articles |
| `notion_editor` | Wikis, knowledge bases, docs |
| `google_docs_editor` | Reports, formal documents |
| `medium_editor_v2` | Clean writing experience |
| `code_notes_editor` | Developer documentation, READMEs |
| `collaborative_editor` | Team editing with presence |
| `document_editor_full` | Full document with shell |
| `academic_editor` | Papers with citations |
| `email_composer` | Email composition |

---

## Step 2 — Add markdown shortcuts

The Notion preset includes built-in markdown shortcuts:

| Shortcut | Result |
|----------|--------|
| `# ` | Heading 1 |
| `## ` | Heading 2 |
| `### ` | Heading 3 |
| `- ` | Bullet list |
| `1. ` | Ordered list |
| `[] ` | Task list |
| `> ` | Blockquote |
| `` ``` `` | Code block |
| `---` | Horizontal rule |
| `/` | Slash command menu |

These work automatically with `notion_editor` and `code_notes_editor`. For custom editors, the PhiaEditor v2 hook handles markdown conversion client-side.

---

## Step 3 — Enable track changes

Use the Google Docs preset or add track changes to any editor:

```heex
<.google_docs_editor
  id="report-editor"
  name="report[body]"
  value={@body}
/>
```

The Google Docs preset includes:
- A ribbon-style menu bar
- A4 page layout with margins
- Track changes with accept/reject
- Comments in the sidebar
- Version history

For custom editors, add track changes explicitly:

```elixir
import PhiaUi.Components.Editor.RichEditor
import PhiaUi.Components.Editor.Extensions
```

```heex
<.rich_editor id="my-editor" name="doc[body]" value={@body}>
  <:toolbar>
    <.formatting_toolbar editor_id="my-editor" />
  </:toolbar>
  <:sidebar>
    <.track_changes_panel id="tc-panel" editor_id="my-editor" />
  </:sidebar>
</.rich_editor>
```

---

## Step 4 — Embed media blocks

All preset editors support media blocks. Use slash commands (`/image`, `/code`, `/table`, etc.) or compose programmatically:

```elixir
import PhiaUi.Components.Editor.MediaBlocks
import PhiaUi.Components.Editor.ContentBlocks
```

```heex
<%!-- Image with resize handles --%>
<.image_block
  id="hero-img"
  src="/uploads/hero.jpg"
  alt="Hero image"
  caption="Figure 1: Dashboard overview"
  alignment={:center}
/>

<%!-- Syntax-highlighted code block --%>
<.code_block_enhanced
  id="code-1"
  language="elixir"
  code={~s|defmodule MyApp do\n  def hello, do: "world"\nend|}
/>

<%!-- Interactive table --%>
<.table_block id="data-table" rows={3} cols={4} />

<%!-- KaTeX equation --%>
<.equation_editor id="eq-1" latex="E = mc^2" display={true} />

<%!-- Mermaid diagram --%>
<.diagram_block id="diagram-1" content="graph TD; A-->B; B-->C;" />
```

---

## Step 5 — A4 page layout for documents

The Google Docs preset uses A4 pages. You can also use them directly:

```elixir
import PhiaUi.Components.Editor.AdvancedBlocks
```

```heex
<.a4_page id="page-1">
  <:header>
    <.page_header_footer position={:header}>
      <span>Company Report</span>
      <span>Confidential</span>
    </.page_header_footer>
  </:header>

  <%!-- Your editor content renders here --%>
  <.rich_editor id="doc-editor" name="doc[body]" value={@body} />

  <:footer>
    <.page_header_footer position={:footer}>
      <span>Page 1</span>
      <span>March 2026</span>
    </.page_header_footer>
  </:footer>
</.a4_page>
```

---

## Step 6 — Collaborative editing

The `collaborative_editor` preset combines the rich editor with the Collab Suite:

```heex
<.collaborative_editor
  id="team-doc"
  name="doc[body]"
  value={@body}
  room_id="doc-#{@document.id}"
/>
```

This gives you:
- Real-time presence avatars
- Live cursors with user names
- Inline comments and threads
- Comments sidebar

For custom collab setups, see the [Collaboration docs](../components/collaboration.md).

---

## Block types reference

| Block | Slash command | Module |
|-------|--------------|--------|
| Heading 1-3 | `/h1`, `/h2`, `/h3` | Core |
| Paragraph | — | Core |
| Bullet list | `/bullet` | Core |
| Ordered list | `/numbered` | Core |
| Task list | `/todo` | Blocks |
| Callout | `/callout` | Blocks |
| Collapsible | `/toggle` | Blocks |
| Columns | `/columns` | Blocks |
| Image | `/image` | MediaBlocks |
| Table | `/table` | MediaBlocks |
| Code block | `/code` | MediaBlocks |
| Equation | `/equation` | MediaBlocks |
| Diagram | `/diagram` | MediaBlocks |
| Drawing | `/drawing` | MediaBlocks |
| Embed | `/embed` | MediaBlocks |
| Video | `/video` | ContentBlocks |
| Audio | `/audio` | ContentBlocks |
| Bookmark | `/bookmark` | ContentBlocks |
| PDF viewer | `/pdf` | ContentBlocks |
| Map | `/map` | ContentBlocks |
| Toggle list | `/toggle-list` | ContentBlocks |
| Tab block | `/tabs` | ContentBlocks |
| Synced block | `/synced` | AdvancedBlocks |
| Code sandbox | `/sandbox` | AdvancedBlocks |

---

## Resources

- [Editor component docs](../components/editor.md) — full API reference for all 170+ components
- [Collaboration docs](../components/collaboration.md) — Collab Suite reference
- [PhiaUI-samples](https://github.com/charlenopires/PhiaUI-samples) — demo apps with editor examples
