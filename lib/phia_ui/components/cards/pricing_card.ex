defmodule PhiaUi.Components.PricingCard do
  @moduledoc """
  Pricing plan card for displaying subscription tiers.

  Shows a plan name, price, feature list with availability indicators,
  and a call-to-action button. Supports an optional highlighted state
  for featured/recommended plans.
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Badge
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.Components.Button, only: [button: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :plan, :string, required: true, doc: "Plan name (e.g. 'Pro', 'Enterprise')"
  attr :price, :string, required: true, doc: "Price string (e.g. '$29')"
  attr :period, :string, default: "/month", doc: "Billing period label"
  attr :description, :string, default: nil, doc: "Short plan description"

  attr :features, :list,
    default: [],
    doc: "List of feature strings. Prefix '—' marks unavailable features."

  attr :highlighted, :boolean, default: false, doc: "Highlight as recommended/featured plan"
  attr :badge, :string, default: nil, doc: "Optional badge label above plan name"
  attr :cta_label, :string, default: "Get started", doc: "Call-to-action button label"
  attr :cta_href, :string, default: nil, doc: "Optional href for CTA button"
  attr :disabled, :boolean, default: false, doc: "Disable the CTA button"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the card element"

  slot :header_extra, doc: "Extra content rendered below the price"
  slot :footer, doc: "Content rendered below the CTA button"

  @doc "Renders a pricing plan card."
  def pricing_card(assigns) do
    ~H"""
    <.card
      class={cn([highlighted_class(@highlighted), @class])}
      {@rest}
    >
      <.card_header>
        <.badge :if={@badge} variant={:default} class="mb-2 w-fit">{@badge}</.badge>
        <.card_title class="text-lg font-bold">{@plan}</.card_title>
        <div class="flex items-baseline gap-1 mt-2">
          <span class="text-4xl font-bold">{@price}</span>
          <span class="text-sm text-muted-foreground">{@period}</span>
        </div>
        <.card_description :if={@description}>{@description}</.card_description>
        <div :if={@header_extra != []} class="mt-2">
          {render_slot(@header_extra)}
        </div>
      </.card_header>

      <.card_content class="pt-0">
        <hr class="border-border mb-4" />

        <ul class="space-y-2 mb-6">
          <li :for={feature <- @features} class="flex items-center gap-2 text-sm">
            <span :if={feature_available(feature)}>
              <.icon name="check-circle" size={:sm} class="text-emerald-500 shrink-0" />
            </span>
            <span :if={!feature_available(feature)} class="text-muted-foreground shrink-0">—</span>
            <span class={cn([!feature_available(feature) && "text-muted-foreground"])}>
              {feature_text(feature)}
            </span>
          </li>
        </ul>

        <a :if={@cta_href} href={@cta_href} class="block">
          <.button class="w-full" disabled={@disabled}>{@cta_label}</.button>
        </a>
        <.button :if={!@cta_href} class="w-full" disabled={@disabled}>{@cta_label}</.button>
      </.card_content>

      <.card_footer :if={@footer != []} class="pt-0">
        {render_slot(@footer)}
      </.card_footer>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp highlighted_class(true), do: "ring-2 ring-primary bg-primary/5"
  defp highlighted_class(false), do: nil

  defp feature_available("—" <> _rest), do: false
  defp feature_available(_), do: true

  defp feature_text("—" <> rest), do: String.trim(rest)
  defp feature_text(text), do: text
end
