# Inputs

61 input components with full Ecto `FormField` integration and WAI-ARIA accessibility. Every component that wraps a form field ships with a `phia_X/1` companion that accepts `Phoenix.HTML.FormField` — name, value, errors, and form ID are wired automatically.

**Modules**:
- `PhiaUi.Components.Inputs` — core inputs
- `PhiaUi.Components.AdvancedSelects` — tree_select, rich_select, visual_select
- `PhiaUi.Components.SpecialEntry` — verifiable_input, duration_input, split_input, credit_card_input
- `PhiaUi.Components.SmartInputs` — drag_number, suggestion_input, emoji_picker, keyboard_shortcut_input
- `PhiaUi.Components.TextareaEnhanced` — 7 textarea variants + form companions (v0.1.11)

```elixir
import PhiaUi.Components.Inputs
import PhiaUi.Components.TextareaEnhanced
```

---

## Table of Contents

**Core Inputs**
- [phia_input](#phia_input) — universal form input
- [input](#input) — bare input element
- [textarea](#textarea) — bare textarea
- [select](#select) / [combobox](#combobox) / [multi_select](#multi_select)
- [checkbox](#checkbox) / [radio_group](#radio_group) / [switch](#switch)
- [slider](#slider) / [rating](#rating) / [number_input](#number_input)
- [password_input](#password_input) / [input_otp](#input_otp)
- [segmented_control](#segmented_control) / [chip](#chip)
- [tags_input](#tags_input) / [editable](#editable) / [color_picker](#color_picker)
- [mention_input](#mention_input) / [rich_text_editor](#rich_text_editor)

**Input Utilities**
- [search_input](#search_input) / [clearable_input](#clearable_input) / [copy_input](#copy_input)
- [url_input](#url_input) / [phone_input](#phone_input) / [unit_input](#unit_input)
- [input_group](#input_group) / [input_addon](#input_addon) / [inline_search](#inline_search)
- [autocomplete_input](#autocomplete_input)

**Uploads**
- [file_upload](#file_upload) / [image_upload](#image_upload) / [avatar_upload](#avatar_upload)
- [upload_button](#upload_button) / [upload_card](#upload_card) / [upload_progress](#upload_progress)
- [upload_queue](#upload_queue) / [document_upload](#document_upload)
- [image_gallery_upload](#image_gallery_upload) / [fullscreen_drop](#fullscreen_drop)

**Advanced Selects**
- [tree_select](#tree_select) / [rich_select](#rich_select) / [visual_select](#visual_select)

**Special Entry**
- [verifiable_input](#verifiable_input) / [duration_input](#duration_input)
- [split_input](#split_input) / [credit_card_input](#credit_card_input)

**Smart Inputs**
- [drag_number](#drag_number) / [suggestion_input](#suggestion_input)
- [emoji_picker](#emoji_picker) / [keyboard_shortcut_input](#keyboard_shortcut_input)

**Textarea Variants (v0.1.11)**
- [autoresize_textarea](#autoresize_textarea)
- [chat_textarea](#chat_textarea)
- [code_textarea](#code_textarea)
- [textarea_with_actions](#textarea_with_actions)
- [split_textarea](#split_textarea)
- [ghost_textarea](#ghost_textarea)
- [expandable_textarea](#expandable_textarea)

---

## phia_input

Universal form input — wraps `Phoenix.HTML.FormField` and renders the correct input type with label, description, and error display.

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:name]}   label="Full name"  required />
  <.phia_input field={@form[:email]}  type="email"  label="Email" />
  <.phia_input field={@form[:bio]}    type="textarea" label="Bio" rows={4} />
  <.phia_input field={@form[:role]}   type="select" label="Role"
    options={[{"Admin", "admin"}, {"User", "user"}]} />
  <.phia_input field={@form[:active]} type="checkbox" label="Active" />
</.form>
```

**Types**: `text` · `email` · `password` · `number` · `tel` · `url` · `date` · `time` · `datetime-local` · `textarea` · `select` · `checkbox` · `hidden`

**Attrs**: `field` (required), `type`, `label`, `description`, `required`, `disabled`, `class`

---

## input

Bare unstyled input component. Use inside custom form wrappers.

```heex
<.input type="text" name="query" value={@query} placeholder="Search…" phx-debounce="300" />
<.input type="email" name="email" value="" required class="w-full" />
```

---

## textarea

Bare textarea with resize control.

```heex
<.textarea name="body" value={@draft} rows={6} placeholder="Write your post…" />
```

---

## select

Native `<select>` with styled options.

```heex
<.select name="country" value={@country} options={Countries.all()} />
<.select name="plan" value={@plan}
  options={[{"Starter — $9/mo", "starter"}, {"Pro — $29/mo", "pro"}]} />
```

---

## combobox

Searchable single-select with keyboard navigation.

```heex
<.combobox
  id="user-select"
  name="user_id"
  value={@selected_user_id}
  options={Enum.map(@users, &{&1.name, &1.id})}
  placeholder="Search users…"
  phx-change="select_user"
/>
```

---

## multi_select

Multiple-value combobox with tag badges.

```heex
<.multi_select
  id="tags-select"
  name="tags"
  values={@selected_tags}
  options={@available_tags}
  placeholder="Add tags…"
  on_change="update_tags"
/>
```

---

## checkbox

Standard checkbox with label.

```heex
<.checkbox name="agree" value="true" checked={@agreed} label="I agree to the Terms" />
```

---

## radio_group

Radio buttons as a vertical or horizontal group.

```heex
<.radio_group name="plan" value={@plan} on_change="set_plan"
  options={[{"Starter", "starter"}, {"Pro", "pro"}, {"Enterprise", "enterprise"}]} />
```

---

## switch

iOS-style toggle switch.

```heex
<.switch name="notifications" checked={@notifications_enabled} phx-change="toggle_notifications" />

<%!-- With label --%>
<div class="flex items-center justify-between">
  <span>Email notifications</span>
  <.switch name="email_notif" checked={@email_notif} phx-change="toggle_email" />
</div>
```

---

## slider

Range slider, with optional marks and value display.

```heex
<.slider name="volume" min={0} max={100} step={5} value={@volume} phx-change="set_volume" />
<.slider name="price" min={0} max={1000} value={@price_range} show_value={true} />
```

---

## rating

Star rating input. Supports half-stars and custom icons.

```heex
<.rating name="stars" value={@rating} max={5} phx-change="set_rating" />
<.rating name="score" value={@score} max={5} allow_half={true} phx-change="set_score" />
```

---

## number_input

Number input with increment/decrement buttons and step control.

```heex
<.number_input name="quantity" value={@qty} min={1} max={99} step={1} phx-change="set_qty" />
```

---

## password_input

Password input with show/hide toggle. Uses `JS.toggle_attribute` — zero JS hook required.

```heex
<.password_input name="password" value="" label="Password" />
<.phia_input field={@form[:password]} type="password" label="Password" />
```

---

## input_otp

One-time passcode input — N grouped digit boxes. Moves focus automatically.

```heex
<.input_otp name="otp" length={6} phx-change="verify_otp" />
<%!-- Grouped as 3+3 --%>
<.input_otp name="code" length={6} groups={[3, 3]} separator="-" phx-change="submit_code" />
```

---

## segmented_control

Button-style radio group with equal-width segments.

```heex
<.segmented_control name="view" value={@view} on_change="set_view"
  options={[{"List", "list"}, {"Grid", "grid"}, {"Map", "map"}]} />
```

---

## chip

Selectable filter pill. Toggle on/off.

```heex
<div class="flex flex-wrap gap-2">
  <%= for tag <- @all_tags do %>
    <.chip
      value={tag.id}
      selected={tag.id in @selected_tags}
      phx-click="toggle_tag"
      phx-value-id={tag.id}
    ><%= tag.name %></.chip>
  <% end %>
</div>
```

---

## tags_input

Free-form tag entry — type and press Enter or comma.

```heex
<.tags_input name="tags" values={@tags} placeholder="Add a tag…" phx-change="update_tags" />
```

---

## editable

Click-to-edit inline text field.

```heex
<.editable value={@title} on_submit="update_title" class="text-2xl font-bold" />
```

---

## color_picker

HEX/HSL/RGB colour picker with swatches.

```heex
<.color_picker name="brand_color" value={@color} phx-change="set_color" />
```

---

## mention_input

Text input that triggers `@mention` suggestions. Hook: `PhiaMentionInput`.

```heex
<.mention_input
  id="comment-input"
  name="comment"
  value=""
  mention_source="search_users"
  phx-change="update_comment"
/>
```

---

## rich_text_editor

Full WYSIWYG editor. Outputs HTML. Hook: `PhiaRichText`.

```heex
<.rich_text_editor id="description" name="description" value={@body} />
```

---

## search_input

Search field with leading icon and clear button.

```heex
<.search_input name="q" value={@query} phx-change="search" phx-debounce="300"
  placeholder="Search projects…" />
```

---

## clearable_input

Standard input with an X clear button.

```heex
<.clearable_input name="filter" value={@filter} phx-change="set_filter" placeholder="Filter…" />
```

---

## copy_input

Read-only input with a copy-to-clipboard button.

```heex
<.copy_input label="Share URL" value={@share_url} />
<.copy_input label="API Key" value={@api_key} type="password" />
```

---

## url_input

URL input with protocol prefix.

```heex
<.url_input name="website" value={@url} placeholder="yoursite.com" />
```

---

## phone_input

Phone input with country flag selector.

```heex
<.phone_input name="phone" value={@phone} default_country="US" phx-change="set_phone" />
```

---

## unit_input

Number input with a fixed unit label (e.g. "kg", "px", "%").

```heex
<.unit_input name="weight" value={@weight} unit="kg" min={0} />
<.unit_input name="width" value={@width} unit="px" min={0} max={9999} />
```

---

## input_group

Combines multiple inputs into a visually joined row (prefix + input + suffix).

```heex
<.input_group>
  <:prefix>https://</:prefix>
  <.input name="domain" value={@domain} placeholder="yoursite.com" />
  <:suffix>.com</:suffix>
</.input_group>
```

---

## input_addon

Addon slot that attaches to an input — button, icon, or label.

```heex
<.input_addon>
  <:addon_left><.icon name="search" size="sm" /></:addon_left>
  <.input name="q" value={@q} placeholder="Search…" />
</.input_addon>
```

---

## inline_search

Expandable inline search bar. Animates open on focus.

```heex
<.inline_search id="header-search" phx-change="search" phx-debounce="200" />
```

---

## autocomplete_input

Single-select input with async suggestion loading.

```heex
<.autocomplete_input
  id="city-search"
  name="city"
  value={@city}
  placeholder="Search city…"
  on_search="search_cities"
  options={@city_suggestions}
/>
```

---

## file_upload

LiveView upload area with drag-and-drop.

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.file_upload upload={@uploads.avatar} />
  <.button type="submit">Save</.button>
</.form>
```

---

## image_upload

Image upload with live preview.

```heex
<.image_upload upload={@uploads.photo} />
```

---

## avatar_upload

Circular avatar crop/upload with preview overlay.

```heex
<.avatar_upload upload={@uploads.avatar} current_url={@user.avatar_url} />
```

---

## upload_button

Small button that triggers a file dialog.

```heex
<.upload_button upload={@uploads.file} label="Attach file" />
```

---

## upload_card

Card-style upload entry with progress, name, and cancel.

```heex
<%= for entry <- @uploads.files.entries do %>
  <.upload_card entry={entry} on_cancel="cancel_upload" />
<% end %>
```

---

## upload_progress

Thin progress bar for a single upload entry.

```heex
<.upload_progress entry={entry} />
```

---

## upload_queue

Full upload queue manager — lists all in-progress entries.

```heex
<.upload_queue uploads={@uploads.files} on_cancel="cancel_upload" />
```

---

## document_upload

Drop zone styled for documents (PDF, DOCX, etc.).

```heex
<.document_upload upload={@uploads.report} accept=".pdf,.docx" />
```

---

## image_gallery_upload

Multi-image upload with thumbnail grid.

```heex
<.image_gallery_upload upload={@uploads.photos} max_files={10} />
```

---

## fullscreen_drop

Full-window drag-and-drop overlay. Shows on drag-enter. Hook: `PhiaFullscreenDrop`.

```heex
<.fullscreen_drop id="page-drop" upload={@uploads.files}>
  <p>Drop files anywhere to upload</p>
</.fullscreen_drop>
```

---

## tree_select

Hierarchical dropdown for nested data. Hook: `PhiaTreeSelect`.

```heex
<.tree_select
  id="category-select"
  name="category_id"
  value={@category_id}
  options={@category_tree}
  placeholder="Select category…"
  phx-change="set_category"
/>
```

---

## rich_select

Dropdown with icons, descriptions, and search per option.

```heex
<.rich_select id="role-select" name="role" value={@role} phx-change="set_role">
  <.rich_select_option value="admin" icon="shield" description="Full access">Admin</.rich_select_option>
  <.rich_select_option value="editor" icon="pencil" description="Can edit">Editor</.rich_select_option>
  <.rich_select_option value="viewer" icon="eye" description="Read only">Viewer</.rich_select_option>
</.rich_select>
```

---

## visual_select

Card-style radio select with thumbnails.

```heex
<.visual_select name="theme" value={@theme} phx-change="set_theme">
  <.visual_select_item value="light" image_src="/light.png">Light</.visual_select_item>
  <.visual_select_item value="dark" image_src="/dark.png">Dark</.visual_select_item>
  <.visual_select_item value="system" image_src="/system.png">System</.visual_select_item>
</.visual_select>
```

---

## verifiable_input

Input with async server verification (e.g. check username availability).

```heex
<.verifiable_input
  id="username-check"
  name="username"
  value={@username}
  on_verify="check_username"
  status={@username_status}
/>
```

---

## duration_input

HH:MM:SS duration entry with separate spinners.

```heex
<.duration_input name="duration" value={3661} show_hours={true} phx-change="set_duration" />
<%!-- value is total seconds; 3661 = 1h 1m 1s --%>
```

---

## split_input

N separate input boxes for structured codes (OTP, credit card, etc.). Hook: `PhiaSplitInput`.

```heex
<.split_input name="code" parts={4} value={@code} type="number" phx-change="update_code" />
```

---

## credit_card_input

Credit card form with number, expiry, CVV, and cardholder auto-formatting. Hook: `PhiaCreditCard`.

```heex
<.credit_card_input
  id="card-form"
  name_prefix="card"
  phx-change="validate_card"
/>
```

---

## drag_number

Number input that increments/decrements by dragging left/right. Hook: `PhiaDragNumber`.

```heex
<.drag_number name="opacity" value={@opacity} min={0} max={100} step={1} />
```

---

## suggestion_input

Text input with configurable suggestion chips below. Hook: `PhiaSuggestionInput`.

```heex
<.suggestion_input
  id="prompt-input"
  name="prompt"
  value={@prompt}
  suggestions={["Summarise", "Translate", "Improve writing"]}
  on_suggestion="apply_suggestion"
/>
```

---

## emoji_picker

Emoji picker popover with category tabs and search. Hook: `PhiaEmojiPicker`.

```heex
<.emoji_picker id="emoji-1" name="reaction" on_select="add_reaction" />
```

---

## keyboard_shortcut_input

Records a keyboard shortcut combination (e.g. ⌘+Shift+P). Hook: `PhiaKeyShortcut`.

```heex
<.keyboard_shortcut_input name="shortcut" value={@shortcut} phx-change="set_shortcut" />
```

---

## Textarea Variants (v0.1.11)

All textarea variants in `PhiaUi.Components.TextareaEnhanced`. Each ships with a `phia_X` companion for Ecto FormField integration.

### autoresize_textarea

Auto-grows as you type. Feature-detects `field-sizing: content`; falls back to `scrollHeight`. Hook: `PhiaAutoresize`.

```heex
<.autoresize_textarea
  id="bio-input"
  name="bio"
  value={@bio}
  min_rows={2}
  max_rows={10}
  phx-change="update_bio"
/>

<%!-- Form-integrated --%>
<.phia_autoresize_textarea field={@form[:bio]} label="Bio" min_rows={2} max_rows={10} />
```

### chat_textarea

Enter to submit, Shift+Enter for newline. Auto-grows. Optional actions slot. Hook: `PhiaChatTextarea`.

```heex
<.chat_textarea id="chat-input" name="message" on_submit="send_message">
  <:actions>
    <.icon_button icon="paperclip" label="Attach" phx-click="attach" variant="ghost" />
    <.icon_button icon="send" label="Send" phx-click="send" variant="default" />
  </:actions>
</.chat_textarea>
```

### code_textarea

Monospace textarea with line numbers and Tab indentation. Hook: `PhiaCodeTextarea`.

```heex
<.code_textarea
  id="snippet-editor"
  name="code"
  value={@snippet}
  tab_size={2}
  show_line_numbers={true}
  rows={20}
  phx-change="update_code"
/>
```

### textarea_with_actions

Textarea with a bottom action bar.

```heex
<.textarea_with_actions name="post" value={@draft}>
  <:actions>
    <.badge_button count={@word_count} variant="secondary">Words</.badge_button>
    <.button type="submit" size="sm">Publish</.button>
  </:actions>
</.textarea_with_actions>
```

### split_textarea

Side-by-side Write / Preview split view.

```heex
<.split_textarea name="body" value={@markdown}>
  <:preview>
    <div class="prose dark:prose-invert">
      <%= raw(@preview_html) %>
    </div>
  </:preview>
</.split_textarea>
```

### ghost_textarea

Borderless, transparent — use for inline note editing.

```heex
<.ghost_textarea id="inline-note" name="note" value={@note} phx-blur="save_note"
  placeholder="Add a note…" />
```

### expandable_textarea

Starts collapsed; expands to full height on button click — no round-trip needed.

```heex
<.expandable_textarea
  id="desc-input"
  name="description"
  value={@description}
  collapsed_rows={3}
  expanded_rows={12}
/>
```

**Attrs (common)**: `id`, `name`, `value`, `placeholder`, `class`, `phx-change`, `phx-blur`
