defmodule PhiaUi.Components.SwitchTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Switch

    attr(:checked, :boolean, default: false)
    attr(:disabled, :boolean, default: false)
    attr(:class, :string, default: nil)

    def render_switch(assigns) do
      ~H"""
      <.switch checked={@checked} disabled={@disabled} class={@class} />
      """
    end

    attr(:field, Phoenix.HTML.FormField, required: true)
    attr(:label, :string, default: nil)

    def render_form_switch(assigns) do
      ~H"""
      <.form_switch field={@field} label={@label} />
      """
    end
  end

  defp render_switch(attrs \\ %{}) do
    render_component(&H.render_switch/1, attrs)
  end

  defp build_field(value \\ false) do
    form = Phoenix.HTML.FormData.to_form(%{}, as: :test, skip_hidden: true)

    %Phoenix.HTML.FormField{
      id: "test_active",
      name: "test[active]",
      errors: [],
      field: :active,
      form: form,
      value: value
    }
  end

  defp render_form_switch(attrs \\ %{}) do
    render_component(&H.render_form_switch/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # switch/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "switch/1 ARIA" do
    test "renders role=switch" do
      assert render_switch() =~ ~s(role="switch")
    end

    test "renders aria-checked=false when unchecked" do
      assert render_switch(%{checked: false}) =~ ~s(aria-checked="false")
    end

    test "renders aria-checked=true when checked" do
      assert render_switch(%{checked: true}) =~ ~s(aria-checked="true")
    end

    test "renders as a button element" do
      assert render_switch() =~ "<button"
    end
  end

  # ---------------------------------------------------------------------------
  # switch/1 — visual track
  # ---------------------------------------------------------------------------

  describe "switch/1 track styling" do
    test "renders track background token bg-input when unchecked" do
      html = render_switch(%{checked: false})
      assert html =~ "bg-input"
    end

    test "renders track background token bg-primary when checked" do
      html = render_switch(%{checked: true})
      assert html =~ "bg-primary"
    end

    test "track has rounded-full shape" do
      assert render_switch() =~ "rounded-full"
    end

    test "does not use hardcoded track colors" do
      html = render_switch(%{checked: true})
      refute html =~ "bg-gray-"
      refute html =~ "bg-[#"
    end
  end

  # ---------------------------------------------------------------------------
  # switch/1 — thumb
  # ---------------------------------------------------------------------------

  describe "switch/1 thumb" do
    test "renders thumb element with bg-background" do
      assert render_switch() =~ "bg-background"
    end

    test "thumb is circular (rounded-full)" do
      html = render_switch()
      # At least two rounded-full: one for track, one for thumb
      count = html |> String.split("rounded-full") |> length() |> Kernel.-(1)
      assert count >= 2
    end

    test "thumb has transition for smooth animation" do
      assert render_switch() =~ "transition"
    end

    test "thumb translates right when checked" do
      html = render_switch(%{checked: true})
      assert html =~ "translate-x"
    end
  end

  # ---------------------------------------------------------------------------
  # switch/1 — disabled state
  # ---------------------------------------------------------------------------

  describe "switch/1 disabled" do
    test "renders disabled attribute when disabled=true" do
      assert render_switch(%{disabled: true}) =~ "disabled"
    end

    test "applies opacity class when disabled" do
      assert render_switch(%{disabled: true}) =~ "opacity-50"
    end

    test "does not apply opacity when enabled" do
      refute render_switch(%{disabled: false}) =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # switch/1 — class customization
  # ---------------------------------------------------------------------------

  describe "switch/1 :class" do
    test "applies custom class" do
      assert render_switch(%{class: "my-custom"}) =~ "my-custom"
    end

    test "nil class renders without issues" do
      html = render_switch(%{class: nil})
      assert html =~ ~s(role="switch")
    end
  end

  # ---------------------------------------------------------------------------
  # switch/1 — focus
  # ---------------------------------------------------------------------------

  describe "switch/1 focus" do
    test "includes focus-visible ring classes" do
      assert render_switch() =~ "focus-visible:ring"
    end
  end

  # ---------------------------------------------------------------------------
  # form_switch/1
  # ---------------------------------------------------------------------------

  describe "form_switch/1" do
    test "renders a hidden checkbox input" do
      html = render_form_switch(%{field: build_field(false)})
      assert html =~ ~s(type="checkbox")
    end

    test "renders switch button" do
      html = render_form_switch(%{field: build_field(false)})
      assert html =~ ~s(role="switch")
    end

    test "renders label when provided" do
      html = render_form_switch(%{field: build_field(false), label: "Ativar notificações"})
      assert html =~ "Ativar notificações"
    end

    test "reflects checked state from field value" do
      html = render_form_switch(%{field: build_field(true)})
      assert html =~ ~s(aria-checked="true")
    end
  end
end
