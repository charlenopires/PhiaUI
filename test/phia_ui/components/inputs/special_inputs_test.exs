defmodule PhiaUi.Components.SpecialInputsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SpecialInputs

    attr :symbol, :string, default: "$"
    attr :symbol_position, :string, default: "left"
    attr :value, :any, default: nil
    attr :disabled, :boolean, default: false

    def render_currency_input(assigns) do
      ~H"""
      <.currency_input
        id="price"
        name="price"
        value={@value}
        symbol={@symbol}
        symbol_position={@symbol_position}
        disabled={@disabled}
      />
      """
    end

    attr :field, :any

    def render_form_currency_input(assigns) do
      ~H"""
      <.form_currency_input field={@field} label="Price" symbol="$" />
      """
    end

    attr :value, :string, default: ""
    attr :disabled, :boolean, default: false

    def render_masked_input(assigns) do
      ~H"""
      <.masked_input
        id="phone-input"
        name="phone"
        value={@value}
        mask="(###) ###-####"
        disabled={@disabled}
      />
      """
    end

    attr :field, :any

    def render_form_masked_input(assigns) do
      ~H"""
      <.form_masked_input field={@field} label="Phone" mask="(###) ###-####" />
      """
    end

    attr :value_from, :integer, default: 20
    attr :value_to, :integer, default: 80
    attr :disabled, :boolean, default: false
    attr :show_values, :boolean, default: true

    def render_range_slider(assigns) do
      ~H"""
      <.range_slider
        id="slider-1"
        name_from="price_min"
        name_to="price_max"
        min={0}
        max={100}
        step={1}
        value_from={@value_from}
        value_to={@value_to}
        show_values={@show_values}
        disabled={@disabled}
      />
      """
    end

    attr :field_from, :any
    attr :field_to, :any

    def render_form_range_slider(assigns) do
      ~H"""
      <.form_range_slider
        field_from={@field_from}
        field_to={@field_to}
        label="Price range"
        min={0}
        max={1000}
      />
      """
    end

    attr :clearable, :boolean, default: true

    def render_signature_pad(assigns) do
      ~H"""
      <.signature_pad id="sig-1" name="signature" width={300} height={150} clearable={@clearable} />
      """
    end

    attr :value, :string, default: nil
    attr :swatches, :list, default: ["#ff0000", "#00ff00", "#0000ff"]
    attr :size, :string, default: "md"

    def render_color_swatch_picker(assigns) do
      ~H"""
      <.color_swatch_picker swatches={@swatches} value={@value} size={@size} />
      """
    end

    attr :field, :any
    attr :swatches, :list, default: ["#ff0000", "#00ff00"]

    def render_form_color_swatch_picker(assigns) do
      ~H"""
      <.form_color_swatch_picker field={@field} label="Brand color" swatches={@swatches} />
      """
    end

    attr :label, :string, default: "Email address"
    attr :value, :string, default: ""
    attr :error, :boolean, default: false
    attr :disabled, :boolean, default: false

    def render_float_input(assigns) do
      ~H"""
      <.float_input
        id="float-email"
        name="email"
        label={@label}
        value={@value}
        error={@error}
        disabled={@disabled}
      />
      """
    end

    attr :field, :any

    def render_form_float_input(assigns) do
      ~H"""
      <.form_float_input field={@field} label="Email address" />
      """
    end

    attr :label, :string, default: "Message"
    attr :value, :string, default: ""
    attr :rows, :integer, default: 4
    attr :error, :boolean, default: false

    def render_float_textarea(assigns) do
      ~H"""
      <.float_textarea
        id="float-msg"
        name="message"
        label={@label}
        value={@value}
        rows={@rows}
        error={@error}
      />
      """
    end

    attr :field, :any

    def render_form_float_textarea(assigns) do
      ~H"""
      <.form_float_textarea field={@field} label="Message" rows={4} />
      """
    end

    attr :status, :string, default: "success"
    attr :title, :string, default: nil
    attr :message, :string, default: nil

    def render_form_feedback(assigns) do
      ~H"""
      <.form_feedback status={@status} title={@title} message={@message} />
      """
    end

    attr :status, :string, default: "valid"

    def render_input_status(assigns) do
      ~H"""
      <.input_status status={@status} />
      """
    end

    attr :steps, :list,
      default: [%{label: "Account"}, %{label: "Profile"}, %{label: "Billing"}]

    attr :current_step, :integer, default: 1
    attr :orientation, :string, default: "horizontal"

    def render_form_stepper(assigns) do
      ~H"""
      <.form_stepper steps={@steps} current_step={@current_step} orientation={@orientation} />
      """
    end

    attr :step, :integer, default: 1
    attr :label, :string, default: "Account"
    attr :status, :string, default: "active"
    attr :description, :string, default: nil

    def render_form_stepper_item(assigns) do
      ~H"""
      <.form_stepper_item step={@step} label={@label} status={@status} description={@description} />
      """
    end

    attr :value, :string, default: nil
    attr :include_dial_code, :boolean, default: false

    def render_country_select(assigns) do
      ~H"""
      <.country_select id="country" name="country" value={@value} include_dial_code={@include_dial_code} />
      """
    end

    attr :field, :any

    def render_form_country_select(assigns) do
      ~H"""
      <.form_country_select field={@field} label="Country" />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "user_field"),
      name: Keyword.get(attrs, :name, "user[field]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :field),
      value: Keyword.get(attrs, :value, ""),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # currency_input/1
  # ---------------------------------------------------------------------------

  describe "currency_input/1" do
    test "renders a number input" do
      html = render_component(&H.render_currency_input/1, %{})
      assert html =~ ~s(type="number")
    end

    test "renders currency symbol on the left by default" do
      html = render_component(&H.render_currency_input/1, %{symbol: "$"})
      assert html =~ "$"
      # symbol div appears before input in left position
      assert String.contains?(html, "$")
    end

    test "renders symbol on the right when symbol_position is right" do
      html = render_component(&H.render_currency_input/1, %{symbol: "€", symbol_position: "right"})
      assert html =~ "€"
      assert html =~ "border-l"
    end

    test "renders symbol on the left when symbol_position is left" do
      html = render_component(&H.render_currency_input/1, %{symbol_position: "left"})
      assert html =~ "border-r"
    end

    test "passes value to input" do
      html = render_component(&H.render_currency_input/1, %{value: "42.50"})
      assert html =~ ~s(value="42.50")
    end

    test "applies opacity when disabled" do
      html = render_component(&H.render_currency_input/1, %{disabled: true})
      assert html =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # form_currency_input/1
  # ---------------------------------------------------------------------------

  describe "form_currency_input/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_currency_input/1, %{field: field})
      assert html =~ "Price"
    end

    test "uses field.id for label for" do
      field = build_field(id: "product_price")
      html = render_component(&H.render_form_currency_input/1, %{field: field})
      assert html =~ ~s(for="product_price")
    end

    test "renders errors from field" do
      field = build_field(errors: [{"must be greater than 0", []}])
      html = render_component(&H.render_form_currency_input/1, %{field: field})
      assert html =~ "must be greater than 0"
    end

    test "applies error border when field has errors" do
      field = build_field(errors: [{"invalid", []}])
      html = render_component(&H.render_form_currency_input/1, %{field: field})
      assert html =~ "border-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # masked_input/1
  # ---------------------------------------------------------------------------

  describe "masked_input/1" do
    test "renders phx-hook attribute" do
      html = render_component(&H.render_masked_input/1, %{})
      assert html =~ ~s(phx-hook="PhiaMaskedInput")
    end

    test "requires id for hook" do
      html = render_component(&H.render_masked_input/1, %{})
      assert html =~ ~s(id="phone-input")
    end

    test "sets data-mask attribute" do
      html = render_component(&H.render_masked_input/1, %{})
      assert html =~ ~s(data-mask="(###) ###-####")
    end

    test "renders placeholder derived from mask" do
      html = render_component(&H.render_masked_input/1, %{})
      assert html =~ "placeholder"
      assert html =~ "___"
    end

    test "sets value attribute" do
      html = render_component(&H.render_masked_input/1, %{value: "(555) 123-4567"})
      assert html =~ "(555) 123-4567"
    end

    test "applies disabled attribute and styling" do
      html = render_component(&H.render_masked_input/1, %{disabled: true})
      assert html =~ "disabled"
      assert html =~ "disabled:opacity-50"
    end

    test "uses text input type" do
      html = render_component(&H.render_masked_input/1, %{})
      assert html =~ ~s(type="text")
    end
  end

  # ---------------------------------------------------------------------------
  # form_masked_input/1
  # ---------------------------------------------------------------------------

  describe "form_masked_input/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_masked_input/1, %{field: field})
      assert html =~ "Phone"
    end

    test "uses field.id as hook id" do
      field = build_field(id: "user_phone")
      html = render_component(&H.render_form_masked_input/1, %{field: field})
      assert html =~ ~s(id="user_phone")
    end

    test "passes mask data attribute" do
      field = build_field()
      html = render_component(&H.render_form_masked_input/1, %{field: field})
      assert html =~ "data-mask"
    end

    test "renders errors" do
      field = build_field(errors: [{"invalid format", []}])
      html = render_component(&H.render_form_masked_input/1, %{field: field})
      assert html =~ "invalid format"
    end
  end

  # ---------------------------------------------------------------------------
  # range_slider/1
  # ---------------------------------------------------------------------------

  describe "range_slider/1" do
    test "renders phx-hook attribute" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ ~s(phx-hook="PhiaRangeSlider")
    end

    test "requires id for hook" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ ~s(id="slider-1")
    end

    test "renders data-min, data-max, data-step attributes" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ ~s(data-min="0")
      assert html =~ ~s(data-max="100")
      assert html =~ ~s(data-step="1")
    end

    test "renders data-from and data-to attributes" do
      html = render_component(&H.render_range_slider/1, %{value_from: 25, value_to: 75})
      assert html =~ ~s(data-from="25")
      assert html =~ ~s(data-to="75")
    end

    test "renders two range inputs (from and to)" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ "data-range-from"
      assert html =~ "data-range-to"
    end

    test "renders visual thumb elements" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ "data-range-thumb-from"
      assert html =~ "data-range-thumb-to"
    end

    test "renders value labels when show_values is true" do
      html = render_component(&H.render_range_slider/1, %{show_values: true, value_from: 20})
      assert html =~ "data-range-from-label"
      assert html =~ "20"
    end

    test "hides value labels when show_values is false" do
      html = render_component(&H.render_range_slider/1, %{show_values: false})
      refute html =~ "data-range-from-label"
    end

    test "applies pointer-events-none when disabled" do
      html = render_component(&H.render_range_slider/1, %{disabled: true})
      assert html =~ "pointer-events-none"
    end

    test "renders filled track element" do
      html = render_component(&H.render_range_slider/1, %{})
      assert html =~ "data-range-track"
    end
  end

  # ---------------------------------------------------------------------------
  # form_range_slider/1
  # ---------------------------------------------------------------------------

  describe "form_range_slider/1" do
    test "renders label" do
      from_field = build_field(id: "price_min", name: "price_min", value: "100")
      to_field = build_field(id: "price_max", name: "price_max", value: "500")

      html =
        render_component(&H.render_form_range_slider/1, %{
          field_from: from_field,
          field_to: to_field
        })

      assert html =~ "Price range"
    end

    test "uses field names for range inputs" do
      from_field = build_field(id: "pmin", name: "price_min", value: "0")
      to_field = build_field(id: "pmax", name: "price_max", value: "100")

      html =
        render_component(&H.render_form_range_slider/1, %{
          field_from: from_field,
          field_to: to_field
        })

      assert html =~ ~s(name="price_min")
      assert html =~ ~s(name="price_max")
    end

    test "renders the range slider hook" do
      from_field = build_field(id: "f1", name: "f1")
      to_field = build_field(id: "f2", name: "f2")

      html =
        render_component(&H.render_form_range_slider/1, %{
          field_from: from_field,
          field_to: to_field
        })

      assert html =~ ~s(phx-hook="PhiaRangeSlider")
    end
  end

  # ---------------------------------------------------------------------------
  # signature_pad/1
  # ---------------------------------------------------------------------------

  describe "signature_pad/1" do
    test "renders phx-hook attribute" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ ~s(phx-hook="PhiaSignaturePad")
    end

    test "requires id for hook" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ ~s(id="sig-1")
    end

    test "renders canvas element" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ "<canvas"
    end

    test "sets canvas width and height" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ ~s(width="300")
      assert html =~ ~s(height="150")
    end

    test "renders clear button when clearable is true" do
      html = render_component(&H.render_signature_pad/1, %{clearable: true})
      assert html =~ "Clear signature"
      assert html =~ "data-clear"
    end

    test "does not render clear button when clearable is false" do
      html = render_component(&H.render_signature_pad/1, %{clearable: false})
      refute html =~ "Clear signature"
    end

    test "renders hidden input for name" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(name="signature")
    end

    test "sets data-stroke-color" do
      html = render_component(&H.render_signature_pad/1, %{})
      assert html =~ ~s(data-stroke-color="#000000")
    end
  end

  # ---------------------------------------------------------------------------
  # color_swatch_picker/1
  # ---------------------------------------------------------------------------

  describe "color_swatch_picker/1" do
    test "renders a button for each swatch" do
      html =
        render_component(&H.render_color_swatch_picker/1, %{
          swatches: ["#ff0000", "#00ff00", "#0000ff"]
        })

      assert html =~ "#ff0000"
      assert html =~ "#00ff00"
      assert html =~ "#0000ff"
    end

    test "applies selected ring when value matches a swatch" do
      html =
        render_component(&H.render_color_swatch_picker/1, %{
          swatches: ["#ff0000", "#00ff00"],
          value: "#ff0000"
        })

      assert html =~ "ring-2"
    end

    test "sets background-color inline style" do
      html = render_component(&H.render_color_swatch_picker/1, %{})
      assert html =~ "background-color"
    end

    test "applies sm size class" do
      html = render_component(&H.render_color_swatch_picker/1, %{size: "sm"})
      assert html =~ "h-6"
    end

    test "applies md size class (default)" do
      html = render_component(&H.render_color_swatch_picker/1, %{size: "md"})
      assert html =~ "h-8"
    end

    test "applies lg size class" do
      html = render_component(&H.render_color_swatch_picker/1, %{size: "lg"})
      assert html =~ "h-10"
    end

    test "renders role=group for accessibility" do
      html = render_component(&H.render_color_swatch_picker/1, %{})
      assert html =~ ~s(role="group")
    end
  end

  # ---------------------------------------------------------------------------
  # form_color_swatch_picker/1
  # ---------------------------------------------------------------------------

  describe "form_color_swatch_picker/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_color_swatch_picker/1, %{field: field})
      assert html =~ "Brand color"
    end

    test "renders swatches" do
      field = build_field()
      html = render_component(&H.render_form_color_swatch_picker/1, %{field: field})
      assert html =~ "#ff0000"
    end

    test "renders errors" do
      field = build_field(errors: [{"must select a color", []}])
      html = render_component(&H.render_form_color_swatch_picker/1, %{field: field})
      assert html =~ "must select a color"
    end
  end

  # ---------------------------------------------------------------------------
  # float_input/1
  # ---------------------------------------------------------------------------

  describe "float_input/1" do
    test "renders an input element" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ "<input"
    end

    test "renders label text" do
      html = render_component(&H.render_float_input/1, %{label: "Email address"})
      assert html =~ "Email address"
    end

    test "renders label as absolute-positioned element" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ "absolute"
    end

    test "uses placeholder= (space) for peer trick" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ ~s(placeholder=" ")
    end

    test "input has peer class" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ "peer"
    end

    test "applies destructive border styling when error is true" do
      html = render_component(&H.render_float_input/1, %{error: true})
      assert html =~ "border-destructive"
    end

    test "applies disabled attribute and class" do
      html = render_component(&H.render_float_input/1, %{disabled: true})
      assert html =~ "disabled"
    end

    test "sets value attribute" do
      html = render_component(&H.render_float_input/1, %{value: "user@example.com"})
      assert html =~ "user@example.com"
    end

    test "applies peer-placeholder-shown for label position" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ "peer-placeholder-shown"
    end

    test "applies peer-focus class for label position" do
      html = render_component(&H.render_float_input/1, %{})
      assert html =~ "peer-focus"
    end
  end

  # ---------------------------------------------------------------------------
  # form_float_input/1
  # ---------------------------------------------------------------------------

  describe "form_float_input/1" do
    test "renders floating label" do
      field = build_field()
      html = render_component(&H.render_form_float_input/1, %{field: field})
      assert html =~ "Email address"
    end

    test "uses field.id for input id" do
      field = build_field(id: "user_email")
      html = render_component(&H.render_form_float_input/1, %{field: field})
      assert html =~ ~s(id="user_email")
    end

    test "applies error styling when field has errors" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_form_float_input/1, %{field: field})
      assert html =~ "border-destructive"
    end

    test "renders error messages" do
      field = build_field(errors: [{"can't be blank", []}])
      html = render_component(&H.render_form_float_input/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end
  end

  # ---------------------------------------------------------------------------
  # float_textarea/1
  # ---------------------------------------------------------------------------

  describe "float_textarea/1" do
    test "renders a textarea element" do
      html = render_component(&H.render_float_textarea/1, %{})
      assert html =~ "<textarea"
    end

    test "renders floating label" do
      html = render_component(&H.render_float_textarea/1, %{label: "Message"})
      assert html =~ "Message"
    end

    test "applies placeholder= (space) for peer trick" do
      html = render_component(&H.render_float_textarea/1, %{})
      assert html =~ ~s(placeholder=" ")
    end

    test "sets rows attribute" do
      html = render_component(&H.render_float_textarea/1, %{rows: 6})
      assert html =~ ~s(rows="6")
    end

    test "applies destructive border when error is true" do
      html = render_component(&H.render_float_textarea/1, %{error: true})
      assert html =~ "border-destructive"
    end

    test "renders value content" do
      html = render_component(&H.render_float_textarea/1, %{value: "Hello world"})
      assert html =~ "Hello world"
    end
  end

  # ---------------------------------------------------------------------------
  # form_float_textarea/1
  # ---------------------------------------------------------------------------

  describe "form_float_textarea/1" do
    test "renders textarea with floating label" do
      field = build_field()
      html = render_component(&H.render_form_float_textarea/1, %{field: field})
      assert html =~ "<textarea"
      assert html =~ "Message"
    end

    test "renders errors" do
      field = build_field(errors: [{"is too long", []}])
      html = render_component(&H.render_form_float_textarea/1, %{field: field})
      assert html =~ "is too long"
    end
  end

  # ---------------------------------------------------------------------------
  # form_feedback/1
  # ---------------------------------------------------------------------------

  describe "form_feedback/1" do
    test "renders role=alert" do
      html = render_component(&H.render_form_feedback/1, %{status: "success"})
      assert html =~ ~s(role="alert")
    end

    test "renders success icon" do
      html = render_component(&H.render_form_feedback/1, %{status: "success"})
      assert html =~ "✓"
    end

    test "renders error icon" do
      html = render_component(&H.render_form_feedback/1, %{status: "error"})
      assert html =~ "✕"
    end

    test "renders warning icon" do
      html = render_component(&H.render_form_feedback/1, %{status: "warning"})
      assert html =~ "⚠"
    end

    test "renders info icon" do
      html = render_component(&H.render_form_feedback/1, %{status: "info"})
      assert html =~ "ℹ"
    end

    test "renders title when provided" do
      html = render_component(&H.render_form_feedback/1, %{status: "success", title: "Done!"})
      assert html =~ "Done!"
    end

    test "renders message when provided" do
      html =
        render_component(&H.render_form_feedback/1, %{
          status: "error",
          message: "Something went wrong."
        })

      assert html =~ "Something went wrong."
    end

    test "applies green color for success status" do
      html = render_component(&H.render_form_feedback/1, %{status: "success"})
      assert html =~ "green"
    end

    test "applies destructive color for error status" do
      html = render_component(&H.render_form_feedback/1, %{status: "error"})
      assert html =~ "destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # input_status/1
  # ---------------------------------------------------------------------------

  describe "input_status/1" do
    test "renders nothing for status=none" do
      html = render_component(&H.render_input_status/1, %{status: "none"})
      assert html == ""
    end

    test "renders checkmark for status=valid" do
      html = render_component(&H.render_input_status/1, %{status: "valid"})
      assert html =~ "✓"
    end

    test "renders X for status=invalid" do
      html = render_component(&H.render_input_status/1, %{status: "invalid"})
      assert html =~ "✕"
    end

    test "renders spinner for status=pending" do
      html = render_component(&H.render_input_status/1, %{status: "pending"})
      assert html =~ "animate-spin"
    end

    test "applies aria-label with status value" do
      html = render_component(&H.render_input_status/1, %{status: "valid"})
      assert html =~ ~s(aria-label="valid")
    end
  end

  # ---------------------------------------------------------------------------
  # form_stepper/1
  # ---------------------------------------------------------------------------

  describe "form_stepper/1" do
    test "renders all step labels" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Account"}, %{label: "Profile"}, %{label: "Billing"}]
        })

      assert html =~ "Account"
      assert html =~ "Profile"
      assert html =~ "Billing"
    end

    test "renders step numbers for pending steps" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Step 1"}, %{label: "Step 2"}, %{label: "Step 3"}],
          current_step: 1
        })

      assert html =~ "2"
      assert html =~ "3"
    end

    test "renders checkmark for completed steps" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Step 1"}, %{label: "Step 2"}],
          current_step: 2
        })

      assert html =~ "✓"
    end

    test "applies active styling on current step" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Step 1"}, %{label: "Step 2"}],
          current_step: 1
        })

      assert html =~ "border-primary"
      assert html =~ "bg-primary"
    end

    test "applies green styling for completed steps" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Done"}, %{label: "Active"}],
          current_step: 2
        })

      assert html =~ "green"
    end

    test "renders description when provided in step map" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Account", description: "Create your account"}]
        })

      assert html =~ "Create your account"
    end

    test "renders horizontal layout by default" do
      html = render_component(&H.render_form_stepper/1, %{orientation: "horizontal"})
      assert html =~ "flex"
    end

    test "renders vertical layout when specified" do
      html = render_component(&H.render_form_stepper/1, %{orientation: "vertical"})
      assert html =~ "flex-col"
    end

    test "respects explicit status in step map" do
      html =
        render_component(&H.render_form_stepper/1, %{
          steps: [%{label: "Failed Step", status: "error"}],
          current_step: 1
        })

      assert html =~ "destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # form_stepper_item/1
  # ---------------------------------------------------------------------------

  describe "form_stepper_item/1" do
    test "renders step label" do
      html = render_component(&H.render_form_stepper_item/1, %{label: "My Step"})
      assert html =~ "My Step"
    end

    test "renders step number for pending status" do
      html = render_component(&H.render_form_stepper_item/1, %{step: 3, status: "pending"})
      assert html =~ "3"
    end

    test "renders checkmark for complete status" do
      html = render_component(&H.render_form_stepper_item/1, %{status: "complete"})
      assert html =~ "✓"
    end

    test "renders X for error status" do
      html = render_component(&H.render_form_stepper_item/1, %{status: "error"})
      assert html =~ "✕"
    end

    test "renders description when provided" do
      html =
        render_component(&H.render_form_stepper_item/1, %{
          description: "Set up your account"
        })

      assert html =~ "Set up your account"
    end

    test "applies active indicator styling" do
      html = render_component(&H.render_form_stepper_item/1, %{status: "active"})
      assert html =~ "border-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # country_select/1
  # ---------------------------------------------------------------------------

  describe "country_select/1" do
    test "renders a <select> element" do
      html = render_component(&H.render_country_select/1, %{})
      assert html =~ "<select"
    end

    test "renders multiple country options" do
      html = render_component(&H.render_country_select/1, %{})
      assert html =~ "United States"
      assert html =~ "Germany"
      assert html =~ "Brazil"
    end

    test "renders country codes as values" do
      html = render_component(&H.render_country_select/1, %{})
      assert html =~ ~s(value="US")
      assert html =~ ~s(value="DE")
    end

    test "marks the selected country" do
      html = render_component(&H.render_country_select/1, %{value: "DE"})
      assert html =~ "selected"
    end

    test "renders chevron icon" do
      html = render_component(&H.render_country_select/1, %{})
      assert html =~ "<polyline"
    end

    test "renders prompt option first" do
      html = render_component(&H.render_country_select/1, %{})
      assert html =~ "Select a country"
    end

    test "appends dial code to options when include_dial_code is true" do
      html = render_component(&H.render_country_select/1, %{include_dial_code: true})
      assert html =~ "+1"
    end

    test "does not show dial code by default" do
      html = render_component(&H.render_country_select/1, %{include_dial_code: false})
      assert html =~ "United States"
      refute html =~ "+1"
    end
  end

  # ---------------------------------------------------------------------------
  # form_country_select/1
  # ---------------------------------------------------------------------------

  describe "form_country_select/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_country_select/1, %{field: field})
      assert html =~ "Country"
    end

    test "uses field.id for label association" do
      field = build_field(id: "user_country")
      html = render_component(&H.render_form_country_select/1, %{field: field})
      assert html =~ ~s(for="user_country")
      assert html =~ ~s(id="user_country")
    end

    test "uses field.name for select name" do
      field = build_field(name: "user[country]")
      html = render_component(&H.render_form_country_select/1, %{field: field})
      assert html =~ ~s(name="user[country]")
    end

    test "renders field errors" do
      field = build_field(errors: [{"must be selected", []}])
      html = render_component(&H.render_form_country_select/1, %{field: field})
      assert html =~ "must be selected"
    end

    test "applies destructive border when field has errors" do
      field = build_field(errors: [{"invalid", []}])
      html = render_component(&H.render_form_country_select/1, %{field: field})
      assert html =~ "border-destructive"
    end
  end
end
