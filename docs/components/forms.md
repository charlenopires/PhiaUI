# Forms

Form layout primitives. Integrate with `Phoenix.HTML.Form` and Ecto changesets. These are the structural building blocks — pair them with components from [inputs.md](inputs.md) for actual input elements.

## Table of Contents

- [form](#form)
- [field](#field)
- [form_field](#form_field)
- [label](#label)
- [Error Translation](#error-translation)
- [Recipes](#recipes)

---

## form

Thin wrapper around `Phoenix.Component.form/1`. Forwards `for`, `phx-change`, `phx-submit`, and all global HTML attributes to `<form>`.

```heex
<%!-- Basic Ecto-integrated form --%>
<.form for={@form} phx-change="validate" phx-submit="save">
  <div class="space-y-4">
    <.phia_input field={@form[:name]}  label="Full name" />
    <.phia_input field={@form[:email]} type="email" label="Email" phx-debounce="blur" />
  </div>
  <.button type="submit" class="mt-6">Save</.button>
</.form>

<%!-- Sign-up form --%>
<.form for={@form} phx-change="validate" phx-submit="register">
  <div class="space-y-4">
    <div class="grid grid-cols-2 gap-4">
      <.phia_input field={@form[:first_name]} label="First name" />
      <.phia_input field={@form[:last_name]}  label="Last name" />
    </div>
    <.phia_input field={@form[:email]}    type="email"    label="Email" />
    <.phia_input field={@form[:password]} type="password" label="Password" />
    <.form_checkbox field={@form[:terms]} label="I accept the Terms of Service" />
    <.button type="submit" class="w-full">Create account</.button>
  </div>
</.form>
```

```elixir
def handle_event("validate", %{"user" => params}, socket) do
  form = %User{} |> User.changeset(params) |> to_form(action: :validate)
  {:noreply, assign(socket, form: form)}
end

def handle_event("register", %{"user" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, _user} -> {:noreply, push_navigate(socket, to: ~p"/dashboard")}
    {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## field

Standalone `space-y-2` layout wrapper for custom inputs **without** a `Phoenix.HTML.FormField` binding. Use when you have no Ecto changeset.

**Sub-components**: `field_label/1`, `field_description/1`, `field_message/1`

```heex
<%!-- Custom field layout --%>
<.field>
  <.field_label for="username">Username</.field_label>
  <input id="username" name="username" type="text" class="phia-input" />
  <.field_description>3–20 characters. Letters, numbers, underscores.</.field_description>
  <.field_message :if={@username_error} error={@username_error} />
</.field>

<%!-- Terms checkbox --%>
<.field>
  <div class="flex items-center gap-2">
    <.checkbox id="terms" name="terms" phx-click="toggle-terms" checked={@terms_checked} />
    <.field_label for="terms">
      I agree to the <a href="/terms" class="underline">Terms of Service</a>
    </.field_label>
  </div>
  <.field_message :if={@terms_error} error={@terms_error} />
</.field>

<%!-- Password with strength hint --%>
<.field>
  <.field_label for="pass" required>Password</.field_label>
  <.password_input id="pass" name="password" value={@password} />
  <.field_description>Use at least 8 characters, a mix of letters and numbers.</.field_description>
</.field>

<%!-- Inline label + input row --%>
<.field class="flex items-center justify-between">
  <.field_label for="dark-mode">Dark mode</.field_label>
  <.switch id="dark-mode" name="dark_mode" checked={@dark_mode} phx-click="toggle-dark-mode" />
</.field>
```

---

## form_field

`Phoenix.HTML.FormField`-aware layout. Reads errors from the changeset automatically.

**Sub-components**: `form_label/1`, `form_message/1`

```heex
<%!-- Basic usage (rarely needed directly — phia_input wraps this) --%>
<.form for={@form} phx-submit="save">
  <.form_field field={@form[:email]}>
    <.form_label>Email</.form_label>
    <input type="email" name={@form[:email].name} value={@form[:email].value} class="phia-input" />
    <.form_message field={@form[:email]} />
  </.form_field>
</.form>

<%!-- Custom compound field --%>
<.form_field field={@form[:price]}>
  <.form_label>Price</.form_label>
  <.input_addon>
    <:prefix>$</:prefix>
    <input type="number" name={@form[:price].name} value={@form[:price].value} class="phia-input" />
    <:suffix>USD</:suffix>
  </.input_addon>
  <.form_message field={@form[:price]} />
</.form_field>
```

---

## label

Accessible `<label>` element with `for` binding and optional required indicator.

```heex
<.label for="email">Email address</.label>
<.label for="name" required>Full name</.label>
<.label for="bio" class="text-sm font-normal text-muted-foreground">Bio (optional)</.label>
```

---

## Error Translation

PhiaUI form components translate Ecto changeset errors using the standard Phoenix `translate_error/1` helper. Custom error messages are passed as `message` in the validation tuple:

```elixir
# In your schema
validates :email,
  format: [with: ~r/@/, message: "must be a valid email address"],
  length: [max: 160, message: "is too long (max 160 chars)"]

# With custom translation
def translate_error({msg, opts}) do
  Enum.reduce(opts, msg, fn {key, value}, acc ->
    String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
  end)
end
```

---

## Recipes

### Settings page pattern

```heex
<.card>
  <.card_header>
    <.card_title>Profile</.card_title>
    <.card_description>Update your public profile information.</.card_description>
  </.card_header>
  <.card_content>
    <.form for={@form} phx-change="validate" phx-submit="save-profile">
      <div class="space-y-6">
        <div class="flex items-center gap-6">
          <.avatar size="xl">
            <.avatar_image src={@current_user.avatar_url} />
            <.avatar_fallback name={@current_user.name} />
          </.avatar>
          <.image_upload upload={@uploads.avatar} label="Change avatar" />
        </div>
        <.separator />
        <div class="grid grid-cols-2 gap-4">
          <.phia_input field={@form[:first_name]} label="First name" />
          <.phia_input field={@form[:last_name]}  label="Last name" />
        </div>
        <.phia_input field={@form[:username]} label="Username"
          description="Your unique identifier on the platform." />
        <.phia_input field={@form[:website]} label="Website" placeholder="https://" />
        <.field>
          <.field_label for="bio-field">Bio</.field_label>
          <.textarea id="bio-field" name="user[bio]" rows={3}
            placeholder="Tell us about yourself…" value={@form[:bio].value} />
        </.field>
      </div>
      <.card_footer class="mt-6 px-0">
        <.button type="submit">Save changes</.button>
        <.button variant="ghost" type="button" phx-click="cancel">Cancel</.button>
      </.card_footer>
    </.form>
  </.card_content>
</.card>
```

### Multi-step form

```heex
<%!-- Step tracker showing progress --%>
<.step_tracker class="mb-8">
  <.step step={1} label="Account"   status={step_status(@step, 1)} />
  <.step step={2} label="Profile"   status={step_status(@step, 2)} />
  <.step step={3} label="Billing"   status={step_status(@step, 3)} />
  <.step step={4} label="Confirm"   status={step_status(@step, 4)} />
</.step_tracker>

<%!-- Step 1 --%>
<div :if={@step == 1}>
  <.form for={@form} phx-submit="next-step">
    <.phia_input field={@form[:email]}    type="email"    label="Email" />
    <.phia_input field={@form[:password]} type="password" label="Password" />
    <.button type="submit" class="mt-4 w-full">Continue</.button>
  </.form>
</div>

<%!-- Step 2 --%>
<div :if={@step == 2}>
  <.form for={@form} phx-submit="next-step">
    <div class="space-y-4">
      <.phia_input field={@form[:name]} label="Full name" />
      <.form_select field={@form[:timezone]} label="Timezone" options={timezone_options()} />
    </div>
    <div class="flex gap-2 mt-4">
      <.button variant="outline" type="button" phx-click="prev-step">Back</.button>
      <.button type="submit" class="flex-1">Continue</.button>
    </div>
  </.form>
</div>
```

← [Back to README](../../README.md)
