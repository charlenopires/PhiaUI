# Editor

Rich text editor system for Phoenix LiveView. **170+ components across 12 modules** — from low-level formatting controls to complete preset editors. Designed around TipTap/ProseMirror patterns but implemented entirely in Elixir/HEEx with vanilla JS hooks — no npm runtime dependencies.

## Module Overview

| Module | Import | Components | Description |
|--------|--------|:---:|-------------|
| `PhiaUi.Components.Editor` | `import PhiaUi.Components.Editor` | 19 | Core toolbar, bubble/floating menus, slash commands, find-replace |
| `PhiaUi.Components.Editor.RichEditor` | `import PhiaUi.Components.Editor.RichEditor` | 6 | Rich editor shell, toolbar, content area, floating/slash menus |
| `PhiaUi.Components.Editor.Blocks` | `import PhiaUi.Components.Editor.Blocks` | 9 | Task list, callout, collapsible section, columns layout, page break |
| `PhiaUi.Components.Editor.MediaBlocks` | `import PhiaUi.Components.Editor.MediaBlocks` | 8 | Image (with resize), table tools, equation editor, diagram, drawing canvas, embed |
| `PhiaUi.Components.Editor.ContentBlocks` | `import PhiaUi.Components.Editor.ContentBlocks` | 14 | Toggle list, tab block, video/audio, bookmark card, math block, social embed, PDF viewer, map embed |
| `PhiaUi.Components.Editor.BlockControls` | `import PhiaUi.Components.Editor.BlockControls` | 4 | Block add button, conversion menu, block toolbar, drag indicator |
| `PhiaUi.Components.Editor.AdvancedBlocks` | `import PhiaUi.Components.Editor.AdvancedBlocks` | 5 | Synced block, columns block, code sandbox, A4 page, page header/footer |
| `PhiaUi.Components.Editor.Formatting` | `import PhiaUi.Components.Editor.Formatting` | 16 | Bold, italic, underline, strikethrough, highlight, subscript, superscript, alignment, lists, etc. |
| `PhiaUi.Components.Editor.FormattingToolbar` | `import PhiaUi.Components.Editor.FormattingToolbar` | 1 | Assembled formatting toolbar component |
| `PhiaUi.Components.Editor.Extensions` | `import PhiaUi.Components.Editor.Extensions` | 10 | Track changes, search/nav, export, AI assistant bridge |
| `PhiaUi.Components.Editor.TextDirection` | `import PhiaUi.Components.Editor.TextDirection` | 2 | RTL/LTR toggle, bidirectional text block |
| `PhiaUi.Components.Editor.LanguageTools` | `import PhiaUi.Components.Editor.LanguageTools` | 4 | Grammar panel, grammar suggestion, spell check toggle, dictionary panel |
| `PhiaUi.Components.Editor.Presets` | `import PhiaUi.Components.Editor.Presets` | 10 | 5 original + 5 v2 preset editors |
| `PhiaUi.Components.Editor.Academic` | `import PhiaUi.Components.Editor.Academic` | ~8 | Citation toolbar, reference list, footnotes |
| `PhiaUi.Components.Editor.WritingTools` | `import PhiaUi.Components.Editor.WritingTools` | ~6 | Focus mode, typewriter scroll, distraction-free |
| `PhiaUi.Components.Editor.SearchNav` | `import PhiaUi.Components.Editor.SearchNav` | ~4 | Document outline navigation, search within editor |
| `PhiaUi.Components.Editor.TrackChanges` | `import PhiaUi.Components.Editor.TrackChanges` | ~5 | Track changes UI, accept/reject, change markers |
| `PhiaUi.Components.Editor.Export` | `import PhiaUi.Components.Editor.Export` | ~4 | Export to PDF/HTML/Markdown, print layout |
| `PhiaUi.Components.Editor.AiAssistant` | `import PhiaUi.Components.Editor.AiAssistant` | ~4 | AI writing assistant, autocomplete, rewrite |
| `PhiaUi.Components.Editor.DocumentShell` | `import PhiaUi.Components.Editor.DocumentShell` | ~4 | Document shell, sidebar, status bar |
| `PhiaUi.Components.Editor.EditorContent` | `import PhiaUi.Components.Editor.EditorContent` | ~6 | Editor content area, block rendering |

## Preset Editors

The fastest way to use the editor system — drop in a single component:

```heex
<%!-- Notion-style: slash commands, drag handles, block toolbars --%>
<.notion_editor id="notion" name="doc[body]" value={@body} />

<%!-- Google Docs-style: menu bar, A4 pages, track changes --%>
<.google_docs_editor id="gdocs" name="doc[body]" value={@body} />

<%!-- Medium-style: floating toolbar, clean reading, images --%>
<.medium_editor_v2 id="medium" name="post[body]" value={@body} />

<%!-- Developer notes: syntax highlighting, code sandbox --%>
<.code_notes_editor id="notes" name="note[body]" value={@body} />

<%!-- Full collaboration: presence, cursors, comments --%>
<.collaborative_editor id="collab" name="doc[body]" value={@body} room_id="doc-123" />
```

See also: [Rich Editor v2 Tutorial](../guides/tutorial-editor.md)

---

## Core Editor Components (PhiaUi.Components.Editor)

```elixir
import PhiaUi.Components.Editor
```

---

## editor_toolbar/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Full-width formatting toolbar container. Groups toolbar buttons and separators into a bordered strip.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_toolbar>
  <.toolbar_button icon="bold" label="Bold" active={false} />
  <.toolbar_separator />
  <.toolbar_button icon="link" label="Link" />
</.editor_toolbar>
```

---

## toolbar_button/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Individual toolbar action button with active and disabled states.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `icon` | `:string` | required | Lucide icon name |
| `label` | `:string` | required | Accessible label (shown as tooltip) |
| `active` | `:boolean` | `false` | Whether this format is currently applied |
| `disabled` | `:boolean` | `false` | Disables the button |
| `on_click` | `:string` | `nil` | `phx-click` event name |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.toolbar_button icon="bold" label="Bold" active={@bold_active} on_click="toggle_bold" />
```

---

## toolbar_group/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Visually grouped set of toolbar buttons sharing a common border and background.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.toolbar_group>
  <.toolbar_button icon="align-left" label="Align left" />
  <.toolbar_button icon="align-center" label="Center" />
  <.toolbar_button icon="align-right" label="Align right" />
</.toolbar_group>
```

---

## toolbar_separator/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: primitive

Vertical divider between toolbar groups.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.toolbar_separator />
```

---

## bubble_menu/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaBubbleMenu`

Floating selection toolbar that appears when text is selected inside an editor container. Positions itself near the selection using `getBoundingClientRect`.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `target` | `:string` | required | CSS selector of the editor element to observe |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.bubble_menu id="editor-bubble" target="#my-editor">
  <.toolbar_button icon="bold" label="Bold" />
  <.toolbar_button icon="italic" label="Italic" />
  <.toolbar_button icon="link" label="Link" />
</.bubble_menu>
```

---

## floating_menu/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaFloatingMenu`

Contextual menu floating near the cursor. Appears when cursor is at the start of an empty line.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `target` | `:string` | required | CSS selector of the editor element |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.floating_menu id="editor-float" target="#my-editor">
  <.toolbar_button icon="image" label="Insert image" />
  <.toolbar_button icon="table" label="Insert table" />
</.floating_menu>
```

---

## slash_command_menu/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaSlashCommand`

`/command` trigger menu for inserting content blocks. Appears when `/` is typed at the start of a line.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `items` | `:list` | required | List of command maps: `%{id, label, description, icon}` |
| `on_select` | `:string` | required | `phx-click` event fired with `phx-value-id` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.slash_command_menu
  id="slash-menu"
  items={[
    %{id: "heading", label: "Heading 1", description: "Large section title", icon: "heading-1"},
    %{id: "code", label: "Code Block", description: "Fenced code block", icon: "code"},
    %{id: "image", label: "Image", description: "Upload or embed image", icon: "image"}
  ]}
  on_select="insert_block"
/>
```

---

## inline_edit/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Click-to-edit inline text field. Renders a preview span; on click, switches to an input. Confirms on Enter or blur, cancels on Escape.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Unique ID |
| `value` | `:string` | required | Current text value |
| `on_submit` | `:string` | required | `phx-click` event for save |
| `placeholder` | `:string` | `"Click to edit"` | Placeholder text |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.inline_edit id="title-edit" value={@title} on_submit="update_title" />
```

---

## inline_edit_group/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Group of related inline-editable fields with a shared label row.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `label` | `:string` | `nil` | Group label |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.inline_edit_group label="Project Details">
  <.inline_edit id="name-edit" value={@project.name} on_submit="update_name" />
  <.inline_edit id="desc-edit" value={@project.description} on_submit="update_desc" />
</.inline_edit_group>
```

---

## editor_color_picker/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaEditorColorPicker`

Color picker for text color and highlight formatting in the editor toolbar.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `label` | `:string` | `"Color"` | Button label |
| `on_select` | `:string` | required | `phx-click` event fired with `phx-value-color` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_color_picker id="text-color" label="Text Color" on_select="set_text_color" />
```

---

## editor_toolbar_dropdown/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaEditorDropdown`

Dropdown menu for toolbar (heading level selector, font size picker).

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `label` | `:string` | required | Button label |
| `options` | `:list` | required | List of `%{value, label}` option maps |
| `on_select` | `:string` | required | `phx-click` event fired with `phx-value-value` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_toolbar_dropdown
  id="heading-picker"
  label="Paragraph"
  options={[
    %{value: "p", label: "Paragraph"},
    %{value: "h1", label: "Heading 1"},
    %{value: "h2", label: "Heading 2"},
    %{value: "h3", label: "Heading 3"}
  ]}
  on_select="set_block_type"
/>
```

---

## editor_link_dialog/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive

Link insert/edit dialog for the editor. Contains URL and optional text inputs with insert/remove actions.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for `PhiaDialog` hook |
| `open` | `:boolean` | `false` | Whether the dialog is open |
| `href` | `:string` | `nil` | Pre-filled href value |
| `on_insert` | `:string` | required | `phx-click` event for inserting the link |
| `on_remove` | `:string` | `nil` | `phx-click` event for removing the link |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_link_dialog id="link-dialog" open={@link_dialog_open} on_insert="insert_link" on_remove="remove_link" />
```

---

## editor_code_block/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: widget

Syntax-highlighted code block with language label and optional copy button.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `language` | `:string` | `"text"` | Language identifier label |
| `code` | `:string` | required | Code content to display |
| `show_copy` | `:boolean` | `true` | Show copy button |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_code_block language="elixir" code={@snippet} />
```

---

## editor_character_count/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: widget

Live character and word count display for an editor field.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `chars` | `:integer` | required | Current character count |
| `words` | `:integer` | `nil` | Current word count (optional) |
| `max_chars` | `:integer` | `nil` | Maximum character limit |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_character_count chars={@char_count} words={@word_count} max_chars={5000} />
```

---

## markdown_editor/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: widget
**Hook**: `PhiaMarkdownEditor`

Split-pane markdown editor with live HTML preview. Left pane is a `<textarea>`; right pane renders the parsed HTML.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `name` | `:string` | required | Form field name |
| `value` | `:string` | `""` | Initial markdown content |
| `height` | `:string` | `"400px"` | Editor height |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.markdown_editor id="post-editor" name="post[body]" value={@post.body} height="600px" />
```

---

## rich_text_viewer/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: primitive

Read-only HTML content renderer with prose typography. Uses `Phoenix.HTML.raw/1` — caller must sanitize content.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `content` | `:string` | required | Sanitized HTML content string |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.rich_text_viewer content={@post.html_body} class="max-w-prose" />
```

> **Security note:** Always sanitize HTML with `HtmlSanitizeEx` or equivalent before passing to `rich_text_viewer`.

---

## editor_find_replace/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaEditorFindReplace`

Slide-in find-and-replace panel for inline text editing. Supports regex mode, match-case, and replace-all.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `target` | `:string` | required | CSS selector of the editor element |
| `open` | `:boolean` | `false` | Whether the panel is visible |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_find_replace id="find-replace" target="#my-editor" open={@find_open} />
```

---

## editor_word_count/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: widget

Word count display with estimated reading time.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `words` | `:integer` | required | Current word count |
| `reading_speed` | `:integer` | `200` | Words per minute for reading time estimate |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.editor_word_count words={@word_count} />
```

---

## advanced_editor/1

**Module**: `PhiaUi.Components.Editor`
**Tier**: interactive
**Hook**: `PhiaAdvancedEditor`

Full-featured ProseMirror-inspired rich text editor. Includes toolbar, bubble menu, slash commands, link dialog, and find-replace — assembled in a single composable component. Inspired by TipTap (the most popular ProseMirror wrapper, used by Notion, Linear, and Vercel).

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `name` | `:string` | required | Hidden form field name for serialized content |
| `value` | `:string` | `""` | Initial HTML content |
| `height` | `:string` | `"400px"` | Editor height |
| `show_toolbar` | `:boolean` | `true` | Show formatting toolbar |
| `show_word_count` | `:boolean` | `true` | Show word count footer |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.advanced_editor id="article-editor" name="article[body]" value={@article.body} height="500px" />
```

### LiveView Example

```elixir
def mount(_params, _session, socket) do
  article = Articles.get!(1)
  {:ok, assign(socket, article: article)}
end

def handle_event("save", %{"article" => params}, socket) do
  case Articles.update(socket.assigns.article, params) do
    {:ok, article} -> {:noreply, assign(socket, article: article)}
    {:error, changeset} -> {:noreply, assign(socket, changeset: changeset)}
  end
end
```

```heex
<.form for={@form} phx-submit="save">
  <.advanced_editor id="body-editor" name="article[body]" value={@article.body} />
  <.button type="submit">Publish</.button>
</.form>
```

---

## Rich Editor (PhiaUi.Components.Editor.RichEditor)

```elixir
import PhiaUi.Components.Editor.RichEditor
```

The v2 rich editor shell — a composable editor with toolbar, content area, and floating menus. Powered by the PhiaEditor v2 JS engine (~1,200 LOC).

| Component | Tier | Hook | Description |
|-----------|------|------|-------------|
| `rich_editor` | interactive | `PhiaRichEditor` | Main editor shell with toolbar/content slots |
| `rich_toolbar` | interactive | — | Toolbar container for the rich editor |
| `rich_content` | interactive | — | Content area with block rendering |
| `rich_floating_menu` | interactive | — | Floating block insert menu |
| `rich_slash_command` | interactive | — | Slash command menu for rich editor |
| `rich_bubble_toolbar` | interactive | — | Selection-aware floating toolbar |

### Usage

```heex
<.rich_editor id="my-editor" name="content[body]" value={@body}>
  <:toolbar>
    <.formatting_toolbar editor_id="my-editor" />
  </:toolbar>
</.rich_editor>
```

---

## Editor Blocks (PhiaUi.Components.Editor.Blocks)

```elixir
import PhiaUi.Components.Editor.Blocks
```

Structural block types for the editor.

| Component | Description |
|-----------|-------------|
| `task_list` | Interactive checklist with checkboxes |
| `task_list_item` | Individual task item |
| `callout_block` | Highlighted callout with icon and color |
| `collapsible_section` | Expandable/collapsible content section |
| `columns_layout` | Multi-column content layout |
| `column` | Individual column in a columns layout |
| `page_break` | Visual page break separator |
| `horizontal_rule` | Themed horizontal divider |
| `block_quote` | Styled blockquote for the editor |

---

## Media Blocks (PhiaUi.Components.Editor.MediaBlocks)

```elixir
import PhiaUi.Components.Editor.MediaBlocks
```

Rich media embedding blocks.

| Component | Hook | Description |
|-----------|------|-------------|
| `image_block` | `PhiaImageResize` | Image with resize handles, caption, alignment |
| `table_block` | `PhiaTableEditor` | Interactive table with add/remove rows/cols |
| `equation_editor` | `PhiaEquationRenderer` | KaTeX math equation editor |
| `diagram_block` | `PhiaDiagramRenderer` | Mermaid diagram renderer |
| `drawing_canvas` | `PhiaDrawingCanvas` | Freehand drawing canvas |
| `embed_block` | — | oEmbed content embedding |
| `code_block_enhanced` | `PhiaCodeHighlight` | Syntax-highlighted code with language selector |
| `emoji_picker_block` | `PhiaEmojiPickerBlock` | Inline emoji picker |

---

## Content Blocks (PhiaUi.Components.Editor.ContentBlocks) — v0.1.17

```elixir
import PhiaUi.Components.Editor.ContentBlocks
```

| Component | Description |
|-----------|-------------|
| `toggle_list` | Expandable list items (FAQ-style) |
| `toggle_list_item` | Individual toggle item |
| `tab_block` | Tabbed content container |
| `tab_block_item` | Individual tab panel |
| `video_block` | Video embed with controls |
| `audio_block` | Audio player block |
| `bookmark_card` | URL bookmark with preview |
| `math_block` | Display math (block-level KaTeX) |
| `social_embed` | Twitter/YouTube/etc embed |
| `pdf_viewer` | Inline PDF viewer |
| `map_embed` | Map embed block |
| `file_attachment` | File attachment block |
| `divider_block` | Decorative divider with styles |
| `table_of_contents_block` | Auto-generated TOC from headings |

---

## Block Controls (PhiaUi.Components.Editor.BlockControls) — v0.1.17

```elixir
import PhiaUi.Components.Editor.BlockControls
```

| Component | Hook | Description |
|-----------|------|-------------|
| `block_add_button` | — | "+" button to insert new blocks |
| `block_conversion_menu` | — | Menu to convert block types (paragraph to heading, etc.) |
| `block_toolbar` | — | Floating toolbar for selected blocks |
| `block_drag_indicator` | `PhiaDragHandle` | Drag handle for reordering blocks |

---

## Advanced Blocks (PhiaUi.Components.Editor.AdvancedBlocks) — v0.1.17

```elixir
import PhiaUi.Components.Editor.AdvancedBlocks
```

| Component | Description |
|-----------|-------------|
| `synced_block` | Block synced across multiple locations |
| `columns_block` | Advanced multi-column layout with resize |
| `code_sandbox` | Interactive code sandbox with preview |
| `a4_page` | A4-sized page container for document layout |
| `page_header_footer` | Header/footer for A4 page mode |

---

## Formatting (PhiaUi.Components.Editor.Formatting)

```elixir
import PhiaUi.Components.Editor.Formatting
```

16 individual formatting control components. Each fires a `phx-click` event to toggle formatting.

| Component | Description |
|-----------|-------------|
| `bold_button` | Toggle bold |
| `italic_button` | Toggle italic |
| `underline_button` | Toggle underline |
| `strikethrough_button` | Toggle strikethrough |
| `highlight_button` | Toggle text highlight |
| `subscript_button` | Toggle subscript |
| `superscript_button` | Toggle superscript |
| `code_button` | Toggle inline code |
| `link_button` | Insert/edit link |
| `align_left_button` | Align text left |
| `align_center_button` | Center text |
| `align_right_button` | Align text right |
| `align_justify_button` | Justify text |
| `bullet_list_button` | Toggle bullet list |
| `ordered_list_button` | Toggle ordered list |
| `clear_formatting_button` | Clear all formatting |

---

## Text Direction (PhiaUi.Components.Editor.TextDirection) — v0.1.17

```elixir
import PhiaUi.Components.Editor.TextDirection
```

| Component | Description |
|-----------|-------------|
| `text_direction_toggle` | Toggle between LTR and RTL text direction |
| `bidi_text_block` | Bidirectional text block with auto-detection |

---

## Language Tools (PhiaUi.Components.Editor.LanguageTools) — v0.1.17

```elixir
import PhiaUi.Components.Editor.LanguageTools
```

| Component | Description |
|-----------|-------------|
| `grammar_panel` | Grammar checking panel with suggestions |
| `grammar_suggestion` | Individual grammar suggestion item |
| `spell_check_toggle` | Toggle spell checking on/off |
| `dictionary_panel` | Dictionary/thesaurus lookup panel |

---

## Extensions (PhiaUi.Components.Editor.Extensions)

```elixir
import PhiaUi.Components.Editor.Extensions
```

| Component | Hook | Description |
|-----------|------|-------------|
| `track_changes_panel` | `PhiaTrackChanges` | Track changes sidebar with accept/reject |
| `search_nav` | — | Document search and navigation |
| `export_menu` | — | Export to PDF/HTML/Markdown menu |
| `ai_assistant_panel` | — | AI writing assistant sidebar |
| `version_history` | — | Document version history viewer |
| `comments_sidebar` | — | Inline comments sidebar |
| `outline_panel` | — | Document outline/structure panel |
| `word_count_bar` | — | Bottom bar with word/char/page counts |
| `reading_time` | — | Estimated reading time display |
| `focus_mode` | — | Distraction-free writing mode |

---

## Presets (PhiaUi.Components.Editor.Presets)

```elixir
import PhiaUi.Components.Editor.Presets
```

### Original Presets (v0.1.17)

| Preset | Description |
|--------|-------------|
| `simple_editor` | Minimal editor with bold/italic/link/lists toolbar |
| `article_editor` | Medium-style editor for blog posts and articles |
| `document_editor_full` | Full document shell with header/footer/sidebar |
| `academic_editor` | Academic editor with citation toolbar |
| `email_composer` | Email-style editor with To/Subject/Signature |

### v2 Presets (v0.1.17)

| Preset | Description |
|--------|-------------|
| `notion_editor` | Notion-style: slash commands, drag, block toolbars |
| `google_docs_editor` | GDocs: menu bar, A4 pages, track changes |
| `medium_editor_v2` | Medium: floating toolbar, clean reading, images |
| `code_notes_editor` | Dev notes: syntax highlighting, code sandbox, markdown |
| `collaborative_editor` | Full collab: presence, cursors, comments sidebar |

### Usage

```heex
<.notion_editor
  id="my-editor"
  name="document[body]"
  value={@document.body}
  placeholder="Type / for commands..."
/>
```

---

## JS Hooks

The editor system ships with 10+ JS hooks in v0.1.17:

| Hook | File | Description |
|------|------|-------------|
| `PhiaRichEditor` | `phia_rich_editor.js` | Core editor engine (v2, ~1,200 LOC) |
| `PhiaEditorV2` | `phia_editor_v2.js` | Editor v2 lifecycle management |
| `PhiaEditorBundle` | `phia_editor_bundle.js` | Bundled editor with all extensions |
| `PhiaCodeHighlight` | `code_highlight.js` | Syntax highlighting for code blocks |
| `PhiaImageResize` | `image_resize.js` | Image resize handles |
| `PhiaTableEditor` | `table_editor.js` | Interactive table editing |
| `PhiaEquationRenderer` | `equation_renderer.js` | KaTeX equation rendering |
| `PhiaDiagramRenderer` | `diagram_renderer.js` | Mermaid diagram rendering |
| `PhiaDrawingCanvas` | `drawing_canvas.js` | Freehand drawing canvas |
| `PhiaDragHandle` | `drag_handle.js` | Block drag-and-drop |
| `PhiaEmojiPickerBlock` | `emoji_picker_block.js` | Emoji picker popup |
| `PhiaFormatPainter` | `format_painter.js` | Format painter tool |
| `PhiaTrackChanges` | `track_changes.js` | Track changes engine |
| `PhiaRibbonToolbar` | `ribbon_toolbar.js` | Microsoft-style ribbon toolbar |
| `PhiaCollab` | `phia_collab.js` | Collaborative editing bridge |
