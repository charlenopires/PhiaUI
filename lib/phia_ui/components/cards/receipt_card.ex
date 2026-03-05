defmodule PhiaUi.Components.ReceiptCard do
  @moduledoc """
  Ticket/receipt styled card with a perforated CSS divider.

  Mimics a physical receipt or ticket: a card with a header section (amount,
  status), a perforated divider (dashed border + side notches), a body section
  (rows of label/value pairs), and an optional footer (QR code, action).

  ## Sub-components

  | Component       | Purpose                                             |
  |-----------------|-----------------------------------------------------|
  | `receipt_card/1` | Outer card with header, divider, body, footer slots |
  | `receipt_row/1`  | Single label/value row for the body section         |

  ## How the perforated divider works

  Two `rounded-full` circles (colored `bg-background`) are positioned
  half-inside, half-outside the card at each end of the dashed horizontal line.
  The circles visually "punch through" the card border, simulating the
  tear-perforations on a physical ticket. No JavaScript — pure CSS.

  ## Examples

      <%!-- Payment receipt --%>
      <.receipt_card>
        <:header>
          <div class="text-center">
            <p class="text-muted-foreground text-sm">Amount paid</p>
            <p class="text-4xl font-bold">$99.00</p>
          </div>
        </:header>
        <:body>
          <.receipt_row label="Date" value="March 5, 2026" />
          <.receipt_row label="Method" value="Visa •••• 4242" />
          <.receipt_row label="Reference" value="TXN-8821" />
        </:body>
        <:footer>
          <div class="flex justify-center">
            <%!-- QR code component or image --%>
          </div>
        </:footer>
      </.receipt_card>

      <%!-- Ticket / voucher --%>
      <.receipt_card class="max-w-sm">
        <:header>
          <h2 class="text-lg font-semibold">VIP Access Pass</h2>
        </:header>
        <:body>
          <.receipt_row label="Event" value="ElixirConf 2026" />
          <.receipt_row label="Seat" value="A-14" />
        </:body>
      </.receipt_card>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # receipt_card/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:header,
    required: true,
    doc: "Top section — amount, status badge, title, etc."
  )

  slot(:body,
    doc: "Middle section — typically a list of `receipt_row/1` components."
  )

  slot(:footer,
    doc: "Bottom section — QR code, barcode, or a call-to-action button."
  )

  @doc """
  Renders a receipt/ticket card with a perforated divider.

  ## Example

      <.receipt_card>
        <:header>$49.00</:header>
        <:body>
          <.receipt_row label="Plan" value="Pro" />
        </:body>
      </.receipt_card>
  """
  def receipt_card(assigns) do
    ~H"""
    <div class={cn(["relative w-full rounded-2xl border border-border bg-card shadow-sm", @class])} {@rest}>
      <%!-- Header section --%>
      <div class="p-6">
        {render_slot(@header)}
      </div>

      <%!-- Perforated divider: dashed line + side notch circles --%>
      <div class="relative flex items-center" data-receipt-divider>
        <span class="absolute left-0 h-5 w-5 -translate-x-1/2 rounded-full border border-border bg-background" />
        <div class="mx-2.5 flex-1 border-t-2 border-dashed border-border" />
        <span class="absolute right-0 h-5 w-5 translate-x-1/2 rounded-full border border-border bg-background" />
      </div>

      <%!-- Body section --%>
      <div :if={@body != []} class="p-6">
        {render_slot(@body)}
      </div>

      <%!-- Footer section (optional) --%>
      <div :if={@footer != []} class="border-t border-border px-6 pb-6 pt-4">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # receipt_row/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Row label (left-aligned, muted foreground).")
  attr(:value, :string, required: true, doc: "Row value (right-aligned, medium weight).")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the row element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the row `<div>` element.")

  @doc """
  Renders a single label/value row for use inside a `receipt_card/1` body slot.

  ## Example

      <.receipt_row label="Order ID" value="#8812-XZ" />
  """
  def receipt_row(assigns) do
    ~H"""
    <div class={cn(["flex items-center justify-between py-1.5", @class])} {@rest}>
      <span class="text-sm text-muted-foreground">{@label}</span>
      <span class="text-sm font-medium">{@value}</span>
    </div>
    """
  end
end
