defmodule PhiaUi.Components.SpecialInputs do
  @moduledoc """
  Specialized form input components: currency, masked input, two-thumb range slider,
  signature pad, floating labels, swatch picker, form stepper, and country selector.

  ## Components

  | Function | Purpose | JS Hook |
  |---|---|---|
  | `currency_input/1` | Number input with currency symbol | none |
  | `form_currency_input/1` | Ecto-integrated currency input | none |
  | `masked_input/1` | Pattern-masked text input | PhiaMaskedInput |
  | `form_masked_input/1` | Ecto-integrated masked input | PhiaMaskedInput |
  | `range_slider/1` | Two-thumb range slider | PhiaRangeSlider |
  | `form_range_slider/1` | Ecto-integrated two-thumb slider | PhiaRangeSlider |
  | `signature_pad/1` | Canvas freehand signature | PhiaSignaturePad |
  | `color_swatch_picker/1` | Preset color swatch grid | none |
  | `form_color_swatch_picker/1` | Ecto-integrated swatch picker | none |
  | `float_input/1` | Text input with floating label | none |
  | `form_float_input/1` | Ecto-integrated floating label input | none |
  | `float_textarea/1` | Textarea with floating label | none |
  | `form_float_textarea/1` | Ecto-integrated floating label textarea | none |
  | `form_feedback/1` | Form-level status alert | none |
  | `input_status/1` | Per-field validation status icon | none |
  | `form_stepper/1` | Multi-step form progress indicator | none |
  | `form_stepper_item/1` | Individual step item | none |
  | `country_select/1` | Country selector with ISO 3166-1 options | none |
  | `form_country_select/1` | Ecto-integrated country selector | none |
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ISO 3166-1 alpha-2 countries: {name, code, dial_code}
  @countries [
    {"Afghanistan", "AF", "+93"},
    {"Albania", "AL", "+355"},
    {"Algeria", "DZ", "+213"},
    {"Argentina", "AR", "+54"},
    {"Australia", "AU", "+61"},
    {"Austria", "AT", "+43"},
    {"Bangladesh", "BD", "+880"},
    {"Belgium", "BE", "+32"},
    {"Bolivia", "BO", "+591"},
    {"Brazil", "BR", "+55"},
    {"Canada", "CA", "+1"},
    {"Chile", "CL", "+56"},
    {"China", "CN", "+86"},
    {"Colombia", "CO", "+57"},
    {"Croatia", "HR", "+385"},
    {"Czech Republic", "CZ", "+420"},
    {"Denmark", "DK", "+45"},
    {"Ecuador", "EC", "+593"},
    {"Egypt", "EG", "+20"},
    {"Ethiopia", "ET", "+251"},
    {"Finland", "FI", "+358"},
    {"France", "FR", "+33"},
    {"Germany", "DE", "+49"},
    {"Ghana", "GH", "+233"},
    {"Greece", "GR", "+30"},
    {"Hungary", "HU", "+36"},
    {"India", "IN", "+91"},
    {"Indonesia", "ID", "+62"},
    {"Iran", "IR", "+98"},
    {"Iraq", "IQ", "+964"},
    {"Ireland", "IE", "+353"},
    {"Israel", "IL", "+972"},
    {"Italy", "IT", "+39"},
    {"Japan", "JP", "+81"},
    {"Jordan", "JO", "+962"},
    {"Kenya", "KE", "+254"},
    {"Malaysia", "MY", "+60"},
    {"Mexico", "MX", "+52"},
    {"Morocco", "MA", "+212"},
    {"Netherlands", "NL", "+31"},
    {"New Zealand", "NZ", "+64"},
    {"Nigeria", "NG", "+234"},
    {"Norway", "NO", "+47"},
    {"Pakistan", "PK", "+92"},
    {"Peru", "PE", "+51"},
    {"Philippines", "PH", "+63"},
    {"Poland", "PL", "+48"},
    {"Portugal", "PT", "+351"},
    {"Romania", "RO", "+40"},
    {"Russia", "RU", "+7"},
    {"Saudi Arabia", "SA", "+966"},
    {"Singapore", "SG", "+65"},
    {"South Africa", "ZA", "+27"},
    {"South Korea", "KR", "+82"},
    {"Spain", "ES", "+34"},
    {"Sri Lanka", "LK", "+94"},
    {"Sweden", "SE", "+46"},
    {"Switzerland", "CH", "+41"},
    {"Taiwan", "TW", "+886"},
    {"Tanzania", "TZ", "+255"},
    {"Thailand", "TH", "+66"},
    {"Tunisia", "TN", "+216"},
    {"Turkey", "TR", "+90"},
    {"Uganda", "UG", "+256"},
    {"Ukraine", "UA", "+380"},
    {"United Arab Emirates", "AE", "+971"},
    {"United Kingdom", "GB", "+44"},
    {"United States", "US", "+1"},
    {"Uruguay", "UY", "+598"},
    {"Venezuela", "VE", "+58"},
    {"Vietnam", "VN", "+84"},
    {"Yemen", "YE", "+967"},
    {"Zimbabwe", "ZW", "+263"}
  ]

  # ---------------------------------------------------------------------------
  # currency_input/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :symbol, :string, default: "$", doc: "Currency symbol to display"
  attr :symbol_position, :string, default: "left", doc: "left | right"
  attr :placeholder, :string, default: "0.00"
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-blur phx-debounce step min max)

  @doc """
  Renders a number input with a currency symbol prefix or suffix. No JavaScript required.

  ## Example

      <.currency_input name="price" value={@price} symbol="$" symbol_position="left" />
      <.currency_input name="amount" value={@amount} symbol="€" symbol_position="right" />
  """
  def currency_input(assigns) do
    ~H"""
    <div class={cn([
      "flex h-10 overflow-hidden rounded-md border border-input",
      @disabled && "opacity-50",
      @class
    ])}>
      <span
        :if={@symbol_position == "left"}
        class="flex select-none items-center border-r border-input bg-muted px-3 text-sm text-muted-foreground"
      >
        {@symbol}
      </span>
      <input
        type="number"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        class="min-w-0 flex-1 bg-background px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
        {@rest}
      />
      <span
        :if={@symbol_position == "right"}
        class="flex select-none items-center border-l border-input bg-muted px-3 text-sm text-muted-foreground"
      >
        {@symbol}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_currency_input/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :symbol, :string, default: "$"
  attr :symbol_position, :string, default: "left"
  attr :class, :string, default: nil

  @doc "Renders a currency input integrated with `Phoenix.HTML.FormField`."
  def form_currency_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@field.id} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      <.currency_input
        id={@field.id}
        name={@field.name}
        value={@field.value}
        symbol={@symbol}
        symbol_position={@symbol_position}
        class={cn([@errors != [] && "border-destructive", @class])}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # masked_input/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true, doc: "Required for phx-hook"
  attr :name, :string, default: nil
  attr :value, :string, default: ""
  attr :mask, :string, required: true, doc: "Mask pattern: # = digit, A = letter, * = any"
  attr :placeholder, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-blur phx-debounce)

  @doc """
  Renders a pattern-masked text input powered by the `PhiaMaskedInput` JS hook.

  The hook intercepts `input` events and enforces the mask by stripping invalid
  characters and inserting mask literals at the correct positions.

  Mask syntax: `#` = digit, `A` = letter, `*` = any character.

  ## Examples

      <%!-- US phone number --%>
      <.masked_input id="phone" name="phone" mask="(###) ###-####" />

      <%!-- Date --%>
      <.masked_input id="dob" name="dob" mask="##/##/####" />

      <%!-- Credit card --%>
      <.masked_input id="cc" name="cc" mask="#### #### #### ####" />
  """
  def masked_input(assigns) do
    ~H"""
    <input
      id={@id}
      name={@name}
      type="text"
      value={@value}
      placeholder={@placeholder || mask_to_placeholder(@mask)}
      disabled={@disabled}
      phx-hook="PhiaMaskedInput"
      data-mask={@mask}
      class={cn([
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono",
        "placeholder:text-muted-foreground placeholder:font-sans",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50",
        @class
      ])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # form_masked_input/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :mask, :string, required: true
  attr :class, :string, default: nil

  @doc "Renders a masked input integrated with `Phoenix.HTML.FormField`."
  def form_masked_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@field.id} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      <.masked_input
        id={@field.id}
        name={@field.name}
        value={@field.value || ""}
        mask={@mask}
        class={cn([@errors != [] && "border-destructive", @class])}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # range_slider/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true, doc: "Required for phx-hook"
  attr :name_from, :string, default: nil, doc: "Input name for the lower thumb value"
  attr :name_to, :string, default: nil, doc: "Input name for the upper thumb value"
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :value_from, :integer, default: 20, doc: "Initial lower thumb value"
  attr :value_to, :integer, default: 80, doc: "Initial upper thumb value"
  attr :show_values, :boolean, default: true, doc: "Show current from/to values below slider"
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Renders a two-thumb range slider powered by the `PhiaRangeSlider` JS hook.

  The hook keeps the `--from` and `--to` CSS custom properties on the container
  in sync with the thumb positions to drive the filled track segment. It also
  sends a `range-change` push event with `{from, to}` on every change.

  ## Example

      <.range_slider
        id="price-range"
        name_from="price_min"
        name_to="price_max"
        min={0}
        max={1000}
        step={10}
        value_from={@price_min}
        value_to={@price_max}
      />
  """
  def range_slider(assigns) do
    range = assigns.max - assigns.min
    from_pct = if range > 0, do: Float.round((assigns.value_from - assigns.min) / range * 100, 1), else: 0.0
    to_pct = if range > 0, do: Float.round((assigns.value_to - assigns.min) / range * 100, 1), else: 100.0

    assigns =
      assigns
      |> assign(:from_pct, from_pct)
      |> assign(:to_pct, to_pct)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaRangeSlider"
      data-min={@min}
      data-max={@max}
      data-step={@step}
      data-from={@value_from}
      data-to={@value_to}
      class={cn(["select-none space-y-3", @disabled && "pointer-events-none opacity-50", @class])}
    >
      <%!-- Slider track + thumbs --%>
      <div class="relative flex h-5 items-center">
        <%!-- Background track --%>
        <div class="absolute h-1.5 w-full overflow-hidden rounded-full bg-muted">
          <%!-- Filled segment between thumbs --%>
          <div
            data-range-track
            class="absolute h-full rounded-full bg-primary"
            style={"left: #{@from_pct}%; right: #{100 - @to_pct}%;"}
          />
        </div>
        <%!-- From input (transparent, sits over track for pointer events) --%>
        <input
          type="range"
          name={@name_from}
          min={@min}
          max={@max}
          step={@step}
          value={@value_from}
          disabled={@disabled}
          data-range-from
          class="absolute h-full w-full cursor-pointer opacity-0"
        />
        <%!-- To input --%>
        <input
          type="range"
          name={@name_to}
          min={@min}
          max={@max}
          step={@step}
          value={@value_to}
          disabled={@disabled}
          data-range-to
          class="absolute h-full w-full cursor-pointer opacity-0"
        />
        <%!-- Visual thumb: from --%>
        <div
          data-range-thumb-from
          class="pointer-events-none absolute h-5 w-5 -translate-x-1/2 rounded-full border-2 border-primary bg-background shadow-md"
          style={"left: #{@from_pct}%;"}
        />
        <%!-- Visual thumb: to --%>
        <div
          data-range-thumb-to
          class="pointer-events-none absolute h-5 w-5 -translate-x-1/2 rounded-full border-2 border-primary bg-background shadow-md"
          style={"left: #{@to_pct}%;"}
        />
      </div>
      <%!-- Value labels --%>
      <div :if={@show_values} class="flex justify-between text-xs text-muted-foreground">
        <span data-range-from-label>{@value_from}</span>
        <span data-range-to-label>{@value_to}</span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_range_slider/1
  # ---------------------------------------------------------------------------

  attr :field_from, Phoenix.HTML.FormField, required: true
  attr :field_to, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :class, :string, default: nil

  @doc "Renders a two-thumb range slider integrated with two `Phoenix.HTML.FormField` structs."
  def form_range_slider(assigns) do
    slider_id = "rs-#{assigns.field_from.id}"
    assigns = assign(assigns, :slider_id, slider_id)

    ~H"""
    <div class="space-y-2">
      <p :if={@label} class="text-sm font-medium leading-none">{@label}</p>
      <.range_slider
        id={@slider_id}
        name_from={@field_from.name}
        name_to={@field_to.name}
        min={@min}
        max={@max}
        step={@step}
        value_from={parse_integer(@field_from.value, @min)}
        value_to={parse_integer(@field_to.value, @max)}
        class={@class}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # signature_pad/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true, doc: "Required for phx-hook"
  attr :name, :string, default: nil, doc: "Hidden input name for data URL submission"
  attr :width, :integer, default: 400
  attr :height, :integer, default: 200
  attr :stroke_color, :string, default: "#000000"
  attr :clearable, :boolean, default: true, doc: "Show a Clear button below the canvas"
  attr :class, :string, default: nil

  @doc """
  Renders a canvas-based freehand signature pad powered by the `PhiaSignaturePad` hook.

  On every pointer-up, the hook serializes the canvas to a PNG data URL and sends
  a `signature-change` push event with `%{data: "data:image/png;base64,..."}`.
  The hidden input (`data-signature-value`) is also updated for native form submission.

  ## Example

      <.signature_pad id="sig" name="signature" width={500} height={200} />
  """
  def signature_pad(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSignaturePad"
      data-stroke-color={@stroke_color}
      class={cn(["inline-flex flex-col gap-2", @class])}
    >
      <canvas
        width={@width}
        height={@height}
        class="cursor-crosshair touch-none rounded-md border border-input bg-background"
        style={"width: #{@width}px; height: #{@height}px;"}
      />
      <input :if={@name} type="hidden" name={@name} data-signature-value />
      <div :if={@clearable} class="flex justify-end">
        <button
          type="button"
          data-clear
          class="text-xs text-muted-foreground underline hover:text-foreground"
        >
          Clear signature
        </button>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # color_swatch_picker/1
  # ---------------------------------------------------------------------------

  attr :name, :string, default: nil
  attr :swatches, :list, required: true, doc: "List of hex color strings, e.g. [\"#ff0000\", ...]"
  attr :value, :string, default: nil, doc: "Currently selected hex color"
  attr :size, :string, default: "md", doc: "Swatch button size: sm | md | lg"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change)

  @doc """
  Renders a grid of preset color swatch buttons. No JavaScript required.

  The selected swatch gets a visible border ring. Clicking sends a `phx-click` or
  `phx-change` event depending on how you wire it.

  ## Example

      <.color_swatch_picker
        name="brand_color"
        value={@brand_color}
        swatches={["#ef4444", "#f97316", "#eab308", "#22c55e", "#3b82f6", "#8b5cf6"]}
      />
  """
  def color_swatch_picker(assigns) do
    ~H"""
    <div role="group" aria-label="Color swatches" class={cn(["flex flex-wrap gap-2", @class])}>
      <button
        :for={color <- @swatches}
        type="button"
        name={@name}
        value={color}
        title={color}
        phx-click="swatch_pick"
        phx-value-color={color}
        class={cn([
          "rounded-full border-2 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          swatch_size_class(@size),
          if(@value == color,
            do: "border-foreground ring-2 ring-ring ring-offset-1",
            else: "border-transparent hover:border-foreground/30"
          )
        ])}
        style={"background-color: #{color};"}
        {@rest}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_color_swatch_picker/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :swatches, :list, required: true
  attr :size, :string, default: "md"
  attr :class, :string, default: nil

  @doc "Renders a color swatch picker integrated with `Phoenix.HTML.FormField`."
  def form_color_swatch_picker(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <label :if={@label} class="text-sm font-medium leading-none">{@label}</label>
      <.color_swatch_picker
        name={@field.name}
        value={@field.value}
        swatches={@swatches}
        size={@size}
        class={@class}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # float_input/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :label, :string, required: true, doc: "Floating label text"
  attr :type, :string, default: "text"
  attr :value, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :error, :boolean, default: false, doc: "Apply destructive styling"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-blur phx-debounce autocomplete readonly required)

  @doc """
  Renders a text input with a CSS-only floating label (MUI / Mantine style).

  The label starts positioned over the input (placeholder position). It floats up
  when the input gains focus or has a value, via Tailwind `peer` classes.

  Requires `placeholder=" "` (single space) on the input — this is how the
  `peer-placeholder-shown:*` CSS trick detects whether the input is empty.

  ## Example

      <.float_input id="email" name="email" label="Email address" type="email" />
  """
  def float_input(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <input
        id={@id}
        name={@name}
        type={@type}
        value={@value}
        disabled={@disabled}
        placeholder=" "
        class={cn([
          "peer block h-14 w-full rounded-md border bg-background px-3 pb-2 pt-6 text-sm",
          "placeholder:text-transparent",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:cursor-not-allowed disabled:opacity-50",
          if(@error, do: "border-destructive", else: "border-input")
        ])}
        {@rest}
      />
      <label
        for={@id}
        class={cn([
          "pointer-events-none absolute left-3 select-none text-sm transition-all duration-150",
          "top-1 text-xs",
          "peer-placeholder-shown:top-4 peer-placeholder-shown:text-sm peer-placeholder-shown:text-muted-foreground",
          if(@error,
            do: "text-destructive peer-focus:top-1 peer-focus:text-xs peer-focus:text-destructive",
            else:
              "text-muted-foreground peer-focus:top-1 peer-focus:text-xs peer-focus:text-primary"
          )
        ])}
      >
        {@label}
      </label>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_float_input/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true
  attr :type, :string, default: "text"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-debounce autocomplete readonly disabled)

  @doc "Renders a floating-label input integrated with `Phoenix.HTML.FormField`."
  def form_float_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-1">
      <.float_input
        id={@field.id}
        name={@field.name}
        label={@label}
        type={@type}
        value={@field.value || ""}
        error={@errors != []}
        class={@class}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # float_textarea/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :label, :string, required: true, doc: "Floating label text"
  attr :rows, :integer, default: 4
  attr :value, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :error, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change phx-blur phx-debounce readonly required)

  @doc """
  Renders a textarea with a CSS-only floating label. Same pattern as `float_input/1`.
  """
  def float_textarea(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <textarea
        id={@id}
        name={@name}
        rows={@rows}
        disabled={@disabled}
        placeholder=" "
        class={cn([
          "peer block w-full resize-none rounded-md border bg-background px-3 pb-2 pt-6 text-sm",
          "placeholder:text-transparent",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:cursor-not-allowed disabled:opacity-50",
          if(@error, do: "border-destructive", else: "border-input")
        ])}
        {@rest}
      >{@value}</textarea>
      <label
        for={@id}
        class={cn([
          "pointer-events-none absolute left-3 select-none text-sm transition-all duration-150",
          "top-1 text-xs",
          "peer-placeholder-shown:top-4 peer-placeholder-shown:text-sm peer-placeholder-shown:text-muted-foreground",
          if(@error,
            do: "text-destructive peer-focus:top-1 peer-focus:text-xs peer-focus:text-destructive",
            else:
              "text-muted-foreground peer-focus:top-1 peer-focus:text-xs peer-focus:text-primary"
          )
        ])}
      >
        {@label}
      </label>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_float_textarea/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true
  attr :rows, :integer, default: 4
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-debounce readonly disabled)

  @doc "Renders a floating-label textarea integrated with `Phoenix.HTML.FormField`."
  def form_float_textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-1">
      <.float_textarea
        id={@field.id}
        name={@field.name}
        label={@label}
        rows={@rows}
        value={@field.value || ""}
        error={@errors != []}
        class={@class}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_feedback/1
  # ---------------------------------------------------------------------------

  attr :status, :string, required: true, doc: "success | error | warning | info"
  attr :title, :string, default: nil
  attr :message, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block

  @doc """
  Renders a form-level status alert for submission outcomes or validation summaries.

  ## Example

      <.form_feedback status="success" title="Saved!" message="Your changes have been saved." />
      <.form_feedback status="error" title="Failed" message="Unable to save. Please try again." />
  """
  def form_feedback(assigns) do
    ~H"""
    <div
      role="alert"
      class={cn(["flex gap-3 rounded-md border px-4 py-3", feedback_color(@status), @class])}
    >
      <span class="mt-0.5 shrink-0 text-base leading-none" aria-hidden="true">
        {feedback_icon(@status)}
      </span>
      <div class="flex-1 min-w-0">
        <p :if={@title} class="text-sm font-semibold">{@title}</p>
        <p :if={@message} class="text-sm">{@message}</p>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # input_status/1
  # ---------------------------------------------------------------------------

  attr :status, :string, required: true, doc: "valid | invalid | pending | none"
  attr :class, :string, default: nil

  @doc """
  Renders a per-field validation status icon.

  - `valid` → green checkmark
  - `invalid` → red X
  - `pending` → spinning loader
  - `none` → renders nothing
  """
  def input_status(%{status: "none"} = assigns) do
    ~H"""
    """
  end

  def input_status(assigns) do
    ~H"""
    <span
      class={cn(["inline-flex shrink-0 items-center justify-center", status_class(@status), @class])}
      aria-label={@status}
    >
      {status_icon(@status)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # form_stepper/1
  # ---------------------------------------------------------------------------

  attr :steps, :list, required: true,
    doc: "List of step maps with :label, optional :description, optional :status"

  attr :current_step, :integer, default: 1, doc: "1-based active step index"
  attr :orientation, :string, default: "horizontal", doc: "horizontal | vertical"
  attr :class, :string, default: nil

  @doc """
  Renders a multi-step form progress indicator.

  Steps are auto-classified as `"complete"`, `"active"`, or `"pending"` based on
  `:current_step`, unless an explicit `:status` key is provided in the step map.

  ## Example

      <.form_stepper
        current_step={2}
        steps={[
          %{label: "Account"},
          %{label: "Profile"},
          %{label: "Billing"},
          %{label: "Confirm"}
        ]}
      />
  """
  def form_stepper(assigns) do
    total = length(assigns.steps)
    steps_indexed = Enum.with_index(assigns.steps, 1)

    assigns =
      assigns
      |> assign(:steps_indexed, steps_indexed)
      |> assign(:total_steps, total)

    ~H"""
    <ol class={cn([stepper_container(@orientation), @class])}>
      <li
        :for={{step, idx} <- @steps_indexed}
        class={cn([stepper_item(@orientation)])}
      >
        <%!-- Indicator circle --%>
        <div class={cn([
          "flex shrink-0 items-center justify-center rounded-full border-2 text-xs font-bold",
          stepper_indicator(@orientation),
          step_indicator_class(resolve_step_status(step, idx, @current_step))
        ])}>
          {step_indicator_content(step, idx, @current_step)}
        </div>
        <%!-- Connector line (not on last step) --%>
        <div
          :if={idx < @total_steps}
          class={cn([stepper_connector(@orientation, resolve_step_status(step, idx, @current_step))])}
        />
        <%!-- Label --%>
        <div class={cn([stepper_label_wrapper(@orientation)])}>
          <p class={cn(["text-sm font-medium", step_label_class(resolve_step_status(step, idx, @current_step))])}>
            {step.label}
          </p>
          <p
            :if={Map.get(step, :description)}
            class="mt-0.5 text-xs text-muted-foreground"
          >
            {step.description}
          </p>
        </div>
      </li>
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # form_stepper_item/1
  # ---------------------------------------------------------------------------

  attr :step, :integer, required: true, doc: "1-based step number shown inside the indicator"
  attr :label, :string, required: true
  attr :description, :string, default: nil
  attr :status, :string, default: "pending", doc: "pending | active | complete | error"
  attr :class, :string, default: nil

  @doc "Renders a single standalone step item for manual stepper layouts."
  def form_stepper_item(assigns) do
    ~H"""
    <div class={cn(["flex items-start gap-3", @class])}>
      <div class={cn([
        "flex h-8 w-8 shrink-0 items-center justify-center rounded-full border-2 text-xs font-bold",
        step_indicator_class(@status)
      ])}>
        {step_icon_for_status(@status, @step)}
      </div>
      <div class="min-w-0">
        <p class={cn(["text-sm font-medium", step_label_class(@status)])}>{@label}</p>
        <p :if={@description} class="mt-0.5 text-xs text-muted-foreground">{@description}</p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # country_select/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil, doc: "ISO 3166-1 alpha-2 country code, e.g. \"US\""
  attr :include_dial_code, :boolean, default: false, doc: "Append dial code to option labels"
  attr :prompt, :string, default: "Select a country..."
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(phx-change disabled required)

  @doc """
  Renders a styled `<select>` populated with ISO 3166-1 alpha-2 countries.

  ## Example

      <.country_select name="country" value={@country} />
      <.country_select name="phone_country" value="US" include_dial_code={true} />
  """
  def country_select(assigns) do
    assigns = assign(assigns, :countries, all_countries())

    ~H"""
    <div class="relative">
      <select
        id={@id}
        name={@name}
        class={cn([
          "h-10 w-full appearance-none rounded-md border border-input bg-background px-3 py-2 pr-8 text-sm",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])}
        {@rest}
      >
        <option value="">{@prompt}</option>
        <option
          :for={{name, code, dial} <- @countries}
          value={code}
          selected={@value == code}
        >
          {if @include_dial_code, do: "#{name} (#{dial})", else: name}
        </option>
      </select>
      <div class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2">
        <svg
          class="h-4 w-4 text-muted-foreground"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_country_select/1
  # ---------------------------------------------------------------------------

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :include_dial_code, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Renders a country select integrated with `Phoenix.HTML.FormField`."
  def form_country_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :errors, Enum.map(field.errors, &translate_error/1))

    ~H"""
    <div class="space-y-2">
      <label :if={@label} for={@field.id} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      <.country_select
        id={@field.id}
        name={@field.name}
        value={@field.value}
        include_dial_code={@include_dial_code}
        class={cn([@errors != [] && "border-destructive", @class])}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp all_countries, do: @countries

  defp mask_to_placeholder(mask) do
    mask
    |> String.replace("#", "_")
    |> String.replace("A", "_")
    |> String.replace("*", "_")
  end

  defp swatch_size_class("sm"), do: "h-6 w-6"
  defp swatch_size_class("md"), do: "h-8 w-8"
  defp swatch_size_class("lg"), do: "h-10 w-10"
  defp swatch_size_class(_), do: "h-8 w-8"

  defp feedback_color("success"),
    do:
      "border-green-500/40 bg-green-50 text-green-800 dark:bg-green-950/40 dark:text-green-300"

  defp feedback_color("error"),
    do: "border-destructive/40 bg-destructive/10 text-destructive"

  defp feedback_color("warning"),
    do:
      "border-yellow-500/40 bg-yellow-50 text-yellow-800 dark:bg-yellow-950/40 dark:text-yellow-300"

  defp feedback_color("info"),
    do: "border-blue-500/40 bg-blue-50 text-blue-800 dark:bg-blue-950/40 dark:text-blue-300"

  defp feedback_color(_), do: "border-border bg-muted text-foreground"

  defp feedback_icon("success"), do: "✓"
  defp feedback_icon("error"), do: "✕"
  defp feedback_icon("warning"), do: "⚠"
  defp feedback_icon("info"), do: "ℹ"
  defp feedback_icon(_), do: "•"

  defp status_class("valid"), do: "h-5 w-5 text-green-600"
  defp status_class("invalid"), do: "h-5 w-5 text-destructive"
  defp status_class("pending"), do: "h-5 w-5 animate-spin text-muted-foreground"
  defp status_class(_), do: "h-5 w-5"

  defp status_icon("valid"), do: "✓"
  defp status_icon("invalid"), do: "✕"
  defp status_icon("pending"), do: "⟳"
  defp status_icon(_), do: ""

  # Stepper helpers

  defp stepper_container("vertical"), do: "flex flex-col"
  defp stepper_container(_), do: "flex items-start"

  defp stepper_item("vertical"), do: "relative flex items-start gap-3 pb-8 last:pb-0"
  defp stepper_item(_), do: "relative flex flex-1 flex-col items-center"

  defp stepper_indicator("vertical"), do: "h-8 w-8"
  defp stepper_indicator(_), do: "h-8 w-8"

  defp stepper_connector("vertical", "complete"),
    do: "absolute left-4 top-8 h-full w-0.5 -translate-x-1/2 bg-green-600"

  defp stepper_connector("vertical", _),
    do: "absolute left-4 top-8 h-full w-0.5 -translate-x-1/2 bg-muted-foreground/30"

  defp stepper_connector(_, "complete"),
    do: "absolute left-1/2 top-4 h-0.5 w-full bg-green-600"

  defp stepper_connector(_, _),
    do: "absolute left-1/2 top-4 h-0.5 w-full bg-muted-foreground/30"

  defp stepper_label_wrapper("vertical"), do: "min-w-0 pb-1"
  defp stepper_label_wrapper(_), do: "mt-2 text-center"

  defp step_indicator_class("complete"),
    do: "border-green-600 bg-green-600 text-white"

  defp step_indicator_class("active"),
    do: "border-primary bg-primary text-primary-foreground"

  defp step_indicator_class("error"),
    do: "border-destructive bg-destructive text-destructive-foreground"

  defp step_indicator_class(_),
    do: "border-muted-foreground/40 bg-background text-muted-foreground"

  defp step_label_class("complete"), do: "text-green-700 dark:text-green-400"
  defp step_label_class("active"), do: "text-foreground"
  defp step_label_class("error"), do: "text-destructive"
  defp step_label_class(_), do: "text-muted-foreground"

  defp resolve_step_status(%{status: status}, _idx, _current) when is_binary(status), do: status
  defp resolve_step_status(_, idx, current) when idx < current, do: "complete"
  defp resolve_step_status(_, idx, current) when idx == current, do: "active"
  defp resolve_step_status(_, _, _), do: "pending"

  defp step_indicator_content(step, idx, current) do
    step_icon_for_status(resolve_step_status(step, idx, current), idx)
  end

  defp step_icon_for_status("complete", _), do: "✓"
  defp step_icon_for_status("error", _), do: "✕"
  defp step_icon_for_status(_, idx), do: to_string(idx)

  defp parse_integer(nil, default), do: default
  defp parse_integer("", default), do: default
  defp parse_integer(v, _) when is_integer(v), do: v

  defp parse_integer(v, default) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> default
    end
  end

  defp parse_integer(_, default), do: default

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
