defmodule PhiaUi.Components.TestimonialCard do
  @moduledoc """
  TestimonialCard — a customer quote card with author info, optional star rating,
  and three layout variants.

  ## Variants

  | Variant     | Description                           |
  |-------------|---------------------------------------|
  | `:default`  | `.card` wrapper with shadow-sm        |
  | `:bordered` | `.card` wrapper with border-2         |
  | `:minimal`  | Plain div, no card chrome             |

  ## Examples

      <.testimonial_card
        quote="Phia UI saved us weeks of work."
        author_name="Jane Doe"
        author_role="CTO"
        rating={5}
      />

      <.testimonial_card
        quote="Minimal and clean."
        author_name="Bob"
        variant={:minimal}
      />
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Avatar
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :quote, :string, required: true, doc: "The testimonial quote text"
  attr :author_name, :string, required: true, doc: "Author's full name"
  attr :author_role, :string, default: nil, doc: "Author's job title"
  attr :author_src, :string, default: nil, doc: "Author avatar image URL"
  attr :company, :string, default: nil, doc: "Company name"
  attr :rating, :integer, default: nil, doc: "Star rating 1–5; nil = no stars"

  attr :variant, :atom,
    default: :default,
    values: [:default, :bordered, :minimal],
    doc: "Visual variant"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the outer element"

  @doc """
  Renders a testimonial card.
  """
  def testimonial_card(assigns) do
    ~H"""
    <%= if @variant == :minimal do %>
      <div class={cn(["flex flex-col gap-4", @class])} {@rest}>
        {render_testimonial_body(assigns)}
      </div>
    <% else %>
      <.card class={cn([variant_card_class(@variant), @class])} {@rest}>
        <.card_content class="pt-6 flex flex-col gap-4">
          {render_testimonial_body(assigns)}
        </.card_content>
      </.card>
    <% end %>
    """
  end

  defp render_testimonial_body(assigns) do
    ~H"""
    <%!-- Stars --%>
    <div :if={@rating != nil} class="flex gap-0.5 text-amber-400">
      {render_stars(@rating)}
    </div>

    <%!-- Decorative quote mark --%>
    <div class="text-6xl leading-none text-muted-foreground/20 font-serif select-none">"</div>

    <%!-- Quote text --%>
    <p class="italic text-base text-foreground">{@quote}</p>

    <%!-- Author row --%>
    <div class="flex items-center gap-3 mt-2">
      <.avatar :if={@author_src} size="sm">
        <.avatar_image src={@author_src} alt={@author_name} />
        <.avatar_fallback name={@author_name} />
      </.avatar>
      <div>
        <p class="font-semibold text-sm">{@author_name}</p>
        <p :if={@author_role || @company} class="text-xs text-muted-foreground">
          {[@author_role, @company] |> Enum.filter(& &1) |> Enum.join(", ")}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp variant_card_class(:default), do: "shadow-sm"
  defp variant_card_class(:bordered), do: "border-2 shadow-none"

  defp render_stars(rating) when rating >= 1 and rating <= 5 do
    filled = List.duplicate(star_filled(), rating)
    empty = List.duplicate(star_empty(), 5 - rating)

    (filled ++ empty)
    |> Enum.map_join("", & &1)
  end

  defp render_stars(_), do: ""

  defp star_filled, do: "★"
  defp star_empty, do: "☆"
end
