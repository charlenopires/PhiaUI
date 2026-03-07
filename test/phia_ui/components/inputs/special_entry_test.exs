defmodule PhiaUi.Components.SpecialEntryTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SpecialEntry

    attr(:id, :string, default: "vi")
    attr(:type, :atom, default: :password)
    attr(:name, :string, default: "value")
    attr(:confirm_name, :string, default: "confirm_value")
    attr(:value, :string, default: "")
    attr(:confirm_value, :string, default: "")
    attr(:matched, :boolean, default: nil)
    attr(:placeholder, :string, default: nil)
    attr(:confirm_placeholder, :string, default: nil)
    attr(:size, :atom, default: :default)
    attr(:disabled, :boolean, default: false)

    def render_verifiable_input(assigns) do
      ~H"""
      <.verifiable_input
        id={@id}
        type={@type}
        name={@name}
        confirm_name={@confirm_name}
        value={@value}
        confirm_value={@confirm_value}
        matched={@matched}
        placeholder={@placeholder}
        confirm_placeholder={@confirm_placeholder}
        size={@size}
        disabled={@disabled}
      />
      """
    end

    attr(:id, :string, default: "di")
    attr(:name, :string, default: "duration")
    attr(:value, :any, default: 0)
    attr(:show_hours, :boolean, default: true)
    attr(:show_seconds, :boolean, default: true)
    attr(:max_hours, :integer, default: 99)
    attr(:disabled, :boolean, default: false)

    def render_duration_input(assigns) do
      ~H"""
      <.duration_input
        id={@id}
        name={@name}
        value={@value}
        show_hours={@show_hours}
        show_seconds={@show_seconds}
        max_hours={@max_hours}
        disabled={@disabled}
      />
      """
    end

    attr(:id, :string, default: "si")
    attr(:name, :string, default: "split")
    attr(:separator, :string, default: "")

    def render_split_input(assigns) do
      ~H"""
      <.split_input id={@id} name={@name} separator={@separator}>
        <.split_input_field placeholder="A" maxlength={1} />
        <.split_input_field placeholder="B" maxlength={1} />
        <.split_input_field placeholder="C" maxlength={1} />
      </.split_input>
      """
    end

    attr(:id, :string, default: "cc")
    attr(:show_cardholder, :boolean, default: true)

    def render_credit_card_input(assigns) do
      ~H"""
      <.credit_card_input id={@id} show_cardholder={@show_cardholder} />
      """
    end

    def render_split_field(assigns) do
      ~H"""
      <.split_input_field placeholder="X" maxlength={2} />
      """
    end
  end

  defp render_verifiable_input(attrs \\ %{}) do
    render_component(&H.render_verifiable_input/1, attrs)
  end

  defp render_duration_input(attrs \\ %{}) do
    render_component(&H.render_duration_input/1, attrs)
  end

  defp render_split_input(attrs \\ %{}) do
    render_component(&H.render_split_input/1, attrs)
  end

  defp render_credit_card_input(attrs \\ %{}) do
    render_component(&H.render_credit_card_input/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # verifiable_input/1
  # ---------------------------------------------------------------------------

  describe "verifiable_input/1 — structure" do
    test "renders two input elements" do
      html = render_verifiable_input()
      count = html |> String.split("<input") |> length() |> Kernel.-(1)
      assert count == 2
    end

    test "both inputs have distinct names" do
      html = render_verifiable_input(%{name: "pw", confirm_name: "pw_confirm"})
      assert html =~ ~s(name="pw")
      assert html =~ ~s(name="pw_confirm")
    end

    test "type=:password sets type=password on inputs" do
      html = render_verifiable_input(%{type: :password})
      assert html =~ ~s(type="password")
    end

    test "type=:email sets type=email on inputs" do
      html = render_verifiable_input(%{type: :email})
      assert html =~ ~s(type="email")
    end

    test "disabled=true adds disabled to inputs" do
      html = render_verifiable_input(%{disabled: true})
      assert html =~ "disabled"
    end
  end

  describe "verifiable_input/1 — matched states" do
    test "matched=nil shows no status indicator" do
      html = render_verifiable_input(%{matched: nil})
      refute html =~ "text-green-500"
      refute html =~ "text-destructive"
    end

    test "matched=true shows green checkmark" do
      html = render_verifiable_input(%{matched: true})
      assert html =~ "text-green-500"
    end

    test "matched=false shows destructive icon" do
      html = render_verifiable_input(%{matched: false})
      assert html =~ "text-destructive"
    end

    test "matched=false shows error message" do
      html = render_verifiable_input(%{matched: false})
      assert html =~ "do not match"
    end

    test "matched=false adds border-destructive to confirm input" do
      html = render_verifiable_input(%{matched: false})
      assert html =~ "border-destructive"
    end

    test "matched=false sets aria-invalid on confirm input" do
      html = render_verifiable_input(%{matched: false})
      assert html =~ ~s(aria-invalid="true")
    end
  end

  describe "verifiable_input/1 — placeholder" do
    test "renders placeholder on primary input" do
      html = render_verifiable_input(%{placeholder: "Enter password"})
      assert html =~ "Enter password"
    end

    test "renders confirm_placeholder on secondary input" do
      html = render_verifiable_input(%{confirm_placeholder: "Re-enter password"})
      assert html =~ "Re-enter password"
    end
  end

  # ---------------------------------------------------------------------------
  # duration_input/1
  # ---------------------------------------------------------------------------

  describe "duration_input/1 — structure" do
    test "renders hour input by default" do
      html = render_duration_input()
      assert html =~ ~s(aria-label="Hours")
    end

    test "renders minute input" do
      html = render_duration_input()
      assert html =~ ~s(aria-label="Minutes")
    end

    test "renders second input by default" do
      html = render_duration_input()
      assert html =~ ~s(aria-label="Seconds")
    end

    test "show_hours=false hides hour input" do
      html = render_duration_input(%{show_hours: false})
      refute html =~ ~s(aria-label="Hours")
    end

    test "show_seconds=false hides second input" do
      html = render_duration_input(%{show_seconds: false})
      refute html =~ ~s(aria-label="Seconds")
    end

    test "renders hidden total-seconds input" do
      html = render_duration_input()
      assert html =~ ~s(type="hidden")
    end
  end

  describe "duration_input/1 — value parsing" do
    test "integer 3661 parses to 1:01:01" do
      html = render_duration_input(%{value: 3661})
      # 3661 = 1 hour, 1 minute, 1 second — hidden total shows 3661
      assert html =~ ~s(value="3661")
      assert html =~ ~s(aria-label="Hours")
    end

    test "string HH:MM:SS parses correctly" do
      html = render_duration_input(%{value: "02:30:15"})
      assert html =~ ~s(value="2")
      assert html =~ ~s(value="30")
      assert html =~ ~s(value="15")
    end

    test "zero value shows zero in all fields" do
      html = render_duration_input(%{value: 0})
      assert html =~ ~s(value="0")
    end

    test "hidden input has total seconds value" do
      html = render_duration_input(%{value: 90})
      assert html =~ ~s(value="90")
    end

    test "disabled inputs have disabled attribute" do
      html = render_duration_input(%{disabled: true})
      assert html =~ "disabled"
    end
  end

  # ---------------------------------------------------------------------------
  # split_input/1
  # ---------------------------------------------------------------------------

  describe "split_input/1 — structure" do
    test "renders phx-hook=PhiaSplitInput" do
      html = render_split_input()
      assert html =~ ~s(phx-hook="PhiaSplitInput")
    end

    test "renders slot inputs with data-slot attribute" do
      html = render_split_input()
      assert html =~ "data-slot"
    end

    test "renders three slot inputs" do
      html = render_split_input()
      count = html |> String.split("data-slot") |> length() |> Kernel.-(1)
      assert count == 3
    end

    test "renders hidden output input" do
      html = render_split_input()
      assert html =~ "data-split-output"
    end

    test "data-separator attr is set" do
      html = render_split_input(%{separator: "-"})
      assert html =~ ~s(data-separator="-")
    end

    test "renders slot placeholders" do
      html = render_split_input()
      assert html =~ ~s(placeholder="A")
      assert html =~ ~s(placeholder="B")
    end
  end

  describe "split_input_field/1" do
    test "renders text input" do
      html = render_component(&H.render_split_field/1, %{})
      assert html =~ ~s(type="text")
      assert html =~ ~s(maxlength="2")
      assert html =~ "data-slot"
    end
  end

  # ---------------------------------------------------------------------------
  # credit_card_input/1
  # ---------------------------------------------------------------------------

  describe "credit_card_input/1 — structure" do
    test "renders phx-hook=PhiaCreditCard" do
      html = render_credit_card_input()
      assert html =~ ~s(phx-hook="PhiaCreditCard")
    end

    test "renders card number input" do
      html = render_credit_card_input()
      assert html =~ "data-cc-number"
    end

    test "card number has inputmode=numeric" do
      html = render_credit_card_input()
      assert html =~ ~s(inputmode="numeric")
    end

    test "card number placeholder is 0000 0000 0000 0000" do
      html = render_credit_card_input()
      assert html =~ "0000 0000 0000 0000"
    end

    test "renders expiry input" do
      html = render_credit_card_input()
      assert html =~ "data-cc-expiry"
    end

    test "renders CVV input" do
      html = render_credit_card_input()
      assert html =~ "data-cc-cvv"
    end

    test "renders cardholder input by default" do
      html = render_credit_card_input()
      assert html =~ "data-cc-cardholder"
    end

    test "show_cardholder=false hides cardholder field" do
      html = render_credit_card_input(%{show_cardholder: false})
      refute html =~ "data-cc-cardholder"
    end

    test "renders Card Number label" do
      html = render_credit_card_input()
      assert html =~ "Card Number"
    end

    test "renders Expiry label" do
      html = render_credit_card_input()
      assert html =~ "Expiry"
    end

    test "renders CVV label" do
      html = render_credit_card_input()
      assert html =~ "CVV"
    end

    test "card number autocomplete=cc-number" do
      html = render_credit_card_input()
      assert html =~ ~s(autocomplete="cc-number")
    end
  end
end
