defmodule PhiaUi.Components.Glass do
  @moduledoc """
  Glass and frosted-surface components for PhiaUI — 5 components covering
  glassmorphism, acrylic noise textures, Apple Liquid Glass, and neon glow effects.

  All components use pure CSS backdrop-filter (no JS hooks required).

  ## Components
  - `glass_card/1` — backdrop-blur card with configurable opacity
  - `glass_panel/1` — wider glass panel for nav/sidebar overlays
  - `acrylic_surface/1` — Windows Acrylic with noise texture overlay
  - `liquid_glass/1` — Apple Liquid Glass 2025 style with prismatic border
  - `neon_glow_card/1` — colored neon box-shadow card
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 6. glass_card/1
  # ---------------------------------------------------------------------------

  attr :blur, :string, values: ~w(sm md lg xl), default: "md"
  attr :opacity, :string, values: ~w(light medium dark), default: "medium"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Glassmorphism card with configurable backdrop-blur and opacity.

  ## Examples

      <.glass_card blur="lg" opacity="light">
        Glass content
      </.glass_card>
  """
  def glass_card(assigns) do
    ~H"""
    <div
      class={cn([
        "rounded-xl border shadow-lg",
        glass_blur_class(@blur),
        glass_bg_class(@opacity),
        "border-white/20 dark:border-white/10",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 7. glass_panel/1
  # ---------------------------------------------------------------------------

  attr :blur, :string, values: ~w(sm md lg xl), default: "md"
  attr :opacity, :string, values: ~w(light medium dark), default: "medium"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Wide glass panel for nav/sidebar overlays, with more padding than glass_card.

  ## Examples

      <.glass_panel blur="xl" opacity="dark">
        Sidebar content
      </.glass_panel>
  """
  def glass_panel(assigns) do
    ~H"""
    <div
      class={cn([
        "rounded-2xl p-6 border",
        glass_blur_class(@blur),
        glass_bg_class(@opacity),
        "border-white/20 dark:border-white/10 shadow-lg",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp glass_blur_class("sm"), do: "backdrop-blur-sm"
  defp glass_blur_class("md"), do: "backdrop-blur-md"
  defp glass_blur_class("lg"), do: "backdrop-blur-lg"
  defp glass_blur_class("xl"), do: "backdrop-blur-xl"

  defp glass_bg_class("light"),  do: "bg-white/10 dark:bg-black/10"
  defp glass_bg_class("medium"), do: "bg-white/20 dark:bg-black/20"
  defp glass_bg_class("dark"),   do: "bg-white/40 dark:bg-black/40"

  # ---------------------------------------------------------------------------
  # 8. acrylic_surface/1
  # ---------------------------------------------------------------------------

  attr :blur, :string, values: ~w(sm md lg), default: "lg"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Windows Acrylic effect — backdrop-blur with subtle noise texture overlay.

  ## Examples

      <.acrylic_surface blur="md">
        Acrylic content
      </.acrylic_surface>
  """
  def acrylic_surface(assigns) do
    ~H"""
    <div
      class={cn([
        "relative overflow-hidden rounded-xl",
        "border border-white/20 dark:border-white/10",
        "bg-white/30 dark:bg-black/30",
        glass_blur_class(@blur),
        @class
      ])}
      {@rest}
    >
      <%!-- Noise overlay --%>
      <div
        class="absolute inset-0 pointer-events-none opacity-[0.03]"
        style="background-image: url(&quot;data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E&quot;); background-size: 128px 128px;"
      />
      <div class="relative z-10">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 9. liquid_glass/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Apple Liquid Glass 2025 — prismatic border wrapper with inset glow.

  ## Examples

      <.liquid_glass>
        Liquid glass content
      </.liquid_glass>
  """
  def liquid_glass(assigns) do
    ~H"""
    <%!-- Prismatic border wrapper --%>
    <div class={cn(["bg-gradient-to-br from-white/40 via-white/5 to-transparent p-px rounded-2xl", @class])}>
      <div
        class={cn([
          "backdrop-blur-xl rounded-2xl",
          "bg-white/15 dark:bg-white/8",
          "border border-white/30 dark:border-white/20"
        ])}
        style="box-shadow: inset 0 1px 0 0 rgb(255 255 255 / 0.3), inset 0 -1px 0 0 rgb(255 255 255 / 0.1), 0 20px 25px -5px rgb(0 0 0 / 0.1);"
        {@rest}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 10. neon_glow_card/1
  # ---------------------------------------------------------------------------

  attr :color, :string, values: ~w(purple blue green pink cyan orange), default: "purple"
  attr :intensity, :string, values: ~w(sm md lg), default: "md"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Neon glow card with color-matched box-shadow.

  ## Examples

      <.neon_glow_card color="blue" intensity="lg">
        Neon content
      </.neon_glow_card>
  """
  def neon_glow_card(assigns) do
    ~H"""
    <div
      class={cn(["bg-card rounded-xl border border-border", @class])}
      style={neon_shadow(@color, @intensity)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp neon_shadow("purple", "sm"),  do: "box-shadow: 0 0 10px rgb(168 85 247 / 0.3), 0 0 20px rgb(168 85 247 / 0.1), inset 0 0 20px rgb(168 85 247 / 0.03);"
  defp neon_shadow("purple", "md"),  do: "box-shadow: 0 0 20px rgb(168 85 247 / 0.4), 0 0 40px rgb(168 85 247 / 0.2), inset 0 0 40px rgb(168 85 247 / 0.05);"
  defp neon_shadow("purple", "lg"),  do: "box-shadow: 0 0 30px rgb(168 85 247 / 0.6), 0 0 60px rgb(168 85 247 / 0.3), inset 0 0 60px rgb(168 85 247 / 0.08);"
  defp neon_shadow("blue", "sm"),    do: "box-shadow: 0 0 10px rgb(59 130 246 / 0.3), 0 0 20px rgb(59 130 246 / 0.1), inset 0 0 20px rgb(59 130 246 / 0.03);"
  defp neon_shadow("blue", "md"),    do: "box-shadow: 0 0 20px rgb(59 130 246 / 0.4), 0 0 40px rgb(59 130 246 / 0.2), inset 0 0 40px rgb(59 130 246 / 0.05);"
  defp neon_shadow("blue", "lg"),    do: "box-shadow: 0 0 30px rgb(59 130 246 / 0.6), 0 0 60px rgb(59 130 246 / 0.3), inset 0 0 60px rgb(59 130 246 / 0.08);"
  defp neon_shadow("green", "sm"),   do: "box-shadow: 0 0 10px rgb(34 197 94 / 0.3), 0 0 20px rgb(34 197 94 / 0.1), inset 0 0 20px rgb(34 197 94 / 0.03);"
  defp neon_shadow("green", "md"),   do: "box-shadow: 0 0 20px rgb(34 197 94 / 0.4), 0 0 40px rgb(34 197 94 / 0.2), inset 0 0 40px rgb(34 197 94 / 0.05);"
  defp neon_shadow("green", "lg"),   do: "box-shadow: 0 0 30px rgb(34 197 94 / 0.6), 0 0 60px rgb(34 197 94 / 0.3), inset 0 0 60px rgb(34 197 94 / 0.08);"
  defp neon_shadow("pink", "sm"),    do: "box-shadow: 0 0 10px rgb(236 72 153 / 0.3), 0 0 20px rgb(236 72 153 / 0.1), inset 0 0 20px rgb(236 72 153 / 0.03);"
  defp neon_shadow("pink", "md"),    do: "box-shadow: 0 0 20px rgb(236 72 153 / 0.4), 0 0 40px rgb(236 72 153 / 0.2), inset 0 0 40px rgb(236 72 153 / 0.05);"
  defp neon_shadow("pink", "lg"),    do: "box-shadow: 0 0 30px rgb(236 72 153 / 0.6), 0 0 60px rgb(236 72 153 / 0.3), inset 0 0 60px rgb(236 72 153 / 0.08);"
  defp neon_shadow("cyan", "sm"),    do: "box-shadow: 0 0 10px rgb(6 182 212 / 0.3), 0 0 20px rgb(6 182 212 / 0.1), inset 0 0 20px rgb(6 182 212 / 0.03);"
  defp neon_shadow("cyan", "md"),    do: "box-shadow: 0 0 20px rgb(6 182 212 / 0.4), 0 0 40px rgb(6 182 212 / 0.2), inset 0 0 40px rgb(6 182 212 / 0.05);"
  defp neon_shadow("cyan", "lg"),    do: "box-shadow: 0 0 30px rgb(6 182 212 / 0.6), 0 0 60px rgb(6 182 212 / 0.3), inset 0 0 60px rgb(6 182 212 / 0.08);"
  defp neon_shadow("orange", "sm"),  do: "box-shadow: 0 0 10px rgb(249 115 22 / 0.3), 0 0 20px rgb(249 115 22 / 0.1), inset 0 0 20px rgb(249 115 22 / 0.03);"
  defp neon_shadow("orange", "md"),  do: "box-shadow: 0 0 20px rgb(249 115 22 / 0.4), 0 0 40px rgb(249 115 22 / 0.2), inset 0 0 40px rgb(249 115 22 / 0.05);"
  defp neon_shadow("orange", "lg"),  do: "box-shadow: 0 0 30px rgb(249 115 22 / 0.6), 0 0 60px rgb(249 115 22 / 0.3), inset 0 0 60px rgb(249 115 22 / 0.08);"
end
