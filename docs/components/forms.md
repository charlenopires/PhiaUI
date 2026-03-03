# Form Components

All form components integrate with `Phoenix.HTML.Form` and Ecto changesets. They display inline validation errors, support `phx-debounce`, and follow WAI-ARIA labelling conventions.

- [Input](#input)
- [Textarea](#textarea)
- [Select](#select)
- [Form primitives](#form-primitives)
- [Tags Input](#tags-input)
- [Image Upload](#image-upload)
- [Rich Text Editor](#rich-text-editor)

---

## Input

Label + input + optional description + Ecto changeset errors in one component.

```heex
<.phia_input field={@form[:email]} type="email" label="Email address" />
<.phia_input field={@form[:name]} label="Full name" description="As it appears on your ID." />
<.phia_input field={@form[:password]} type="password" label="Password" />
<.phia_input field={@form[:amount]} type="number" label="Amount" placeholder="0.00" />
```

### With debounce

```heex
<.phia_input
  field={@form[:slug]}
  label="URL slug"
  description="Lowercase letters, hyphens only."
  phx-debounce="500"
/>
```

### Full sign-up form

```heex
<.form for={@form} phx-change="validate" phx-submit="register">
  <div class="space-y-4">
    <div class="grid grid-cols-2 gap-4">
      <.phia_input field={@form[:first_name]} label="First name" />
      <.phia_input field={@form[:last_name]} label="Last name" />
    </div>
    <.phia_input field={@form[:email]} type="email" label="Email" />
    <.phia_input field={@form[:password]} type="password" label="Password" />
    <.phia_input field={@form[:password_confirmation]} type="password" label="Confirm password" />
    <.button type="submit" class="w-full">Create account</.button>
  </div>
</.form>
```

### LiveView validate + submit pattern

```elixir
def handle_event("validate", %{"user" => params}, socket) do
  form = %User{} |> User.changeset(params) |> to_form(action: :validate)
  {:noreply, assign(socket, form: form)}
end

def handle_event("register", %{"user" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, user} -> {:noreply, push_navigate(socket, to: ~p"/dashboard")}
    {:error, cs} -> {:noreply, assign(socket, form: to_form(cs))}
  end
end
```

---

## Textarea

Multi-line form field with changeset error display.

```heex
<.phia_textarea field={@form[:bio]} label="Bio" rows={4} />
<.phia_textarea field={@form[:notes]} label="Notes" placeholder="Add any notes…" />
<.phia_textarea
  field={@form[:description]}
  label="Description"
  description="Max 500 characters."
  rows={6}
/>
```

---

## Select

Native `<select>` with FormField integration.

```heex
<.phia_select
  field={@form[:role]}
  options={["Admin", "Editor", "Viewer"]}
  label="Role"
  prompt="Choose a role…"
/>

<%!-- With keyword list for value/label pairs --%>
<.phia_select
  field={@form[:country]}
  options={[{"United States", "us"}, {"Brazil", "br"}, {"Portugal", "pt"}]}
  label="Country"
/>

<%!-- Loaded from database --%>
<.phia_select
  field={@form[:team_id]}
  options={Enum.map(@teams, &{&1.name, &1.id})}
  label="Team"
  prompt="Select team…"
/>
```

---

## Form Primitives

Low-level building blocks for custom form layouts.

```heex
<.form_field>
  <.form_label for="custom-input">Label text</.form_label>
  <input id="custom-input" type="text" class="…" />
  <.form_message>Validation message here.</.form_message>
</.form_field>
```

### Building a custom two-column row

```heex
<div class="grid grid-cols-2 gap-4">
  <.form_field>
    <.form_label for="city">City</.form_label>
    <input id="city" type="text" name="address[city]" class="phia-input" />
  </.form_field>
  <.form_field>
    <.form_label for="zip">ZIP Code</.form_label>
    <input id="zip" type="text" name="address[zip]" class="phia-input" />
  </.form_field>
</div>
```

---

## Tags Input

Multi-value input with deduplication. Tags are synced to a hidden CSV input for form submission.

```heex
<.tags_input
  field={@form[:tags]}
  label="Tags"
  placeholder="Type and press Enter…"
  separator=","
/>
```

### With initial values from assigns

```heex
<.tags_input
  field={@form[:skills]}
  label="Skills"
  placeholder="Add a skill…"
/>
```

The component reads the current value from `field.value` (a comma-separated string) and splits it into individual tag chips automatically.

### Requires PhiaTagsInput hook

```javascript
// assets/js/app.js
import PhiaTagsInput from "./phia_hooks/tags_input"
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaTagsInput }
})
```

### LiveView handler

```elixir
# Tags arrive as a comma-separated string in params
def handle_event("validate", %{"post" => %{"tags" => tags_csv}}, socket) do
  tags = String.split(tags_csv, ",", trim: true)
  # validate as normal
end
```

---

## Image Upload

Drop zone + file picker + preview grid. Uses native Phoenix LiveView uploads — no custom upload endpoint needed.

```heex
<.live_file_input upload={@uploads.avatar} class="sr-only" />
<.image_upload upload={@uploads.avatar} label="Profile photo" />
```

### Multiple file upload

```heex
<.live_file_input upload={@uploads.photos} class="sr-only" />
<.image_upload
  upload={@uploads.photos}
  label="Product photos"
  description="Up to 5 photos. JPG or PNG, max 5MB each."
/>
```

### LiveView setup

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> allow_upload(:avatar,
     accept: ~w(.jpg .jpeg .png .webp),
     max_entries: 1,
     max_file_size: 5_000_000
   )}
end

def handle_event("save", _params, socket) do
  urls =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:my_app), "static/uploads", Path.basename(path)])
      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)

  {:noreply, update(socket, :uploaded_urls, &(&1 ++ urls))}
end
```

---

## Rich Text Editor

WYSIWYG editor using `contenteditable` + `document.execCommand()`. Zero npm dependencies.

```heex
<.rich_text_editor
  field={@form[:content]}
  label="Content"
  placeholder="Start writing…"
  min_height="200px"
/>
```

### With custom height for long-form content

```heex
<.rich_text_editor
  field={@form[:article_body]}
  label="Article body"
  placeholder="Write your article…"
  min_height="400px"
/>
```

### Toolbar commands

| Category | Commands |
|----------|----------|
| Text style | Bold, Italic, Underline, Strikethrough |
| Headings | H1, H2, H3, Paragraph |
| Lists | Bullet list, Ordered list |
| Blocks | Blockquote, Code block |
| Inline | Inline code, Insert link |

### Requires PhiaRichTextEditor hook

```javascript
import PhiaRichTextEditor from "./phia_hooks/rich_text_editor"
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaRichTextEditor }
})
```

### Reading HTML content in LiveView

```elixir
def handle_event("save", %{"post" => params}, socket) do
  # params["content"] contains sanitized HTML
  case Posts.create(params) do
    {:ok, post} -> {:noreply, push_navigate(socket, to: ~p"/posts/#{post}")}
    {:error, cs} -> {:noreply, assign(socket, form: to_form(cs))}
  end
end
```

---

## Checkbox

Native HTML checkbox styled with Tailwind, with `indeterminate` state support and FormField integration.

```heex
<%!-- Standalone --%>
<.checkbox id="agree" name="agree" />
<.checkbox id="agree" name="agree" checked={true} />
<.checkbox id="partials" name="partials" indeterminate={true} />
<.checkbox id="disabled" name="disabled" disabled={true} />

<%!-- With Field wrapper (no Ecto) --%>
<.field>
  <div class="flex items-center gap-2">
    <.checkbox id="terms" name="terms" phx-change="toggle-terms" />
    <.field_label for="terms" required={true}>
      I agree to the <a href="/terms" class="underline">Terms of Service</a>
    </.field_label>
  </div>
  <.field_message error={@terms_error} />
</.field>

<%!-- With FormField (Ecto changeset) --%>
<.form for={@form} phx-change="validate" phx-submit="save">
  <.form_checkbox
    field={@form[:newsletter]}
    label="Subscribe to newsletter"
  />
  <.form_checkbox
    field={@form[:terms_accepted]}
    label="I accept the terms"
    required
  />
  <.button type="submit">Register</.button>
</.form>

<%!-- Select all / indeterminate pattern --%>
<.field>
  <div class="flex items-center gap-2">
    <.checkbox
      id="select-all"
      indeterminate={@some_selected}
      checked={@all_selected}
      phx-click="toggle-all"
    />
    <.field_label for="select-all">Select All</.field_label>
  </div>
</.field>
<.field :for={item <- @items}>
  <div class="flex items-center gap-2">
    <.checkbox
      id={"item-#{item.id}"}
      name="items[]"
      value={item.id}
      checked={item.id in @selected_ids}
      phx-click="toggle-item"
      phx-value-id={item.id}
    />
    <.field_label for={"item-#{item.id}"}>{item.name}</.field_label>
  </div>
</.field>
```

### ARIA states

| State | `data-state` | `aria-checked` |
|-------|-------------|----------------|
| Unchecked | `"unchecked"` | `"false"` |
| Checked | `"checked"` | `"true"` |
| Indeterminate | `"indeterminate"` | `"mixed"` |

---

## Calendar

Server-rendered monthly calendar grid for date selection.

```heex
<%!-- Single mode --%>
<.calendar
  id="booking-cal"
  value={@selected_date}
  current_month={@current_month}
  on_change="pick-date"
/>

<%!-- With constraints --%>
<.calendar
  id="delivery-cal"
  value={@delivery_date}
  current_month={@current_month}
  min={Date.utc_today()}
  max={Date.add(Date.utc_today(), 30)}
  disabled_dates={@unavailable_dates}
  on_change="pick-delivery"
/>
```

```elixir
def handle_event("pick-date", %{"date" => iso}, socket) do
  {:noreply, assign(socket, selected_date: Date.from_iso8601!(iso))}
end

def handle_event("calendar-prev-month", %{"month" => iso}, socket) do
  {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
end

def handle_event("calendar-next-month", %{"month" => iso}, socket) do
  {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
end
```

### Hook registration

```javascript
import PhiaCalendar from "./phia_hooks/calendar"
```

← [Back to README](../../README.md)
