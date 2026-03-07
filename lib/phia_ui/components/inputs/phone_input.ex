defmodule PhiaUi.Components.PhoneInput do
  @moduledoc """
  Phone number input with a country dial-code prefix selector.

  Provides `phone_input/1` — a text input for phone numbers with a `<select>`
  prefix showing the country flag emoji and dial code (+1, +44, etc.). Also
  provides `form_phone_input/1` for changeset-integrated usage.

  The component ships with ~40 of the most common country codes. The selected
  dial code is stored in a separate named field so it is submitted alongside
  the phone number.

  ## When to use

  Use for any phone number field in a registration, checkout, profile, or
  notification settings form where international users are expected.

  ## Basic usage

      <.phone_input
        name="phone"
        value={@phone}
        selected_code="+1"
        phx-change="update_phone"
      />

  ## Form-integrated

      <.form_phone_input
        field={@form[:phone_number]}
        label="Phone number"
        selected_code={@dial_code}
      />

  ## Capturing both fields

  On submit, both the dial code (`:code_name` field) and the number (`:name`
  field) are included in the params:

      def handle_event("save", %{"phone_code" => code, "phone" => number}, socket) do
        full = code <> number   # e.g. "+15551234567"
        ...
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # phone_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the phone number `<input>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name for the phone number field."
  )

  attr(:code_name, :string,
    default: nil,
    doc: "HTML name for the dial-code `<select>`. Defaults to `name <> \"_code\"`."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current phone number value (without the dial code)."
  )

  attr(:selected_code, :string,
    default: "+1",
    doc: "Currently selected dial code, e.g. `\"+1\"`, `\"+44\"`."
  )

  attr(:placeholder, :string,
    default: "000 000 0000",
    doc: "Placeholder text for the number field."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables both the selector and the number input."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown required autocomplete),
    doc: "HTML attributes forwarded to the phone number `<input>`."
  )

  @doc """
  Renders a phone number input with a country dial-code prefix selector.

  ## Examples

      <.phone_input name="phone" value={@phone} />

      <.phone_input name="phone" value={@phone} selected_code="+44" placeholder="7700 900000" />
  """
  def phone_input(assigns) do
    id = assigns.id || "phone-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    assigns =
      if assigns.code_name do
        assigns
      else
        assign(assigns, :code_name, if(assigns.name, do: assigns.name <> "_code", else: nil))
      end

    ~H"""
    <div class={cn([
      "flex items-stretch h-10 w-full rounded-md border border-input bg-background overflow-hidden",
      "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
      @disabled && "cursor-not-allowed opacity-50",
      @class
    ])}>
      <%!-- Country dial-code selector --%>
      <select
        name={@code_name}
        disabled={@disabled}
        aria-label="Country code"
        class="flex items-center border-r border-input bg-muted pl-2 pr-1 text-sm focus:outline-none cursor-pointer"
      >
        <%= for {flag, label, code} <- country_codes() do %>
          <option value={code} selected={@selected_code == code}>
            {flag} {code}
          </option>
        <% end %>
      </select>

      <%!-- Phone number input --%>
      <input
        type="tel"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        inputmode="tel"
        autocomplete="tel-national"
        class="flex-1 min-w-0 bg-transparent px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none disabled:cursor-not-allowed"
        {@rest}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_phone_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:selected_code, :string,
    default: "+1",
    doc: "Currently selected dial code."
  )

  attr(:placeholder, :string,
    default: "000 000 0000",
    doc: "Placeholder for the number field."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce disabled required),
    doc: "HTML attributes forwarded to `phone_input/1`."
  )

  @doc """
  Renders a form-integrated phone input with label and error messages.

  ## Examples

      <.form_phone_input field={@form[:phone]} label="Phone number" />

      <.form_phone_input field={@form[:phone]} label="Phone" selected_code="+44" />
  """
  def form_phone_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)

    ~H"""
    <div class="space-y-2">
      <label
        :if={@label}
        for={@id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.phone_input
        id={@id}
        name={@name}
        value={@value}
        selected_code={@selected_code}
        placeholder={@placeholder}
        class={cn([error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Country codes — most common ~40 countries with flag emoji + dial code
  # ---------------------------------------------------------------------------

  # Returns [{flag_emoji, country_name, dial_code}]
  defp country_codes do
    [
      {"🇺🇸", "United States", "+1"},
      {"🇬🇧", "United Kingdom", "+44"},
      {"🇨🇦", "Canada", "+1"},
      {"🇦🇺", "Australia", "+61"},
      {"🇩🇪", "Germany", "+49"},
      {"🇫🇷", "France", "+33"},
      {"🇧🇷", "Brazil", "+55"},
      {"🇮🇳", "India", "+91"},
      {"🇨🇳", "China", "+86"},
      {"🇯🇵", "Japan", "+81"},
      {"🇰🇷", "South Korea", "+82"},
      {"🇲🇽", "Mexico", "+52"},
      {"🇮🇹", "Italy", "+39"},
      {"🇪🇸", "Spain", "+34"},
      {"🇳🇱", "Netherlands", "+31"},
      {"🇸🇪", "Sweden", "+46"},
      {"🇨🇭", "Switzerland", "+41"},
      {"🇳🇴", "Norway", "+47"},
      {"🇩🇰", "Denmark", "+45"},
      {"🇫🇮", "Finland", "+358"},
      {"🇵🇹", "Portugal", "+351"},
      {"🇵🇱", "Poland", "+48"},
      {"🇷🇺", "Russia", "+7"},
      {"🇺🇦", "Ukraine", "+380"},
      {"🇹🇷", "Turkey", "+90"},
      {"🇮🇱", "Israel", "+972"},
      {"🇸🇦", "Saudi Arabia", "+966"},
      {"🇦🇪", "UAE", "+971"},
      {"🇿🇦", "South Africa", "+27"},
      {"🇳🇬", "Nigeria", "+234"},
      {"🇸🇬", "Singapore", "+65"},
      {"🇭🇰", "Hong Kong", "+852"},
      {"🇹🇼", "Taiwan", "+886"},
      {"🇮🇩", "Indonesia", "+62"},
      {"🇲🇾", "Malaysia", "+60"},
      {"🇵🇭", "Philippines", "+63"},
      {"🇹🇭", "Thailand", "+66"},
      {"🇻🇳", "Vietnam", "+84"},
      {"🇦🇷", "Argentina", "+54"},
      {"🇨🇴", "Colombia", "+57"},
      {"🇵🇪", "Peru", "+51"},
      {"🇨🇱", "Chile", "+56"},
      {"🇳🇿", "New Zealand", "+64"},
      {"🇦🇹", "Austria", "+43"},
      {"🇧🇪", "Belgium", "+32"},
      {"🇨🇿", "Czech Republic", "+420"},
      {"🇷🇴", "Romania", "+40"},
      {"🇭🇺", "Hungary", "+36"},
      {"🇬🇷", "Greece", "+30"},
      {"🇵🇰", "Pakistan", "+92"}
    ]
  end

  defp error_class([]), do: nil
  defp error_class(_), do: "border-destructive"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
