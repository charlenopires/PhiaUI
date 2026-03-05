defmodule PhiaUi.Components.ReceiptCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ReceiptCard

    def render_basic(assigns) do
      ~H"""
      <.receipt_card>
        <:header>Payment Successful</:header>
        <:body>Details here</:body>
      </.receipt_card>
      """
    end

    def render_with_all_slots(assigns) do
      ~H"""
      <.receipt_card>
        <:header>$99.00</:header>
        <:body>
          <.receipt_row label="Date" value="2026-03-05" />
          <.receipt_row label="Method" value="Visa •••• 4242" />
        </:body>
        <:footer>QR Code area</:footer>
      </.receipt_card>
      """
    end

    def render_header_only(assigns) do
      ~H"""
      <.receipt_card>
        <:header>Header only</:header>
      </.receipt_card>
      """
    end

    def render_with_footer(assigns) do
      ~H"""
      <.receipt_card>
        <:header>Amount</:header>
        <:body>Row content</:body>
        <:footer>Scan QR</:footer>
      </.receipt_card>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.receipt_card class="my-receipt-class">
        <:header>Test</:header>
      </.receipt_card>
      """
    end

    def render_receipt_row(assigns) do
      ~H"""
      <.receipt_row label="Total" value="$50.00" />
      """
    end

    def render_receipt_row_custom_class(assigns) do
      ~H"""
      <.receipt_row label="Fee" value="$5.00" class="row-custom-class" />
      """
    end

    def render_multiple_rows(assigns) do
      ~H"""
      <.receipt_card>
        <:header>Receipt</:header>
        <:body>
          <.receipt_row label="Subtotal" value="$45.00" />
          <.receipt_row label="Tax" value="$5.00" />
          <.receipt_row label="Total" value="$50.00" />
        </:body>
      </.receipt_card>
      """
    end
  end

  describe "receipt_card/1" do
    test "renders a root element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders header slot content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Payment Successful"
    end

    test "renders body slot content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Details here"
    end

    test "renders footer slot content" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "Scan QR"
    end

    test "footer not rendered when slot is empty" do
      html = render_component(&H.render_header_only/1, %{})
      refute html =~ "Scan QR"
    end

    test "has perforated divider (border-dashed)" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "border-dashed"
    end

    test "has notch circles (rounded-full)" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "rounded-full"
    end

    test "divider has data-receipt-divider marker" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-receipt-divider"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-receipt-class"
    end

    test "renders all slots together" do
      html = render_component(&H.render_with_all_slots/1, %{})
      assert html =~ "$99.00"
      assert html =~ "Date"
      assert html =~ "2026-03-05"
      assert html =~ "QR Code area"
    end

    test "multiple receipt_rows render correctly" do
      html = render_component(&H.render_multiple_rows/1, %{})
      assert html =~ "Subtotal"
      assert html =~ "Tax"
      assert html =~ "Total"
    end
  end

  describe "receipt_row/1" do
    test "renders label text" do
      html = render_component(&H.render_receipt_row/1, %{})
      assert html =~ "Total"
    end

    test "renders value text" do
      html = render_component(&H.render_receipt_row/1, %{})
      assert html =~ "$50.00"
    end

    test "has justify-between layout" do
      html = render_component(&H.render_receipt_row/1, %{})
      assert html =~ "justify-between"
    end

    test "custom class applied" do
      html = render_component(&H.render_receipt_row_custom_class/1, %{})
      assert html =~ "row-custom-class"
    end

    test "label has muted-foreground style" do
      html = render_component(&H.render_receipt_row/1, %{})
      assert html =~ "muted-foreground"
    end
  end
end
