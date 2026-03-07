defmodule PhiaUi.Components.SliderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Slider

    def render_slider(assigns) do
      ~H"""
      <.slider
        value={Map.get(assigns, :value, 50)}
        min={Map.get(assigns, :min, 0)}
        max={Map.get(assigns, :max, 100)}
        step={Map.get(assigns, :step, 1)}
        disabled={Map.get(assigns, :disabled, false)}
        class={Map.get(assigns, :class, nil)}
      />
      """
    end

    attr(:value, :integer, default: 50)
    attr(:min, :integer, default: 0)
    attr(:max, :integer, default: 100)
    attr(:step, :integer, default: 1)
    attr(:disabled, :boolean, default: false)
    attr(:marks, :list, default: [])
    attr(:vertical, :boolean, default: false)
    attr(:show_value, :boolean, default: false)
    attr(:class, :string, default: nil)

    def render_slider_attrs(assigns) do
      ~H"""
      <.slider
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        disabled={@disabled}
        marks={@marks}
        vertical={@vertical}
        show_value={@show_value}
        class={@class}
      />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:description, :string, default: nil)
    attr(:min, :integer, default: 0)
    attr(:max, :integer, default: 100)
    attr(:step, :integer, default: 1)
    attr(:class, :string, default: nil)

    def render_form_slider(assigns) do
      ~H"""
      <.form_slider
        field={@field}
        label={@label}
        description={@description}
        min={@min}
        max={@max}
        step={@step}
        class={@class}
      />
      """
    end
  end

  defp render_slider(attrs \\ %{}) do
    render_component(&H.render_slider_attrs/1, attrs)
  end

  defp make_field(value \\ "50", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"volume" => value}, as: :audio)
    field = form[:volume]
    %{field | errors: errors}
  end

  defp render_form_slider(attrs) do
    render_component(&H.render_form_slider/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # slider/1 — base classes
  # ---------------------------------------------------------------------------

  describe "slider/1 — base CSS classes" do
    test "renders w-full class" do
      assert render_slider() =~ "w-full"
    end

    test "renders h-2 class" do
      assert render_slider() =~ "h-2"
    end

    test "renders cursor-pointer class" do
      assert render_slider() =~ "cursor-pointer"
    end

    test "renders accent-primary class" do
      assert render_slider() =~ "accent-primary"
    end

    test "renders bg-secondary class" do
      assert render_slider() =~ "bg-secondary"
    end

    test "renders rounded-full class" do
      assert render_slider() =~ "rounded-full"
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — WAI-ARIA and attributes
  # ---------------------------------------------------------------------------

  describe "slider/1 — ARIA attributes" do
    test "default value=0 renders aria-valuenow=0" do
      html = render_slider(%{value: 0})
      assert html =~ ~s(aria-valuenow="0")
    end

    test "custom value sets aria-valuenow" do
      html = render_slider(%{value: 75})
      assert html =~ ~s(aria-valuenow="75")
    end

    test "default min=0 renders aria-valuemin=0" do
      assert render_slider() =~ ~s(aria-valuemin="0")
    end

    test "custom min sets aria-valuemin" do
      html = render_slider(%{min: 10})
      assert html =~ ~s(aria-valuemin="10")
    end

    test "default max=100 renders aria-valuemax=100" do
      assert render_slider() =~ ~s(aria-valuemax="100")
    end

    test "custom max sets aria-valuemax" do
      html = render_slider(%{max: 200})
      assert html =~ ~s(aria-valuemax="200")
    end

    test "role=slider is present" do
      assert render_slider() =~ ~s(role="slider")
    end

    test "step attribute is rendered" do
      html = render_slider(%{step: 5})
      assert html =~ ~s(step="5")
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — disabled state
  # ---------------------------------------------------------------------------

  describe "slider/1 — disabled state" do
    test "disabled renders opacity-50" do
      html = render_slider(%{disabled: true})
      assert html =~ "opacity-50"
    end

    test "disabled renders cursor-not-allowed" do
      html = render_slider(%{disabled: true})
      assert html =~ "cursor-not-allowed"
    end

    test "non-disabled slider does not add standalone opacity-50 token" do
      html = render_slider(%{disabled: false})
      # The base classes include disabled:opacity-50 (with pseudo-class prefix).
      # The bare dynamic token opacity-50 (no colon before it) should only appear when
      # @disabled=true. We check the class attr doesn't contain a space-separated bare token.
      refute html =~ ~r/ opacity-50[ "]/
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — custom class and rest attrs
  # ---------------------------------------------------------------------------

  describe "slider/1 — class and rest attrs" do
    test "custom class is applied" do
      html = render_slider(%{class: "my-custom-slider"})
      assert html =~ "my-custom-slider"
    end

    test "base classes are still present alongside custom class" do
      html = render_slider(%{class: "my-custom-slider"})
      assert html =~ "w-full"
      assert html =~ "my-custom-slider"
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — focus-visible ring classes
  # ---------------------------------------------------------------------------

  describe "slider/1 — focus-visible ring classes" do
    test "renders focus-visible:outline-none" do
      assert render_slider() =~ "focus-visible:outline-none"
    end

    test "renders focus-visible:ring-2" do
      assert render_slider() =~ "focus-visible:ring-2"
    end

    test "renders focus-visible:ring-ring" do
      assert render_slider() =~ "focus-visible:ring-ring"
    end

    test "renders focus-visible:ring-offset-2" do
      assert render_slider() =~ "focus-visible:ring-offset-2"
    end
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — label
  # ---------------------------------------------------------------------------

  describe "form_slider/1 — label" do
    test "renders label text when provided" do
      html = render_form_slider(%{field: make_field(), label: "Volume"})
      assert html =~ "Volume"
    end

    test "renders label element for the field id" do
      field = make_field()
      html = render_form_slider(%{field: field, label: "Volume"})
      assert html =~ ~s(for="#{field.id}")
    end

    test "does not render label element when label is nil" do
      html = render_form_slider(%{field: make_field()})
      refute html =~ "<label"
    end
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — description
  # ---------------------------------------------------------------------------

  describe "form_slider/1 — description" do
    test "renders description text when provided" do
      html = render_form_slider(%{field: make_field(), description: "Adjust the volume level"})
      assert html =~ "Adjust the volume level"
    end

    test "renders description with muted-foreground class" do
      html = render_form_slider(%{field: make_field(), description: "Helper text"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render description element when nil" do
      html = render_form_slider(%{field: make_field()})
      refute html =~ "text-muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — field id, name, value
  # ---------------------------------------------------------------------------

  describe "form_slider/1 — field integration" do
    test "renders the field id on the input" do
      field = make_field()
      html = render_form_slider(%{field: field})
      assert html =~ ~s(id="#{field.id}")
    end

    test "renders the field name on the input" do
      field = make_field()
      html = render_form_slider(%{field: field})
      assert html =~ ~s(name="#{field.name}")
    end

    test "renders the field value on the input" do
      field = make_field("72")
      html = render_form_slider(%{field: field})
      assert html =~ ~s(value="72")
    end

    test "falls back to value 0 when field value is nil" do
      field = %{make_field() | value: nil}
      html = render_form_slider(%{field: field})
      assert html =~ ~s(value="0")
    end
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — errors
  # ---------------------------------------------------------------------------

  describe "form_slider/1 — errors" do
    test "renders error message when field has errors" do
      field = make_field("", [{"must be a valid number", []}])
      html = render_form_slider(%{field: field})
      assert html =~ "must be a valid number"
    end

    test "renders error with text-destructive class" do
      field = make_field("", [{"is invalid", []}])
      html = render_form_slider(%{field: field})
      assert html =~ "text-destructive"
    end

    test "applies accent-destructive class on input when errors present" do
      field = make_field("", [{"is invalid", []}])
      html = render_form_slider(%{field: field})
      assert html =~ "accent-destructive"
    end

    test "does not render error paragraph when no errors" do
      html = render_form_slider(%{field: make_field()})
      refute html =~ "text-destructive"
    end

    test "does not apply accent-destructive when no errors" do
      html = render_form_slider(%{field: make_field()})
      refute html =~ "accent-destructive"
    end

    test "interpolates error placeholder opts" do
      field = make_field("", [{"must be at most %{max} characters", [max: 100]}])
      html = render_form_slider(%{field: field})
      assert html =~ "must be at most 100 characters"
    end
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — min, max, step
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # slider/1 — marks
  # ---------------------------------------------------------------------------

  describe "slider/1 — marks" do
    test "marks renders a wrapper div (relative container)" do
      html =
        render_component(&H.render_slider_attrs/1, %{
          value: 50,
          marks: [%{value: 0, label: "Min"}, %{value: 100, label: "Max"}]
        })

      assert html =~ "relative"
    end

    test "marks renders tick labels" do
      html =
        render_component(&H.render_slider_attrs/1, %{
          value: 50,
          marks: [%{value: 0, label: "Min"}, %{value: 100, label: "Max"}]
        })

      assert html =~ "Min"
      assert html =~ "Max"
    end

    test "marks positions labels with left: style" do
      html =
        render_component(&H.render_slider_attrs/1, %{
          value: 50,
          marks: [%{value: 50, label: "Mid"}]
        })

      assert html =~ "left:"
    end

    test "marks=[] (default) renders bare input without wrapper div" do
      html = render_slider()
      refute html =~ "<div"
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — vertical
  # ---------------------------------------------------------------------------

  describe "slider/1 — vertical" do
    test "vertical=true renders wrapper container" do
      html =
        render_component(&H.render_slider_attrs/1, %{value: 50, vertical: true})

      assert html =~ "<div"
    end

    test "vertical=true adds rotate class on input" do
      html =
        render_component(&H.render_slider_attrs/1, %{value: 50, vertical: true})

      assert html =~ "-rotate-90"
    end

    test "vertical=false (default) renders bare input" do
      html = render_slider()
      refute html =~ "-rotate-90"
    end
  end

  # ---------------------------------------------------------------------------
  # slider/1 — show_value
  # ---------------------------------------------------------------------------

  describe "slider/1 — show_value" do
    test "show_value=true renders value badge" do
      html =
        render_component(&H.render_slider_attrs/1, %{value: 42, show_value: true})

      assert html =~ "42"
      assert html =~ "-translate-x-1/2"
    end

    test "show_value=true positions badge with left: style" do
      html =
        render_component(&H.render_slider_attrs/1, %{value: 50, show_value: true})

      assert html =~ "left:"
    end

    test "show_value=false (default) does not render badge" do
      html = render_slider(%{value: 50})
      refute html =~ "-translate-x-1/2"
    end
  end

  describe "form_slider/1 — min, max, step attrs" do
    test "renders custom min attribute" do
      html = render_form_slider(%{field: make_field(), min: 10})
      assert html =~ ~s(min="10")
    end

    test "renders custom max attribute" do
      html = render_form_slider(%{field: make_field(), max: 500})
      assert html =~ ~s(max="500")
    end

    test "renders custom step attribute" do
      html = render_form_slider(%{field: make_field(), step: 10})
      assert html =~ ~s(step="10")
    end

    test "renders role=slider on form_slider input" do
      html = render_form_slider(%{field: make_field()})
      assert html =~ ~s(role="slider")
    end

    test "renders aria-valuemin from min attr" do
      html = render_form_slider(%{field: make_field(), min: 5})
      assert html =~ ~s(aria-valuemin="5")
    end

    test "renders aria-valuemax from max attr" do
      html = render_form_slider(%{field: make_field(), max: 50})
      assert html =~ ~s(aria-valuemax="50")
    end
  end
end
