# Editor

Rich text editor toolkit for Phoenix LiveView. All 19 components live in `PhiaUi.Components.Editor`. Designed around TipTap/ProseMirror patterns but implemented entirely in Elixir/HEEx with vanilla JS hooks — no npm runtime dependencies.

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
