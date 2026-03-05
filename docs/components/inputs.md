# Inputs

All 24 input components with full Ecto/FormField integration and WAI-ARIA accessibility.

PhiaUI input components cover every common form pattern from bare `<input>` elements to rich WYSIWYG editors.
Each component that wraps a form field ships with a companion `form_X/1` variant that accepts a `Phoenix.HTML.FormField`
and automatically reads the field name, value, errors, and form ID so you never have to wire them manually.

---

## Table of Contents

- [phia_input](#phia_input)
- [input](#input)
- [textarea](#textarea)
- [select](#select)
- [checkbox](#checkbox)
- [radio_group](#radio_group)
- [switch](#switch)
- [slider](#slider)
- [rating](#rating)
- [number_input](#number_input)
- [password_input](#password_input)
- [input_otp](#input_otp)
- [input_addon](#input_addon)
- [segmented_control](#segmented_control)
- [chip](#chip)
- [editable](#editable)
- [combobox](#combobox)
- [multi_select](#multi_select)
- [tags_input](#tags_input)
- [file_upload](#file_upload)
- [image_upload](#image_upload)
- [rich_text_editor](#rich_text_editor)
- [color_picker](#color_picker)
- [mention_input](#mention_input)

---

## phia_input

The all-in-one form field wrapper. Renders a label, an `<input>` (or `<select>`/`<textarea>`), an optional
description line, and Ecto changeset error messages — all wired automatically from a `Phoenix.HTML.FormField`.
This is the recommended starting point for any Ecto-backed form.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `field` | `Phoenix.HTML.FormField` | required | Provides name, id, value, errors |
| `type` | `string` | `"text"` | Any HTML input type plus `"select"`, `"textarea"` |
| `label` | `string` | `nil` | Rendered as `<label>` |
| `description` | `string` | `nil` | Helper text below the input |
| `placeholder` | `string` | `nil` | Passed to the inner element |
| `phx-debounce` | `string` | `nil` | Passed through to `phx-debounce` |
| `class` | `string` | `nil` | Extra classes on the wrapper div |

**Examples**

Simple text field from a changeset form:

```heex
<.phia_input
  field={@form[:email]}
  type="email"
  label="Email address"
  description="We will never share your email."
  placeholder="you@example.com"
  phx-debounce="300"
/>
```

Select with inline options:

```heex
<.phia_input
  field={@form[:role]}
  type="select"
  label="Role"
  options={[{"Admin", "admin"}, {"Editor", "editor"}, {"Viewer", "viewer"}]}
/>
```

Multi-line textarea:

```heex
<.phia_input
  field={@form[:bio]}
  type="textarea"
  label="Bio"
  placeholder="Tell us about yourself…"
  rows={5}
/>
```

---

## input

The bare `<input>` element with PhiaUI styling. Use this when you are not working with an Ecto changeset
or when you need full manual control over name, value, and change events.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `type` | `string` | `"text"` | Any valid HTML input type |
| `value` | `string` | `nil` | Controlled value |
| `name` | `string` | `nil` | Form field name |
| `placeholder` | `string` | `nil` | Placeholder text |
| `disabled` | `boolean` | `false` | Disables the element |
| `class` | `string` | `nil` | Extra classes |

**Examples**

Uncontrolled standalone input:

```heex
<.input type="text" name="search" placeholder="Search…" />
```

Controlled via LiveView assigns:

```heex
<.input
  type="number"
  name="quantity"
  value={@quantity}
  phx-change="update_quantity"
  min="1"
  max="99"
/>
```

---

## textarea

Multi-line text input with automatic resize support and optional FormField integration.

Has a companion `form_textarea/1` that accepts `field` and wires errors automatically.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `field` | `Phoenix.HTML.FormField` | `nil` | Used by `form_textarea/1` |
| `rows` | `integer` | `3` | Visible row count |
| `placeholder` | `string` | `nil` | Placeholder text |
| `resize` | `string` | `"vertical"` | `"none"` / `"vertical"` / `"both"` |
| `class` | `string` | `nil` | Extra classes |

**Examples**

Bare textarea:

```heex
<.textarea name="notes" placeholder="Add notes…" rows={6} />
```

FormField variant with error display:

```heex
<.form_textarea
  field={@form[:description]}
  label="Description"
  rows={4}
  placeholder="Describe the issue…"
/>
```

---

## select

Native `<select>` element. Use `form_select/1` to bind to a FormField and display validation errors.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `options` | `list` | required | `[{"Label", value}, ...]` or `["item", ...]` |
| `value` | `any` | `nil` | Currently selected value |
| `name` | `string` | `nil` | Form field name |
| `prompt` | `string` | `nil` | Placeholder option with blank value |
| `multiple` | `boolean` | `false` | Enables multi-select |
| `on_change` | `string` | `nil` | `phx-change` event name |

**Examples**

Static options with a prompt:

```heex
<.select
  name="country"
  value={@country}
  prompt="Select a country"
  options={[{"United States", "us"}, {"Canada", "ca"}, {"Mexico", "mx"}]}
  phx-change="country_changed"
/>
```

FormField variant:

```heex
<.form_select
  field={@form[:status]}
  label="Status"
  prompt="-- pick one --"
  options={[{"Active", :active}, {"Inactive", :inactive}]}
/>
```

---

## checkbox

Standard checkbox with support for indeterminate state and a select-all pattern.
Companion: `form_checkbox/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `checked` | `boolean` | `false` | Controlled checked state |
| `indeterminate` | `boolean` | `false` | Visual indeterminate (dash icon) |
| `name` | `string` | `nil` | Form field name |
| `value` | `string` | `"true"` | Value sent when checked |
| `label` | `string` | `nil` | Inline label |
| `on_change` | `string` | `nil` | phx-change event |

**Examples**

Select-all header checkbox with indeterminate:

```heex
<.checkbox
  id="select-all"
  checked={Enum.all?(@rows, & &1.selected)}
  indeterminate={Enum.any?(@rows, & &1.selected) and not Enum.all?(@rows, & &1.selected)}
  phx-click="toggle_all"
  label="Select all"
/>
```

FormField variant with Ecto:

```heex
<.form_checkbox
  field={@form[:agree_to_terms]}
  label="I agree to the terms and conditions"
/>
```

LiveView handler:

```elixir
def handle_event("toggle_all", _, socket) do
  all_selected = Enum.all?(socket.assigns.rows, & &1.selected)
  rows = Enum.map(socket.assigns.rows, &Map.put(&1, :selected, !all_selected))
  {:noreply, assign(socket, :rows, rows)}
end
```

---

## radio_group

Radio button group. A `:let` context exposes `checked` and `value` down to each option slot,
letting you build any custom radio UI. Companion: `form_radio_group/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `value` | `any` | `nil` | Currently selected value |
| `name` | `string` | `nil` | Shared name for all radios |
| `on_change` | `string` | `nil` | phx-change event |
| `:option` slot | — | — | Repeated for each option; exposes `checked`, `value` |

**Examples**

Custom card-style radio group:

```heex
<.radio_group name="plan" value={@plan} phx-change="select_plan">
  <:option value="starter" :let={opt}>
    <label class={["border rounded-lg p-4 cursor-pointer", opt.checked && "border-primary"]}>
      <input type="radio" name={opt.name} value={opt.value} checked={opt.checked} class="sr-only" />
      <span class="font-medium">Starter — Free</span>
    </label>
  </:option>
  <:option value="pro" :let={opt}>
    <label class={["border rounded-lg p-4 cursor-pointer", opt.checked && "border-primary"]}>
      <input type="radio" name={opt.name} value={opt.value} checked={opt.checked} class="sr-only" />
      <span class="font-medium">Pro — $12/mo</span>
    </label>
  </:option>
</.radio_group>
```

FormField variant:

```heex
<.form_radio_group field={@form[:gender]} label="Gender">
  <:option value="m">Male</:option>
  <:option value="f">Female</:option>
  <:option value="nb">Non-binary</:option>
</.form_radio_group>
```

---

## switch

A CSS toggle switch. Renders a visually styled `<button role="switch">` that communicates its
checked state to screen readers. Companion: `form_switch/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `checked` | `boolean` | `false` | On/off state |
| `on_change` | `string` | `nil` | phx-click event |
| `label` | `string` | `nil` | Visible label or `aria-label` |
| `disabled` | `boolean` | `false` | Disables interaction |
| `size` | `atom` | `:default` | `:sm` / `:default` / `:lg` |

**Examples**

Notifications toggle:

```heex
<.switch
  id="notif-switch"
  checked={@notifications_enabled}
  on_change="toggle_notifications"
  label="Email notifications"
/>
```

FormField variant:

```heex
<.form_switch
  field={@form[:is_public]}
  label="Make profile public"
/>
```

LiveView handler:

```elixir
def handle_event("toggle_notifications", _, socket) do
  {:noreply, update(socket, :notifications_enabled, &(!&1))}
end
```

---

## slider

A styled `<input type="range">` with full WAI-ARIA attributes (`aria-valuemin`, `aria-valuemax`,
`aria-valuenow`). Companion: `form_slider/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `value` | `number` | `0` | Current value |
| `min` | `number` | `0` | Minimum |
| `max` | `number` | `100` | Maximum |
| `step` | `number` | `1` | Step increment |
| `on_change` | `string` | `nil` | phx-input / phx-change event |
| `show_value` | `boolean` | `false` | Displays current value badge |

**Examples**

Volume control:

```heex
<.slider
  id="volume"
  value={@volume}
  min={0}
  max={100}
  step={5}
  show_value={true}
  phx-input="set_volume"
/>
```

FormField with label:

```heex
<.form_slider
  field={@form[:experience_years]}
  label="Years of experience"
  min={0}
  max={40}
  step={1}
/>
```

---

## rating

A star rating widget rendered as a CSS `role="radiogroup"`. Supports 1–10 stars (default 5).
Companion: `form_rating/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `value` | `integer` | `nil` | Currently selected star count |
| `max` | `integer` | `5` | Total number of stars (1–10) |
| `on_change` | `string` | `nil` | phx-click event |
| `readonly` | `boolean` | `false` | Display-only mode |
| `size` | `atom` | `:default` | `:sm` / `:default` / `:lg` |

**Examples**

Interactive product rating:

```heex
<.rating
  id="product-rating"
  value={@rating}
  max={5}
  on_change="rate_product"
/>
```

Read-only display:

```heex
<.rating value={4} max={5} readonly={true} />
```

FormField variant:

```heex
<.form_rating
  field={@form[:satisfaction]}
  label="How satisfied are you?"
  max={10}
/>
```

---

## number_input

An enhanced number field with plus/minus stepper buttons flanking the input. Supports prefix and
suffix slots (e.g., currency symbol, unit label). Companion: `form_number_input/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `value` | `number` | `nil` | Current value |
| `min` | `number` | `nil` | Minimum allowed |
| `max` | `number` | `nil` | Maximum allowed |
| `step` | `number` | `1` | Increment/decrement amount |
| `prefix` | `string` | `nil` | Text/icon before the input |
| `suffix` | `string` | `nil` | Text/icon after the input |
| `on_change` | `string` | `nil` | phx-change event |

**Examples**

Quantity selector with bounds:

```heex
<.number_input
  id="qty"
  value={@quantity}
  min={1}
  max={99}
  step={1}
  phx-change="update_qty"
/>
```

Price field with currency prefix:

```heex
<.number_input
  id="price"
  value={@price}
  min={0}
  step={0.01}
  prefix="$"
  suffix="USD"
  phx-change="update_price"
/>
```

FormField variant:

```heex
<.form_number_input
  field={@form[:seats]}
  label="Number of seats"
  min={1}
  max={500}
/>
```

---

## password_input

A password input with a show/hide toggle button. Uses `JS.toggle_attribute/1` to flip the
`type` attribute between `"password"` and `"text"` — no JavaScript hook required.
Companion: `form_password_input/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `value` | `string` | `nil` | Controlled value |
| `name` | `string` | `nil` | Form field name |
| `autocomplete` | `string` | `"current-password"` | `"new-password"` for registration forms |
| `placeholder` | `string` | `nil` | Placeholder text |

**Examples**

Login form password:

```heex
<.password_input
  id="user-password"
  name="user[password]"
  placeholder="Enter your password"
  autocomplete="current-password"
/>
```

Registration form with new-password autocomplete:

```heex
<.form_password_input
  field={@form[:password]}
  label="New password"
  autocomplete="new-password"
  placeholder="At least 8 characters"
/>
```

---

## input_otp

One-time password input. Composed of three sub-components:
`input_otp_group/1`, `input_otp_slot/1`, and `input_otp_separator/1`.

- Auto-advances focus to the next slot on each keypress.
- Paste distributes characters across slots automatically.
- Backspace moves focus to the previous slot and clears it.

**Key attrs (input_otp/1)**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `length` | `integer` | `6` | Total number of digit slots |
| `value` | `string` | `""` | Controlled current value |
| `on_complete` | `string` | `nil` | Event fired when all slots are filled |
| `type` | `string` | `"number"` | `"text"` for alphanumeric codes |

**Examples**

Six-digit SMS code:

```heex
<.input_otp id="sms-otp" length={6} value={@otp_value} on_complete="verify_otp">
  <.input_otp_group>
    <.input_otp_slot index={0} />
    <.input_otp_slot index={1} />
    <.input_otp_slot index={2} />
  </.input_otp_group>
  <.input_otp_separator />
  <.input_otp_group>
    <.input_otp_slot index={3} />
    <.input_otp_slot index={4} />
    <.input_otp_slot index={5} />
  </.input_otp_group>
</.input_otp>
```

Alphanumeric invite code (8 chars):

```heex
<.input_otp id="invite-otp" length={8} type="text" on_complete="redeem_code">
  <.input_otp_group>
    <%= for i <- 0..7 do %>
      <.input_otp_slot index={i} />
    <% end %>
  </.input_otp_group>
</.input_otp>
```

LiveView handler:

```elixir
def handle_event("verify_otp", %{"value" => code}, socket) do
  case MyApp.Auth.verify_otp(socket.assigns.user, code) do
    :ok -> {:noreply, push_navigate(socket, to: ~p"/dashboard")}
    {:error, _} -> {:noreply, assign(socket, :otp_error, "Invalid code. Try again.")}
  end
end
```

---

## input_addon

Wraps an `<input>` with a prefix and/or suffix element (icon, text, button). Sub-components:
`input_addon_prefix/1` and `input_addon_suffix/1`.

**Key attrs (input_addon/1)**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `class` | `string` | `nil` | Extra classes on the wrapper |

**Examples**

URL input with https:// prefix:

```heex
<.input_addon>
  <.input_addon_prefix>https://</.input_addon_prefix>
  <.input type="text" name="domain" placeholder="yoursite.com" class="rounded-l-none" />
</.input_addon>
```

Search input with icon prefix and clear button suffix:

```heex
<.input_addon>
  <.input_addon_prefix>
    <.icon name="hero-magnifying-glass" class="size-4 text-muted-foreground" />
  </.input_addon_prefix>
  <.input type="text" name="q" value={@query} placeholder="Search…" class="rounded-none" />
  <.input_addon_suffix>
    <button phx-click="clear_search" class="px-2 text-muted-foreground hover:text-foreground">
      <.icon name="hero-x-mark" class="size-4" />
    </button>
  </.input_addon_suffix>
</.input_addon>
```

---

## segmented_control

A radio-button-based tab bar with a CSS animated active indicator that slides between options.
Useful for mode switching (e.g., list/grid view, time range filters).

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | Used as radio group id |
| `name` | `string` | required | Radio input `name` |
| `segments` | `list` | required | `[%{value: "v", label: "L"}, ...]` |
| `value` | `string` | `nil` | Currently selected value |
| `on_change` | `string` | `nil` | phx-change event |
| `size` | `atom` | `:default` | `:sm` / `:default` / `:lg` |

**Examples**

View toggle:

```heex
<.segmented_control
  id="view-toggle"
  name="view"
  value={@view}
  segments={[%{value: "list", label: "List"}, %{value: "grid", label: "Grid"}, %{value: "map", label: "Map"}]}
  on_change="set_view"
/>
```

Time range filter:

```heex
<.segmented_control
  id="range-filter"
  name="range"
  value={@range}
  size={:sm}
  segments={[
    %{value: "1d", label: "1D"},
    %{value: "7d", label: "7D"},
    %{value: "30d", label: "30D"},
    %{value: "ytd", label: "YTD"}
  ]}
  phx-change="update_range"
/>
```

---

## chip

A compact interactive label. Can act as a toggle (pressed/unpressed) or be dismissible.
`chip_group/1` wraps multiple chips in a flex row. Companion: `chip_group/1`.

**Key attrs (chip/1)**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `label` | `string` | required | Chip text |
| `variant` | `atom` | `:default` | `:default` / `:secondary` / `:outline` |
| `size` | `atom` | `:default` | `:sm` / `:default` / `:lg` |
| `pressed` | `boolean` | `false` | Toggle state; sets `aria-pressed` |
| `on_dismiss` | `string` | `nil` | If set, renders a remove (×) button |
| `on_press` | `string` | `nil` | phx-click for toggle |

**Examples**

Tag filter chips:

```heex
<.chip_group>
  <%= for tag <- @available_tags do %>
    <.chip
      label={tag.name}
      pressed={tag.name in @selected_tags}
      variant={:outline}
      phx-click="toggle_tag"
      phx-value-tag={tag.name}
    />
  <% end %>
</.chip_group>
```

Dismissible selected values:

```heex
<.chip_group>
  <%= for item <- @selections do %>
    <.chip
      label={item.label}
      variant={:secondary}
      on_dismiss="remove_selection"
      phx-value-id={item.id}
    />
  <% end %>
</.chip_group>
```

---

## editable

Click-to-edit inline text. Uses the `PhiaEditable` JavaScript hook to manage the view/edit state
transition. Press Enter or click outside to confirm; press Escape to cancel.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | Must be unique for the hook |
| `value` | `string` | `""` | Current display/edit value |
| `on_change` | `string` | `nil` | phx-blur / phx-keydown event |
| `placeholder` | `string` | `"Click to edit"` | Shown when value is empty |
| `tag` | `string` | `"span"` | HTML element for the display view (`"h1"`, `"p"`, etc.) |

**Examples**

Inline page title editor:

```heex
<.editable
  id="page-title"
  value={@page.title}
  tag="h1"
  placeholder="Untitled page"
  phx-blur="save_title"
/>
```

Table cell inline edit:

```heex
<td>
  <.editable
    id={"cell-#{@row.id}"}
    value={@row.name}
    on_change="update_row_name"
    phx-value-id={@row.id}
  />
</td>
```

LiveView handler:

```elixir
def handle_event("save_title", %{"value" => title}, socket) do
  {:ok, page} = MyApp.Pages.update(socket.assigns.page, %{title: title})
  {:noreply, assign(socket, :page, page)}
end
```

---

## combobox

A searchable dropdown with server-side filtering. No JavaScript hook required — search events are
sent to the LiveView which updates the options list. The trigger displays the selected label;
the dropdown is a `<ul>` rendered in a Popover.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | |
| `options` | `list` | `[]` | `[%{value: v, label: l}, ...]` |
| `value` | `any` | `nil` | Selected value |
| `on_search` | `string` | nil | phx-change for the search input |
| `on_select` | `string` | nil | phx-click for option selection |
| `placeholder` | `string` | `"Select…"` | Trigger placeholder |
| `search_placeholder` | `string` | `"Search…"` | Search input placeholder |
| `empty_message` | `string` | `"No results."` | Shown when options is empty |

**Examples**

User search combobox:

```heex
<.combobox
  id="user-search"
  options={@user_options}
  value={@selected_user}
  on_search="search_users"
  on_select="select_user"
  placeholder="Assign to…"
  search_placeholder="Search by name or email"
/>
```

LiveView handlers:

```elixir
def handle_event("search_users", %{"value" => query}, socket) do
  users = MyApp.Accounts.search(query)
  options = Enum.map(users, &%{value: &1.id, label: &1.name})
  {:noreply, assign(socket, :user_options, options)}
end

def handle_event("select_user", %{"value" => user_id}, socket) do
  {:noreply, assign(socket, :selected_user, user_id)}
end
```

---

## multi_select

A `<select multiple>` enhanced with a chip row showing selected values. Companion: `form_multi_select/1`.
The component includes a `find_label/2` helper to map values back to display labels.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `options` | `list` | required | `[{"Label", value}, ...]` |
| `value` | `list` | `[]` | List of selected values |
| `name` | `string` | `nil` | Form field name |
| `on_change` | `string` | `nil` | phx-change event |
| `placeholder` | `string` | `"Select…"` | Shown when nothing selected |

**Examples**

Permission selector:

```heex
<.multi_select
  id="permissions"
  name="permissions"
  value={@selected_permissions}
  options={[
    {"Read", "read"},
    {"Write", "write"},
    {"Delete", "delete"},
    {"Admin", "admin"}
  ]}
  phx-change="update_permissions"
/>
```

FormField variant:

```heex
<.form_multi_select
  field={@form[:tags]}
  label="Tags"
  options={Enum.map(@tags, &{&1.name, &1.id})}
/>
```

---

## tags_input

Multi-tag text input. Tags are stored in a hidden `<input>` as a comma-separated value. The
`PhiaTagsInput` hook handles rendering the tag pills, creating new tags on Enter/comma, and
deleting tags via backspace or the × button.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `field` | `Phoenix.HTML.FormField` | `nil` | Provides hidden input name + initial value |
| `id` | `string` | required | Hook anchor |
| `placeholder` | `string` | `"Add tag…"` | Text input placeholder |
| `separator` | `string` | `","` | Character that triggers tag creation |
| `max_tags` | `integer` | `nil` | Maximum number of tags allowed |

**Examples**

Blog post tags:

```heex
<.tags_input
  id="post-tags"
  field={@form[:tags]}
  placeholder="Add tag and press Enter"
  max_tags={10}
/>
```

Standalone without Ecto:

```heex
<.tags_input
  id="skill-tags"
  name="skills"
  value={Enum.join(@skills, ",")}
  placeholder="Type a skill…"
  phx-change="update_skills"
/>
```

---

## file_upload

Drag-and-drop file upload zone backed by Phoenix LiveView's native `allow_upload/3` mechanism.
Sub-component `file_upload_entry/1` renders a progress bar and cancel button per entry.
Uses `phx-drop-target` for drag-and-drop support.

**Key attrs (file_upload/1)**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `upload` | `Phoenix.LiveView.UploadConfig` | required | From `@uploads.field_name` |
| `label` | `string` | `"Upload files"` | Drop zone label |
| `description` | `string` | `nil` | Allowed types description |
| `class` | `string` | `nil` | Extra classes |

**Examples**

Document upload with entries:

```heex
<.file_upload upload={@uploads.documents} label="Upload documents" description="PDF, DOC up to 10MB">
  <%= for entry <- @uploads.documents.entries do %>
    <.file_upload_entry
      entry={entry}
      on_cancel="cancel_upload"
      phx-value-ref={entry.ref}
    />
  <% end %>
</.file_upload>
```

LiveView setup:

```elixir
def mount(_params, _session, socket) do
  {:ok, allow_upload(socket, :documents,
    accept: ~w(.pdf .doc .docx),
    max_entries: 5,
    max_file_size: 10_000_000
  )}
end

def handle_event("cancel_upload", %{"ref" => ref}, socket) do
  {:noreply, cancel_upload(socket, :documents, ref)}
end

def handle_event("save", _params, socket) do
  paths = consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
    dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", entry.client_name])
    File.cp!(path, dest)
    {:ok, ~p"/uploads/#{entry.client_name}"}
  end)
  {:noreply, update(socket, :uploaded_files, &(&1 ++ paths))}
end
```

---

## image_upload

Image-specific upload zone with an inline preview grid showing thumbnails of uploaded entries.
Built on Phoenix's `live_file_input/1` and `live_img_preview/1`.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `upload` | `Phoenix.LiveView.UploadConfig` | required | From `@uploads.field_name` |
| `label` | `string` | `"Upload images"` | Drop zone label |
| `cols` | `integer` | `3` | Preview grid column count |

**Examples**

Product image gallery upload:

```heex
<.image_upload
  upload={@uploads.images}
  label="Add product images"
  cols={4}
/>

<div class="grid grid-cols-4 gap-2 mt-4">
  <%= for entry <- @uploads.images.entries do %>
    <div class="relative">
      <.live_img_preview entry={entry} class="rounded-lg aspect-square object-cover" />
      <button
        phx-click="cancel_image"
        phx-value-ref={entry.ref}
        class="absolute top-1 right-1 bg-black/50 text-white rounded-full p-0.5"
      >
        <.icon name="hero-x-mark" class="size-3" />
      </button>
    </div>
  <% end %>
</div>
```

---

## rich_text_editor

WYSIWYG rich text editor backed by the `PhiaRichTextEditor` JavaScript hook. Supports 14 toolbar
commands. The editor syncs its HTML content to a hidden textarea on every change, making it
compatible with standard Phoenix form submissions.

**Supported toolbar commands**

Bold, Italic, Underline, Strike, H1, H2, H3, Paragraph, Bullet List, Ordered List, Blockquote,
Code Block, Inline Code, Link.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | Hook anchor |
| `field` | `Phoenix.HTML.FormField` | `nil` | Wires hidden input name + initial value |
| `label` | `string` | `nil` | Label rendered above the toolbar |
| `placeholder` | `string` | `"Write something…"` | Editor placeholder |
| `min_height` | `string` | `"200px"` | CSS min-height of the editor area |

**Examples**

Blog post editor:

```heex
<.rich_text_editor
  id="post-body"
  field={@form[:body]}
  label="Post content"
  placeholder="Start writing your post…"
  min_height="400px"
/>
```

Standalone without a form:

```heex
<.rich_text_editor
  id="notes-editor"
  name="notes"
  label="Notes"
  placeholder="Add your notes here…"
  phx-change="update_notes"
/>
```

---

## color_picker

Color picker combining a native `<input type="color">` swatch trigger, a hex text input, and an
optional row of preset swatches. The `PhiaColorPicker` hook keeps all three views in sync.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | Hook anchor |
| `value` | `string` | `"#000000"` | Hex color string |
| `on_change` | `string` | `nil` | phx-change event |
| `swatches` | `list` | `[]` | List of hex strings for preset swatches |
| `show_hex` | `boolean` | `true` | Show editable hex input |

**Examples**

Brand color picker with presets:

```heex
<.color_picker
  id="brand-color"
  value={@brand_color}
  on_change="update_brand_color"
  swatches={~w(#ef4444 #f97316 #eab308 #22c55e #3b82f6 #8b5cf6 #ec4899)}
/>
```

Form-integrated variant:

```heex
<.color_picker
  id="label-color"
  name="label[color]"
  value={@label.color}
  show_hex={true}
  phx-change="preview_color"
/>
```

LiveView handler:

```elixir
def handle_event("update_brand_color", %{"value" => hex}, socket) do
  {:noreply, assign(socket, :brand_color, hex)}
end
```

---

## mention_input

A textarea that intercepts `@` keystrokes and opens an autocomplete dropdown of mentionable users
or entities. Backed by the `PhiaMentionInput` JavaScript hook.

**Key attrs**

| Attr | Type | Default | Notes |
|---|---|---|---|
| `id` | `string` | required | Hook anchor |
| `suggestions` | `list` | `[]` | `[%{id: id, name: name}, ...]` updated by LiveView |
| `open` | `boolean` | `false` | Whether the dropdown is visible |
| `search` | `string` | `""` | Current mention search string |
| `on_mention` | `string` | `nil` | Event fired when `@` is typed; receives `%{"search" => ""}` |
| `on_select` | `string` | `nil` | Event fired when a suggestion is chosen |
| `placeholder` | `string` | `"Type @ to mention…"` | Textarea placeholder |
| `field` | `Phoenix.HTML.FormField` | `nil` | Wires hidden textarea for form submission |

**Examples**

Comment field with user mentions:

```heex
<.mention_input
  id="comment-body"
  field={@form[:body]}
  suggestions={@mention_suggestions}
  open={@mention_open}
  search={@mention_search}
  on_mention="search_mentions"
  on_select="insert_mention"
  placeholder="Write a comment… use @ to mention someone"
/>
```

LiveView handlers:

```elixir
def handle_event("search_mentions", %{"search" => query}, socket) do
  users = MyApp.Accounts.search_users(query, limit: 5)
  suggestions = Enum.map(users, &%{id: &1.id, name: &1.name})
  {:noreply, assign(socket, mention_suggestions: suggestions, mention_open: true, mention_search: query)}
end

def handle_event("insert_mention", %{"id" => id, "name" => name}, socket) do
  # Hook handles inserting the mention text; LiveView closes the dropdown
  {:noreply, assign(socket, mention_open: false, mention_suggestions: [])}
end
```

---

← [Back to README](../../README.md)
