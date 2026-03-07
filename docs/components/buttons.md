# Buttons

~20 button components — primary actions, toolbars, toggles, floating buttons, social auth, fancy animated buttons, and action utilities.

**Modules**: `PhiaUi.Components.Buttons`, `PhiaUi.Components.FancyButton`, `PhiaUi.Components.ActionButton`

```elixir
import PhiaUi.Components.Buttons
```

---

## Table of Contents

**Core**
- [button](#button)
- [button_group](#button_group)
- [toggle](#toggle)
- [toggle_group](#toggle_group)
- [copy_button](#copy_button)

**Floating & Back**
- [float_button](#float_button)
- [back_top](#back_top)

**Extended Buttons (v0.1.9)**
- [split_button](#split_button)
- [icon_button](#icon_button)
- [social_button](#social_button)

**Fancy Buttons**
- [gradient_button](#gradient_button)
- [shimmer_button](#shimmer_button)
- [glow_button](#glow_button)
- [pulse_button](#pulse_button)

**Action Buttons**
- [close_button](#close_button)
- [badge_button](#badge_button)
- [confirm_button](#confirm_button)
- [countdown_button](#countdown_button)

---

## button

The primary action element. 6 variants × 4 sizes, icon slot, loading state.

**Variants**: `default` · `destructive` · `outline` · `secondary` · `ghost` · `link`

**Sizes**: `sm` · `default` · `lg` · `icon`

```heex
<.button>Save</.button>
<.button variant="outline" size="sm">Cancel</.button>
<.button variant="destructive">Delete account</.button>
<.button variant="ghost" size="icon" aria-label="Settings">
  <.icon name="settings" />
</.button>

<%!-- Loading state --%>
<.button disabled={@saving}>
  <%= if @saving do %>
    <.icon name="loader" class="animate-spin mr-2" /> Saving…
  <% else %>
    Save changes
  <% end %>
</.button>

<%!-- With icon slot --%>
<.button variant="default">
  <:icon><.icon name="plus" /></:icon>
  New project
</.button>
```

**Attrs**: `variant`, `size`, `type` (default `"button"`), `disabled`, `class`, `rest` (forwarded)

---

## button_group

Groups buttons into a visually connected row.

```heex
<.button_group>
  <.button variant="outline">Previous</.button>
  <.button variant="outline">1</.button>
  <.button variant="outline">2</.button>
  <.button variant="outline">Next</.button>
</.button_group>
```

---

## toggle

Single toggle button — pressed / unpressed state.

```heex
<.toggle pressed={@bold} phx-click="toggle_bold" aria-label="Bold">
  <.icon name="bold" />
</.toggle>
```

**Attrs**: `pressed` (boolean), `variant` (`default` | `outline`), `size`, `class`

---

## toggle_group

Multiple toggles with single or multi select.

```heex
<%!-- Single select --%>
<.toggle_group type="single" value={@view} on_change="set_view">
  <.toggle_group_item value="list"><.icon name="list" /></.toggle_group_item>
  <.toggle_group_item value="grid"><.icon name="grid" /></.toggle_group_item>
</.toggle_group>

<%!-- Multi select --%>
<.toggle_group type="multiple" values={@active_formats} on_change="set_formats">
  <.toggle_group_item value="bold"><.icon name="bold" /></.toggle_group_item>
  <.toggle_group_item value="italic"><.icon name="italic" /></.toggle_group_item>
</.toggle_group>
```

---

## copy_button

Copies text to clipboard; shows a check icon for 2 seconds.

```heex
<.copy_button text={@api_key} />

<%!-- Inline with content --%>
<div class="flex items-center gap-2">
  <code class="font-mono text-sm"><%= @api_key %></code>
  <.copy_button text={@api_key} size="sm" />
</div>
```

**Attrs**: `text` (string to copy), `label` (aria-label), `size`

---

## float_button

Fixed-position floating action button.

```heex
<.float_button phx-click="new_item" position={:bottom_right} aria-label="Add item">
  <.icon name="plus" />
</.float_button>
```

**Attrs**: `position` (`:bottom_right` | `:bottom_left` | `:top_right` | `:top_left`), `size`

---

## back_top

Scroll-to-top button that appears after scrolling down. Hook: `PhiaBackTop`.

```heex
<.back_top id="back-to-top" threshold={300} />
```

**Attrs**: `id` (required), `threshold` (px scroll offset before showing, default 300)

---

## split_button

Primary action button with a dropdown for secondary actions. Hook: `PhiaSplitButton`.

```heex
<.split_button id="export-btn" label="Export" phx-click="export_csv">
  <:option phx-click="export_pdf">Export as PDF</:option>
  <:option phx-click="export_xlsx">Export as XLSX</:option>
</.split_button>
```

**Attrs**: `id` (required), `label`, `variant`, `size`

---

## icon_button

Square icon-only button with built-in aria-label support.

```heex
<.icon_button icon="trash" label="Delete" phx-click="delete" variant="destructive" />
<.icon_button icon="pencil" label="Edit" phx-click="edit" variant="ghost" size="sm" />
<.icon_button icon="settings" label="Settings" phx-click="open_settings" />
```

**Attrs**: `icon` (Lucide name), `label` (aria-label text, required), `variant`, `size`

---

## social_button

Pre-styled social auth button with inline SVG brand icon.

```heex
<.social_button provider={:github} phx-click="auth_github">
  Continue with GitHub
</.social_button>
<.social_button provider={:google} phx-click="auth_google">
  Continue with Google
</.social_button>
```

```heex
<%!-- Group for auth page --%>
<.social_button_group>
  <.social_button provider={:github} phx-click="auth_github">GitHub</.social_button>
  <.social_button provider={:google} phx-click="auth_google">Google</.social_button>
</.social_button_group>
```

**Providers**: `:github` · `:google` · `:twitter` · `:discord` · `:facebook` · `:apple`

---

## gradient_button

Button with an animated gradient background.

```heex
<.gradient_button from="from-violet-600" to="to-indigo-600" phx-click="upgrade">
  Upgrade to Pro
</.gradient_button>
```

**Attrs**: `from`, `via`, `to` (Tailwind gradient class strings), `size`, `class`

---

## shimmer_button

Button with a sweeping shimmer animation.

```heex
<.shimmer_button phx-click="launch">
  Launch product
</.shimmer_button>
```

**Attrs**: `shimmer_color` (CSS color), `background` (CSS color), `size`, `class`

---

## glow_button

Button with a coloured glow shadow that pulses on hover.

```heex
<.glow_button color="#6366f1" phx-click="cta">
  Get started free
</.glow_button>
```

**Attrs**: `color` (CSS color for glow), `size`, `class`

---

## pulse_button

Button with a pulsing ring animation — draws attention to a primary CTA.

```heex
<.pulse_button phx-click="cta" variant="default">
  Start now
</.pulse_button>
```

---

## close_button

Compact X button. Use to dismiss modals, sheets, or alerts.

```heex
<.close_button phx-click="close_modal" />
<.close_button phx-click={JS.hide(to: "#banner")} size="sm" />
```

---

## badge_button

Button with a notification badge count.

```heex
<.badge_button count={@unread_count} phx-click="open_notifications">
  <.icon name="bell" />
</.badge_button>
```

**Attrs**: `count` (integer or nil), `variant`, `size`

---

## confirm_button

Two-phase confirm — first click shows a confirmation prompt, second fires the event.

```heex
<.confirm_button
  label="Delete account"
  confirm_label="Yes, delete"
  phx-click="delete_account"
  variant="destructive"
/>
```

**Attrs**: `label`, `confirm_label`, `cancel_label`, `variant`, `size`

Hook: `PhiaConfirmButton`

---

## countdown_button

Disabled for N seconds then auto-enables. Use for resend-OTP flows.

```heex
<.countdown_button
  id="resend-btn"
  seconds={60}
  label="Resend code"
  countdown_label="Resend in {n}s"
  phx-click="resend_otp"
/>
```

**Attrs**: `id` (required), `seconds` (integer), `label`, `countdown_label` (`{n}` replaced with remaining), `variant`

Hook: `PhiaCountdownButton`

---

## Real-world patterns

### Auth page

```heex
<div class="flex flex-col gap-3 max-w-sm mx-auto">
  <.social_button provider={:github} phx-click="auth_github">
    Continue with GitHub
  </.social_button>
  <.social_button provider={:google} phx-click="auth_google">
    Continue with Google
  </.social_button>
  <.separator label="or" />
  <.button variant="outline" phx-click="show_email_form">
    Continue with email
  </.button>
</div>
```

### Toolbar

```heex
<div class="flex items-center gap-1 border rounded-md p-1">
  <.toggle_group type="multiple" values={@formats} on_change="set_format">
    <.toggle_group_item value="bold"><.icon name="bold" size="sm" /></.toggle_group_item>
    <.toggle_group_item value="italic"><.icon name="italic" size="sm" /></.toggle_group_item>
    <.toggle_group_item value="underline"><.icon name="underline" size="sm" /></.toggle_group_item>
  </.toggle_group>
  <.separator orientation={:vertical} class="h-6 mx-1" />
  <.icon_button icon="link" label="Insert link" phx-click="insert_link" variant="ghost" size="sm" />
  <.icon_button icon="image" label="Insert image" phx-click="insert_image" variant="ghost" size="sm" />
</div>
```
