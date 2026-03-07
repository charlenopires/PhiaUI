defmodule PhiaUi.Components.FancyButton do
  @moduledoc """
  Visually enhanced button variants for hero sections, landing pages, and
  attention-grabbing CTAs.

  Exports four components:

  - `gradient_button/1` — multi-color gradient backgrounds
  - `shimmer_button/1` — animated shimmer sweep effect
  - `glow_button/1` — colored box-shadow glow ring
  - `pulse_button/1` — animated ping ring around the button

  ## Notes

  - `gradient_button` always uses `text-white` regardless of gradient — never
    uses `bg-clip-text` (this is a background gradient, not gradient text).
  - `glow_button` applies `box-shadow` via inline `style` to avoid the cn/1
    shadow group conflict (same pattern as `liquid_glass`).
  - `shimmer_button` uses inline `style` on the shimmer span to keep the
    animation out of the cn/1 bg group.
  - `pulse_button` uses Tailwind's built-in `animate-ping` — no new keyframe
    is needed.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # gradient_button/1
  # ---------------------------------------------------------------------------

  attr :gradient, :atom,
    values: [:primary, :sunset, :ocean, :forest, :aurora, :monochrome],
    default: :primary,
    doc: "Gradient color preset"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Button label"
  slot :left_icon, doc: "Icon rendered to the left of the label"
  slot :right_icon, doc: "Icon rendered to the right of the label"

  @doc """
  Renders a button with a gradient background.

  The text color is always `text-white`. Gradient variants:

  | Gradient      | Colors                        |
  |---------------|-------------------------------|
  | `:primary`    | primary → primary/70          |
  | `:sunset`     | orange-500 → rose-500         |
  | `:ocean`      | blue-500 → cyan-400           |
  | `:forest`     | green-600 → emerald-400       |
  | `:aurora`     | violet-500 → indigo-500       |
  | `:monochrome` | gray-900 → gray-600           |
  """
  def gradient_button(assigns) do
    assigns = assign(assigns, :has_icon, assigns.left_icon != [] or assigns.right_icon != [])

    ~H"""
    <button
      type="button"
      class={cn([
        button_base(),
        gradient_class(@gradient),
        size_class(@size),
        "text-white shadow hover:opacity-90",
        @has_icon && "gap-2",
        (@disabled or @loading) && "pointer-events-none opacity-50",
        @class
      ])}
      disabled={@disabled}
      aria-busy={@loading && "true"}
      {@rest}
    >
      <%= if @loading do %>
        <svg
          class="animate-spin h-4 w-4"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
      <% end %>
      <%= if @left_icon != [] do %>
        <%= render_slot(@left_icon) %>
      <% end %>
      <%= render_slot(@inner_block) %>
      <%= if @right_icon != [] do %>
        <%= render_slot(@right_icon) %>
      <% end %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # shimmer_button/1
  # ---------------------------------------------------------------------------

  attr :variant, :atom,
    values: [:dark, :light, :primary],
    default: :dark,
    doc: "Button color — controls background and shimmer contrast"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Button label"

  @doc """
  Renders a button with an animated shimmer sweep.

  The shimmer is a diagonal light pass animated with `phia-shimmer-pass`
  (defined in `theme.css`). The animation is applied via inline `style` on
  a `pointer-events-none` overlay span to avoid cn/1 bg-group conflicts.
  """
  def shimmer_button(assigns) do
    ~H"""
    <button
      type="button"
      class={cn([
        button_base(),
        shimmer_bg_class(@variant),
        size_class(@size),
        "relative overflow-hidden",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      disabled={@disabled}
      {@rest}
    >
      <%!-- Shimmer overlay — inline style keeps it out of cn/1 bg group --%>
      <span aria-hidden="true" class="absolute inset-0 overflow-hidden rounded-[inherit] pointer-events-none">
        <span
          aria-hidden="true"
          style={shimmer_span_style(@variant)}
        ></span>
      </span>
      <%!-- Label — rendered above shimmer via z-index stack --%>
      <span class="relative z-10">
        <%= render_slot(@inner_block) %>
      </span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # glow_button/1
  # ---------------------------------------------------------------------------

  attr :color, :atom,
    values: [:primary, :blue, :purple, :green, :red, :orange, :pink],
    default: :primary,
    doc: "Glow color — sets border color and box-shadow hue"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :glow_intensity, :atom,
    values: [:subtle, :normal, :intense],
    default: :normal,
    doc: "Glow spread — :subtle, :normal, or :intense"

  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Button label"

  @doc """
  Renders a button with a colored glow ring via `box-shadow`.

  The glow is applied via inline `style` to avoid cn/1 shadow group conflicts
  (same pattern as `liquid_glass`). The border matches the glow color.
  """
  def glow_button(assigns) do
    ~H"""
    <button
      type="button"
      class={cn([
        button_base(),
        glow_border_class(@color),
        size_class(@size),
        "bg-background text-foreground",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      style={"box-shadow: #{glow_shadow(@color, @glow_intensity)};"}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # pulse_button/1
  # ---------------------------------------------------------------------------

  attr :color, :atom,
    values: [:primary, :destructive, :success, :warning],
    default: :primary,
    doc: "Color of both the button and the ping ring"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :pulse, :boolean,
    default: true,
    doc: "When true, shows the animate-ping ring around the button"

  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Button label"

  @doc """
  Renders a button with an animated ping ring.

  Uses Tailwind's built-in `animate-ping` — no custom keyframe needed.
  The wrapper `<div>` is `relative inline-flex` to position the ping span.
  """
  def pulse_button(assigns) do
    ~H"""
    <div class="relative inline-flex">
      <%= if @pulse do %>
        <span
          class={cn([
            "absolute inset-0 rounded-md animate-ping opacity-75",
            ping_color_class(@color)
          ])}
          aria-hidden="true"
        ></span>
      <% end %>
      <button
        type="button"
        class={cn([
          button_base(),
          pulse_color_class(@color),
          size_class(@size),
          "relative",
          (@disabled or not @pulse) && "",
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        disabled={@disabled}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — shared
  # ---------------------------------------------------------------------------

  defp button_base do
    "inline-flex items-center justify-center whitespace-nowrap rounded-md " <>
      "text-sm font-medium ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp size_class(:sm), do: "h-9 rounded-md px-3"
  defp size_class(:default), do: "h-10 px-4 py-2"
  defp size_class(:lg), do: "h-11 rounded-md px-8"

  # ---------------------------------------------------------------------------
  # gradient_button helpers
  # ---------------------------------------------------------------------------

  defp gradient_class(:primary), do: "bg-gradient-to-r from-primary to-primary/70"
  defp gradient_class(:sunset), do: "bg-gradient-to-r from-orange-500 to-rose-500"
  defp gradient_class(:ocean), do: "bg-gradient-to-r from-blue-500 to-cyan-400"
  defp gradient_class(:forest), do: "bg-gradient-to-r from-green-600 to-emerald-400"
  defp gradient_class(:aurora), do: "bg-gradient-to-r from-violet-500 to-indigo-500"
  defp gradient_class(:monochrome), do: "bg-gradient-to-r from-gray-900 to-gray-600"

  # ---------------------------------------------------------------------------
  # shimmer_button helpers
  # ---------------------------------------------------------------------------

  defp shimmer_bg_class(:dark), do: "bg-zinc-900 text-white"
  defp shimmer_bg_class(:light), do: "bg-white text-zinc-900 border border-zinc-200"
  defp shimmer_bg_class(:primary), do: "bg-primary text-primary-foreground"

  defp shimmer_span_style(:light) do
    "position:absolute;top:0;left:-100%;width:60%;height:100%;" <>
      "background:linear-gradient(90deg,transparent,rgba(255,255,255,0.6),transparent);" <>
      "animation:phia-shimmer-pass 2s ease-in-out infinite;"
  end

  defp shimmer_span_style(_) do
    "position:absolute;top:0;left:-100%;width:60%;height:100%;" <>
      "background:linear-gradient(90deg,transparent,rgba(255,255,255,0.25),transparent);" <>
      "animation:phia-shimmer-pass 2s ease-in-out infinite;"
  end

  # ---------------------------------------------------------------------------
  # glow_button helpers
  # ---------------------------------------------------------------------------

  defp glow_border_class(:primary), do: "border border-primary/50"
  defp glow_border_class(:blue), do: "border border-blue-500/50"
  defp glow_border_class(:purple), do: "border border-purple-500/50"
  defp glow_border_class(:green), do: "border border-green-500/50"
  defp glow_border_class(:red), do: "border border-red-500/50"
  defp glow_border_class(:orange), do: "border border-orange-500/50"
  defp glow_border_class(:pink), do: "border border-pink-500/50"

  defp glow_hex(:primary), do: "var(--color-primary)"
  defp glow_hex(:blue), do: "#3b82f6"
  defp glow_hex(:purple), do: "#8b5cf6"
  defp glow_hex(:green), do: "#22c55e"
  defp glow_hex(:red), do: "#ef4444"
  defp glow_hex(:orange), do: "#f97316"
  defp glow_hex(:pink), do: "#ec4899"

  defp glow_shadow(color, :subtle) do
    c = glow_hex(color)
    "0 0 8px #{c}, 0 0 16px #{c}"
  end

  defp glow_shadow(color, :normal) do
    c = glow_hex(color)
    "0 0 15px #{c}, 0 0 30px #{c}"
  end

  defp glow_shadow(color, :intense) do
    c = glow_hex(color)
    "0 0 20px #{c}, 0 0 40px #{c}, 0 0 60px #{c}"
  end

  # ---------------------------------------------------------------------------
  # pulse_button helpers
  # ---------------------------------------------------------------------------

  defp pulse_color_class(:primary), do: "bg-primary text-primary-foreground"
  defp pulse_color_class(:destructive), do: "bg-destructive text-destructive-foreground"
  defp pulse_color_class(:success), do: "bg-green-500 text-white"
  defp pulse_color_class(:warning), do: "bg-yellow-500 text-white"

  defp ping_color_class(:primary), do: "bg-primary"
  defp ping_color_class(:destructive), do: "bg-destructive"
  defp ping_color_class(:success), do: "bg-green-500"
  defp ping_color_class(:warning), do: "bg-yellow-500"
end
