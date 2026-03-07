defmodule PhiaUi.Components.UnitInput do
  @moduledoc """
  Number input with a semantic unit prefix or suffix.

  Provides `unit_input/1` — a number input that displays a unit symbol
  (currency, percentage, weight, volume, time, or any custom string) as a
  visual decoration inside the field. Also provides `form_unit_input/1` for
  changeset-integrated forms.

  ## When to use

  Use `unit_input/1` instead of a bare `<input type="number">` whenever the
  unit context is important — prices, percentages, distances, weights, speeds,
  durations, ratings, or any dimensioned quantity.

  ## Presets

  The `:unit` attribute accepts shorthand presets:

  | Preset | Symbol | Position |
  |--------|--------|----------|
  | `:currency_usd` | `$` | left |
  | `:currency_eur` | `€` | left |
  | `:currency_gbp` | `£` | left |
  | `:percent` | `%` | right |
  | `:kg` | `kg` | right |
  | `:lbs` | `lbs` | right |
  | `:km` | `km` | right |
  | `:mi` | `mi` | right |
  | `:m` | `m` | right |
  | `:cm` | `cm` | right |
  | `:custom` | uses `:symbol` | uses `:symbol_position` |

  ## Basic usage

      <%!-- Price field --%>
      <.unit_input name="price" value={@price} unit="currency_usd" min="0" step="0.01" />

      <%!-- Percentage --%>
      <.unit_input name="discount" value={@discount} unit="percent" min="0" max="100" />

      <%!-- Custom unit --%>
      <.unit_input name="speed" value={@speed} unit="custom" symbol="km/h" symbol_position="right" />

  ## Form-integrated

      <.form_unit_input field={@form[:price]} label="Price" unit="currency_usd" step="0.01" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # unit_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute."
  )

  attr(:value, :any,
    default: nil,
    doc: "Current numeric value."
  )

  attr(:unit, :string,
    default: "custom",
    doc: "Unit preset or `\"custom\"`. See module docs for available presets."
  )

  attr(:symbol, :string,
    default: nil,
    doc: "Symbol string used when `:unit` is `\"custom\"`."
  )

  attr(:symbol_position, :string,
    default: "left",
    values: ~w(left right),
    doc: "Where to place the symbol when `:unit` is `\"custom\"`."
  )

  attr(:min, :any, default: nil, doc: "Minimum value (`min` HTML attribute).")
  attr(:max, :any, default: nil, doc: "Maximum value (`max` HTML attribute).")
  attr(:step, :any, default: nil, doc: "Step increment (`step` HTML attribute).")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text.")

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the input."
  )

  attr(:readonly, :boolean,
    default: false,
    doc: "Makes the input read-only."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the outer wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce required autocomplete phx-keydown),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a number input with a unit symbol prefix or suffix.

  ## Examples

      <.unit_input name="price" value={@price} unit="currency_usd" step="0.01" />

      <.unit_input name="weight" value={@weight} unit="kg" min="0" max="500" />

      <.unit_input name="rate" value={@rate} unit="percent" min="0" max="100" />

      <.unit_input name="temp" value={@temp} unit="custom" symbol="°C" symbol_position="right" />
  """
  def unit_input(assigns) do
    id = assigns.id || "unit-input-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    {sym, pos} = resolve_unit(assigns.unit, assigns.symbol, assigns.symbol_position)
    assigns = assign(assigns, sym: sym, pos: pos)

    ~H"""
    <div class={cn([
      "relative flex items-center h-10 w-full rounded-md border border-input bg-background overflow-hidden",
      "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
      @disabled && "cursor-not-allowed opacity-50",
      @class
    ])}>
      <%!-- Left symbol --%>
      <span
        :if={@sym && @pos == "left"}
        class="flex items-center border-r border-input bg-muted px-3 h-full text-sm text-muted-foreground select-none shrink-0"
      >
        {@sym}
      </span>

      <input
        type="number"
        id={@id}
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        placeholder={@placeholder}
        disabled={@disabled}
        readonly={@readonly}
        class="flex-1 min-w-0 bg-transparent px-3 py-2 text-sm focus:outline-none disabled:cursor-not-allowed [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
        {@rest}
      />

      <%!-- Right symbol --%>
      <span
        :if={@sym && @pos == "right"}
        class="flex items-center border-l border-input bg-muted px-3 h-full text-sm text-muted-foreground select-none shrink-0"
      >
        {@sym}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_unit_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`."
  )

  attr(:label, :string, default: nil, doc: "Label text rendered above the input.")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the label.")
  attr(:unit, :string, default: "custom", doc: "Unit preset.")
  attr(:symbol, :string, default: nil, doc: "Custom symbol string.")
  attr(:symbol_position, :string, default: "left", values: ~w(left right), doc: "Symbol position.")
  attr(:min, :any, default: nil, doc: "Minimum value.")
  attr(:max, :any, default: nil, doc: "Maximum value.")
  attr(:step, :any, default: nil, doc: "Step increment.")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper.")

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce disabled required readonly),
    doc: "HTML attributes forwarded to `unit_input/1`."
  )

  @doc """
  Renders a form-integrated unit input with label and error messages.

  ## Examples

      <.form_unit_input field={@form[:price]} label="Price" unit="currency_usd" step="0.01" />

      <.form_unit_input field={@form[:commission]} label="Commission" unit="percent" max="100" />
  """
  def form_unit_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
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
      <.unit_input
        id={@id}
        name={@name}
        value={@value}
        unit={@unit}
        symbol={@symbol}
        symbol_position={@symbol_position}
        min={@min}
        max={@max}
        step={@step}
        placeholder={@placeholder}
        class={cn([error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns {symbol_string, position} based on preset name.
  defp resolve_unit("currency_usd", _sym, _pos), do: {"$", "left"}
  defp resolve_unit("currency_eur", _sym, _pos), do: {"€", "left"}
  defp resolve_unit("currency_gbp", _sym, _pos), do: {"£", "left"}
  defp resolve_unit("currency_brl", _sym, _pos), do: {"R$", "left"}
  defp resolve_unit("currency_jpy", _sym, _pos), do: {"¥", "left"}
  defp resolve_unit("percent", _sym, _pos), do: {"%", "right"}
  defp resolve_unit("kg", _sym, _pos), do: {"kg", "right"}
  defp resolve_unit("lbs", _sym, _pos), do: {"lbs", "right"}
  defp resolve_unit("km", _sym, _pos), do: {"km", "right"}
  defp resolve_unit("mi", _sym, _pos), do: {"mi", "right"}
  defp resolve_unit("m", _sym, _pos), do: {"m", "right"}
  defp resolve_unit("cm", _sym, _pos), do: {"cm", "right"}
  defp resolve_unit("mm", _sym, _pos), do: {"mm", "right"}
  defp resolve_unit("l", _sym, _pos), do: {"L", "right"}
  defp resolve_unit("ml", _sym, _pos), do: {"mL", "right"}
  defp resolve_unit("px", _sym, _pos), do: {"px", "right"}
  defp resolve_unit("rem", _sym, _pos), do: {"rem", "right"}
  defp resolve_unit("custom", sym, pos), do: {sym, pos}
  defp resolve_unit(_, sym, pos), do: {sym, pos}

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
