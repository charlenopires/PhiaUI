defmodule PhiaUi.Components.SpecialEntry do
  @moduledoc """
  Special entry input components for PhiaUI.

  Provides compound input widgets for structured data entry:

  - `verifiable_input/1` + `form_verifiable_input/1` — two fields that must match
    (confirm email / confirm password). Server validates; second field shows status.
  - `duration_input/1` + `form_duration_input/1` — HH:MM:SS segmented time entry.
  - `split_input/1` + `split_input_field/1` — multi-slot inputs that concatenate
    to one value with auto-advance (PhiaSplitInput hook).
  - `credit_card_input/1` + `form_credit_card_input/1` — four-panel card form with
    number formatting and auto-advance (PhiaCreditCard hook).
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # verifiable_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id prefix for both input elements.")

  attr(:type, :atom,
    values: [:text, :password, :email],
    default: :password,
    doc: "Input type for both fields."
  )

  attr(:name, :string, default: "value", doc: "Name for the primary input.")
  attr(:confirm_name, :string, default: "confirm_value", doc: "Name for the confirmation input.")
  attr(:value, :string, default: "", doc: "Value for the primary input.")
  attr(:confirm_value, :string, default: "", doc: "Value for the confirmation input.")

  attr(:matched, :boolean,
    default: nil,
    doc: "Server-computed match status. `nil` = untouched, `true` = match, `false` = mismatch."
  )

  attr(:placeholder, :string, default: nil, doc: "Placeholder for the primary input.")
  attr(:confirm_placeholder, :string, default: nil, doc: "Placeholder for the confirmation input.")
  attr(:size, :atom, values: [:sm, :default, :lg], default: :default, doc: "Input size.")
  attr(:disabled, :boolean, default: false, doc: "Disables both inputs.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes on the wrapper.")

  @doc """
  Renders two inputs that must match. The second field shows a check (matched),
  error (mismatch), or nothing (untouched) based on the `matched` attr.
  """
  def verifiable_input(assigns) do
    primary_id = (assigns.id && "#{assigns.id}-primary") || assigns.name
    confirm_id = (assigns.id && "#{assigns.id}-confirm") || assigns.confirm_name
    assigns = assigns |> assign(:primary_id, primary_id) |> assign(:confirm_id, confirm_id)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <input
        type={Atom.to_string(@type)}
        id={@primary_id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        class={cn([input_base_class(), input_size_class(@size)])}
        aria-label="Value"
      />
      <div class="relative">
        <input
          type={Atom.to_string(@type)}
          id={@confirm_id}
          name={@confirm_name}
          value={@confirm_value}
          placeholder={@confirm_placeholder}
          disabled={@disabled}
          class={cn([
            input_base_class(),
            input_size_class(@size),
            "pr-9",
            @matched == false && "border-destructive focus-visible:ring-destructive"
          ])}
          aria-label="Confirm value"
          aria-invalid={@matched == false && "true"}
        />
        <%= if @matched == true do %>
          <span class="absolute right-3 top-1/2 -translate-y-1/2 text-green-500" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20 6 9 17l-5-5" />
            </svg>
          </span>
        <% end %>
        <%= if @matched == false do %>
          <span class="absolute right-3 top-1/2 -translate-y-1/2 text-destructive" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </span>
          <p class="text-xs text-destructive mt-1">Values do not match</p>
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_verifiable_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "Primary form field.")
  attr(:confirm_field, Phoenix.HTML.FormField, required: true, doc: "Confirmation form field.")
  attr(:label, :string, default: nil, doc: "Label text shown above the inputs.")
  attr(:description, :string, default: nil, doc: "Helper text.")

  attr(:type, :atom,
    values: [:text, :password, :email],
    default: :password,
    doc: "Input type."
  )

  attr(:placeholder, :string, default: nil, doc: "Primary placeholder.")
  attr(:confirm_placeholder, :string, default: nil, doc: "Confirmation placeholder.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  FormField-integrated wrapper for `verifiable_input/1`.
  Derives names/values from fields; computes `matched` from field values.
  """
  def form_verifiable_input(
        %{field: %Phoenix.HTML.FormField{} = field,
          confirm_field: %Phoenix.HTML.FormField{} = confirm_field} = assigns
      ) do
    primary_val = field.value || ""
    confirm_val = confirm_field.value || ""
    matched =
      cond do
        primary_val == "" and confirm_val == "" -> nil
        primary_val == confirm_val -> true
        true -> false
      end

    all_errors =
      Enum.map(field.errors ++ confirm_field.errors, &translate_error/1)

    assigns =
      assigns
      |> assign(:primary_val, primary_val)
      |> assign(:confirm_val, confirm_val)
      |> assign(:matched, matched)
      |> assign(:all_errors, all_errors)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label :if={@label} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.verifiable_input
        id={@field.id}
        type={@type}
        name={@field.name}
        confirm_name={@confirm_field.name}
        value={@primary_val}
        confirm_value={@confirm_val}
        matched={@matched}
        placeholder={@placeholder}
        confirm_placeholder={@confirm_placeholder}
      />
      <p :for={error <- @all_errors} class="text-sm font-medium text-destructive">
        {error}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # duration_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id prefix for the inner inputs.")
  attr(:name, :string, default: "duration", doc: "Form field name for the hidden total-seconds input.")

  attr(:value, :any,
    default: 0,
    doc: "Duration as integer seconds (e.g. `3661`) or \"HH:MM:SS\" string."
  )

  attr(:show_hours, :boolean, default: true, doc: "Show the hours field.")
  attr(:show_seconds, :boolean, default: true, doc: "Show the seconds field.")
  attr(:max_hours, :integer, default: 99, doc: "Maximum allowed hours value.")
  attr(:disabled, :boolean, default: false, doc: "Disables all fields.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders HH:MM:SS segmented time-duration inputs.
  Each segment is a constrained number input. A hidden input carries the total
  seconds for form submission.
  """
  def duration_input(assigns) do
    {h, m, s} = parse_duration(assigns.value)
    assigns = assigns |> assign(:_h, h) |> assign(:_m, m) |> assign(:_s, s)
    total = h * 3600 + m * 60 + s
    assigns = assign(assigns, :_total, total)

    ~H"""
    <div class={cn(["flex items-center gap-1", @class])}>
      <%= if @show_hours do %>
        <div class="flex flex-col items-center">
          <input
            type="number"
            id={@id && "#{@id}-hours"}
            name={@name && "#{@name}[hours]"}
            value={@_h}
            min="0"
            max={@max_hours}
            step="1"
            disabled={@disabled}
            class={cn([input_base_class(), "w-16 text-center [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none"])}
            aria-label="Hours"
            placeholder="HH"
          />
          <span class="text-xs text-muted-foreground mt-0.5">hr</span>
        </div>
        <span class="text-muted-foreground font-bold pb-4">:</span>
      <% end %>

      <div class="flex flex-col items-center">
        <input
          type="number"
          id={@id && "#{@id}-minutes"}
          name={@name && "#{@name}[minutes]"}
          value={@_m}
          min="0"
          max="59"
          step="1"
          disabled={@disabled}
          class={cn([input_base_class(), "w-16 text-center [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none"])}
          aria-label="Minutes"
          placeholder="MM"
        />
        <span class="text-xs text-muted-foreground mt-0.5">min</span>
      </div>

      <%= if @show_seconds do %>
        <span class="text-muted-foreground font-bold pb-4">:</span>
        <div class="flex flex-col items-center">
          <input
            type="number"
            id={@id && "#{@id}-seconds"}
            name={@name && "#{@name}[seconds]"}
            value={@_s}
            min="0"
            max="59"
            step="1"
            disabled={@disabled}
            class={cn([input_base_class(), "w-16 text-center [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none"])}
            aria-label="Seconds"
            placeholder="SS"
          />
          <span class="text-xs text-muted-foreground mt-0.5">sec</span>
        </div>
      <% end %>

      <input type="hidden" name={@name} value={@_total} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_duration_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct.")
  attr(:label, :string, default: nil, doc: "Label text.")
  attr(:description, :string, default: nil, doc: "Helper text.")
  attr(:show_hours, :boolean, default: true, doc: "Show the hours field.")
  attr(:show_seconds, :boolean, default: true, doc: "Show the seconds field.")
  attr(:max_hours, :integer, default: 99, doc: "Maximum allowed hours.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  FormField-integrated wrapper for `duration_input/1`.
  """
  def form_duration_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:value, fn -> field.value || 0 end)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label :if={@label} class="text-sm font-medium leading-none">{@label}</label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.duration_input
        id={@field.id}
        name={@field.name}
        value={@value}
        show_hours={@show_hours}
        show_seconds={@show_seconds}
        max_hours={@max_hours}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # split_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root element ID — required for PhiaSplitInput hook.")
  attr(:name, :string, default: nil, doc: "Hidden input name carrying the concatenated value.")
  attr(:separator, :string, default: "", doc: "String inserted between slot values when joining.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes on the container.")

  slot(:inner_block, required: true, doc: "Contains `split_input_field/1` components.")

  @doc """
  A multi-slot input that concatenates slot values into one hidden field value.
  The `PhiaSplitInput` hook handles auto-advance on fill, backspace, and paste.
  """
  def split_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex items-center gap-2", @class])}
      phx-hook="PhiaSplitInput"
      data-separator={@separator}
      data-name={@name}
    >
      <%= render_slot(@inner_block) %>
      <input type="hidden" name={@name} value="" data-split-output />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # split_input_field/1
  # ---------------------------------------------------------------------------

  attr(:placeholder, :string, default: nil, doc: "Placeholder character(s) for the slot.")
  attr(:maxlength, :integer, default: 1, doc: "Maximum number of characters in this slot.")
  attr(:width, :string, default: "w-10", doc: "Tailwind width class for this slot.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  A single slot within a `split_input/1`. The hook auto-advances on fill and
  backs up on backspace when empty.
  """
  def split_input_field(assigns) do
    ~H"""
    <input
      type="text"
      maxlength={@maxlength}
      placeholder={@placeholder}
      data-slot="true"
      class={cn([
        @width,
        "h-10 text-center border border-border rounded-md font-mono text-sm",
        "bg-background text-foreground",
        "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
        @class
      ])}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # credit_card_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root element ID — required for PhiaCreditCard hook.")

  attr(:card_number_name, :string,
    default: "card_number",
    doc: "Form field name for the card number."
  )

  attr(:expiry_name, :string, default: "expiry", doc: "Form field name for the expiry (MM/YY).")
  attr(:cvv_name, :string, default: "cvv", doc: "Form field name for the CVV.")
  attr(:cardholder_name, :string, default: "cardholder", doc: "Form field name for the cardholder.")
  attr(:show_cardholder, :boolean, default: true, doc: "Show the cardholder name field.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes on the root element.")

  @doc """
  A four-panel credit card entry form: number (4×4 formatted), expiry (MM/YY),
  CVV, and optional cardholder name. The `PhiaCreditCard` JS hook formats input
  and auto-advances between fields.
  """
  def credit_card_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["space-y-3", @class])}
      phx-hook="PhiaCreditCard"
    >
      <%# Card Number %>
      <div class="space-y-1">
        <label class="text-sm font-medium text-foreground" for={"#{@id}-number"}>
          Card Number
        </label>
        <input
          type="text"
          id={"#{@id}-number"}
          name={@card_number_name}
          maxlength="19"
          placeholder="0000 0000 0000 0000"
          inputmode="numeric"
          autocomplete="cc-number"
          data-cc-number
          class={cn([input_base_class(), "font-mono tracking-widest"])}
          aria-label="Card number"
        />
      </div>

      <%# Expiry + CVV side by side %>
      <div class="grid grid-cols-2 gap-3">
        <div class="space-y-1">
          <label class="text-sm font-medium text-foreground" for={"#{@id}-expiry"}>
            Expiry
          </label>
          <input
            type="text"
            id={"#{@id}-expiry"}
            name={@expiry_name}
            maxlength="5"
            placeholder="MM/YY"
            inputmode="numeric"
            autocomplete="cc-exp"
            data-cc-expiry
            class={cn([input_base_class(), "font-mono"])}
            aria-label="Expiry date"
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium text-foreground" for={"#{@id}-cvv"}>
            CVV
          </label>
          <input
            type="text"
            id={"#{@id}-cvv"}
            name={@cvv_name}
            maxlength="4"
            placeholder="•••"
            inputmode="numeric"
            autocomplete="cc-csc"
            data-cc-cvv
            class={cn([input_base_class(), "font-mono"])}
            aria-label="Security code"
          />
        </div>
      </div>

      <%# Cardholder name %>
      <div :if={@show_cardholder} class="space-y-1">
        <label class="text-sm font-medium text-foreground" for={"#{@id}-cardholder"}>
          Cardholder Name
        </label>
        <input
          type="text"
          id={"#{@id}-cardholder"}
          name={@cardholder_name}
          placeholder="Full name on card"
          autocomplete="cc-name"
          data-cc-cardholder
          class={input_base_class()}
          aria-label="Cardholder name"
        />
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_credit_card_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root element ID — required for PhiaCreditCard hook.")
  attr(:label, :string, default: nil, doc: "Section label shown above the card form.")
  attr(:description, :string, default: nil, doc: "Helper text.")
  attr(:card_number_name, :string, default: "card_number", doc: "Card number field name.")
  attr(:expiry_name, :string, default: "expiry", doc: "Expiry field name.")
  attr(:cvv_name, :string, default: "cvv", doc: "CVV field name.")
  attr(:cardholder_name, :string, default: "cardholder", doc: "Cardholder name field name.")
  attr(:show_cardholder, :boolean, default: true, doc: "Show the cardholder name field.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  A labeled wrapper for `credit_card_input/1` matching the form component style.
  """
  def form_credit_card_input(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <p :if={@label} class="text-sm font-medium leading-none">{@label}</p>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.credit_card_input
        id={@id}
        card_number_name={@card_number_name}
        expiry_name={@expiry_name}
        cvv_name={@cvv_name}
        cardholder_name={@cardholder_name}
        show_cardholder={@show_cardholder}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp input_base_class do
    "w-full px-3 py-2 text-sm border border-border rounded-md bg-background text-foreground " <>
      "placeholder:text-muted-foreground " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp input_size_class(:sm), do: "h-8 text-xs"
  defp input_size_class(:lg), do: "h-11 text-base"
  defp input_size_class(_), do: "h-10"

  # Parse duration value — accepts integer seconds or "HH:MM:SS" string
  defp parse_duration(seconds) when is_integer(seconds) and seconds >= 0 do
    h = div(seconds, 3600)
    rem = rem(seconds, 3600)
    m = div(rem, 60)
    s = rem(rem, 60)
    {h, m, s}
  end

  defp parse_duration(value) when is_binary(value) do
    case String.split(value, ":") do
      [h, m, s] ->
        {String.to_integer(h), String.to_integer(m), String.to_integer(s)}

      [m, s] ->
        {0, String.to_integer(m), String.to_integer(s)}

      _ ->
        case Integer.parse(value) do
          {n, _} -> parse_duration(n)
          :error -> {0, 0, 0}
        end
    end
  end

  defp parse_duration(_), do: {0, 0, 0}

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
