defmodule PhiaUi.Components.RatingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Rating

    attr(:value, :any, default: 0)
    attr(:max, :integer, default: 5)
    attr(:readonly, :boolean, default: false)
    attr(:size, :string, default: "default")
    attr(:name, :string, default: "rating")
    attr(:class, :string, default: nil)
    attr(:half, :boolean, default: false)
    attr(:icon, :atom, default: :star)
    attr(:labels, :list, default: [])

    def render_rating(assigns) do
      ~H"""
      <.rating
        value={@value}
        max={@max}
        readonly={@readonly}
        size={@size}
        name={@name}
        class={@class}
        half={@half}
        icon={@icon}
        labels={@labels}
      />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:description, :string, default: nil)

    def render_form_rating(assigns) do
      ~H"""
      <.form_rating field={@field} label={@label} description={@description} />
      """
    end
  end

  defp render_rating(attrs \\ %{}) do
    render_component(&H.render_rating/1, attrs)
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"rating" => value}, as: :review)
    field = form[:rating]
    %{field | errors: errors}
  end

  # ---------------------------------------------------------------------------
  # rating/1 — structural rendering
  # ---------------------------------------------------------------------------

  describe "rating/1 — structural rendering" do
    test "renders fieldset element" do
      assert render_rating() =~ "<fieldset"
    end

    test "has role=radiogroup on fieldset" do
      assert render_rating() =~ ~s(role="radiogroup")
    end

    test "renders correct number of stars for default max (5)" do
      html = render_rating()
      # 5 radio inputs
      assert html |> count_occurrences(~s(type="radio")) == 5
    end

    test "renders correct number of stars for custom max=3" do
      html = render_rating(%{max: 3})
      assert html |> count_occurrences(~s(type="radio")) == 3
    end

    test "renders correct number of stars for max=7" do
      html = render_rating(%{max: 7})
      assert html |> count_occurrences(~s(type="radio")) == 7
    end

    test "renders radio inputs" do
      assert render_rating() =~ ~s(type="radio")
    end

    test "radio inputs have sr-only class (visually hidden)" do
      assert render_rating() =~ "sr-only"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — checked state
  # ---------------------------------------------------------------------------

  describe "rating/1 — checked state" do
    test "value=3 marks first three stars as checked" do
      html = render_rating(%{value: 3})
      # checked attribute should appear 3 times (stars 1, 2, 3)
      assert html |> count_occurrences("checked") == 3
    end

    test "value=0 marks no stars as checked" do
      html = render_rating(%{value: 0})
      refute html =~ "checked"
    end

    test "star beyond value is NOT checked" do
      html = render_rating(%{value: 2, max: 5})
      # Only stars 1 and 2 should be checked
      assert html |> count_occurrences("checked") == 2
    end

    test "value=5 with max=5 marks all stars as checked" do
      html = render_rating(%{value: 5, max: 5})
      assert html |> count_occurrences("checked") == 5
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — readonly mode
  # ---------------------------------------------------------------------------

  describe "rating/1 — readonly mode" do
    test "readonly=true adds disabled attribute to inputs" do
      html = render_rating(%{readonly: true})
      assert html =~ "disabled"
    end

    test "readonly=false does not add disabled attribute" do
      html = render_rating(%{readonly: false})
      refute html =~ "disabled"
    end

    test "readonly=true applies cursor-default class on labels" do
      assert render_rating(%{readonly: true}) =~ "cursor-default"
    end

    test "readonly=false applies cursor-pointer class on labels" do
      assert render_rating(%{readonly: false}) =~ "cursor-pointer"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — star colors
  # ---------------------------------------------------------------------------

  describe "rating/1 — star icon colors" do
    test "selected stars receive text-yellow-400 class" do
      html = render_rating(%{value: 3})
      assert html =~ "text-yellow-400"
    end

    test "unselected stars receive text-muted-foreground/30 class" do
      html = render_rating(%{value: 3, max: 5})
      assert html =~ "text-muted-foreground/30"
    end

    test "value=0 applies only text-muted-foreground/30 (no yellow)" do
      html = render_rating(%{value: 0})
      refute html =~ "text-yellow-400"
      assert html =~ "text-muted-foreground/30"
    end

    test "value=max applies only text-yellow-400 (no muted)" do
      html = render_rating(%{value: 5, max: 5})
      assert html =~ "text-yellow-400"
      refute html =~ "text-muted-foreground/30"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — size variants
  # ---------------------------------------------------------------------------

  describe "rating/1 — size variants" do
    test "size=sm applies h-4 w-4 on SVG icon" do
      html = render_rating(%{size: "sm"})
      assert html =~ "h-4"
      assert html =~ "w-4"
    end

    test "size=default applies h-5 w-5 on SVG icon" do
      html = render_rating(%{size: "default"})
      assert html =~ "h-5"
      assert html =~ "w-5"
    end

    test "size=lg applies h-7 w-7 on SVG icon" do
      html = render_rating(%{size: "lg"})
      assert html =~ "h-7"
      assert html =~ "w-7"
    end

    test "all sizes apply transition-colors on SVG icon" do
      for size <- ~w(sm default lg) do
        assert render_rating(%{size: size}) =~ "transition-colors"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — class passthrough
  # ---------------------------------------------------------------------------

  describe "rating/1 — class merge" do
    test "custom class is applied to fieldset" do
      assert render_rating(%{class: "my-custom-class"}) =~ "my-custom-class"
    end

    test "base flex class is preserved alongside custom class" do
      html = render_rating(%{class: "my-custom-class"})
      assert html =~ "flex"
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — aria-label on inputs
  # ---------------------------------------------------------------------------

  describe "rating/1 — aria-label on radio inputs" do
    test "first star has aria-label '1 star'" do
      assert render_rating() =~ ~s(aria-label="1 star")
    end

    test "second star has aria-label '2 stars'" do
      assert render_rating() =~ ~s(aria-label="2 stars")
    end

    test "fieldset has aria-label=Rating" do
      assert render_rating() =~ ~s(aria-label="Rating")
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — SVG star path
  # ---------------------------------------------------------------------------

  describe "rating/1 — SVG star" do
    test "renders SVG element" do
      assert render_rating() =~ "<svg"
    end

    test "SVG has aria-hidden=true" do
      assert render_rating() =~ ~s(aria-hidden="true")
    end

    test "SVG contains star path data" do
      assert render_rating() =~ "M12 2l3.09 6.26"
    end
  end

  # ---------------------------------------------------------------------------
  # form_rating/1 — rendering
  # ---------------------------------------------------------------------------

  describe "form_rating/1 — label" do
    test "renders label when label attr given" do
      html =
        render_component(&H.render_form_rating/1, %{field: make_field(), label: "Your Rating"})

      assert html =~ "<label"
      assert html =~ "Your Rating"
    end

    test "does not render outer label when label is nil" do
      html = render_component(&H.render_form_rating/1, %{field: make_field()})
      # Star labels exist but the form heading label carries 'font-medium leading-none'
      refute html =~ "font-medium leading-none"
    end
  end

  describe "form_rating/1 — description" do
    test "renders description paragraph when given" do
      html =
        render_component(&H.render_form_rating/1, %{
          field: make_field(),
          description: "Tell us what you think"
        })

      assert html =~ "Tell us what you think"
      assert html =~ "text-sm text-muted-foreground"
    end

    test "does not render description when not given" do
      html = render_component(&H.render_form_rating/1, %{field: make_field()})
      # Description paragraph uses unique class 'text-sm text-muted-foreground'
      # unselected stars use 'text-muted-foreground/30' (different)
      refute html =~ "text-sm text-muted-foreground"
    end
  end

  describe "form_rating/1 — errors" do
    test "renders error message from field.errors" do
      field = make_field("", [{"can't be blank", [validation: :required]}])
      html = render_component(&H.render_form_rating/1, %{field: field})
      assert html =~ "can&#39;t be blank"
    end

    test "error paragraph has text-destructive class" do
      field = make_field("", [{"must be at least 1", []}])
      html = render_component(&H.render_form_rating/1, %{field: field})
      assert html =~ "text-destructive"
    end

    test "no error paragraph when field has no errors" do
      html = render_component(&H.render_form_rating/1, %{field: make_field()})
      refute html =~ "text-destructive"
    end
  end

  describe "form_rating/1 — value parsing from FormField" do
    test "string value '4' is parsed and marks 4 stars checked" do
      html = render_component(&H.render_form_rating/1, %{field: make_field("4")})
      assert html |> count_occurrences("checked") == 4
    end

    test "empty string value marks no stars checked" do
      html = render_component(&H.render_form_rating/1, %{field: make_field("")})
      refute html =~ "checked"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — half-star display (half=true)
  # ---------------------------------------------------------------------------

  describe "rating/1 — half=true overlay rendering" do
    test "half=true renders overlay spans for clip approach" do
      html = render_component(&H.render_rating/1, %{half: true, value: 2.5, max: 5})
      # overlay span with inline style for width percentage
      assert html =~ "overflow-hidden"
    end

    test "half=true with integer value still renders" do
      html = render_component(&H.render_rating/1, %{half: true, value: 3, max: 5})
      assert html =~ "<fieldset"
    end

    test "half=true renders two SVGs per star (background + foreground)" do
      html = render_component(&H.render_rating/1, %{half: true, value: 3, max: 3})
      # At least 6 svg elements for 3 stars (2 each)
      count = html |> String.split("<svg") |> length() |> Kernel.-(1)
      assert count >= 6
    end

    test "half=true value=2.5 shows 50% fill width on third star" do
      html = render_component(&H.render_rating/1, %{half: true, value: 2.5, max: 5})
      assert html =~ "width: 50%"
    end

    test "half=true value=3.0 shows 100% fill on stars 1-3" do
      html = render_component(&H.render_rating/1, %{half: true, value: 3.0, max: 5})
      assert html =~ "width: 100%"
    end

    test "half=true value=0.0 shows 0% fill on all stars" do
      html = render_component(&H.render_rating/1, %{half: true, value: 0.0, max: 3})
      assert html =~ "width: 0%"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — icon variants
  # ---------------------------------------------------------------------------

  describe "rating/1 — icon variants" do
    test "icon=:star renders the star SVG path (default)" do
      html = render_component(&H.render_rating/1, %{icon: :star})
      assert html =~ "M12 2l3.09 6.26"
    end

    test "icon=:heart renders heart SVG path" do
      html = render_component(&H.render_rating/1, %{icon: :heart})
      assert html =~ "M20.84 4.61"
    end

    test "icon=:thumb renders thumb SVG path" do
      html = render_component(&H.render_rating/1, %{icon: :thumb})
      assert html =~ "M7 22H4"
    end

    test "icon=:heart does not render star path" do
      html = render_component(&H.render_rating/1, %{icon: :heart})
      refute html =~ "M12 2l3.09 6.26"
    end
  end

  # ---------------------------------------------------------------------------
  # rating/1 — hover labels
  # ---------------------------------------------------------------------------

  describe "rating/1 — labels" do
    test "labels adds title attribute to star labels" do
      html =
        render_component(&H.render_rating/1, %{
          labels: ["Poor", "Fair", "Good", "Great", "Excellent"]
        })

      assert html =~ ~s(title="Poor")
      assert html =~ ~s(title="Excellent")
    end

    test "labels=[] does not add title attribute" do
      html = render_component(&H.render_rating/1, %{labels: []})
      refute html =~ "title="
    end

    test "partial labels list only fills provided positions" do
      html = render_component(&H.render_rating/1, %{labels: ["Bad", "OK"]})
      assert html =~ ~s(title="Bad")
      assert html =~ ~s(title="OK")
    end
  end

  # ---------------------------------------------------------------------------
  # Private utility
  # ---------------------------------------------------------------------------

  defp count_occurrences(string, substring) do
    string
    |> String.split(substring)
    |> length()
    |> Kernel.-(1)
  end
end
