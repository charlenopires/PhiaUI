defmodule PhiaUi.Components.FeatureCard do
  @moduledoc "Icon + title + description — the standard landing page feature block."

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Feature title"
  attr :description, :string, default: nil, doc: "Optional supporting description"
  attr :variant, :atom, default: :default, values: [:default, :bordered, :ghost], doc: "Visual style variant"
  attr :icon_position, :atom, default: :top, values: [:top, :left], doc: "Position of the icon relative to text"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper element"

  slot :icon, doc: "Optional icon content"
  slot :inner_block, doc: "Optional extra content below description"

  @doc """
  Renders a feature card with an icon, title, description, and optional extra content.

  ## Variants

  - `:default` — card with border and shadow
  - `:bordered` — stronger border-2, no shadow
  - `:ghost` — no border, no shadow (plain div wrapper)

  ## Icon positions

  - `:top` — icon stacked above the title (flex-col)
  - `:left` — icon to the left of title + description (flex-row)

  ## Examples

      <.feature_card title="Fast" description="Blazing fast performance">
        <:icon><.icon name="zap" /></:icon>
      </.feature_card>

      <.feature_card title="Secure" variant={:bordered} icon_position={:left}>
        <:icon><.icon name="shield" /></:icon>
      </.feature_card>
  """
  def feature_card(assigns) do
    ~H"""
    <%= if @variant == :ghost do %>
      <div class={cn(["p-6", variant_class(@variant), layout_class(@icon_position), @class])} {@rest}>
        {render_feature_inner(assigns)}
      </div>
    <% else %>
      <.card class={cn([variant_class(@variant), @class])} {@rest}>
        <.card_content class={cn(["pt-6", layout_class(@icon_position)])}>
          {render_feature_inner(assigns)}
        </.card_content>
      </.card>
    <% end %>
    """
  end

  defp render_feature_inner(assigns) do
    ~H"""
    <div :if={@icon != []} class={cn(["shrink-0", icon_wrapper_class(@icon_position)])}>
      {render_slot(@icon)}
    </div>
    <div class={text_block_class(@icon_position)}>
      <h3 class="font-semibold leading-none tracking-tight mb-2">{@title}</h3>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <div :if={@inner_block != []} class="mt-3">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp variant_class(:default), do: "border shadow-sm"
  defp variant_class(:bordered), do: "border-2"
  defp variant_class(:ghost), do: "border-0 shadow-none"

  defp layout_class(:top), do: "flex flex-col gap-3"
  defp layout_class(:left), do: "flex flex-row gap-4"

  defp icon_wrapper_class(:top), do: "mb-1"
  defp icon_wrapper_class(:left), do: "mt-1"

  defp text_block_class(:top), do: ""
  defp text_block_class(:left), do: "flex-1"
end
