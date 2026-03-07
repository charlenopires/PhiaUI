defmodule PhiaUi.Components.OverlaySurface do
  @moduledoc """
  Overlay surface components for PhiaUI — 6 components for scrims, image overlays,
  gradient overlays, spotlights, and bottom sheets.

  Uses `Phoenix.LiveView.JS` for bottom sheet open/close animations (no custom JS hook).

  ## Components
  - `scrim/1` — fixed-position dark/light overlay
  - `image_scrim/1` — directional gradient scrim over images
  - `gradient_overlay/1` — absolute positioned gradient overlay
  - `spotlight_overlay/1` — radial vignette / spotlight effect
  - `bottom_sheet/1` — slide-up bottom sheet panel
  - `bottom_sheet_trigger/1` — click wrapper to open a bottom sheet
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # 16. scrim/1
  # ---------------------------------------------------------------------------

  attr :color, :string, values: ~w(dark light), default: "dark"
  attr :opacity, :string, values: ~w(sm md lg), default: "md"
  attr :blur, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Fixed-position full-screen scrim overlay.

  ## Examples

      <.scrim color="dark" opacity="md" />

      <.scrim blur>
        <p class="text-white">Content on top of scrim</p>
      </.scrim>
  """
  def scrim(assigns) do
    ~H"""
    <div
      class={cn([
        "fixed inset-0 z-40 pointer-events-none",
        scrim_color_class(@color, @opacity),
        @blur && "backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp scrim_color_class("dark", "sm"), do: "bg-black/20"
  defp scrim_color_class("dark", "md"), do: "bg-black/40"
  defp scrim_color_class("dark", "lg"), do: "bg-black/60"
  defp scrim_color_class("light", "sm"), do: "bg-white/20"
  defp scrim_color_class("light", "md"), do: "bg-white/40"
  defp scrim_color_class("light", "lg"), do: "bg-white/60"

  # ---------------------------------------------------------------------------
  # 17. image_scrim/1
  # ---------------------------------------------------------------------------

  attr :direction, :string, values: ~w(top bottom left right all), default: "bottom"
  attr :intensity, :string, values: ~w(sm md lg full), default: "md"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Directional gradient scrim for image overlays. Place inside a `relative` parent.

  ## Examples

      <div class="relative">
        <img src="/photo.jpg" />
        <.image_scrim direction="bottom" intensity="lg">
          <h2 class="text-white">Caption</h2>
        </.image_scrim>
      </div>
  """
  def image_scrim(assigns) do
    ~H"""
    <div
      class={cn([
        "absolute inset-0 pointer-events-none",
        scrim_gradient_class(@direction, @intensity),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp scrim_gradient_class("bottom", "sm"),   do: "bg-gradient-to-t from-black/30 to-transparent"
  defp scrim_gradient_class("bottom", "md"),   do: "bg-gradient-to-t from-black/60 to-transparent"
  defp scrim_gradient_class("bottom", "lg"),   do: "bg-gradient-to-t from-black/80 to-transparent"
  defp scrim_gradient_class("bottom", "full"), do: "bg-gradient-to-t from-black to-transparent"
  defp scrim_gradient_class("top", "sm"),      do: "bg-gradient-to-b from-black/30 to-transparent"
  defp scrim_gradient_class("top", "md"),      do: "bg-gradient-to-b from-black/60 to-transparent"
  defp scrim_gradient_class("top", "lg"),      do: "bg-gradient-to-b from-black/80 to-transparent"
  defp scrim_gradient_class("top", "full"),    do: "bg-gradient-to-b from-black to-transparent"
  defp scrim_gradient_class("left", "sm"),     do: "bg-gradient-to-r from-black/30 to-transparent"
  defp scrim_gradient_class("left", "md"),     do: "bg-gradient-to-r from-black/60 to-transparent"
  defp scrim_gradient_class("left", "lg"),     do: "bg-gradient-to-r from-black/80 to-transparent"
  defp scrim_gradient_class("left", "full"),   do: "bg-gradient-to-r from-black to-transparent"
  defp scrim_gradient_class("right", "sm"),    do: "bg-gradient-to-l from-black/30 to-transparent"
  defp scrim_gradient_class("right", "md"),    do: "bg-gradient-to-l from-black/60 to-transparent"
  defp scrim_gradient_class("right", "lg"),    do: "bg-gradient-to-l from-black/80 to-transparent"
  defp scrim_gradient_class("right", "full"),  do: "bg-gradient-to-l from-black to-transparent"
  defp scrim_gradient_class("all", "sm"),      do: "bg-black/20"
  defp scrim_gradient_class("all", "md"),      do: "bg-black/40"
  defp scrim_gradient_class("all", "lg"),      do: "bg-black/60"
  defp scrim_gradient_class("all", "full"),    do: "bg-black/80"

  # ---------------------------------------------------------------------------
  # 18. gradient_overlay/1
  # ---------------------------------------------------------------------------

  attr :direction, :string, values: ~w(t b l r tr tl br bl), default: "b"
  attr :from_color, :string, default: "from-black/60"
  attr :to_color, :string, default: "to-transparent"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Absolute positioned gradient overlay with configurable direction and colors.

  ## Examples

      <div class="relative">
        <img src="/bg.jpg" />
        <.gradient_overlay direction="t" from_color="from-primary/80" to_color="to-transparent">
          <p class="text-white">Top gradient</p>
        </.gradient_overlay>
      </div>
  """
  def gradient_overlay(assigns) do
    ~H"""
    <div
      class={cn([
        "absolute inset-0",
        "bg-gradient-to-#{@direction}",
        @from_color,
        @to_color,
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 19. spotlight_overlay/1
  # ---------------------------------------------------------------------------

  attr :size, :string, values: ~w(sm md lg xl), default: "md"
  attr :position, :string, values: ~w(center top bottom), default: "center"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Radial vignette / spotlight overlay — dark edges, bright center.

  ## Examples

      <div class="relative">
        <.spotlight_overlay size="lg" position="center" />
      </div>
  """
  def spotlight_overlay(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={spotlight_style(@size, @position)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp spotlight_style(size, position) do
    {pct_x, pct_y} = spotlight_position(position)
    {w_pct, h_pct} = spotlight_size(size)
    "background: radial-gradient(ellipse #{w_pct} #{h_pct} at #{pct_x} #{pct_y}, transparent 40%, rgba(0,0,0,0.6) 100%);"
  end

  defp spotlight_position("center"), do: {"50%", "50%"}
  defp spotlight_position("top"),    do: {"50%", "20%"}
  defp spotlight_position("bottom"), do: {"50%", "80%"}

  defp spotlight_size("sm"), do: {"30%", "30%"}
  defp spotlight_size("md"), do: {"50%", "50%"}
  defp spotlight_size("lg"), do: {"70%", "70%"}
  defp spotlight_size("xl"), do: {"90%", "90%"}

  # ---------------------------------------------------------------------------
  # 20. bottom_sheet/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :modal, :boolean, default: true
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :header
  slot :footer

  @doc """
  Slide-up bottom sheet panel controlled via JS.open_bottom_sheet/1 and
  JS.close_bottom_sheet/1 helper functions.

  ## Examples

      <.bottom_sheet id="settings-sheet">
        <:header>Settings</:header>
        <p>Sheet content here</p>
        <:footer>
          <button phx-click={close_bottom_sheet("settings-sheet")}>Close</button>
        </:footer>
      </.bottom_sheet>

      <.bottom_sheet_trigger for="settings-sheet">
        <button>Open Sheet</button>
      </.bottom_sheet_trigger>
  """
  def bottom_sheet(assigns) do
    ~H"""
    <div id={@id} class="hidden" role="dialog" aria-modal="true">
      <%!-- Backdrop (modal only) --%>
      <div
        :if={@modal}
        data-part="backdrop"
        class="fixed inset-0 z-40 bg-black/40 backdrop-blur-sm"
        phx-click={close_bottom_sheet(@id)}
      />
      <%!-- Sheet panel --%>
      <div
        data-part="panel"
        class={cn([
          "fixed bottom-0 left-0 right-0 z-50 bg-card rounded-t-2xl shadow-xl",
          "border-t border-border translate-y-full transition-transform duration-300",
          @class
        ])}
      >
        <%!-- Drag handle --%>
        <div class="mx-auto mt-3 h-1.5 w-12 rounded-full bg-muted-foreground/30" />
        <div :if={@header != []} class="px-6 pt-4 pb-2">
          {render_slot(@header)}
        </div>
        <div class="px-6 py-4">
          {render_slot(@inner_block)}
        </div>
        <div :if={@footer != []} class="px-6 pt-2 pb-6">
          {render_slot(@footer)}
        </div>
      </div>
    </div>
    """
  end

  @doc "Returns a JS command to open the bottom sheet with the given id."
  def open_bottom_sheet(id) do
    JS.remove_class("hidden", to: "##{id}")
    |> JS.remove_class("translate-y-full", to: "##{id} [data-part=panel]")
  end

  @doc "Returns a JS command to close the bottom sheet with the given id."
  def close_bottom_sheet(id) do
    JS.add_class("translate-y-full", to: "##{id} [data-part=panel]")
    |> JS.add_class("hidden", to: "##{id}")
  end

  # ---------------------------------------------------------------------------
  # 21. bottom_sheet_trigger/1
  # ---------------------------------------------------------------------------

  attr :for, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Click wrapper that opens the target bottom sheet.

  ## Examples

      <.bottom_sheet_trigger for="settings-sheet">
        <button>Open Settings</button>
      </.bottom_sheet_trigger>
  """
  def bottom_sheet_trigger(assigns) do
    ~H"""
    <div
      class={@class}
      phx-click={open_bottom_sheet(@for)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
