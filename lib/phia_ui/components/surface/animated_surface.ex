defmodule PhiaUi.Components.AnimatedSurface do
  @moduledoc """
  Animated surface components for PhiaUI — 5 components covering rotating
  border beams, shine effects, cursor-tracked gradients, spotlights, and
  moving gradient borders.

  JS hooks required: `PhiaMagicCard`, `PhiaCardSpotlight`.

  ## Components
  - `border_beam/1` — rotating conic-gradient border animation (pure CSS)
  - `shine_border/1` — rotating shine overlay animation (pure CSS)
  - `magic_card/1` — cursor-tracked radial gradient (requires PhiaMagicCard hook)
  - `card_spotlight/1` — cursor spotlight overlay (requires PhiaCardSpotlight hook)
  - `moving_border/1` — animated gradient border (pure CSS)
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 11. border_beam/1
  # ---------------------------------------------------------------------------

  attr :duration, :integer, default: 8
  attr :color_from, :string, default: "#ffaa40"
  attr :color_to, :string, default: "#9c40ff"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Rotating conic-gradient border beam animation. Pure CSS using @keyframes
  phia-border-beam defined in theme.css.

  ## Examples

      <.border_beam duration={6} color_from="#00ff88" color_to="#0088ff">
        Content inside the beam border
      </.border_beam>
  """
  def border_beam(assigns) do
    ~H"""
    <div
      class={cn(["relative overflow-hidden rounded-xl", @class])}
      {@rest}
    >
      <%!-- Rotating beam layer --%>
      <div
        class="absolute inset-0 rounded-xl"
        style={"background: conic-gradient(from calc(var(--angle, 0) * 1turn), transparent 0%, #{@color_from} 5%, #{@color_to} 10%, transparent 15%); animation: phia-border-beam #{@duration}s linear infinite;"}
      />
      <%!-- Content sits on top with a 1px inset --%>
      <div class="relative z-10 m-px rounded-xl bg-card">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 12. shine_border/1
  # ---------------------------------------------------------------------------

  attr :shine_color, :string, default: "#ffffff"
  attr :duration, :integer, default: 6
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Rotating shine overlay border animation. Pure CSS.

  ## Examples

      <.shine_border shine_color="#gold" duration={4}>
        Shiny content
      </.shine_border>
  """
  def shine_border(assigns) do
    ~H"""
    <div
      class={cn(["relative rounded-xl overflow-hidden bg-card", @class])}
      {@rest}
    >
      <%!-- Rotating shine element --%>
      <div
        class="absolute inset-[-100%] pointer-events-none"
        style={"background: conic-gradient(from 0deg, transparent 0%, #{@shine_color} 10%, transparent 20%); animation: phia-shine-border #{@duration}s linear infinite; opacity: 0.6;"}
      />
      <%!-- Content above shine --%>
      <div class="relative z-10 m-px rounded-xl bg-card">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 13. magic_card/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :gradient_color, :string, default: "#262626"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Cursor-tracked radial gradient card. Requires PhiaMagicCard JS hook.

  The hook reads `data-gradient-color` and tracks mousemove to apply a
  radial-gradient to the `[data-magic-overlay]` child div.

  ## Examples

      <.magic_card id="feature-card" gradient_color="#1a1a2e">
        Feature content
      </.magic_card>
  """
  def magic_card(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaMagicCard"
      data-gradient-color={@gradient_color}
      class={cn([
        "group relative rounded-xl bg-card border border-border overflow-hidden cursor-pointer",
        @class
      ])}
      {@rest}
    >
      <%!-- Overlay for the cursor-tracked gradient --%>
      <div data-magic-overlay class="pointer-events-none absolute inset-0 z-0 transition-opacity duration-300" />
      <%!-- Content sits above overlay --%>
      <div class="relative z-10">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 14. card_spotlight/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :color, :string, default: "rgba(255,255,255,0.1)"
  attr :size, :integer, default: 300
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Cursor-following spotlight overlay card. Requires PhiaCardSpotlight JS hook.

  The hook reads `data-size` and `data-color`, tracking mousemove to apply a
  radial-gradient spotlight to the `[data-spotlight-overlay]` child div.

  ## Examples

      <.card_spotlight id="spotlight-card" color="rgba(120,80,255,0.15)" size={400}>
        Card content with spotlight
      </.card_spotlight>
  """
  def card_spotlight(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCardSpotlight"
      data-size={@size}
      data-color={@color}
      class={cn([
        "relative rounded-xl bg-card border border-border overflow-hidden",
        @class
      ])}
      {@rest}
    >
      <%!-- Spotlight overlay --%>
      <div data-spotlight-overlay class="pointer-events-none absolute inset-0 z-0" />
      <%!-- Content sits above spotlight --%>
      <div class="relative z-10">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 15. moving_border/1
  # ---------------------------------------------------------------------------

  attr :duration, :integer, default: 4
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Animated shifting gradient border. Pure CSS using @keyframes phia-moving-border.

  ## Examples

      <.moving_border duration={6}>
        Animated border content
      </.moving_border>
  """
  def moving_border(assigns) do
    ~H"""
    <div
      class={cn(["relative overflow-hidden rounded-xl p-px", @class])}
      {@rest}
    >
      <%!-- Animated gradient border background --%>
      <div
        class="absolute inset-0 rounded-xl"
        style={"background: linear-gradient(270deg, var(--color-primary), var(--color-destructive), var(--color-primary)); background-size: 400% 400%; animation: phia-moving-border #{@duration}s ease infinite;"}
      />
      <%!-- Inner content container --%>
      <div class="relative bg-card rounded-xl w-full h-full">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
