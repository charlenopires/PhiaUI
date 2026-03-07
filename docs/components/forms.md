# Forms

34 form components — layout, fieldsets, checkbox groups, radio cards, cascaders, and transfer lists. These are the structural building blocks for complex forms. Pair them with [inputs.md](inputs.md) for actual input elements.

**Modules**: `PhiaUi.Components.Forms`, `PhiaUi.Components.FormLayout`, `PhiaUi.Components.FormSelects`

```elixir
import PhiaUi.Components.Forms
```

---

## Table of Contents

**Core**
- [form](#form)
- [form_field / phia_input](#form-field-integration)
- [field](#field)
- [label](#label)

**Form Layout**
- [form_section](#form_section)
- [form_fieldset](#form_fieldset)
- [form_grid](#form_grid)
- [form_row](#form_row)
- [form_actions](#form_actions)
- [form_summary](#form_summary)

**Form Feedback**
- [form_feedback](#form_feedback)
- [input_status](#input_status)

**Advanced Selects**
- [checkbox_group](#checkbox_group)
- [form_checkbox_group](#form_checkbox_group)
- [radio_card](#radio_card)
- [radio_card_group](#radio_card_group)
- [form_radio_card_group](#form_radio_card_group)
- [cascader](#cascader)
- [form_cascader](#form_cascader)
- [button_transfer_list](#button_transfer_list)

**Stepped Forms**
- [form_stepper](#form_stepper)

**Specialised Form Inputs**
- [currency_input](#currency_input) / [form_currency_input](#form_currency_input)
- [masked_input](#masked_input) / [form_masked_input](#form_masked_input)
- [range_slider](#range_slider) / [form_range_slider](#form_range_slider)
- [signature_pad](#signature_pad)
- [color_swatch_picker](#color_swatch_picker) / [form_color_swatch_picker](#form_color_swatch_picker)
- [float_input](#float_input) / [form_float_input](#form_float_input)
- [float_textarea](#float_textarea) / [form_float_textarea](#form_float_textarea)
- [country_select](#country_select) / [form_country_select](#form_country_select)

---

## form

Phoenix `<.form>` wrapper with optional error summary and consistent spacing.

```heex
<.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
  <.phia_input field={@form[:name]} label="Full name" required />
  <.phia_input field={@form[:email]} type="email" label="Email" />
  <.form_actions>
    <.button variant="outline" phx-click="cancel" type="button">Cancel</.button>
    <.button type="submit">Save changes</.button>
  </.form_actions>
</.form>
```

---

## Form field integration

Every form input works in two modes:

**Standalone** — pass `name` and `value` directly:

```heex
<.input type="text" name="query" value={@query} placeholder="Search…" />
```

**Ecto-integrated** — pass `field` and get label, validation, error display automatically:

```heex
<.phia_input field={@form[:email]} type="email" label="Email" required />
```

The `field` attr accepts `Phoenix.HTML.FormField` — PhiaUI reads `.name`, `.value`, `.errors`, and `.id` automatically.

---

## field

Bare field wrapper with label, description, and error slot — use to build custom inputs.

```heex
<.field label="Custom widget" description="Configure your preferences.">
  <:input>
    <MyApp.CustomWidget name={@form[:widget].name} value={@form[:widget].value} />
  </:input>
  <:error :for={e <- @form[:widget].errors}><%= translate_error(e) %></:error>
</.field>
```

---

## form_section

Groups a set of fields with a title and optional description. Use to divide long forms into logical blocks.

```heex
<.form for={@form} phx-submit="save">
  <.form_section title="Personal information" description="This is how others will see you.">
    <.phia_input field={@form[:name]} label="Full name" />
    <.phia_input field={@form[:bio]} type="textarea" label="Bio" />
  </.form_section>

  <.form_section title="Account settings">
    <.phia_input field={@form[:email]} type="email" label="Email" />
    <.phia_input field={@form[:username]} label="Username" />
  </.form_section>

  <.form_actions>
    <.button type="submit">Save profile</.button>
  </.form_actions>
</.form>
```

---

## form_fieldset

Named group for related fields — renders a `<fieldset>` with `<legend>`.

```heex
<.form_fieldset legend="Shipping address">
  <.phia_input field={@form[:address]} label="Street" />
  <.form_grid cols={2}>
    <.phia_input field={@form[:city]} label="City" />
    <.phia_input field={@form[:postcode]} label="Postcode" />
  </.form_grid>
</.form_fieldset>
```

---

## form_grid

Responsive column grid for form fields.

```heex
<.form_grid cols={2}>
  <.phia_input field={@form[:first_name]} label="First name" />
  <.phia_input field={@form[:last_name]} label="Last name" />
</form_grid>

<.form_grid cols={3}>
  <.phia_input field={@form[:city]} label="City" />
  <.phia_input field={@form[:state]} label="State" />
  <.phia_input field={@form[:zip]} label="ZIP" />
</.form_grid>
```

**Attrs**: `cols` (1–4, default 1), `gap` (integer, default 4)

---

## form_row

Side-by-side label + input layout (common in settings forms).

```heex
<.form_row label="Email notifications" description="Receive email updates about your account activity.">
  <.switch name="email_notif" checked={@user.email_notif} phx-change="toggle_email" />
</.form_row>
```

---

## form_actions

Sticky bottom action bar for forms.

```heex
<.form_actions sticky={true}>
  <.button variant="outline" phx-click="cancel" type="button">Discard</.button>
  <.button type="submit">Save changes</.button>
</.form_actions>
```

**Attrs**: `sticky` (boolean, uses `sticky bottom-0`)

---

## form_summary

Inline error summary listing all validation errors.

```heex
<.form_summary form={@form} />
```

Renders a `<ul>` of all field errors — useful for long forms where inline errors may scroll out of view.

---

## checkbox_group

Group of checkboxes with optional select-all.

```heex
<.checkbox_group
  label="Permissions"
  name="permissions"
  values={@selected_permissions}
  options={[{"Read", "read"}, {"Write", "write"}, {"Delete", "delete"}]}
  phx-change="update_permissions"
/>
```

---

## form_checkbox_group

Ecto-integrated checkbox group.

```heex
<.form_checkbox_group
  field={@form[:roles]}
  label="Roles"
  options={Enum.map(@all_roles, &{&1.name, &1.id})}
/>
```

---

## radio_card / radio_card_group

Card-style radio buttons — great for plan, theme, or layout pickers.

```heex
<.form for={@form} phx-submit="save">
  <.radio_card_group label="Select your plan">
    <.radio_card
      name="plan"
      value="starter"
      checked={@form[:plan].value == "starter"}
      title="Starter"
      description="For individuals and small teams."
      price="$9/mo"
    />
    <.radio_card
      name="plan"
      value="pro"
      checked={@form[:plan].value == "pro"}
      title="Pro"
      description="For growing teams."
      price="$29/mo"
    />
  </.radio_card_group>
</.form>
```

---

## cascader

Hierarchical multi-level select (province → city → district). Hook: `PhiaCascader`.

```heex
<.cascader
  id="location"
  name="location"
  options={@location_tree}
  placeholder="Select location…"
  phx-change="set_location"
/>
```

`options` is a nested list: `%{label, value, children: [...]}`.

---

## button_transfer_list

Move items between "available" and "selected" lists.

```heex
<.button_transfer_list
  id="feature-flags"
  name="features"
  available={@available_features}
  selected={@selected_features}
  on_change="update_features"
/>
```

---

## form_stepper

Multi-step form with navigation and validation per step.

```heex
<.form_stepper current_step={@step} on_next="next_step" on_prev="prev_step">
  <.form_stepper_item step={1} label="Account" valid={@step > 1}>
    <.phia_input field={@form[:email]} type="email" label="Email" />
    <.phia_input field={@form[:password]} type="password" label="Password" />
  </.form_stepper_item>

  <.form_stepper_item step={2} label="Profile">
    <.phia_input field={@form[:name]} label="Full name" />
    <.phia_input field={@form[:bio]} type="textarea" label="Bio" />
  </.form_stepper_item>

  <.form_stepper_item step={3} label="Confirm">
    <.form_summary form={@form} />
  </.form_stepper_item>
</.form_stepper>
```

---

## currency_input / form_currency_input

Number input formatted as currency with symbol.

```heex
<.currency_input name="price" value={@price} currency="USD" phx-change="set_price" />
<.form_currency_input field={@form[:price]} label="Price" currency="EUR" />
```

---

## masked_input / form_masked_input

Input with format mask (phone, date, card number). Hook: `PhiaMaskedInput`.

```heex
<.masked_input name="phone" value={@phone} mask="+1 (999) 999-9999" />
<.form_masked_input field={@form[:date_of_birth]} label="Date of birth" mask="99/99/9999" />
```

---

## range_slider / form_range_slider

Dual-handle range slider. Hook: `PhiaRangeSlider`.

```heex
<.range_slider
  id="price-range"
  name_from="price_min"
  name_to="price_max"
  from={@price_min}
  to={@price_max}
  min={0}
  max={1000}
  step={10}
  phx-change="set_range"
/>
```

---

## signature_pad

Canvas signature capture. Hook: `PhiaSignaturePad`.

```heex
<.signature_pad id="sig-pad" name="signature" phx-change="update_sig" />
```

---

## color_swatch_picker / form_color_swatch_picker

Preset colour swatches with optional custom hex input.

```heex
<.color_swatch_picker
  name="accent"
  value={@accent_color}
  swatches={["#ef4444", "#f97316", "#eab308", "#22c55e", "#3b82f6", "#8b5cf6"]}
  phx-change="set_accent"
/>
```

---

## float_input / form_float_input

Material-style floating label input — label animates up on focus.

```heex
<.float_input id="email-float" name="email" type="email" label="Email address" value={@email} />
<.form_float_input field={@form[:name]} label="Full name" />
```

---

## float_textarea / form_float_textarea

Material-style floating label textarea.

```heex
<.form_float_textarea field={@form[:message]} label="Your message" rows={5} />
```

---

## country_select / form_country_select

Select with 250 countries and flag emoji.

```heex
<.country_select name="country" value={@country} phx-change="set_country" />
<.form_country_select field={@form[:country]} label="Country" />
```

---

## Real-world: Settings page form

```heex
<.form for={@form} phx-change="validate" phx-submit="save" id="profile-form">
  <.form_section title="Public profile" description="This information will be displayed publicly.">
    <.form_grid cols={2}>
      <.phia_input field={@form[:first_name]} label="First name" required />
      <.phia_input field={@form[:last_name]} label="Last name" required />
    </.form_grid>
    <.phia_input field={@form[:username]} label="Username" />
    <.phia_input field={@form[:bio]} type="textarea" label="Bio" rows={3} />
    <.phia_input field={@form[:website]} type="url" label="Website" />
  </.form_section>

  <.form_section title="Notifications">
    <.form_row label="Email updates" description="Receive news and product updates via email.">
      <.switch name="notif_email" checked={@form[:notif_email].value} phx-change="toggle" />
    </.form_row>
    <.form_row label="Weekly digest" description="A summary of activity every Monday.">
      <.switch name="notif_digest" checked={@form[:notif_digest].value} phx-change="toggle" />
    </.form_row>
  </.form_section>

  <.form_actions sticky={true}>
    <.button variant="outline" phx-click="reset" type="button">Discard changes</.button>
    <.button type="submit" disabled={not @form.source.valid?}>Save profile</.button>
  </.form_actions>
</.form>
```
