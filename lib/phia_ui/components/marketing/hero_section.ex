defmodule PhiaUi.Components.Marketing.HeroSection do
  @moduledoc """
  Structured hero section with heading, subheading, CTA buttons, and optional media.

  Distinct from `cover` (which is a background media wrapper). HeroSection
  is a structured content section with explicit heading/description/actions layout.

  ## Layouts

  | Layout     | Description                                    |
  |------------|------------------------------------------------|
  | `:stacked` | Content centered/stacked vertically (default)  |
  | `:split`   | Content left, media right (two columns)        |

  ## Examples

      <.hero_section title="Build faster with PhiaUI" description="623 components ready to use.">
        <:actions>
          <.button size={:lg}>Get Started</.button>
          <.button variant={:outline} size={:lg}>Learn More</.button>
        </:actions>
      </.hero_section>

      <.hero_section title="Ship products faster" layout={:split}>
        <:media>
          <img src="/images/hero.png" alt="Product screenshot" />
        </:media>
        <:actions>
          <.button>Try Free</.button>
        </:actions>
      </.hero_section>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :align, :atom, values: [:center, :start], default: :center
  attr :layout, :atom, values: [:stacked, :split], default: :stacked
  attr :size, :atom, values: [:sm, :default, :lg], default: :default
  attr :class, :string, default: nil
  attr :rest, :global

  slot :actions, doc: "CTA buttons"
  slot :media, doc: "Optional image/video/illustration"
  slot :badge, doc: "Optional top badge"
  slot :inner_block, doc: "Additional content"

  @doc "Renders a structured hero section with heading, description, actions, and optional media."
  def hero_section(assigns) do
    ~H"""
    <section
      class={cn([
        "w-full",
        @layout == :split && "grid items-center gap-12 lg:grid-cols-2",
        @layout == :stacked && "flex flex-col items-center",
        @class
      ])}
      {@rest}
    >
      <div class={cn([
        "flex flex-col gap-6",
        @layout == :stacked && align_class(@align),
        @layout == :stacked && "max-w-3xl"
      ])}>
        <%= for badge <- @badge do %>
          <div>{render_slot(badge)}</div>
        <% end %>

        <h1 class={cn([title_size(@size), "font-bold tracking-tight text-foreground"])}>
          {@title}
        </h1>

        <%= if @description do %>
          <p class={cn([desc_size(@size), "text-muted-foreground", @layout == :stacked && "max-w-2xl"])}>
            {@description}
          </p>
        <% end %>

        <%= for actions <- @actions do %>
          <div class={cn(["flex flex-wrap gap-3", @align == :center && @layout == :stacked && "justify-center"])}>
            {render_slot(actions)}
          </div>
        <% end %>

        {render_slot(@inner_block)}
      </div>

      <%= for media <- @media do %>
        <div class={cn(["w-full", @layout == :stacked && "mt-8"])}>
          {render_slot(media)}
        </div>
      <% end %>
    </section>
    """
  end

  defp align_class(:center), do: "items-center text-center"
  defp align_class(:start), do: "items-start text-left"

  defp title_size(:sm), do: "text-3xl sm:text-4xl"
  defp title_size(:default), do: "text-4xl sm:text-5xl lg:text-6xl"
  defp title_size(:lg), do: "text-5xl sm:text-6xl lg:text-7xl"

  defp desc_size(:sm), do: "text-base"
  defp desc_size(:default), do: "text-lg sm:text-xl"
  defp desc_size(:lg), do: "text-xl sm:text-2xl"
end
