defmodule PhiaUi.Components.CtaCard do
  @moduledoc "Call-to-action card: illustration/icon + headline + description + CTA buttons."

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "CTA headline"
  attr :description, :string, default: nil, doc: "Optional supporting description"
  attr :variant, :atom, default: :default, values: [:default, :bordered, :filled, :minimal], doc: "Visual style variant"
  attr :align, :atom, default: :center, values: [:center, :start], doc: "Content alignment"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper element"

  slot :illustration, doc: "Optional illustration or icon above the title"
  slot :actions, doc: "CTA buttons or links"
  slot :footer, doc: "Optional footer content below the actions"

  @doc """
  Renders a call-to-action card with illustration, headline, description, and action buttons.

  ## Variants

  - `:default` — card with border and shadow
  - `:bordered` — border-2, no shadow
  - `:filled` — `bg-muted` background
  - `:minimal` — plain div wrapper, no card chrome

  ## Alignment

  - `:center` — text-center, items-center
  - `:start` — text-start, items-start

  ## Examples

      <.cta_card title="Get Started" description="Sign up for free today.">
        <:actions>
          <.button>Sign Up</.button>
        </:actions>
      </.cta_card>

      <.cta_card title="Upgrade" variant={:filled} align={:start}>
        <:illustration><.icon name="star" /></:illustration>
        <:actions>
          <.button>Upgrade Now</.button>
          <.button variant={:outline}>Learn More</.button>
        </:actions>
        <:footer><span class="text-xs text-muted-foreground">No credit card required</span></:footer>
      </.cta_card>
  """
  def cta_card(assigns) do
    ~H"""
    <%= if @variant == :minimal do %>
      <div class={cn(["flex flex-col gap-4 p-6", align_class(@align), @class])} {@rest}>
        {render_cta_inner(assigns)}
      </div>
    <% else %>
      <.card class={cn([variant_class(@variant), @class])} {@rest}>
        <.card_content class={cn(["pt-6 flex flex-col gap-4", align_class(@align)])}>
          {render_cta_inner(assigns)}
        </.card_content>
      </.card>
    <% end %>
    """
  end

  defp render_cta_inner(assigns) do
    ~H"""
    <div :if={@illustration != []} class="mb-2">
      {render_slot(@illustration)}
    </div>
    <div class="space-y-2">
      <h3 class="font-semibold text-lg leading-tight">{@title}</h3>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
    </div>
    <div :if={@actions != []} class="flex flex-wrap gap-3">
      {render_slot(@actions)}
    </div>
    <div :if={@footer != []}>
      {render_slot(@footer)}
    </div>
    """
  end

  defp variant_class(:default), do: "border shadow-sm bg-card"
  defp variant_class(:bordered), do: "border-2 bg-card"
  defp variant_class(:filled), do: "border bg-muted"
  defp variant_class(:minimal), do: ""

  defp align_class(:center), do: "text-center items-center"
  defp align_class(:start), do: "text-start items-start"
end
